package io.github.zhuzhi09.pclpw.runtime;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowInsets;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import net.kdt.pojavlaunch.LwjglGlfwKeycode;

import org.lwjgl.glfw.CallbackBridge;

import java.io.File;
import java.io.RandomAccessFile;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

/**
 * The in-game assistant: a small ball that can be dragged anywhere and snaps to the nearest side.
 * Tapping it opens a menu next to it; after a few idle seconds it fades and tucks half behind the
 * screen edge so it does not cover the game.
 *
 * <p>It lives in the same view hierarchy as the game surface, so it needs no overlay permission
 * and disappears with the game. Only the views themselves receive touches.
 */
final class GameHud {

    // Translucent panels with thin white outlines; the game shows through behind them
    private static final int CARD = 0x75181818;
    private static final int FILL = 0x1AFFFFFF;
    private static final int PRESSED = 0x40FFFFFF;
    private static final int BORDER = 0xE0FFFFFF;
    private static final int TEXT = 0xFFFFFFFF;
    private static final int MUTED = 0xBDFFFFFF;
    private static final int OK = 0xFF8FE3A6;
    private static final int WARN = 0xFFFFD27A;
    private static final int BAD = 0xFFFFB4AB;

    private static final long FADE_DELAY_MS = 4000;
    private static final float FADED_ALPHA = 0.45f;
    private static final int BALL_DP = 46;
    private static final int EDGE_DP = 10;

    private enum Mode { NONE, MENU, INFO }

    private final Activity activity;
    private final FrameLayout parent;
    private final SharedPreferences prefs;
    private final HudMetrics metrics;
    private final String instance;
    private final String renderer;
    private final String logFile;
    private final boolean aiEnabled;
    private final boolean attachLog;

    private final View ball;
    private final LinearLayout menu;
    private final LinearLayout infoPanel;
    private final View scrim;

    private TextView fpsValue;
    private TextView fpsHint;
    private SparklineView graph;
    private TextView memValue;
    private TextView systemValue;
    private TextView swapValue;
    private TextView cpuValue;
    private TextView tempLabel;
    private TextView tempValue;
    private TextView timeValue;
    private TextView detailValue;

    /** Always-on one-line stats at the top of the screen. */
    private final TextView compactView;
    private TextView compactItem;
    private boolean compact;

    private HudMetrics.Sample lastSample;
    private Mode mode = Mode.NONE;
    private boolean visible;
    private boolean sampling;
    private boolean tucked;
    /** Side the ball rests on, and its top edge in dp (kept in dp so rotation and restarts agree). */
    private boolean startSide;
    private int topDp;
    private ValueAnimator moveAnimator;
    private View gameFocus;
    private Runnable onVisibilityChanged;
    private GameAiDialog aiDialog;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable fadeRunnable = this::tuck;
    private final View.OnLayoutChangeListener parentLayout = this::onParentLayout;

    GameHud(Activity activity, FrameLayout parent, String instance, String renderer, String logFile,
            boolean aiEnabled, boolean attachLog) {
        this.activity = activity;
        this.parent = parent;
        this.prefs = activity.getSharedPreferences("pclpw_hud", Activity.MODE_PRIVATE);
        this.instance = TextUtils.isEmpty(instance) ? "游戏" : instance;
        this.renderer = renderer == null ? "" : renderer;
        this.logFile = logFile;
        this.aiEnabled = aiEnabled;
        this.attachLog = attachLog;
        this.visible = prefs.getBoolean("visible", true);
        this.compact = prefs.getBoolean("compact", false);
        this.startSide = !"end".equals(prefs.getString("side", "start"));
        // Older versions stored pixels under "top"; the dp value has its own key
        this.topDp = prefs.getInt("topDp", 72);
        this.metrics = new HudMetrics(activity);
        // Frame counting is only possible when the renderer draws through a TextureView (Zink);
        // SurfaceView renderers do not tell the app when a frame is presented.
        metrics.setFpsAvailable("zink".equals(this.renderer));

        ball = buildBall();
        compactView = buildCompact();
        menu = buildMenu();
        infoPanel = buildInfoPanel();

        scrim = new View(activity);
        scrim.setBackgroundColor(0x14000000);
        scrim.setVisibility(View.GONE);
        scrim.setClickable(true);
        scrim.setOnClickListener(v -> setMode(Mode.NONE));
    }

    // ---------- construction ----------

    private View buildBall() {
        View v = new View(activity);
        GradientDrawable outer = new GradientDrawable();
        outer.setShape(GradientDrawable.OVAL);
        outer.setColor(0xFFFFFFFF);
        outer.setStroke(dp(1), 0xFFC8C8C8);
        GradientDrawable inner = new GradientDrawable();
        inner.setShape(GradientDrawable.OVAL);
        inner.setColor(0xFF4A4A4A);
        LayerDrawable layers = new LayerDrawable(new Drawable[]{outer, inner});
        int inset = dp(16);
        layers.setLayerInset(1, inset, inset, inset, inset);
        v.setBackground(layers);
        v.setElevation(dp(4));
        v.setContentDescription("游戏助手，点击打开菜单，拖动可以移动");
        installDrag(v);
        return v;
    }

    private TextView buildCompact() {
        TextView v = label("--", 11, TEXT, true, false);
        v.setSingleLine(true);
        v.setGravity(Gravity.CENTER);
        v.setPadding(dp(10), dp(3), dp(10), dp(3));
        GradientDrawable bg = rounded(CARD, 999);
        bg.setStroke(Math.max(1, dp(1)), BORDER);
        v.setBackground(bg);
        v.setClickable(true);
        v.setContentDescription("性能信息，点击查看详情");
        v.setOnClickListener(x -> setMode(Mode.INFO));
        return v;
    }

    private String compactLabel() {
        return compact ? "关闭常驻简略信息" : "常驻简略信息";
    }

    /** Turns the always-on stats line on or off; it stays even when the ball is hidden. */
    private void setCompact(boolean value) {
        compact = value;
        prefs.edit().putBoolean("compact", value).apply();
        if (compactItem != null) compactItem.setText(compactLabel());
        compactView.setVisibility(value ? View.VISIBLE : View.GONE);
        if (value) {
            parent.bringChildToFront(compactView);
            startSampling();
        } else if (!visible) {
            stopSampling();
        }
        setMode(Mode.NONE);
    }

    private LinearLayout buildMenu() {
        LinearLayout card = card(176);
        card.setPadding(dp(6), dp(6), dp(6), dp(6));
        if (aiEnabled) card.addView(menuItem("问 AI", v -> openAiDialog()));
        card.addView(menuItem("基础信息", v -> setMode(Mode.INFO)));
        compactItem = (TextView) menuItem(compactLabel(), v -> setCompact(!compact));
        card.addView(compactItem);
        card.addView(menuItem("回到启动器", v -> {
            setMode(Mode.NONE);
            openLauncher();
        }));
        card.addView(menuItem("隐藏助手", v -> setVisible(false)));
        return card;
    }

    private LinearLayout buildInfoPanel() {
        LinearLayout card = card(300);
        card.setPadding(dp(8), dp(8), dp(8), dp(8));

        LinearLayout header = new LinearLayout(activity);
        header.setOrientation(LinearLayout.HORIZONTAL);
        header.setGravity(Gravity.CENTER_VERTICAL);
        header.setPadding(dp(6), 0, 0, dp(6));
        LinearLayout titles = new LinearLayout(activity);
        titles.setOrientation(LinearLayout.VERTICAL);
        titles.addView(label("基础信息", 13, TEXT, false, true));
        TextView subtitle = label(instance + rendererName(), 11, MUTED, false, false);
        subtitle.setSingleLine(true);
        subtitle.setEllipsize(TextUtils.TruncateAt.END);
        titles.addView(subtitle);
        header.addView(titles, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        TextView close = button("关闭", v -> setMode(Mode.NONE), false);
        header.addView(close);
        card.addView(header);

        LinearLayout body = section();
        LinearLayout fpsRow = new LinearLayout(activity);
        fpsRow.setOrientation(LinearLayout.HORIZONTAL);
        fpsRow.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout fpsBlock = new LinearLayout(activity);
        fpsBlock.setOrientation(LinearLayout.VERTICAL);
        fpsValue = label("--", 24, TEXT, true, true);
        fpsValue.setIncludeFontPadding(false);
        fpsBlock.addView(fpsValue);
        fpsBlock.addView(label("FPS", 10, MUTED, false, false));
        fpsRow.addView(fpsBlock, new LinearLayout.LayoutParams(dp(72), LinearLayout.LayoutParams.WRAP_CONTENT));
        graph = new SparklineView(activity);
        LinearLayout.LayoutParams graphLp = new LinearLayout.LayoutParams(0, dp(38), 1);
        graphLp.setMarginStart(dp(8));
        fpsRow.addView(graph, graphLp);
        body.addView(fpsRow);
        fpsHint = label("当前渲染器无法读取帧率", 10, MUTED, false, false);
        fpsHint.setVisibility(View.GONE);
        body.addView(fpsHint);
        card.addView(body);

        LinearLayout memory = section();
        memValue = memoryRow(memory, "Java 已用 / 上限");
        systemValue = memoryRow(memory, "系统已用 / 总内存");
        swapValue = memoryRow(memory, "交换已用 / 总交换");
        card.addView(memory);

        LinearLayout more = section();
        LinearLayout metricsRow = new LinearLayout(activity);
        metricsRow.setOrientation(LinearLayout.HORIZONTAL);
        cpuValue = metricCell(metricsRow, "CPU");
        LinearLayout tempCell = new LinearLayout(activity);
        tempCell.setOrientation(LinearLayout.VERTICAL);
        tempLabel = label("温度", 10, MUTED, false, false);
        tempCell.addView(tempLabel);
        tempValue = label("--", 14, TEXT, true, false);
        tempCell.addView(tempValue);
        metricsRow.addView(tempCell, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        timeValue = metricCell(metricsRow, "运行时长");
        more.addView(metricsRow);
        detailValue = label("", 10, MUTED, false, false);
        more.addView(detailValue);
        card.addView(more);

        LinearLayout actions = new LinearLayout(activity);
        actions.setOrientation(LinearLayout.HORIZONTAL);
        actions.setPadding(0, dp(6), 0, 0);
        actions.addView(button("暂停游戏", v -> {
            setMode(Mode.NONE);
            CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ESCAPE);
        }, true));
        actions.addView(button("回到启动器", v -> {
            setMode(Mode.NONE);
            openLauncher();
        }, true));
        card.addView(actions);
        return card;
    }

    private LinearLayout card(int widthDp) {
        LinearLayout card = new LinearLayout(activity);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(rounded(CARD, 14));
        card.setElevation(dp(8));
        card.setVisibility(View.GONE);
        card.setClickable(true);
        card.setTag(widthDp);
        return card;
    }

    private LinearLayout section() {
        LinearLayout s = new LinearLayout(activity);
        s.setOrientation(LinearLayout.VERTICAL);
        s.setBackground(outlined(FILL, 10));
        s.setPadding(dp(12), dp(10), dp(12), dp(10));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.bottomMargin = dp(6);
        s.setLayoutParams(lp);
        return s;
    }

    private View menuItem(String title, View.OnClickListener listener) {
        TextView row = label(title, 13, TEXT, false, false);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(14), 0, dp(14), 0);
        row.setMinHeight(dp(42));
        row.setBackground(pressable(10));
        row.setClickable(true);
        row.setOnClickListener(listener);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(2);
        lp.bottomMargin = dp(2);
        row.setLayoutParams(lp);
        return row;
    }

    private TextView button(String text, View.OnClickListener listener, boolean filled) {
        TextView v = label(text, 12, TEXT, false, false);
        v.setGravity(Gravity.CENTER);
        v.setPadding(dp(12), 0, dp(12), 0);
        v.setMinHeight(dp(34));
        v.setBackground(pressable(9));
        v.setClickable(true);
        v.setOnClickListener(listener);
        LinearLayout.LayoutParams lp = filled
                ? new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1)
                : new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        if (filled) lp.setMarginEnd(dp(6));
        v.setLayoutParams(lp);
        return v;
    }

    /** Adds a label/value pair to a horizontal row and returns the value view. */
    private TextView metricCell(LinearLayout row, String title) {
        LinearLayout cell = new LinearLayout(activity);
        cell.setOrientation(LinearLayout.VERTICAL);
        cell.addView(label(title, 10, MUTED, false, false));
        TextView value = label("--", 14, TEXT, true, false);
        cell.addView(value);
        row.addView(cell, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        return value;
    }

    /** Adds a full-width label/value pair and returns the value view. */
    private TextView memoryRow(LinearLayout parent, String title) {
        LinearLayout row = new LinearLayout(activity);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, dp(2), 0, dp(2));
        row.addView(label(title, 11, MUTED, false, false),
                new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        TextView value = label("--", 12, TEXT, true, false);
        value.setGravity(Gravity.END);
        row.addView(value);
        parent.addView(row);
        return value;
    }

    private String rendererName() {
        switch (renderer) {
            case "zink":
                return " · Zink";
            case "angle":
                return " · ANGLE";
            case "system_gles":
                return " · 系统 GLES";
            case "mobileglues":
                return " · MobileGlues";
            case "krypton":
                return " · Krypton Wrapper";
            default:
                return "";
        }
    }

    // ---------- lifecycle ----------

    /** Rotation or a new window size: put the ball and an open panel back in place. */
    private void onParentLayout(View v, int l, int t, int r, int b, int ol, int ot, int or, int ob) {
        if (r - l == or - ol && b - t == ob - ot) return;
        placeBall(false);
        placeCompact();
        if (mode != Mode.NONE) positionPanel(mode == Mode.MENU ? menu : infoPanel);
    }

    /** Below the camera cutout, centered. */
    private void placeCompact() {
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) compactView.getLayoutParams();
        if (lp == null) return;
        lp.topMargin = Math.max(dp(4), topInset() - dp(4));
        compactView.setLayoutParams(lp);
    }

    void attach() {
        parent.addView(scrim, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        for (LinearLayout card : new LinearLayout[]{menu, infoPanel}) {
            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                    dp((Integer) card.getTag()), FrameLayout.LayoutParams.WRAP_CONTENT);
            lp.gravity = Gravity.TOP | Gravity.START;
            parent.addView(card, lp);
        }
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(dp(BALL_DP), dp(BALL_DP));
        lp.gravity = Gravity.TOP | Gravity.START;
        parent.addView(ball, lp);
        FrameLayout.LayoutParams compactLp = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        compactLp.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
        parent.addView(compactView, compactLp);
        compactView.setVisibility(compact ? View.VISIBLE : View.GONE);
        parent.addOnLayoutChangeListener(parentLayout);

        ball.setVisibility(visible ? View.VISIBLE : View.GONE);
        ball.post(() -> {
            placeBall(false);
            placeCompact();
            if (visible) wake();
            if (visible || compact) startSampling();
        });
    }

    void setGameFocus(View view) {
        gameFocus = view;
    }

    void onVisibilityListener(Runnable listener) {
        onVisibilityChanged = listener;
    }

    void onGrabState(boolean grabbing) {
        // Opening a menu turns the pointer back into a cursor; a panel on top of the inventory
        // would be in the way, so close it and leave only the ball.
        if (!grabbing) {
            if (aiDialog != null) aiDialog.hide();
            setMode(Mode.NONE);
        }
    }

    void onPause() {
        stopSampling();
        handler.removeCallbacks(fadeRunnable);
        if (aiDialog != null) aiDialog.onPause();
    }

    void onResume() {
        if (visible) wake();
        if (visible || compact) startSampling();
        if (aiDialog != null) aiDialog.onResume();
    }

    void dispose() {
        stopSampling();
        handler.removeCallbacks(fadeRunnable);
        if (moveAnimator != null) moveAnimator.cancel();
        if (aiDialog != null) aiDialog.dispose();
        parent.removeOnLayoutChangeListener(parentLayout);
        parent.removeView(ball);
        parent.removeView(compactView);
        parent.removeView(menu);
        parent.removeView(infoPanel);
        parent.removeView(scrim);
    }

    void onFrame() {
        metrics.frame();
    }

    boolean isVisible() {
        return visible;
    }

    /** True when the AI dialog owns the keyboard; GameActivity must not forward keys to the game. */
    boolean hasInputFocus() {
        return aiDialog != null && aiDialog.isOpen();
    }

    /** Android back: close a panel instead of sending Esc to the game. */
    boolean onBack() {
        if (aiDialog != null && aiDialog.isOpen()) {
            aiDialog.hide();
            return true;
        }
        if (mode == Mode.NONE) return false;
        setMode(Mode.NONE);
        return true;
    }

    void toggleVisible() {
        setVisible(!visible);
    }

    void setVisible(boolean value) {
        if (visible == value) return;
        visible = value;
        prefs.edit().putBoolean("visible", value).apply();
        if (!value) {
            if (aiDialog != null) aiDialog.hide();
            setMode(Mode.NONE);
        }
        ball.animate().cancel();
        if (value) {
            ball.setAlpha(0f);
            ball.setVisibility(View.VISIBLE);
            tucked = false;
            placeBall(false);
            startSampling();
            wake();
        } else {
            handler.removeCallbacks(fadeRunnable);
            if (!compact) stopSampling();
            ball.animate().alpha(0f).setDuration(120).withEndAction(() -> {
                if (!visible) ball.setVisibility(View.GONE);
            }).start();
        }
        if (onVisibilityChanged != null) onVisibilityChanged.run();
    }

    void openLauncher() {
        Intent intent = activity.getPackageManager().getLaunchIntentForPackage(activity.getPackageName());
        if (intent == null) return;
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        activity.startActivity(intent);
    }

    // ---------- idle fade ----------

    /** Brings the ball fully on screen and restarts the idle timer. */
    private void wake() {
        handler.removeCallbacks(fadeRunnable);
        ball.animate().cancel();
        ball.animate().alpha(1f).setDuration(120).start();
        if (tucked) {
            tucked = false;
            placeBall(true);
        }
        scheduleFade();
    }

    private void scheduleFade() {
        handler.removeCallbacks(fadeRunnable);
        if (visible && mode == Mode.NONE) handler.postDelayed(fadeRunnable, FADE_DELAY_MS);
    }

    /** Fades the idle ball and slides it half behind the screen edge. */
    private void tuck() {
        if (!visible || mode != Mode.NONE || (aiDialog != null && aiDialog.isOpen())) return;
        tucked = true;
        placeBall(true);
        ball.animate().alpha(FADED_ALPHA).setDuration(400).start();
    }

    // ---------- modes ----------

    private void setMode(Mode next) {
        if (mode == next) next = Mode.NONE;
        mode = next;
        menu.setVisibility(View.GONE);
        infoPanel.setVisibility(View.GONE);
        scrim.setVisibility(next == Mode.NONE ? View.GONE : View.VISIBLE);
        if (next != Mode.NONE) {
            handler.removeCallbacks(fadeRunnable);
            if (tucked) {
                tucked = false;
                placeBall(false);
            }
            ball.animate().cancel();
            ball.setAlpha(1f);
            parent.bringChildToFront(scrim);
            LinearLayout card = next == Mode.MENU ? menu : infoPanel;
            parent.bringChildToFront(card);
            parent.bringChildToFront(ball);
            card.setAlpha(0f);
            card.setVisibility(View.VISIBLE);
            // Position once the card has been measured, then fade it in
            card.post(() -> {
                positionPanel(card);
                card.animate().alpha(1f).setDuration(120).start();
            });
        } else {
            scheduleFade();
        }
    }

    /** Places a panel beside the ball on the open side, keeping it inside the screen. */
    private void positionPanel(LinearLayout card) {
        if (card.getVisibility() != View.VISIBLE) return;
        FrameLayout.LayoutParams ballLp = (FrameLayout.LayoutParams) ball.getLayoutParams();
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) card.getLayoutParams();
        int pw = parent.getWidth();
        int ph = parent.getHeight();
        int cw = Math.min(dp((Integer) card.getTag()), pw - dp(2 * EDGE_DP));
        lp.width = cw;
        int ch = card.getHeight();
        int gap = dp(8);
        int x = startSide ? ballLp.leftMargin + dp(BALL_DP) + gap : ballLp.leftMargin - cw - gap;
        lp.leftMargin = clamp(x, dp(EDGE_DP), Math.max(dp(EDGE_DP), pw - cw - dp(EDGE_DP)));
        lp.topMargin = clamp(ballLp.topMargin, topInset(), Math.max(topInset(), ph - ch - dp(EDGE_DP)));
        card.setLayoutParams(lp);
    }

    private void openAiDialog() {
        if (!aiEnabled) return;
        setMode(Mode.NONE);
        handler.removeCallbacks(fadeRunnable);
        if (aiDialog == null) {
            aiDialog = new GameAiDialog(activity, parent, this, instance, renderer);
            aiDialog.setOnClosed(() -> {
                if (gameFocus != null) gameFocus.requestFocus();
                wake();
            });
        }
        aiDialog.show();
    }

    // ---------- dragging and position ----------

    private void installDrag(View handle) {
        final int slop = ViewConfiguration.get(activity).getScaledTouchSlop();
        handle.setOnTouchListener(new View.OnTouchListener() {
            private float downX;
            private float downY;
            private int startLeft;
            private int startTop;
            private boolean moved;
            private boolean wasTucked;

            @Override
            public boolean onTouch(View v, MotionEvent e) {
                FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ball.getLayoutParams();
                switch (e.getActionMasked()) {
                    case MotionEvent.ACTION_DOWN:
                        if (moveAnimator != null) moveAnimator.cancel();
                        handler.removeCallbacks(fadeRunnable);
                        ball.animate().cancel();
                        ball.setAlpha(1f);
                        ball.animate().scaleX(1.08f).scaleY(1.08f).setDuration(90).start();
                        downX = e.getRawX();
                        downY = e.getRawY();
                        startLeft = lp.leftMargin;
                        startTop = lp.topMargin;
                        moved = false;
                        wasTucked = tucked;
                        return true;
                    case MotionEvent.ACTION_MOVE: {
                        float dx = e.getRawX() - downX;
                        float dy = e.getRawY() - downY;
                        if (!moved && Math.hypot(dx, dy) < slop) return true;
                        if (!moved) {
                            moved = true;
                            tucked = false;
                            if (mode != Mode.NONE) setMode(Mode.NONE);
                            handler.removeCallbacks(fadeRunnable);
                        }
                        int size = dp(BALL_DP);
                        lp.leftMargin = clamp(Math.round(startLeft + dx), -size / 2, parent.getWidth() - size / 2);
                        lp.topMargin = clamp(Math.round(startTop + dy), topInset(), parent.getHeight() - size);
                        ball.setLayoutParams(lp);
                        return true;
                    }
                    case MotionEvent.ACTION_UP:
                        ball.animate().scaleX(1f).scaleY(1f).setDuration(120).start();
                        if (!moved) {
                            if (wasTucked) {
                                tucked = false;
                                placeBall(true);
                            }
                            setMode(mode == Mode.NONE ? Mode.MENU : Mode.NONE);
                        } else {
                            startSide = lp.leftMargin + dp(BALL_DP) / 2 < parent.getWidth() / 2;
                            topDp = pxToDp(lp.topMargin);
                            prefs.edit().putString("side", startSide ? "start" : "end").putInt("topDp", topDp).apply();
                            placeBall(true);
                            scheduleFade();
                        }
                        return true;
                    case MotionEvent.ACTION_CANCEL:
                        ball.animate().scaleX(1f).scaleY(1f).setDuration(120).start();
                        placeBall(true);
                        scheduleFade();
                        return true;
                    default:
                        return false;
                }
            }
        });
    }

    /** Moves the ball to its resting place on the chosen side (half hidden when tucked). */
    private void placeBall(boolean animate) {
        int pw = parent.getWidth();
        int ph = parent.getHeight();
        if (pw == 0 || ph == 0) return;
        int size = dp(BALL_DP);
        int x;
        if (tucked) x = startSide ? -size / 2 : pw - size / 2;
        else x = startSide ? dp(EDGE_DP) : pw - size - dp(EDGE_DP);
        int y = clamp(dp(topDp), topInset(), Math.max(topInset(), ph - size - dp(EDGE_DP)));
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ball.getLayoutParams();
        if (moveAnimator != null) moveAnimator.cancel();
        if (!animate) {
            lp.leftMargin = x;
            lp.topMargin = y;
            ball.setLayoutParams(lp);
            return;
        }
        final int fromX = lp.leftMargin;
        final int fromY = lp.topMargin;
        moveAnimator = ValueAnimator.ofFloat(0f, 1f);
        moveAnimator.setDuration(220);
        moveAnimator.setInterpolator(new DecelerateInterpolator(1.6f));
        moveAnimator.addUpdateListener(a -> {
            float f = (float) a.getAnimatedValue();
            FrameLayout.LayoutParams p = (FrameLayout.LayoutParams) ball.getLayoutParams();
            p.leftMargin = Math.round(fromX + (x - fromX) * f);
            p.topMargin = Math.round(fromY + (y - fromY) * f);
            ball.setLayoutParams(p);
        });
        moveAnimator.start();
    }

    /**
     * Where the ball rests (ignoring the half-hidden idle state), in dp, which equals CSS pixels
     * in the AI page: {"x", "y", "size", "start"}. The AI window opens next to it.
     */
    String aiAnchor() {
        int pw = parent.getWidth();
        int ph = parent.getHeight();
        int size = dp(BALL_DP);
        int x = startSide ? dp(EDGE_DP) : pw - size - dp(EDGE_DP);
        int y = clamp(dp(topDp), topInset(), Math.max(topInset(), ph - size - dp(EDGE_DP)));
        float d = activity.getResources().getDisplayMetrics().density;
        return String.format(Locale.ROOT, "{\"x\":%.1f,\"y\":%.1f,\"size\":%.1f,\"start\":%b}",
                x / d, y / d, size / d, startSide);
    }

    private int topInset() {
        int cutout = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowInsets insets = parent.getRootWindowInsets();
            if (insets != null) cutout = insets.getInsets(WindowInsets.Type.displayCutout()).top;
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            WindowInsets insets = parent.getRootWindowInsets();
            if (insets != null) cutout = insets.getSystemWindowInsetTop();
        }
        return cutout + dp(8);
    }

    // ---------- sampling ----------

    private void startSampling() {
        if (sampling) {
            metrics.start(this::onSample);
            return;
        }
        sampling = true;
        graph.clear();
        metrics.start(this::onSample);
    }

    private void stopSampling() {
        sampling = false;
        metrics.stop();
    }

    private void onSample(HudMetrics.Sample s) {
        lastSample = s;
        fpsValue.setText(s.fpsAvailable ? String.format(Locale.ROOT, "%.0f", s.fps) : "--");
        fpsHint.setVisibility(s.fpsAvailable ? View.GONE : View.VISIBLE);
        graph.setVisibility(s.fpsAvailable ? View.VISIBLE : View.GONE);
        if (s.fpsAvailable) graph.add((float) s.fps);

        memValue.setText(gbPair(s.heapUsed, s.heapMax));
        systemValue.setText(gbPair(s.systemUsed, s.systemTotal));
        swapValue.setText(s.swapTotal > 0 ? gbPair(s.swapUsed, s.swapTotal) : "无");

        cpuValue.setText(String.format(Locale.ROOT, "%.0f%%", s.cpuPercent));
        cpuValue.setTextColor(s.cpuPercent > 80 ? WARN : TEXT);

        tempLabel.setText(s.batteryTemperature ? "电池温度" : "温度");
        boolean hasTemp = s.temperature > 0;
        tempValue.setText(hasTemp ? String.format(Locale.ROOT, "%.0f°C", s.temperature) : "--");
        tempValue.setTextColor(!hasTemp ? MUTED : s.temperature >= 45 ? BAD : s.temperature >= 40 ? WARN : OK);

        timeValue.setText(duration(s.uptimeMs));
        if (compact) compactView.setText(compactText(s));
        detailValue.setText(s.batteryPercent > 0 ? "电池 " + s.batteryPercent + "%" : "");
        detailValue.setVisibility(s.batteryPercent > 0 ? View.VISIBLE : View.GONE);
    }

    /** e.g. "58 FPS · 1.2/3.0G · CPU 34% · 41°C" */
    private static String compactText(HudMetrics.Sample s) {
        StringBuilder b = new StringBuilder();
        if (s.fpsAvailable) b.append(String.format(Locale.ROOT, "%.0f FPS · ", s.fps));
        if (s.heapMax > 0) {
            b.append(String.format(Locale.ROOT, "%.1f/%.1fG · ", s.heapUsed / 1073741824.0, s.heapMax / 1073741824.0));
        }
        b.append(String.format(Locale.ROOT, "CPU %.0f%%", s.cpuPercent));
        if (s.temperature > 0) b.append(String.format(Locale.ROOT, " · %.0f°C", s.temperature));
        return b.toString();
    }

    private static String gbPair(long used, long total) {
        if (total <= 0) return "--";
        return String.format(Locale.ROOT, "%.1f / %.1f GB", used / 1073741824.0, total / 1073741824.0);
    }

    private static String duration(long ms) {
        long total = Math.max(0, ms) / 1000;
        long h = total / 3600;
        long m = total % 3600 / 60;
        long s = total % 60;
        return h > 0
                ? String.format(Locale.ROOT, "%d:%02d:%02d", h, m, s)
                : String.format(Locale.ROOT, "%02d:%02d", m, s);
    }

    // ---------- AI context ----------

    /** Game state attached to every in-game question (sent to the launcher, not stored). */
    String aiContext() {
        StringBuilder b = new StringBuilder();
        b.append("实例：").append(instance).append('\n');
        b.append("渲染器：").append(renderer.isEmpty() ? "未知" : renderer).append('\n');
        HudMetrics.Sample s = lastSample;
        if (s != null) {
            if (s.fpsAvailable) b.append("帧率：").append(String.format(Locale.ROOT, "%.0f FPS", s.fps)).append('\n');
            b.append("堆内存：").append(gbPair(s.heapUsed, s.heapMax)).append('\n');
            b.append("系统内存：").append(gbPair(s.systemUsed, s.systemTotal)).append('\n');
            if (s.swapTotal > 0) b.append("交换空间：").append(gbPair(s.swapUsed, s.swapTotal)).append('\n');
            b.append("CPU：").append(String.format(Locale.ROOT, "%.0f%%", s.cpuPercent)).append('\n');
            if (s.temperature > 0) {
                b.append(s.batteryTemperature ? "电池温度：" : "温度：")
                        .append(String.format(Locale.ROOT, "%.0f°C", s.temperature)).append('\n');
            }
            b.append("已运行：").append(duration(s.uptimeMs)).append('\n');
        }
        if (attachLog) {
            final String tail = readTail(logFile, 6000);
            if (!tail.isEmpty()) b.append("\n最近日志（末尾）：\n```\n").append(tail).append("\n```\n");
        }
        return b.toString();
    }

    private static String readTail(String path, int maxBytes) {
        if (path == null) return "";
        File file = new File(path);
        if (!file.isFile()) return "";
        try (RandomAccessFile raf = new RandomAccessFile(file, "r")) {
            long len = raf.length();
            long start = Math.max(0, len - maxBytes);
            byte[] bytes = new byte[(int) (len - start)];
            raf.seek(start);
            raf.readFully(bytes);
            String text = new String(bytes, StandardCharsets.UTF_8);
            return start > 0 ? "…（更早的日志省略）\n" + text : text;
        } catch (Throwable ignored) {
            return "";
        }
    }

    // ---------- small helpers ----------

    private TextView label(String text, float sp, int color, boolean mono, boolean bold) {
        TextView v = new TextView(activity);
        v.setText(text);
        v.setTextSize(sp);
        v.setTextColor(color);
        if (mono) v.setTypeface(Typeface.MONOSPACE, bold ? Typeface.BOLD : Typeface.NORMAL);
        else v.setTypeface(Typeface.create("sans-serif", bold ? Typeface.BOLD : Typeface.NORMAL));
        return v;
    }

    private GradientDrawable rounded(int color, int radiusDp) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(dp(radiusDp));
        return d;
    }

    /** Translucent fill with a thin white outline. */
    private GradientDrawable outlined(int fill, int radiusDp) {
        GradientDrawable d = rounded(fill, radiusDp);
        d.setStroke(Math.max(1, dp(1)), BORDER);
        return d;
    }

    /** Outlined background that brightens while pressed. */
    private Drawable pressable(int radiusDp) {
        android.graphics.drawable.StateListDrawable states = new android.graphics.drawable.StateListDrawable();
        states.addState(new int[]{android.R.attr.state_pressed}, outlined(PRESSED, radiusDp));
        states.addState(new int[]{}, outlined(FILL, radiusDp));
        return states;
    }

    private int pxToDp(int px) {
        return Math.round(px / activity.getResources().getDisplayMetrics().density);
    }

    private int dp(float value) {
        return Math.round(value * activity.getResources().getDisplayMetrics().density);
    }

    private static int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }
}
