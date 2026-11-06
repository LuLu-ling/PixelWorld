import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import 'config.dart';
import 'instance_config.dart';

/// 旧版启动器的内存滑块刻度 -> GB；保留这个映射是为了兼容导入的旧配置。
/// 用分段表表示，避免直接复刻原来的判断表达式。
const _ramSteps = <({int from, int to, double start, double step})>[
  (from: 1, to: 12, start: 0.4, step: 0.1),
  (from: 13, to: 25, start: 2.0, step: 0.5),
  (from: 26, to: 33, start: 9.0, step: 1.0),
  (from: 34, to: 1 << 20, start: 18.0, step: 2.0),
];

double ramFromTick(int tick) {
  if (tick <= 0) return 0.3;
  for (final segment in _ramSteps) {
    if (tick <= segment.to) {
      return segment.start + (tick - segment.from) * segment.step;
    }
  }
  return _ramSteps.last.start;
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
  if (Platform.isLinux || Platform.isAndroid) {
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
/// 原版按 2G 起步；OptiFine 3G；可安装 Mod 的版本按 4G + 每个 Mod 25M 估算，最多 12G。
/// 同时给系统保留至少 2G 或总内存的 15%，且不超过当前空闲内存的 85%。
double autoRam({required bool modable, required bool optifine, required String gameDir}) {
  final mem = systemMemory();
  final need = modable ? min(12.0, 4 + _countMods(gameDir) * 0.025) : (optifine ? 3.0 : 2.0);
  final cap = min(mem.total - max(2.0, mem.total * 0.15), mem.free * 0.85);
  final give = max(1.0, min(need, cap));
  // 取 0.5G 的整数倍，方便用户理解和修改
  return max(1.0, (give * 2).floor() / 2);
}

/// -Xmx 与 -Xms，GB；initial 为 null 表示不设置 -Xms
typedef MemoryPlan = ({double max, double? initial});

/// 合并全局与实例设置中的内存选项，得到最终内存
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
