import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../app_info.dart';
import 'updater.dart';

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version}'
  ..connectionTimeout = const Duration(seconds: 8);

/// 依次从各个接口地址获取 [file]（如 update.json），返回第一个格式有效（format 为 1）的内容；
/// 全部失败时返回 null
Future<Map<String, dynamic>?> fetchSiteJson(String file, {List<String>? bases}) async {
  for (final base in bases ?? AppInfo.siteApiBases) {
    try {
      final data = await _get('$base/$file').timeout(const Duration(seconds: 15));
      if (data is Map<String, dynamic> && data['format'] == 1) return data;
    } catch (_) {
      // 换下一个地址
    }
  }
  return null;
}

Future<Object?> _get(String url) async {
  final req = await _client.getUrl(Uri.parse(url));
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  final res = await req.close();
  if (res.statusCode != 200) {
    await res.drain<void>();
    throw HttpException('HTTP ${res.statusCode}');
  }
  return jsonDecode(await res.transform(utf8.decoder).join());
}

/// 解析 update.json，返回各通道的最新发布（没有发布的通道不在结果中）；格式不支持时返回 null
Map<String, Release>? parseUpdateChannels(Map<String, dynamic> json) {
  if (json['format'] != 1) return null;
  final channels = json['channels'];
  if (channels is! Map) return null;
  final result = <String, Release>{};
  for (final c in UpdateChannel.values) {
    final j = channels[c.name];
    if (j is! Map<String, dynamic>) continue;
    try {
      final r = Release.fromSite(j);
      if (r.tag.isNotEmpty) result[c.name] = r;
    } catch (_) {
      // 跳过无效条目
    }
  }
  return result;
}

/// 从自有接口获取各通道的最新发布；接口不可用或内容无效时返回 null
Future<Map<String, Release>?> fetchUpdateChannels() async {
  final json = await fetchSiteJson('update.json');
  return json == null ? null : parseUpdateChannels(json);
}

enum NoticeLevel { info, warning, error }

/// 公告（notices.json 的一项）
class Notice {
  Notice({
    required this.id,
    required this.level,
    required this.title,
    required this.body,
    this.url,
    this.urlText,
    this.platforms,
    this.channels,
    this.minVersion,
    this.maxVersion,
    this.start,
    this.end,
    this.dismissible = true,
  });

  /// 解析一项公告；无效时返回 null
  static Notice? tryParse(Object? j) {
    if (j is! Map) return null;
    try {
      final id = j['id'], title = j['title'];
      if (id is! String || id.trim().isEmpty || title is! String || title.trim().isEmpty) return null;
      List<String>? list(Object? v) => v is List ? [for (final x in v) '$x'] : null;
      String? text(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
      final url = text(j['url']);
      final uri = url == null ? null : Uri.tryParse(url);
      final safeUrl = uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
      return Notice(
        id: id.trim(),
        level: NoticeLevel.values.where((l) => l.name == j['level']).firstOrNull ?? NoticeLevel.info,
        title: title.trim(),
        body: j['body'] is String ? j['body'] as String : '',
        url: safeUrl ? url : null,
        urlText: text(j['urlText']),
        platforms: list(j['platforms']),
        channels: list(j['channels']),
        minVersion: text(j['minVersion']),
        maxVersion: text(j['maxVersion']),
        start: DateTime.tryParse('${j['start'] ?? ''}'),
        end: DateTime.tryParse('${j['end'] ?? ''}'),
        dismissible: j['dismissible'] != false,
      );
    } catch (_) {
      return null;
    }
  }

  /// 解析 notices.json，跳过无效与重复编号的条目；格式不支持时返回空列表
  static List<Notice> parseAll(Map<String, dynamic> json) {
    if (json['format'] != 1) return [];
    final raw = json['notices'];
    if (raw is! List) return [];
    final seen = <String>{};
    return [
      for (final j in raw)
        if (tryParse(j) case final n? when seen.add(n.id)) n,
    ];
  }

  final String id;
  final NoticeLevel level;
  final String title;
  final String body;
  final String? url;
  final String? urlText;

  /// 为空表示不限制
  final List<String>? platforms;
  final List<String>? channels;
  final String? minVersion;
  final String? maxVersion;
  final DateTime? start;
  final DateTime? end;
  final bool dismissible;

  /// 在给定平台（windows/android/macos/linux）、更新通道、版本号与时间下是否应显示；
  /// 可关闭的公告在 [dismissed] 中时不显示
  bool visibleFor({
    required String platform,
    required String channel,
    required String version,
    required DateTime now,
    Set<String> dismissed = const {},
  }) {
    if (dismissible && dismissed.contains(id)) return false;
    if (platforms != null && !platforms!.contains(platform)) return false;
    if (channels != null && !channels!.contains(channel)) return false;
    if (minVersion != null && compareVersions(version, minVersion!) < 0) return false;
    if (maxVersion != null && compareVersions(version, maxVersion!) > 0) return false;
    if (start != null && now.isBefore(start!)) return false;
    if (end != null && now.isAfter(end!)) return false;
    return true;
  }
}

/// 从自有接口获取公告；失败时返回空列表
Future<List<Notice>> fetchNotices() async {
  final json = await fetchSiteJson('notices.json');
  return json == null ? [] : Notice.parseAll(json);
}

Future<List<Notice>>? _noticesFuture;

/// 每次启动只获取一次公告，切换页面不会重复请求
Future<List<Notice>> loadNotices() => _noticesFuture ??= fetchNotices().catchError((_) => <Notice>[]);

/// 当前平台在公告中的名称
String get noticePlatform => Platform.isWindows
    ? 'windows'
    : Platform.isAndroid
    ? 'android'
    : Platform.isMacOS
    ? 'macos'
    : 'linux';
