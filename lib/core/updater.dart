import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../app_info.dart';

/// 启动器的更新通道，对应 GitHub Releases 中的三类发布（见 .github/workflows/release.yml）
enum UpdateChannel {
  /// 不带「-」的 v* 标签
  stable('正式版'),

  /// 所有 v* 标签，包括 v0.4.0-beta 这样的预发布
  preview('预览版'),

  /// main 分支的每次更新，标签固定为 nightly
  nightly('Nightly');

  const UpdateChannel(this.label);

  final String label;

  static UpdateChannel parse(String s) =>
      values.where((c) => c.name == s).firstOrNull ??
      values.where((c) => c.name == AppInfo.channel).firstOrNull ??
      stable;
}

class ReleaseAsset {
  ReleaseAsset({required this.name, required this.url, required this.size, this.sha256});

  final String name;
  final String url;
  final int size;

  /// GitHub 为发布文件计算的 SHA-256（较早上传的文件没有）
  final String? sha256;
}

class Release {
  Release({
    required this.tag,
    required this.name,
    required this.body,
    required this.prerelease,
    required this.commit,
    required this.publishedAt,
    required this.assets,
    required this.page,
  });

  factory Release.fromJson(Map<String, dynamic> j) => Release(
    tag: '${j['tag_name'] ?? ''}',
    name: '${j['name'] ?? j['tag_name'] ?? ''}',
    body: '${j['body'] ?? ''}',
    prerelease: j['prerelease'] == true,
    commit: '${j['target_commitish'] ?? ''}',
    publishedAt: DateTime.tryParse('${j['published_at'] ?? ''}'),
    page: '${j['html_url'] ?? ''}',
    assets: [
      for (final a in (j['assets'] as List? ?? const []).whereType<Map<String, dynamic>>())
        ReleaseAsset(
          name: '${a['name']}',
          url: '${a['browser_download_url']}',
          size: (a['size'] as num?)?.toInt() ?? 0,
          sha256: RegExp(r'^sha256:([0-9a-f]{64})$').firstMatch('${a['digest'] ?? ''}')?.group(1),
        ),
    ],
  );

  final String tag;
  final String name;
  final String body;
  final bool prerelease;

  /// nightly 发布指向的提交（工作流用 --target 指定为完整的提交号）
  final String commit;
  final DateTime? publishedAt;
  final List<ReleaseAsset> assets;
  final String page;

  bool get isNightly => tag == 'nightly';

  /// v0.3.0 → 0.3.0
  String get version => tag.startsWith('v') ? tag.substring(1) : tag;

  /// 显示用的版本名与用于「跳过这个版本」的键
  String get label => isNightly ? 'Nightly ${commit.length >= 7 ? commit.substring(0, 7) : commit}' : tag;
  String get key => isNightly ? 'nightly-$commit' : tag;
}

/// 比较版本号：1.2.3 > 1.2.3-beta.2 > 1.2.3-beta.1 > 1.2.2；返回正数表示 [a] 更新
int compareVersions(String a, String b) {
  (List<int>, String?) split(String v) {
    v = v.trim().replaceFirst(RegExp(r'^v'), '').split('+').first;
    final dash = v.indexOf('-');
    final core = dash < 0 ? v : v.substring(0, dash);
    return ([for (final x in core.split('.')) int.tryParse(x) ?? 0], dash < 0 ? null : v.substring(dash + 1));
  }

  final (ca, pa) = split(a);
  final (cb, pb) = split(b);
  for (var i = 0; i < 3 || i < ca.length || i < cb.length; i++) {
    final x = i < ca.length ? ca[i] : 0, y = i < cb.length ? cb[i] : 0;
    if (x != y) return x - y;
  }
  if (pa == pb) return 0;
  // 没有预发布后缀的更新
  if (pa == null) return 1;
  if (pb == null) return -1;
  final xa = pa.split('.'), xb = pb.split('.');
  for (var i = 0; i < xa.length && i < xb.length; i++) {
    final na = int.tryParse(xa[i]), nb = int.tryParse(xb[i]);
    final c = na != null && nb != null ? na - nb : xa[i].compareTo(xb[i]);
    if (c != 0) return c;
  }
  return xa.length - xb.length;
}

final _versionTag = RegExp(r'^v\d+(\.\d+)*(-[0-9A-Za-z.-]+)?$');

/// 通道中最新的发布
Release? latestRelease(List<Release> list, UpdateChannel channel) {
  if (channel == UpdateChannel.nightly) return list.where((r) => r.isNightly).firstOrNull;
  final candidates = list
      .where((r) => _versionTag.hasMatch(r.tag) && (channel == UpdateChannel.preview || !r.prerelease))
      .toList();
  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => compareVersions(b.version, a.version));
  return candidates.first;
}

/// [r] 是否比当前构建新。nightly 按提交号判断：本地构建没有提交号，视为需要更新
bool isNewer(Release r, {String currentVersion = AppInfo.version, String currentCommit = AppInfo.commit}) {
  if (r.isNightly) {
    if (currentCommit.isEmpty || r.commit.isEmpty) return true;
    return !r.commit.startsWith(currentCommit) && !currentCommit.startsWith(r.commit);
  }
  return compareVersions(r.version, currentVersion) > 0;
}

/// Windows 上通过安装程序安装（安装目录中有安装清单），否则为便携版
bool get isInstalledWindowsBuild =>
    Platform.isWindows && File(p.join(p.dirname(Platform.resolvedExecutable), '.pw-install.json')).existsSync();

/// 当前平台使用的发布文件；Linux 还没有发布包
ReleaseAsset? assetFor(Release r, {bool? android, bool? windows, bool? macos, bool? installed}) {
  android ??= Platform.isAndroid;
  windows ??= Platform.isWindows;
  macos ??= Platform.isMacOS;
  installed ??= isInstalledWindowsBuild;
  final String suffix;
  if (android) {
    suffix = '-android-arm64.apk';
  } else if (windows) {
    suffix = installed ? '-windows-x64-setup.exe' : '-windows-x64-portable.zip';
  } else if (macos) {
    suffix = '-macos.dmg';
  } else {
    return null;
  }
  return r.assets.where((a) => a.name.endsWith(suffix)).firstOrNull;
}

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version}'
  ..connectionTimeout = const Duration(seconds: 20);

Future<List<Release>> fetchReleases() async {
  final req = await _client.getUrl(Uri.parse('${AppInfo.repoApi}/releases?per_page=30'));
  req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
  final res = await req.close().timeout(const Duration(seconds: 30));
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode == 403 || res.statusCode == 429) throw Exception('GitHub 访问次数超出限制，请稍后再试');
  if (res.statusCode != 200) throw Exception('无法获取更新信息（HTTP ${res.statusCode}）');
  return [for (final j in (jsonDecode(body) as List).whereType<Map<String, dynamic>>()) Release.fromJson(j)];
}

/// 检查更新：返回比当前构建新的发布，没有时返回 null
Future<Release?> checkForUpdate(UpdateChannel channel) async {
  final r = latestRelease(await fetchReleases(), channel);
  return r != null && isNewer(r) ? r : null;
}

/// 下载发布文件到临时文件夹，核对大小与 SHA-256
Future<File> downloadAsset(ReleaseAsset asset, {void Function(int received, int total)? onProgress}) async {
  final dir = Directory(p.join(Directory.systemTemp.path, 'pclpw-update'));
  await dir.create(recursive: true);
  final out = File(p.join(dir.path, asset.name));
  final tmp = File('${out.path}.part');
  final req = await _client.getUrl(Uri.parse(asset.url));
  final res = await req.close().timeout(const Duration(seconds: 30));
  if (res.statusCode != 200) {
    await res.drain<void>();
    throw Exception('下载失败（HTTP ${res.statusCode}）');
  }
  final total = asset.size > 0 ? asset.size : res.contentLength;
  final sink = tmp.openWrite();
  var received = 0;
  final digest = _DigestSink();
  final hasher = sha256.startChunkedConversion(digest);
  try {
    await for (final chunk in res.timeout(const Duration(seconds: 60))) {
      sink.add(chunk);
      hasher.add(chunk);
      received += chunk.length;
      onProgress?.call(received, total);
    }
  } finally {
    await sink.close();
    hasher.close();
  }
  if (asset.size > 0 && received != asset.size) {
    await tmp.delete();
    throw Exception('下载不完整（$received / ${asset.size} 字节）');
  }
  if (asset.sha256 != null && digest.value.toString() != asset.sha256) {
    await tmp.delete();
    throw Exception('文件校验失败（SHA-256 不匹配）');
  }
  if (out.existsSync()) await out.delete();
  return tmp.rename(out.path);
}

const _channel = MethodChannel('pclpw/update');

/// 安装下载好的更新。Windows 上会启动安装程序或替换脚本，然后由调用方退出启动器
Future<void> applyUpdate(File file) async {
  if (Platform.isAndroid) {
    // 系统会弹出安装确认；首次需要允许「安装未知应用」
    await _channel.invokeMethod('installApk', {'path': file.path});
    return;
  }
  // macOS：打开下载的 dmg，由用户把新版本拖进「应用程序」替换旧版本
  if (Platform.isMacOS) {
    await Process.run('open', [file.path]);
    return;
  }
  if (!Platform.isWindows) throw UnsupportedError('这个平台暂不支持自动更新');
  if (file.path.endsWith('.exe')) {
    await Process.start(file.path, const [], mode: ProcessStartMode.detached);
    return;
  }
  // 便携版：解压后等启动器退出，再覆盖程序文件夹并重新启动（用户数据在 %APPDATA%，不受影响）
  final stage = Directory(p.join(p.dirname(file.path), 'portable'));
  if (stage.existsSync()) await stage.delete(recursive: true);
  await extractFileToDisk(file.path, stage.path);
  final top = stage.listSync().whereType<Directory>().toList();
  final source = top.length == 1 && stage.listSync().length == 1 ? top.single.path : stage.path;
  if (!File(p.join(source, 'PCL.PW.exe')).existsSync()) throw Exception('更新包中找不到 PCL.PW.exe');
  final target = p.dirname(Platform.resolvedExecutable);
  final exe = p.join(target, 'PCL.PW.exe');
  String q(String s) => "'${s.replaceAll("'", "''")}'";
  final script = [
    'Wait-Process -Id $pid -ErrorAction SilentlyContinue',
    'Start-Sleep -Milliseconds 500',
    'robocopy ${q(source)} ${q(target)} /E /R:5 /W:1 /NFL /NDL /NJH /NJS | Out-Null',
    'Start-Process ${q(File(exe).existsSync() ? exe : Platform.resolvedExecutable)}',
  ].join('; ');
  await Process.start('powershell.exe', [
    '-NoProfile',
    '-WindowStyle',
    'Hidden',
    '-Command',
    script,
  ], mode: ProcessStartMode.detached);
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
