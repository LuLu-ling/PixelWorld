// 启动器创建的备份文件格式：AI 修改游戏文件前的备份，以及恢复前的检查与解压

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'safe_path.dart';
import 'i18n/strings.dart';

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
      throw BackupException(tr.backupBackupFileCorrupted(e));
    }
    if (manifest == null) throw BackupException(tr.backupBackupWasntCreatedPixel);
    final rawPaths = manifest['paths'];
    if (rawPaths is! List || rawPaths.isEmpty) throw BackupException(tr.backupInvalidBackupManifest);
    final paths = <String>[];
    for (final e in rawPaths) {
      if (e is! String) throw BackupException(tr.backupInvalidBackupManifest);
      try {
        paths.add(splitRelative(e).join('/'));
      } on UnsafePathException {
        throw BackupException(tr.backupBackupManifestContainsUnsafe(e));
      }
    }
    if (normalizePathSet(paths).length != paths.length) throw BackupException(tr.backupBackupManifestContainsDuplicate);

    // 签名：有 mac 就必须验证通过
    Map<String, String>? digests;
    Map<String, int>? sizes;
    final mac = manifest['mac'];
    if (mac != null) {
      final body = Map<String, dynamic>.of(manifest)..remove('mac');
      if (mac is! String || _mac(key, body) != mac) {
        throw BackupException(tr.backupBackupSignatureMismatchBackup);
      }
      final files = manifest['files'];
      if (files is! Map) throw BackupException(tr.backupInvalidBackupManifest);
      digests = {};
      sizes = {};
      for (final e in files.entries) {
        final info = e.value;
        if (info is! Map || info['sha256'] is! String || info['size'] is! int) {
          throw BackupException(tr.backupInvalidBackupManifest);
        }
        digests['${e.key}'] = info['sha256'] as String;
        sizes['${e.key}'] = info['size'] as int;
      }
    }

    var count = 0, bytes = 0;
    final seen = <String>{};
    for (final f in archive.files) {
      if (f.name == backupManifestName) continue;
      if (f.isSymbolicLink) throw BackupException(tr.backupBackupContainsSymbolicLink(f.name));
      final String rel;
      try {
        rel = splitRelative(f.name).join('/');
      } on UnsafePathException {
        throw BackupException(tr.backupBackupContainsUnsafePath(f.name));
      }
      if (!_under(paths, rel)) throw BackupException(tr.backupBackupContainsFileNot(f.name));
      if (!f.isFile) continue;
      if (!seen.add(rel.toLowerCase())) throw BackupException(tr.backupBackupContainsDuplicateFile(f.name));
      if (sizes != null && sizes[rel] != f.size) throw BackupException(tr.backupBackupContentsDontMatch(f.name));
      count++;
      bytes += f.size;
    }
    if (sizes != null && sizes.length != count) throw BackupException(tr.backupBackupMissingFilesListed);
    return BackupCheck(paths: paths, signed: mac != null, files: count, bytes: bytes, digests: digests);
  } finally {
    await input.close();
  }
}

/// 把检查过的备份解压到新的临时文件夹 [staging]，并核对 CRC 与（签名备份的）SHA-256
Future<void> extractBackup(String zip, String staging, BackupCheck check) async {
  if (FileSystemEntity.typeSync(staging, followLinks: false) != FileSystemEntityType.notFound) {
    throw BackupException(tr.commonTemporaryFolderAlreadyExists(staging));
  }
  await Directory(staging).create(recursive: true);
  final input = InputFileStream(zip);
  try {
    final archive = ZipDecoder().decodeStream(input, verify: true);
    for (final f in archive.files) {
      if (f.name == backupManifestName) continue;
      if (f.isSymbolicLink) throw BackupException(tr.backupBackupContainsSymbolicLink2(f.name));
      final rel = splitRelative(f.name).join('/');
      if (!_under(check.paths, rel)) throw BackupException(tr.backupBackupContainsFileNot(f.name));
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
      if (want != null && await _sha256Of(File(abs)) != want) {
        throw BackupException(tr.backupFileContentsDontMatch(rel));
      }
    }
  } finally {
    await input.close();
  }
}
