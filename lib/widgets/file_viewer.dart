import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../core/instance_files.dart';
import '../platform.dart';

const _viewerMaxBytes = 2 * 1024 * 1024;

const _mono = TextStyle(
  fontFamily: 'Consolas',
  fontFamilyFallback: ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
  fontSize: 12.5,
  height: 1.5,
);

/// 打开文件查看器：Markdown 渲染（可切换源码），其他文本用等宽字体。
/// 桌面用对话框，手机用全屏页面。
Future<void> showFileViewer(BuildContext context, File file) {
  final viewer = FileViewer(file: file);
  if (!isDesktop) {
    return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => viewer));
  }
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760), child: viewer),
    ),
  );
}

class FileViewer extends StatefulWidget {
  const FileViewer({super.key, required this.file});

  final File file;

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late Future<String?> _text = _load();
  bool _source = false;

  bool get _isMarkdown => const {'.md', '.markdown'}.contains(p.extension(widget.file.path).toLowerCase());

  /// 读取文本；二进制或太大时返回 null
  Future<String?> _load() async {
    final f = widget.file;
    if (!await f.exists()) throw const FileSystemException('文件不存在');
    if (await f.length() > _viewerMaxBytes) return null;
    final bytes = await f.readAsBytes();
    if (bytes.take(8192).contains(0)) return null;
    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = p.basename(widget.file.path);
    void close() => Navigator.of(context).maybePop();
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 6),
      child: Row(
        children: [
          Icon(_isMarkdown ? Icons.article_outlined : Icons.description_outlined, color: scheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium)),
          if (_isMarkdown)
            SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: false, label: Text('预览')),
                ButtonSegment(value: true, label: Text('源码')),
              ],
              selected: {_source},
              onSelectionChanged: (v) => setState(() => _source = v.first),
            ),
          IconButton(
            tooltip: '刷新',
            onPressed: () => setState(() => _text = _load()),
            icon: const Icon(Icons.refresh),
          ),
          FutureBuilder<String?>(
            future: _text,
            builder: (context, snap) => IconButton(
              tooltip: '复制全文',
              onPressed: snap.data == null
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: snap.data!));
                      toast(context, '已复制');
                    },
              icon: const Icon(Icons.copy_outlined),
            ),
          ),
          IconButton(
            tooltip: '在文件管理器中打开',
            onPressed: () => openInFileManager(p.dirname(widget.file.path), create: false),
            icon: const Icon(Icons.folder_open_outlined),
          ),
          if (isDesktop) IconButton(tooltip: '关闭', onPressed: close, icon: const Icon(Icons.close)),
        ],
      ),
    );
    final body = FutureBuilder<String?>(
      future: _text,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('打不开：${snap.error}'));
        final text = snap.data;
        if (text == null) {
          return Center(
            child: Text('这个文件不是文本，或者超过 2 MB，不能在这里查看', style: TextStyle(color: scheme.onSurfaceVariant)),
          );
        }
        if (_isMarkdown && !_source) {
          return Markdown(
            data: text,
            selectable: true,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            onTapLink: (_, href, _) {
              final uri = href == null ? null : Uri.tryParse(href);
              if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyMedium?.copyWith(height: 1.65),
              code: _mono.copyWith(backgroundColor: scheme.surfaceContainerHighest),
              codeblockDecoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
              tableBorder: TableBorder.all(color: scheme.outlineVariant),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SelectableText(text, style: _mono),
        );
      },
    );
    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(titleSpacing: 0, title: header),
        body: body,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, const Divider(height: 1), Expanded(child: body)],
    );
  }
}
