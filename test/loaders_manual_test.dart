// 手动运行的联网测试：真实安装 OptiFine、Cleanroom、LabyMod 到 PW_TEST_GAME_DIR。
//   PW_TEST_GAME_DIR=... flutter test test/loaders_manual_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/instance.dart';
import 'package:pcl_pw/core/loaders.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/task.dart';

void main() {
  final dir = Platform.environment['PW_TEST_GAME_DIR'];
  final g = GamePaths(dir ?? '');
  final dl = Downloader(useMirror: false, concurrency: 16);

  Future<void> run(LoaderKind kind, String game) async {
    final versions = await loaderVersions(dl, kind, game);
    expect(versions, isNotEmpty, reason: '$kind 没有 $game 的版本');
    final v = versions.firstWhere((x) => x.stable, orElse: () => versions.first);
    final t = TaskProgress('test', steps: []);
    t.addListener(() {});
    final id = await installLoader(g, kind, game, v.version, dl, t);
    final info = await analyzeInstance(g, id);
    // ignore: avoid_print
    print(
      '$kind ${v.label} -> $id  识别为 ${info.loader} ${info.addons} 原版 ${info.gameVersion}  步骤 ${t.steps.map((s) => '${s.label}:${s.state.name}').join(' / ')}',
    );
  }

  test(
    'OptiFine 1.20.1',
    () => run(LoaderKind.optifine, '1.20.1'),
    skip: dir == null,
    timeout: const Timeout(Duration(minutes: 5)),
  );
  test(
    'LabyMod 1.20.1',
    () => run(LoaderKind.labymod, '1.20.1'),
    skip: dir == null,
    timeout: const Timeout(Duration(minutes: 10)),
  );
  test(
    'Cleanroom 1.12.2',
    () => run(LoaderKind.cleanroom, '1.12.2'),
    skip: dir == null,
    timeout: const Timeout(Duration(minutes: 10)),
  );
  setUpAll(() async => Paths.appData = Directory.systemTemp.createTempSync('pclpw-test').path);
}
