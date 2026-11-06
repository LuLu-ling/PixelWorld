package io.github.zhuzhi09.pclpw.runtime;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import net.kdt.pojavlaunch.Logger;
import net.kdt.pojavlaunch.LwjglGlfwKeycode;
import net.kdt.pojavlaunch.utils.JREUtils;

import org.libsdl.app.SDLActivity;
import org.libsdl.app.SDLSurface;
import org.lwjgl.glfw.CallbackBridge;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Full-screen game view. Runs in its own process (":game"), so when Minecraft exits
 * the launcher is not affected.
 *
 * <p>Touch: in menus a finger is the mouse pointer; in game, drag to look around,
 * tap to use / place, hold to attack / break. On-screen buttons cover movement and common keys.
 */
public class GameActivity extends Activity implements SurfaceHolder.Callback, CallbackBridge.GrabListener {
    public static final String EXTRA_JAVA_HOME = "javaHome";
    public static final String EXTRA_GAME_DIR = "gameDir";
    public static final String EXTRA_LOG_FILE = "logFile";
    public static final String EXTRA_ARGS = "args";
    public static final String EXTRA_SCALE = "scale";
    /** The game reads input from the queue pumped by glfwPollEvents (versions with {@code arguments}) */
    public static final String EXTRA_INPUT_QUEUE = "inputQueue";
    /** The game uses the fixed-function pipeline (before 1.17), so SFPEW wraps the renderer */
    public static final String EXTRA_FFP = "ffp";
    /** LWJGL version of the runtime: 3.3.3, or 3.4.1 for versions that use SDL3 (26.x) */
    public static final String EXTRA_LWJGL = "lwjgl";
    /** One of the GameRuntime renderer names */
    public static final String EXTRA_RENDERER = "renderer";
    /** Zink on Adreno: load the bundled Turnip driver */
    public static final String EXTRA_TURNIP = "turnip";
    /** Show the in-game overlay (frame rate, memory, quick actions) */
    public static final String EXTRA_HUD = "hud";
    /** Show the "ask AI" item in the overlay menu */
    public static final String EXTRA_HUD_AI = "hudAi";
    /** Attach the tail of the game log to AI questions */
    public static final String EXTRA_HUD_AI_LOG = "hudAiLog";
    /** Name of the instance shown in the overlay header */
    public static final String EXTRA_INSTANCE = "instance";

    private static final String TAG = "PCLPW-Game";
    private static boolean sStarted = false;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private FrameLayout root;
    /** The game surface: a SurfaceView, or a TextureView for Zink (see createTextureView) */
    private View surface;
    /** SDL's view of our surface; SDL draws on the native surface we hand it */
    private SDLSurface sdlSurface;
    /** In-game control groups, shown only while the game grabs the cursor */
    private final ArrayList<View> controls = new ArrayList<>();
    /** The in-game overlay; null when disabled in the launcher settings */
    private GameHud hud;
    private Button hudButton;


    /** Adds views to the root and remembers them as in-game controls */
    private final class ControlLayer {
        private final FrameLayout root;

        ControlLayer(FrameLayout root) {
            this.root = root;
        }

        void addView(View v, FrameLayout.LayoutParams lp) {
            v.setVisibility(View.GONE);
            controls.add(v);
            root.addView(v, lp);
        }
    }
    private JoystickView joystick;
    private EditText textInput;
    private float scale = 1f;

    // Touch state
    private int activePointer = -1;
    private float lastX, lastY, downX, downY;
    private long downTime;
    private boolean moved, holding;
    private final Runnable holdStart = () -> {
        holding = true;
        CallbackBridge.sendMouseButton(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT, true);
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        installCrashLogger();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        scale = getIntent().getFloatExtra(EXTRA_SCALE, 1f);

        root = new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);
        if (GameRuntime.ZINK.equals(getIntent().getStringExtra(EXTRA_RENDERER))) {
            surface = createTextureView();
        } else {
            SurfaceView view = new SurfaceView(this);
            view.getHolder().addCallback(this);
            surface = view;
        }
        surface.setFocusable(true);
        surface.setFocusableInTouchMode(true);
        surface.setOnTouchListener(this::onSurfaceTouch);
        surface.setOnGenericMotionListener(this::onMouse);
        root.addView(surface, new FrameLayout.LayoutParams(-1, -1));

        textInput = createTextInput();
        root.addView(textInput, new FrameLayout.LayoutParams(1, 1));

        createControls(root);
        if (getIntent().getBooleanExtra(EXTRA_HUD, true)) {
            try {
                hud = new GameHud(this, root,
                        getIntent().getStringExtra(EXTRA_INSTANCE),
                        getIntent().getStringExtra(EXTRA_RENDERER),
                        getIntent().getStringExtra(EXTRA_LOG_FILE),
                        getIntent().getBooleanExtra(EXTRA_HUD_AI, true),
                        getIntent().getBooleanExtra(EXTRA_HUD_AI_LOG, true));
                hud.setGameFocus(surface);
                hud.onVisibilityListener(this::syncHudButton);
                hud.attach();
            } catch (Throwable e) {
                Log.e(TAG, "In-game HUD failed to start", e);
                hud = null;
            }
        }
        root.addView(createTopBar(), new FrameLayout.LayoutParams(-2, -2, Gravity.TOP | Gravity.END));
        setContentView(root);
        // The decor view exists only after setContentView
        hideSystemBars();
        CallbackBridge.addGrabListener(this);
        // Back gesture = Esc (pause menu / close screen) instead of leaving the game.
        // Android 13+ delivers back through this callback, not as a key event.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getOnBackInvokedDispatcher().registerOnBackInvokedCallback(
                    android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                    () -> {
                        if (hud != null && hud.onBack()) return;
                        CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ESCAPE);
                    });
        }
    }

    private void syncHudButton() {
        if (hudButton == null) return;
        hudButton.setAlpha(hud != null && hud.isVisible() ? 1f : 0.55f);
    }

    /** Java exceptions in this process go to the game log, so the launcher can show them */
    private void installCrashLogger() {
        String path = getIntent().getStringExtra(EXTRA_LOG_FILE);
        if (path == null) return;
        Thread.UncaughtExceptionHandler previous = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler((thread, e) -> {
            try {
                File f = new File(path);
                f.getParentFile().mkdirs();
                try (java.io.FileWriter w = new java.io.FileWriter(f, true)) {
                    w.write("\nPCL.PW runtime: uncaught exception in thread " + thread.getName() + "\n" + Log.getStackTraceString(e) + "\n");
                }
            } catch (Throwable ignored) {
            }
            GameRuntime.recordExit(this, -1, false);
            if (previous != null) previous.uncaughtException(thread, e);
        });
    }

    @Override
    protected void onDestroy() {
        if (hud != null) hud.dispose();
        CallbackBridge.removeGrabListener(this);
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        if (hud != null) hud.onPause();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (hud != null) hud.onResume();
    }

    @SuppressWarnings("deprecation")
    private void hideSystemBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowInsetsController c = getWindow().getInsetsController();
            if (c != null) {
                c.hide(WindowInsets.Type.systemBars());
                c.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } else {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            getWindow().getAttributes().layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
        }
    }

    // ---------- Surface and JVM ----------

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        // The view keeps the screen size; the surface buffer is scaled by setFixedSize, which
        // calls back here with the scaled size. Use the view size, or the scale would be applied again.
        int viewW = surface.getWidth() > 0 ? surface.getWidth() : width;
        int viewH = surface.getHeight() > 0 ? surface.getHeight() : height;
        int w = Math.max(1, Math.round(viewW * scale)), h = Math.max(1, Math.round(viewH * scale));
        if (width != w || height != h) {
            // Wait for the callback with the target size
            holder.setFixedSize(w, h);
            return;
        }
        onSurfaceReady(holder.getSurface(), viewW, viewH, w, h);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        onSurfaceGone();
    }

    /**
     * Zink draws through Vulkan, and a SurfaceView's Vulkan surface reports the display rotation
     * (pre-transform), which Mesa does not apply, so the picture comes out sideways. A TextureView
     * is composed by the app with no rotation (as Amethyst does for Zink).
     */
    private TextureView createTextureView() {
        TextureView view = new TextureView(this);
        view.setOpaque(true);
        view.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            private android.view.Surface native_;

            private void ready(android.graphics.SurfaceTexture texture, int viewW, int viewH) {
                int w = Math.max(1, Math.round(viewW * scale)), h = Math.max(1, Math.round(viewH * scale));
                texture.setDefaultBufferSize(w, h);
                if (native_ == null) native_ = new android.view.Surface(texture);
                onSurfaceReady(native_, viewW, viewH, w, h);
            }

            @Override
            public void onSurfaceTextureAvailable(android.graphics.SurfaceTexture texture, int width, int height) {
                native_ = null;
                ready(texture, width, height);
            }

            @Override
            public void onSurfaceTextureSizeChanged(android.graphics.SurfaceTexture texture, int width, int height) {
                ready(texture, width, height);
            }

            @Override
            public boolean onSurfaceTextureDestroyed(android.graphics.SurfaceTexture texture) {
                onSurfaceGone();
                if (native_ != null) native_.release();
                native_ = null;
                return true;
            }

            @Override
            public void onSurfaceTextureUpdated(android.graphics.SurfaceTexture texture) {
                if (hud != null) hud.onFrame();
            }
        });
        return view;
    }

    /** The game surface has its final (scaled) size */
    private void onSurfaceReady(android.view.Surface native_, int viewW, int viewH, int w, int h) {
        CallbackBridge.physicalWidth = viewW;
        CallbackBridge.physicalHeight = viewH;
        CallbackBridge.windowWidth = w;
        CallbackBridge.windowHeight = h;
        JREUtils.setupBridgeWindow(native_);
        if (usesSdl()) attachSdl(native_, viewW, viewH);
        // Minecraft starts with the --width/--height size and only learns the real one through the
        // size callback; the flag stays set until the game pumps events, so it is safe to send early
        CallbackBridge.sendUpdateWindowSize(w, h);
        if (sStarted) return;
        sStarted = true;
        startGame(w, h);
    }

    private void onSurfaceGone() {
        if (sdlSurface != null) sdlSurface.surfaceDestroyed(null);
        JREUtils.releaseBridgeWindow();
    }

    private boolean usesSdl() {
        return "3.4.1".equals(getIntent().getStringExtra(EXTRA_LWJGL));
    }

    /**
     * Hands our surface to SDL's Android glue (following Amethyst's MinecraftGLSurface). SDL is
     * not started by an SDLActivity here; it becomes active when the game calls SDL_Init.
     */
    private void attachSdl(android.view.Surface native_, int viewW, int viewH) {
        if (sdlSurface == null) {
            org.libsdl.app.SDL.initialize();
            org.libsdl.app.SDL.setContext(this);
            sdlSurface = new SDLSurface(this);
            SDLActivity.externalInitialize(sdlSurface, root, native_);
        } else {
            SDLSurface.setNativeSurface(native_);
        }
        if (CallbackBridge.sdlEnabled) {
            // SDL keeps the unscaled size for input; the drawable size comes from nativeResize
            sdlSurface.surfaceChanged(null, 0, viewW, viewH);
            sdlSurface.nativeResize(CallbackBridge.windowWidth, CallbackBridge.windowHeight);
        }
    }

    private void startGame(int width, int height) {
        Bundle extras = getIntent().getExtras();
        if (extras == null) {
            finish();
            return;
        }
        File javaHome = new File(extras.getString(EXTRA_JAVA_HOME));
        File gameDir = new File(extras.getString(EXTRA_GAME_DIR));
        File logFile = new File(extras.getString(EXTRA_LOG_FILE));
        ArrayList<String> args = new ArrayList<>(Arrays.asList(extras.getStringArray(EXTRA_ARGS)));
        boolean ffp = extras.getBoolean(EXTRA_FFP, false);
        // 1.13+ reads input from a queue on the game thread, where GLFW callbacks called from
        // the UI thread are ignored; LWJGL 2 versions (through lwjglx) poll the state instead
        CallbackBridge.nativeSetUseInputStackQueue(extras.getBoolean(EXTRA_INPUT_QUEUE, true));
        Thread t = new Thread(() -> {
            int code;
            try {
                String lwjgl = extras.getString(EXTRA_LWJGL, GameRuntime.LWJGL_VERSION);
                String renderer = extras.getString(EXTRA_RENDERER, GameRuntime.MOBILEGLUES);
                code = GameRuntime.launch(this, javaHome, gameDir, logFile, args, width, height, ffp, lwjgl, renderer,
                        extras.getBoolean(EXTRA_TURNIP, false));
            } catch (Throwable e) {
                Log.e(TAG, "Launch failed", e);
                Logger.appendToLog("PCL.PW runtime: launch failed: " + Log.getStackTraceString(e));
                code = -1;
            }
            if (code != 0) GameRuntime.recordExit(this, code, false);
            runOnUiThread(this::finish);
            // The JVM cannot be started twice in one process
            System.exit(code);
        }, "Minecraft");
        t.setPriority(Thread.MAX_PRIORITY);
        t.start();
    }

    // ---------- Touch ----------

    private float toWindowX(float x) {
        return x * CallbackBridge.windowWidth / Math.max(1, surface.getWidth());
    }

    private float toWindowY(float y) {
        return y * CallbackBridge.windowHeight / Math.max(1, surface.getHeight());
    }

    @SuppressLint("ClickableViewAccessibility")
    private boolean onSurfaceTouch(View v, MotionEvent e) {
        if (e.isFromSource(android.view.InputDevice.SOURCE_MOUSE)) return onMouse(v, e);
        int action = e.getActionMasked();
        // Two fingers in menus scroll
        if (e.getPointerCount() == 2 && !CallbackBridge.isGrabbing()) {
            if (action == MotionEvent.ACTION_MOVE) {
                float y = (e.getY(0) + e.getY(1)) / 2;
                float dy = y - lastY;
                if (Math.abs(dy) > 24) {
                    CallbackBridge.sendScroll(0, dy > 0 ? 1 : -1);
                    lastY = y;
                }
            } else if (action == MotionEvent.ACTION_POINTER_DOWN) {
                lastY = (e.getY(0) + e.getY(1)) / 2;
                CallbackBridge.sendMouseButton(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT, false);
            }
            return true;
        }
        switch (action) {
            case MotionEvent.ACTION_DOWN: {
                activePointer = e.getPointerId(0);
                lastX = downX = e.getX();
                lastY = downY = e.getY();
                downTime = e.getEventTime();
                moved = false;
                holding = false;
                if (CallbackBridge.isGrabbing()) {
                    handler.postDelayed(holdStart, ViewConfiguration.getLongPressTimeout());
                } else {
                    CallbackBridge.sendCursorPos(toWindowX(e.getX()), toWindowY(e.getY()));
                    CallbackBridge.sendMouseButton(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT, true);
                }
                return true;
            }
            case MotionEvent.ACTION_MOVE: {
                int i = e.findPointerIndex(activePointer);
                if (i < 0) return true;
                float x = e.getX(i), y = e.getY(i);
                if (Math.hypot(x - downX, y - downY) > ViewConfiguration.get(this).getScaledTouchSlop()) {
                    if (!moved && !holding) handler.removeCallbacks(holdStart);
                    moved = true;
                }
                if (CallbackBridge.isGrabbing()) {
                    // Camera turns by screen pixels, so the render scale does not change the sensitivity
                    CallbackBridge.sendCursorPos(CallbackBridge.mouseX + (x - lastX), CallbackBridge.mouseY + (y - lastY));
                } else {
                    CallbackBridge.sendCursorPos(toWindowX(x), toWindowY(y));
                }
                lastX = x;
                lastY = y;
                return true;
            }
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL: {
                handler.removeCallbacks(holdStart);
                if (CallbackBridge.isGrabbing()) {
                    if (holding) {
                        CallbackBridge.sendMouseButton(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT, false);
                    } else if (!moved && action == MotionEvent.ACTION_UP
                            && e.getEventTime() - downTime < ViewConfiguration.getLongPressTimeout()) {
                        clickMouse(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_RIGHT);
                    }
                } else {
                    CallbackBridge.sendMouseButton(LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT, false);
                }
                holding = false;
                activePointer = -1;
                return true;
            }
        }
        return true;
    }

    /** Physical mouse */
    private boolean onMouse(View v, MotionEvent e) {
        if (!e.isFromSource(android.view.InputDevice.SOURCE_MOUSE)) return false;
        switch (e.getActionMasked()) {
            case MotionEvent.ACTION_HOVER_MOVE:
            case MotionEvent.ACTION_MOVE:
                if (CallbackBridge.isGrabbing() && surface.hasPointerCapture()) {
                    CallbackBridge.sendCursorPos(CallbackBridge.mouseX + e.getX(), CallbackBridge.mouseY + e.getY());
                } else {
                    CallbackBridge.sendCursorPos(toWindowX(e.getX()), toWindowY(e.getY()));
                }
                return true;
            case MotionEvent.ACTION_BUTTON_PRESS:
            case MotionEvent.ACTION_BUTTON_RELEASE: {
                boolean down = e.getActionMasked() == MotionEvent.ACTION_BUTTON_PRESS;
                int b = e.getActionButton();
                int glfw = b == MotionEvent.BUTTON_SECONDARY ? LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_RIGHT
                        : b == MotionEvent.BUTTON_TERTIARY ? LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_MIDDLE
                        : LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT;
                CallbackBridge.sendMouseButton(glfw, down);
                return true;
            }
            case MotionEvent.ACTION_SCROLL:
                CallbackBridge.sendScroll(e.getAxisValue(MotionEvent.AXIS_HSCROLL), e.getAxisValue(MotionEvent.AXIS_VSCROLL));
                return true;
        }
        return false;
    }

    private void clickMouse(int button) {
        CallbackBridge.sendMouseButton(button, true);
        handler.postDelayed(() -> CallbackBridge.sendMouseButton(button, false), 50);
    }

    @Override
    public void onGrabState(boolean grabbing) {
        for (View v : controls) v.setVisibility(grabbing ? View.VISIBLE : View.GONE);
        // Opening a menu must not leave movement keys held down
        if (!grabbing && joystick != null) joystick.reset();
        if (hud != null) hud.onGrabState(grabbing);
        if (grabbing) {
            // Center the virtual cursor so camera movement starts from a known point
            CallbackBridge.sendCursorPos(CallbackBridge.windowWidth / 2f, CallbackBridge.windowHeight / 2f);
            if (hasHardwareMouse()) surface.requestPointerCapture();
        } else if (surface.hasPointerCapture()) {
            surface.releasePointerCapture();
        }
    }

    private boolean hasHardwareMouse() {
        for (int id : android.view.InputDevice.getDeviceIds()) {
            android.view.InputDevice d = android.view.InputDevice.getDevice(id);
            if (d != null && d.supportsSource(android.view.InputDevice.SOURCE_MOUSE) && !d.isVirtual()) return true;
        }
        return false;
    }

    // ---------- Keyboard ----------

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (hud != null && hud.hasInputFocus()) return super.dispatchKeyEvent(event);
        if (textInput.hasFocus() && event.getKeyCode() != KeyEvent.KEYCODE_BACK
                && event.getKeyCode() != KeyEvent.KEYCODE_DEL && event.getKeyCode() != KeyEvent.KEYCODE_ENTER) {
            return super.dispatchKeyEvent(event);
        }
        int glfw = Keys.toGlfw(event.getKeyCode());
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK && event.getSource() != android.view.InputDevice.SOURCE_MOUSE) {
            glfw = LwjglGlfwKeycode.GLFW_KEY_ESCAPE;
        }
        if (glfw == 0) return super.dispatchKeyEvent(event);
        boolean down = event.getAction() == KeyEvent.ACTION_DOWN;
        if (event.getAction() == KeyEvent.ACTION_MULTIPLE) return true;
        CallbackBridge.setModifiers(glfw, down);
        char ch = (char) event.getUnicodeChar();
        CallbackBridge.sendKeycode(glfw, textInput.hasFocus() ? 0 : ch, 0, CallbackBridge.getCurrentMods(), down);
        return true;
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onBackPressed() {
        // Android 12 and older
        if (hud != null && hud.onBack()) return;
        CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ESCAPE);
    }

    /** Invisible text field for the soft keyboard, forwarding typed characters */
    private EditText createTextInput() {
        EditText t = new EditText(this);
        t.setAlpha(0f);
        t.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        t.setImeOptions(EditorInfo.IME_FLAG_NO_EXTRACT_UI | EditorInfo.IME_FLAG_NO_FULLSCREEN | EditorInfo.IME_ACTION_DONE);
        t.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
                for (int i = 0; i < before; i++) CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_BACKSPACE);
                for (int i = start; i < start + count; i++) CallbackBridge.sendChar(s.charAt(i), CallbackBridge.getCurrentMods());
            }
            @Override public void afterTextChanged(Editable s) {
                // Keep the field short; characters were already sent
                if (s.length() > 64) {
                    t.removeTextChangedListener(this);
                    s.clear();
                    t.addTextChangedListener(this);
                }
            }
        });
        t.setOnEditorActionListener((v, actionId, event) -> {
            CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ENTER);
            return true;
        });
        return t;
    }

    private void toggleKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (textInput.hasFocus()) {
            imm.hideSoftInputFromWindow(textInput.getWindowToken(), 0);
            textInput.clearFocus();
            surface.requestFocus();
        } else {
            textInput.getText().clear();
            textInput.requestFocus();
            imm.showSoftInput(textInput, InputMethodManager.SHOW_IMPLICIT);
        }
    }

    // ---------- On-screen controls ----------

    private int dp(float v) {
        return Math.round(v * getResources().getDisplayMetrics().density);
    }

    private Button button(String label, int size) {
        Button b = new Button(this);
        b.setText(label);
        b.setAllCaps(false);
        b.setTextColor(Color.WHITE);
        b.setTextSize(13);
        b.setPadding(0, 0, 0, 0);
        b.setMinWidth(0);
        b.setMinHeight(0);
        b.setMinimumWidth(0);
        b.setMinimumHeight(0);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(0x55000000);
        bg.setStroke(dp(1), 0x88FFFFFF);
        bg.setCornerRadius(dp(10));
        b.setBackground(bg);
        b.setLayoutParams(new LinearLayout.LayoutParams(dp(size), dp(size)));
        return b;
    }

    /** A button that holds a key while pressed */
    @SuppressLint("ClickableViewAccessibility")
    private Button keyButton(String label, int key, int size) {
        Button b = button(label, size);
        b.setOnTouchListener((v, e) -> {
            int a = e.getActionMasked();
            if (a == MotionEvent.ACTION_DOWN) {
                v.setPressed(true);
                v.setAlpha(0.55f);
                CallbackBridge.setModifiers(key, true);
                CallbackBridge.sendKeyPress(key, CallbackBridge.getCurrentMods(), true);
            } else if (a == MotionEvent.ACTION_UP || a == MotionEvent.ACTION_CANCEL) {
                v.setPressed(false);
                v.setAlpha(1f);
                CallbackBridge.setModifiers(key, false);
                CallbackBridge.sendKeyPress(key, CallbackBridge.getCurrentMods(), false);
            }
            return true;
        });
        return b;
    }

    /** A button that toggles a key (sneak) */
    private Button toggleButton(String label, int key, int size) {
        Button b = button(label, size);
        final boolean[] on = {false};
        b.setOnClickListener(v -> {
            on[0] = !on[0];
            b.setAlpha(on[0] ? 1f : 0.7f);
            CallbackBridge.setModifiers(key, on[0]);
            CallbackBridge.sendKeyPress(key, CallbackBridge.getCurrentMods(), on[0]);
        });
        b.setAlpha(0.7f);
        return b;
    }

    /**
     * Adds the control groups directly to the root. A full-screen container would become the
     * touch target of the first finger and then receive every later finger as well, so the
     * game view could not be dragged while a button is held.
     */
    private void createControls(FrameLayout root) {
        ControlLayer layer = new ControlLayer(root);
        int s = 56;

        // Movement joystick, bottom left; push to the edge to sprint
        joystick = new JoystickView(this);
        FrameLayout.LayoutParams lpStick = new FrameLayout.LayoutParams(dp(160), dp(160), Gravity.BOTTOM | Gravity.START);
        lpStick.setMargins(dp(36), 0, 0, dp(28));
        layer.addView(joystick, lpStick);

        // Actions, bottom right
        LinearLayout actions = new LinearLayout(this);
        actions.setOrientation(LinearLayout.VERTICAL);
        actions.setGravity(Gravity.END);
        LinearLayout row1 = new LinearLayout(this);
        row1.addView(keyButton("列表", LwjglGlfwKeycode.GLFW_KEY_TAB, s));
        row1.addView(keyButton("副手", LwjglGlfwKeycode.GLFW_KEY_F, s));
        row1.addView(keyButton("丢弃", LwjglGlfwKeycode.GLFW_KEY_Q, s));
        row1.addView(keyButton("背包", LwjglGlfwKeycode.GLFW_KEY_E, s));
        actions.addView(row1);
        LinearLayout row2 = new LinearLayout(this);
        row2.setGravity(Gravity.BOTTOM);
        row2.addView(toggleButton("潜行", LwjglGlfwKeycode.GLFW_KEY_LEFT_SHIFT, s));
        row2.addView(keyButton("跳跃", LwjglGlfwKeycode.GLFW_KEY_SPACE, s + 24));
        actions.addView(row2);
        FrameLayout.LayoutParams lpAct = new FrameLayout.LayoutParams(-2, -2, Gravity.BOTTOM | Gravity.END);
        lpAct.setMargins(0, 0, dp(28), dp(24));
        layer.addView(actions, lpAct);

        // Hotbar and view, bottom center (above the hotbar)
        LinearLayout hotbar = new LinearLayout(this);
        Button prev = button("◀", 44);
        prev.setOnClickListener(v -> CallbackBridge.sendScroll(0, 1));
        Button next = button("▶", 44);
        next.setOnClickListener(v -> CallbackBridge.sendScroll(0, -1));
        hotbar.addView(prev);
        hotbar.addView(keyButton("视角", LwjglGlfwKeycode.GLFW_KEY_F5, 44));
        hotbar.addView(keyButton("隐藏", LwjglGlfwKeycode.GLFW_KEY_F1, 44));
        hotbar.addView(next);
        FrameLayout.LayoutParams lpHot = new FrameLayout.LayoutParams(-2, -2, Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
        lpHot.setMargins(0, 0, 0, dp(64));
        layer.addView(hotbar, lpHot);
    }

    /** Always visible: pause, chat, keyboard and the assistant toggle */
    private View createTopBar() {
        LinearLayout bar = new LinearLayout(this);
        bar.setPadding(0, dp(8), dp(8), 0);
        Button esc = button("暂停", 48);
        esc.setOnClickListener(v -> CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ESCAPE));
        Button chat = button("聊天", 48);
        chat.setOnClickListener(v -> {
            CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_T);
            handler.postDelayed(this::toggleKeyboard, 150);
        });
        Button keyboard = button("键盘", 48);
        keyboard.setOnClickListener(v -> toggleKeyboard());
        bar.addView(esc);
        bar.addView(chat);
        bar.addView(keyboard);
        if (hud != null) {
            hudButton = button("助手", 48);
            hudButton.setOnClickListener(v -> hud.toggleVisible());
            bar.addView(hudButton);
            syncHudButton();
        }
        TextView spacer = new TextView(this);
        bar.addView(spacer);
        return bar;
    }
}
