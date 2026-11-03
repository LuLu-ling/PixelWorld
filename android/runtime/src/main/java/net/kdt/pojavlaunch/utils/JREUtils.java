package net.kdt.pojavlaunch.utils;

import android.content.Context;

/**
 * Native entry points of libpojavexec. The class name is fixed by the JNI symbols.
 * Derived from Amethyst-Android's JREUtils (LGPL-3.0); the launch logic lives in GameRuntime.
 */
public final class JREUtils {
    private JREUtils() {}

    public static native int chdir(String path);
    public static native boolean dlopen(String libPath);
    public static native void setLdLibraryPath(String ldLibraryPath);
    public static native void setupBridgeWindow(Object surface);
    public static native void releaseBridgeWindow();
    public static native void setupExitMethod(Context context);
    /** Registers the atexit handler that leaves through Android when the game exits */
    public static native void initializeHooks();

    static {
        System.loadLibrary("pojavexec");
    }
}
