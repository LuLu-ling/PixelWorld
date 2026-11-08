import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/forge.dart';
import 'package:pcl_pw/core/loaders.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/task.dart';

/// 真实网络 + 真实安装器的端到端测试，默认跳过：
///
///   $env:PCLPW_FORGE_E2E='1'; flutter test test/forge_offline_e2e_test.dart
///
/// 会下载 1.20.1 的本体与资源文件，比较耗时。
/// 设置 `PCLPW_GAME_DIR` 可以复用之前的游戏目录，避免重复下载。
void main() {
  final enabled = Platform.environment['PCLPW_FORGE_E2E'] == '1';
  test(
    'Forge 1.20.1 使用离线模式安装',
    () async {
      final reuse = Platform.environment['PCLPW_GAME_DIR'];
      final dir = reuse == null
          ? await Directory.systemTemp.createTemp('pclpw_forge_e2e')
          : Directory(reuse);
      await dir.create(recursive: true);
      // 测试里没有 Flutter 引擎，自行指定启动器数据目录（Java 运行时与校验缓存）
      Paths.appData = p.join(dir.path, 'appdata');
      await Directory(Paths.appData).create(recursive: true);
      VerifiedFiles.storePath = p.join(Paths.appData, 'verified-files.json');
      final g = GamePaths(dir.path);
      final task = TaskProgress('安装 Forge 1.20.1');
      final dl = Downloader(useMirror: true, concurrency: 16);
      // 安装器输出会刷掉 2000 行以前的日志，用监听器在出现时立刻记下
      var offlineSeen = false;
      task.addListener(() {
        if (task.detail.contains('ENABLING OFFLINE MODE')) offlineSeen = true;
      });
      var ok = false;
      try {
        final id = await installForgeLike(g, LoaderKind.forge, '1.20.1', '1.20.1-47.4.28', dl, task);
        expect(File(g.versionJson(id)).existsSync(), isTrue);
        expect(File(g.versionJar(id)).existsSync(), isTrue);
        // 安装器只有在真正进入离线模式时才会打印这一行
        expect(offlineSeen, isTrue, reason: '安装器没有进入离线模式');
        stdout.writeln('installed "$id" into ${dir.path}');
        ok = true;
      } finally {
        // 失败时保留目录，方便查看安装器日志
        if (ok && reuse == null) await dir.delete(recursive: true);
      }
    },
    skip: enabled ? false : '真实网络安装测试，设置 PCLPW_FORGE_E2E=1 运行',
    timeout: const Timeout(Duration(minutes: 40)),
  );
}
