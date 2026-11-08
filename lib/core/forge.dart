import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'download.dart';
import 'extra_loaders.dart';
import 'install.dart';
import 'java_run.dart';
import 'loaders.dart';
import 'paths.dart';
import 'task.dart';
import 'version.dart';

/// Forge 与 NeoForge：用官方安装器安装。
/// 新版安装器支持 --installClient 命令行安装；1.12.2 以前的大部分安装器不支持，
/// 这时从安装器中取出版本信息与主 jar 自行写入（与 HMCL、PCL 的做法相同）。

const _forgeMaven = 'https://maven.minecraftforge.net/net/minecraftforge/forge';
const _neoMaven = 'https://maven.neoforged.net/releases/net/neoforged';
const _neoApi = 'https://maven.neoforged.net/api/maven/versions/releases/net/neoforged';

// ---------- 版本列表 ----------

Map<String, String>? _promos;
List<String>? _forgeAll;

Future<List<LoaderVersion>> forgeVersions(Downloader dl, String gameVersion) async {
  if (_forgeAll == null) {
    final xml = await dl.fetchText('$_forgeMaven/maven-metadata.xml');
    _forgeAll = RegExp(r'<version>([^<]+)</version>').allMatches(xml).map((m) => m.group(1)!).toList();
  }
  try {
    _promos ??=
        ((await dl.fetchJson('https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json')
                    as Map)['promos']
                as Map)
            .map((k, v) => MapEntry('$k', '$v'));
  } catch (_) {
    _promos = {};
  }
  final recommended = _promos!['$gameVersion-recommended'];
  final latest = _promos!['$gameVersion-latest'];
  // maven-metadata 中较新的版本在前；完整版本号形如 1.20.1-47.3.0，老版本末尾还带 -1.7.10
  return [
    for (final full in _forgeAll!)
      if (full.startsWith('$gameVersion-'))
        LoaderVersion(
          full,
          stable: () {
            final build = full.substring(gameVersion.length + 1).split('-').first;
            return build == recommended || (recommended == null && build == latest);
          }(),
          label: full.substring(gameVersion.length + 1),
        ),
  ];
}

/// NeoForge 版本号对应的 Minecraft 版本：21.1.x -> 1.21.1，20.4.x -> 1.20.4，26.3.0.x -> 26.3
String? neoForgeGameVersion(String v) {
  final parts = v.split(RegExp(r'[.-]'));
  final major = int.tryParse(parts[0]);
  if (major == null || major == 0 || parts.length < 3) return null; // 0.x 为快照版本
  if (major >= 26) return parts[2] == '0' ? '${parts[0]}.${parts[1]}' : '${parts[0]}.${parts[1]}.${parts[2]}';
  return parts[1] == '0' ? '1.${parts[0]}' : '1.${parts[0]}.${parts[1]}';
}

Future<List<LoaderVersion>> neoForgeVersions(Downloader dl, String gameVersion) async {
  // 1.20.1 的 NeoForge 发布在 net.neoforged:forge 下，版本号形如 1.20.1-47.1.106
  if (gameVersion == '1.20.1') {
    final list = ((await dl.fetchJson('$_neoApi/forge') as Map)['versions'] as List).cast<String>();
    return [
      for (final v in list.reversed)
        if (v.startsWith('1.20.1-')) LoaderVersion(v, stable: !v.contains('beta'), label: v.substring(7)),
    ];
  }
  final list = ((await dl.fetchJson('$_neoApi/neoforge') as Map)['versions'] as List).cast<String>();
  return [
    for (final v in list.reversed)
      if (neoForgeGameVersion(v) == gameVersion) LoaderVersion(v, stable: !v.contains('beta') && !v.contains('alpha')),
  ];
}

String _installerUrl(LoaderKind kind, String version) => switch (kind) {
  LoaderKind.cleanroom => cleanroomInstallerUrl(version),
  LoaderKind.neoforge when version.startsWith('1.20.1-') => '$_neoMaven/forge/$version/forge-$version-installer.jar',
  LoaderKind.neoforge => '$_neoMaven/neoforge/$version/neoforge-$version-installer.jar',
  _ => '$_forgeMaven/$version/forge-$version-installer.jar',
};

// ---------- 安装 ----------

/// Forge 等安装器要求 launcher_profiles.json 存在
Future<void> ensureLauncherProfiles(String root) async {
  final f = File(p.join(root, 'launcher_profiles.json'));
  if (f.existsSync()) return;
  final now = DateTime.now().toUtc().toIso8601String();
  await f.parent.create(recursive: true);
  await f.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'profiles': {
        'PCL.PW': {
          'icon': 'Grass',
          'name': 'PCL.PW',
          'lastVersionId': 'latest-release',
          'type': 'latest-release',
          'lastUsed': now,
          'created': now,
        },
      },
      'selectedProfile': 'PCL.PW',
      'clientToken': '23323323323323323323323323323333',
    }),
  );
}

Set<String> _versionIds(GamePaths g) {
  final dir = Directory(g.versions);
  if (!dir.existsSync()) return {};
  return dir.listSync().whereType<Directory>().map((d) => p.basename(d.path)).toSet();
}

/// 把版本改名：文件夹、JSON、jar 与 JSON 中的 id 一起改
Future<String> renameVersion(GamePaths g, String from, String to) async {
  if (from == to) return to;
  final name = checkVersionName(g, to);
  await Directory(g.versionDir(from)).rename(g.versionDir(name));
  final dir = g.versionDir(name);
  final json = File(p.join(dir, '$from.json'));
  final v = VersionJson(jsonDecode(await json.readAsString()) as Map<String, dynamic>)..id = name;
  await json.delete();
  await File(p.join(dir, '$name.json')).writeAsString(const JsonEncoder.withIndent('  ').convert(v.raw));
  final jar = File(p.join(dir, '$from.jar'));
  if (jar.existsSync()) await jar.rename(p.join(dir, '$name.jar'));
  return name;
}

/// 复制版本（JSON 与 jar），原版本保留
Future<String> copyVersion(GamePaths g, String from, String to) async {
  final name = checkVersionName(g, to);
  await Directory(g.versionDir(name)).create(recursive: true);
  final v = VersionJson(jsonDecode(await File(g.versionJson(from)).readAsString()) as Map<String, dynamic>)..id = name;
  await File(g.versionJson(name)).writeAsString(const JsonEncoder.withIndent('  ').convert(v.raw));
  final jar = File(g.versionJar(from));
  if (jar.existsSync()) await jar.copy(g.versionJar(name));
  return name;
}

Future<String> installForgeLike(
  GamePaths g,
  LoaderKind kind,
  String gameVersion,
  String version,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  await ensureVanilla(g, gameVersion, dl, task);
  final label = kind.label;

  final component = loaderComponent(kind, gameVersion, version);
  task.beginStep(downloadStep(component));
  task.setStage('下载 $label 安装器');
  final installer = Paths.tempFile('${kind.name}-$version-installer.jar');
  await dl.downloadFile(DownloadItem(url: _installerUrl(kind, version), path: installer.path));
  try {
    final zip = ZipDecoder().decodeBytes(await installer.readAsBytes());
    final profileEntry = zip.findFile('install_profile.json');
    if (profileEntry == null) throw Exception('$label 安装器已损坏：找不到 install_profile.json');
    final profile = jsonDecode(utf8.decode(profileEntry.content)) as Map<String, dynamic>;

    task.beginStep(installStep(component));
    final String id;
    // 安装器将生成的版本名；这个版本已存在时安装器会覆盖它，改名时要复制而不是移走原版本
    String? expectedId;
    var preexisting = false;
    if (profile['versionInfo'] is Map) {
      id = await _installLegacy(g, zip, profile, dl, task, label);
    } else {
      // 安装器自带的版本 JSON 要求更新的 Java 时（例如 Cleanroom 需要 Java 21），按它的要求选择
      final inner = zip.findFile('version.json');
      final innerJson = inner == null ? null : jsonDecode(utf8.decode(inner.content)) as Map<String, dynamic>;
      final innerJava = innerJson?['javaVersion'] as Map<String, dynamic>?;
      expectedId = innerJson?['id'] as String?;
      preexisting = expectedId != null && File(g.versionJson(expectedId)).existsSync();
      // 安装器自己的下载器只连官方源、不重试，慢网络下常常卡在连接超时。
      // 先把依赖库、处理器依赖和 Mojang 映射全部下好，再让安装器离线运行。
      final offline =
          kind != LoaderKind.cleanroom &&
          _installerSupportsOffline(zip) &&
          await _prepareInstallerFiles(g, gameVersion, kind, profile, [innerJson, profile], dl, task, label);
      if (offline) await _patchInstallerProfile(installer.path);
      // Cleanroom 的新版安装器有自己的命令行格式
      final args = kind == LoaderKind.cleanroom
          ? ['client', '--version', version, '-d', g.root, '--no-gui', '-y']
          : ['--installClient', g.root, if (offline) '--offline'];
      id = await _runInstaller(
        g,
        gameVersion,
        installer.path,
        dl,
        task,
        label,
        javaVersion: innerJava,
        args: args,
        expectedId: expectedId,
        offline: offline,
      );
    }
    // NeoForge 1.20.1 的安装器生成的版本名形如 1.20.1-forge-47.1.106，容易与 Forge 混淆
    final wanted =
        name ??
        (kind == LoaderKind.neoforge && id.contains('-forge-') ? id.replaceFirst('-forge-', '-neoforge-') : null);
    final finalId = wanted == null || wanted == id
        ? id
        : preexisting
        ? await copyVersion(g, id, wanted)
        : await renameVersion(g, id, wanted);
    // 独立的版本 JSON（例如 Cleanroom）没有记录原版版本号，补上 clientVersion（HMCL 也使用这个字段）
    final jsonFile = File(g.versionJson(finalId));
    task.registerCleanupPath(g.versionDir(finalId));
    final raw = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
    if (raw['inheritsFrom'] == null && raw['clientVersion'] == null) {
      raw['clientVersion'] = gameVersion;
      await jsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(raw));
    }
    // 补全安装器没有下载的文件（例如资源文件）
    await ensureVersionFiles(g, finalId, dl, task, resourcesDir: () => p.join(g.versionDir(finalId), 'resources'));
    return finalId;
  } finally {
    if (installer.existsSync()) await installer.delete().catchError((_) => installer);
  }
}

/// 先用启动器的下载器下好安装器要用的文件（镜像、重试、多线程）。
/// 全部就绪时返回 true，之后可以让安装器带 --offline 运行；否则交给安装器自己联网重试。
Future<bool> _prepareInstallerFiles(
  GamePaths g,
  String gameVersion,
  LoaderKind kind,
  Map<String, dynamic> profile,
  List<Map<String, dynamic>?> jsons,
  Downloader dl,
  TaskProgress task,
  String label,
) async {
  final items = <String, DownloadItem>{};
  void add(DownloadItem item) {
    final old = items[item.path];
    // 已有带校验值的条目就不要被后来的无校验条目覆盖
    if (old == null || (old.sha1 == null && item.sha1 != null)) items[item.path] = item;
  }

  for (final j in jsons) {
    for (final lib in (j?['libraries'] as List? ?? const []).whereType<Map<String, dynamic>>()) {
      if (!rulesAllow(lib['rules'] as List?)) continue;
      final name = lib['name'] as String?;
      final art = (lib['downloads'] as Map?)?['artifact'] as Map?;
      String? url, path, sha1;
      int? size;
      if (art != null) {
        url = art['url'] as String?;
        path = art['path'] as String? ?? (name == null ? null : mavenPath(name));
        sha1 = art['sha1'] as String?;
        size = (art['size'] as num?)?.toInt();
      } else if (name != null && lib['url'] is String) {
        final base = lib['url'] as String;
        path = mavenPath(name);
        url = '${base.endsWith('/') ? base : '$base/'}$path';
      }
      // 没有下载地址的是安装器自带或在本地生成的文件
      if (url == null || url.isEmpty || path == null) continue;
      add(DownloadItem(url: url, path: p.join(g.libraries, path), sha1: sha1, size: size));
    }
  }

  final processors = (profile['processors'] as List? ?? const []).whereType<Map>().toList();
  // 处理器自己的 jar 与 classpath 有时不在 libraries 列表里
  final mavenRoot = kind == LoaderKind.neoforge
      ? 'https://maven.neoforged.net/releases'
      : 'https://maven.minecraftforge.net';
  for (final pr in processors) {
    final coords = <String>[
      if (pr['jar'] is String) pr['jar'] as String,
      ...(pr['classpath'] as List? ?? const []).whereType<String>(),
    ];
    for (final coord in coords) {
      final path = mavenPath(coord);
      add(DownloadItem(url: '$mavenRoot/$path', path: p.join(g.libraries, path)));
    }
  }

  final vanilla = await resolveVersion(g, gameVersion);
  // 原版 jar 是安装器的输入，缺失时不能离线
  final vanillaJar = File(g.versionJar(vanilla.rootJar));
  if (!vanillaJar.existsSync()) return false;

  if (processors.any(_isMojmapsProcessor)) {
    // 这个处理器不认 --offline，会直连 launchermeta.mojang.com 下载映射
    final coord = _artifactCoord(_dataValue(profile, 'MOJMAPS', 'client'));
    final mappings = (vanilla.raw['downloads'] as Map?)?['client_mappings'] as Map?;
    if (coord == null || mappings == null || mappings['url'] == null) {
      task.output('$label 安装器需要联网下载 Mojang 映射，无法完全离线安装');
      return false;
    }
    add(
      DownloadItem(
        url: '${mappings['url']}',
        path: p.join(g.libraries, mavenPath(coord)),
        sha1: mappings['sha1'] as String?,
        size: (mappings['size'] as num?)?.toInt(),
      ),
    );
  }

  if (items.isEmpty) return true;
  task.setStage('下载 $label 安装器需要的文件');
  try {
    await dl.downloadAll(items.values.toList(), task.progress, cancelled: () => task.cancelled);
  } catch (e) {
    task.output('部分文件没有下载成功，交给安装器重试：$e');
  }
  for (final item in items.values) {
    if (!await Downloader.isComplete(item)) return false;
  }
  return true;
}

/// 安装器的 install_profile.json 中读取某个数据项（形如 `[group:artifact:version:classifier@ext]`）
String? _dataValue(Map<String, dynamic> profile, String key, String side) {
  final v = (profile['data'] as Map?)?[key];
  if (v is Map) return v[side]?.toString();
  return v?.toString();
}

String? _artifactCoord(String? value) {
  final s = value?.trim();
  if (s == null || s.length < 3 || !s.startsWith('[') || !s.endsWith(']')) return null;
  return s.substring(1, s.length - 1);
}

bool _isMojmapsProcessor(Map pr) =>
    (pr['args'] as List? ?? const []).any((a) => '$a'.toUpperCase().contains('DOWNLOAD_MOJMAPS'));

/// 安装器是否支持 --offline（Forge 安装器 2.0 起）
bool _installerSupportsOffline(Archive zip) {
  final cls = zip.files.where((f) => f.name.endsWith('SimpleInstaller.class')).firstOrNull;
  if (cls == null) return false;
  return utf8.decode(cls.content as List<int>, allowMalformed: true).contains('attempt any network calls');
}

/// 去掉负责下载 Mojang 映射的处理器：文件已由启动器下好，而这个处理器不认 --offline。
Future<void> _patchInstallerProfile(String installer) async {
  final file = File(installer);
  final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
  final entry = archive.findFile('install_profile.json');
  if (entry == null) return;
  final profile = jsonDecode(utf8.decode(entry.content as List<int>)) as Map<String, dynamic>;
  final processors = (profile['processors'] as List? ?? const []).whereType<Map>().toList();
  final kept = [
    for (final pr in processors)
      if (!_isMojmapsProcessor(pr)) pr,
  ];
  if (kept.length == processors.length) return;
  profile['processors'] = kept;

  final out = Archive();
  final patched = utf8.encode(jsonEncode(profile));
  for (final f in archive.files) {
    out.addFile(f.name == 'install_profile.json' ? ArchiveFile.bytes(f.name, patched) : f);
  }
  await file.writeAsBytes(ZipEncoder().encode(out), flush: true);
}

/// 新版安装器：命令行安装到当前游戏文件夹，返回新增的版本名
Future<String> _runInstaller(
  GamePaths g,
  String gameVersion,
  String installer,
  Downloader dl,
  TaskProgress task,
  String label, {
  Map<String, dynamic>? javaVersion,
  List<String> args = const [],
  String? expectedId,
  bool offline = false,
}) async {
  await ensureLauncherProfiles(g.root);
  // 安装器的处理器需要与该版本相同或更新的 Java
  final vanilla = await resolveVersion(g, gameVersion);
  final needed = (javaVersion?['majorVersion'] as num?)?.toInt() ?? 0;
  final javaFor = needed > (vanilla.javaMajor ?? 8)
      ? VersionJson({'id': gameVersion, 'javaVersion': javaVersion})
      : vanilla;

  task.setStage(offline ? '运行 $label 安装器（处理文件，可能需要几分钟）' : '运行 $label 安装器（下载依赖并处理文件，可能需要几分钟）');
  final before = _versionIds(g);
  final r = await runJava(
    javaFor,
    ['-jar', installer, ...args],
    workDir: g.root,
    dl: dl,
    task: task,
    onLine: task.output,
  );
  // 安装器会在工作目录留下与安装器同名的 .log
  final installerLog = File(p.join(g.root, '${p.basename(installer)}.log'));
  if (installerLog.existsSync()) await installerLog.delete().catchError((_) => installerLog);
  String tail() => r.output.trim().split('\n').reversed.take(8).toList().reversed.join('\n');
  if (r.code != 0) throw Exception('$label 安装器运行失败（退出代码 ${r.code}）\n${tail()}');
  // 安卓上拿不到 System.exit 的退出代码，安装器报告失败时按输出判断
  if (Platform.isAndroid &&
      RegExp(r'There was an error during installation|Exception in thread "main"').hasMatch(r.output)) {
    throw Exception('$label 安装器运行失败\n${tail()}');
  }
  // 优先用安装器自带的版本名（已安装过同一个版本时，安装器会覆盖它，不新增文件夹）。
  // 不能只看前后新增了哪些文件夹：排队时同时进行的其他安装也会新增版本，会认错版本
  if (expectedId != null && File(g.versionJson(expectedId)).existsSync()) return expectedId;
  final added = _versionIds(g).difference(before);
  final candidates = added.length > 1 ? added.where((id) => id.contains(gameVersion)).toSet() : added;
  if (candidates.length == 1) return candidates.single;
  if (candidates.length > 1) {
    throw Exception('$label 安装器之后出现了多个新版本（${candidates.join('、')}），无法确定是哪一个');
  }
  throw Exception('$label 安装器没有生成新的版本');
}

/// 老版安装器：install_profile.json 中包含 versionInfo（版本 JSON）与 install（主 jar 位置）
Future<String> _installLegacy(
  GamePaths g,
  Archive zip,
  Map<String, dynamic> profile,
  Downloader dl,
  TaskProgress task,
  String label,
) async {
  task.setStage('安装 $label');
  final info = Map<String, dynamic>.from(profile['versionInfo'] as Map);
  final install = profile['install'] as Map<String, dynamic>;
  final id = '${info['id']}';
  checkVersionName(g, id);

  // 主 jar 放进 libraries，对应 install.path 的 Maven 坐标
  final universal = zip.findFile('${install['filePath']}');
  if (universal == null) throw Exception('$label 安装器已损坏：找不到 ${install['filePath']}');
  final target = File(p.join(g.libraries, mavenPath('${install['path']}')));
  await target.parent.create(recursive: true);
  await target.writeAsBytes(universal.content);

  // 老版本库地址仍指向已停用的 files.minecraftforge.net，换成现在的 Maven
  final libs = <Map<String, dynamic>>[];
  for (final lib in (info['libraries'] as List).cast<Map<String, dynamic>>()) {
    if (lib['clientreq'] == false && lib['serverreq'] == true) continue;
    final l = Map<String, dynamic>.from(lib)
      ..remove('clientreq')
      ..remove('serverreq')
      ..remove('checksums');
    final url = l['url'] as String?;
    if (url != null && url.contains('minecraftforge.net')) l['url'] = 'https://maven.minecraftforge.net/';
    // 主 jar 已从安装器中取出，不需要下载
    if (l['name'] == install['path']) {
      l['downloads'] = {
        'artifact': {'path': mavenPath('${install['path']}'), 'url': ''},
      };
    }
    libs.add(l);
  }
  info['libraries'] = libs;
  final v = VersionJson(info);
  await Directory(g.versionDir(id)).create(recursive: true);
  await File(g.versionJson(id)).writeAsString(const JsonEncoder.withIndent('  ').convert(v.raw));
  return id;
}
