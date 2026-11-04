package io.github.zhuzhi09.pclpw.runtime;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import net.kdt.pojavlaunch.Logger;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Runs one jar without a window in its own process ({@code :jar}). The launcher binds to it while
 * it runs, so the process keeps the launcher's priority, and learns that it finished when the
 * process goes away. A process can start the JVM only once, so it exits afterwards.
 */
public final class JarService extends Service {
    private static final String TAG = "PCLPW-Jar";

    public static final String EXTRA_JAVA_HOME = "javaHome";
    public static final String EXTRA_WORK_DIR = "workDir";
    public static final String EXTRA_LOG_FILE = "logFile";
    public static final String EXTRA_ARGS = "args";

    private boolean started;

    @Override
    public IBinder onBind(Intent intent) {
        if (!started) {
            started = true;
            start(intent);
        }
        return new Binder();
    }

    private void start(Intent intent) {
        File javaHome = new File(intent.getStringExtra(EXTRA_JAVA_HOME));
        File workDir = new File(intent.getStringExtra(EXTRA_WORK_DIR));
        File logFile = new File(intent.getStringExtra(EXTRA_LOG_FILE));
        ArrayList<String> args = new ArrayList<>(Arrays.asList(intent.getStringArrayExtra(EXTRA_ARGS)));
        Thread t = new Thread(() -> {
            int code;
            try {
                code = GameRuntime.runJar(this, javaHome, workDir, logFile, args);
            } catch (Throwable e) {
                Log.e(TAG, "Run failed", e);
                try {
                    Logger.appendToLog("PCL.PW runtime: run failed: " + Log.getStackTraceString(e));
                } catch (Throwable ignored) {
                    // The native logger is not available
                }
                code = -1;
            }
            if (code != 0) GameRuntime.recordExit(this, code, false);
            System.exit(code);
        }, "Jar");
        t.start();
    }
}
