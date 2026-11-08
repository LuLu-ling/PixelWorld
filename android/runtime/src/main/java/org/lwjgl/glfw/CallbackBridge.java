package org.lwjgl.glfw;

import android.content.ClipData;
import android.content.ClipDescription;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.DisplayMetrics;
import android.view.Choreographer;
import android.view.MotionEvent;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;

import net.kdt.pojavlaunch.EfficientAndroidLWJGLKeycode;
import net.kdt.pojavlaunch.Logger;
import net.kdt.pojavlaunch.LwjglGlfwKeycode;

import org.libsdl.app.SDLActivity;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.ArrayList;

import dalvik.annotation.optimization.CriticalNative;

/**
 * Bridge between Android input and the game running inside the JVM: the GLFW stub, and SDL3
 * for versions that use it (26.x). Derived from Amethyst-Android's CallbackBridge (LGPL-3.0);
 * gamepad remapping removed.
 */
public class CallbackBridge {
    public static final Choreographer sChoreographer = Choreographer.getInstance();
    private static boolean isGrabbing = false;
    private static final ArrayList<GrabListener> grabListeners = new ArrayList<>();

    public static final int CLIPBOARD_COPY = 2000;
    public static final int CLIPBOARD_PASTE = 2001;
    public static final int CLIPBOARD_OPEN = 2002;

    public static volatile int windowWidth, windowHeight;
    public static volatile int physicalWidth, physicalHeight;
    public static float mouseX, mouseY;
    /** Cursor movement since the last event, sent to SDL while the cursor is grabbed */
    public static float deltaX, deltaY;
    /** The game initialized SDL3, so input also goes to SDL */
    public static volatile boolean sdlEnabled = false;
    private static int sMouseButtonState = 0;
    public volatile static boolean holdingAlt, holdingCapslock, holdingCtrl, holdingNumlock, holdingShift;

    /** Application context, used for the clipboard and for opening links */
    public static Context sContext;

    public static final ByteBuffer sGamepadButtonBuffer;
    public static final FloatBuffer sGamepadAxisBuffer;

    public interface GrabListener {
        void onGrabState(boolean isGrabbing);
    }

    public static void sendCursorPos(float x, float y) {
        deltaX = x - mouseX;
        deltaY = y - mouseY;
        mouseX = x;
        mouseY = y;
        nativeSendCursorPos(mouseX, mouseY);
        if (!sdlEnabled) return;
        // SDL reads absolute positions in menus and relative motion while grabbed
        if (isGrabbing) SDLActivity.onNativeMouse(0, MotionEvent.ACTION_MOVE, deltaX, deltaY, true);
        else SDLActivity.onNativeMouse(0, MotionEvent.ACTION_MOVE, x, y, false);
    }

    public static void sendKeycode(int keycode, char keychar, int scancode, int modifiers, boolean isDown) {
        if (keycode != 0) nativeSendKey(keycode, scancode, isDown ? 1 : 0, modifiers);
        if (isDown && keychar != 0 && !Character.isISOControl(keychar)) {
            nativeSendCharMods(keychar, modifiers);
            nativeSendChar(keychar);
        }
        if (!sdlEnabled || keycode == 0) return;
        int android = EfficientAndroidLWJGLKeycode.getAndroidKeycode(keycode);
        if (isDown) SDLActivity.onNativeKeyDown(android);
        else SDLActivity.onNativeKeyUp(android);
    }

    public static void sendChar(char keychar, int modifiers) {
        nativeSendCharMods(keychar, modifiers);
        nativeSendChar(keychar);
        if (!sdlEnabled) return;
        int android = EfficientAndroidLWJGLKeycode.getAndroidKeycode(keychar);
        SDLActivity.onNativeKeyDown(android);
        SDLActivity.onNativeKeyUp(android);
    }

    public static void sendKeyPress(int keyCode, int modifiers, boolean status) {
        sendKeycode(keyCode, '\u0000', 0, modifiers, status);
    }

    public static void sendKeyPress(int keyCode) {
        sendKeyPress(keyCode, getCurrentMods(), true);
        sendKeyPress(keyCode, getCurrentMods(), false);
    }

    public static void sendMouseButton(int button, boolean status) {
        nativeSendMouseButton(button, status ? 1 : 0, getCurrentMods());
        if (!sdlEnabled) return;
        int bit;
        switch (button) {
            case LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_LEFT: bit = MotionEvent.BUTTON_PRIMARY; break;
            case LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_RIGHT: bit = MotionEvent.BUTTON_SECONDARY; break;
            case LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_MIDDLE: bit = MotionEvent.BUTTON_TERTIARY; break;
            // SDL swaps back and forward
            case LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_5: bit = MotionEvent.BUTTON_BACK; break;
            case LwjglGlfwKeycode.GLFW_MOUSE_BUTTON_4: bit = MotionEvent.BUTTON_FORWARD; break;
            default: return;
        }
        // SDL expects MotionEvent.getButtonState(): the buttons still held after this event
        if (status) sMouseButtonState |= bit;
        else sMouseButtonState &= ~bit;        SDLActivity.onNativeMouse(sMouseButtonState, status ? MotionEvent.ACTION_DOWN : MotionEvent.ACTION_UP,
                mouseX, mouseY, false);
    }

    public static void sendScroll(float xoffset, float yoffset) {
        nativeSendScroll(xoffset, yoffset);
        if (sdlEnabled) SDLActivity.onNativeMouse(0, MotionEvent.ACTION_SCROLL, xoffset, yoffset, false);
    }

    public static void sendUpdateWindowSize(int w, int h) {
        nativeSendScreenSize(w, h);
    }

    public static boolean isGrabbing() {
        return isGrabbing;
    }

    // Called from JRE side
    @Keep
    @SuppressWarnings("unused")
    public static @Nullable String accessAndroidClipboard(int type, String copy) {
        if (sContext == null) return null;
        ClipboardManager clipboard = (ClipboardManager) sContext.getSystemService(Context.CLIPBOARD_SERVICE);
        switch (type) {
            case CLIPBOARD_COPY:
                clipboard.setPrimaryClip(ClipData.newPlainText("Copy", copy));
                return null;
            case CLIPBOARD_PASTE:
                if (clipboard.hasPrimaryClip() && clipboard.getPrimaryClipDescription() != null
                        && clipboard.getPrimaryClipDescription().hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN)) {
                    CharSequence text = clipboard.getPrimaryClip().getItemAt(0).getText();
                    return text == null ? "" : text.toString();
                }
                return "";
            case CLIPBOARD_OPEN:
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(copy)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                sContext.startActivity(intent);
                return null;
            default:
                return null;
        }
    }

    public static final int NOTIF_TYPE_SDL = 0;
    public static final int ACTION_INIT_LAUNCHER_INTEGRATION = 0;

    // Called from JRE side when the game calls SDL_Init (the SDLInit override in the LWJGL 3.4 stub)
    @Keep
    @SuppressWarnings("unused")
    public static boolean notifyLauncher(int type, int... action) {
        if (type != NOTIF_TYPE_SDL || action.length == 0 || action[0] != ACTION_INIT_LAUNCHER_INTEGRATION) return false;
        if (sdlEnabled) return true;
        try {
            System.loadLibrary("SDL3");
            org.libsdl.app.SDL.setupJNI();
            sdlEnabled = true;
            // SDL needs the surface size for input; the surface itself is attached by GameActivity
            if (SDLActivity.getSDLSurface() != null) SDLActivity.getSDLSurface().nativeResize(windowWidth, windowHeight);
            Logger.appendToLog("Pixel World runtime: SDL enabled");
            return true;
        } catch (Throwable e) {
            Logger.appendToLog("Pixel World runtime: cannot initialize SDL: " + e);
            return false;
        }
    }

    public static int getCurrentMods() {
        int mods = 0;
        if (holdingAlt) mods |= LwjglGlfwKeycode.GLFW_MOD_ALT;
        if (holdingCapslock) mods |= LwjglGlfwKeycode.GLFW_MOD_CAPS_LOCK;
        if (holdingCtrl) mods |= LwjglGlfwKeycode.GLFW_MOD_CONTROL;
        if (holdingNumlock) mods |= LwjglGlfwKeycode.GLFW_MOD_NUM_LOCK;
        if (holdingShift) mods |= LwjglGlfwKeycode.GLFW_MOD_SHIFT;
        return mods;
    }

    public static void setModifiers(int keyCode, boolean isDown) {
        switch (keyCode) {
            case LwjglGlfwKeycode.GLFW_KEY_LEFT_SHIFT: holdingShift = isDown; return;
            case LwjglGlfwKeycode.GLFW_KEY_LEFT_CONTROL: holdingCtrl = isDown; return;
            case LwjglGlfwKeycode.GLFW_KEY_LEFT_ALT: holdingAlt = isDown; return;
            case LwjglGlfwKeycode.GLFW_KEY_CAPS_LOCK: holdingCapslock = isDown; return;
            case LwjglGlfwKeycode.GLFW_KEY_NUM_LOCK: holdingNumlock = isDown;
        }
    }

    // Called from JRE side
    @Keep
    @SuppressWarnings("unused")
    private static void onDirectInputEnable() {
    }

    // Called from JRE side
    @Keep
    @SuppressWarnings("unused")
    private static void onGrabStateChanged(final boolean grabbing) {
        isGrabbing = grabbing;        sChoreographer.postFrameCallbackDelayed((time) -> {
            if (isGrabbing != grabbing) return;
            synchronized (grabListeners) {
                for (GrabListener g : grabListeners) g.onGrabState(grabbing);
            }
        }, 16);
    }

    public static void addGrabListener(GrabListener listener) {
        synchronized (grabListeners) {
            listener.onGrabState(isGrabbing);
            grabListeners.add(listener);
        }
    }

    public static void removeGrabListener(GrabListener listener) {
        synchronized (grabListeners) {
            grabListeners.remove(listener);
        }
    }

    private static FloatBuffer createGamepadAxisBuffer() {
        ByteBuffer axisByteBuffer = nativeCreateGamepadAxisBuffer();
        return axisByteBuffer.order(ByteOrder.LITTLE_ENDIAN).asFloatBuffer();
    }

    // Used to implement glfwGetWindowContentScale
    @Keep
    @SuppressWarnings("unused")
    private static float getAndroidDPI() {
        DisplayMetrics metrics = new DisplayMetrics();
        metrics.setToDefaults();
        return metrics.density;
    }

    @Keep @CriticalNative public static native void nativeSetUseInputStackQueue(boolean useInputStackQueue);
    @Keep @CriticalNative private static native boolean nativeSendChar(char codepoint);
    @Keep @CriticalNative private static native boolean nativeSendCharMods(char codepoint, int mods);
    @Keep @CriticalNative private static native void nativeSendKey(int key, int scancode, int action, int mods);
    @Keep @CriticalNative private static native void nativeSendCursorPos(float x, float y);
    @Keep @CriticalNative private static native void nativeSendMouseButton(int button, int action, int mods);
    @Keep @CriticalNative private static native void nativeSendScroll(double xoffset, double yoffset);
    @Keep @CriticalNative private static native void nativeSendScreenSize(int width, int height);
    public static native void nativeSetWindowAttrib(int attrib, int value);
    private static native ByteBuffer nativeCreateGamepadButtonBuffer();
    private static native ByteBuffer nativeCreateGamepadAxisBuffer();

    static {
        System.loadLibrary("pojavexec");
        sGamepadButtonBuffer = nativeCreateGamepadButtonBuffer();
        sGamepadAxisBuffer = createGamepadAxisBuffer();
    }
}
