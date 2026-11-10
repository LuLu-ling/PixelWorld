package io.github.zhuzhi09.pclpw.runtime;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
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
 * Samples the values shown by the in-game HUD once a second. The Java heap comes from the game
 * process itself; system memory and swap come from ActivityManager / /proc/meminfo.
 */
final class HudMetrics {

    /** One reading of the values shown in the HUD. */
    static final class Sample {
        double fps;
        boolean fpsAvailable;
        long heapUsed;
        long heapMax;
        long systemUsed;
        long systemTotal;
        long swapUsed;
        long swapTotal;
        double cpuPercent;
        /** GPU busy share in percent; negative when the device does not expose it to apps */
        double gpuPercent = -1;
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
    private final int cores;
    private final File javaStatsFile;
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
    /** Index into GPU_FILES that worked; -1 = not probed yet, -2 = none readable */
    private int gpuSource = -1;

    /**
     * GPU load files. Adreno's gpubusy ("busy total" of the last sample window) is readable by
     * every app domain on recent Qualcomm builds, unlike gpu_busy_percentage; the others are
     * "NN %" files on Mali / Exynos / MediaTek kernels.
     */
    private static final String[] GPU_FILES = {
            "/sys/class/kgsl/kgsl-3d0/gpubusy",
            "/sys/class/kgsl/kgsl-3d0/gpu_busy_percentage",
            "/sys/kernel/gpu/gpu_busy",
            "/sys/class/misc/mali0/device/utilization",
    };

    HudMetrics(Activity activity) {
        this.activity = activity;
        long hz = 100;
        try {
            hz = Os.sysconf(OsConstants._SC_CLK_TCK);
        } catch (Throwable ignored) {
        }
        clkTck = hz > 0 ? hz : 100;
        cores = Math.max(1, Runtime.getRuntime().availableProcessors());
        javaStatsFile = new File(activity.getFilesDir(), "hud-java-stats");
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

        readJavaHeap(s);

        try {
            readSystemMemory(s);
        } catch (Throwable ignored) {
        }

        s.cpuPercent = readCpu(now, previous);
        s.gpuPercent = readGpu();
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

    /** GPU busy percent from the first readable file in GPU_FILES; -1 when there is none. */
    private double readGpu() {
        if (gpuSource == -2) return -1;
        int from = gpuSource >= 0 ? gpuSource : 0;
        int to = gpuSource >= 0 ? gpuSource + 1 : GPU_FILES.length;
        for (int i = from; i < to; i++) {
            double v = parseGpu(GPU_FILES[i]);
            if (v >= 0) {
                gpuSource = i;
                return v;
            }
        }
        // Probing failed (or the chosen file stopped working): give up instead of retrying every second
        gpuSource = -2;
        return -1;
    }

    private static double parseGpu(String path) {
        try (BufferedReader r = new BufferedReader(new FileReader(path))) {
            String line = r.readLine();
            if (line == null) return -1;
            String[] parts = line.trim().replace("%", " ").trim().split("\\s+");
            if (parts.length >= 2 && path.endsWith("gpubusy")) {
                long busy = Long.parseLong(parts[0]);
                long total = Long.parseLong(parts[1]);
                // An idle GPU reports 0 0
                return total > 0 ? Math.max(0, Math.min(100, busy * 100.0 / total)) : 0;
            }
            return Math.max(0, Math.min(100, Double.parseDouble(parts[0])));
        } catch (Throwable e) {
            return -1;
        }
    }

    /** Heap values written by {@code hud-agent.jar} inside the game JVM. */
    private void readJavaHeap(Sample s) {
        long used = 0;
        long max = 0;
        try (BufferedReader r = new BufferedReader(new FileReader(javaStatsFile))) {
            String line;
            while ((line = r.readLine()) != null) {
                int eq = line.indexOf('=');
                if (eq <= 0) continue;
                try {
                    long value = Long.parseLong(line.substring(eq + 1).trim());
                    switch (line.substring(0, eq)) {
                        case "used":
                            used = value;
                            break;
                        case "max":
                            max = value;
                            break;
                        default:
                            break;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        } catch (Throwable ignored) {
        }
        if (max > 0) {
            s.heapUsed = used;
            s.heapMax = max;
        }
    }

    /**
     * System RAM and swap. ActivityManager gives the same "available" figure as the system
     * settings; /proc/meminfo also provides swap on Android.
     */
    private void readSystemMemory(Sample s) {
        long total = 0;
        long available = 0;
        long swapTotal = 0;
        long swapFree = 0;
        try (BufferedReader r = new BufferedReader(new FileReader("/proc/meminfo"))) {
            String line;
            while ((line = r.readLine()) != null) {
                if (line.startsWith("MemTotal:")) total = parseKb(line);
                else if (line.startsWith("MemAvailable:")) available = parseKb(line);
                else if (line.startsWith("SwapTotal:")) swapTotal = parseKb(line);
                else if (line.startsWith("SwapFree:")) swapFree = parseKb(line);
            }
        } catch (Throwable ignored) {
        }

        if (total <= 0 || available <= 0) {
            ActivityManager am = (ActivityManager) activity.getSystemService(Activity.ACTIVITY_SERVICE);
            if (am != null) {
                ActivityManager.MemoryInfo info = new ActivityManager.MemoryInfo();
                am.getMemoryInfo(info);
                total = info.totalMem;
                available = info.availMem;
            }
        }

        if (total > 0) {
            s.systemTotal = total;
            s.systemUsed = Math.max(0, total - available);
        }
        s.swapTotal = swapTotal;
        s.swapUsed = Math.max(0, swapTotal - swapFree);
    }

    private static long parseKb(String line) {
        int colon = line.indexOf(':');
        if (colon < 0) return 0;
        String[] parts = line.substring(colon + 1).trim().split("\\s+");
        if (parts.length == 0 || parts[0].isEmpty()) return 0;
        try {
            return Long.parseLong(parts[0]) * 1024;
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    /** CPU usage of the whole game process, in percent of one core. */
    private double readCpu(long now, long previous) {        long[] cpu = readProcStat();
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
        double percent = usedTicks * 100.0 * 1000.0 / clkTck / elapsed / cores;
        return Math.max(0, Math.min(100, percent));
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
