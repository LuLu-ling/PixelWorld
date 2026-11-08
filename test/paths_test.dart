import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/paths.dart';

void main() {
  test('品牌改名后把旧数据目录整体迁移到新位置', () async {
    final root = await Directory.systemTemp.createTemp('pclpw_migrate');
    final roaming = p.join(root.path, 'Roaming');
    final old = Directory(p.join(roaming, 'PCL.PW', 'PCL.PW'));
    await old.create(recursive: true);
    await File(p.join(old.path, 'config.json')).writeAsString('{"gameDir":"X"}');
    await File(p.join(old.path, 'accounts.dat')).writeAsString('account');
    await Directory(p.join(old.path, 'runtime', 'jre')).create(recursive: true);
    await File(p.join(old.path, 'runtime', 'jre', 'java.exe')).writeAsString('java');

    final target = p.join(roaming, 'Pixel World', 'Pixel World');
    await migrateAppData(roaming, target);

    expect(File(p.join(target, 'config.json')).existsSync(), isTrue);
    expect(File(p.join(target, 'accounts.dat')).existsSync(), isTrue);
    expect(File(p.join(target, 'runtime', 'jre', 'java.exe')).existsSync(), isTrue);
    expect(old.existsSync(), isFalse);
    await root.delete(recursive: true);
  });

  test('新目录已有配置时不覆盖', () async {
    final root = await Directory.systemTemp.createTemp('pclpw_migrate2');
    final roaming = p.join(root.path, 'Roaming');
    final old = Directory(p.join(roaming, 'PCL.PW', 'PCL.PW'));
    await old.create(recursive: true);
    await File(p.join(old.path, 'config.json')).writeAsString('old');
    final target = p.join(roaming, 'Pixel World', 'Pixel World');
    await Directory(target).create(recursive: true);
    await File(p.join(target, 'config.json')).writeAsString('new');

    await migrateAppData(roaming, target);

    expect(await File(p.join(target, 'config.json')).readAsString(), 'new');
    expect(old.existsSync(), isTrue);
    await root.delete(recursive: true);
  });
}
