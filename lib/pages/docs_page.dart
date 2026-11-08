import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/docs.dart';

/// 工具页的「使用文档」：从官网抓取文档并在启动器内重排显示，断网时使用缓存。
class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  int _index = 0;
  late Future<String> _future = loadDocMarkdown(docPages[_index].id);

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _future = loadDocMarkdown(docPages[index].id);
    });
  }

  void _reload() => setState(() => _future = loadDocMarkdown(docPages[_index].id));

  void _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  void _onLink(String? href) {
    if (href == null || href.isEmpty || href.startsWith('#')) return;
    if (href.startsWith('http://') || href.startsWith('https://')) return _open(href);
    // 指向官网首页等站外页面
    if (href.startsWith('../')) return _open('https://pixelworld.zhuzhi.site/${href.substring(3)}');
    final path = href.split('#').first;
    final name = path.split('/').last;
    if (name.endsWith('.html')) {
      final id = name.substring(0, name.length - 5);
      final target = docPages.indexWhere((p) => p.id == id);
      if (target >= 0) return _select(target);
    }
    // 其余的相对链接按文档页面地址解析后交给浏览器
    _open(Uri.parse(docPageUrl(docPages[_index].id)).resolve(href).toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final page = docPages[_index];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!wide)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: DropdownButton<int>(
                  value: _index,
                  isExpanded: true,
                  items: [
                    for (var i = 0; i < docPages.length; i++)
                      DropdownMenuItem(value: i, child: Text(docPages[i].title)),
                  ],
                  onChanged: (i) {
                    if (i != null) _select(i);
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(page.title, style: theme.textTheme.titleMedium),
                        Text(
                          '来自 pixelworld.zhuzhi.site · 断网时显示最近一次缓存',
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '在浏览器打开',
                    onPressed: () => _open(docPageUrl(page.id)),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  IconButton(tooltip: '刷新', onPressed: _reload, icon: const Icon(Icons.refresh)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(theme)),
          ],
        );
        if (!wide) return content;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 208,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                children: [
                  for (var i = 0; i < docPages.length; i++)
                    ListTile(
                      dense: true,
                      selected: i == _index,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(docPages[i].title),
                      onTap: () => _select(i),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme) {
    final scheme = theme.colorScheme;
    return FutureBuilder<String>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 40, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.error),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonal(onPressed: _reload, child: const Text('重试')),
                      TextButton(onPressed: () => _open(docPageUrl(docPages[_index].id)), child: const Text('在浏览器打开')),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 24, 32),
            child: MarkdownBody(
              data: snap.data!,
              onTapLink: (_, href, _) => _onLink(href),
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                h1: theme.textTheme.headlineSmall,
                h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                h3: theme.textTheme.titleMedium,
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                listBullet: theme.textTheme.bodyMedium,
                a: TextStyle(color: scheme.primary),
                code: TextStyle(
                  fontFamily: 'Consolas',
                  fontFamilyFallback: const ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
                  fontSize: 13,
                  backgroundColor: scheme.surfaceContainerHigh,
                ),
                codeblockDecoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquoteDecoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                tableBorder: TableBorder.all(color: scheme.outlineVariant),
                tableCellsPadding: const EdgeInsets.all(8),
                tableHead: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      },
    );
  }
}
