import 'dart:async';
import 'dart:io';

import '../app_info.dart';
import 'i18n/strings.dart';

/// 网络检测：测各个服务能不能连上、多快。「自动选择」下载源用它在官方源和 BMCLAPI 之间选快的，
/// 首次设置和「设置 → 下载」里的网络检测也用它。

/// 一项检测的结果
class NetResult {
  const NetResult.ok({required this.latency, required this.bytes, required this.elapsed}) : error = null;
  const NetResult.failed(this.error) : latency = null, bytes = 0, elapsed = null;

  /// 从发出请求到收到第一个字节
  final Duration? latency;

  /// 测速期间收到的字节数和用时（只读前 [_sampleBytes] 字节）
  final int bytes;
  final Duration? elapsed;
  final String? error;

  bool get ok => error == null;

  /// 下载速度（字节/秒）；数据太少时按延迟估算，仍然能比较两边快慢
  double get speed {
    final e = elapsed;
    if (e == null) return 0;
    final secs = e.inMicroseconds / 1e6;
    return secs <= 0 ? 0 : bytes / secs;
  }
}

/// 网络检测的一项：名称、用途和测试地址
class NetTarget {
  const NetTarget(this.id, this.name, this.purpose, this.url);

  final String id;
  final String name;
  final String purpose;
  final String url;
}

/// 两个下载源测同一个文件（游戏版本列表，一百多 KB），速度可以直接比较
NetTarget get officialProbe => NetTarget(
  'official',
  tr.networkCheckMojangOfficial,
  tr.networkCheckGameLibraryDownloads,
  'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json',
);
NetTarget get mirrorProbe => NetTarget(
  'bmclapi',
  tr.downloadSourceMirror,
  tr.networkCheckGameLoaderDownloadsMainland,
  'https://bmclapi2.bangbang93.com/mc/game/version_manifest_v2.json',
);

/// 网络检测的全部项目
List<NetTarget> get netTargets => [
  officialProbe,
  mirrorProbe,
  NetTarget(
    'microsoft',
    tr.networkCheckMicrosoftSign,
    tr.networkCheckMicrosoftAccountSign,
    'https://login.microsoftonline.com/consumers/v2.0/.well-known/openid-configuration',
  ),
  NetTarget('modrinth', 'Modrinth', tr.networkCheckModsModpacksResourcePacks, 'https://api.modrinth.com/v2/tag/loader'),
  NetTarget(
    'update',
    tr.networkCheckPixelWorldUpdates,
    tr.networkCheckUpdateChecksAnnouncementsDocs,
    '${AppInfo.siteApiBases.first}/update.json',
  ),
];

const _sampleBytes = 512 * 1024;

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version}'
  ..connectionTimeout = const Duration(seconds: 6);

/// 测一个地址：延迟（首字节）和速度（最多读 512 KB）；[timeout] 内没完成算失败
Future<NetResult> probe(String url, {Duration timeout = const Duration(seconds: 8)}) async {
  final sw = Stopwatch()..start();
  try {
    return await () async {
      final req = await _client.getUrl(Uri.parse(url));
      final res = await req.close();
      final latency = sw.elapsed;
      if (res.statusCode >= 400) {
        await res.drain<void>();
        return NetResult.failed('HTTP ${res.statusCode}');
      }
      var bytes = 0;
      await for (final chunk in res) {
        bytes += chunk.length;
        if (bytes >= _sampleBytes) break;
      }
      return NetResult.ok(latency: latency, bytes: bytes, elapsed: sw.elapsed - latency);
    }().timeout(timeout);
  } on TimeoutException {
    return NetResult.failed(tr.networkCheckTimedOut);
  } on SocketException catch (e) {
    return NetResult.failed(e.osError?.message ?? tr.instanceCantConnect);
  } on HandshakeException {
    return NetResult.failed(tr.networkCheckSecureConnectionFailed);
  } catch (e) {
    return NetResult.failed('$e');
  }
}

/// 「自动选择」下载源：记住官方源和 BMCLAPI 哪个更快。
/// 启动时测一次；下载时某一边失败、另一边成功也会调整（见 [reportFallback]）。
class DownloadSourcePicker {
  DownloadSourcePicker._();

  static bool? _preferMirror;
  static ({NetResult official, NetResult mirror})? _last;
  static Future<({NetResult official, NetResult mirror})>? _running;

  /// 是否优先用镜像；还没测过时中文系统先用镜像
  static bool get preferMirror => _preferMirror ?? Platform.localeName.startsWith('zh');

  /// 最近一次测速结果（没测过为 null）
  static ({NetResult official, NetResult mirror})? get last => _last;

  /// 测两个下载源并决定优先用哪个；同时只测一次
  static Future<({NetResult official, NetResult mirror})> measure() => _running ??= () async {
    try {
      final rs = await Future.wait([probe(officialProbe.url), probe(mirrorProbe.url)]);
      return update(rs[0], rs[1]);
    } finally {
      _running = null;
    }
  }();

  /// 记下一次测速结果（网络检测页面测完也会调用）
  static ({NetResult official, NetResult mirror}) update(NetResult official, NetResult mirror) {
    final r = (official: official, mirror: mirror);
    _last = r;
    _preferMirror = decide(official, mirror);
    return r;
  }

  /// 两边都能用时选速度快的；官方源要明显更快（1.3 倍以上）才用官方，因为镜像的节点一般更稳定
  static bool decide(NetResult official, NetResult mirror) {
    if (!mirror.ok) return !official.ok;
    if (!official.ok) return true;
    return official.speed < mirror.speed * 1.3;
  }

  /// 下载时优先的源失败、换另一边成功了：这次运行里改为优先另一边
  static void reportFallback({required bool mirrorWorked}) => _preferMirror = mirrorWorked;
}

/// 显示用：延迟和速度
String describeNet(NetResult r) {
  if (!r.ok) return tr.networkCheckConnectionFailed(r.error ?? '');
  final ms = r.latency!.inMilliseconds;
  final speed = r.speed;
  final s = speed >= 1024 * 1024
      ? '${(speed / 1024 / 1024).toStringAsFixed(1)} MB/s'
      : '${(speed / 1024).round()} KB/s';
  return r.bytes >= 64 * 1024 ? '$ms ms · $s' : '$ms ms';
}
