// 局域网互传：接收方临时开一个 HTTP 服务，显示 IP、随机端口和配对码；
// 发送方先用配对码确认能连上，再把选中的内容打包成 zip 上传。接收方确认后才导入。
//
// zip 结构：
//   pclpw-transfer.json   清单（类型、版本、来源设备、每个文件的大小）
//   version/...           versions/<版本> 文件夹中的文件（只在发送整个版本时有）
//   parent/<版本>/...     依赖的原版（inheritsFrom），只有版本 json 和 jar
//   game/...              运行目录中选中的内容（mods、config、saves 等）

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'backup.dart';
import 'instance_config.dart';
import 'paths.dart';
import 'safe_path.dart';

const transferManifestName = 'pclpw-transfer.json';
const transferPath = '/pclpw/transfer';
const transferHelloPath = '/pclpw/hello';

/// 单次传输的大小上限
const transferMaxBytes = 32 * 1024 * 1024 * 1024;

/// 配对码连续输错几次后停止接收
const transferMaxFailures = 3;

/// 可以单独传输的运行目录内容（名称 → 显示文字）
const transferItems = {
  'mods': '模组',
  'config': '模组配置',
  'saves': '存档',
  'resourcepacks': '资源包',
  'shaderpacks': '光影包',
  'options.txt': '游戏设置',
  'screenshots': '截图',
};

/// 打包整个版本时跳过的内容：日志、崩溃报告、解压出的本地库，接收方用不到
bool _skipInVersion(String rel) {
  final first = rel.split('/').first;
  return first == 'logs' || first == 'crash-reports' || first.endsWith('-natives') || first == 'natives';
}

class TransferException implements Exception {
  TransferException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TransferManifest {
  TransferManifest({
    required this.wholeVersion,
    required this.version,
    required this.from,
    required this.items,
    required this.files,
    this.parents = const [],
    this.loader,
    this.gameVersion,
    this.describe,
  });

  /// 整个版本（导入为新版本）还是部分内容（导入到已有版本）
  final bool wholeVersion;
  final String version;

  /// 发送方的设备名
  final String from;

  /// 运行目录中包含的内容（transferItems 的名称；整个版本且开启了版本隔离时为空，内容都在 version/ 中）
  final List<String> items;

  /// zip 中每个文件的大小
  final Map<String, int> files;

  /// 一起发送的依赖版本（Forge、Fabric 等版本依赖的原版），导入方没有时才导入
  final List<String> parents;

  /// 发送方版本的加载器（Loader 的名称，如 fabric）、游戏版本与显示用的描述（如「Fabric · 1.20.1」）。
  /// 较早的传输包没有这些信息
  final String? loader;
  final String? gameVersion;
  final String? describe;

  int get bytes => files.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
    'format': 2,
    'wholeVersion': wholeVersion,
    'version': version,
    'from': from,
    'items': items,
    'files': files,
    'parents': parents,
    'loader': ?loader,
    'gameVersion': ?gameVersion,
    'describe': ?describe,
  };

  static TransferManifest parse(Map<String, dynamic> j) {
    if (j['format'] != 2) throw TransferException('不支持的传输格式，请把两边的启动器更新到同一版本');
    final version = j['version'];
    final items = j['items'];
    final files = j['files'];
    if (version is! String || items is! List || files is! Map) throw TransferException('传输清单无效');
    splitRelative(version); // 版本名只能是一级合法的文件夹名
    if (version.contains('/') || version.contains('\\')) throw TransferException('版本名无效：$version');
    final parents = (j['parents'] as List? ?? const []).whereType<String>().toList();
    for (final id in parents) {
      if (splitRelative(id).length != 1 || id == version) throw TransferException('依赖版本名无效：$id');
    }
    final names = items.whereType<String>().toList();
    if (names.length != items.length || names.any((n) => !transferItems.containsKey(n))) {
      throw TransferException('传输清单中有不支持的内容');
    }
    final sizes = <String, int>{};
    for (final e in files.entries) {
      final v = e.value;
      if (e.key is! String || v is! int || v < 0) throw TransferException('传输清单无效');
      sizes[e.key as String] = v;
    }
    return TransferManifest(
      wholeVersion: j['wholeVersion'] == true,
      version: version,
      from: (j['from'] as String?) ?? '未知设备',
      items: names,
      files: sizes,
      parents: parents,
      loader: j['loader'] is String ? j['loader'] as String : null,
      gameVersion: j['gameVersion'] is String ? j['gameVersion'] as String : null,
      describe: j['describe'] is String ? j['describe'] as String : null,
    );
  }
}

/// 本机设备名
String transferDeviceName() {
  try {
    return Platform.localHostname;
  } catch (_) {
    return Platform.operatingSystem;
  }
}

/// 打包要发送的内容，返回临时 zip 文件。[versionDir] 是 versions/<版本>，[gameDir] 是运行目录。
/// 不压缩（mods 和存档本身多已压缩，手机上压缩很慢），不包含符号链接。
Future<File> packTransfer({
  required String version,
  required String versionDir,
  required String gameDir,
  required bool wholeVersion,
  required List<String> items,
  String? loader,
  String? gameVersion,
  String? describe,
  void Function(int files)? onFile,
}) async {
  final isolated = p.equals(versionDir, gameDir);
  if (!wholeVersion && items.isEmpty) throw TransferException('请至少选择一项内容');
  final out = Paths.tempFile('transfer.zip');
  final sizes = <String, int>{};
  final included = <String>[];
  final enc = ZipFileEncoder()..create(out.path, level: ZipFileEncoder.store);
  try {
    Future<void> add(File f, String name) async {
      sizes[name] = f.lengthSync();
      await enc.addFile(f, name, ZipFileEncoder.store);
      onFile?.call(sizes.length);
    }

    Future<void> addTree(String root, String rel, String prefix, {bool Function(String rel)? skip}) async {
      final abs = rel.isEmpty ? root : resolveInside(root, rel);
      final type = FileSystemEntity.typeSync(abs, followLinks: false);
      if (type == FileSystemEntityType.file) {
        await add(File(abs), '$prefix$rel');
      } else if (type == FileSystemEntityType.directory) {
        for (final f in Directory(abs).listSync(recursive: true, followLinks: false).whereType<File>()) {
          final r = p.relative(f.path, from: root).replaceAll('\\', '/');
          if (skip != null && skip(r)) continue;
          await add(f, '$prefix$r');
        }
      }
    }

    final parents = <String>[];
    if (wholeVersion) {
      await addTree(versionDir, '', 'version/', skip: _skipInVersion);
      // 依赖的原版也要带上，否则对方没有这个原版时版本无法识别
      final versionsDir = p.dirname(versionDir);
      var cur = version;
      while (true) {
        final parent = _inheritsFrom(p.join(versionsDir, cur, '$cur.json'));
        if (parent == null || parent == version || parents.contains(parent)) break;
        final dir = p.join(versionsDir, parent);
        if (!File(p.join(dir, '$parent.json')).existsSync()) break;
        parents.add(parent);
        for (final name in ['$parent.json', '$parent.jar']) {
          final f = File(p.join(dir, name));
          if (f.existsSync()) await add(f, 'parent/$parent/$name');
        }
        cur = parent;
      }
    }
    // 开启版本隔离时，整个版本已经包含运行目录中的一切
    if (!(wholeVersion && isolated)) {
      for (final item in items) {
        if (!transferItems.containsKey(item)) continue;
        if (FileSystemEntity.typeSync(p.join(gameDir, item), followLinks: false) == FileSystemEntityType.notFound) {
          continue;
        }
        included.add(item);
        await addTree(gameDir, item, 'game/');
      }
    }
    if (sizes.isEmpty) throw TransferException('选中的内容都不存在');
    final manifest = TransferManifest(
      wholeVersion: wholeVersion,
      version: version,
      from: transferDeviceName(),
      items: included,
      files: sizes,
      parents: parents,
      loader: loader,
      gameVersion: gameVersion,
      describe: describe,
    );
    enc.addArchiveFile(ArchiveFile.string(transferManifestName, jsonEncode(manifest.toJson())));
  } catch (_) {
    await enc.close();
    if (out.existsSync()) out.deleteSync();
    rethrow;
  }
  await enc.close();
  return out;
}

String? _inheritsFrom(String json) {
  try {
    final v = (jsonDecode(File(json).readAsStringSync()) as Map<String, dynamic>)['inheritsFrom'];
    return v is String && v.isNotEmpty ? v : null;
  } catch (_) {
    return null;
  }
}

/// 读取并检查收到的 zip：清单存在、每个文件都在清单中、路径安全、大小不超过清单所写
TransferManifest checkTransfer(String zip) {
  final input = InputFileStream(zip);
  try {
    final archive = ZipDecoder().decodeStream(input);
    final m = archive.findFile(transferManifestName);
    if (m == null) throw TransferException('收到的文件不是 PCL.PW 的传输包');
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(m.readBytes() ?? const [])) as Map<String, dynamic>;
    } catch (_) {
      throw TransferException('传输清单无法读取');
    }
    final manifest = TransferManifest.parse(json);
    final seen = <String>{};
    for (final f in archive.files) {
      if (f.name == transferManifestName || !f.isFile) continue;
      _checkEntry(manifest, f);
      seen.add(f.name);
    }
    if (seen.length != manifest.files.length) throw TransferException('传输包缺少文件，可能没有传输完整');
    return manifest;
  } finally {
    input.closeSync();
  }
}

/// 返回条目解压后的相对路径：整个版本时相对 versions 文件夹，部分内容时相对运行目录
String _checkEntry(TransferManifest m, ArchiveFile f) {
  if (f.isSymbolicLink) throw TransferException('传输包中有符号链接：${f.name}');
  final want = m.files[f.name];
  if (want == null) throw TransferException('传输包中有清单以外的文件：${f.name}');
  if (f.size > want) throw TransferException('文件大小与清单不符：${f.name}');
  final String rel;
  if (f.name.startsWith('version/')) {
    if (!m.wholeVersion) throw TransferException('传输包无效：${f.name}');
    rel = '${m.version}/${splitRelative(f.name.substring('version/'.length)).join('/')}';
  } else if (f.name.startsWith('parent/')) {
    final parts = splitRelative(f.name.substring('parent/'.length));
    if (!m.wholeVersion || parts.length != 2 || !m.parents.contains(parts[0])) {
      throw TransferException('传输包无效：${f.name}');
    }
    if (parts[1] != '${parts[0]}.json' && parts[1] != '${parts[0]}.jar') throw TransferException('传输包无效：${f.name}');
    rel = parts.join('/');
  } else if (f.name.startsWith('game/')) {
    final r = splitRelative(f.name.substring('game/'.length)).join('/');
    if (!m.items.contains(r.split('/').first)) throw TransferException('传输包中有清单以外的文件：${f.name}');
    rel = m.wholeVersion ? '${m.version}/$r' : r;
  } else {
    throw TransferException('传输包无效：${f.name}');
  }
  return rel;
}

/// 解压到新的临时文件夹 [staging]
Future<void> _extract(
  String zip,
  TransferManifest m,
  String staging,
  void Function(int total, int done)? onProgress,
) async {
  if (FileSystemEntity.typeSync(staging, followLinks: false) != FileSystemEntityType.notFound) {
    throw TransferException('临时文件夹已存在：$staging');
  }
  await Directory(staging).create(recursive: true);
  final input = InputFileStream(zip);
  try {
    final archive = ZipDecoder().decodeStream(input, verify: true);
    final total = m.bytes;
    var done = 0;
    for (final f in archive.files) {
      if (f.name == transferManifestName || !f.isFile) continue;
      final rel = _checkEntry(m, f);
      final abs = resolveInside(staging, rel);
      if (File(abs).existsSync()) throw TransferException('传输包中有重复的文件：$rel');
      await Directory(p.dirname(abs)).create(recursive: true);
      final out = OutputFileStream(abs);
      try {
        f.writeContent(out);
      } finally {
        await out.close();
      }
      if (File(abs).lengthSync() != m.files[f.name]) throw TransferException('文件大小与清单不符：$rel');
      done += m.files[f.name]!;
      onProgress?.call(total, done);
      // 让界面有机会刷新进度
      await Future<void>.delayed(Duration.zero);
    }
  } finally {
    await input.close();
  }
}

String _stamp() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
}

/// 把整个版本导入为 versions/<原名>，导入后开启版本隔离，返回版本名。
/// 依赖的原版只在本机没有时导入，已有的不覆盖。
Future<String> importTransferVersion(
  String zip,
  TransferManifest m,
  String gameRoot, {
  void Function(int total, int done)? onProgress,
}) async {
  if (!m.wholeVersion) throw TransferException('这个传输包不是整个版本');
  final id = m.version;
  final versions = p.join(gameRoot, 'versions');
  final dest = p.join(versions, id);
  if (FileSystemEntity.typeSync(dest, followLinks: false) != FileSystemEntityType.notFound) {
    throw TransferException('已经有名为「$id」的版本，请先在版本设置里重命名或删除它');
  }
  final staging = p.join(versions, '.pclpw-import-${_stamp()}');
  try {
    await _extract(zip, m, staging, onProgress);
    final main = p.join(staging, id);
    if (!File(p.join(main, '$id.json')).existsSync()) throw TransferException('传输包中没有版本文件 $id.json');
    for (final parent in m.parents) {
      final to = p.join(versions, parent);
      if (FileSystemEntity.typeSync(to, followLinks: false) != FileSystemEntityType.notFound) continue;
      if (Directory(p.join(staging, parent)).existsSync()) await Directory(p.join(staging, parent)).rename(to);
    }
    await writeInstanceRaw(main, {'VersionArgumentIndieV2': true});
    await Directory(main).rename(dest);
  } finally {
    if (Directory(staging).existsSync()) await Directory(staging).delete(recursive: true);
  }
  return id;
}

/// 把部分内容导入到运行目录 [gameDir]：已有的同名内容先备份到 [backupDir]，再整体替换。
/// 返回备份文件路径（没有需要备份的内容时为 null）。
Future<String?> importTransferFiles(
  String zip,
  TransferManifest m,
  String gameDir, {
  required String targetVersion,
  required String backupDir,
  void Function(int total, int done)? onProgress,
}) async {
  if (m.wholeVersion) throw TransferException('这个传输包是整个版本，请导入为新版本');
  final staging = p.join(gameDir, '.pclpw-import-${_stamp()}');
  String? backup;
  try {
    await _extract(zip, m, staging, onProgress);
    final existing = [
      for (final item in m.items)
        if (FileSystemEntity.typeSync(p.join(gameDir, item), followLinks: false) != FileSystemEntityType.notFound) item,
    ];
    if (existing.isNotEmpty) {
      backup = p.join(backupDir, '${_stamp()}-局域网导入前.zip');
      for (var i = 2; File(backup!).existsSync(); i++) {
        backup = p.join(backupDir, '${_stamp()}-局域网导入前-$i.zip');
      }
      await createBackup(backup, gameDir, existing, versionId: targetVersion, key: backupKey(Paths.appData));
    }
    for (final item in m.items) {
      final target = resolveInside(gameDir, item);
      final type = FileSystemEntity.typeSync(target, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        await Directory(target).delete(recursive: true);
      } else if (type != FileSystemEntityType.notFound) {
        await File(target).delete();
      }
      final src = p.join(staging, item);
      final srcType = FileSystemEntity.typeSync(src, followLinks: false);
      if (srcType == FileSystemEntityType.directory) {
        await Directory(src).rename(target);
      } else if (srcType == FileSystemEntityType.file) {
        await File(src).rename(target);
      } else {
        // 发送方的空文件夹：zip 中没有文件
        await Directory(target).create();
      }
    }
  } finally {
    if (Directory(staging).existsSync()) await Directory(staging).delete(recursive: true);
  }
  return backup;
}

// ---------- 网络 ----------

/// 收到的传输包
class ReceivedTransfer {
  ReceivedTransfer(this.file, this.manifest, this.address);

  final File file;
  final TransferManifest manifest;

  /// 发送方 IP
  final String address;
}

/// 本机的局域网 IPv4 地址
Future<List<String>> localAddresses() async {
  final list = await NetworkInterface.list(type: InternetAddressType.IPv4);
  final out = <String>[];
  for (final i in list) {
    for (final a in i.addresses) {
      if (a.isLoopback || a.isLinkLocal) continue;
      out.add(a.address);
    }
  }
  // 常见的家庭/局域网网段排在前面
  int rank(String a) => a.startsWith('192.168.') ? 0 : (a.startsWith('10.') || a.startsWith('172.') ? 1 : 2);
  out.sort((a, b) => rank(a).compareTo(rank(b)));
  return out;
}

String _newCode() {
  final r = Random.secure();
  return List.generate(6, (_) => r.nextInt(10)).join();
}

bool _sameCode(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// 接收服务：只在接收页面打开期间运行
class TransferServer {
  TransferServer._(this._server, this.code, this.onReceived, this.onStopped);

  final HttpServer _server;
  final String code;
  final void Function(ReceivedTransfer) onReceived;

  /// 服务停止（配对码输错太多次）时调用，参数是原因
  final void Function(String reason) onStopped;

  var _failures = 0;
  var _busy = false;
  var _closed = false;

  int get port => _server.port;

  /// 正在接收的字节数（总数，已收到）
  final progress = StreamController<(int, int)>.broadcast();

  static Future<TransferServer> start({
    required void Function(ReceivedTransfer) onReceived,
    required void Function(String reason) onStopped,
  }) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final s = TransferServer._(server, _newCode(), onReceived, onStopped);
    server.listen(s._handle, onError: (_) {});
    return s;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _server.close(force: true);
    await progress.close();
  }

  Future<void> _reply(HttpRequest req, int status, String message) async {
    try {
      req.response
        ..statusCode = status
        ..headers.contentType = ContentType('text', 'plain', charset: 'utf-8')
        ..write(message);
      await req.response.close();
    } catch (_) {}
  }

  /// 检查配对码；输错时计数，达到上限就停止服务
  Future<bool> _auth(HttpRequest req) async {
    final given = req.headers.value('x-pclpw-code') ?? '';
    if (_sameCode(given, code)) return true;
    _failures++;
    final left = transferMaxFailures - _failures;
    final msg = left > 0 ? '配对码不正确，还可以再试 $left 次' : '配对码错误次数太多，对方已停止接收';
    if (left <= 0) onStopped('配对码错误次数太多，已停止接收。需要时重新开始接收，会生成新的配对码。');
    await _reply(req, 403, msg);
    if (left <= 0) unawaited(close());
    return false;
  }

  Future<void> _handle(HttpRequest req) async {
    final addr = req.connectionInfo?.remoteAddress.address ?? '';
    if (req.uri.path == transferHelloPath && req.method == 'GET') {
      if (!await _auth(req)) return;
      return _reply(req, 200, jsonEncode({'name': transferDeviceName()}));
    }
    if (req.uri.path != transferPath || req.method != 'POST') return _reply(req, 404, '');
    if (!await _auth(req)) return;
    if (_busy) return _reply(req, 409, '对方正在接收另一个传输，请稍后再试');
    final total = req.contentLength;
    if (total <= 0) return _reply(req, 411, '缺少文件大小');
    if (total > transferMaxBytes) return _reply(req, 413, '文件太大，单次最多 32 GB');
    _busy = true;
    final file = Paths.tempFile('received.zip');
    var ok = false;
    try {
      final sink = file.openWrite();
      var got = 0;
      try {
        await for (final chunk in req) {
          got += chunk.length;
          if (got > total) throw TransferException('收到的数据比声明的多');
          sink.add(chunk);
          if (!progress.isClosed) progress.add((total, got));
        }
      } finally {
        await sink.close();
      }
      if (got != total) throw TransferException('传输中断，只收到 $got / $total 字节');
      final manifest = await Future(() => checkTransfer(file.path));
      ok = true;
      onReceived(ReceivedTransfer(file, manifest, addr));
      await _reply(req, 200, '对方已收到，等待对方确认导入');
    } on TransferException catch (e) {
      await _reply(req, 400, e.message);
    } on UnsafePathException catch (e) {
      await _reply(req, 400, e.message);
    } catch (e) {
      await _reply(req, 400, '接收失败：$e');
    } finally {
      _busy = false;
      if (!ok && file.existsSync()) file.deleteSync();
    }
  }
}

/// 解析用户输入的「IP:端口」
Uri parseTransferAddress(String input) {
  final s = input.trim().replaceFirst(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/.*$'), '');
  final m = RegExp(r'^([0-9.]+):(\d{1,5})$').firstMatch(s);
  final ip = m == null ? null : InternetAddress.tryParse(m.group(1)!);
  final port = m == null ? 0 : int.parse(m.group(2)!);
  if (ip == null || port <= 0 || port > 65535) throw TransferException('地址格式应为「IP:端口」，例如 192.168.1.5:43567');
  return Uri(scheme: 'http', host: ip.address, port: port);
}

HttpClient _client() => HttpClient()
  ..connectionTimeout = const Duration(seconds: 5)
  ..findProxy = (_) => 'DIRECT';

/// 用配对码确认能连上对方，返回对方的设备名
Future<String> transferHello(Uri base, String code) async {
  final client = _client();
  try {
    final req = await client.getUrl(base.replace(path: transferHelloPath));
    req.headers.set('x-pclpw-code', code.trim());
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) throw TransferException(body.isEmpty ? '连接失败（${res.statusCode}）' : body);
    return (jsonDecode(body) as Map<String, dynamic>)['name'] as String? ?? '对方设备';
  } on SocketException {
    throw TransferException('连不上 ${base.host}:${base.port}。请确认两台设备在同一个局域网，对方正在接收，且防火墙允许 PCL.PW 联网');
  } finally {
    client.close(force: true);
  }
}

/// 上传打包好的文件，[onProgress] 参数为（总字节，已发送字节）。返回对方的回复。
Future<String> transferSend(Uri base, String code, File zip, {void Function(int total, int sent)? onProgress}) async {
  final client = _client();
  try {
    final total = zip.lengthSync();
    final req = await client.postUrl(base.replace(path: transferPath));
    req.headers.set('x-pclpw-code', code.trim());
    req.headers.contentType = ContentType('application', 'zip');
    req.contentLength = total;
    var sent = 0;
    await req.addStream(
      zip.openRead().map((chunk) {
        sent += chunk.length;
        onProgress?.call(total, sent);
        return chunk;
      }),
    );
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) throw TransferException(body.isEmpty ? '发送失败（${res.statusCode}）' : body);
    return body;
  } on SocketException catch (e) {
    throw TransferException('传输中断：${e.message}');
  } on HttpException catch (e) {
    throw TransferException('传输中断：${e.message}');
  } finally {
    client.close(force: true);
  }
}
