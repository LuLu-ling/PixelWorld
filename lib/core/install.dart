import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'download.dart';
import 'paths.dart';
import 'task.dart';
import 'instance.dart';
import 'version.dart';

/// 补全版本运行所需的文件（客户端、依赖库、日志配置、资源），启动前调用。
/// [resourcesDir] 是旧版本按原文件名展开资源的目录（map_to_resources），即实际运行目录下的 resources。
Future<VersionJson> ensureVersionFiles(
  GamePaths g,
  String id,
  Downloader dl,
  TaskProgress task, {
  required String Function() resourcesDir,
}) async {
  final v = await resolveVersion(g, id);
  final items = <DownloadItem>[];

  // 客户端 jar
  final client = v.clientDownload;
  if (client != null) {
    items.add(
      DownloadItem(
        url: '${client['url']}',
        path: g.versionJar(v.rootJar),
        sha1: client['sha1'] as String?,
        size: (client['size'] as num?)?.toInt(),
      ),
    );
  }

  // 依赖库
  final missingLocal = <String>[];
  for (final lib in resolveLibraries(g, v)) {
    if (lib.url.isEmpty) {
      // 由安装器在本地生成的库没有下载地址
      if (!File(lib.path).existsSync()) missingLocal.add(lib.name);
      continue;
    }
    items.add(DownloadItem(url: lib.url, path: lib.path, sha1: lib.sha1, size: lib.size));
  }
  if (missingLocal.isNotEmpty) {
    throw Exception('缺少由安装器生成的文件：${missingLocal.take(3).join('、')}，请重新安装这个版本');
  }

  // 日志配置（修复 Log4Shell）
  final log = v.loggingClient?['file'] as Map<String, dynamic>?;
  if (log != null) {
    items.add(
      DownloadItem(
        url: '${log['url']}',
        path: p.join(g.assets, 'log_configs', '${log['id']}'),
        sha1: log['sha1'] as String?,
        size: (log['size'] as num?)?.toInt(),
      ),
    );
  }

  task.setStage('下载游戏本体与依赖库');
  await dl.downloadAll(items, task.progress);

  // 继承的版本使用自己文件夹里的游戏 jar 副本
  if (v.launchJar != v.rootJar) {
    final own = File(g.versionJar(v.launchJar));
    final root = File(g.versionJar(v.rootJar));
    if (root.existsSync() && (!own.existsSync() || own.lengthSync() != root.lengthSync())) {
      await own.parent.create(recursive: true);
      await root.copy(own.path);
    }
  }

  // 资源文件
  final ai = v.assetIndex;
  if (ai != null) {
    task.setStage('下载资源索引');
    final indexItem = DownloadItem(
      url: '${ai['url']}',
      path: p.join(g.assets, 'indexes', '${ai['id']}.json'),
      sha1: ai['sha1'] as String?,
      size: (ai['size'] as num?)?.toInt(),
    );
    if (!await Downloader.isComplete(indexItem)) await dl.downloadFile(indexItem);
    final index = jsonDecode(await File(indexItem.path).readAsString()) as Map<String, dynamic>;
    final objects = (index['objects'] as Map<String, dynamic>).entries.map((e) {
      final hash = '${(e.value as Map)['hash']}';
      return (
        name: e.key,
        item: DownloadItem(
          url: 'https://resources.download.minecraft.net/${hash.substring(0, 2)}/$hash',
          path: p.join(g.assets, 'objects', hash.substring(0, 2), hash),
          sha1: hash,
          size: ((e.value as Map)['size'] as num?)?.toInt(),
        ),
      );
    }).toList();
    task.setStage('下载资源文件');
    await dl.downloadAll([for (final o in objects) o.item], task.progress);

    // 旧版本资源需要按原文件名展开
    final mapToResources = index['map_to_resources'] == true;
    if (index['virtual'] == true || mapToResources) {
      task.setStage('整理旧版资源');
      final target = mapToResources ? resourcesDir() : p.join(g.assets, 'virtual', '${ai['id']}');
      for (final o in objects) {
        final dest = File(p.join(target, o.name));
        if (dest.existsSync()) continue;
        await dest.parent.create(recursive: true);
        await File(o.item.path).copy(dest.path);
      }
    }
  }
  return v;
}

// ---------- 远程版本列表 ----------

const _manifestUrl = 'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json';

class RemoteVersion {
  RemoteVersion({
    required this.id,
    required this.type,
    required this.url,
    required this.releaseTime,
    required this.fool,
  });

  final String id;

  /// release / snapshot / old_beta / old_alpha
  final String type;
  final String url;
  final String releaseTime;

  /// 愚人节版本
  final bool fool;
}

({DateTime at, List<RemoteVersion> list, String latestRelease, String latestSnapshot})? _manifestCache;

Future<({List<RemoteVersion> list, String latestRelease, String latestSnapshot})> remoteVersions(Downloader dl) async {
  final c = _manifestCache;
  if (c != null && DateTime.now().difference(c.at) < const Duration(minutes: 10)) {
    return (list: c.list, latestRelease: c.latestRelease, latestSnapshot: c.latestSnapshot);
  }
  final data = await dl.fetchJson(_manifestUrl) as Map<String, dynamic>;
  final list = [
    for (final v in (data['versions'] as List).cast<Map<String, dynamic>>())
      RemoteVersion(
        id: '${v['id']}',
        type: '${v['type']}',
        url: '${v['url']}',
        releaseTime: '${v['releaseTime']}',
        fool: isAprilFools('${v['id']}', '${v['releaseTime']}'),
      ),
  ];
  final latest = data['latest'] as Map<String, dynamic>;
  _manifestCache = (
    at: DateTime.now(),
    list: list,
    latestRelease: '${latest['release']}',
    latestSnapshot: '${latest['snapshot']}',
  );
  return (list: list, latestRelease: '${latest['release']}', latestSnapshot: '${latest['snapshot']}');
}

// ---------- 安装 ----------

/// 版本名称用作文件夹名，排除非法字符
String checkVersionName(GamePaths g, String name) {
  final n = name.trim();
  if (n.isEmpty || n.length > 64 || RegExp(r'[\/:*?"<>|]').hasMatch(n) || n == '.' || n == '..') {
    throw Exception(r'版本名称不能为空，且不能包含 \ / : * ? " < > |');
  }
  if (Directory(g.versionDir(n)).existsSync()) throw Exception('已存在名为 $n 的版本');
  return n;
}

/// 写入版本 JSON（可改名）并补全文件，返回最终版本名
Future<String> saveVersionJson(GamePaths g, VersionJson json, Downloader dl, TaskProgress task, {String? name}) async {
  final id = name != null ? checkVersionName(g, name) : json.id;
  json.id = id;
  await Directory(g.versionDir(id)).create(recursive: true);
  await File(g.versionJson(id)).writeAsString(const JsonEncoder.withIndent('  ').convert(json.raw));
  // 新安装的版本还没有决定隔离，map_to_resources 的旧版资源放在版本文件夹下
  await ensureVersionFiles(g, id, dl, task, resourcesDir: () => p.join(g.versionDir(id), 'resources'));
  return id;
}

/// 任务步骤名称：每个组件分为下载与安装两步
String downloadStep(String component) => '下载 $component';
String installStep(String component) => '安装 $component';

Future<String> installVanilla(GamePaths g, String id, Downloader dl, TaskProgress task, {String? name}) async {
  task.beginStep(downloadStep('Minecraft $id'));
  task.setStage('获取版本信息');
  final entry = (await remoteVersions(dl)).list.where((v) => v.id == id).firstOrNull;
  if (entry == null) throw Exception('找不到版本 $id');
  final json = VersionJson(await dl.fetchJson(entry.url) as Map<String, dynamic>);
  final result = await saveVersionJson(g, json, dl, task, name: name != null && name != id ? name : null);
  task.beginStep(installStep('Minecraft $id'));
  return result;
}

/// 确保加载器依赖的原版已安装（以原版版本号命名）
Future<void> ensureVanilla(GamePaths g, String gameVersion, Downloader dl, TaskProgress task) async {
  if (!File(g.versionJson(gameVersion)).existsSync()) await installVanilla(g, gameVersion, dl, task);
}
