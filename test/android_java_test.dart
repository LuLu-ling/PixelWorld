import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/android_runtime.dart';
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/instance_config.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/task.dart';
import 'package:pcl_pw/core/version.dart';

void main() {
  late Directory dir;
  final dl = Downloader(useMirror: false, concurrency: 1);

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('pclpw-android-java');
    Paths.appData = dir.path;
    // 模拟已安装的 Java 8 与 17
    for (final m in [8, 17]) {
      Directory(androidJavaHome(m)).createSync(recursive: true);
      File(p.join(androidJavaHome(m), '.installed')).writeAsStringSync('$m');
    }
    // 没有解压完的 Java 21（没有 .installed）
    Directory(androidJavaHome(21)).createSync(recursive: true);
  });
  tearDownAll(() => dir.deleteSync(recursive: true));

  VersionJson needs(int major) => VersionJson({
    'id': 'x',
    'javaVersion': {'majorVersion': major},
  });

  test('列出安装完成的 Java，没有装完的不算', () {
    expect(installedAndroidJavas().map((j) => j.major), [17, 8]);
  });

  test('版本设置指定的 Java 优先于全局设置', () async {
    final j = await ensureAndroidJava(
      needs(8),
      dl,
      TaskProgress('t'),
      pref: JavaExist(androidJavaHome(8)),
      globalJava: androidJavaHome(17),
    );
    expect(j.major, 8);
  });

  test('跟随全局设置', () async {
    final j = await ensureAndroidJava(
      needs(8),
      dl,
      TaskProgress('t'),
      globalJava: androidJavaHome(17),
      pref: const JavaGlobal(),
    );
    expect(j.major, 17);
  });

  test('指定的 Java 版本过低时报错，不自动替换', () {
    expect(
      ensureAndroidJava(needs(17), dl, TaskProgress('t'), pref: JavaExist(androidJavaHome(8))),
      throwsA(predicate((e) => '$e'.contains('至少需要 Java 17'))),
    );
  });

  test('指定的 Java 没有安装时报错', () {
    expect(
      ensureAndroidJava(needs(21), dl, TaskProgress('t'), pref: const JavaGlobal(), globalJava: androidJavaHome(21)),
      throwsA(predicate((e) => '$e'.contains('没有安装'))),
    );
  });

  test('自动选择时使用已安装的对应版本', () async {
    final j = await ensureAndroidJava(needs(17), dl, TaskProgress('t'));
    expect(j.major, 17);
    // 1.12 等老版本要求 Java 8
    expect((await ensureAndroidJava(needs(8), dl, TaskProgress('t'))).major, 8);
  });
}
