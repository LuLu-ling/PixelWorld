package io.github.zhuzhi09.pclpw.agent;

import java.io.File;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/**
 * Reports the game JVM's heap to the in-game HUD.
 *
 * <p>The HUD runs in the Android runtime, so {@code Runtime.getRuntime()} there describes the
 * Android heap, not the embedded game JVM. This agent is loaded into the game JVM by the launcher
 * and writes a few numbers to a file once a second; the HUD reads them.
 */
public final class HudStatsAgent {

    private HudStatsAgent() {
    }

    public static void premain(String args, java.lang.instrument.Instrumentation inst) {
        final String path = System.getProperty("pclpw.hud.stats");
        if (path == null || path.isEmpty()) return;
        Thread thread = new Thread(() -> {
            while (true) {
                try {
                    Runtime rt = Runtime.getRuntime();
                    long total = rt.totalMemory();
                    long used = total - rt.freeMemory();
                    long max = rt.maxMemory();
                    write(path, used, total, max);
                } catch (Throwable ignored) {
                }
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    return;
                }
            }
        }, "PCLPW-HudStats");
        thread.setDaemon(true);
        thread.start();
    }

    private static void write(String path, long used, long total, long max) {
        File target = new File(path);
        File tmp = new File(path + ".tmp");
        try (FileWriter w = new FileWriter(tmp, false)) {
            w.write("used=" + used + "\n");
            w.write("total=" + total + "\n");
            w.write("max=" + max + "\n");
        } catch (Throwable e) {
            return;
        }
        try {
            Files.move(tmp.toPath(), target.toPath(),
                    StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
        } catch (Throwable e) {
            try {
                Files.move(tmp.toPath(), target.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (Throwable ignored) {
            }
        }
    }
}
