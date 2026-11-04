import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/launch.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('pclpw-splash'));
  tearDown(() => dir.deleteSync(recursive: true));

  File splash() => File(p.join(dir.path, 'config', 'splash.properties'));

  test('没有配置文件时新建并关闭加载画面', () async {
    await disableForgeSplash(dir.path);
    expect(splash().readAsStringSync(), 'enabled=false\n');
  });

  test('已开启时改为关闭，其他设置不变', () async {
    splash()
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('#Splash screen properties\nbackground=0xFFFFFF\nenabled=true\nrotate=false\n');
    await disableForgeSplash(dir.path);
    expect(
      splash().readAsStringSync(),
      '#Splash screen properties\nbackground=0xFFFFFF\nenabled=false\nrotate=false\n',
    );
  });

  test('配置里没有 enabled 时补上', () async {
    splash()
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('rotate=false');
    await disableForgeSplash(dir.path);
    expect(splash().readAsStringSync(), 'rotate=false\nenabled=false\n');
  });
}
