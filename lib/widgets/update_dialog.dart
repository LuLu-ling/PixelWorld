import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../core/updater.dart';
import '../l10n/l10n.dart';

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
      if (manual) toast(context, context.l10n.updateDialogYoureLatestVersion(channel.label));
      return;
    }
    // 自动检查：跳过的版本不提示；本地构建没有提交号，不自动提示 nightly
    if (!manual && (cfg.updateSkipped == r.key || (r.isNightly && AppInfo.commit.isEmpty))) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(release: r, manual: manual),
    );
  } catch (e) {
    if (manual && context.mounted) toast(context, context.l10n.updateDialogCouldntCheckUpdates(errorText(e)));
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

  /// 已经下载好的安装包。授权或失败后重试时直接复用，不再重新下载
  File? _file;
  bool _needsPermission = false;

  Release get r => widget.release;

  Future<void> _update(ReleaseAsset asset) async {
    setState(() {
      _busy = true;
      _error = null;
      _needsPermission = false;
      _progress = _file == null ? 0 : 1;
    });
    try {
      final file =
          _file ??
          await downloadAsset(
            asset,
            onProgress: (got, total) {
              if (mounted && total > 0) setState(() => _progress = got / total);
            },
          );
      _file = file;
      if (mounted) setState(() => _progress = 1);
      await applyUpdate(file);
      // Windows：安装程序或替换脚本会在启动器退出后接手
      if (Platform.isWindows) exit(0);
      if (mounted) Navigator.pop(context);
    } on InstallPermissionException {
      // 安装包已下载好，等用户授权后点「继续安装」即可
      if (mounted) {
        setState(() {
          _busy = false;
          _needsPermission = true;
        });
      }
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
        : '${AppInfo.version}${context.l10n.commonParenthesized(AppInfo.commit.substring(0, AppInfo.commit.length.clamp(0, 7)))}';
    return AlertDialog(
      title: Text(context.l10n.updateDialogNewVersionAvailable(r.label)),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.updateDialogCurrentVersion(
                current,
                r.isNightly
                    ? 'Nightly'
                    : (r.prerelease ? context.l10n.updateChannelPreview : context.l10n.updateChannelStable),
                date == null ? '' : context.l10n.updateDialogReleased(date),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            // 更新日志占用剩下的高度并可滚动：手机横屏只有约 400 高，固定高度会把按钮挤出去
            Flexible(
              child: SingleChildScrollView(
                child: MarkdownBody(data: r.body.isEmpty ? context.l10n.updateDialogNoReleaseNotes : r.body),
              ),
            ),
            if (asset == null) ...[
              const SizedBox(height: 12),
              Text(
                Platform.isLinux
                    ? context.l10n.updateDialogNoPackageHasBeen
                    : context.l10n.updateDialogReleaseHasNoFile,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (Platform.isMacOS && asset != null) ...[
              const SizedBox(height: 12),
              Text(context.l10n.updateDialogAfterDownloadingInstallerImage, style: theme.textTheme.bodySmall),
            ],
            if (Platform.isAndroid && asset != null) ...[
              const SizedBox(height: 12),
              Text(context.l10n.updateDialogAfterDownloadingSystemInstalls, style: theme.textTheme.bodySmall),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 4),
              Text(
                _progress == null
                    ? context.l10n.updateDialogDownloading
                    : context.l10n.updateDialogDownloading2((_progress! * 100).toStringAsFixed(0)),
                style: theme.textTheme.labelSmall,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (_needsPermission) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.updateDialogInstallerHasBeenDownloaded,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
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
            child: Text(context.l10n.updateDialogSkipVersion),
          ),
        TextButton(
          onPressed: () => launchUrl(Uri.parse(r.page), mode: LaunchMode.externalApplication),
          child: Text(context.l10n.updateDialogViewGitHub),
        ),
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(context.l10n.updateDialogLater)),
        if (asset != null)
          FilledButton(
            onPressed: _busy ? null : () => _update(asset),
            child: Text(
              _file != null
                  ? context.l10n.updateDialogContinueInstall
                  : (Platform.isWindows
                        ? context.l10n.updateDialogUpdateRestart
                        : context.l10n.updateDialogDownloadInstall),
            ),
          ),
      ],
    );
  }
}
