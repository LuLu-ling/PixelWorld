import 'package:flutter/material.dart';

import '../core/network_check.dart';

/// 网络检测：同时测各项服务，一行一项显示结果，最后说明「自动选择」会用哪个下载源。
/// 用于首次设置和「设置 → 下载」
class NetworkCheckPanel extends StatefulWidget {
  const NetworkCheckPanel({super.key, this.autoStart = true, this.onDone});

  /// 显示时立即开始检测
  final bool autoStart;

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
              _results[t.id] == null ? (_running ? '检测中…' : '') : describeNet(_results[t.id]!),
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
                      ? '正在检测，最多 8 秒'
                      : [
                          if (!official.ok && !mirror.ok)
                            '两个下载源都连不上，请检查网络或代理设置'
                          else
                            '「自动选择」会优先使用${DownloadSourcePicker.decide(official, mirror) ? ' BMCLAPI 镜像' : '官方源'}，失败时自动换另一个',
                          if (failed > 0 && (official.ok || mirror.ok)) '有 $failed 项连接失败，相关功能可能用不了',
                        ].join('；'),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              TextButton.icon(
                onPressed: _running ? null : _run,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重新检测'),
              ),
            ],
          ),
        ),
      ],
    );
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
    title: const Text('网络检测'),
    contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
    content: const SizedBox(width: 520, child: SingleChildScrollView(child: NetworkCheckPanel())),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
  ),
);
