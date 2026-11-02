import 'dart:convert';
import 'dart:io';

import '../app_info.dart';
import 'download.dart';
import 'install.dart';

/// 首页的 Minecraft 版本动态：取官方版本列表中最新的几个正式版与快照，
/// 再从中文 Minecraft Wiki 读取对应版本页面的简介与配图。
class VersionNews {
  VersionNews({
    required this.id,
    required this.type,
    required this.releaseTime,
    required this.summary,
    required this.image,
    required this.wikiUrl,
  });

  final String id;

  /// release / snapshot
  final String type;
  final DateTime releaseTime;

  /// Wiki 页面开头的简介；页面还没写好时为空
  final String summary;
  final String? image;
  final String wikiUrl;
}

const _wiki = 'https://zh.minecraft.wiki';

String _title(String id) => 'Java版$id';

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version} (github.com/zhuzhi-09/PCL.PW)'
  ..connectionTimeout = const Duration(seconds: 15);

Future<Map<String, ({String summary, String? image})>> _wikiExtracts(List<String> titles) async {
  final uri = Uri.parse('$_wiki/api.php').replace(
    queryParameters: {
      'action': 'query',
      'prop': 'extracts|pageimages',
      'exintro': '1',
      'explaintext': '1',
      'exsentences': '3',
      'exlimit': 'max',
      'piprop': 'thumbnail',
      'pithumbsize': '640',
      'pilimit': 'max',
      'redirects': '1',
      'format': 'json',
      'titles': titles.join('|'),
    },
  );
  final res = await (await _client.getUrl(uri)).close().timeout(const Duration(seconds: 20));
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode != 200) throw Exception('Minecraft Wiki 请求失败（${res.statusCode}）');
  final query = (jsonDecode(body) as Map<String, dynamic>)['query'] as Map<String, dynamic>? ?? {};
  // 重定向后的标题映射回请求时的标题
  final redirects = {
    for (final r in (query['redirects'] as List? ?? const []).cast<Map<String, dynamic>>())
      '${r['to']}': '${r['from']}',
  };
  final out = <String, ({String summary, String? image})>{};
  for (final page in ((query['pages'] as Map<String, dynamic>?) ?? {}).values.cast<Map<String, dynamic>>()) {
    if (page.containsKey('missing')) continue;
    final title = '${page['title']}';
    out[redirects[title] ?? title] = (
      summary: '${page['extract'] ?? ''}'.trim(),
      image: (page['thumbnail'] as Map?)?['source'] as String?,
    );
  }
  return out;
}

Future<List<VersionNews>> loadVersionNews(Downloader dl, {int count = 8}) async {
  final manifest = await remoteVersions(dl);
  final latest = manifest.list.where((v) => v.type == 'release' || v.type == 'snapshot').take(count).toList();
  Map<String, ({String summary, String? image})> wiki = {};
  try {
    wiki = await _wikiExtracts([for (final v in latest) _title(v.id)]);
  } catch (_) {
    // Wiki 不可用时仍显示版本列表
  }
  return [
    for (final v in latest)
      VersionNews(
        id: v.id,
        type: v.type,
        releaseTime: DateTime.tryParse(v.releaseTime)?.toLocal() ?? DateTime.now(),
        summary: wiki[_title(v.id)]?.summary ?? '',
        image: wiki[_title(v.id)]?.image,
        wikiUrl: '$_wiki/w/${Uri.encodeComponent(_title(v.id))}',
      ),
  ];
}
