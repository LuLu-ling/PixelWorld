package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowInsets;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import net.kdt.pojavlaunch.LwjglGlfwKeycode;

import org.lwjgl.glfw.CallbackBridge;

import java.io.File;
import java.io.RandomAccessFile;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * The in-game assistant: a small draggable ball. Tapping it opens a menu with basic information
 * and the built-in AI; the AI request goes through the launcher's local bridge so the model,
 * prompt and API key stay in one place.
 *
 * <p>It lives in the same view hierarchy as the game surface, so it needs no overlay permission
 * and disappears with the game. Only the views themselves receive touches.
 */
final class GameHud {

    private static final int BG = 0xE6161C24;
    private static final int BG_BUTTON = 0x22FFFFFF;
    private static final int STROKE = 0x33FFFFFF;
    private static final int TEXT = 0xFFF2F6FF;
    private static final int MUTED = 0xFF9AA7B8;
    private static final int ACCENT = 0xFF7FB4FF;
    private static final int BLUE = 0xF21370F3;
    private static final int OK = 0xFF7ADFA0;
    private static final int WARN = 0xFFFFC46B;
    private static final int BAD = 0xFFFF8A80;

    private enum Mode { NONE, MENU, INFO, AI }

    private final Activity activity;
    private final FrameLayout parent;
    private final SharedPreferences prefs;
    private final HudMetrics metrics;
    private final HudAiClient aiClient;
    private final String instance;
    private final String renderer;
    private final String logFile;

    private final LinearLayout root;
    private final TextView ball;
    private final LinearLayout menu;
    private final LinearLayout infoPanel;
    private final LinearLayout aiPanel;
    private final View scrim;

    private TextView fpsValue;
    private TextView fpsLabel;
    private TextView fpsHint;
    private SparklineView graph;
    private TextView memValue;
    private TextView cpuValue;
    private TextView tempLabel;
    private TextView tempValue;
    private TextView timeValue;
    private TextView detailValue;

    private EditText aiInput;
    private TextView aiSend;
    private TextView aiStatus;
    private TextView aiAnswer;
    private ScrollView aiScroll;

    private final List<String[]> aiHistory = new ArrayList<>();
    private final StringBuilder aiTranscript = new StringBuilder();
    private final StringBuilder aiBuffer = new StringBuilder();

    private HudMetrics.Sample lastSample;
    private Mode mode = Mode.NONE;
    private boolean visible;
    private boolean sampling;
    private boolean aiBusy;
    private View gameFocus;
    private Runnable onVisibilityChanged;

    GameHud(Activity activity, FrameLayout parent, String instance, String renderer, String logFile) {
        this.activity = activity;
        this.parent = parent;
        this.prefs = activity.getSharedPreferences("pclpw_hud", Activity.MODE_PRIVATE);
        this.instance = TextUtils.isEmpty(instance) ? "游戏" : instance;
        this.renderer = renderer == null ? "" : renderer;
        this.logFile = logFile;
        this.visible = prefs.getBoolean("visible", true);
        this.metrics = new HudMetrics(activity);
        this.aiClient = new HudAiClient(activity);
        // Frame counting is only possible when the renderer draws through a TextureView (Zink);
        // SurfaceView renderers do not tell the app when a frame is presented.
        metrics.setFpsAvailable("zink".equals(this.renderer));

        root = new LinearLayout(activity);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setClipChildren(false);
        root.setClipToPadding(false);
        root.setClickable(true);

        ball = buildBall();
        menu = buildMenu();
        infoPanel = buildInfoPanel();
        aiPanel = buildAiPanel();

        root.addView(ball);
        root.addView(menu);
        root.addView(infoPanel);
        root.addView(aiPanel);

        scrim = new View(activity);
        scrim.setBackgroundColor(0x4D000000);
        scrim.setVisibility(View.GONE);
        scrim.setClickable(true);
        scrim.setOnClickListener(v -> setMode(Mode.NONE));
    }

    // ---------- construction ----------

    private TextView buildBall() {
        TextView v = new TextView(activity);
        v.setText("✦");
        v.setTextSize(20);
        v.setTextColor(Color.WHITE);
        v.setGravity(Gravity.CENTER);
        v.setIncludeFontPadding(false);
        v.setTypeface(Typeface.create("sans-serif", Typeface.NORMAL));
        GradientDrawable bg = oval(BLUE);
        bg.setStroke(dp(1), 0x66FFFFFF);
        v.setBackground(bg);
        v.setElevation(dp(8));
        v.setContentDescription("游戏助手，点击打开菜单");
        v.setLayoutParams(new LinearLayout.LayoutParams(dp(48), dp(48)));
        installDrag(v, true);
        return v;
    }

    private LinearLayout buildMenu() {
        LinearLayout card = card(200);
        card.setPadding(dp(6), dp(6), dp(6), dp(6));
        card.addView(menuItem("✦", "问 AI", v -> setMode(Mode.AI)));
        card.addView(menuItem("i", "基础信息", v -> setMode(Mode.INFO)));
        card.addView(menuItem("×", "隐藏", v -> setVisible(false)));
        return card;
    }

    private LinearLayout buildInfoPanel() {
        LinearLayout card = card(300);
        card.setPadding(dp(14), dp(8), dp(14), dp(12));

        LinearLayout header = header("基础信息", "关闭", v -> setMode(Mode.NONE));
        card.addView(header);

        TextView subtitle = label(instance + rendererName(), 11, MUTED, false, false);
        subtitle.setSingleLine(true);
        subtitle.setEllipsize(TextUtils.TruncateAt.END);
        LinearLayout.LayoutParams subLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        subLp.topMargin = dp(1);
        subtitle.setLayoutParams(subLp);
        card.addView(subtitle);

        LinearLayout fpsRow = new LinearLayout(activity);
        fpsRow.setOrientation(LinearLayout.HORIZONTAL);
        fpsRow.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout.LayoutParams fpsRowLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        fpsRowLp.topMargin = dp(12);
        fpsRow.setLayoutParams(fpsRowLp);

        LinearLayout fpsBlock = new LinearLayout(activity);
        fpsBlock.setOrientation(LinearLayout.VERTICAL);
        fpsValue = label("--", 26, TEXT, true, true);
        fpsValue.setIncludeFontPadding(false);
        fpsBlock.addView(fpsValue);
        fpsLabel = label("FPS", 10, MUTED, false, false);
        fpsBlock.addView(fpsLabel);
        fpsRow.addView(fpsBlock, new LinearLayout.LayoutParams(dp(78), LinearLayout.LayoutParams.WRAP_CONTENT));

        graph = new SparklineView(activity);
        LinearLayout.LayoutParams graphLp = new LinearLayout.LayoutParams(0, dp(42), 1);
        graphLp.setMarginStart(dp(8));
        graph.setLayoutParams(graphLp);
        fpsRow.addView(graph);
        card.addView(fpsRow);

        fpsHint = label("当前渲染器无法读取帧率", 10, MUTED, false, false);
        LinearLayout.LayoutParams hintLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        hintLp.topMargin = dp(2);
        fpsHint.setLayoutParams(hintLp);
        fpsHint.setVisibility(View.GONE);
        card.addView(fpsHint);

        card.addView(divider());

        LinearLayout metricsRow1 = new LinearLayout(activity);
        metricsRow1.setOrientation(LinearLayout.HORIZONTAL);
        memValue = metricCell(metricsRow1, "内存");
        cpuValue = metricCell(metricsRow1, "CPU");
        card.addView(metricsRow1);

        LinearLayout metricsRow2 = new LinearLayout(activity);
        metricsRow2.setOrientation(LinearLayout.HORIZONTAL);
        LinearLayout tempCell = new LinearLayout(activity);
        tempCell.setOrientation(LinearLayout.VERTICAL);
        tempCell.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        tempLabel = label("温度", 10, MUTED, false, false);
        tempCell.addView(tempLabel);
        tempValue = label("--", 15, TEXT, true, false);
        tempCell.addView(tempValue);
        metricsRow2.addView(tempCell);
        timeValue = metricCell(metricsRow2, "时长");
        card.addView(metricsRow2);

        detailValue = label("", 10, MUTED, true, false);
        LinearLayout.LayoutParams detailLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        detailLp.topMargin = dp(4);
        detailValue.setLayoutParams(detailLp);
        card.addView(detailValue);

        LinearLayout actions = new LinearLayout(activity);
        actions.setOrientation(LinearLayout.HORIZONTAL);
        LinearLayout.LayoutParams actionsLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        actionsLp.topMargin = dp(12);
        actions.setLayoutParams(actionsLp);
        actions.addView(action("暂停", v -> CallbackBridge.sendKeyPress(LwjglGlfwKeycode.GLFW_KEY_ESCAPE)));
        actions.addView(action("启动器", v -> openLauncher()));
        card.addView(actions);

        installDrag(header, false);
        return card;
    }

    private LinearLayout buildAiPanel() {
        LinearLayout card = card(300);
        card.setPadding(dp(14), dp(8), dp(14), dp(12));

        LinearLayout header = header("问 AI", "关闭", v -> setMode(Mode.NONE));
        card.addView(header);
        installDrag(header, false);

        // Input first: when the soft keyboard opens it covers the lower part of the panel, but the
        // user can still see what they are typing.
        LinearLayout inputRow = new LinearLayout(activity);
        inputRow.setOrientation(LinearLayout.HORIZONTAL);
        inputRow.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout.LayoutParams inputRowLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        inputRowLp.topMargin = dp(8);
        inputRow.setLayoutParams(inputRowLp);

        aiInput = new EditText(activity);
        aiInput.setHint("问点什么…");
        aiInput.setHintTextColor(MUTED);
        aiInput.setTextColor(TEXT);
        aiInput.setTextSize(13);
        aiInput.setSingleLine(true);
        aiInput.setImeOptions(EditorInfo.IME_ACTION_SEND);
        aiInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_SENTENCES);
        aiInput.setBackground(rounded(BG_BUTTON, 10, 0, 0));
        aiInput.setPadding(dp(10), dp(7), dp(10), dp(7));
        aiInput.setOnEditorActionListener((v, actionId, event) -> {
            sendAiQuestion();
            return true;
        });
        LinearLayout.LayoutParams inputLp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
        aiInput.setLayoutParams(inputLp);
        inputRow.addView(aiInput);

        aiSend = label("发送", 12, ACCENT, false, true);
        aiSend.setPadding(dp(12), dp(7), dp(4), dp(7));
        aiSend.setClickable(true);
        aiSend.setOnClickListener(v -> sendAiQuestion());
        LinearLayout.LayoutParams sendLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        sendLp.setMarginStart(dp(6));
        aiSend.setLayoutParams(sendLp);
        inputRow.addView(aiSend);
        card.addView(inputRow);

        aiStatus = label("", 10, MUTED, false, false);
        LinearLayout.LayoutParams statusLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        statusLp.topMargin = dp(3);
        aiStatus.setLayoutParams(statusLp);
        card.addView(aiStatus);

        aiScroll = new ScrollView(activity);
        LinearLayout.LayoutParams scrollLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(150));
        scrollLp.topMargin = dp(6);
        aiScroll.setLayoutParams(scrollLp);
        aiScroll.setBackground(rounded(0x14000000, 10, 0, 0));
        aiScroll.setPadding(dp(10), dp(8), dp(10), dp(8));
        aiAnswer = label("可以问我崩溃、模组、设置……", 12, TEXT, false, false);
        aiAnswer.setTextIsSelectable(true);
        aiAnswer.setLineSpacing(dp(2), 1f);
        aiScroll.addView(aiAnswer);
        card.addView(aiScroll);

        return card;
    }

    private LinearLayout card(int widthDp) {
        LinearLayout card = new LinearLayout(activity);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackground(rounded(BG, 20, STROKE, 1));
        card.setElevation(dp(10));
        card.setVisibility(View.GONE);
        card.setClickable(true);
        int width = Math.min(dp(widthDp), activity.getResources().getDisplayMetrics().widthPixels - dp(24));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(width, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(8);
        card.setLayoutParams(lp);
        return card;
    }

    private LinearLayout header(String title, String action, View.OnClickListener onAction) {
        LinearLayout row = new LinearLayout(activity);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, dp(4), 0, 0);
        TextView titleView = label(title, 13, TEXT, false, true);
        row.addView(titleView);
        View spacer = new View(activity);
        row.addView(spacer, new LinearLayout.LayoutParams(0, 1, 1));
        TextView actionView = label(action, 11, MUTED, false, false);
        actionView.setPadding(dp(10), dp(6), dp(2), dp(6));
        actionView.setClickable(true);
        actionView.setOnClickListener(onAction);
        row.addView(actionView);
        return row;
    }

    private View menuItem(String glyph, String title, View.OnClickListener listener) {
        LinearLayout row = new LinearLayout(activity);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(10), dp(10), dp(10), dp(10));
        row.setClickable(true);
        row.setOnClickListener(listener);

        TextView icon = label(glyph, 15, ACCENT, false, true);
        icon.setGravity(Gravity.CENTER);
        icon.setLayoutParams(new LinearLayout.LayoutParams(dp(26), LinearLayout.LayoutParams.WRAP_CONTENT));
        row.addView(icon);
        row.addView(label(title, 13, TEXT, false, false), new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        row.addView(label("›", 14, MUTED, false, false));
        return row;
    }

    /** Adds a label/value pair to a horizontal row and returns the value view. */
    private TextView metricCell(LinearLayout row, String title) {
        LinearLayout cell = new LinearLayout(activity);
        cell.setOrientation(LinearLayout.VERTICAL);
        cell.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
        cell.addView(label(title, 10, MUTED, false, false));
        TextView value = label("--", 15, TEXT, true, false);
        cell.addView(value);
        row.addView(cell);
        return value;
    }

    private View divider() {
        View line = new View(activity);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(1));
        lp.topMargin = dp(10);
        lp.bottomMargin = dp(8);
        line.setLayoutParams(lp);
        line.setBackgroundColor(0x1FFFFFFF);
        return line;
    }

    private TextView action(String text, View.OnClickListener listener) {
        TextView v = label(text, 12, TEXT, false, false);
        v.setGravity(Gravity.CENTER);
        v.setPadding(dp(12), dp(7), dp(12), dp(7));
        v.setBackground(rounded(BG_BUTTON, 10, 0, 0));
        v.setClickable(true);
        v.setOnClickListener(listener);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMarginEnd(dp(8));
        v.setLayoutParams(lp);
        return v;
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
            default:
                return "";
        }
    }

    // ---------- lifecycle ----------

    void attach() {
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        boolean start = !"end".equals(prefs.getString("side", "start"));
        applySide(lp, start);
        lp.topMargin = topInset(prefs.getInt("top", dp(8)));
        root.setLayoutParams(lp);

        root.setVisibility(visible ? View.VISIBLE : View.GONE);
        parent.addView(scrim, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        parent.addView(root);

        if (visible) startSampling();
        root.post(() -> {
            FrameLayout.LayoutParams fixed = (FrameLayout.LayoutParams) root.getLayoutParams();
            fixed.topMargin = topInset(fixed.topMargin);
            root.setLayoutParams(fixed);
            keepOnScreen();
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
        if (!grabbing) setMode(Mode.NONE);
    }

    void onPause() {
        stopSampling();
        aiClient.cancel();
        hideKeyboard();
    }

    void onResume() {
        if (visible) startSampling();
    }

    void dispose() {
        stopSampling();
        aiClient.cancel();
        parent.removeView(root);
        parent.removeView(scrim);
    }

    void onFrame() {
        metrics.frame();
    }

    boolean isVisible() {
        return visible;
    }

    /** True when the AI input owns the keyboard; GameActivity must not forward keys to the game. */
    boolean hasInputFocus() {
        return aiInput != null && aiInput.hasFocus();
    }

    /** Android back: close a panel instead of sending Esc to the game. */
    boolean onBack() {
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
        if (!value) setMode(Mode.NONE);
        root.animate().cancel();
        if (value) {
            root.setAlpha(0f);
            root.setVisibility(View.VISIBLE);
            root.animate().alpha(1f).setDuration(140).start();
            startSampling();
        } else {
            stopSampling();
            root.animate().alpha(0f).setDuration(120).withEndAction(() -> {
                if (!visible) root.setVisibility(View.GONE);
            }).start();
        }
        if (onVisibilityChanged != null) onVisibilityChanged.run();
    }

    // ---------- modes ----------

    private void setMode(Mode next) {
        if (mode == next) next = Mode.NONE;
        final boolean leavingAi = mode == Mode.AI;
        mode = next;
        menu.setVisibility(next == Mode.MENU ? View.VISIBLE : View.GONE);
        infoPanel.setVisibility(next == Mode.INFO ? View.VISIBLE : View.GONE);
        aiPanel.setVisibility(next == Mode.AI ? View.VISIBLE : View.GONE);
        scrim.setVisibility(next == Mode.NONE ? View.GONE : View.VISIBLE);
        if (next != Mode.NONE) {
            parent.bringChildToFront(scrim);
            parent.bringChildToFront(root);
        }
        if (next == Mode.AI) {
            aiInput.post(this::showKeyboard);
        } else if (leavingAi) {
            aiClient.cancel();
            aiBusy = false;
            updateAiSendState();
            hideKeyboard();
        }
        if (next == Mode.NONE) aiClient.cancel();
        root.post(this::keepOnScreen);
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
        String fps = s.fpsAvailable ? String.format(Locale.ROOT, "%.0f", s.fps) : "--";
        fpsValue.setText(fps);
        fpsLabel.setText("FPS");
        fpsHint.setVisibility(s.fpsAvailable ? View.GONE : View.VISIBLE);
        graph.setVisibility(s.fpsAvailable ? View.VISIBLE : View.GONE);
        if (s.fpsAvailable) graph.add((float) s.fps);

        memValue.setText(String.format(Locale.ROOT, "%.1f / %.1f GB",
                s.heapUsed / 1073741824.0, s.heapMax / 1073741824.0));
        cpuValue.setText(String.format(Locale.ROOT, "%.0f%%", s.cpuPercent));
        cpuValue.setTextColor(s.cpuPercent > 80 ? WARN : TEXT);

        tempLabel.setText(s.batteryTemperature ? "电池温度" : "温度");
        boolean hasTemp = s.temperature > 0;
        tempValue.setText(hasTemp ? String.format(Locale.ROOT, "%.0f°C", s.temperature) : "--");
        tempValue.setTextColor(!hasTemp ? MUTED : s.temperature >= 45 ? BAD : s.temperature >= 40 ? WARN : OK);

        timeValue.setText(duration(s.uptimeMs));
        String pss = s.pss > 0 ? String.format(Locale.ROOT, "PSS %.1f GB", s.pss / 1073741824.0) : "";
        String battery = s.batteryPercent > 0 ? s.batteryPercent + "% 电量" : "";
        detailValue.setText(pss.isEmpty() ? battery : battery.isEmpty() ? pss : pss + " · " + battery);
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

    // ---------- AI ----------

    private void sendAiQuestion() {
        if (aiBusy) return;
        final String question = aiInput.getText().toString().trim();
        if (question.isEmpty()) return;
        aiInput.setText("");
        hideKeyboard();
        aiBusy = true;
        updateAiSendState();
        aiStatus.setText("正在连接…");
        aiBuffer.setLength(0);
        if (aiTranscript.length() > 0) aiTranscript.append("\n\n");
        aiTranscript.append("你：").append(question).append("\n\n助手：");
        aiAnswer.setText(aiTranscript.toString() + "…");
        scrollToBottom();

        final String context = aiContext();
        aiClient.ask(question, context, aiHistory, new HudAiClient.Listener() {
            @Override
            public void onStart() {
                aiStatus.setText("正在回答…");
            }

            @Override
            public void onDelta(String text) {
                aiBuffer.append(text);
                aiAnswer.setText(aiTranscript.toString() + aiBuffer);
                scrollToBottom();
            }

            @Override
            public void onDone() {
                final String answer = aiBuffer.toString().trim();
                aiTranscript.append(answer);
                if (answer.isEmpty()) aiStatus.setText("没有返回内容");
                else aiStatus.setText("完成");
                remember(question, answer);
                aiBuffer.setLength(0);
                aiBusy = false;
                updateAiSendState();
            }

            @Override
            public void onError(String message) {
                aiStatus.setText(message);
                aiAnswer.setText(aiTranscript.toString() + "\n\n（" + message + "）");
                aiBuffer.setLength(0);
                aiBusy = false;
                updateAiSendState();
                scrollToBottom();
            }
        });
    }

    private void remember(String question, String answer) {
        if (answer.isEmpty()) return;
        aiHistory.add(new String[]{"user", question});
        aiHistory.add(new String[]{"assistant", answer});
        while (aiHistory.size() > 8) {
            aiHistory.remove(0);
            aiHistory.remove(0);
        }
    }

    private void updateAiSendState() {
        aiSend.setAlpha(aiBusy ? 0.5f : 1f);
        aiSend.setEnabled(!aiBusy);
    }

    private String aiContext() {
        StringBuilder b = new StringBuilder();
        b.append("实例：").append(instance).append('\n');
        b.append("渲染器：").append(renderer.isEmpty() ? "未知" : renderer).append('\n');
        HudMetrics.Sample s = lastSample;
        if (s != null) {
            if (s.fpsAvailable) b.append("帧率：").append(String.format(Locale.ROOT, "%.0f FPS", s.fps)).append('\n');
            b.append("堆内存：").append(String.format(Locale.ROOT, "%.1f / %.1f GB",
                    s.heapUsed / 1073741824.0, s.heapMax / 1073741824.0)).append('\n');
            b.append("进程内存：").append(String.format(Locale.ROOT, "%.1f GB", s.pss / 1073741824.0)).append('\n');
            b.append("CPU：").append(String.format(Locale.ROOT, "%.0f%%", s.cpuPercent)).append('\n');
            if (s.temperature > 0) {
                b.append(s.batteryTemperature ? "电池温度：" : "温度：")
                        .append(String.format(Locale.ROOT, "%.0f°C", s.temperature)).append('\n');
            }
            b.append("已运行：").append(duration(s.uptimeMs)).append('\n');
        }
        final String tail = readTail(logFile, 6000);
        if (!tail.isEmpty()) {
            b.append("\n最近日志（末尾）：\n```\n").append(tail).append("\n```\n");
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

    private void scrollToBottom() {
        aiScroll.post(() -> aiScroll.fullScroll(View.FOCUS_DOWN));
    }

    private void showKeyboard() {
        aiInput.requestFocus();
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        if (imm != null) imm.showSoftInput(aiInput, InputMethodManager.SHOW_IMPLICIT);
    }

    private void hideKeyboard() {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        if (imm != null) imm.hideSoftInputFromWindow(aiInput.getWindowToken(), 0);
        aiInput.clearFocus();
        if (gameFocus != null) gameFocus.requestFocus();
    }

    private void openLauncher() {
        Intent intent = activity.getPackageManager().getLaunchIntentForPackage(activity.getPackageName());
        if (intent == null) return;
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        activity.startActivity(intent);
    }

    // ---------- dragging and position ----------

    private void installDrag(View handle, boolean closeOnDrag) {
        final int slop = ViewConfiguration.get(activity).getScaledTouchSlop();
        handle.setOnTouchListener(new View.OnTouchListener() {
            private float downX;
            private float downY;
            private int startLeft;
            private int startTop;
            private boolean moved;
            private boolean wasOpen;

            @Override
            public boolean onTouch(View v, MotionEvent e) {
                switch (e.getActionMasked()) {
                    case MotionEvent.ACTION_DOWN:
                        downX = e.getRawX();
                        downY = e.getRawY();
                        startLeft = root.getLeft();
                        startTop = root.getTop();
                        moved = false;
                        wasOpen = mode != Mode.NONE;
                        if (closeOnDrag && wasOpen) setMode(Mode.NONE);
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        float dx = e.getRawX() - downX;
                        float dy = e.getRawY() - downY;
                        if (!moved && Math.hypot(dx, dy) < slop) return true;
                        moved = true;
                        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) root.getLayoutParams();
                        int maxLeft = Math.max(0, parent.getWidth() - root.getWidth());
                        int maxTop = Math.max(0, parent.getHeight() - root.getHeight());
                        lp.gravity = Gravity.TOP | Gravity.START;
                        lp.leftMargin = clamp(Math.round(startLeft + dx), 0, maxLeft);
                        lp.rightMargin = 0;
                        lp.topMargin = clamp(Math.round(startTop + dy), topInset(0), maxTop);
                        root.setLayoutParams(lp);
                        root.setGravity(Gravity.TOP | Gravity.START);
                        return true;
                    case MotionEvent.ACTION_UP:
                        if (!moved) {
                            if (!wasOpen) setMode(Mode.MENU);
                        } else {
                            snapToEdge();
                        }
                        return true;
                    case MotionEvent.ACTION_CANCEL:
                        if (moved) snapToEdge();
                        return true;
                }
                return false;
            }
        });
    }

    /** Snaps to the closer side and remembers where it was left. */
    private void snapToEdge() {
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) root.getLayoutParams();
        int w = root.getWidth();
        int parentW = parent.getWidth();
        boolean start = lp.leftMargin + w / 2 < parentW / 2;
        lp.topMargin = clamp(lp.topMargin, topInset(0),
                Math.max(topInset(0), parent.getHeight() - root.getHeight()));
        applySide(lp, start);
        root.setLayoutParams(lp);
        prefs.edit()
                .putString("side", start ? "start" : "end")
                .putInt("top", pxToDp(lp.topMargin))
                .apply();
    }

    private void applySide(FrameLayout.LayoutParams lp, boolean start) {
        lp.gravity = Gravity.TOP | (start ? Gravity.START : Gravity.END);
        lp.leftMargin = start ? dp(12) : 0;
        lp.rightMargin = start ? 0 : dp(12);
        root.setGravity(Gravity.TOP | (start ? Gravity.START : Gravity.END));
    }

    /** Expanded panels grow downwards; move the ball up if they would leave the screen. */
    private void keepOnScreen() {
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) root.getLayoutParams();
        int maxTop = Math.max(topInset(0), parent.getHeight() - root.getHeight());
        if (lp.topMargin > maxTop) {
            lp.topMargin = maxTop;
            root.setLayoutParams(lp);
        }
    }

    private int topInset(int desiredTop) {
        int cutout = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowInsets insets = parent.getRootWindowInsets();
            if (insets != null) cutout = insets.getInsets(WindowInsets.Type.displayCutout()).top;
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            WindowInsets insets = parent.getRootWindowInsets();
            if (insets != null) cutout = insets.getSystemWindowInsetTop();
        }
        return Math.max(desiredTop, cutout + dp(8));
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

    private GradientDrawable rounded(int color, int radiusDp, int strokeColor, int strokeDp) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(dp(radiusDp));
        if (strokeDp > 0) d.setStroke(dp(strokeDp), strokeColor);
        return d;
    }

    private GradientDrawable oval(int color) {
        GradientDrawable d = new GradientDrawable();
        d.setShape(GradientDrawable.OVAL);
        d.setColor(color);
        return d;
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
