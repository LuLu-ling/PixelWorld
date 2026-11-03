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
    public static final String LWJGL_VERSION = "3.3.3";
    public static final String RENDERER = "opengles_mobileglues";
    public static final String RENDERER_LIB = "libmobileglues.so";

    private GameRuntime() {}

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

    /** Copies the bundled LWJGL jars to app storage; returns their folder */
    public static File extractLwjgl(Context context) throws IOException {
        File dir = new File(context.getFilesDir(), "lwjgl3/" + LWJGL_VERSION);
        File marker = new File(dir, ".version");
        String version = String.valueOf(appVersionCode(context));
        if (marker.exists() && version.equals(readText(marker))) return dir;
        if (dir.exists()) deleteRecursive(dir);
        dir.mkdirs();
        AssetManager assets = context.getAssets();
        String base = "lwjgl3/" + LWJGL_VERSION;
        String[] names = assets.list(base);
        if (names == null || names.length == 0) throw new IOException("LWJGL jars are missing from the APK");
        for (String name : names) {
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

    /** Classpath entries that replace the game's own LWJGL libraries */
    public static List<String> lwjglClasspath(Context context) throws IOException {
        File dir = extractLwjgl(context);
        List<String> out = new ArrayList<>();
        // Core first, then the merged modules (which contain the GLFW stub), then the rest
        out.add(new File(dir, "lwjgl.jar").getAbsolutePath());
        out.add(new File(dir, "lwjgl-" + LWJGL_VERSION + "-merged-modules.jar").getAbsolutePath());
        File[] jars = dir.listFiles((d, name) -> name.endsWith(".jar"));
        if (jars != null) {
            Arrays.sort(jars);
            for (File f : jars) {
                if (!out.contains(f.getAbsolutePath())) out.add(f.getAbsolutePath());
            }
        }
        return out;
    }

    // ---------- Launch ----------

    /**
     * Starts the JVM on the current thread and blocks until the game exits.
     *
     * @param args JVM arguments, main class and game arguments (without the program name)
     */
    public static int launch(Activity activity, File jreHome, File gameDir, File logFile, List<String> args,
                             int width, int height) throws Throwable {
        Context app = activity.getApplicationContext();
        String nativeDir = app.getApplicationInfo().nativeLibraryDir;
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
                + "/system/lib64:/vendor/lib64:/vendor/lib64/hw:" + nativeDir;

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
        env.put("AMETHYST_RENDERER", RENDERER);
        env.put("MG_DIR_PATH", new File(app.getFilesDir(), "MobileGlues").getAbsolutePath());
        env.put("POJAVEXEC_EGL", RENDERER_LIB);
        env.put("AWTSTUB_WIDTH", String.valueOf(width));
        env.put("AWTSTUB_HEIGHT", String.valueOf(height));
        env.put("DALVIK_APPLICATION", Tools.jObjectToString(activity.getApplication()));
        env.put("DALVIK_JAVAVM", String.valueOf(Tools.getJavaVMPointer()));
        for (Map.Entry<String, String> e : env.entrySet()) {
            Os.setenv(e.getKey(), e.getValue(), true);
        }
        new File(app.getFilesDir(), "MobileGlues").mkdirs();

        File server = new File(lib, "server/libjvm.so");
        String jvmDir = new File(lib, server.exists() ? "server" : "client").getAbsolutePath();
        JREUtils.setLdLibraryPath(jvmDir + ":" + ldPath);

        if (!JREUtils.dlopen(RENDERER_LIB) && !JREUtils.dlopen(nativeDir + "/" + RENDERER_LIB)) {
            throw new IOException("Cannot load the renderer " + RENDERER_LIB);
        }

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
                "-Dorg.lwjgl.opengl.libname=" + RENDERER_LIB,
                "-Dorg.lwjgl.freetype.libname=" + nativeDir + "/libfreetype.so",
                "-Dorg.lwjgl.system.allocator=system",
                "-Dorg.lwjgl.librarypath=" + nativeDir,
                "-XX:ActiveProcessorCount=" + java.lang.Runtime.getRuntime().availableProcessors()
        ));
        argv.addAll(args);
        Logger.appendToLog("PCL.PW runtime: " + String.join(" ", redact(argv)));

        loadJavaLibraries(jreHome, jvmDir, nativeDir);
        JREUtils.setupExitMethod(app);
        JREUtils.chdir(gameDir.getAbsolutePath());
        int code = VMLauncher.launchJVM(argv.toArray(new String[0]));
        Logger.appendToLog("Java exit code: " + code);
        return code;
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

    public static void recordExit(Context context, int code, boolean isSignal) {
        try {
            writeText(exitFile(context), code + (isSignal ? " signal" : ""));
        } catch (IOException e) {
            Log.e(TAG, "Cannot record exit code", e);
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
