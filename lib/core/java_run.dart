import 'dart:convert';
import 'dart:io';

import 'android_runtime.dart';
import 'download.dart';
import 'instance_config.dart';
import 'java.dart';
import 'task.dart';
import 'version.dart';

/// 用适合 [v] 的 Java 运行一个 jar（加载器安装器、OptiFine Patcher 等），返回退出代码与输出。
/// 电脑上作为独立进程运行；安卓上 Java 只能经游戏运行时启动，在单独的进程中无界面运行。
/// 安卓上拿不到 System.exit 的退出代码（见 [AndroidRuntime.runJar]），调用方应按生成的结果判断是否成功。
Future<({int code, String output})> runJava(
  VersionJson v,
  List<String> args, {
  required String workDir,
  required Downloader dl,
  required TaskProgress task,
  void Function(String line)? onLine,
}) async {
  if (Platform.isAndroid) {
    final java = await ensureAndroidJava(v, dl, task);
    return AndroidRuntime.runJar(javaHome: java.path, workDir: workDir, args: args, onLine: onLine);
  }
  final java = await ensureJava(v, const JavaAuto(), '', dl, task);
  final proc = await Process.start(java.path, args, workingDirectory: workDir);
  final out = StringBuffer();
  void add(String l) {
    out.writeln(l);
    onLine?.call(l);
  }

  final a = proc.stdout
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter())
      .listen(add)
      .asFuture<void>();
  final b = proc.stderr
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter())
      .listen(add)
      .asFuture<void>();
  final code = await proc.exitCode;
  await Future.wait([a, b]).catchError((_) => const <void>[]);
  return (code: code, output: out.toString());
}
