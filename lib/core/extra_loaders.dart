import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'download.dart';
import 'install.dart';
import 'java_run.dart';
import 'loaders.dart';
import 'paths.dart';
import 'task.dart';
import 'version.dart';

// ---------- OptiFine ----------
//
// 官网下载需要经过广告页，与 HMCL、PCL 一样使用 BMCLAPI 的版本列表与下载地址。
// 独立安装：用 OptiFine 自带的 Patcher 基于原版 jar 生成 OptiFine 库，再通过 launchwrapper 与
// OptiFineTweaker 启动；没有 Patcher 的老版本直接把安装包作为库。

const _bmclapi = 'https://bmclapi2.bangbang93.com';

List<Map<String, dynamic>>? _optifineAll;

Future<List<LoaderVersion>> optiFineVersions(Downloader dl, String gameVersion) async {
  _optifineAll ??= ((await dl.fetchJson('$_bmclapi/optifine/versionList')) as List).cast<Map<String, dynamic>>();
  return [
    for (final v in _optifineAll!.reversed)
      if (v['mcversion'] == gameVersion)
        LoaderVersion(
          '${v['type']}_${v['patch']}',
          stable: !'${v['patch']}'.startsWith('pre'),
          label: '${'${v['type']}'.replaceAll('_', ' ')} ${v['patch']}',
          // 形如「Forge 47.1.0」「Forge #2851」或「Forge N/A」（与 Forge 不兼容）
          requiredForge: '${v['forge'] ?? ''}'.contains('N/A')
              ? null
              : '${v['forge'] ?? ''}'.replaceAll('Forge', '').replaceAll('#', '').trim(),
          fileName: v['filename'] as String?,
        ),
  ];
}

/// 作为模组安装：把 OptiFine 的 jar 原样放进版本运行目录的 mods（与 PCL 相同，由 Forge 等加载器加载）
Future<void> installOptiFineAsMod(
  String gameDir,
  String gameVersion,
  String version,
  Downloader dl,
  TaskProgress task,
) async {
  final component = loaderComponent(LoaderKind.optifine, gameVersion, version);
  task.beginStep(downloadStep(component));
  final cut = version.lastIndexOf('_');
  final entry = (await optiFineVersions(dl, gameVersion)).where((v) => v.version == version).firstOrNull;
  final fileName = entry?.fileName ?? 'OptiFine_${gameVersion}_$version.jar';
  task.setStage('下载 OptiFine');
  final tmp = Paths.tempFile(fileName);
  await dl.downloadFile(
    DownloadItem(
      url: '$_bmclapi/optifine/$gameVersion/${version.substring(0, cut)}/${version.substring(cut + 1)}',
      path: tmp.path,
    ),
  );
  task.beginStep(installStep(component));
  task.setStage('放入 mods 文件夹');
  final target = File(p.join(gameDir, 'mods', fileName));
  await target.parent.create(recursive: true);
  await tmp.copy(target.path);
  await tmp.delete();
  task.output('已放入 ${target.path}');
}

Future<String> installOptiFine(
  GamePaths g,
  String gameVersion,
  String version,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  await ensureVanilla(g, gameVersion, dl, task);
  final component = loaderComponent(LoaderKind.optifine, gameVersion, version);
  task.beginStep(downloadStep(component));

  // version 形如 HD_U_I6；BMCLAPI 的下载地址把 type 与 patch 分开
  final cut = version.lastIndexOf('_');
  final type = version.substring(0, cut);
  final patch = version.substring(cut + 1);
  task.setStage('下载 OptiFine 安装包');
  final installer = Paths.tempFile('optifine-$gameVersion-$version.jar');
  await dl.downloadFile(DownloadItem(url: '$_bmclapi/optifine/$gameVersion/$type/$patch', path: installer.path));

  task.beginStep(installStep(component));
  try {
    final zip = ZipDecoder().decodeBytes(await installer.readAsBytes());
    final id = name ?? '$gameVersion-OptiFine_$version';
    checkVersionName(g, id);

    // OptiFine 库：libraries/optifine/OptiFine/<mc>_<version>/OptiFine-<mc>_<version>.jar
    final libVersion = '${gameVersion}_$version';
    final libName = 'optifine:OptiFine:$libVersion';
    final libFile = File(p.join(g.libraries, mavenPath(libName)));
    await libFile.parent.create(recursive: true);
    if (zip.findFile('optifine/Patcher.class') != null) {
      task.setStage('生成 OptiFine 库');
      final vanilla = await resolveVersion(g, gameVersion);
      if (libFile.existsSync()) await libFile.delete();
      final r = await runJava(
        vanilla,
        ['-cp', installer.path, 'optifine.Patcher', g.versionJar(gameVersion), installer.path, libFile.path],
        workDir: g.root,
        dl: dl,
        task: task,
        onLine: task.output,
      );
      if (r.code != 0 || !libFile.existsSync() || libFile.lengthSync() == 0) {
        final tail = r.output.trim().split('\n').reversed.take(6).toList().reversed.join('\n');
        if (libFile.existsSync()) await libFile.delete();
        throw Exception('OptiFine Patcher 运行失败（退出代码 ${r.code}）\n$tail');
      }
    } else {
      await installer.copy(libFile.path);
    }

    // launchwrapper：新版 OptiFine 自带改过的 launchwrapper-of，旧版用 Mojang 的 launchwrapper
    final libraries = <Map<String, dynamic>>[
      {
        'name': libName,
        'downloads': {
          'artifact': {'path': mavenPath(libName), 'url': ''},
        },
      },
    ];
    final ofTxt = zip.findFile('launchwrapper-of.txt');
    if (ofTxt != null) {
      final lwVersion = utf8.decode(ofTxt.content).trim();
      final lwJar = zip.findFile('launchwrapper-of-$lwVersion.jar');
      if (lwJar == null) throw Exception('OptiFine 安装包已损坏：找不到 launchwrapper-of-$lwVersion.jar');
      final lwName = 'optifine:launchwrapper-of:$lwVersion';
      final lwFile = File(p.join(g.libraries, mavenPath(lwName)));
      await lwFile.parent.create(recursive: true);
      await lwFile.writeAsBytes(lwJar.content);
      libraries.add({
        'name': lwName,
        'downloads': {
          'artifact': {'path': mavenPath(lwName), 'url': ''},
        },
      });
    } else {
      libraries.add({'name': 'net.minecraft:launchwrapper:1.12'});
    }

    final vanilla = await readVersionJson(g, gameVersion);
    const tweak = ['--tweakClass', 'optifine.OptiFineTweaker'];
    final json = VersionJson({
      'id': id,
      'inheritsFrom': gameVersion,
      'type': vanilla.type,
      'releaseTime': vanilla.releaseTime,
      'time': vanilla.raw['time'],
      'mainClass': 'net.minecraft.launchwrapper.Launch',
      'libraries': libraries,
      if (vanilla.minecraftArguments != null)
        'minecraftArguments': '${vanilla.minecraftArguments} ${tweak.join(' ')}'
      else
        'arguments': {'game': tweak},
    });
    await Directory(g.versionDir(id)).create(recursive: true);
    await File(g.versionJson(id)).writeAsString(const JsonEncoder.withIndent('  ').convert(json.raw));
    await ensureVersionFiles(g, id, dl, task, resourcesDir: () => p.join(g.versionDir(id), 'resources'));
    return id;
  } finally {
    if (installer.existsSync()) await installer.delete().catchError((_) => installer);
  }
}

// ---------- Cleanroom ----------
//
// 只支持 1.12.2。版本列表与安装器来自 Cleanroom 自己的 Maven 仓库（GitHub API 未登录时有频率限制），
// 安装流程与 Forge 相同（见 forge.dart）。

const _cleanroomMaven = 'https://repo.cleanroommc.com/releases/com/cleanroommc/cleanroom';

List<LoaderVersion>? _cleanroomAll;

Future<List<LoaderVersion>> cleanroomVersions(Downloader dl, String gameVersion) async {
  if (gameVersion != '1.12.2') return [];
  if (_cleanroomAll == null) {
    final xml = await dl.fetchText('$_cleanroomMaven/maven-metadata.xml');
    final versions = RegExp(r'<version>([^<]+)</version>').allMatches(xml).map((m) => m.group(1)!).toList();
    // maven-metadata 中较旧的版本在前；Cleanroom 目前都是 alpha，最新的一个视为推荐版本
    _cleanroomAll = [
      for (var i = versions.length - 1; i >= 0; i--) LoaderVersion(versions[i], stable: i == versions.length - 1),
    ];
  }
  return _cleanroomAll!;
}

String cleanroomInstallerUrl(String version) => '$_cleanroomMaven/$version/cleanroom-$version-installer.jar';

// ---------- LabyMod 4 ----------
//
// 版本清单来自 LabyMod 的发布服务器：每个游戏版本有一份完整的版本 JSON，
// 再加上 LabyMod 的依赖库与核心 jar（规则参考 PCL-CE 的 MergeJsonLabyMod）。

const _laby = 'https://releases.r2.labymod.net/api/v1';

Future<List<LoaderVersion>> labyModVersions(Downloader dl, String gameVersion) async {
  final out = <LoaderVersion>[];
  for (final channel in ['production', 'snapshot']) {
    try {
      final m = await dl.fetchJson('$_laby/manifest/$channel/latest.json') as Map<String, dynamic>;
      final supported = ((m['minecraftVersions'] as List?) ?? const []).cast<Map<String, dynamic>>().any(
        (v) => v['version'] == gameVersion,
      );
      if (!supported) continue;
      out.add(
        LoaderVersion(
          '$channel:${m['commitReference']}:${m['labyModVersion']}',
          stable: channel == 'production',
          label: '4.${m['labyModVersion']}（${channel == 'production' ? '正式版' : '快照'}）',
        ),
      );
    } catch (_) {
      // 某个频道获取失败时只显示另一个
    }
  }
  return out;
}

Future<String> installLabyMod(
  GamePaths g,
  String gameVersion,
  String version,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  final [channel, commit, labyVersion] = version.split(':');
  final component = loaderComponent(LoaderKind.labymod, gameVersion, version);
  task.beginStep(downloadStep(component));
  task.setStage('获取 LabyMod 版本清单');
  final manifest = await dl.fetchJson(
    '$_laby/download/manifest/labymod4/$channel/$gameVersion/$commit.json',
  ) as Map<String, dynamic>;
  final libs = await dl.fetchJson('$_laby/libraries/$channel.json') as Map<String, dynamic>;
  final core = await dl.fetchJson('$_laby/manifest/$channel/latest.json') as Map<String, dynamic>;

  // LabyMod 自带的 LWJGL 原生库会替换原版的同名库
  final isolated = {
    for (final l in ((libs['isolated_libraries'] as List?) ?? const []).cast<Map<String, dynamic>>())
      if (((l['versions'] as List?) ?? const []).contains(gameVersion)) '${l['name']}',
  };
  final lwjgl = RegExp(r'^org\.lwjgl:(lwjgl[a-z0-9._-]*):[^:]+:[^:]+');
  final libraries = <Map<String, dynamic>>[
    for (final l in ((manifest['libraries'] as List?) ?? const []).cast<Map<String, dynamic>>())
      if (!isolated.contains(lwjgl.firstMatch('${l['name']}')?.group(1))) l,
    for (final l in ((libs['libraries'] as List?) ?? const []).cast<Map<String, dynamic>>())
      if (l['minecraftVersion'] == null || l['minecraftVersion'] == 'all' || l['minecraftVersion'] == gameVersion)
        {
          'name': l['name'],
          'downloads': {
            'artifact': {
              'path': '${l['url']}'.split('/libraries/').last,
              'sha1': l['sha1'],
              'size': l['size'],
              'url': l['url'],
            },
          },
        },
    {
      'name': 'net.labymod:LabyMod:4',
      'downloads': {
        'artifact': {
          'path': 'net/labymod/LabyMod/4/LabyMod-4.jar',
          'sha1': core['sha1'],
          'size': core['size'],
          'url': '$_laby/download/labymod4/$channel/${core['commitReference']}.jar',
        },
      },
    },
  ];

  final id = name ?? '$gameVersion-LabyMod-4.$labyVersion';
  checkVersionName(g, id);
  final json = Map<String, dynamic>.from(manifest)
    ..['id'] = id
    ..['libraries'] = libraries
    ..['labymod_data'] = {
      'channelType': channel,
      'commitReference': core['commitReference'],
      'version': core['labyModVersion'],
      'versionType': 'release',
    };
  // 下载与安装：写入版本 JSON 后补全文件
  await Directory(g.versionDir(id)).create(recursive: true);
  await File(g.versionJson(id)).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  await ensureVersionFiles(g, id, dl, task, resourcesDir: () => p.join(g.versionDir(id), 'resources'));
  task.beginStep(installStep(component));
  return id;
}
