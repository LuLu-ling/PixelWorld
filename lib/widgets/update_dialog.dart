import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../core/updater.dart';

/// 当前使用的更新通道：设置里没有选择时跟随这个构建自己的通道
UpdateChannel currentUpdateChannel(BuildContext context) =>
    UpdateChannel.parse(AppScope.read(context).config.updateChannel);

var _checking = false;

/// 检查更新并提示。[manual] 为用户主动检查：没有更新或出错时也要告诉用户，并忽略「跳过这个版本」
Future<void> checkUpdates(BuildContext context, {required bool manual}) async {
  if (_checking) return;
  _checking = true;
  final cfg = AppScope.read(context).config;
  final channel = currentUpdateChannel(context);
  try {
    final r = await checkForUpdate(channel);
    if (!context.mounted) return;
    if (r == null) {
      if (manual) toast(context, '已是最新版本（${channel.label}）');
      return;
    }
    // 自动检查：跳过的版本不提示；本地构建没有提交号，不自动提示 nightly
    if (!manual && (cfg.updateSkipped == r.key || (r.isNightly && AppInfo.commit.isEmpty))) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(release: r, manual: manual),
    );
  } catch (e) {
    if (manual && context.mounted) toast(context, '检查更新失败：${errorText(e)}');
  } finally {
    _checking = false;
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.release, required this.manual});

  final Release release;
  final bool manual;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double? _progress;
  bool _busy = false;
  String? _error;

  Release get r => widget.release;

  Future<void> _update(ReleaseAsset asset) async {
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      final file = await downloadAsset(
        asset,
        onProgress: (got, total) {
          if (mounted && total > 0) setState(() => _progress = got / total);
        },
      );
      await applyUpdate(file);
      // Windows：安装程序或替换脚本会在启动器退出后接手
      if (Platform.isWindows) exit(0);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = assetFor(r);
    final date = r.publishedAt?.toLocal().toString().substring(0, 16);
    final current = AppInfo.commit.isEmpty
        ? AppInfo.version
        : '${AppInfo.version}（${AppInfo.commit.substring(0, AppInfo.commit.length.clamp(0, 7))}）';
    return AlertDialog(
      title: Text('发现新版本：${r.label}'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前版本 $current · ${r.isNightly ? 'Nightly' : (r.prerelease ? '预览版' : '正式版')}'
              '${date == null ? '' : ' · 发布于 $date'}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(child: MarkdownBody(data: r.body.isEmpty ? '没有更新说明' : r.body)),
            ),
            if (asset == null) ...[
              const SizedBox(height: 12),
              Text(
                Platform.isMacOS || Platform.isLinux ? '这个平台还没有发布包，请到 GitHub 查看。' : '这个发布中没有适用于当前平台的文件。',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (Platform.isAndroid && asset != null) ...[
              const SizedBox(height: 12),
              Text('下载后由系统安装，需要在弹出的界面中确认；游戏文件不受影响。', style: theme.textTheme.bodySmall),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 4),
              Text(
                _progress == null ? '正在下载' : '正在下载 ${(_progress! * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        if (!widget.manual)
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    AppScope.read(context).config.update({'updateSkipped': r.key});
                    Navigator.pop(context);
                  },
            child: const Text('跳过这个版本'),
          ),
        TextButton(
          onPressed: () => launchUrl(Uri.parse(r.page), mode: LaunchMode.externalApplication),
          child: const Text('在 GitHub 查看'),
        ),
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('稍后')),
        if (asset != null)
          FilledButton(
            onPressed: _busy ? null : () => _update(asset),
            child: Text(Platform.isWindows ? '更新并重启' : '下载并安装'),
          ),
      ],
    );
  }
}
