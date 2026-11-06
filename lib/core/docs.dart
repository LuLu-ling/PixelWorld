import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;

import '../app_info.dart';
import 'paths.dart';

/// 文档页面；id 对应 `https://pcl.pw.zhuzhi.site/docs/<id>.html`
const docPages = [
  (id: 'index', title: '总览'),
  (id: 'install', title: '下载与安装'),
  (id: 'first-run', title: '第一次启动'),
  (id: 'versions', title: '版本与加载器'),
  (id: 'resources', title: '模组与资源'),
  (id: 'android', title: '安卓版'),
  (id: 'ai', title: 'AI 排障'),
  (id: 'troubleshooting', title: '常见问题与排错'),
  (id: 'api', title: '启动器接口'),
];

const docSite = 'https://pcl.pw.zhuzhi.site/docs';

/// 官网不可用时从 raw.githubusercontent 读取 site 分支的内容
const _rawDocs = 'https://raw.githubusercontent.com/zhuzhi-09/PCL.PW/site/docs/docs';

String docPageUrl(String id) => '$docSite/$id.html';

final _client = HttpClient()
  ..userAgent = '${AppInfo.name}/${AppInfo.version}'
  ..connectionTimeout = const Duration(seconds: 10);

/// 读取一页文档并转换成 Markdown。优先联网，失败时使用上次缓存的版本。
Future<String> loadDocMarkdown(String id) async {
  final cache = File(p.join(Paths.appData, 'docs-cache', '$id.md'));
  Object? error;
  for (final base in [docSite, _rawDocs]) {
    try {
      final html = await _get('$base/$id.html');
      final md = htmlToMarkdown(html);
      if (md.trim().isEmpty) throw Exception('文档内容为空');
      await cache.parent.create(recursive: true);
      await cache.writeAsString(md);
      return md;
    } catch (e) {
      error = e;
    }
  }
  if (cache.existsSync()) return cache.readAsStringSync();
  throw Exception('无法获取文档（${error ?? '没有缓存'}），请检查网络后重试');
}

Future<String> _get(String url) async {
  final req = await _client.getUrl(Uri.parse(url));
  final res = await req.close().timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    await res.drain<void>();
    throw HttpException('HTTP ${res.statusCode}');
  }
  return utf8.decode(await res.expand((b) => b).toList());
}

/// 把文档页面的 <article> 转成 Markdown（只处理文档里实际用到的结构）
String htmlToMarkdown(String html) {
  final doc = html_parser.parse(html);
  final article = doc.querySelector('article') ?? doc.body;
  if (article == null) return '';
  return _blocks(article).trim();
}

String _blocks(dom.Element root) {
  final b = StringBuffer();
  for (final el in root.children) {
    final s = _block(el).trim();
    if (s.isEmpty) continue;
    b.writeln(s);
    b.writeln();
  }
  return b.toString();
}

String _block(dom.Element el) {
  switch (el.localName) {
    case 'h1':
      return '# ${_inline(el)}';
    case 'h2':
      return '## ${_inline(el)}';
    case 'h3':
      return '### ${_inline(el)}';
    case 'h4':
      return '#### ${_inline(el)}';
    case 'p':
      return _inline(el);
    case 'ul':
      return _list(el, ordered: false);
    case 'ol':
      return _list(el, ordered: true);
    case 'pre':
      return '```\n${el.text.trimRight()}\n```';
    case 'table':
      return _table(el);
    case 'hr':
      return '---';
    case 'details':
      return _details(el);
    case 'div':
      if (el.classes.contains('callout')) {
        final inner = _blocks(el).trim();
        return inner.split('\n').map((l) => l.trim().isEmpty ? '>' : '> $l').join('\n');
      }
      return _blocks(el);
    default:
      return _blocks(el);
  }
}

String _inline(dom.Element el) => _inlineNodes(el.nodes).trim();

String _inlineNodes(Iterable<dom.Node> nodes) {
  final b = StringBuffer();
  void write(dom.Node n) {
    if (n is dom.Text) {
      b.write(n.text.replaceAll(RegExp(r'\s+'), ' '));
      return;
    }
    if (n is! dom.Element) return;
    switch (n.localName) {
      case 'strong' || 'b':
        b.write('**${_inline(n)}**');
      case 'em' || 'i':
        b.write('*${_inline(n)}*');
      case 'code':
        final code = n.text.replaceAll('\n', ' ').trim();
        b.write(code.contains('`') ? '`` $code ``' : '`$code`');
      case 'a':
        final href = n.attributes['href'] ?? '';
        final text = _inline(n);
        if (href.isEmpty || text.isEmpty) {
          b.write(text);
        } else {
          b.write('[$text]($href)');
        }
      case 'br':
        b.write('  \n');
      case 'img':
        final src = n.attributes['src'] ?? '';
        if (src.isNotEmpty) b.write('![]($src)');
      default:
        b.write(_inlineNodes(n.nodes));
    }
  }

  for (final n in nodes) {
    write(n);
  }
  return b.toString().replaceAll(RegExp(r'[ \t]{2,}'), ' ');
}

String _list(dom.Element list, {required bool ordered}) {
  final b = StringBuffer();
  var index = 1;
  for (final li in list.children.where((e) => e.localName == 'li')) {
    final nested = <dom.Element>[];
    final parts = <dom.Node>[];
    for (final n in li.nodes) {
      if (n is dom.Element && (n.localName == 'ul' || n.localName == 'ol')) {
        nested.add(n);
      } else {
        parts.add(n);
      }
    }
    final text = _inlineNodes(parts).trim().replaceAll('\n', ' ');
    b.writeln('${ordered ? '${index++}.' : '-'} $text');
    for (final n in nested) {
      final sub = _list(n, ordered: n.localName == 'ol');
      for (final line in sub.trimRight().split('\n')) {
        b.writeln('  $line');
      }
    }
  }
  return b.toString().trimRight();
}

String _table(dom.Element table) {
  final rows = <List<String>>[];
  for (final tr in table.querySelectorAll('tr')) {
    final cells = [
      for (final c in tr.children.where((e) => e.localName == 'td' || e.localName == 'th'))
        _inline(c).replaceAll('|', r'\|').replaceAll('\n', ' '),
    ];
    if (cells.isNotEmpty) rows.add(cells);
  }
  if (rows.isEmpty) return '';
  final width = rows.map((r) => r.length).reduce(max);
  String line(List<String> r) => '| ${[...r, for (var i = r.length; i < width; i++) ''].join(' | ')} |';
  final b = StringBuffer()
    ..writeln(line(rows.first))
    ..writeln('|${List.filled(width, ' --- ').join('|')}|');
  for (final r in rows.skip(1)) {
    b.writeln(line(r));
  }
  return b.toString().trimRight();
}

String _details(dom.Element el) {
  final summary = el.querySelector('summary');
  final title = summary == null ? '' : _inline(summary);
  final rest = StringBuffer();
  for (final child in el.children) {
    if (child == summary) continue;
    rest.writeln(_block(child));
  }
  return [
    if (title.isNotEmpty) '**$title**',
    if (rest.toString().trim().isNotEmpty) rest.toString().trim(),
  ].join('\n\n');
}
