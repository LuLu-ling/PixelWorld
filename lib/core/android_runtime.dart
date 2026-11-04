import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'download.dart';
import 'java.dart';
import 'paths.dart';
import 'task.dart';
import 'version.dart';

/// 安卓上的游戏运行时（android/runtime 模块，LGPL-3.0）。启动器只通过这里与它交互，以后可以整体替换。
abstract final class AndroidRuntime {
  static const _channel = MethodChannel('pclpw/runtime');

  /// 解压 LWJGL，返回本地库目录、替换游戏自带 LWJGL 的 classpath，以及 LWJGL 2 兼容层（lwjglx）。
  /// [sdl]：游戏用 SDL3 代替 GLFW（26.x），需要 LWJGL 3.4.1
  static Future<({String nativeLibDir, List<String> lwjglClasspath, String lwjglx, String lwjgl})> prepare({
    bool sdl = false,
  }) async {
    final r = (await _channel.invokeMapMethod<String, dynamic>('prepare', {'sdl': sdl}))!;
    return (
      nativeLibDir: r['nativeLibDir'] as String,
      lwjglClasspath: (r['lwjglClasspath'] as List).cast<String>(),
      lwjglx: r['lwjglx'] as String,
      lwjgl: r['lwjglVersion'] as String,
    );
  }

  /// 游戏日志（游戏在独立进程中运行，输出写到这个文件）
  static String get logFile => p.join(Paths.appData, 'game_logs', 'latest.log');

  /// 在独立进程中启动游戏；[args] 是 JVM 参数、主类与游戏参数。
  /// [inputQueue]：1.13+ 在游戏线程上处理输入；[ffp]：1.17 之前的固定管线，需要 SFPEW 模拟
  static Future<void> launch({
    required String javaHome,
    required String gameDir,
    required List<String> args,
    double scale = 1,
    bool inputQueue = true,
    bool ffp = false,
    String lwjgl = '3.3.3',
    String renderer = 'mobileglues',
    bool turnip = false,
  }) async {
    await File(logFile).parent.create(recursive: true);
    if (File(logFile).existsSync()) await File(logFile).delete();
    _launchedAt = DateTime.now();
    await _channel.invokeMethod('launch', {
      'javaHome': javaHome,
      'gameDir': gameDir,
      'logFile': logFile,
      'args': args,
      'scale': scale,
      'inputQueue': inputQueue,
      'ffp': ffp,
      'lwjgl': lwjgl,
      'renderer': renderer,
      'turnip': turnip,
    });
  }

  static DateTime? _launchedAt;

  /// 本应用自启动游戏以来的系统日志（包括游戏进程的原生崩溃信息）
  static Future<String> systemLog() async {
    final since = (_launchedAt ?? DateTime.now().subtract(const Duration(minutes: 1))).subtract(
      const Duration(seconds: 2),
    );
    try {
      return await _channel.invokeMethod<String>('logcat', {'since': since.millisecondsSinceEpoch}) ?? '';
    } catch (e) {
      return '读取系统日志失败：$e';
    }
  }

  /// 回到正在运行的游戏界面
  static Future<void> resume() => _channel.invokeMethod('resume');

  /// 结束游戏进程
  static Future<void> stop() => _channel.invokeMethod('stop');

  static Future<bool> isRunning() async => await _channel.invokeMethod<bool>('isRunning') ?? false;

  /// 游戏异常退出时记录的退出代码，读取后清除
  static Future<int?> lastExit() async {
    final s = await _channel.invokeMethod<String>('lastExit');
    return s == null ? null : int.tryParse(s.split(' ').first);
  }

  /// 跟踪游戏日志，游戏进程结束时返回退出代码
  static Future<int> watch(void Function(String chunk) onLog) async {
    var offset = 0;
    var started = false;
    final file = File(logFile);
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    int? code;
    void read() {
      if (!file.existsSync()) return;
      final len = file.lengthSync();
      if (len <= offset) return;
      final raf = file.openSync();
      raf.setPositionSync(offset);
      final bytes = raf.readSync(len - offset);
      raf.closeSync();
      offset = len;
      final text = utf8.decode(bytes, allowMalformed: true);
      onLog(text);
      final m = RegExp(r'Java exit code: (-?\d+)').firstMatch(text);
      if (m != null) code = int.parse(m.group(1)!);
    }

    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      read();
      final running = await isRunning();
      if (running) started = true;
      // 进程结束；进程一直没起来时最多等 30 秒
      if (!running && (started || DateTime.now().isAfter(deadline))) break;
    }
    read();
    final exit = await lastExit() ?? code ?? (started ? 0 : -1);
    if (!started) onLog('\n[PCL.PW] 游戏进程没有启动，或启动后立即退出了。\n');
    // 异常退出时附上系统日志，原生库加载失败等问题只会出现在这里
    if (exit != 0 || offset == 0) {
      onLog('\n---------- 系统日志（logcat） ----------\n${await systemLog()}\n');
    }
    return exit;
  }

  /// 在独立进程中无界面地运行 jar，等它结束。[args] 为 JVM 参数加上 `-jar <文件> ...` 或 `-cp <路径> <主类> ...`。
  /// 输出逐行交给 [onLine]，返回完整输出与退出代码。
  /// 只有异常退出能得到退出代码（信号、未捕获的异常）；System.exit 的代码拿不到，记为 0，
  /// 所以调用方应按结果（生成的文件等）判断是否成功。
  static Future<({int code, String output})> runJar({
    required String javaHome,
    required String workDir,
    required List<String> args,
    void Function(String line)? onLine,
  }) async {
    final log = File(p.join(Paths.appData, 'jar_logs', 'latest.log'));
    await log.parent.create(recursive: true);
    if (log.existsSync()) await log.delete();
    _launchedAt = DateTime.now();
    await _channel.invokeMethod('runJar', {
      'javaHome': javaHome,
      'workDir': workDir,
      'logFile': log.path,
      'args': args,
    });

    final out = StringBuffer();
    var offset = 0;
    var pending = '';
    int? reported;
    void read() {
      if (!log.existsSync()) return;
      final len = log.lengthSync();
      if (len <= offset) return;
      final raf = log.openSync();
      raf.setPositionSync(offset);
      final bytes = raf.readSync(len - offset);
      raf.closeSync();
      offset = len;
      final text = pending + utf8.decode(bytes, allowMalformed: true);
      final lines = text.split('\n');
      pending = lines.removeLast();
      for (final l in lines) {
        final line = l.trimRight();
        final m = RegExp(r'^Java exit code: (-?\d+)$').firstMatch(line);
        if (m != null) reported = int.parse(m.group(1)!);
        out.writeln(line);
        onLine?.call(line);
      }
    }

    var started = false;
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      read();
      final running = await _channel.invokeMethod<bool>('jarRunning') ?? false;
      if (running) started = true;
      if (!running && (started || DateTime.now().isAfter(deadline))) break;
    }
    read();
    if (pending.isNotEmpty) {
      out.writeln(pending);
      onLine?.call(pending);
    }
    final s = await _channel.invokeMethod<String>('jarExit');
    // 运行时启动 JVM 前会写一行「PCL.PW runtime:」；没有这一行说明进程在那之前就崩溃了
    final jvmStarted = out.toString().contains('PCL.PW runtime:');
    final code = (s == null ? null : int.tryParse(s.split(' ').first)) ?? reported ?? (started && jvmStarted ? 0 : -1);
    if (!started) {
      out.writeln('[PCL.PW] jar 运行进程没有启动');
    } else if (!jvmStarted) {
      out.writeln('[PCL.PW] jar 运行进程在启动 Java 前退出了');
      final log = await systemLog();
      final lines = log.split('\n').where((l) => l.contains(':jar') || l.contains('AndroidRuntime')).toList();
      out.writeln((lines.length > 30 ? lines.sublist(lines.length - 30) : lines).join('\n'));
    }
    return (code: code, output: out.toString());
  }

  /// 结束正在运行的 jar
  static Future<void> stopJar() => _channel.invokeMethod('stopJar');
}

/// 安卓上的渲染器（名字与运行时 GameRuntime 一致）；auto 按显卡选择
/// MobileGlues + ANGLE（运行时名 angle）暂不提供：在骁龙 8 Gen 3 上 ANGLE 初始化后界面线程卡死被系统结束。
/// 已选的会按「自动」处理
const androidRenderers = {
  'auto': '自动',
  'mobileglues': 'MobileGlues（推荐）',
  'zink': 'Zink（OpenGL 转 Vulkan）',
  'system_gles': '系统 GLES 驱动（仅限支持 GLES 的模组）',
};

/// 各渲染器的说明，显示在设置里
const androidRendererHints = {
  'auto': '按显卡自动选择，目前几乎所有设备都会用 MobileGlues',
  'mobileglues': 'OpenGL 转 OpenGL ES，速度快，支持所有版本（旧版本自动加 SFPEW 模拟固定管线）',
  'zink':
      'Mesa Zink：完整的 OpenGL 4.6，需要 Vulkan 1.1。骁龙（Adreno）上自动改用自带的开源驱动 Turnip，'
      '适合 MobileGlues 画面出错时使用',
  'system_gles': '直接使用系统 GLES 驱动，不做转译。原版 Minecraft 无法以此运行',
};

/// 显卡信息（系统 GLES 驱动报告的名称与 Vulkan 版本）
class AndroidGpu {
  AndroidGpu(Map<String, dynamic> m)
    : renderer = '${m['renderer'] ?? ''}',
      vendor = '${m['vendor'] ?? ''}',
      glesVersion = '${m['glesVersion'] ?? ''}',
      vulkan = '${m['vulkan'] ?? ''}',
      soc = '${m['soc'] ?? ''}';

  final String renderer, vendor, glesVersion, vulkan, soc;

  /// GLES 主版本，例如 "OpenGL ES 3.2 V@..." 为 3
  int get glesMajor => int.tryParse(RegExp(r'OpenGL ES (\d+)').firstMatch(glesVersion)?.group(1) ?? '') ?? 0;

  bool get hasVulkan11 {
    final parts = vulkan.split('.');
    final major = int.tryParse(parts.first) ?? 0, minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return major > 1 || (major == 1 && minor >= 1);
  }

  bool get isAdreno => renderer.toLowerCase().contains('adreno');
  bool get isMali => renderer.toLowerCase().contains('mali');

  @override
  String toString() => [
    if (renderer.isNotEmpty) renderer,
    if (glesVersion.isNotEmpty) glesVersion.split(' ').take(3).join(' '),
    vulkan.isEmpty ? '无 Vulkan' : 'Vulkan $vulkan',
    if (soc.isNotEmpty) soc,
  ].join(' · ');
}

AndroidGpu? _gpu;

/// 读取显卡信息（只读一次）
Future<AndroidGpu> androidGpu() async =>
    _gpu ??= AndroidGpu((await AndroidRuntime._channel.invokeMapMethod<String, dynamic>('gpu')) ?? const {});

/// 把设置中的渲染器（可能是 auto）换成实际使用的渲染器，并给出理由
({String renderer, String reason}) resolveAndroidRenderer(String pref, AndroidGpu gpu) {
  if (pref != 'auto' && androidRenderers.containsKey(pref)) return (renderer: pref, reason: '设置指定');
  // MobileGlues 需要 OpenGL ES 3；更老的驱动只能走 Vulkan
  if (gpu.glesMajor > 0 && gpu.glesMajor < 3 && gpu.hasVulkan11) {
    return (renderer: 'zink', reason: '显卡不支持 OpenGL ES 3');
  }
  return (renderer: 'mobileglues', reason: '自动选择');
}

/// 安卓版 OpenJDK（AngelAuraMC 构建，GPLv2 + Classpath Exception）
int androidJavaMajor(int required) => required <= 8
    ? 8
    : required <= 17
    ? 17
    : required <= 21
    ? 21
    : 25;

String _jreUrl(int major) =>
    'https://github.com/AngelAuraMC/angelauramc-openjdk-build/releases/download/download_jre$major/jre$major-android-arm64.tar.xz';

/// 按版本需要下载并解压安卓版 Java
Future<JavaInfo> ensureAndroidJava(VersionJson v, Downloader dl, TaskProgress task) async {
  final major = androidJavaMajor(v.javaMajor ?? 8);
  final root = p.join(Paths.appData, 'android-java');
  final home = p.join(root, 'jre$major');
  final marker = File(p.join(home, '.installed'));
  if (!marker.existsSync()) {
    final archive = p.join(root, 'jre$major.tar.xz');
    task.setStage('下载 Java $major（安卓版，约 30 MB）');
    await dl.downloadFile(DownloadItem(url: _jreUrl(major), path: archive));
    task.setStage('解压 Java $major');
    await AndroidRuntime._channel.invokeMethod('installJre', {'archive': archive, 'dest': home});
    await File(archive).delete().catchError((_) => File(archive));
    await marker.writeAsString('$major');
  }
  return JavaInfo(path: home, version: '$major', major: major, is64: true, managed: true);
}
