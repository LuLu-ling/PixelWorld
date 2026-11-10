package io.github.zhuzhi09.pclpw.runtime;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.system.Os;
import android.util.Log;
import android.util.SparseIntArray;
import android.view.MotionEvent;
import android.view.View;

import net.kdt.pojavlaunch.Logger;

import top.fifthlight.touchcontroller.proxy.client.LauncherProxyClient;
import top.fifthlight.touchcontroller.proxy.client.MessageTransport;
import top.fifthlight.touchcontroller.proxy.client.android.transport.UnixSocketTransportKt;

/**
 * Bridge to the TouchController mod (https://github.com/TouchController/TouchController, LGPL-3.0):
 * Bedrock-style touch controls inside Java Edition. GLFW has no touch input, so the launcher
 * forwards every finger to the mod over a Unix socket whose name it passes in
 * TOUCH_CONTROLLER_PROXY_SOCKET. Coordinates are relative to the game view, in [0, 1].
 */
final class TouchControllerBridge implements AutoCloseable {
    private static final String TAG = "PCLPW-TouchController";
    /** Socket name of the running proxy; GameRuntime exports it again right before the JVM starts */
    static volatile String socketName;

    private final LauncherProxyClient client;
    /** Android pointer id -> TouchController pointer index (must only grow) */
    private final SparseIntArray ids = new SparseIntArray();
    private int nextId = 1;

    private TouchControllerBridge(LauncherProxyClient client) {
        this.client = client;
    }

    /** Opens the socket and exports its name to the game; null when that fails */
    static TouchControllerBridge start(Context context) {
        String name = "PixelWorld-TouchController-" + android.os.Process.myPid();
        try {
            MessageTransport transport = UnixSocketTransportKt.UnixSocketTransport(name);
            LauncherProxyClient client = new LauncherProxyClient(transport);
            Vibrator vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
            if (vibrator != null) {
                client.setVibrationHandler(kind -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            vibrator.vibrate(VibrationEffect.createOneShot(30, VibrationEffect.DEFAULT_AMPLITUDE));
                        } else {
                            vibrator.vibrate(30);
                        }
                    } catch (Throwable ignored) {
                    }
                });
            }
            client.run();
            Os.setenv("TOUCH_CONTROLLER_PROXY_SOCKET", name, true);
            socketName = name;
            Log.i(TAG, "proxy started on @" + name + ", env=" + Os.getenv("TOUCH_CONTROLLER_PROXY_SOCKET"));
            Logger.appendToLog("Pixel World runtime: TouchController proxy on @" + name);
            return new TouchControllerBridge(client);
        } catch (Throwable e) {
            Log.w(TAG, "Cannot start the TouchController proxy", e);
            return null;
        }
    }

    /** Forwards a touch event on [view] (the game surface) to the mod */
    void onTouch(View view, MotionEvent e) {
        float w = Math.max(1, view.getWidth()), h = Math.max(1, view.getHeight());
        switch (e.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_POINTER_DOWN: {
                int i = e.getActionIndex();
                int id = nextId++;
                ids.put(e.getPointerId(i), id);
                client.addPointer(id, e.getX(i) / w, e.getY(i) / h);
                break;
            }
            case MotionEvent.ACTION_MOVE:
                for (int i = 0; i < e.getPointerCount(); i++) {
                    int id = ids.get(e.getPointerId(i));
                    if (id != 0) client.addPointer(id, e.getX(i) / w, e.getY(i) / h);
                }
                break;
            case MotionEvent.ACTION_POINTER_UP: {
                int pointer = e.getPointerId(e.getActionIndex());
                int id = ids.get(pointer);
                ids.delete(pointer);
                if (id != 0) client.removePointer(id);
                break;
            }
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                ids.clear();
                client.clearPointer();
                break;
            default:
                break;
        }
    }

    /** Lifts every finger, e.g. when a menu opens */
    void clear() {
        ids.clear();
        client.clearPointer();
    }

    @Override
    public void close() {
        try {
            client.close();
        } catch (Throwable ignored) {
        }
    }
}
