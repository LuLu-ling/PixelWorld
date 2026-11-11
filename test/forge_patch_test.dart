import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/forge.dart';

void main() {
  test('改写安装器配置时去掉签名文件，原安装器不变', () async {
    final dir = await Directory.systemTemp.createTemp('pw_forge_patch');
    try {
      final profile = {
        'processors': [
          {
            'jar': 'a:b:1',
            'args': ['--task', 'DOWNLOAD_MOJMAPS'],
          },
          {
            'jar': 'c:d:1',
            'args': ['--task', 'MCP_DATA'],
          },
        ],
      };
      final src = Archive()
        ..addFile(ArchiveFile.string('META-INF/MANIFEST.MF', 'Manifest-Version: 1.0\n'))
        ..addFile(ArchiveFile.string('META-INF/FORGE.SF', 'sig'))
        ..addFile(ArchiveFile.string('META-INF/FORGE.RSA', 'sig'))
        ..addFile(ArchiveFile.string('install_profile.json', jsonEncode(profile)))
        ..addFile(ArchiveFile.string('version.json', '{}'));
      final installer = p.join(dir.path, 'installer.jar');
      final output = p.join(dir.path, 'patched.jar');
      final original = ZipEncoder().encode(src);
      await File(installer).writeAsBytes(original);

      expect(await patchInstallerProfile(installer, output), isTrue);
      expect(await File(installer).readAsBytes(), original);

      final out = ZipDecoder().decodeBytes(await File(output).readAsBytes());
      final names = out.files.map((f) => f.name).toSet();
      expect(names, containsAll(['META-INF/MANIFEST.MF', 'install_profile.json', 'version.json']));
      expect(names.where((n) => n.endsWith('.SF') || n.endsWith('.RSA')), isEmpty);
      final patched = jsonDecode(utf8.decode(out.findFile('install_profile.json')!.content)) as Map;
      expect((patched['processors'] as List).single['jar'], 'c:d:1');

      // 没有要去掉的处理器时不生成新文件
      final plain = p.join(dir.path, 'plain.jar');
      await File(plain).writeAsBytes(
        ZipEncoder().encode(Archive()..addFile(ArchiveFile.string('install_profile.json', '{"processors":[]}'))),
      );
      expect(await patchInstallerProfile(plain, p.join(dir.path, 'x.jar')), isFalse);
      expect(File(p.join(dir.path, 'x.jar')).existsSync(), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
