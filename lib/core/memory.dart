import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import 'config.dart';
import 'instance_config.dart';

/// PCL-CE 内存滑块刻度 -> GB（PageSetupLaunch.GetRamFromTick）
double ramFromTick(int tick) {
  if (tick <= 12) return tick * 0.1 + 0.3;
  if (tick <= 25) return (tick - 12) * 0.5 + 1.5;
  if (tick <= 33) return (tick - 25) + 8.0;
  return (tick - 33) * 2 + 16.0;
}

/// 不超过 maxGb 的最大刻度，用于限制滑块范围
int maxTickFor(double maxGb) {
  var t = 1;
  while (ramFromTick(t + 1) <= maxGb) {
    t++;
  }
  return t;
}

const _gb = 1024 * 1024 * 1024;

/// 系统总内存与空闲内存，GB
({double total, double free}) systemMemory() {
  if (Platform.isWindows) {
    final s = calloc<MEMORYSTATUSEX>();
    try {
      s.ref.dwLength = sizeOf<MEMORYSTATUSEX>();
      GlobalMemoryStatusEx(s);
      return (total: s.ref.ullTotalPhys / _gb, free: s.ref.ullAvailPhys / _gb);
    } finally {
      calloc.free(s);
    }
  }
  if (Platform.isLinux) {
    final info = <String, int>{};
    for (final line in File('/proc/meminfo').readAsLinesSync()) {
      final m = RegExp(r'^(\w+):\s+(\d+)').firstMatch(line);
      if (m != null) info[m.group(1)!] = int.parse(m.group(2)!);
    }
    return (total: (info['MemTotal'] ?? 0) / 1024 / 1024, free: (info['MemAvailable'] ?? 0) / 1024 / 1024);
  }
  // macOS：总内存来自 sysctl，空闲内存按 vm_stat 的空闲与非活动页估算
  final total = int.tryParse('${Process.runSync('sysctl', ['-n', 'hw.memsize']).stdout}'.trim()) ?? 0;
  final vm = '${Process.runSync('vm_stat', []).stdout}';
  final pageSize = int.tryParse(RegExp(r'page size of (\d+)').firstMatch(vm)?.group(1) ?? '') ?? 4096;
  int pages(String name) => int.tryParse(RegExp('$name:\\s+(\\d+)').firstMatch(vm)?.group(1) ?? '') ?? 0;
  final free = (pages('Pages free') + pages('Pages inactive')) * pageSize;
  return (total: total / _gb, free: free / _gb);
}

int _countMods(String gameDir) {
  try {
    return Directory(p.join(gameDir, 'mods')).listSync().whereType<File>().length;
  } catch (_) {
    return 0;
  }
}

/// 自动分配内存，返回 GB。
/// 先按版本类型估算需求（原版 2G、OptiFine 3G、Mod 版本 3G + 每个 Mod 30M，最多 12G），
/// 再限制在系统可承受范围内：给系统保留总内存的 20%（至少 1.5G），且不超过当前空闲内存的 90%。
double autoRam({required bool modable, required bool optifine, required String gameDir}) {
  final mem = systemMemory();
  final need = modable ? min(12.0, 3 + _countMods(gameDir) * 0.03) : (optifine ? 3.0 : 2.0);
  final cap = min(mem.total - max(1.5, mem.total * 0.2), mem.free * 0.9);
  final give = max(1.0, min(need, cap));
  // 取 0.5G 的整数倍，更符合常见设置习惯
  return max(1.0, (give * 2).floor() / 2);
}

/// -Xmx 与 -Xms，GB；initial 为 null 表示不设置 -Xms
typedef MemoryPlan = ({double max, double? initial});

/// 合并全局与实例设置（含 PCL-CE 实例配置中的内存选项），得到最终内存
MemoryPlan planMemory(
  LauncherConfig cfg,
  InstanceSettings inst, {
  required bool modable,
  required bool optifine,
  required String gameDir,
  bool is64BitJava = true,
}) {
  final useGlobal = inst.memoryMode == 'global';
  final mode = useGlobal ? cfg.memoryMode : inst.memoryMode;
  var maxGb = mode == 'auto'
      ? autoRam(modable: modable, optifine: optifine, gameDir: gameDir)
      : ramFromTick(useGlobal ? cfg.memoryTick : inst.memoryTick);
  // 32 位 Java 最多 1G
  if (!is64BitJava) maxGb = min(1, maxGb);

  double? initial;
  // 自定义 JVM 参数里已有 -Xms 时以它为准
  final jvm = inst.jvmArgs.isNotEmpty ? inst.jvmArgs : cfg.jvmArgs;
  if (RegExp('-Xms', caseSensitive: false).hasMatch(jvm)) {
    initial = null;
  } else if (cfg.lockMemory) {
    initial = maxGb;
  } else if (mode == 'custom') {
    final tick = useGlobal ? cfg.memoryInitialTick : inst.memoryInitialTick;
    if (tick > 0) initial = min(ramFromTick(tick), maxGb);
  }
  return (max: maxGb, initial: initial);
}
