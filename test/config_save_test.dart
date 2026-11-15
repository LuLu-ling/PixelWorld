import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/config.dart';
import 'package:pcl_pw/core/paths.dart';

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('pw-config-');
    Paths.appData = p.join(dir.path, 'data');
    Paths.configDir = dir.path;
  });
  tearDownAll(() => dir.delete(recursive: true));

  test('连续快速修改（拖动滑块）时排队保存，最后的配置文件完整且是最新值', () async {
    final cfg = LauncherConfig.load();
    // 不等待，模拟每一帧都改一次
    final pending = [
      for (var i = 0; i <= 100; i++) cfg.update({'bgPanelOpacity': i / 100}),
    ];
    await Future.wait(pending);
    final file = File(p.join(dir.path, 'config.json'));
    final saved = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(saved['bgPanelOpacity'], 1.0);
    expect(File('${file.path}.tmp').existsSync(), isFalse);
  });

  test('persist 为 false 时只改内存、不写文件', () async {
    final cfg = LauncherConfig.load();
    await cfg.update({'bgPanelOpacity': .5}, persist: false);
    expect(cfg.raw['bgPanelOpacity'], .5);
  });
}
