import 'package:flutter/material.dart';

import '../core/network_check.dart';
import '../l10n/l10n.dart';

/// 网络检测：同时测各项服务，一行一项显示结果，最后说明「自动选择」会用哪个下载源。
/// 用于首次设置和「设置 → 下载」
class NetworkCheckPanel extends StatefulWidget {
  const NetworkCheckPanel({super.key, this.autoStart = true, this.compact = false, this.onDone});

  /// 显示时立即开始检测
  final bool autoStart;

  /// 紧凑样式（首次设置）：一排小格，只显示名称和结果
  final bool compact;

  /// 检测完成（[preferMirror] 为自动选择的结果）
  final void Function(bool preferMirror)? onDone;

  @override
  State<NetworkCheckPanel> createState() => _NetworkCheckPanelState();
}

class _NetworkCheckPanelState extends State<NetworkCheckPanel> {
  final _results = <String, NetResult>{};
  bool _running = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) _run();
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _results.clear();
    });
    await Future.wait([
      for (final t in netTargets)
        probe(t.url).then((r) {
          if (mounted) setState(() => _results[t.id] = r);
        }),
    ]);
    if (!mounted) return;
    final picked = DownloadSourcePicker.update(_results[officialProbe.id]!, _results[mirrorProbe.id]!);
    setState(() => _running = false);
    widget.onDone?.call(DownloadSourcePicker.decide(picked.official, picked.mirror));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final official = _results[officialProbe.id];
    final mirror = _results[mirrorProbe.id];
    final failed = _results.values.where((r) => !r.ok).length;
    if (widget.compact) return _compact(theme, failed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in netTargets)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: SizedBox.square(dimension: 22, child: _status(scheme, _results[t.id])),
            title: Text(t.name),
            subtitle: Text(t.purpose),
            trailing: Text(
              _results[t.id] == null
                  ? (_running ? context.l10n.networkCheckPanelChecking : '')
                  : describeNet(_results[t.id]!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _results[t.id]?.ok == false ? scheme.error : scheme.onSurfaceVariant,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _running || official == null || mirror == null
                      ? context.l10n.networkCheckPanelCheckingUp8Seconds
                      : [
                          if (!official.ok && !mirror.ok)
                            context.l10n.networkCheckPanelNeitherDownloadSourceCan
                          else
                            context.l10n.networkCheckPanelAutomaticWillPreferSwitch(
                              DownloadSourcePicker.decide(official, mirror)
                                  ? context.l10n.networkCheckPanelBMCLAPIMirror
                                  : context.l10n.downloadSourceOfficial,
                            ),
                          if (failed > 0 && (official.ok || mirror.ok))
                            context.l10n.networkCheckPanelOtherConnectionsFailedRelated(failed),
                        ].join(context.l10n.commonClauseSeparator),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              TextButton.icon(
                onPressed: _running ? null : _run,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.networkCheckPanelCheckAgain),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Map<String, String> _short(AppLocalizations l) => {
    'official': l.downloadSourceOfficial,
    'bmclapi': 'BMCLAPI',
    'microsoft': l.commonSignMicrosoft,
    'modrinth': 'Modrinth',
    'update': l.networkCheckPanelLauncherUpdates,
  };

  Widget _compact(ThemeData theme, int failed) {
    final scheme = theme.colorScheme;
    final done = !_running && _results.length == netTargets.length;
    final small = theme.textTheme.bodySmall!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(context.l10n.networkCheck, style: small.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                !done
                    ? context.l10n.networkCheckPanelCheckingUp8Seconds2
                    : failed == 0
                    ? context.l10n.networkCheckPanelAllGood
                    : context.l10n.networkCheckPanelOtherConnectionsFailedRelated(failed),
                overflow: TextOverflow.ellipsis,
                style: small.copyWith(color: failed > 0 && done ? scheme.error : scheme.outline),
              ),
            ),
            TextButton.icon(
              onPressed: _running ? null : _run,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(context.l10n.networkCheckPanelCheckAgain),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 600;
            final cols = c.maxWidth >= 440 ? 5 : 3;
            const gap = 8.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final t in netTargets) SizedBox(width: w, child: _tile(theme, t, _results[t.id], wide))],
            );
          },
        ),
      ],
    );
  }

  Widget _tile(ThemeData theme, NetTarget t, NetResult? r, bool wide) {
    final scheme = theme.colorScheme;
    final small = theme.textTheme.bodySmall!;
    final value = r == null
        ? (_running ? context.l10n.networkCheckPanelChecking : '')
        : !r.ok
        ? context.l10n.networkCheckPanelConnectionFailed
        : wide
        ? describeNet(r)
        : describeNet(r).replaceFirst(' · ', '\n');
    // 窄的时候结果占两行，各格一样高
    final shown = wide || value.contains('\n') ? value : '$value\n';
    final tile = Container(
      padding: EdgeInsets.symmetric(horizontal: wide ? 12 : 9, vertical: wide ? 10 : 7),
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 14,
                child: r == null
                    ? (_running ? const CircularProgressIndicator(strokeWidth: 1.6) : null)
                    : Icon(r.ok ? Icons.check : Icons.close, size: 14, color: r.ok ? scheme.primary : scheme.error),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  wide ? t.name : _short(context.l10n)[t.id] ?? t.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: small.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
                ),
              ),
            ],
          ),
          if (wide)
            Text(
              t.purpose,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: small.copyWith(color: scheme.outline, fontSize: 11),
            ),
          const SizedBox(height: 3),
          Text(
            shown,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: small.copyWith(color: r?.ok == false ? scheme.error : scheme.onSurfaceVariant, fontSize: 11.5),
          ),
        ],
      ),
    );
    return r != null && !r.ok ? Tooltip(message: describeNet(r), child: tile) : tile;
  }

  Widget _status(ColorScheme scheme, NetResult? r) {
    if (r == null) {
      return _running ? const CircularProgressIndicator(strokeWidth: 2) : const SizedBox.shrink();
    }
    return Icon(r.ok ? Icons.check_circle : Icons.error_outline, size: 22, color: r.ok ? scheme.primary : scheme.error);
  }
}

/// 「设置 → 下载 → 网络检测」的对话框
Future<void> showNetworkCheck(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(context.l10n.networkCheck),
    contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
    content: const SizedBox(width: 520, child: SingleChildScrollView(child: NetworkCheckPanel())),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.windowClose))],
  ),
);
