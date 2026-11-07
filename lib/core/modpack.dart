import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'download.dart';
import 'instance_config.dart';
import 'install.dart';
import 'loaders.dart';
import 'modrinth.dart';
import 'paths.dart';
import 'safe_path.dart';
import 'task.dart';

/// Modrinth 整合包（.mrpack）里的依赖。
class _PackDependencies {
  _PackDependencies({required this.minecraft, this.loader, this.loaderVersion = ''});

  final String minecraft;
  final LoaderKind? loader;
  final String loaderVersion;

  /// 加载器在安装器中使用的完整版本号
  String get fullLoaderVersion => switch (loader) {
    LoaderKind.forge => loaderVersion.startsWith('$minecraft-') ? loaderVersion : '$minecraft-$loaderVersion',
    LoaderKind.neoforge when minecraft == '1.20.1' =>
      loaderVersion.startsWith('1.20.1-') ? loaderVersion : '1.20.1-$loaderVersion',
    _ => loaderVersion,
  };
}

/// 解析整合包依赖。Modrinth 的键名见 https://support.modrinth.com/en/articles/8802351
_PackDependencies _parseDependencies(Map<String, dynamic> index) {
  final deps = (index['dependencies'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
  final minecraft = '${deps['minecraft'] ?? ''}'.trim();
  if (minecraft.isEmpty) throw Exception('整合包没有标明 Minecraft 版本');
  for (final (key, kind) in const [
    ('fabric-loader', LoaderKind.fabric),
    ('quilt-loader', LoaderKind.quilt),
    ('forge', LoaderKind.forge),
    ('neoforge', LoaderKind.neoforge),
    ('liteloader', LoaderKind.liteloader),
  ]) {
    final v = '${deps[key] ?? ''}'.trim();
    if (v.isNotEmpty) return _PackDependencies(minecraft: minecraft, loader: kind, loaderVersion: v);
  }
  return _PackDependencies(minecraft: minecraft);
}

/// 目标版本名：去掉文件名非法字符，过长时截断；重名时追加序号。
String _uniqueVersionName(GamePaths g, String wanted, String fallback) {
  var base = wanted.trim().replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '-').replaceAll(RegExp(r'\s+'), ' ');
  if (base.isEmpty) base = fallback;
  if (base.length > 60) base = base.substring(0, 60).trim();
  if (base.isEmpty || base == '.' || base == '..') base = '整合包';

  var name = base;
  for (var i = 2; Directory(g.versionDir(name)).existsSync(); i++) {
    name = '$base ($i)';
  }
  return name;
}

/// 从 Modrinth 下载并安装整合包，返回新版本的名称。
Future<String> installModpackFiles(
  GamePaths g,
  ResourceVersion version,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) async {
  task.beginStep('下载整合包');
  task.setStage('下载整合包');
  final pack = Paths.tempFile('modpack-${version.id}.mrpack');
  try {
    await dl.downloadFile(
      DownloadItem(
        url: version.fileUrl,
        path: pack.path,
        sha1: version.fileSha1,
        size: version.fileSize > 0 ? version.fileSize : null,
      ),
    );
    return await _installArchive(g, pack.path, dl, task, name: name, fallbackName: version.name);
  } finally {
    if (pack.existsSync()) await pack.delete().catchError((_) => pack);
  }
}

/// 安装本地的 .mrpack 文件，返回新版本的名称。
Future<String> installModpackArchive(
  GamePaths g,
  String archivePath,
  Downloader dl,
  TaskProgress task, {
  String? name,
}) {
  task.beginStep('读取整合包');
  task.setStage('读取整合包');
  return _installArchive(g, archivePath, dl, task, name: name, fallbackName: p.basenameWithoutExtension(archivePath));
}

/// 解压并安装 .mrpack：安装对应的游戏与加载器，再把整合包文件放进隔离的版本目录。
Future<String> _installArchive(
  GamePaths g,
  String archivePath,
  Downloader dl,
  TaskProgress task, {
  required String? name,
  required String fallbackName,
}) async {
  final input = InputFileStream(archivePath);
  try {
    final archive = ZipDecoder().decodeStream(input, verify: true);
    final indexEntry = archive.findFile('modrinth.index.json');
    if (indexEntry == null || !indexEntry.isFile) {
      throw Exception('不是有效的 Modrinth 整合包：缺少 modrinth.index.json');
    }
    final index = jsonDecode(utf8.decode(indexEntry.content)) as Map<String, dynamic>;
    final deps = _parseDependencies(index);

    // 先确定版本名，再安装游戏与加载器
    final packName = _uniqueVersionName(g, name ?? '${index['name'] ?? fallbackName}', '整合包');
    task.beginStep('安装游戏与加载器');
    task.setStage('安装 Minecraft ${deps.minecraft}');
    final String id;
    if (deps.loader == null) {
      id = await installVanilla(g, deps.minecraft, dl, task, name: packName);
    } else {
      id = await installLoader(g, deps.loader!, deps.minecraft, deps.fullLoaderVersion, dl, task, name: packName);
    }

    // 整合包内容放在版本自己的目录里，必须开启版本隔离
    await writeInstanceRaw(g.versionDir(id), {'VersionArgumentIndieV2': true});
    final gameDir = g.versionDir(id);
    await Directory(gameDir).create(recursive: true);

    // 整合包清单里的文件
    final items = <DownloadItem>[];
    var skipped = 0;
    for (final raw in (index['files'] as List? ?? const []).whereType<Map>()) {
      final file = raw.cast<String, dynamic>();
      final env = (file['env'] as Map?)?.cast<String, dynamic>();
      // 客户端不需要的文件（例如仅服务端模组）
      if ('${env?['client'] ?? 'required'}' == 'unsupported') {
        skipped++;
        continue;
      }
      final rel = '${file['path'] ?? ''}';
      final downloads = (file['downloads'] as List? ?? const []).map((e) => '$e').toList();
      if (rel.isEmpty || downloads.isEmpty) {
        skipped++;
        continue;
      }
      final String target;
      try {
        target = resolveInside(gameDir, rel);
      } on UnsafePathException catch (e) {
        throw Exception('整合包包含不安全的路径：${e.message}');
      }
      final hashes = (file['hashes'] as Map?)?.cast<String, dynamic>();
      final size = (file['fileSize'] as num?)?.toInt();
      items.add(
        DownloadItem(
          url: downloads.first,
          path: target,
          sha1: hashes?['sha1'] as String?,
          size: size != null && size > 0 ? size : null,
        ),
      );
    }

    task.beginStep('下载整合包文件');
    task.setStage('下载整合包文件');
    if (items.isEmpty) {
      task.progress(0, 0);
    } else {
      await dl.downloadAll(items, task.progress);
    }
    if (skipped > 0) task.output('跳过 $skipped 个不需要的文件');

    // overrides 与 client-overrides 解压到版本目录。
    // client-overrides 后解压，遇到同名文件时覆盖 overrides。
    task.beginStep('解压整合包配置');
    task.setStage('解压整合包配置');
    var extracted = 0;
    for (final prefix in const ['overrides/', 'client-overrides/']) {
      for (final f in archive.files) {
        if (!f.isFile) continue;
        final entry = f.name.replaceAll('\\', '/');
        if (!entry.startsWith(prefix)) continue;
        final rel = entry.substring(prefix.length);
        if (rel.isEmpty) continue;
        final String target;
        try {
          target = resolveInside(gameDir, rel);
        } on UnsafePathException catch (e) {
          throw Exception('整合包包含不安全的路径：${e.message}');
        }
        await Directory(p.dirname(target)).create(recursive: true);
        final out = OutputFileStream(target);
        try {
          f.writeContent(out);
        } finally {
          await out.close();
        }
        extracted++;
      }
    }
    task.output('已解压 $extracted 个配置与覆盖文件');
    return id;
  } finally {
    await input.close();
  }
}
