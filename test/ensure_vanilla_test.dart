import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/install.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/task.dart';

void main() {
  late Directory dir;
  late GamePaths g;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pw_vanilla');
    g = GamePaths(dir.path);
    await Directory(g.versionDir('1.20.1')).create(recursive: true);
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> writeJson(Map<String, dynamic>? client) => File(g.versionJson('1.20.1')).writeAsString(
    jsonEncode({
      'id': '1.20.1',
      if (client != null) 'downloads': {'client': client},
    }),
  );

  test('原版 jar 的下载项固定在 versions/<版本>/<版本>.jar', () async {
    await writeJson({'url': 'https://example.invalid/client.jar', 'sha1': 'a' * 40, 'size': 3});
    final item = await vanillaJarItem(g, '1.20.1');
    expect(item!.path, p.join(g.versionDir('1.20.1'), '1.20.1.jar'));
    expect(item.sha1, 'a' * 40);
    expect(item.size, 3);
  });

  test('JSON 没有下载信息时返回 null（需要重新获取原版 JSON）', () async {
    await writeJson(null);
    expect(await vanillaJarItem(g, '1.20.1'), isNull);
  });

  test('jar 完整时不联网', () async {
    final bytes = utf8.encode('jar');
    await File(g.versionJar('1.20.1')).writeAsBytes(bytes);
    await writeJson({
      'url': 'https://example.invalid/client.jar',
      'sha1': sha1.convert(bytes).toString(),
      'size': bytes.length,
    });
    // 地址无效：如果去下载会抛出异常
    await ensureVanilla(g, '1.20.1', Downloader(useMirror: false, concurrency: 1), TaskProgress('t'));
  });
}
