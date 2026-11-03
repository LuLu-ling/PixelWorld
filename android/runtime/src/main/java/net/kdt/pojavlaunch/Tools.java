package net.kdt.pojavlaunch;

/** Native helpers of libpojavexec. The class name is fixed by the JNI symbols. */
public final class Tools {
    private Tools() {}

    /** Pointer to the Dalvik object as a string, passed to the JVM side through the environment */
    public static native String jObjectToString(Object object);

    /** Pointer to the Dalvik JavaVM */
    public static native long getJavaVMPointer();

    static {
        System.loadLibrary("pojavexec");
    }
}
