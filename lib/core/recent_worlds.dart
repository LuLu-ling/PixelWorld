import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';

/// 一个最近玩过的存档。存档可能位于游戏根目录的 `saves`，也可能位于隔离版本的 `versions/<id>/saves`。
class RecentWorld {
  const RecentWorld({
    required this.name,
    required this.path,
    required this.folderName,
    required this.modified,
    this.versionId,
  });

  final String name;
  final String path;
  final String folderName;
  final DateTime modified;

  /// 隔离版本里的存档会带版本名；根目录的存档为 null
  final String? versionId;
}

DateTime? _cachedAt;
String? _cachedKey;
List<RecentWorld>? _cached;

/// 扫描所有游戏文件夹里的存档，按 level.dat 的修改时间倒序返回。
/// 只读取目录信息，不解析存档内容；结果短时间缓存，避免首页重建时反复扫描。
Future<List<RecentWorld>> recentWorlds(LauncherConfig config, {bool force = false}) async {
  final roots = <({String path, String label})>[];
  final seen = <String>{};
  void addRoot(String path, String label) {
    final normalized = p.normalize(path).toLowerCase();
    if (!seen.add(normalized)) return;
    roots.add((path: path, label: label));
  }

  addRoot(config.gameDir, '当前文件夹');
  for (final folder in config.gameFolders) {
    addRoot(folder.path, folder.name);
  }

  final key = roots.map((e) => '${e.path}\u0000${e.label}').join('\u0001');
  final now = DateTime.now();
  if (!force &&
      _cached != null &&
      _cachedKey == key &&
      _cachedAt != null &&
      now.difference(_cachedAt!) < const Duration(seconds: 3)) {
    return _cached!;
  }

  final result = <RecentWorld>[];
  for (final root in roots) {
    await _scanRoot(root.path, root.label, result);
  }

  result.sort((a, b) => b.modified.compareTo(a.modified));
  final trimmed = result.take(6).toList();
  _cached = trimmed;
  _cachedKey = key;
  _cachedAt = now;
  return trimmed;
}

Future<void> _scanRoot(String root, String label, List<RecentWorld> out) async {
  final game = Directory(root);
  if (!await game.exists()) return;

  await _scanSaves(Directory(p.join(root, 'saves')), label, null, out);

  final versions = Directory(p.join(root, 'versions'));
  if (!await versions.exists()) return;
  List<FileSystemEntity> entries;
  try {
    entries = await versions.list(followLinks: false).toList();
  } catch (_) {
    return;
  }
  for (final entry in entries) {
    if (entry is! Directory) continue;
    final id = p.basename(entry.path);
    if (id.startsWith('.')) continue;
    await _scanSaves(Directory(p.join(entry.path, 'saves')), label, id, out);
  }
}

Future<void> _scanSaves(
  Directory dir,
  String folderName,
  String? versionId,
  List<RecentWorld> out,
) async {
  if (!await dir.exists()) return;
  List<FileSystemEntity> entries;
  try {
    entries = await dir.list(followLinks: false).toList();
  } catch (_) {
    return;
  }
  for (final entry in entries) {
    if (entry is! Directory) continue;
    final level = File(p.join(entry.path, 'level.dat'));
    if (!await level.exists()) continue;
    DateTime modified;
    try {
      modified = (await level.stat()).modified;
    } catch (_) {
      continue;
    }
    out.add(
      RecentWorld(
        name: p.basename(entry.path),
        path: entry.path,
        folderName: folderName,
        modified: modified,
        versionId: versionId,
      ),
    );
  }
}
