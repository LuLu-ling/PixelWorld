package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowInsets;
import android.view.inputmethod.InputMethodManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * In-game AI dialog. The page ({@code assets/hud_ai.html}) only draws; the conversations live in
 * the launcher and are read and written through {@link HudAiClient}, so the launcher's "AI" page
 * and the game show the same history.
 */
final class GameAiDialog {

    private final Activity activity;
    private final FrameLayout parent;
    private final GameHud owner;
    private final String instance;
    private final String renderer;
    private final SharedPreferences prefs;
    private final Handler handler = new Handler(Looper.getMainLooper());

    private HudAiClient client;
    private FrameLayout container;
    private WebView webView;
    private boolean open;
    private boolean pageReady;

    /** null: a new conversation that is created by the first question. */
    private String currentId;
    private JSONArray sessions = new JSONArray();
    private JSONArray messages = new JSONArray();
    private boolean busy;
    private int askId;
    private String lastQuestion = "";
    private final StringBuilder streaming = new StringBuilder();
    private String status = "";
    private String notice = "";
    private boolean loading;

    private Runnable onClosed;
    private ViewTreeObserver.OnGlobalLayoutListener imeListener;

    GameAiDialog(Activity activity, FrameLayout parent, GameHud owner, String instance, String renderer) {
        this.activity = activity;
        this.parent = parent;
        this.owner = owner;
        this.instance = instance;
        this.renderer = renderer;
        this.prefs = activity.getSharedPreferences("pclpw_hud_ai", Activity.MODE_PRIVATE);
        String saved = prefs.getString("current", "");
        this.currentId = saved.isEmpty() ? null : saved;
    }

    void setOnClosed(Runnable listener) {
        onClosed = listener;
    }

    boolean isOpen() {
        return open;
    }

    void show() {
        if (open) {
            if (container != null) {
                container.setVisibility(View.VISIBLE);
                parent.bringChildToFront(container);
            }
            return;
        }
        open = true;
        client = new HudAiClient(activity);
        ensureView();
        if (container == null) return;
        container.setVisibility(View.VISIBLE);
        parent.bringChildToFront(container);
        if (webView != null) {
            webView.onResume();
            webView.requestFocus();
        }
        refresh();
    }

    /** Closing does not stop an answer: it keeps going in the launcher and is saved there. */
    void hide() {
        if (!open) return;
        open = false;
        if (client != null) client.close();
        client = null;
        busy = false;
        streaming.setLength(0);
        destroyView();
        if (onClosed != null) onClosed.run();
    }

    void onPause() {
        if (webView != null) webView.onPause();
    }

    void onResume() {
        if (webView != null && open) webView.onResume();
    }

    void dispose() {
        if (client != null) client.close();
        client = null;
        destroyView();
        open = false;
    }

    // ---------- launcher data ----------

    private static JSONObject req(String type) {
        JSONObject o = new JSONObject();
        try {
            o.put("type", type);
        } catch (Throwable ignored) {
        }
        return o;
    }

    /** Imports conversations kept by older versions in the game process, then loads the list. */
    private void refresh() {
        if (client == null) return;
        loading = true;
        notice = "";
        pushState();
        String legacy = prefs.getString("sessions", "");
        if (!legacy.isEmpty() && !"[]".equals(legacy)) {
            try {
                JSONObject r = req("import").put("sessions", new JSONArray(legacy));
                client.request(r, msg -> {
                    if ("ok".equals(msg.optString("type"))) {
                        prefs.edit().remove("sessions").apply();
                        // Old ids are prefixed in the launcher
                        if (currentId != null && !currentId.startsWith("game-") && msg.optInt("count") > 0) {
                            currentId = "game-" + currentId;
                        }
                    }
                    loadList(true);
                });
                return;
            } catch (Throwable ignored) {
                prefs.edit().remove("sessions").apply();
            }
        }
        loadList(true);
    }

    private void loadList(boolean thenCurrent) {
        if (client == null) return;
        client.request(req("list"), msg -> {
            if ("error".equals(msg.optString("type"))) {
                loading = false;
                notice = msg.optString("message");
                pushState();
                return;
            }
            JSONArray list = msg.optJSONArray("sessions");
            sessions = list == null ? new JSONArray() : list;
            if (currentId != null && indexOf(currentId) < 0) setCurrent(null);
            if (thenCurrent && currentId != null) {
                load(currentId);
            } else {
                loading = false;
                pushState();
            }
        });
    }

    private void load(String id) {
        if (client == null) return;
        setCurrent(id);
        messages = new JSONArray();
        streaming.setLength(0);
        status = "";
        busy = false;
        loading = true;
        pushState();
        JSONObject r = req("load");
        try {
            r.put("session", id);
        } catch (Throwable ignored) {
        }
        final int[] requestId = new int[1];
        requestId[0] = client.request(r, msg -> {
            if (!id.equals(currentId)) return;
            String type = msg.optString("type");
            if ("load".equals(type)) {
                JSONObject s = msg.optJSONObject("session");
                messages = s != null && s.optJSONArray("messages") != null ? s.optJSONArray("messages") : new JSONArray();
                loading = false;
                busy = s != null && s.optBoolean("busy");
                if (busy) askId = requestId[0];
                pushState();
                return;
            }
            if ("error".equals(type) && !busy) {
                loading = false;
                notice = msg.optString("message");
                pushState();
                return;
            }
            // The launcher is still answering this conversation; it streams the rest here
            onAnswer(msg);
        });
    }

    private void ask(String text) {
        if (!open || busy || client == null) return;
        final String question = text == null ? "" : text.trim();
        if (question.isEmpty()) return;
        lastQuestion = question;
        try {
            messages.put(new JSONObject().put("role", "user").put("content", question));
        } catch (Throwable ignored) {
        }
        busy = true;
        notice = "";
        status = "正在连接启动器…";
        streaming.setLength(0);
        pushState();

        JSONObject r = req("ask");
        try {
            r.put("text", question);
            r.put("context", owner.aiContext());
            if (currentId != null) r.put("session", currentId);
        } catch (Throwable ignored) {
        }
        askId = client.request(r, this::onAnswer);
    }

    private void onAnswer(JSONObject msg) {
        if (msg.optInt("id") != askId) return;
        switch (msg.optString("type")) {
            case "start": {
                String id = msg.optString("session");
                if (!id.isEmpty() && !id.equals(currentId)) {
                    setCurrent(id);
                    try {
                        sessions = prepend(new JSONObject()
                                .put("id", id)
                                .put("title", msg.optString("title", "新对话"))
                                .put("updated", System.currentTimeMillis()));
                    } catch (Throwable ignored) {
                    }
                }
                status = "正在回答…";
                pushState();
                break;
            }
            case "delta":
                streaming.append(msg.optString("text"));
                call("PclHud.stream(" + JSONObject.quote(streaming.toString()) + ")");
                break;
            case "replace":
                streaming.setLength(0);
                streaming.append(msg.optString("text"));
                call("PclHud.stream(" + JSONObject.quote(streaming.toString()) + ")");
                break;
            case "status": {
                String text = msg.optString("text");
                status = text.isEmpty() ? "正在回答…" : text;
                call("PclHud.status(" + JSONObject.quote(status) + ")");
                break;
            }
            case "done":
                finishAnswer(null);
                loadList(false);
                break;
            case "error":
                finishAnswer(msg.optString("message", "AI 请求失败"));
                break;
            default:
                break;
        }
    }

    private void finishAnswer(String error) {
        boolean answered = streaming.length() > 0;
        if (answered) {
            try {
                messages.put(new JSONObject().put("role", "assistant").put("content", streaming.toString()));
            } catch (Throwable ignored) {
            }
        }
        busy = false;
        streaming.setLength(0);
        status = "";
        notice = error == null ? "" : error;
        pushState();
        // Nothing came back: give the question back so it can be sent again
        if (error != null && !answered && !lastQuestion.isEmpty()) {
            call("PclHud.restore(" + JSONObject.quote(lastQuestion) + ")");
        }
    }

    private void stop() {
        if (!busy || client == null || currentId == null) return;
        JSONObject r = req("cancel");
        try {
            r.put("session", currentId);
        } catch (Throwable ignored) {
        }
        client.request(r, null);
        status = "正在停止…";
        call("PclHud.status(" + JSONObject.quote(status) + ")");
    }

    private void newSession() {
        if (busy) return;
        setCurrent(null);
        messages = new JSONArray();
        notice = "";
        pushState();
    }

    private void delete(String id) {
        if (client == null) return;
        JSONObject r = req("delete");
        try {
            r.put("session", id);
        } catch (Throwable ignored) {
        }
        if (id.equals(currentId)) {
            if (busy) return;
            setCurrent(null);
            messages = new JSONArray();
        }
        JSONArray next = new JSONArray();
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s != null && !id.equals(s.optString("id"))) next.put(s);
        }
        sessions = next;
        pushState();
        client.request(r, msg -> loadList(false));
    }

    private void setCurrent(String id) {
        currentId = id;
        prefs.edit().putString("current", id == null ? "" : id).apply();
    }

    private int indexOf(String id) {
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s != null && id.equals(s.optString("id"))) return i;
        }
        return -1;
    }

    private JSONArray prepend(JSONObject first) {
        JSONArray next = new JSONArray();
        next.put(first);
        String id = first.optString("id");
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s != null && !id.equals(s.optString("id"))) next.put(s);
        }
        return next;
    }

    private void pushState() {
        if (!pageReady || webView == null) return;
        try {
            JSONObject state = new JSONObject();
            state.put("sessions", sessions);
            state.put("currentId", currentId == null ? "" : currentId);
            state.put("messages", messages);
            state.put("busy", busy);
            state.put("loading", loading);
            state.put("streaming", streaming.toString());
            state.put("status", status);
            state.put("notice", notice);
            state.put("instance", instance + rendererName());
            call("PclHud.state(" + JSONObject.quote(state.toString()) + ")");
        } catch (Throwable ignored) {
        }
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

    // ---------- WebView ----------

    private void ensureView() {
        if (container != null) return;
        container = new FrameLayout(activity);
        container.setBackgroundColor(Color.TRANSPARENT);
        container.setVisibility(View.GONE);

        webView = new WebView(activity);
        webView.setBackgroundColor(Color.TRANSPARENT);
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(false);
        settings.setAllowFileAccessFromFileURLs(false);
        settings.setAllowUniversalAccessFromFileURLs(false);
        settings.setSupportZoom(false);
        settings.setBuiltInZoomControls(false);
        settings.setTextZoom(100);
        settings.setMediaPlaybackRequiresUserGesture(true);
        webView.setVerticalScrollBarEnabled(false);
        webView.setHorizontalScrollBarEnabled(false);
        webView.setOverScrollMode(View.OVER_SCROLL_NEVER);
        webView.addJavascriptInterface(new Bridge(), "PclHudNative");
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                openLink(request.getUrl());
                return true;
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                pageReady = true;
                updateIme();
                pushState();
            }
        });

        container.addView(webView, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        parent.addView(container, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        imeListener = this::updateIme;
        container.getViewTreeObserver().addOnGlobalLayoutListener(imeListener);

        try {
            String html = readAsset("hud_ai.html");
            String marked = readAsset("hud_ai_marked.js");
            html = html.replace("/*MARKED_JS*/", marked);
            webView.loadDataWithBaseURL("https://pclpw.local/", html, "text/html", "UTF-8", null);
        } catch (Throwable e) {
            TextView error = new TextView(activity);
            error.setText("无法打开游戏内 AI 界面：\n" + e);
            error.setTextColor(0xFF1F1F1F);
            error.setBackgroundColor(0xFFEDEDED);
            error.setTextSize(13);
            int pad = Math.round(20 * activity.getResources().getDisplayMetrics().density);
            error.setPadding(pad, pad, pad, pad);
            container.removeAllViews();
            container.addView(error);
        }
    }

    private void destroyView() {
        if (container != null) {
            if (imeListener != null) {
                ViewTreeObserver observer = container.getViewTreeObserver();
                if (observer.isAlive()) observer.removeOnGlobalLayoutListener(imeListener);
                imeListener = null;
            }
            parent.removeView(container);
            container = null;
        }
        if (webView != null) {
            InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
            if (imm != null) imm.hideSoftInputFromWindow(webView.getWindowToken(), 0);
            webView.clearFocus();
            webView.removeJavascriptInterface("PclHudNative");
            webView.destroy();
            webView = null;
        }
        pageReady = false;
    }

    private void openLink(Uri uri) {
        if (uri == null) return;
        String scheme = uri.getScheme();
        if (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme)) return;
        try {
            activity.startActivity(new Intent(Intent.ACTION_VIEW, uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
        } catch (Throwable ignored) {
        }
    }

    private void copy(String text) {
        try {
            ClipboardManager cm = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
            if (cm == null) return;
            cm.setPrimaryClip(ClipData.newPlainText("Pixel World AI", text));
            // Android 13+ shows its own confirmation
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                Toast.makeText(activity, "已复制", Toast.LENGTH_SHORT).show();
            }
        } catch (Throwable ignored) {
        }
    }

    private String readAsset(String name) throws Exception {
        try (InputStream in = activity.getAssets().open(name)) {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buffer = new byte[8192];
            int n;
            while ((n = in.read(buffer)) > 0) out.write(buffer, 0, n);
            return new String(out.toByteArray(), StandardCharsets.UTF_8);
        }
    }

    private void call(String js) {
        if (webView == null || !pageReady) return;
        try {
            webView.evaluateJavascript(js, null);
        } catch (Throwable ignored) {
        }
    }

    /** Keep the composer above the soft keyboard even though the game uses adjustNothing. */
    private void updateIme() {
        if (container == null || !pageReady) return;
        Rect frame = new Rect();
        container.getWindowVisibleDisplayFrame(frame);
        int screen = container.getRootView().getHeight();
        int ime = Math.max(0, screen - frame.bottom);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowInsets insets = container.getRootWindowInsets();
            if (insets != null) ime = Math.max(ime, insets.getInsets(WindowInsets.Type.ime()).bottom);
        }
        float density = activity.getResources().getDisplayMetrics().density;
        call("PclHud.ime(" + Math.round(ime / (density > 0 ? density : 1f)) + ")");
    }

    private final class Bridge {
        @JavascriptInterface
        public void ready() {
            handler.post(() -> {
                pageReady = true;
                updateIme();
                pushState();
            });
        }

        @JavascriptInterface
        public void ask(String text) {
            handler.post(() -> GameAiDialog.this.ask(text));
        }

        @JavascriptInterface
        public void stop() {
            handler.post(GameAiDialog.this::stop);
        }

        @JavascriptInterface
        public void newSession() {
            handler.post(GameAiDialog.this::newSession);
        }

        @JavascriptInterface
        public void selectSession(String id) {
            handler.post(() -> {
                if (!busy && id != null && !id.equals(currentId)) load(id);
            });
        }

        @JavascriptInterface
        public void deleteSession(String id) {
            handler.post(() -> delete(id));
        }

        @JavascriptInterface
        public void reload() {
            handler.post(GameAiDialog.this::refresh);
        }

        @JavascriptInterface
        public void copy(String text) {
            handler.post(() -> GameAiDialog.this.copy(text));
        }

        @JavascriptInterface
        public void openLauncher() {
            handler.post(() -> {
                hide();
                owner.openLauncher();
            });
        }

        @JavascriptInterface
        public void close() {
            handler.post(GameAiDialog.this::hide);
        }
    }
}
