import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/instance_config.dart';
import 'package:pcl_pw/core/lan_transfer.dart';
import 'package:pcl_pw/core/paths.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pclpw-lan-');
    Paths.appData = p.join(tmp.path, 'appdata');
    Directory(Paths.appData).createSync();
  });

  tearDownAll(() => tmp.deleteSync(recursive: true));

  void write(String path, String text) {
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(text);
  }

  test('解析地址', () {
    expect(parseTransferAddress(' 192.168.1.5:43567 ').toString(), 'http://192.168.1.5:43567');
    expect(() => parseTransferAddress('192.168.1.5'), throwsA(isA<TransferException>()));
    expect(() => parseTransferAddress('example.com:80'), throwsA(isA<TransferException>()));
  });

  test('发送部分内容并导入，替换前备份', () async {
    final src = p.join(tmp.path, 'src', 'versions', 'a');
    write(p.join(src, 'a.json'), '{}');
    write(p.join(src, 'mods', 'x.jar'), 'new mod');
    write(p.join(src, 'saves', 'w', 'level.dat'), 'world');

    final dstRoot = p.join(tmp.path, 'dst');
    final dst = p.join(dstRoot, 'versions', 'b');
    write(p.join(dst, 'mods', 'old.jar'), 'old');

    String? stopped;
    ReceivedTransfer? got;
    final server = await TransferServer.start(onReceived: (t) => got = t, onStopped: (r) => stopped = r);
    final base = Uri.parse('http://127.0.0.1:${server.port}');
    try {
      expect(await transferHello(base, server.code), isNotEmpty);
      final zip = await packTransfer(
        version: 'a',
        versionDir: src,
        gameDir: src,
        wholeVersion: false,
        items: ['mods', 'saves'],
      );
      await transferSend(base, server.code, zip);
      zip.deleteSync();
    } finally {
      await server.close();
    }
    expect(stopped, isNull);
    expect(got!.manifest.items, ['mods', 'saves']);

    final backup = await importTransferFiles(
      got!.file.path,
      got!.manifest,
      dst,
      targetVersion: 'b',
      backupDir: p.join(dstRoot, 'backups', 'b'),
    );
    expect(backup, isNotNull);
    expect(File(backup!).existsSync(), isTrue);
    expect(File(p.join(dst, 'mods', 'old.jar')).existsSync(), isFalse);
    expect(File(p.join(dst, 'mods', 'x.jar')).readAsStringSync(), 'new mod');
    expect(File(p.join(dst, 'saves', 'w', 'level.dat')).readAsStringSync(), 'world');
    expect(Directory(dst).listSync().where((e) => p.basename(e.path).startsWith('.pclpw-import')), isEmpty);
  });

  test('整个版本导入为新版本并开启版本隔离；同名版本已存在时拒绝', () async {
    final root = p.join(tmp.path, 'whole');
    final ver = p.join(root, 'versions', 'v1');
    write(p.join(ver, 'v1.json'), '{"id":"v1"}');
    write(p.join(ver, 'logs', 'latest.log'), 'log');
    write(p.join(root, 'mods', 'm.jar'), 'mod');

    final zip = await packTransfer(version: 'v1', versionDir: ver, gameDir: root, wholeVersion: true, items: ['mods']);
    final m = checkTransfer(zip.path);
    expect(m.files.keys, containsAll(['version/v1.json', 'game/mods/m.jar']));
    expect(m.files.keys.any((k) => k.contains('logs')), isFalse);

    final dstRoot = p.join(tmp.path, 'whole-dst');
    Directory(p.join(dstRoot, 'versions')).createSync(recursive: true);
    expect(await importTransferVersion(zip.path, m, dstRoot), 'v1');
    expect(File(p.join(dstRoot, 'versions', 'v1', 'mods', 'm.jar')).existsSync(), isTrue);
    expect(readInstanceSettings(p.join(dstRoot, 'versions', 'v1')).isolation, isTrue);
    await expectLater(importTransferVersion(zip.path, m, dstRoot), throwsA(isA<TransferException>()));
    zip.deleteSync();
  });

  test('整个版本带上依赖的原版；本机已有原版时不覆盖', () async {
    final root = p.join(tmp.path, 'inherit');
    write(p.join(root, 'versions', 'forge', 'forge.json'), '{"id":"forge","inheritsFrom":"1.20.1"}');
    write(p.join(root, 'versions', '1.20.1', '1.20.1.json'), '{"id":"1.20.1"}');
    write(p.join(root, 'versions', '1.20.1', '1.20.1.jar'), 'jar');
    write(p.join(root, 'versions', '1.20.1', 'saves', 'w', 'level.dat'), 'not sent');
    final zip = await packTransfer(
      version: 'forge',
      versionDir: p.join(root, 'versions', 'forge'),
      gameDir: p.join(root, 'versions', 'forge'),
      wholeVersion: true,
      items: const [],
    );
    final m = checkTransfer(zip.path);
    expect(m.parents, ['1.20.1']);
    expect(m.files.keys.where((k) => k.startsWith('parent/')).toSet(), {
      'parent/1.20.1/1.20.1.json',
      'parent/1.20.1/1.20.1.jar',
    });

    final a = p.join(tmp.path, 'inherit-a');
    Directory(p.join(a, 'versions')).createSync(recursive: true);
    final steps = <int>[];
    await importTransferVersion(zip.path, m, a, onProgress: (t, d) => steps.add(d));
    expect(steps.last, m.bytes);
    expect(File(p.join(a, 'versions', '1.20.1', '1.20.1.jar')).readAsStringSync(), 'jar');
    expect(File(p.join(a, 'versions', 'forge', 'forge.json')).existsSync(), isTrue);

    final b = p.join(tmp.path, 'inherit-b');
    write(p.join(b, 'versions', '1.20.1', '1.20.1.jar'), 'local');
    await importTransferVersion(zip.path, m, b);
    expect(File(p.join(b, 'versions', '1.20.1', '1.20.1.jar')).readAsStringSync(), 'local');
    expect(Directory(p.join(b, 'versions')).listSync().map((e) => p.basename(e.path)).toSet(), {'1.20.1', 'forge'});
    zip.deleteSync();
  });

  test('配对码错 3 次后停止接收', () async {
    String? stopped;
    final server = await TransferServer.start(onReceived: (_) {}, onStopped: (r) => stopped = r);
    final base = Uri.parse('http://127.0.0.1:${server.port}');
    final wrong = server.code == '000000' ? '111111' : '000000';
    for (var i = 0; i < transferMaxFailures; i++) {
      await expectLater(transferHello(base, wrong), throwsA(isA<TransferException>()));
    }
    expect(stopped, isNotNull);
    await server.close();
  });
}
