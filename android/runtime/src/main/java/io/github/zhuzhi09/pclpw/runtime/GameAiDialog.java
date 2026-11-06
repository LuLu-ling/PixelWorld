package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
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

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Full in-game AI dialog. The layout and Markdown rendering live in a local WebView
 * ({@code assets/hud_ai.html}); sessions and the connection to the launcher's AI bridge stay in
 * Java. The WebView only talks to the game through the small {@link Bridge} interface.
 */
final class GameAiDialog {

    private final Activity activity;
    private final FrameLayout parent;
    private final GameHud owner;
    private final String instance;
    private final String renderer;
    private final String logFile;
    private final boolean attachLog;
    private final SharedPreferences prefs;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final HudAiClient aiClient;

    private FrameLayout container;
    private WebView webView;
    private boolean open;
    private boolean pageReady;
    private boolean busy;
    private boolean sessionsLoaded;
    private String currentId = "";
    private JSONArray sessions = new JSONArray();
    private final StringBuilder answer = new StringBuilder();
    private Runnable onClosed;
    private ViewTreeObserver.OnGlobalLayoutListener imeListener;

    GameAiDialog(Activity activity, FrameLayout parent, GameHud owner,
                 String instance, String renderer, String logFile, boolean attachLog) {
        this.activity = activity;
        this.parent = parent;
        this.owner = owner;
        this.instance = instance;
        this.renderer = renderer;
        this.logFile = logFile;
        this.attachLog = attachLog;
        this.prefs = activity.getSharedPreferences("pclpw_hud_ai", Activity.MODE_PRIVATE);
        this.aiClient = new HudAiClient(activity);
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
            if (webView != null) webView.onResume();
            return;
        }
        open = true;
        ensureView();
        if (container == null) return;
        if (!sessionsLoaded) loadSessions();
        container.setVisibility(View.VISIBLE);
        parent.bringChildToFront(container);
        if (webView != null) {
            webView.onResume();
            webView.requestFocus();
        }
        if (pageReady) pushState();
    }

    void hide() {
        if (!open) return;
        open = false;
        aiClient.cancel();
        busy = false;
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
        aiClient.cancel();
        destroyView();
        open = false;
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
            error.setTextColor(0xFFFF9D9D);
            error.setTextSize(13);
            error.setPadding(dp(20), dp(20), dp(20), dp(20));
            container.removeAllViews();
            container.addView(error);
        }
    }

    private void openLink(Uri uri) {
        if (uri == null) return;
        String scheme = uri.getScheme();
        if (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme)) return;
        try {
            activity.startActivity(new Intent(Intent.ACTION_VIEW, uri)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
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
        public void newSession() {
            handler.post(GameAiDialog.this::newSession);
        }

        @JavascriptInterface
        public void selectSession(String id) {
            handler.post(() -> select(id));
        }

        @JavascriptInterface
        public void deleteSession(String id) {
            handler.post(() -> delete(id));
        }

        @JavascriptInterface
        public void close() {
            handler.post(GameAiDialog.this::hide);
        }
    }

    // ---------- sessions ----------

    private void loadSessions() {
        try {
            sessions = new JSONArray(prefs.getString("sessions", "[]"));
        } catch (Throwable e) {
            sessions = new JSONArray();
        }
        if (sessions.length() == 0) {
            newSession();
            sessionsLoaded = true;
            return;
        }
        currentId = prefs.getString("current", "");
        if (find(currentId) == null) currentId = sessions.optJSONObject(0).optString("id");
        sessionsLoaded = true;
    }

    private JSONObject currentSession() {
        return find(currentId);
    }

    private JSONObject find(String id) {
        if (TextUtils.isEmpty(id)) return null;
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s != null && id.equals(s.optString("id"))) return s;
        }
        return null;
    }

    private void newSession() {
        String id = UUID.randomUUID().toString();
        JSONObject session = new JSONObject();
        try {
            session.put("id", id);
            session.put("title", "新对话");
            session.put("updated", System.currentTimeMillis());
            session.put("messages", new JSONArray());
        } catch (Throwable ignored) {
        }
        currentId = id;
        moveToFront(session);
        save();
        pushState();
    }

    private void select(String id) {
        if (find(id) == null) return;
        currentId = id;
        save();
        pushState();
    }

    private void delete(String id) {
        JSONArray next = new JSONArray();
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s == null || id.equals(s.optString("id"))) continue;
            next.put(s);
        }
        sessions = next;
        if (sessions.length() == 0) {
            newSession();
            return;
        }
        if (id.equals(currentId)) currentId = sessions.optJSONObject(0).optString("id");
        save();
        pushState();
    }

    private void moveToFront(JSONObject session) {
        JSONArray next = new JSONArray();
        next.put(session);
        String id = session.optString("id");
        for (int i = 0; i < sessions.length(); i++) {
            JSONObject s = sessions.optJSONObject(i);
            if (s == null || id.equals(s.optString("id"))) continue;
            next.put(s);
        }
        sessions = next;
    }

    private void save() {
        prefs.edit()
                .putString("sessions", sessions.toString())
                .putString("current", currentId)
                .apply();
    }

    private void ask(String text) {
        if (!open || busy) return;
        final String question = text == null ? "" : text.trim();
        if (question.isEmpty()) return;
        JSONObject session = currentSession();
        if (session == null) {
            newSession();
            session = currentSession();
        }
        if (session == null) return;
        JSONArray messages = session.optJSONArray("messages");
        if (messages == null) {
            messages = new JSONArray();
            try {
                session.put("messages", messages);
            } catch (Throwable ignored) {
            }
        }
        try {
            messages.put(new JSONObject().put("role", "user").put("content", question));
            if ("新对话".equals(session.optString("title"))) {
                session.put("title", titleFrom(question));
            }
            session.put("updated", System.currentTimeMillis());
        } catch (Throwable ignored) {
        }
        moveToFront(session);
        save();
        busy = true;
        answer.setLength(0);
        pushState();
        call("PclHud.busy(true)");

        final List<String[]> history = new ArrayList<>();
        try {
            int last = messages.length() - 1;
            for (int i = Math.max(0, last - 8); i < last; i++) {
                JSONObject m = messages.optJSONObject(i);
                if (m == null) continue;
                String role = m.optString("role");
                String content = m.optString("content");
                if ((role.equals("user") || role.equals("assistant")) && !content.isEmpty()) {
                    history.add(new String[]{role, content});
                }
            }
        } catch (Throwable ignored) {
        }

        final JSONObject target = session;
        aiClient.ask(question, owner.aiContext(), history, new HudAiClient.Listener() {
            @Override
            public void onStart() {
                if (open) call("PclHud.busy(true)");
            }

            @Override
            public void onDelta(String text) {
                if (!open) return;
                answer.append(text);
                call("PclHud.delta(" + JSONObject.quote(text) + ")");
            }

            @Override
            public void onDone() {
                busy = false;
                if (!open) return;
                try {
                    JSONArray messages = target.optJSONArray("messages");
                    if (messages != null) {
                        messages.put(new JSONObject().put("role", "assistant").put("content", answer.toString()));
                    }
                    target.put("updated", System.currentTimeMillis());
                    moveToFront(target);
                    save();
                } catch (Throwable ignored) {
                }
                call("PclHud.done()");
                pushState();
            }

            @Override
            public void onError(String message) {
                busy = false;
                if (open) call("PclHud.error(" + JSONObject.quote(message) + ")");
            }
        });
    }

    private static String titleFrom(String text) {
        String line = text.trim().split("\n")[0].trim();
        return line.length() > 30 ? line.substring(0, 30) + "…" : (line.isEmpty() ? "新对话" : line);
    }

    // ---------- JS state ----------

    private void pushState() {
        if (!pageReady || webView == null) return;
        try {
            JSONObject state = new JSONObject();
            JSONArray list = new JSONArray();
            for (int i = 0; i < sessions.length(); i++) {
                JSONObject s = sessions.optJSONObject(i);
                if (s == null) continue;
                list.put(new JSONObject()
                        .put("id", s.optString("id"))
                        .put("title", s.optString("title"))
                        .put("updated", s.optLong("updated")));
            }
            state.put("sessions", list);
            state.put("currentId", currentId);
            JSONObject current = currentSession();
            state.put("messages", current != null ? current.optJSONArray("messages") : new JSONArray());
            state.put("busy", busy);
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
            if (insets != null) {
                ime = Math.max(ime, insets.getInsets(WindowInsets.Type.ime()).bottom);
            }
        }
        float density = activity.getResources().getDisplayMetrics().density;
        int css = Math.round(ime / (density > 0 ? density : 1f));
        call("PclHud.ime(" + css + ")");
    }

    private int dp(float v) {
        return Math.round(v * activity.getResources().getDisplayMetrics().density);
    }
}
