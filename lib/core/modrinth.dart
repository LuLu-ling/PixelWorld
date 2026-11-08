import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_info.dart';
import 'download.dart';
import 'instance.dart';
import 'paths.dart';
import 'task.dart';

const _api = 'https://api.modrinth.com/v2';

enum ResourceType {
  mod('mod', '模组', 'mods'),
  modpack('modpack', '整合包', 'mods'),
  resourcepack('resourcepack', '资源包', 'resourcepacks'),
  shader('shader', '光影包', 'shaderpacks'),
  datapack('datapack', '数据包', 'datapacks');

  const ResourceType(this.tag, this.label, this.folder);

  /// Modrinth 的 project_type
  final String tag;
  final String label;

  /// 安装到运行目录下的哪个文件夹
  final String folder;
}

class ResourceHit {
  ResourceHit({
    required this.id,
    required this.slug,
    required this.type,
    required this.title,
    required this.description,
    required this.author,
    required this.icon,
    required this.downloads,
    required this.follows,
    required this.updated,
    required this.categories,
  });

  final String id;
  final String slug;
  final ResourceType type;
  final String title;
  final String description;
  final String author;
  final String? icon;
  final int downloads;
  final int follows;
  final String updated;
  final List<String> categories;

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'type': type.tag,
    'title': title,
    'description': description,
    'author': author,
    'icon': icon,
    'downloads': downloads,
    'follows': follows,
    'updated': updated,
    'categories': categories,
  };

  static ResourceHit fromJson(Map<String, dynamic> j) => ResourceHit(
    id: '${j['id']}',
    slug: '${j['slug']}',
    type: ResourceType.values.firstWhere((t) => t.tag == j['type'], orElse: () => ResourceType.mod),
    title: '${j['title']}',
    description: '${j['description'] ?? ''}',
    author: '${j['author'] ?? ''}',
    icon: j['icon'] as String?,
    downloads: (j['downloads'] as num?)?.toInt() ?? 0,
    follows: (j['follows'] as num?)?.toInt() ?? 0,
    updated: '${j['updated'] ?? ''}',
    categories: ((j['categories'] as List?) ?? const []).map((e) => '$e').toList(),
  );
}

class ResourceProject {
  ResourceProject({required this.hit, required this.body, required this.page, required this.gameVersions});

  final ResourceHit hit;

  /// Markdown 介绍
  final String body;
  final String page;
  final List<String> gameVersions;
}

class ResourceVersion {
  ResourceVersion(this.raw);

  final Map<String, dynamic> raw;

  String get id => '${raw['id']}';
  String get projectId => '${raw['project_id']}';
  String get name => '${raw['name']}';
  String get versionNumber => '${raw['version_number']}';

  /// release / beta / alpha
  String get type => '${raw['version_type']}';
  List<String> get gameVersions => ((raw['game_versions'] as List?) ?? const []).map((e) => '$e').toList();
  List<String> get loaders => ((raw['loaders'] as List?) ?? const []).map((e) => '$e').toList();
  String get published => '${raw['date_published']}';
  int get downloads => (raw['downloads'] as num?)?.toInt() ?? 0;

  Map<String, dynamic>? get _file {
    final files = ((raw['files'] as List?) ?? const []).cast<Map<String, dynamic>>();
    return files.where((f) => f['primary'] == true).firstOrNull ?? files.firstOrNull;
  }

  bool get hasFile => _file != null;
  String get fileName => '${_file!['filename']}';
  String get fileUrl => '${_file!['url']}';
  int get fileSize => (_file!['size'] as num?)?.toInt() ?? 0;
  String? get fileSha1 => (_file!['hashes'] as Map?)?['sha1'] as String?;

  /// 必需的前置（项目 ID）
  List<String> get requires => [
    for (final d in ((raw['dependencies'] as List?) ?? const []).cast<Map<String, dynamic>>())
      if (d['dependency_type'] == 'required' && d['project_id'] != null) '${d['project_id']}',
  ];
}

/// 实例的加载器 -> 可用的 Modrinth 加载器标签
List<String> modrinthLoaders(Loader loader) => switch (loader) {
  Loader.fabric => ['fabric'],
  Loader.quilt => ['quilt', 'fabric'],
  Loader.legacyfabric => ['legacy-fabric'],
  Loader.forge || Loader.cleanroom => ['forge'],
  Loader.neoforge => ['neoforge'],
  Loader.liteloader => ['liteloader'],
  _ => [],
};

class InstallResult {
  InstallResult(this.installed, this.skipped, this.missing);

  final List<String> installed;
  final List<String> skipped;

  /// 找不到兼容版本的前置
  final List<String> missing;
}

/// Modrinth API。Modrinth 要求 User-Agent 能识别出应用
class Modrinth {
  static final _client = HttpClient()
    ..userAgent = 'zhuzhi-09/PixelWorld/${AppInfo.version} (github.com/zhuzhi-09/PixelWorld)'
    ..connectionTimeout = const Duration(seconds: 20);

  static Future<dynamic> _get(String path) async {
    Object? lastErr;
    for (var i = 0; i < 3; i++) {
      try {
        final res = await (await _client.getUrl(Uri.parse('$_api$path'))).close().timeout(const Duration(seconds: 20));
        final body = await res.transform(utf8.decoder).join();
        if (res.statusCode == 404) throw const _NotFound();
        if (res.statusCode == 429) throw Exception('请求过于频繁，请稍后再试');
        if (res.statusCode != 200) throw Exception('Modrinth 请求失败（${res.statusCode}）');
        return jsonDecode(body);
      } on _NotFound {
        throw Exception('Modrinth 上找不到该资源');
      } catch (e) {
        lastErr = e;
        await Future<void>.delayed(Duration(milliseconds: 400 * (i + 1)));
      }
    }
    throw lastErr!;
  }

  static String _qs(Map<String, Object?> o) => Uri(
    queryParameters: {
      for (final e in o.entries)
        if (e.value != null && '${e.value}'.isNotEmpty) e.key: '${e.value}',
    },
  ).query;

  /// 搜索。sort：relevance / downloads / follows / newest / updated
  static Future<({List<ResourceHit> hits, int total})> search({
    required ResourceType type,
    String query = '',
    String? gameVersion,
    String? loader,
    String sort = 'relevance',
    int offset = 0,
  }) async {
    final facets = [
      ['project_type:${type.tag}'],
      if (gameVersion != null) ['versions:$gameVersion'],
      if (loader != null) ['categories:$loader'],
    ];
    final data = await _get(
      '/search?${_qs({'query': query, 'facets': jsonEncode(facets), 'index': sort, 'offset': offset, 'limit': 20})}',
    ) as Map<String, dynamic>;
    final hits = [
      for (final h in (data['hits'] as List).cast<Map<String, dynamic>>())
        ResourceHit(
          id: '${h['project_id']}',
          slug: '${h['slug']}',
          type: type,
          title: '${h['title']}',
          description: '${h['description'] ?? ''}',
          author: '${h['author'] ?? ''}',
          icon: (h['icon_url'] as String?)?.isNotEmpty == true ? h['icon_url'] as String : null,
          downloads: (h['downloads'] as num?)?.toInt() ?? 0,
          follows: (h['follows'] as num?)?.toInt() ?? 0,
          updated: '${h['date_modified'] ?? ''}',
          categories: ((h['display_categories'] ?? h['categories']) as List? ?? const []).map((e) => '$e').toList(),
        ),
    ];
    return (hits: hits, total: (data['total_hits'] as num?)?.toInt() ?? hits.length);
  }

  static Future<ResourceProject> project(String id, ResourceType type) async {
    final p = await _get('/project/${Uri.encodeComponent(id)}') as Map<String, dynamic>;
    var author = '';
    try {
      final members = (await _get('/team/${p['team']}/members') as List).cast<Map<String, dynamic>>();
      final owner = members.where((m) => m['role'] == 'Owner').firstOrNull ?? members.firstOrNull;
      author = '${(owner?['user'] as Map?)?['username'] ?? ''}';
    } catch (_) {
      // 作者信息不影响显示
    }
    return ResourceProject(
      hit: ResourceHit(
        id: '${p['id']}',
        slug: '${p['slug']}',
        type: type,
        title: '${p['title']}',
        description: '${p['description'] ?? ''}',
        author: author,
        icon: (p['icon_url'] as String?)?.isNotEmpty == true ? p['icon_url'] as String : null,
        downloads: (p['downloads'] as num?)?.toInt() ?? 0,
        follows: (p['followers'] as num?)?.toInt() ?? 0,
        updated: '${p['updated'] ?? ''}',
        categories: ((p['categories'] as List?) ?? const []).map((e) => '$e').toList(),
      ),
      body: '${p['body'] ?? ''}',
      page: 'https://modrinth.com/${p['project_type']}/${p['slug']}',
      gameVersions: ((p['game_versions'] as List?) ?? const []).map((e) => '$e').toList(),
    );
  }

  static Future<List<ResourceVersion>> versions(String id, {String? gameVersion, List<String>? loaders}) async {
    final list = await _get(
      '/project/${Uri.encodeComponent(id)}/version?${_qs({
        'game_versions': gameVersion == null ? null : jsonEncode([gameVersion]),
        'loaders': loaders == null || loaders.isEmpty ? null : jsonEncode(loaders),
      })}',
    ) as List;
    return list.cast<Map<String, dynamic>>().map(ResourceVersion.new).where((v) => v.hasFile).toList();
  }

  /// 安装到实例的运行目录；模组会一并安装必需的前置
  static Future<InstallResult> install({
    required ResourceVersion version,
    required ResourceType type,
    required InstanceInfo instance,
    required String gameDir,
    String? world,
    required Downloader dl,
    required TaskProgress task,
  }) async {
    if (type == ResourceType.modpack) throw Exception('整合包安装将在后续版本提供');
    final String dir;
    if (type == ResourceType.datapack) {
      if (world == null) throw Exception('请选择要安装数据包的世界');
      dir = p.join(gameDir, 'saves', world, 'datapacks');
    } else {
      dir = p.join(gameDir, type.folder);
    }
    await Directory(dir).create(recursive: true);
    final existing = Directory(dir).listSync().map((e) => p.basename(e.path)).toSet();

    final files = [version];
    final missing = <String>[];
    if (type == ResourceType.mod) {
      task.beginStep('解析前置');
      final loaders = modrinthLoaders(instance.loader);
      final seen = {version.projectId};
      final queue = [...version.requires];
      while (queue.isNotEmpty) {
        final pid = queue.removeAt(0);
        if (!seen.add(pid)) continue;
        task.setStage('解析前置（${seen.length - 1}）');
        final candidates = await versions(
          pid,
          gameVersion: instance.gameVersion,
          loaders: loaders,
        ).catchError((_) => <ResourceVersion>[]);
        final best = candidates.where((v) => v.type == 'release').firstOrNull ?? candidates.firstOrNull;
        if (best == null) {
          missing.add(await _get('/project/$pid').then((p) => '${(p as Map)['title']}').catchError((_) => pid));
          continue;
        }
        files.add(best);
        queue.addAll(best.requires);
      }
    }

    final installed = <String>[];
    final skipped = <String>[];
    final items = <DownloadItem>[];
    for (final v in files) {
      // 已禁用的同名模组也算已存在
      if (existing.contains(v.fileName) || existing.contains('${v.fileName}.disabled')) {
        skipped.add(v.fileName);
        continue;
      }
      items.add(DownloadItem(url: v.fileUrl, path: p.join(dir, v.fileName), sha1: v.fileSha1, size: v.fileSize));
      installed.add(v.fileName);
    }
    task.beginStep('下载文件');
    task.setStage('下载文件');
    await dl.downloadAll(items, task.progress);
    return InstallResult(installed, skipped, missing);
  }
}

class _NotFound implements Exception {
  const _NotFound();
}

/// 资源收藏夹，保存在应用数据目录的 favorites.json
class Favorites {
  static File get _file => File(p.join(Paths.appData, 'favorites.json'));

  static List<ResourceHit> load() {
    try {
      return (jsonDecode(_file.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>()
          .map(ResourceHit.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<ResourceHit> list) =>
      _file.writeAsString(const JsonEncoder.withIndent('  ').convert([for (final h in list) h.toJson()]));
}
