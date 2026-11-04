package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import android.system.ErrnoException;
import android.system.Os;
import android.util.Log;

import com.oracle.dalvik.VMLauncher;

import net.kdt.pojavlaunch.Logger;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.utils.JREUtils;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.compressors.xz.XZCompressorInputStream;
import org.lwjgl.glfw.CallbackBridge;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * Runs Minecraft: Java Edition inside this process with an Android build of OpenJDK,
 * LWJGL 3 with the GLFW stub, and MobileGlues as the OpenGL implementation.
 *
 * <p>This is the only API the launcher uses, so the runtime can be replaced later.
 * The environment and arguments follow Amethyst-Android's JREUtils (LGPL-3.0).
 */
public final class GameRuntime {
    private static final String TAG = "PCLPW-Runtime";
    /** Default LWJGL; 26.x needs {@link #LWJGL_SDL_VERSION} */
    public static final String LWJGL_VERSION = "3.3.3";
    /** LWJGL with SDL3 support, for versions that use SDL instead of GLFW */
    public static final String LWJGL_SDL_VERSION = "3.4.1";
    public static final String RENDERER_LIB = "libmobileglues.so";

    /** Renderers the launcher can choose; see {@link #rendererConfig} */
    public static final String MOBILEGLUES = "mobileglues";
    /** MobileGlues running its GLES calls on ANGLE (GLES over Vulkan) */
    public static final String MOBILEGLUES_ANGLE = "angle";
    /** Mesa Zink: desktop OpenGL 4.6 over the device's Vulkan driver */
    public static final String ZINK = "zink";
    /** The device's own GLES driver without translation, only for mods that render with GLES */
    public static final String SYSTEM_GLES = "system_gles";

    /**
     * Environment of a renderer: the AMETHYST_RENDERER name the native bridge understands, the EGL
     * library it creates contexts with, and the library LWJGL loads OpenGL from (it must export
     * glXGetProcAddress; libpojavexec does that for plain EGL implementations).
     */
    static final class RendererConfig {
        final String amethyst, egl, gl;
        final boolean ffpWrapper;

        RendererConfig(String amethyst, String egl, String gl, boolean ffpWrapper) {
            this.amethyst = amethyst;
            this.egl = egl;
            this.gl = gl;
            this.ffpWrapper = ffpWrapper;
        }
    }

    static RendererConfig rendererConfig(String renderer) {
        switch (renderer) {
            case ZINK:
                // Zink is a full desktop GL, so it needs no fixed-function wrapper
                return new RendererConfig("opengles3_desktopgl_zink_kopper", "libEGL_mesa.so", "libpojavexec.so", false);
            case SYSTEM_GLES:
                return new RendererConfig("opengles_system_gles", null, "libpojavexec.so", false);
            default:
                return new RendererConfig("opengles_mobileglues", RENDERER_LIB, RENDERER_LIB, true);
        }
    }
    /** Emulates the fixed-function pipeline on top of the renderer, for versions before 1.17 */
    public static final String FFP_WRAPPER_LIB = "libSimpleFPEWrapper.so";
    /** LWJGL 2 API on top of LWJGL 3, for 1.12.2 and older */
    public static final String LWJGLX_JAR = "lwjgl-lwjglx.jar";

    private GameRuntime() {}

    // ---------- Device ----------

    /**
     * The GPU as the system GLES driver reports it (a 1x1 offscreen context), and the Vulkan
     * version the device declares; used to pick a renderer.
     */
    public static Map<String, Object> gpuInfo(Context context) {
        Map<String, Object> out = new LinkedHashMap<>();
        android.opengl.EGLDisplay display = android.opengl.EGL14.eglGetDisplay(android.opengl.EGL14.EGL_DEFAULT_DISPLAY);
        int[] version = new int[2];
        if (android.opengl.EGL14.eglInitialize(display, version, 0, version, 1)) {
            int[] attribs = {
                    android.opengl.EGL14.EGL_RENDERABLE_TYPE, 0x40 /* EGL_OPENGL_ES3_BIT */,
                    android.opengl.EGL14.EGL_SURFACE_TYPE, android.opengl.EGL14.EGL_PBUFFER_BIT,
                    android.opengl.EGL14.EGL_NONE};
            android.opengl.EGLConfig[] configs = new android.opengl.EGLConfig[1];
            int[] count = new int[1];
            if (android.opengl.EGL14.eglChooseConfig(display, attribs, 0, configs, 0, 1, count, 0) && count[0] > 0) {
                android.opengl.EGLContext ctx = android.opengl.EGL14.eglCreateContext(display, configs[0],
                        android.opengl.EGL14.EGL_NO_CONTEXT, new int[]{android.opengl.EGL14.EGL_CONTEXT_CLIENT_VERSION, 3,
                                android.opengl.EGL14.EGL_NONE}, 0);
                android.opengl.EGLSurface surface = android.opengl.EGL14.eglCreatePbufferSurface(display, configs[0],
                        new int[]{android.opengl.EGL14.EGL_WIDTH, 1, android.opengl.EGL14.EGL_HEIGHT, 1,
                                android.opengl.EGL14.EGL_NONE}, 0);
                if (ctx != android.opengl.EGL14.EGL_NO_CONTEXT
                        && android.opengl.EGL14.eglMakeCurrent(display, surface, surface, ctx)) {
                    out.put("renderer", android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER));
                    out.put("vendor", android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_VENDOR));
                    out.put("glesVersion", android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_VERSION));
                    android.opengl.EGL14.eglMakeCurrent(display, android.opengl.EGL14.EGL_NO_SURFACE,
                            android.opengl.EGL14.EGL_NO_SURFACE, android.opengl.EGL14.EGL_NO_CONTEXT);
                }
                if (surface != android.opengl.EGL14.EGL_NO_SURFACE) android.opengl.EGL14.eglDestroySurface(display, surface);
                if (ctx != android.opengl.EGL14.EGL_NO_CONTEXT) android.opengl.EGL14.eglDestroyContext(display, ctx);
            }
            android.opengl.EGL14.eglTerminate(display);
        }
        // Highest declared Vulkan API version, e.g. 0x403000 = 1.3
        int vulkan = 0;
        for (android.content.pm.FeatureInfo f : context.getPackageManager().getSystemAvailableFeatures()) {
            if (android.content.pm.PackageManager.FEATURE_VULKAN_HARDWARE_VERSION.equals(f.name)) vulkan = f.version;
        }
        out.put("vulkan", vulkan == 0 ? "" : ((vulkan >> 22) + "." + ((vulkan >> 12) & 0x3ff)));
        out.put("soc", Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ? Build.SOC_MODEL : Build.HARDWARE);
        return out;
    }

    // ---------- Install ----------

    /** Extracts an Android JRE (.tar.xz) into {@code dest} and prepares it for in-process use */
    public static void installJre(Context context, File archive, File dest) throws IOException {
        if (dest.exists()) deleteRecursive(dest);
        if (!dest.mkdirs()) throw new IOException("Cannot create " + dest);
        try (InputStream in = new BufferedInputStream(new FileInputStream(archive));
             TarArchiveInputStream tar = new TarArchiveInputStream(new XZCompressorInputStream(in))) {
            TarArchiveEntry entry;
            byte[] buffer = new byte[64 * 1024];
            String root = dest.getCanonicalPath() + File.separator;
            while ((entry = tar.getNextEntry()) != null) {
                File out = new File(dest, entry.getName());
                if (!out.getCanonicalPath().startsWith(root) && !out.getCanonicalPath().equals(dest.getCanonicalPath())) {
                    throw new IOException("Unsafe path in archive: " + entry.getName());
                }
                if (entry.isDirectory()) {
                    out.mkdirs();
                } else if (entry.isSymbolicLink()) {
                    out.getParentFile().mkdirs();
                    try {
                        Os.symlink(entry.getLinkName(), out.getAbsolutePath());
                    } catch (ErrnoException e) {
                        throw new IOException("Cannot create symlink " + entry.getName(), e);
                    }
                } else {
                    out.getParentFile().mkdirs();
                    try (OutputStream os = new FileOutputStream(out)) {
                        int n;
                        while ((n = tar.read(buffer)) != -1) os.write(buffer, 0, n);
                    }
                    if ((entry.getMode() & 0111) != 0) out.setExecutable(true, false);
                }
            }
        }
        // Java 8 builds ship libfreetype.so.6; the loader looks for libfreetype.so
        File lib = jreLibDir(dest);
        File ftIn = new File(lib, "libfreetype.so.6");
        File ftOut = new File(lib, "libfreetype.so");
        if (ftIn.exists() && !ftOut.exists() && !ftIn.renameTo(ftOut)) throw new IOException("Cannot rename libfreetype");
        // AWT without X11, so classes that touch AWT can still load
        copyFile(new File(context.getApplicationInfo().nativeLibraryDir, "libawt_xawt.so"), new File(lib, "libawt_xawt.so"));
        if (!new File(lib, "server/libjvm.so").exists() && !new File(lib, "client/libjvm.so").exists()) {
            throw new IOException("The archive is not an Android JRE (libjvm.so missing)");
        }
    }

    /** {@code lib} or {@code lib/aarch64} depending on the JRE version */
    static File jreLibDir(File jreHome) {
        File arch = new File(jreHome, "lib/aarch64");
        return arch.isDirectory() ? arch : new File(jreHome, "lib");
    }

    /**
     * Copies the bundled LWJGL jars to app storage; returns their folder. 3.4.1 also has its own
     * native libraries in {@code natives/}: they share file names with the 3.3.3 ones in the APK's
     * native library folder, so they cannot go there.
     */
    public static File extractLwjgl(Context context, String lwjgl) throws IOException {
        File dir = new File(context.getFilesDir(), "lwjgl3/" + lwjgl);
        File marker = new File(dir, ".version");
        String version = String.valueOf(appVersionCode(context));
        if (marker.exists() && version.equals(readText(marker))) return dir;
        if (dir.exists()) deleteRecursive(dir);
        dir.mkdirs();
        AssetManager assets = context.getAssets();
        String base = "lwjgl3/" + lwjgl;
        String[] names = assets.list(base);
        if (names == null || names.length == 0) throw new IOException("LWJGL " + lwjgl + " is missing from the APK");
        for (String name : names) {
            String[] sub = assets.list(base + "/" + name);
            if (sub != null && sub.length > 0) {
                // A folder (natives)
                File out = new File(dir, name);
                out.mkdirs();
                for (String s : sub) {
                    try (InputStream in = assets.open(base + "/" + name + "/" + s); OutputStream os = new FileOutputStream(new File(out, s))) {
                        copy(in, os);
                    }
                }
                continue;
            }
            try (InputStream in = assets.open(base + "/" + name); OutputStream out = new FileOutputStream(new File(dir, name))) {
                copy(in, out);
            }
        }
        try (InputStream in = assets.open("resolv.conf"); OutputStream out = new FileOutputStream(new File(context.getFilesDir(), "resolv.conf"))) {
            copy(in, out);
        }
        writeText(marker, version);
        return dir;
    }

    /** Native libraries of an LWJGL version, or null when they are the ones in the APK */
    static File lwjglNatives(Context context, String lwjgl) {
        File dir = new File(context.getFilesDir(), "lwjgl3/" + lwjgl + "/natives");
        return dir.isDirectory() ? dir : null;
    }

    /** Classpath entries that replace the game's own LWJGL libraries */
    public static List<String> lwjglClasspath(Context context, String lwjgl) throws IOException {
        File dir = extractLwjgl(context, lwjgl);
        List<String> out = new ArrayList<>();
        // Core first, then the merged modules (which contain the GLFW stub and SDL overrides), then the rest
        out.add(new File(dir, "lwjgl.jar").getAbsolutePath());
        out.add(new File(dir, "lwjgl-" + lwjgl + "-merged-modules.jar").getAbsolutePath());
        File[] jars = dir.listFiles((d, name) -> name.endsWith(".jar") && !name.equals(LWJGLX_JAR));
        if (jars != null) {
            Arrays.sort(jars);
            for (File f : jars) {
                if (!out.contains(f.getAbsolutePath())) out.add(f.getAbsolutePath());
            }
        }
        return out;
    }

    /** The LWJGL 2 compatibility jar; LWJGL 2 versions put it at the end of the classpath */
    public static String lwjglxJar(Context context) throws IOException {
        return new File(extractLwjgl(context, LWJGL_VERSION), LWJGLX_JAR).getAbsolutePath();
    }

    // ---------- Launch ----------

    /**
     * Starts the JVM on the current thread and blocks until the game exits.
     *
     * @param args JVM arguments, main class and game arguments (without the program name)
     * @param ffp  the game uses the fixed-function pipeline, so SFPEW wraps the renderer
     * @param lwjgl the LWJGL version whose jars are on the classpath
     * @param renderer one of {@link #MOBILEGLUES}, {@link #MOBILEGLUES_ANGLE}, {@link #ZINK}, {@link #SYSTEM_GLES}
     * @param turnip Zink on Adreno: use the bundled Turnip driver instead of the vendor Vulkan driver
     */
    public static int launch(Activity activity, File jreHome, File gameDir, File logFile, List<String> args,
                             int width, int height, boolean ffp, String lwjgl, String renderer,
                             boolean turnip) throws Throwable {
        RendererConfig rc = rendererConfig(renderer);
        // SFPEW only wraps MobileGlues
        ffp = ffp && rc.ffpWrapper;
        String glLib = ffp ? FFP_WRAPPER_LIB : rc.gl;
        Context app = activity.getApplicationContext();
        String nativeDir = app.getApplicationInfo().nativeLibraryDir;
        // LWJGL's own libraries; other libraries (renderer, SDL3, OpenAL) stay in the APK folder
        File natives = lwjglNatives(app, lwjgl);
        String lwjglDir = natives != null ? natives.getAbsolutePath() : nativeDir;
        String home = jreHome.getAbsolutePath();
        File lib = jreLibDir(jreHome);
        File cache = app.getCacheDir();

        logFile.getParentFile().mkdirs();
        // The native side opens the file without O_CREAT
        //noinspection ResultOfMethodCallIgnored
        logFile.createNewFile();
        Logger.begin(logFile.getAbsolutePath());
        CallbackBridge.sContext = app;

        String ldPath = lib.getAbsolutePath() + "/jli:" + lib.getAbsolutePath() + ":"
                + "/system/lib64:/vendor/lib64:/vendor/lib64/hw:"
                + (natives != null ? lwjglDir + ":" : "") + nativeDir;

        Map<String, String> env = new LinkedHashMap<>();
        env.put("POJAV_NATIVEDIR", nativeDir);
        env.put("JAVA_HOME", home);
        env.put("HOME", gameDir.getAbsolutePath());
        env.put("TMPDIR", cache.getAbsolutePath());
        env.put("LIBGL_MIPMAP", "3");
        env.put("LIBGL_NOERROR", "1");
        env.put("LIBGL_NOINTOVLHACK", "1");
        env.put("LIBGL_NORMALIZE", "1");
        env.put("LIBGL_ES", "3");
        env.put("FORCE_VSYNC", "false");
        env.put("MESA_GLSL_CACHE_DIR", cache.getAbsolutePath());
        env.put("LD_LIBRARY_PATH", ldPath);
        env.put("PATH", home + "/bin:" + Os.getenv("PATH"));
        env.put("AMETHYST_RENDERER", rc.amethyst);
        File mgDir = new File(app.getFilesDir(), "MobileGlues");
        env.put("MG_DIR_PATH", mgDir.getAbsolutePath());
        if (rc.egl != null) env.put("POJAVEXEC_EGL", rc.egl);
        if (ffp) env.put("SFPEW_EGL", rc.egl);
        if (ZINK.equals(renderer)) {
            env.put("MESA_GL_VERSION_OVERRIDE", "4.6COMPAT");
            env.put("MESA_GLSL_VERSION_OVERRIDE", "460");
            // Mesa looks for <dir>/libzink_dri.so; without this it uses a path from the build machine
            env.put("LIBGL_DRIVERS_PATH", nativeDir);
            // The native bridge then loads the system Vulkan loader with liblinkerhook, which
            // swaps the vendor driver for libvulkan_freedreno.so (see egl_bridge.c load_turnip_vulkan)
            if (turnip) env.put("POJAV_LOAD_TURNIP", "1");
        }
        // SDL creates the GL context itself (26.x), with the same renderer
        env.put("SDL_OPENGL_LIBRARY", glLib);
        if (rc.egl != null) env.put("SDL_EGL_LIBRARY", nativeDir + "/" + rc.egl);
        env.put("AWTSTUB_WIDTH", String.valueOf(width));
        env.put("AWTSTUB_HEIGHT", String.valueOf(height));
        env.put("DALVIK_APPLICATION", Tools.jObjectToString(activity.getApplication()));
        env.put("DALVIK_JAVAVM", String.valueOf(Tools.getJavaVMPointer()));
        for (Map.Entry<String, String> e : env.entrySet()) {
            Os.setenv(e.getKey(), e.getValue(), true);
        }
        if (rc.egl == null) Os.unsetenv("POJAVEXEC_EGL");
        mgDir.mkdirs();
        if (rc.egl != null && rc.egl.equals(RENDERER_LIB)) writeMobileGluesConfig(mgDir, MOBILEGLUES_ANGLE.equals(renderer));

        File server = new File(lib, "server/libjvm.so");
        String jvmDir = new File(lib, server.exists() ? "server" : "client").getAbsolutePath();
        JREUtils.setLdLibraryPath(jvmDir + ":" + ldPath);

        // MobileGlues reads its config when loaded, so the config is written first
        if (RENDERER_LIB.equals(rc.gl) && !JREUtils.dlopen(RENDERER_LIB) && !JREUtils.dlopen(nativeDir + "/" + RENDERER_LIB)) {
            throw new IOException("Cannot load the renderer " + RENDERER_LIB);
        }
        Logger.appendToLog("PCL.PW runtime: renderer " + renderer + (ffp ? " + SFPEW" : "")
                + (turnip && ZINK.equals(renderer) ? " + Turnip" : ""));

        List<String> argv = new ArrayList<>();
        argv.add("java");
        argv.addAll(Arrays.asList(
                "-Djava.home=" + home,
                "-Djava.io.tmpdir=" + cache.getAbsolutePath(),
                "-Djna.boot.library.path=" + nativeDir,
                "-Duser.home=" + gameDir.getAbsolutePath(),
                "-Duser.language=" + System.getProperty("user.language"),
                "-Duser.timezone=" + TimeZone.getDefault().getID(),
                "-Dos.name=Linux",
                "-Dos.version=Android-" + Build.VERSION.RELEASE,
                "-Dorg.lwjgl.vulkan.libname=libvulkan.so",
                "-Dglfwstub.windowWidth=" + width,
                "-Dglfwstub.windowHeight=" + height,
                "-Dglfwstub.initEgl=false",
                "-Dext.net.resolvPath=" + new File(app.getFilesDir(), "resolv.conf").getAbsolutePath(),
                "-Dlog4j2.formatMsgNoLookups=true",
                "-Dfml.earlyprogresswindow=false",
                "-Dloader.disable_forked_guis=true",
                "-Djdk.lang.Process.launchMechanism=FORK",
                // LWJGL loads the GL library by this name; SFPEW then loads the renderer itself
                "-Dorg.lwjgl.opengl.libname=" + glLib,
                "-Dfml.ignoreInvalidMinecraftCertificates=true",
                "-Dorg.lwjgl.freetype.libname=" + lwjglDir + "/libfreetype.so",
                "-Dorg.lwjgl.system.allocator=system",
                // Our spirv-cross build is the shared C API library (26.x loads it at startup)
                "-Dorg.lwjgl.spvc.libname=spirv-cross-c-shared",
                // SDL3 through a shim that lets Minecraft's several windows share Android's one window
                "-Dorg.lwjgl.sdl.libname=" + nativeDir + "/libpclpw_sdlshim.so",
                "-Dorg.lwjgl.librarypath=" + lwjglDir,
                "-XX:ActiveProcessorCount=" + java.lang.Runtime.getRuntime().availableProcessors()
        ));
        // 26.x: rename shader uniform blocks that MobileGlues would mangle (see agent/ShaderNamesAgent)
        File agent = new File(app.getFilesDir(), "lwjgl3/" + lwjgl + "/agent/pclpw-agent.jar");
        if (agent.isFile()) argv.add("-javaagent:" + agent.getAbsolutePath());
        argv.addAll(withWindowSize(args, width, height));
        Logger.appendToLog("PCL.PW runtime: " + String.join(" ", redact(argv)));

        loadJavaLibraries(jreHome, jvmDir, nativeDir);
        JREUtils.setupExitMethod(app);
        sLogFile = logFile;
        JREUtils.chdir(gameDir.getAbsolutePath());
        // Registered last so it runs before the exit handlers of the JVM libraries
        JREUtils.initializeHooks();
        int code = VMLauncher.launchJVM(argv.toArray(new String[0]));
        Logger.appendToLog("Java exit code: " + code);
        return code;
    }

    /**
     * Runs a jar or main class without a window or renderer: loader installers, the OptiFine
     * patcher, or a jar the user picked. Called on a worker thread in the {@code :jar} process
     * ({@link JarService}); the JVM cannot be started twice, so the process exits afterwards.
     *
     * @param args JVM options followed by {@code -jar <file> ...} or {@code -cp <path> <class> ...}
     */
    public static int runJar(Context context, File jreHome, File workDir, File logFile, List<String> args)
            throws Throwable {
        sJarMode = true;
        // The game process loads it while setting up its window; this process has none.
        // Loading it initialises CallbackBridge, which needs a Looper on the calling thread
        if (android.os.Looper.myLooper() == null) android.os.Looper.prepare();
        System.loadLibrary("pojavexec");
        Context app = context.getApplicationContext();
        String nativeDir = app.getApplicationInfo().nativeLibraryDir;
        String home = jreHome.getAbsolutePath();
        File lib = jreLibDir(jreHome);
        File cache = app.getCacheDir();

        logFile.getParentFile().mkdirs();
        //noinspection ResultOfMethodCallIgnored
        logFile.createNewFile();
        Logger.begin(logFile.getAbsolutePath());

        String ldPath = lib.getAbsolutePath() + "/jli:" + lib.getAbsolutePath() + ":"
                + "/system/lib64:/vendor/lib64:" + nativeDir;
        Map<String, String> env = new LinkedHashMap<>();
        env.put("POJAV_NATIVEDIR", nativeDir);
        env.put("JAVA_HOME", home);
        env.put("HOME", workDir.getAbsolutePath());
        env.put("TMPDIR", cache.getAbsolutePath());
        env.put("LD_LIBRARY_PATH", ldPath);
        env.put("PATH", home + "/bin:" + Os.getenv("PATH"));
        for (Map.Entry<String, String> e : env.entrySet()) {
            Os.setenv(e.getKey(), e.getValue(), true);
        }
        File server = new File(lib, "server/libjvm.so");
        String jvmDir = new File(lib, server.exists() ? "server" : "client").getAbsolutePath();
        JREUtils.setLdLibraryPath(jvmDir + ":" + ldPath);

        List<String> argv = new ArrayList<>();
        argv.add("java");
        argv.addAll(Arrays.asList(
                "-Djava.home=" + home,
                "-Djava.io.tmpdir=" + cache.getAbsolutePath(),
                "-Duser.home=" + workDir.getAbsolutePath(),
                "-Duser.dir=" + workDir.getAbsolutePath(),
                "-Duser.language=" + System.getProperty("user.language"),
                "-Duser.timezone=" + TimeZone.getDefault().getID(),
                "-Dos.name=Linux",
                "-Dos.version=Android-" + Build.VERSION.RELEASE,
                "-Djava.awt.headless=true",
                "-Dext.net.resolvPath=" + new File(app.getFilesDir(), "resolv.conf").getAbsolutePath(),
                "-Djdk.lang.Process.launchMechanism=FORK",
                "-XX:ActiveProcessorCount=" + java.lang.Runtime.getRuntime().availableProcessors()
        ));
        argv.addAll(args);
        Logger.appendToLog("PCL.PW runtime: " + String.join(" ", argv));

        loadJavaLibraries(jreHome, jvmDir, nativeDir);
        JREUtils.setupExitMethod(app);
        JREUtils.chdir(workDir.getAbsolutePath());
        JREUtils.initializeHooks();
        int code = VMLauncher.launchJVM(argv.toArray(new String[0]));
        Logger.appendToLog("Java exit code: " + code);
        return code;
    }

    /** Set in the {@code :jar} process: exits are recorded in {@link #jarExitFile} */
    private static boolean sJarMode;

    /** Exit code of the last {@link #runJar}; only abnormal exits are known (see stdio_is.c) */
    public static File jarExitFile(Context context) {
        return new File(context.getFilesDir(), "jar_exit.txt");
    }

    /**
     * MobileGlues settings (MG_DIR_PATH/config.json). Every key is written, because a missing key
     * reads as -1. ANGLE: 3 forces it on, 2 forces it off.
     */
    private static void writeMobileGluesConfig(File dir, boolean angle) throws IOException {
        String json = "{\n"
                + "  \"enableANGLE\": " + (angle ? 3 : 2) + ",\n"
                + "  \"enableNoError\": 0,\n"
                + "  \"enableExtComputeShader\": 0,\n"
                + "  \"enableExtTimerQuery\": 0,\n"
                + "  \"enableExtDirectStateAccess\": 0,\n"
                + "  \"angleDepthClearFixMode\": 0,\n"
                + "  \"customGLVersion\": 40,\n"
                + "  \"fsr1Setting\": 0,\n"
                + "  \"hideMGEnvLevel\": 0,\n"
                + "  \"maxGlslCacheSize\": 0\n"
                + "}\n";
        writeText(new File(dir, "config.json"), json);
    }

    private static void loadJavaLibraries(File jreHome, String jvmDir, String nativeDir) {
        File lib = jreLibDir(jreHome);
        JREUtils.dlopen(new File(lib, "jli/libjli.so").exists() ? new File(lib, "jli/libjli.so").getAbsolutePath() : new File(lib, "libjli.so").getAbsolutePath());
        if (!JREUtils.dlopen("libjvm.so")) JREUtils.dlopen(jvmDir + "/libjvm.so");
        for (String name : new String[]{"libverify.so", "libjava.so", "libnet.so", "libnio.so", "libawt.so",
                "libawt_headless.so", "libfreetype.so", "libfontmanager.so"}) {
            File f = new File(lib, name);
            if (f.exists()) JREUtils.dlopen(f.getAbsolutePath());
        }
        for (File f : listLibs(lib)) JREUtils.dlopen(f.getAbsolutePath());
        JREUtils.dlopen(nativeDir + "/libopenal.so");
    }

    private static List<File> listLibs(File dir) {
        List<File> out = new ArrayList<>();
        File[] list = dir.listFiles();
        if (list == null) return out;
        for (File f : list) {
            if (f.isFile() && f.getName().endsWith(".so")) out.add(f);
            else if (f.isDirectory()) out.addAll(listLibs(f));
        }
        return out;
    }

    /**
     * Sets the game's --width/--height to the surface size. SDL on Android always makes the window
     * the size of the surface without sending a resize event, and 26.x keeps the requested size
     * for mapping the mouse, so with the launcher's 854x480 every tap would land in the wrong place.
     */
    private static List<String> withWindowSize(List<String> args, int width, int height) {
        List<String> out = new ArrayList<>(args);
        boolean w = false, h = false;
        for (int i = 0; i + 1 < out.size(); i++) {
            if (out.get(i).equals("--width")) {
                out.set(i + 1, String.valueOf(width));
                w = true;
            } else if (out.get(i).equals("--height")) {
                out.set(i + 1, String.valueOf(height));
                h = true;
            }
        }
        if (!w) out.addAll(Arrays.asList("--width", String.valueOf(width)));
        if (!h) out.addAll(Arrays.asList("--height", String.valueOf(height)));
        return out;
    }

    /** Hides the access token in the logged command line */
    private static List<String> redact(List<String> argv) {
        List<String> out = new ArrayList<>(argv);
        for (int i = 0; i + 1 < out.size(); i++) {
            if (out.get(i).equals("--accessToken")) out.set(i + 1, "******");
        }
        return out;
    }

    // ---------- Exit ----------

    /** Written when the game exits abnormally; the launcher reads it after returning */
    public static File exitFile(Context context) {
        return new File(context.getFilesDir(), "game_exit.txt");
    }

    private static File sLogFile;

    public static void recordExit(Context context, int code, boolean isSignal) {
        if (sJarMode) {
            try {
                writeText(jarExitFile(context), code + (isSignal ? " signal" : ""));
            } catch (IOException e) {
                Log.e(TAG, "Cannot record exit code", e);
            }
            return;
        }
        // The JVM can abort while tearing down after a normal quit ("Stopping!" is Minecraft's
        // last line on a normal shutdown); that is not a crash
        if (isSignal && stoppedNormally()) return;
        try {
            writeText(exitFile(context), code + (isSignal ? " signal" : ""));
        } catch (IOException e) {
            Log.e(TAG, "Cannot record exit code", e);
        }
    }

    private static boolean stoppedNormally() {
        File f = sLogFile;
        if (f == null || !f.exists()) return false;
        try (java.io.RandomAccessFile raf = new java.io.RandomAccessFile(f, "r")) {
            long len = raf.length();
            int n = (int) Math.min(len, 16 * 1024);
            byte[] tail = new byte[n];
            raf.seek(len - n);
            raf.readFully(tail);
            String text = new String(tail, StandardCharsets.UTF_8);
            return text.contains("Stopping!") && !text.contains("Game crashed!");
        } catch (IOException e) {
            return false;
        }
    }

    // ---------- Files ----------

    private static long appVersionCode(Context context) {
        try {
            // Changes with every install or update, so new jars are always extracted
            return context.getPackageManager().getPackageInfo(context.getPackageName(), 0).lastUpdateTime;
        } catch (Exception e) {
            return 0;
        }
    }

    static void copy(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[64 * 1024];
        int n;
        while ((n = in.read(buffer)) != -1) out.write(buffer, 0, n);
    }

    private static void copyFile(File from, File to) throws IOException {
        try (InputStream in = new FileInputStream(from); OutputStream out = new FileOutputStream(to)) {
            copy(in, out);
        }
    }

    private static String readText(File f) throws IOException {
        try (InputStream in = new FileInputStream(f)) {
            byte[] data = new byte[(int) f.length()];
            int read = 0;
            while (read < data.length) {
                int n = in.read(data, read, data.length - read);
                if (n < 0) break;
                read += n;
            }
            return new String(data, 0, read, StandardCharsets.UTF_8).trim();
        }
    }

    private static void writeText(File f, String text) throws IOException {
        try (OutputStream out = new FileOutputStream(f)) {
            out.write(text.getBytes(StandardCharsets.UTF_8));
        }
    }

    static void deleteRecursive(File f) {
        File[] children = f.isDirectory() && !isSymlink(f) ? f.listFiles() : null;
        if (children != null) for (File c : children) deleteRecursive(c);
        //noinspection ResultOfMethodCallIgnored
        f.delete();
    }

    private static boolean isSymlink(File f) {
        try {
            return !f.getCanonicalFile().equals(f.getAbsoluteFile());
        } catch (IOException e) {
            return false;
        }
    }
}
