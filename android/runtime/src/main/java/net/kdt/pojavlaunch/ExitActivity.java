package net.kdt.pojavlaunch;

import android.content.Context;

import androidx.annotation.Keep;

import io.github.zhuzhi09.pclpw.runtime.GameRuntime;

/**
 * Called by libpojavexec when the JVM exits with a non-zero code or a fatal signal.
 * The class and method names are fixed by the native side.
 */
@Keep
public final class ExitActivity {
    private ExitActivity() {}

    @Keep
    public static void showExitMessage(Context context, int code, boolean isSignal) {
        GameRuntime.recordExit(context, code, isSignal);
    }
}
