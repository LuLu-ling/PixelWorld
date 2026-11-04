import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/backup.dart';

void main() {
  late Directory tmp;
  late String game;
  final key = List.generate(32, (i) => i);

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pclpw-backup');
    game = p.join(tmp.path, 'game');
    Directory(p.join(game, 'saves', 'w', 'region')).createSync(recursive: true);
    File(p.join(game, 'saves', 'w', 'level.dat')).writeAsStringSync('level');
    File(p.join(game, 'saves', 'w', 'region', 'r.0.0.mca')).writeAsStringSync('region');
    Directory(p.join(game, 'config')).createSync();
    File(p.join(game, 'config', 'a.json')).writeAsStringSync('{"a":1}');
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  String zipOf(List<ArchiveFile> files) {
    final out = p.join(tmp.path, 'b${DateTime.now().microsecondsSinceEpoch}.zip');
    final a = Archive();
    files.forEach(a.add);
    File(out).writeAsBytesSync(ZipEncoder().encode(a));
    return out;
  }

  ArchiveFile manifest(Object paths, {Map<String, dynamic> extra = const {}}) =>
      ArchiveFile.string(backupManifestName, jsonEncode({'version': 'x', 'paths': paths, ...extra}));

  Matcher rejects(String text) => throwsA(isA<BackupException>().having((e) => e.message, 'message', contains(text)));

  test('PCL.PW 创建的备份可以通过检查并完整解压', () async {
    final zip = p.join(tmp.path, 'ok.zip');
    await createBackup(zip, game, ['saves/w', 'config/a.json', 'saves/w/level.dat'], versionId: 'x', key: key);
    final check = await checkBackup(zip, game, key);
    expect(check.signed, isTrue);
    expect(check.paths, ['config/a.json', 'saves/w']..sort((a, b) => a.length.compareTo(b.length)));
    expect(check.files, 3);

    final staging = p.join(tmp.path, 'staging');
    await extractBackup(zip, staging, check);
    expect(File(p.join(staging, 'saves', 'w', 'region', 'r.0.0.mca')).readAsStringSync(), 'region');
    expect(File(p.join(staging, 'config', 'a.json')).readAsStringSync(), '{"a":1}');
  });

  test('其他设备的密钥签名的备份被拒绝', () async {
    final zip = p.join(tmp.path, 'ok.zip');
    await createBackup(zip, game, ['config'], versionId: 'x', key: key);
    expect(checkBackup(zip, game, List.filled(32, 7)), rejects('签名不匹配'));
  });

  test('内容被修改的签名备份被拒绝', () async {
    final zip = p.join(tmp.path, 'ok.zip');
    await createBackup(zip, game, ['config'], versionId: 'x', key: key);
    // 保留原清单，替换文件内容（长度相同）
    final original = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
    final tampered = zipOf([
      ArchiveFile.string('config/a.json', '{"a":2}'),
      ArchiveFile.bytes(backupManifestName, original.findFile(backupManifestName)!.content),
    ]);
    final check = await checkBackup(tampered, game, key);
    expect(extractBackup(tampered, p.join(tmp.path, 's2'), check), rejects('不符'));
  });

  test('没有清单的 zip 被拒绝', () async {
    expect(checkBackup(zipOf([ArchiveFile.string('mods/a.jar', 'x')]), game, key), rejects('不是由 PCL.PW 创建'));
  });

  test('清单中的不安全路径被拒绝', () async {
    for (final bad in ['../outside', '/etc', r'C:\Windows', 'saves/../../x', 'a:b']) {
      expect(
        checkBackup(
          zipOf([
            manifest([bad]),
          ]),
          game,
          key,
        ),
        rejects('不安全的路径'),
        reason: bad,
      );
    }
    expect(checkBackup(zipOf([manifest('mods')]), game, key), rejects('清单无效'));
    expect(checkBackup(zipOf([manifest(<String>[])]), game, key), rejects('清单无效'));
    expect(
      checkBackup(
        zipOf([
          manifest(['mods', 'mods/a.jar']),
        ]),
        game,
        key,
      ),
      rejects('互相包含'),
    );
  });

  test('条目路径穿越或超出清单范围被拒绝', () async {
    expect(
      checkBackup(
        zipOf([
          manifest(['mods']),
          ArchiveFile.string('mods/../../evil.txt', 'x'),
        ]),
        game,
        key,
      ),
      rejects('不安全的路径'),
    );
    expect(
      checkBackup(
        zipOf([
          manifest(['mods']),
          ArchiveFile.string('config/evil.txt', 'x'),
        ]),
        game,
        key,
      ),
      rejects('清单以外'),
    );
    expect(
      checkBackup(
        zipOf([
          manifest(['mods']),
          ArchiveFile.string('modsx/evil.txt', 'x'),
        ]),
        game,
        key,
      ),
      rejects('清单以外'),
    );
  });

  test('符号链接条目被拒绝', () async {
    final link = ArchiveFile.string('mods/link', '')..symbolicLink = '/etc/passwd';
    expect(
      checkBackup(
        zipOf([
          manifest(['mods']),
          link,
        ]),
        game,
        key,
      ),
      rejects('符号链接'),
    );
  });

  test('伪造的签名被拒绝', () async {
    final zip = zipOf([
      manifest(
        ['mods'],
        extra: {
          'files': {
            'mods/a.jar': {'size': 1, 'sha256': '00'},
          },
          'mac': 'deadbeef',
        },
      ),
      ArchiveFile.string('mods/a.jar', 'x'),
    ]);
    expect(checkBackup(zip, game, key), rejects('签名不匹配'));
  });

  test('旧版（无签名）备份仍可检查，但标记为未签名', () async {
    final zip = zipOf([
      manifest(['config']),
      ArchiveFile.string('config/a.json', '{}'),
    ]);
    final check = await checkBackup(zip, game, key);
    expect(check.signed, isFalse);
    expect(check.paths, ['config']);
  });

  test('备份不包含指向外部的目录链接', () async {
    final outside = Directory(p.join(tmp.path, 'outside'))..createSync();
    File(p.join(outside.path, 'secret.txt')).writeAsStringSync('secret');
    Link(p.join(game, 'config', 'linked')).createSync(outside.path);
    final zip = p.join(tmp.path, 'ok.zip');
    await createBackup(zip, game, ['config'], versionId: 'x', key: key);
    final names = ZipDecoder().decodeBytes(File(zip).readAsBytesSync()).files.map((f) => f.name).toList();
    expect(names.where((n) => n.contains('secret')), isEmpty);
  });

  test('路径集合去掉重复与被包含的路径', () {
    expect(normalizePathSet(['mods/a.jar', 'mods', 'mods/', 'config', 'configs/x']), ['mods', 'config', 'configs/x']);
  });
}
