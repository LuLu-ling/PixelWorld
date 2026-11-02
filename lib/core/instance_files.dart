import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// 版本运行目录下的资源文件夹
enum InstanceFolder {
  saves('存档'),
  screenshots('截图'),
  mods('模组'),
  resourcepacks('资源包'),
  shaderpacks('光影包'),
  schematics('投影');

  const InstanceFolder(this.label);

  final String label;
}

class InstanceFile {
  InstanceFile({required this.path, required this.size, required this.modified, required this.isDir});

  final String path;
  final int size;
  final DateTime modified;
  final bool isDir;

  String get name => p.basename(path);

  /// 模组被禁用（.disabled 后缀，与 PCL 相同）
  bool get disabled => name.toLowerCase().endsWith('.disabled');
}

final _image = RegExp(r'\.(png|jpe?g|webp)$', caseSensitive: false);

List<InstanceFile> listInstanceFiles(String gameDir, InstanceFolder folder) {
  final dir = Directory(p.join(gameDir, folder.name));
  if (!dir.existsSync()) return [];
  final out = <InstanceFile>[];
  for (final e in dir.listSync()) {
    final isDir = e is Directory;
    if (folder == InstanceFolder.saves && !isDir) continue;
    if (folder == InstanceFolder.screenshots && !_image.hasMatch(e.path)) continue;
    try {
      final s = e.statSync();
      out.add(InstanceFile(path: e.path, size: s.size, modified: s.modified, isDir: isDir));
    } catch (_) {
      // 文件被占用或刚被删除
    }
  }
  return out..sort((a, b) => b.modified.compareTo(a.modified));
}

/// 与 PCL 一样用 .disabled 后缀禁用模组
Future<void> setModEnabled(InstanceFile f, bool enabled) async {
  final target = enabled ? f.path.replaceFirst(RegExp(r'\.disabled$', caseSensitive: false), '') : '${f.path}.disabled';
  if (target != f.path) await File(f.path).rename(target);
}

/// 在系统文件管理器中打开文件夹或文件；文件夹不存在时先创建
Future<void> openInFileManager(String path, {bool create = true}) async {
  if (create && p.extension(path).isEmpty) await Directory(path).create(recursive: true);
  if (Platform.isWindows) {
    await Process.start('explorer.exe', [path]);
  } else if (Platform.isMacOS) {
    await Process.start('open', [path]);
  } else {
    await Process.start('xdg-open', [path]);
  }
}

/// 删除都进回收站，避免误删存档
Future<void> moveToTrash(String path) async {
  if (Platform.isWindows) {
    final kind = FileSystemEntity.isDirectorySync(path) ? 'DeleteDirectory' : 'DeleteFile';
    final escaped = path.replaceAll("'", "''");
    final r = await Process.run('powershell.exe', [
      '-NoProfile',
      '-Command',
      "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::$kind('$escaped', 'OnlyErrorDialogs', 'SendToRecycleBin')",
    ]);
    if (r.exitCode != 0) throw Exception('无法移到回收站：${r.stderr}');
  } else if (Platform.isMacOS) {
    final r = await Process.run('osascript', ['-e', 'tell application "Finder" to delete POSIX file "$path"']);
    if (r.exitCode != 0) throw Exception('无法移到废纸篓');
  } else {
    final r = await Process.run('gio', ['trash', path]);
    if (r.exitCode != 0) throw Exception('无法移到回收站');
  }
}

/// 存档里的世界（用于安装数据包）
List<String> worldsOf(String gameDir) => listInstanceFiles(
  gameDir,
  InstanceFolder.saves,
).where((f) => File(p.join(f.path, 'level.dat')).existsSync()).map((f) => f.name).toList();

// ---------- servers.dat（未压缩的 NBT） ----------

class SavedServer {
  SavedServer(this.name, this.address);

  final String name;
  final String address;
}

Object? _readNbt(Uint8List buf) {
  final data = ByteData.sublistView(buf);
  var pos = 0;
  String str() {
    final n = data.getUint16(pos);
    pos += 2;
    // NBT 字符串是修改版 UTF-8，常见字符与标准 UTF-8 相同
    final s = utf8.decode(buf.sublist(pos, pos + n), allowMalformed: true);
    pos += n;
    return s;
  }

  Object? payload(int type) {
    switch (type) {
      case 1:
        pos += 1;
      case 2:
        pos += 2;
      case 3 || 5:
        pos += 4;
      case 4 || 6:
        pos += 8;
      case 7:
        pos += 4 + data.getInt32(pos);
      case 8:
        return str();
      case 9:
        final t = data.getInt8(pos);
        final n = data.getInt32(pos + 1);
        pos += 5;
        return [for (var i = 0; i < n; i++) payload(t)];
      case 10:
        final o = <String, Object?>{};
        while (true) {
          final t = data.getInt8(pos++);
          if (t == 0) return o;
          final key = str();
          o[key] = payload(t);
        }
      case 11:
        pos += 4 + data.getInt32(pos) * 4;
      case 12:
        pos += 4 + data.getInt32(pos) * 8;
      default:
        throw Exception('未知的 NBT 类型 $type');
    }
    return null;
  }

  final root = data.getInt8(pos++);
  str();
  return payload(root);
}

List<SavedServer> savedServers(String gameDir) {
  final f = File(p.join(gameDir, 'servers.dat'));
  if (!f.existsSync()) return [];
  try {
    final root = _readNbt(f.readAsBytesSync());
    final servers = (root is Map ? root['servers'] : null) as List? ?? const [];
    return [
      for (final s in servers.whereType<Map>())
        if ('${s['ip'] ?? ''}'.isNotEmpty)
          SavedServer('${s['name'] ?? ''}'.isEmpty ? '${s['ip']}' : '${s['name']}', '${s['ip']}'),
    ];
  } catch (_) {
    return [];
  }
}
