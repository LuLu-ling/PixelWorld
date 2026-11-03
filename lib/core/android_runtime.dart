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

  /// 解压 LWJGL，返回本地库目录与替换游戏自带 LWJGL 的 classpath
  static Future<({String nativeLibDir, List<String> lwjglClasspath})> prepare() async {
    final r = (await _channel.invokeMapMethod<String, dynamic>('prepare'))!;
    return (nativeLibDir: r['nativeLibDir'] as String, lwjglClasspath: (r['lwjglClasspath'] as List).cast<String>());
  }

  /// 游戏日志（游戏在独立进程中运行，输出写到这个文件）
  static String get logFile => p.join(Paths.appData, 'game_logs', 'latest.log');

  /// 在独立进程中启动游戏；[args] 是 JVM 参数、主类与游戏参数
  static Future<void> launch({
    required String javaHome,
    required String gameDir,
    required List<String> args,
    double scale = 1,
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
    });
  }

  static DateTime? _launchedAt;

  /// 本应用自启动游戏以来的系统日志（包括游戏进程的原生崩溃信息）
  static Future<String> systemLog() async {
    final since = (_launchedAt ?? DateTime.now().subtract(const Duration(minutes: 1))).subtract(const Duration(seconds: 2));
    try {
      return await _channel.invokeMethod<String>('logcat', {'since': since.millisecondsSinceEpoch}) ?? '';
    } catch (e) {
      return '读取系统日志失败：$e';
    }
  }

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
  if (major == 8) {
    throw Exception('安卓版暂时只能启动 Minecraft 1.17 及以上版本（需要 Java 17 或更新），旧版本的支持正在开发中');
  }
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
