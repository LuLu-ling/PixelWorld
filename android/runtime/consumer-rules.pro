# Classes and members looked up by name from libpojavexec and from the game's JVM
-keep class net.kdt.pojavlaunch.** { *; }
-keep class org.lwjgl.glfw.CallbackBridge { *; }
-keep class com.oracle.dalvik.VMLauncher { *; }
# SDL3 registers natives on and calls into these classes by name
-keep class org.libsdl.app.** { *; }
# Only libjnidispatch.so from the JNA aar is used (by the game); its Java classes may be removed
-dontwarn java.awt.**
