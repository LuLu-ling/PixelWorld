import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'download.dart';
import 'paths.dart';
import 'task.dart';
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
        path: g.versionJar(v.jar ?? v.id),
        sha1: client['sha1'] as String?,
        size: (client['size'] as num?)?.toInt(),
      ),
    );
  }

  // 依赖库
  for (final lib in resolveLibraries(g, v)) {
    items.add(DownloadItem(url: lib.url, path: lib.path, sha1: lib.sha1, size: lib.size));
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
