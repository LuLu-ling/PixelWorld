// PCL-CE 迁移的模拟样本：按 PCL-CE 的目录结构构造版本文件夹与 JSON（不是真实的 PCL-CE 数据），
// 检查版本识别、继承合并、游戏 jar 路径、版本隔离与实例设置的读取。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/instance.dart';
import 'package:pcl_pw/core/instance_config.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/version.dart';

void main() {
  late Directory tmp;
  late GamePaths g;

  Map<String, dynamic> lib(String name) => {'name': name};

  void version(String folder, Map<String, dynamic> json, {bool jar = false}) {
    final dir = Directory(g.versionDir(folder))..createSync(recursive: true);
    File(p.join(dir.path, '$folder.json')).writeAsStringSync(jsonEncode(json));
    if (jar) File(p.join(dir.path, '$folder.jar')).writeAsStringSync('jar');
  }

  Map<String, dynamic> vanilla(String id, {String type = 'release', String time = '2023-06-12T00:00:00+00:00'}) => {
    'id': id,
    'type': type,
    'releaseTime': time,
    'mainClass': 'net.minecraft.client.main.Main',
    'assetIndex': {'id': '5'},
    'javaVersion': {'majorVersion': 17, 'component': 'java-runtime-gamma'},
    'downloads': {
      'client': {'url': 'https://example.invalid/client.jar', 'sha1': 'x', 'size': 1},
    },
    'arguments': {
      'game': ['--username', r'${auth_player_name}'],
      'jvm': ['-cp', r'${classpath}'],
    },
    'libraries': [lib('org.lwjgl:lwjgl:3.3.1'), lib('com.google.guava:guava:31.1-jre')],
  };

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pclpw-migrate');
    g = GamePaths(p.join(tmp.path, '.minecraft'));
    version('1.20.1', vanilla('1.20.1'), jar: true);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('原版：识别版本号与加载器', () async {
    final info = await analyzeInstance(g, '1.20.1');
    expect(info.loader, Loader.vanilla);
    expect(info.gameVersion, '1.20.1');
    expect(info.nonRelease, isFalse);
  });

  test('文件夹改名后 JSON id 仍是旧名称：游戏 jar 按文件夹名找，版本号按 JSON 识别', () async {
    version('我的生存', vanilla('1.20.1'), jar: true);
    final v = await resolveVersion(g, '我的生存');
    expect(v.id, '1.20.1');
    expect(v.launchJar, '我的生存');
    expect(v.rootJar, '我的生存');
    expect(File(g.versionJar(v.launchJar)).existsSync(), isTrue);
    expect((await analyzeInstance(g, '我的生存')).gameVersion, '1.20.1');
  });

  test('Fabric：继承原版，合并库与参数，使用自己的 jar 副本', () async {
    version('1.20.1-Fabric 0.15.0', {
      'id': 'fabric-loader-0.15.0-1.20.1', // PCL 改名后可能与文件夹不一致
      'inheritsFrom': '1.20.1',
      'mainClass': 'net.fabricmc.loader.impl.launch.knot.KnotClient',
      'arguments': {
        'game': <Object>[],
        'jvm': ['-DFabricMcEmu= net.minecraft.client.main.Main '],
      },
      'libraries': [lib('net.fabricmc:fabric-loader:0.15.0'), lib('com.google.guava:guava:32.0-jre')],
    });
    final v = await resolveVersion(g, '1.20.1-Fabric 0.15.0');
    expect(v.mainClass, contains('Knot'));
    expect(v.launchJar, '1.20.1-Fabric 0.15.0');
    expect(v.rootJar, '1.20.1');
    expect(v.javaMajor, 17);
    expect(v.assetIndex?['id'], '5');
    // 同一构件只保留子版本的
    final names = v.libraries.map((l) => l['name']).toList();
    expect(names.where((n) => '$n'.startsWith('com.google.guava:guava')), ['com.google.guava:guava:32.0-jre']);
    expect(names, contains('org.lwjgl:lwjgl:3.3.1'));
    expect(v.jvmArguments, containsAll(['-cp', '-DFabricMcEmu= net.minecraft.client.main.Main ']));
    final info = await analyzeInstance(g, '1.20.1-Fabric 0.15.0');
    expect(info.loader, Loader.fabric);
    expect(info.gameVersion, '1.20.1');
  });

  test('Forge + OptiFine：识别两个组件', () async {
    version('1.20.1-Forge_47.2.0-OptiFine_I6', {
      'id': '1.20.1-forge-47.2.0',
      'inheritsFrom': '1.20.1',
      'mainClass': 'cpw.mods.bootstraplauncher.BootstrapLauncher',
      'arguments': {
        'game': ['--launchTarget', 'forgeclient'],
        'jvm': [r'-DignoreList=${version_name}.jar'],
      },
      'libraries': [lib('net.minecraftforge:fmlloader:1.20.1-47.2.0'), lib('optifine:OptiFine:1.20.1_HD_U_I6')],
    });
    final info = await analyzeInstance(g, '1.20.1-Forge_47.2.0-OptiFine_I6');
    expect(info.loader, Loader.forge);
    expect(info.optifine, isTrue);
    expect(info.modable, isTrue);
  });

  test('NeoForge：识别加载器', () async {
    version('1.20.4-NeoForge', {
      'id': 'neoforge-20.4.200',
      'inheritsFrom': '1.20.1',
      'mainClass': 'cpw.mods.bootstraplauncher.BootstrapLauncher',
      'libraries': [lib('net.neoforged.fancymodloader:loader:2.0.0')],
    });
    expect((await analyzeInstance(g, '1.20.4-NeoForge')).loader, Loader.neoforge);
  });

  test('旧版 Forge（minecraftArguments）：子版本的参数替换父版本', () async {
    final old = vanilla('1.12.2')
      ..remove('arguments')
      ..['minecraftArguments'] = r'--username ${auth_player_name}';
    version('1.12.2', old, jar: true);
    version('1.12.2-Forge', {
      'id': '1.12.2-forge-14.23.5.2860',
      'inheritsFrom': '1.12.2',
      'mainClass': 'net.minecraft.launchwrapper.Launch',
      'minecraftArguments':
          r'--username ${auth_player_name} --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker',
      'libraries': [lib('net.minecraftforge:forge:1.12.2-14.23.5.2860')],
    });
    final v = await resolveVersion(g, '1.12.2-Forge');
    expect(v.minecraftArguments, contains('FMLTweaker'));
    expect(v.arguments, isNull);
    expect((await analyzeInstance(g, '1.12.2-Forge')).loader, Loader.forge);
  });

  test('多层继承（OptiFine 独立版本继承改过名的原版）', () async {
    version('原版改名', vanilla('1.20.1'), jar: true);
    version('OptiFine 独立', {
      'id': '1.20.1-OptiFine_HD_U_I6',
      'inheritsFrom': '原版改名',
      'mainClass': 'net.minecraft.launchwrapper.Launch',
      'libraries': [lib('optifine:OptiFine:1.20.1_HD_U_I6'), lib('net.minecraft:launchwrapper:1.12')],
    });
    final v = await resolveVersion(g, 'OptiFine 独立');
    expect(v.rootJar, '原版改名');
    expect(v.launchJar, 'OptiFine 独立');
    expect((await analyzeInstance(g, 'OptiFine 独立')).gameVersion, '1.20.1');
  });

  test('版本隔离：已有 mods 或存档的版本文件夹按隔离处理', () async {
    version('1.20.1-Fabric', {
      'id': '1.20.1-Fabric',
      'inheritsFrom': '1.20.1',
      'libraries': [lib('net.fabricmc:fabric-loader:0.15.0')],
    });
    final fabric = await analyzeInstance(g, '1.20.1-Fabric');
    final vanillaInfo = await analyzeInstance(g, '1.20.1');
    // 全局「关闭」时：没有内容的版本不隔离
    expect(shouldIsolate(g, fabric, 0), isFalse);
    // PCL-CE 默认（隔离可安装模组的版本）
    expect(shouldIsolate(g, fabric, 1), isTrue);
    expect(shouldIsolate(g, vanillaInfo, 1), isFalse);
    // 版本文件夹里已有存档：无论全局设置都视为隔离
    Directory(p.join(g.versionDir('1.20.1'), 'saves', 'world')).createSync(recursive: true);
    expect(shouldIsolate(g, vanillaInfo, 0), isTrue);
  });

  test('读取 PCL-CE 的实例设置（YAML）：隔离、内存与自定义 Java', () async {
    final dir = Directory(p.join(g.versionDir('1.20.1'), 'PCL'))..createSync(recursive: true);
    File(p.join(dir.path, 'config.v1.yml')).writeAsStringSync(
      [
        'VersionArgumentIndieV2: false',
        'VersionRamType: 1',
        'VersionRamCustom: 15',
        r'VersionArgumentJavaSelect: "{\"kind\":\"exist\",\"JavaExePath\":\"C:\\\\Java\\\\bin\\\\javaw.exe\"}"',
      ].join('\n'),
    );
    final s = readInstanceSettings(g.versionDir('1.20.1'));
    expect(s.isolation, isFalse);
    expect(s.memoryMode, 'custom');
    expect(s.memoryTick, 15);
    expect(s.java, isA<JavaExist>().having((j) => j.path, 'path', r'C:\Java\bin\javaw.exe'));
    expect((await analyzeInstance(g, '1.20.1')).isolation, isFalse);
  });

  test('读取旧版 PCL 的实例设置（setup.ini）', () {
    final dir = Directory(p.join(g.versionDir('1.20.1'), 'PCL'))..createSync(recursive: true);
    File(p.join(dir.path, 'setup.ini')).writeAsStringSync('VersionArgumentIndieV2:True\r\nVersionRamType:0\r\n');
    final s = readInstanceSettings(g.versionDir('1.20.1'));
    expect(s.isolation, isTrue);
    expect(s.memoryMode, 'auto');
  });

  test('JSON 损坏或缺失的版本不出现在列表中，其他版本不受影响', () async {
    Directory(g.versionDir('broken')).createSync(recursive: true);
    File(g.versionJson('broken')).writeAsStringSync('{not json');
    Directory(g.versionDir('empty')).createSync(recursive: true);
    final ids = (await installedVersions(g)).map((v) => v.id);
    expect(ids, contains('1.20.1'));
    expect(ids, isNot(contains('broken')));
    expect(ids, isNot(contains('empty')));
  });
}
