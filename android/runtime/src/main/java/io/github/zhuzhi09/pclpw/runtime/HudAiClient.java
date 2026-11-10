package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Connection to the launcher's AI bridge (lib/core/hud_bridge.dart) over a loopback socket.
 *
 * <p>The launcher owns the model settings, the API key and the conversation history; the game
 * process only sends requests and shows what comes back. One connection carries several requests;
 * every reply carries the id of its request and is delivered to that request's callback on the
 * main thread.
 */
final class HudAiClient {

    interface Callback {
        /** Called on the main thread for every reply to the request. */
        void onMessage(JSONObject message);
    }

    /** Reply types after which a request is finished. */
    private static boolean isFinal(String type) {
        switch (type) {
            case "list":
            case "load":
            case "ok":
            case "done":
            case "error":
                return true;
            default:
                return false;
        }
    }

    private final Activity activity;
    private final Handler main = new Handler(Looper.getMainLooper());
    private final ExecutorService io = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "PCLPW-HudAI");
        t.setDaemon(true);
        return t;
    });
    private final Map<Integer, Callback> callbacks = new ConcurrentHashMap<>();
    private final AtomicInteger nextId = new AtomicInteger(1);

    private Socket socket;
    private BufferedWriter out;
    private volatile boolean closed;

    HudAiClient(Activity activity) {
        this.activity = activity;
    }

    /** Sends a request; {@code callback} may be null when no reply is needed. */
    int request(JSONObject request, Callback callback) {
        final int id = nextId.getAndIncrement();
        try {
            request.put("id", id);
        } catch (Throwable ignored) {
        }
        if (callback != null) callbacks.put(id, callback);
        closed = false;
        io.execute(() -> {
            try {
                ensureConnected();
                out.write(request.toString());
                out.write('\n');
                out.flush();
            } catch (Throwable e) {
                disconnect();
                fail(id, friendlyError(e));
            }
        });
        return id;
    }

    /** Stops delivering replies and closes the connection. Answers still finish in the launcher. */
    void close() {
        closed = true;
        callbacks.clear();
        io.execute(this::disconnect);
    }

    // ---------- connection (io thread) ----------

    private void ensureConnected() throws Exception {
        if (socket != null && !socket.isClosed()) return;
        JSONObject bridge = readBridge();
        if (bridge == null) throw new IllegalStateException("启动器没有在运行，无法使用 AI。先回到启动器再试。");
        int port = bridge.optInt("port");
        String token = bridge.optString("token");
        if (port <= 0 || token.isEmpty()) throw new IllegalStateException("AI 连接还没有准备好，请回到启动器再试。");

        Socket s = new Socket();
        s.connect(new InetSocketAddress("127.0.0.1", port), 3000);
        s.setTcpNoDelay(true);
        BufferedWriter w = new BufferedWriter(new OutputStreamWriter(s.getOutputStream(), StandardCharsets.UTF_8));
        w.write(new JSONObject().put("type", "hello").put("token", token).toString());
        w.write('\n');
        w.flush();
        socket = s;
        out = w;

        Thread reader = new Thread(() -> read(s), "PCLPW-HudAI-read");
        reader.setDaemon(true);
        reader.start();
    }

    private void read(Socket s) {
        try {
            BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream(), StandardCharsets.UTF_8));
            String line;
            while ((line = in.readLine()) != null) {
                final JSONObject msg;
                try {
                    msg = new JSONObject(line);
                } catch (Throwable ignored) {
                    continue;
                }
                final int id = msg.optInt("id");
                // Loading a conversation that is still being answered: the answer follows on the same id
                JSONObject loaded = msg.optJSONObject("session");
                boolean streams = "load".equals(msg.optString("type")) && loaded != null && loaded.optBoolean("busy");
                final Callback cb = isFinal(msg.optString("type")) && !streams ? callbacks.remove(id) : callbacks.get(id);
                if (cb != null) post(() -> cb.onMessage(msg));
            }
        } catch (Throwable ignored) {
            // socket closed
        }
        io.execute(() -> {
            if (socket == s) disconnect();
        });
        // Everything still waiting lost its answer
        if (!closed) {
            List<Integer> ids = new ArrayList<>(callbacks.keySet());
            for (int id : ids) fail(id, "和启动器的连接断开了。回答会在启动器里继续完成，可以稍后在这里重新打开这个对话。");
        }
    }

    private void disconnect() {
        Socket s = socket;
        socket = null;
        out = null;
        if (s != null) {
            try {
                s.close();
            } catch (Throwable ignored) {
            }
        }
    }

    private JSONObject readBridge() {
        File file = new File(activity.getFilesDir(), "hud_bridge.json");
        if (!file.exists()) return null;
        try (FileInputStream in = new FileInputStream(file);
             InputStreamReader reader = new InputStreamReader(in, StandardCharsets.UTF_8)) {
            StringBuilder text = new StringBuilder();
            char[] buf = new char[1024];
            int n;
            while ((n = reader.read(buf)) > 0) text.append(buf, 0, n);
            return new JSONObject(text.toString());
        } catch (Throwable ignored) {
            return null;
        }
    }

    private static String friendlyError(Throwable e) {
        if (e instanceof IllegalStateException && e.getMessage() != null) return e.getMessage();
        if (e instanceof java.net.ConnectException || e instanceof java.net.SocketTimeoutException
                || e instanceof java.net.NoRouteToHostException) {
            return "连不上启动器的 AI 服务。先回到启动器，再切回游戏试试。";
        }
        return "AI 请求失败：" + e.getClass().getSimpleName();
    }

    private void fail(int id, String message) {
        final Callback cb = callbacks.remove(id);
        if (cb == null || closed) return;
        final JSONObject msg = new JSONObject();
        try {
            msg.put("type", "error").put("id", id).put("message", message);
        } catch (Throwable ignored) {
        }
        post(() -> cb.onMessage(msg));
    }

    private void post(Runnable r) {
        main.post(() -> {
            if (!closed) r.run();
        });
    }
}
