package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Debug;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.system.Os;
import android.system.OsConstants;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.Locale;

/**
 * Samples the values shown by the in-game HUD once a second. Everything here is read from the
 * game process itself: the HUD runs in the same process as the JVM, so the heap and PSS values
 * belong to the game rather than to the launcher.
 */
final class HudMetrics {

    /** One reading of the values shown in the HUD. */
    static final class Sample {
        double fps;
        boolean fpsAvailable;
        long heapUsed;
        long heapMax;
        long pss;
        double cpuPercent;
        float temperature;
        boolean batteryTemperature;
        int batteryPercent;
        long uptimeMs;
    }

    interface Callback {
        void onSample(Sample sample);
    }

    private static final long INTERVAL_MS = 1000;

    private final Activity activity;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable tick = this::sample;
    private final long clkTck;
    private final long startedAt = SystemClock.elapsedRealtime();

    private Callback callback;
    private boolean running;
    private boolean fpsAvailable;
    private long frames;
    private long lastFrames;
    private long lastSampleAt;
    private long lastCpuTicks = -1;
    private String thermalPath;
    private boolean thermalPathResolved;

    HudMetrics(Activity activity) {
        this.activity = activity;
        long hz = 100;
        try {
            hz = Os.sysconf(OsConstants._SC_CLK_TCK);
        } catch (Throwable ignored) {
        }
        clkTck = hz > 0 ? hz : 100;
    }

    /** True when frames can be counted (the Zink renderer draws through a TextureView). */
    void setFpsAvailable(boolean available) {
        fpsAvailable = available;
    }

    /** Called for every frame the renderer hands to the screen. */
    void frame() {
        frames++;
    }

    void start(Callback callback) {
        this.callback = callback;
        if (running) return;
        running = true;
        lastSampleAt = 0;
        lastFrames = frames;
        lastCpuTicks = -1;
        handler.post(tick);
    }

    void stop() {
        running = false;
        handler.removeCallbacks(tick);
    }

    private void sample() {
        if (!running) return;
        long now = SystemClock.elapsedRealtime();
        long previous = lastSampleAt;
        Sample s = new Sample();

        if (previous > 0 && fpsAvailable) {
            long elapsed = now - previous;
            long counted = frames - lastFrames;
            if (elapsed > 0) s.fps = counted * 1000.0 / elapsed;
        }
        s.fpsAvailable = fpsAvailable;
        lastFrames = frames;
        lastSampleAt = now;

        Runtime rt = Runtime.getRuntime();
        s.heapUsed = rt.totalMemory() - rt.freeMemory();
        s.heapMax = rt.maxMemory();

        try {
            Debug.MemoryInfo info = new Debug.MemoryInfo();
            Debug.getMemoryInfo(info);
            s.pss = (long) info.getTotalPss() * 1024;
        } catch (Throwable ignored) {
        }

        s.cpuPercent = readCpu(now, previous);
        try {
            readTemperature(s);
        } catch (Throwable ignored) {
        }
        try {
            readBattery(s);
        } catch (Throwable ignored) {
        }
        s.uptimeMs = now - startedAt;

        if (callback != null) callback.onSample(s);
        if (running) handler.postDelayed(tick, INTERVAL_MS);
    }

    /** CPU usage of the whole game process, in percent of one core. */
    private double readCpu(long now, long previous) {
        long[] cpu = readProcStat();
        if (cpu == null) return 0;
        long ticks = cpu[0] + cpu[1];
        if (lastCpuTicks < 0 || previous == 0) {
            lastCpuTicks = ticks;
            return 0;
        }
        long elapsed = now - previous;
        if (elapsed <= 0) return 0;
        double usedTicks = ticks - lastCpuTicks;
        lastCpuTicks = ticks;
        return Math.max(0, usedTicks * 100.0 * 1000.0 / clkTck / elapsed);
    }

    private static long[] readProcStat() {
        try (BufferedReader r = new BufferedReader(new FileReader("/proc/self/stat"))) {
            String line = r.readLine();
            if (line == null) return null;
            int end = line.lastIndexOf(')');
            if (end < 0) return null;
            String[] f = line.substring(end + 2).trim().split("\\s+");
            // f[0] is field 3 (state); utime and stime are fields 14 and 15
            return new long[]{Long.parseLong(f[11]), Long.parseLong(f[12])};
        } catch (Throwable ignored) {
            return null;
        }
    }

    private void readTemperature(Sample s) {
        if (!thermalPathResolved) {
            thermalPath = findThermalPath();
            thermalPathResolved = true;
        }
        if (thermalPath != null) {
            try (BufferedReader r = new BufferedReader(new FileReader(thermalPath))) {
                float t = Float.parseFloat(r.readLine().trim());
                if (t > 1000) t /= 1000f; // millidegrees
                if (t > 0 && t < 150) {
                    s.temperature = t;
                    return;
                }
            } catch (Throwable ignored) {
            }
        }
        // Fall back to the battery sensor; it still gives a useful idea of the device temperature.
        Intent battery = activity.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        if (battery != null) {
            s.temperature = battery.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) / 10f;
            s.batteryTemperature = true;
        }
    }

    private static String findThermalPath() {
        File dir = new File("/sys/class/thermal");
        File[] zones = dir.listFiles((d, name) -> name.startsWith("thermal_zone"));
        if (zones == null) return null;
        for (File zone : zones) {
            String type = readText(new File(zone, "type")).toLowerCase(Locale.ROOT);
            if (type.isEmpty()) continue;
            if (type.contains("cpu") || type.contains("soc") || type.contains("ap")
                    || type.contains("gpu") || type.contains("core")) {
                File temp = new File(zone, "temp");
                if (temp.canRead()) return temp.getAbsolutePath();
            }
        }
        return null;
    }

    private static String readText(File file) {
        try (BufferedReader r = new BufferedReader(new FileReader(file))) {
            String line = r.readLine();
            return line == null ? "" : line.trim();
        } catch (Throwable ignored) {
            return "";
        }
    }

    private void readBattery(Sample s) {
        Intent battery = activity.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        if (battery == null) return;
        int level = battery.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = battery.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        if (level >= 0 && scale > 0) s.batteryPercent = Math.round(level * 100f / scale);
    }
}
