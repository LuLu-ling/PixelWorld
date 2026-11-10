import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/paths.dart';

void main() {
  late Directory root;
  late String roaming, local, legacy, configDir, dataDir;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('pw_layout');
    roaming = p.join(root.path, 'Roaming');
    local = p.join(root.path, 'Local');
    legacy = p.join(roaming, 'Pixel World', 'Pixel World');
    configDir = p.join(roaming, 'Pixel World');
    dataDir = p.join(local, 'Pixel World');
  });

  tearDown(() => root.delete(recursive: true));

  Future<void> writeLegacy(String dir) async {
    await Directory(p.join(dir, 'runtime', 'jre')).create(recursive: true);
    await File(p.join(dir, 'runtime', 'jre', 'java.exe')).writeAsString('java');
    await File(p.join(dir, 'accounts.dat')).writeAsString('account');
    await File(p.join(dir, 'ai.dat')).writeAsString('key');
    await File(p.join(dir, 'config.json')).writeAsString(
      jsonEncode({
        'gameDir': p.join(dir, '.minecraft'),
        'javaPath': p.join(dir, 'runtime', 'jre', 'java.exe'),
        'gameFolders': [
          {'path': p.join(dir, '.minecraft'), 'name': '默认'},
          {'path': r'D:\Games\.minecraft', 'name': '其他'},
        ],
        'other': '$dir-not-a-child',
      }),
    );
  }

  test('旧目录拆成配置目录（Roaming）和数据目录（Local），配置里的路径改到新位置', () async {
    await writeLegacy(legacy);
    final used = await migrateWindowsLayout(legacy: [legacy], configDir: configDir, dataDir: dataDir);

    expect(used, dataDir);
    expect(File(p.join(configDir, 'config.json')).existsSync(), isTrue);
    expect(File(p.join(configDir, 'accounts.dat')).readAsStringSync(), 'account');
    expect(File(p.join(configDir, 'ai.dat')).existsSync(), isTrue);
    expect(File(p.join(dataDir, 'runtime', 'jre', 'java.exe')).existsSync(), isTrue);
    // 数据目录里不留配置文件的副本，旧目录删掉
    expect(File(p.join(dataDir, 'config.json')).existsSync(), isFalse);
    expect(Directory(legacy).existsSync(), isFalse);

    final cfg = jsonDecode(File(p.join(configDir, 'config.json')).readAsStringSync()) as Map;
    expect(cfg['gameDir'], p.join(dataDir, '.minecraft'));
    expect(cfg['javaPath'], p.join(dataDir, 'runtime', 'jre', 'java.exe'));
    expect((cfg['gameFolders'] as List)[0]['path'], p.join(dataDir, '.minecraft'));
    expect((cfg['gameFolders'] as List)[1]['path'], r'D:\Games\.minecraft');
    // 只替换完整的路径段
    expect(cfg['other'], '$legacy-not-a-child');
  });

  test('已经迁移过（旧目录不存在）时什么都不做', () async {
    await Directory(dataDir).create(recursive: true);
    final used = await migrateWindowsLayout(legacy: [legacy], configDir: configDir, dataDir: dataDir);
    expect(used, dataDir);
    expect(Directory(configDir).existsSync(), isFalse);
  });

  test('新位置已有配置时不覆盖', () async {
    await writeLegacy(legacy);
    await Directory(configDir).create(recursive: true);
    await File(p.join(configDir, 'accounts.dat')).writeAsString('newer');
    await migrateWindowsLayout(legacy: [legacy], configDir: configDir, dataDir: dataDir);
    expect(File(p.join(configDir, 'accounts.dat')).readAsStringSync(), 'newer');
  });

  test('更早的 PCL.PW 目录也能迁移，空的旧父目录一起删掉', () async {
    final old = p.join(roaming, 'PCL.PW', 'PCL.PW');
    await writeLegacy(old);
    final used = await migrateWindowsLayout(legacy: [legacy, old], configDir: configDir, dataDir: dataDir);
    expect(used, dataDir);
    expect(File(p.join(dataDir, 'runtime', 'jre', 'java.exe')).existsSync(), isTrue);
    expect(Directory(p.join(roaming, 'PCL.PW')).existsSync(), isFalse);
  });

  test('数据目录已有内容时逐项合并，同名的保留新目录里的', () async {
    await writeLegacy(legacy);
    await Directory(p.join(dataDir, 'runtime')).create(recursive: true);
    await File(p.join(dataDir, 'runtime', 'keep.txt')).writeAsString('new');
    await Directory(p.join(legacy, 'ai_sessions')).create();
    await migrateWindowsLayout(legacy: [legacy], configDir: configDir, dataDir: dataDir);
    expect(File(p.join(dataDir, 'runtime', 'keep.txt')).existsSync(), isTrue);
    expect(Directory(p.join(dataDir, 'ai_sessions')).existsSync(), isTrue);
  });

  test('从启动器旁边的备份恢复缺失的配置与账户', () async {
    final backup = p.join(root.path, 'App', 'backup');
    await Directory(backup).create(recursive: true);
    await File(p.join(backup, 'config.json')).writeAsString('{"a":1}');
    await File(p.join(backup, 'accounts.dat')).writeAsString('acc');
    await Directory(configDir).create(recursive: true);
    await File(p.join(configDir, 'accounts.dat')).writeAsString('current');

    await restoreConfigBackup(configDir, backup);

    expect(File(p.join(configDir, 'config.json')).readAsStringSync(), '{"a":1}');
    // 已有的文件不被备份覆盖
    expect(File(p.join(configDir, 'accounts.dat')).readAsStringSync(), 'current');
  });
}
