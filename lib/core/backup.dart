// 启动器创建的备份文件格式：AI 修改游戏文件前的备份，以及恢复前的检查与解压

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'safe_path.dart';

// zip 中的 pclpw-backup.json 记录备份的路径；第 2 版起还记录每个文件的大小与 SHA-256，
// 并用保存在启动器数据目录的密钥做 HMAC 签名，恢复时据此确认备份由本机的 Pixel World 创建且未被修改。

const backupManifestName = 'pclpw-backup.json';

/// 读取或生成备份签名密钥
List<int> backupKey(String appData) {
  final f = File(p.join(appData, 'backup.key'));
  if (f.existsSync()) {
    final b = f.readAsBytesSync();
    if (b.length >= 32) return b;
  }
  final r = Random.secure();
  final key = List.generate(32, (_) => r.nextInt(256));
  f.parent.createSync(recursive: true);
  f.writeAsBytesSync(key, flush: true);
  return key;
}

String _mac(List<int> key, Map<String, dynamic> body) =>
    Hmac(sha256, key).convert(utf8.encode(jsonEncode(body))).toString();

/// 去掉重复的路径和被其他路径包含的路径（例如同时有 mods 与 mods/a.jar 时只保留 mods）
List<String> normalizePathSet(List<String> rels) {
  final list = {for (final r in rels) r.replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '')}.toList()
    ..sort((a, b) => a.length.compareTo(b.length));
  final out = <String>[];
  for (final r in list) {
    if (out.any((o) => r == o || r.startsWith('$o/'))) continue;
    out.add(r);
  }
  return out;
}

Future<String> _sha256Of(File f) async => (await sha256.bind(f.openRead()).first).toString();

Future<void> createBackup(
  String out,
  String dir,
  List<String> paths, {
  required String versionId,
  required List<int> key,
  DateTime? created,
}) async {
  paths = normalizePathSet(paths);
  await Directory(p.dirname(out)).create(recursive: true);
  final files = <String, Map<String, dynamic>>{};
  final enc = ZipFileEncoder()..create(out);
  try {
    Future<void> add(File f) async {
      final rel = p.relative(f.path, from: dir).replaceAll('\\', '/');
      files[rel] = {'size': f.lengthSync(), 'sha256': await _sha256Of(f)};
      await enc.addFile(f, rel);
    }

    for (final rel in paths) {
      final abs = resolveInside(dir, rel);
      final type = FileSystemEntity.typeSync(abs, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        // 不跟随符号链接，链接本身也不备份
        for (final f in Directory(abs).listSync(recursive: true, followLinks: false).whereType<File>()) {
          await add(f);
        }
      } else if (type == FileSystemEntityType.file) {
        await add(File(abs));
      }
    }
    final body = <String, dynamic>{
      'format': 2,
      'version': versionId,
      'paths': paths,
      'created': (created ?? DateTime.now()).toIso8601String(),
      'files': files,
    };
    enc.addArchiveFile(ArchiveFile.string(backupManifestName, jsonEncode({...body, 'mac': _mac(key, body)})));
  } finally {
    await enc.close();
  }
}

class BackupCheck {
  BackupCheck({required this.paths, required this.signed, required this.files, required this.bytes, this.digests});

  final List<String> paths;

  /// 有签名且验证通过；旧版备份没有签名
  final bool signed;
  final int files;
  final int bytes;

  /// 签名备份中每个文件的 SHA-256
  final Map<String, String>? digests;
}

class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic>? _readManifest(Archive archive) {
  final m = archive.findFile(backupManifestName);
  if (m == null || !m.isFile) return null;
  final j = jsonDecode(utf8.decode(m.content));
  return j is Map<String, dynamic> ? j : null;
}

/// 只读取备份包含的路径，用于列出备份
Future<List<String>?> readBackupPaths(String zip) async {
  final input = InputFileStream(zip);
  try {
    final paths = _readManifest(ZipDecoder().decodeStream(input))?['paths'];
    return paths is List ? paths.map((e) => '$e').toList() : null;
  } catch (_) {
    return null;
  } finally {
    await input.close();
  }
}

bool _under(List<String> paths, String rel) => paths.any((r) => rel == r || rel.startsWith('$r/'));

/// 不修改任何文件，检查备份能否安全地恢复
Future<BackupCheck> checkBackup(String zip, String dir, List<int> key) async {
  final input = InputFileStream(zip);
  try {
    final Archive archive;
    final Map<String, dynamic>? manifest;
    try {
      archive = ZipDecoder().decodeStream(input);
      manifest = _readManifest(archive);
    } catch (e) {
      throw BackupException('备份文件已损坏：$e');
    }
    if (manifest == null) throw BackupException('这个备份不是由 Pixel World 创建的，无法恢复');
    final rawPaths = manifest['paths'];
    if (rawPaths is! List || rawPaths.isEmpty) throw BackupException('备份清单无效');
    final paths = <String>[];
    for (final e in rawPaths) {
      if (e is! String) throw BackupException('备份清单无效');
      try {
        paths.add(splitRelative(e).join('/'));
      } on UnsafePathException {
        throw BackupException('备份清单中有不安全的路径：$e');
      }
    }
    if (normalizePathSet(paths).length != paths.length) throw BackupException('备份清单中有重复或互相包含的路径');

    // 签名：有 mac 就必须验证通过
    Map<String, String>? digests;
    Map<String, int>? sizes;
    final mac = manifest['mac'];
    if (mac != null) {
      final body = Map<String, dynamic>.of(manifest)..remove('mac');
      if (mac is! String || _mac(key, body) != mac) {
        throw BackupException('备份签名不匹配：备份被修改过，或者不是在这台设备上创建的');
      }
      final files = manifest['files'];
      if (files is! Map) throw BackupException('备份清单无效');
      digests = {};
      sizes = {};
      for (final e in files.entries) {
        final info = e.value;
        if (info is! Map || info['sha256'] is! String || info['size'] is! int) throw BackupException('备份清单无效');
        digests['${e.key}'] = info['sha256'] as String;
        sizes['${e.key}'] = info['size'] as int;
      }
    }

    var count = 0, bytes = 0;
    final seen = <String>{};
    for (final f in archive.files) {
      if (f.name == backupManifestName) continue;
      if (f.isSymbolicLink) throw BackupException('备份中有符号链接，不能恢复：${f.name}');
      final String rel;
      try {
        rel = splitRelative(f.name).join('/');
      } on UnsafePathException {
        throw BackupException('备份中有不安全的路径：${f.name}');
      }
      if (!_under(paths, rel)) throw BackupException('备份中有清单以外的文件：${f.name}');
      if (!f.isFile) continue;
      if (!seen.add(rel.toLowerCase())) throw BackupException('备份中有重复的文件：${f.name}');
      if (sizes != null && sizes[rel] != f.size) throw BackupException('备份内容与清单不符：${f.name}');
      count++;
      bytes += f.size;
    }
    if (sizes != null && sizes.length != count) throw BackupException('备份缺少清单中的文件');
    return BackupCheck(paths: paths, signed: mac != null, files: count, bytes: bytes, digests: digests);
  } finally {
    await input.close();
  }
}

/// 把检查过的备份解压到新的临时文件夹 [staging]，并核对 CRC 与（签名备份的）SHA-256
Future<void> extractBackup(String zip, String staging, BackupCheck check) async {
  if (FileSystemEntity.typeSync(staging, followLinks: false) != FileSystemEntityType.notFound) {
    throw BackupException('临时文件夹已存在：$staging');
  }
  await Directory(staging).create(recursive: true);
  final input = InputFileStream(zip);
  try {
    final archive = ZipDecoder().decodeStream(input, verify: true);
    for (final f in archive.files) {
      if (f.name == backupManifestName) continue;
      if (f.isSymbolicLink) throw BackupException('备份中有符号链接：${f.name}');
      final rel = splitRelative(f.name).join('/');
      if (!_under(check.paths, rel)) throw BackupException('备份中有清单以外的文件：${f.name}');
      if (!f.isFile) continue;
      final abs = resolveInside(staging, rel);
      await Directory(p.dirname(abs)).create(recursive: true);
      final out = OutputFileStream(abs);
      try {
        f.writeContent(out);
      } finally {
        await out.close();
      }
      final want = check.digests?[rel];
      if (want != null && await _sha256Of(File(abs)) != want) throw BackupException('文件内容与备份清单不符：$rel');
    }
  } finally {
    await input.close();
  }
}
