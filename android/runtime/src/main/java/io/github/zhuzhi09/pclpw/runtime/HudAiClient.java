package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
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
import java.util.List;

/**
 * Talks to the launcher's AI bridge over a loopback socket. The launcher owns the model
 * configuration and the AI client; the game process only sends the question and shows the
 * streamed answer, so there is no second copy of the prompt or the API key here.
 */
final class HudAiClient {

    interface Listener {
        void onStart();

        void onDelta(String text);

        void onDone();

        void onError(String message);
    }

    private final Activity activity;
    private final Handler main = new Handler(Looper.getMainLooper());

    private Socket socket;
    private Thread thread;
    private volatile boolean cancelled;

    HudAiClient(Activity activity) {
        this.activity = activity;
    }

    /** history entries are {role, content} pairs. */
    void ask(String question, String context, List<String[]> history, Listener listener) {
        cancel();
        cancelled = false;
        thread = new Thread(() -> run(question, context, history, listener), "PCLPW-HudAI");
        thread.setDaemon(true);
        thread.start();
    }

    void cancel() {
        cancelled = true;
        Socket s = socket;
        socket = null;
        if (s != null) {
            try {
                s.close();
            } catch (Throwable ignored) {
            }
        }
        Thread t = thread;
        thread = null;
        if (t != null) t.interrupt();
    }

    private void run(String question, String context, List<String[]> history, Listener listener) {
        try {
            JSONObject bridge = readBridge();
            if (bridge == null) {
                fail(listener, "启动器没有在运行，无法使用 AI。先回到启动器再试。");
                return;
            }
            int port = bridge.optInt("port");
            String token = bridge.optString("token");
            if (port <= 0 || token.isEmpty()) {
                fail(listener, "AI 连接还没有准备好，请回到启动器再试。");
                return;
            }

            Socket s = new Socket();
            socket = s;
            s.connect(new InetSocketAddress("127.0.0.1", port), 3000);
            s.setSoTimeout(120000);
            s.setTcpNoDelay(true);

            BufferedWriter out = new BufferedWriter(
                    new OutputStreamWriter(s.getOutputStream(), StandardCharsets.UTF_8));
            JSONObject hello = new JSONObject();
            hello.put("type", "hello");
            hello.put("token", token);
            out.write(hello.toString());
            out.write('\n');

            JSONObject req = new JSONObject();
            req.put("type", "ask");
            req.put("id", 1);
            req.put("text", question);
            req.put("context", context == null ? "" : context);
            JSONArray h = new JSONArray();
            for (String[] turn : history) {
                h.put(new JSONObject().put("role", turn[0]).put("content", turn[1]));
            }
            req.put("history", h);
            out.write(req.toString());
            out.write('\n');
            out.flush();

            BufferedReader in = new BufferedReader(
                    new InputStreamReader(s.getInputStream(), StandardCharsets.UTF_8));
            boolean started = false;
            boolean finished = false;
            String line;
            while (!cancelled && (line = in.readLine()) != null) {
                JSONObject res;
                try {
                    res = new JSONObject(line);
                } catch (Throwable ignored) {
                    continue;
                }
                String type = res.optString("type");
                switch (type) {
                    case "start":
                        started = true;
                        post(() -> {
                            if (!cancelled) listener.onStart();
                        });
                        break;
                    case "delta": {
                        String text = res.optString("text");
                        if (!text.isEmpty()) {
                            post(() -> {
                                if (!cancelled) listener.onDelta(text);
                            });
                        }
                        break;
                    }
                    case "done":
                        finished = true;
                        post(() -> {
                            if (!cancelled) listener.onDone();
                        });
                        break;
                    case "error": {
                        finished = true;
                        String message = res.optString("message", "AI 请求失败");
                        fail(listener, message);
                        break;
                    }
                    default:
                        break;
                }
                if (finished) break;
            }
            if (!cancelled && !finished) {
                fail(listener, started ? "AI 回答中断了，请重试。" : "AI 没有响应，请稍后再试。");
            }
        } catch (Throwable e) {
            if (!cancelled) {
                fail(listener, friendlyError(e));
            }
        } finally {
            Socket s = socket;
            socket = null;
            if (s != null) {
                try {
                    s.close();
                } catch (Throwable ignored) {
                }
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
        String name = e.getClass().getSimpleName();
        if (e instanceof java.net.ConnectException || e instanceof java.net.SocketTimeoutException
                || e instanceof java.net.NoRouteToHostException) {
            return "连不上启动器的 AI 服务。先回到启动器，再切回游戏试试。";
        }
        return "AI 请求失败：" + name;
    }

    private void fail(Listener listener, String message) {
        post(() -> {
            if (!cancelled) listener.onError(message);
        });
    }

    private void post(Runnable r) {
        main.post(r);
    }
}
