import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../app_info.dart';
import 'task.dart';

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version} (github.com/zhuzhi-09/PCL.PW)'
  ..connectionTimeout = const Duration(seconds: 15);

Future<(int, Uint8List)> _get(String url, {String? userAgent}) async {
  final req = await _client.getUrl(Uri.parse(url));
  if (userAgent != null) {
    req.headers
      ..set(HttpHeaders.userAgentHeader, userAgent)
      ..set(HttpHeaders.acceptHeader, 'image/avif,image/webp,image/png,image/*;q=0.8,*/*;q=0.5')
      ..set(HttpHeaders.acceptLanguageHeader, 'zh-CN,zh;q=0.9,en;q=0.8');
  }
  final res = await req.close().timeout(const Duration(seconds: 30));
  final b = BytesBuilder(copy: false);
  await for (final chunk in res) {
    b.add(chunk);
  }
  return (res.statusCode, b.takeBytes());
}

// ---------- 清理游戏垃圾 ----------

/// 与 PCL 相同的范围：各游戏文件夹及其中每个版本文件夹下的 logs、crash-reports、
/// hs_err_pid*、*.log、WailaErrorOutput.txt，以及解压出来的 natives 文件夹
List<FileSystemEntity> findGameJunk(List<String> gameFolders) {
  final dirs = <Directory>[];
  for (final root in gameFolders) {
    final d = Directory(root);
    if (!d.existsSync()) continue;
    dirs.add(d);
    final versions = Directory(p.join(root, 'versions'));
    if (versions.existsSync()) dirs.addAll(versions.listSync().whereType<Directory>());
  }
  final out = <FileSystemEntity>[];
  for (final d in dirs) {
    for (final name in ['crash-reports', 'logs']) {
      final sub = Directory(p.join(d.path, name));
      if (sub.existsSync()) out.add(sub);
    }
    try {
      for (final e in d.listSync()) {
        final name = p.basename(e.path);
        if (e is File && (name.startsWith('hs_err_pid') || name.endsWith('.log') || name == 'WailaErrorOutput.txt')) {
          out.add(e);
        } else if (e is Directory && (name == '${p.basename(d.path)}-natives' || name == 'natives-windows-x86_64')) {
          out.add(e);
        }
      }
    } catch (_) {
      // 没有权限读取的文件夹跳过
    }
  }
  return out;
}

int sizeOf(FileSystemEntity e) {
  try {
    if (e is File) return e.lengthSync();
    if (e is Directory) {
      return e.listSync(recursive: true).whereType<File>().fold(0, (s, f) => s + f.lengthSync());
    }
  } catch (_) {}
  return 0;
}

/// 删除，返回删除失败（例如正在被游戏使用）的数量
Future<int> deleteAll(List<FileSystemEntity> items) async {
  var failed = 0;
  for (final e in items) {
    try {
      await e.delete(recursive: true);
    } catch (_) {
      failed++;
    }
  }
  return failed;
}

// ---------- 今日人品 ----------

/// 同一个人同一天的结果固定
int luckToday(String name, [DateTime? day]) {
  final d = day ?? DateTime.now();
  final seed = md5.convert(utf8.encode('${AppInfo.name}|$name|${d.year}-${d.month}-${d.day}')).bytes;
  return (seed[0] << 8 | seed[1]) % 101;
}

String luckComment(int v) => switch (v) {
  100 => '满分！今天做什么都会顺利',
  >= 90 => '大吉，开箱必出钻石',
  >= 75 => '运气不错，适合去下界走走',
  >= 60 => '平平稳稳，挖矿不会挖到岩浆',
  >= 40 => '一般般，记得多带几个床',
  >= 20 => '小心苦力怕，出门前先存档',
  > 0 => '今天适合在家种田',
  _ => '零分……今天还是别下矿了',
};

// ---------- 桌面快捷方式 ----------

Future<String> createDesktopShortcut() async {
  if (!Platform.isWindows) throw Exception('目前只支持 Windows');
  final desktop = p.join(Platform.environment['USERPROFILE'] ?? '', 'Desktop');
  final path = p.join(desktop, '${AppInfo.name}.lnk');
  final exe = Platform.resolvedExecutable;
  String q(String s) => s.replaceAll("'", "''");
  final r = await Process.run('powershell.exe', [
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    "\$s = (New-Object -ComObject WScript.Shell).CreateShortcut('${q(path)}'); \$s.TargetPath = '${q(exe)}'; "
        "\$s.WorkingDirectory = '${q(p.dirname(exe))}'; \$s.Save()",
  ]);
  if (r.exitCode != 0) throw Exception('创建快捷方式失败');
  return path;
}

// ---------- 自定义下载 ----------

Future<void> downloadToFile(String url, String path, TaskProgress task) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) throw Exception('请输入 http 或 https 开头的网址');
  task.beginStep('下载');
  task.setStage('连接 ${uri.host}');
  final res = await (await _client.getUrl(uri)).close().timeout(const Duration(seconds: 30));
  if (res.statusCode != 200) throw Exception('下载失败（HTTP ${res.statusCode}）');
  final total = res.contentLength;
  final tmp = File('$path.download');
  await tmp.parent.create(recursive: true);
  final sink = tmp.openWrite();
  var done = 0;
  task.setStage('下载 ${p.basename(path)}');
  try {
    await for (final chunk in res) {
      sink.add(chunk);
      done += chunk.length;
      task.progressBytes(done, total > 0 ? total : 0);
    }
    await sink.close();
    if (File(path).existsSync()) await File(path).delete();
    await tmp.rename(path);
    task.output('已保存到 $path（${(done / 1024 / 1024).toStringAsFixed(2)} MB）');
  } catch (_) {
    await sink.close().catchError((_) {});
    if (tmp.existsSync()) await tmp.delete();
    rethrow;
  }
}

/// 从网址推测文件名
String fileNameFromUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  final last = uri == null || uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  return last.isEmpty ? 'download' : Uri.decodeComponent(last);
}

// ---------- 正版皮肤 ----------

class PlayerSkin {
  PlayerSkin(this.name, this.uuid, this.png, {required this.slim});

  final String name;
  final String uuid;
  final Uint8List png;

  /// Alex 模型（细手臂）
  final bool slim;
}

Future<PlayerSkin> fetchSkin(String name) async {
  final n = name.trim();
  if (!RegExp(r'^[A-Za-z0-9_]{1,16}$').hasMatch(n)) throw Exception('玩家名只能包含字母、数字和下划线');
  final (s1, b1) = await _get('https://api.mojang.com/users/profiles/minecraft/$n');
  if (s1 == 404 || s1 == 204) throw Exception('找不到正版玩家 $n');
  if (s1 != 200) throw Exception('查询玩家失败（$s1）');
  final profile = jsonDecode(utf8.decode(b1)) as Map<String, dynamic>;
  final uuid = '${profile['id']}';
  final (s2, b2) = await _get('https://sessionserver.mojang.com/session/minecraft/profile/$uuid');
  if (s2 != 200) throw Exception('获取皮肤信息失败（$s2）');
  final props = ((jsonDecode(utf8.decode(b2)) as Map)['properties'] as List).cast<Map<String, dynamic>>();
  final textures = props.firstWhere((e) => e['name'] == 'textures');
  final data = jsonDecode(utf8.decode(base64Decode('${textures['value']}'))) as Map<String, dynamic>;
  final skin = (data['textures'] as Map?)?['SKIN'] as Map<String, dynamic>?;
  if (skin == null) throw Exception('$n 使用的是默认皮肤');
  final (s3, png) = await _get('${skin['url']}'.replaceFirst('http://', 'https://'));
  if (s3 != 200) throw Exception('下载皮肤失败（$s3）');
  return PlayerSkin('${profile['name']}', uuid, png, slim: (skin['metadata'] as Map?)?['model'] == 'slim');
}

// ---------- 自定义成就图片 ----------

/// 由 minecraft-api.com 生成（与 PCL 相同）；该服务拒绝非浏览器的请求头
Future<Uint8List> fetchAchievement({
  required String block,
  required String title,
  required String line1,
  String line2 = '',
}) async {
  String seg(String s) => Uri.encodeComponent(s.trim().replaceAll(' ', '..'));
  if (title.trim().isEmpty || line1.trim().isEmpty) throw Exception('请填写标题和第一行文字');
  var url =
      'https://minecraft-api.com/api/achivements/${seg(block.isEmpty ? 'grass' : block)}/${seg(title)}/${seg(line1)}';
  if (line2.trim().isNotEmpty) url += '/${seg(line2)}';
  final (status, png) = await _get(
    url,
    userAgent:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36',
  );
  if (status == 404) throw Exception('找不到这个物品，请检查物品 ID');
  if (status != 200 || png.length < 8 || png[0] != 0x89) throw Exception('生成失败（$status）');
  return png;
}

// ---------- 服务器查询（Server List Ping） ----------

class ServerStatus {
  ServerStatus({
    required this.online,
    required this.max,
    required this.version,
    required this.motd,
    required this.latency,
    this.favicon,
  });

  final int online;
  final int max;
  final String version;
  final String motd;
  final int latency;
  final Uint8List? favicon;
}

List<int> _varint(int n) {
  final out = <int>[];
  do {
    var b = n & 0x7f;
    n >>>= 7;
    if (n != 0) b |= 0x80;
    out.add(b);
  } while (n != 0);
  return out;
}

List<int> _packet(List<int> body) => [..._varint(body.length), ...body];

(int, int)? _readVarint(List<int> buf, int at) {
  var v = 0;
  for (var i = 0; i < 5; i++) {
    if (at + i >= buf.length) return null;
    final b = buf[at + i];
    v |= (b & 0x7f) << (7 * i);
    if (b & 0x80 == 0) return (v, at + i + 1);
  }
  throw Exception('服务器返回的数据无效');
}

/// 聊天组件转成纯文本，并去掉 § 颜色代码
String _flatten(Object? c) {
  if (c is String) return c.replaceAll(RegExp('§.'), '');
  if (c is List) return c.map(_flatten).join();
  if (c is Map) return _flatten(c['text'] ?? '') + _flatten(c['extra'] ?? '');
  return '';
}

/// SRV 记录：`_minecraft._tcp.<host>`（Dart 没有 SRV 查询，借助系统命令）
Future<(String, int)?> _resolveSrv(String host) async {
  try {
    if (Platform.isWindows) {
      final r = await Process.run('nslookup', [
        '-type=SRV',
        '_minecraft._tcp.$host',
      ]).timeout(const Duration(seconds: 5));
      final out = '${r.stdout}';
      final port = RegExp(r'port\s*=\s*(\d+)').firstMatch(out)?.group(1);
      final target = RegExp(r'svr hostname\s*=\s*(\S+)').firstMatch(out)?.group(1);
      if (port != null && target != null) return (target.replaceAll(RegExp(r'\.$'), ''), int.parse(port));
    } else {
      final r = await Process.run('dig', [
        '+short',
        'SRV',
        '_minecraft._tcp.$host',
      ]).timeout(const Duration(seconds: 5));
      final parts = '${r.stdout}'.trim().split('\n').first.split(' ');
      if (parts.length == 4) return (parts[3].replaceAll(RegExp(r'\.$'), ''), int.parse(parts[2]));
    }
  } catch (_) {
    // 没有 SRV 记录时直接连接
  }
  return null;
}

Future<ServerStatus> queryServer(String address) async {
  final m = RegExp(r'^(\[[^\]]+\]|[^:]+)(?::(\d+))?$').firstMatch(address.trim());
  if (m == null) throw Exception('服务器地址格式不正确');
  var host = m.group(1)!.replaceAll(RegExp(r'^\[|\]$'), '');
  var port = m.group(2) == null ? null : int.parse(m.group(2)!);
  if (port == null) {
    final srv = await _resolveSrv(host);
    if (srv != null) (host, port) = srv;
  }
  final realPort = port ?? 25565;
  final started = DateTime.now();
  Socket sock;
  try {
    sock = await Socket.connect(host, realPort, timeout: const Duration(seconds: 5));
  } catch (e) {
    throw Exception('无法连接：$e');
  }
  final latency = DateTime.now().difference(started).inMilliseconds;
  final done = Completer<ServerStatus>();
  final buf = <int>[];
  sock.listen(
    (d) {
      buf.addAll(d);
      try {
        final len = _readVarint(buf, 0);
        if (len == null || buf.length < len.$2 + len.$1) return;
        final id = _readVarint(buf, len.$2)!;
        final strLen = _readVarint(buf, id.$2)!;
        final s = jsonDecode(utf8.decode(buf.sublist(strLen.$2, strLen.$2 + strLen.$1))) as Map<String, dynamic>;
        final fav = s['favicon'];
        done.complete(
          ServerStatus(
            online: ((s['players'] as Map?)?['online'] as num?)?.toInt() ?? 0,
            max: ((s['players'] as Map?)?['max'] as num?)?.toInt() ?? 0,
            version: '${(s['version'] as Map?)?['name'] ?? '未知'}',
            motd: _flatten(s['description']).trim(),
            latency: latency,
            favicon: fav is String && fav.startsWith('data:image/png;base64,')
                ? base64Decode(fav.substring('data:image/png;base64,'.length).replaceAll('\n', ''))
                : null,
          ),
        );
      } catch (e) {
        if (!done.isCompleted) done.completeError(Exception('服务器返回的数据无效'));
      }
    },
    onError: (Object e) => done.isCompleted ? null : done.completeError(Exception('连接中断：$e')),
    onDone: () => done.isCompleted ? null : done.completeError(Exception('服务器关闭了连接')),
  );
  final hostBytes = utf8.encode(host);
  sock.add(
    _packet([
      ..._varint(0),
      ..._varint(767),
      ..._varint(hostBytes.length),
      ...hostBytes,
      realPort >> 8,
      realPort & 0xff,
      ..._varint(1),
    ]),
  );
  sock.add(_packet(_varint(0)));
  try {
    return await done.future.timeout(const Duration(seconds: 5), onTimeout: () => throw Exception('连接超时'));
  } finally {
    sock.destroy();
  }
}
