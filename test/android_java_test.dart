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

  test('同一个工作同时只进行一次，结束后能再次开始', () async {
    final running = <int, Future<int>>{};
    var started = 0;
    Future<int> work() async {
      started++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 42;
    }

    final a = sharedFuture(running, 21, work);
    final b = sharedFuture(running, 21, work);
    expect(identical(a, b), isTrue);
    // 曾经因为 whenComplete 的回调返回了自己而永远不结束
    expect(await a.timeout(const Duration(seconds: 2)), 42);
    expect(running, isEmpty);
    expect(started, 1);
    await sharedFuture(running, 21, work);
    expect(started, 2);
  });

  test('列出安装完成的 Java，没有装完的不算', () {
    expect(installedAndroidJavas().map((j) => j.major), [17, 8]);
  });

  test('下载地址先 GitHub，失败后使用 ghproxy 等镜像', () {
    final urls = androidJreUrls(17);
    expect(urls.first, startsWith('https://github.com/AngelAuraMC/'));
    expect(urls.first, endsWith('jre17-android-arm64.tar.xz'));
    expect(
      urls[1],
      'https://ghproxy.net/https://github.com/AngelAuraMC/'
      'angelauramc-openjdk-build/releases/download/download_jre17/jre17-android-arm64.tar.xz',
    );
    expect(urls.any((u) => u.startsWith('https://gh-proxy.com/')), isTrue);
    expect(urls.any((u) => u.startsWith('https://ghfast.top/')), isTrue);
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
