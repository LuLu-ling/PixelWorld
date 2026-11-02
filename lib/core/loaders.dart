import 'download.dart';
import 'install.dart';
import 'paths.dart';
import 'task.dart';
import 'version.dart';

/// 可以在原版之上直接安装的加载器
enum LoaderKind {
  fabric('Fabric', 'https://meta.fabricmc.net/v2'),
  quilt('Quilt', 'https://meta.quiltmc.org/v3'),
  legacyfabric('Legacy Fabric', 'https://meta.legacyfabric.net/v2'),
  liteloader('LiteLoader', '');

  const LoaderKind(this.label, this.meta);

  final String label;

  /// Fabric、Quilt、Legacy Fabric 使用相同格式的元数据接口
  final String meta;
}

class LoaderVersion {
  LoaderVersion(this.version, {required this.stable});

  final String version;
  final bool stable;
}

// ---------- LiteLoader ----------

const _liteLoaderManifest = 'http://dl.liteloader.com/versions/versions.json';
const _bmclapi = 'https://bmclapi2.bangbang93.com';

Map<String, dynamic>? _liteCache;

Future<List<Map<String, dynamic>>> _liteLoaderBuilds(Downloader dl, String gameVersion) async {
  if (_liteCache == null) {
    try {
      _liteCache = await dl.fetchJson(_liteLoaderManifest) as Map<String, dynamic>;
    } catch (_) {
      // 官方服务器只有 HTTP 且不稳定，改用 BMCLAPI 的逐版本接口
      try {
        final one = await dl.fetchJson('$_bmclapi/liteloader/list?mcversion=${Uri.encodeComponent(gameVersion)}');
        final build = one is Map ? one['build'] : null;
        return build is Map<String, dynamic> ? [build] : [];
      } catch (_) {
        return [];
      }
    }
  }
  final entry = (_liteCache!['versions'] as Map<String, dynamic>?)?[gameVersion] as Map<String, dynamic>?;
  if (entry == null) return [];
  final builds = <Map<String, dynamic>>[];
  for (final group in ['artefacts', 'snapshots']) {
    final artefacts = (entry[group] as Map?)?['com.mumfrey:liteloader'] as Map<String, dynamic>?;
    if (artefacts == null) continue;
    for (final e in artefacts.entries) {
      if (e.key != 'latest') builds.add(e.value as Map<String, dynamic>);
    }
  }
  return builds;
}

Future<String> _installLiteLoader(
  GamePaths g,
  String gameVersion,
  String version,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  final build = (await _liteLoaderBuilds(dl, gameVersion)).where((b) => b['version'] == version).firstOrNull;
  if (build == null) throw Exception('找不到 LiteLoader $version');
  await ensureVanilla(g, gameVersion, dl, task);
  final parent = await readVersionJson(g, gameVersion);
  if (parent.minecraftArguments == null) throw Exception('LiteLoader 只支持 1.12.2 及更早的版本');

  final liteName = 'com.mumfrey:liteloader:${build['version']}';
  final json = VersionJson({
    'id': '$gameVersion-LiteLoader',
    'inheritsFrom': gameVersion,
    'jar': gameVersion,
    'type': parent.type,
    'releaseTime': parent.releaseTime,
    'time': parent.raw['time'],
    'mainClass': 'net.minecraft.launchwrapper.Launch',
    'minecraftArguments': '${parent.minecraftArguments} --tweakClass ${build['tweakClass']}',
    'libraries': [
      {
        'name': liteName,
        'downloads': {
          'artifact': {
            'path': mavenPath(liteName),
            'url': '$_bmclapi/liteloader/download?version=${Uri.encodeComponent('${build['version']}')}',
          },
        },
      },
      for (final l in (build['libraries'] as List? ?? const []).cast<Map<String, dynamic>>())
        {
          'name': l['name'],
          // launchwrapper 在 Mojang 仓库，ASM 在 Maven Central
          'url': '${l['name']}'.startsWith('net.minecraft:')
              ? 'https://libraries.minecraft.net/'
              : 'https://repo1.maven.org/maven2/',
        },
    ],
  });
  task.setStage('安装 LiteLoader');
  return saveVersionJson(g, json, dl, task, name: name);
}

// ---------- 对外接口 ----------

Future<List<LoaderVersion>> loaderVersions(Downloader dl, LoaderKind kind, String gameVersion) async {
  if (kind == LoaderKind.liteloader) {
    return [
      for (final b in (await _liteLoaderBuilds(dl, gameVersion)).reversed)
        LoaderVersion('${b['version']}', stable: b['stream'] == 'RELEASE'),
    ];
  }
  try {
    final list = await dl.fetchJson('${kind.meta}/versions/loader/${Uri.encodeComponent(gameVersion)}') as List;
    return [
      for (final e in list.cast<Map<String, dynamic>>())
        LoaderVersion(
          '${(e['loader'] as Map)['version']}',
          // Quilt 没有 stable 字段，按版本号判断
          stable:
              ((e['loader'] as Map)['stable'] as bool?) ??
              !RegExp('beta|alpha|pre|rc', caseSensitive: false).hasMatch('${(e['loader'] as Map)['version']}'),
        ),
    ];
  } catch (_) {
    return [];
  }
}

Future<String> installLoader(
  GamePaths g,
  LoaderKind kind,
  String gameVersion,
  String loaderVersion,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  if (kind == LoaderKind.liteloader) return _installLiteLoader(g, gameVersion, loaderVersion, dl, task, name: name);
  await ensureVanilla(g, gameVersion, dl, task);
  task.setStage('获取 ${kind.label} 配置');
  final profile = await dl.fetchJson(
    '${kind.meta}/versions/loader/${Uri.encodeComponent(gameVersion)}/${Uri.encodeComponent(loaderVersion)}/profile/json',
  );
  return saveVersionJson(g, VersionJson(profile as Map<String, dynamic>), dl, task, name: name);
}

/// 默认的版本名称，与各加载器官方安装器一致
String defaultVersionName(LoaderKind? kind, String gameVersion, String loaderVersion) => switch (kind) {
  null => gameVersion,
  LoaderKind.liteloader => '$gameVersion-LiteLoader',
  LoaderKind.quilt => 'quilt-loader-$loaderVersion-$gameVersion',
  _ => 'fabric-loader-$loaderVersion-$gameVersion',
};
