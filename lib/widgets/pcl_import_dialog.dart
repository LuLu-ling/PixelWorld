import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/pcl_import.dart';
import '../pages/file_manager_page.dart';

/// 从 PCL-CE 导入设置、游戏文件夹与账户
Future<void> showPclImport(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _PclImportDialog());

class _PclImportDialog extends StatefulWidget {
  const _PclImportDialog();

  @override
  State<_PclImportDialog> createState() => _PclImportDialogState();
}

class _PclImportDialogState extends State<_PclImportDialog> {
  final _detection = detectPcl();
  bool _settings = true;
  bool _folders = true;
  bool _accounts = true;
  String? _pclDir;
  bool _running = false;
  PclImportResult? _result;
  String? _error;

  Future<void> _pickDir() async {
    final dir = await pickFolder(context);
    if (dir != null) setState(() => _pclDir = dir);
  }

  Future<void> _run() async {
    final state = AppScope.read(context);
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final r = await importFromPcl(
        state.config,
        state.accounts,
        settings: _settings,
        folders: _folders,
        accounts: _accounts,
        pclDir: _pclDir,
      );
      await state.refreshVersions();
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = _result;
    return AlertDialog(
      icon: const Icon(Icons.move_down),
      title: const Text('从 PCL-CE 导入'),
      content: SizedBox(
        width: 460,
        child: r != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('导入完成', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (r.settings.isNotEmpty) Text('设置：${r.settings.join('、')}'),
                  Text('新增游戏文件夹 ${r.folders} 个，账户 ${r.accounts} 个'),
                  if (r.skippedAccounts.isNotEmpty) Text('未导入：${r.skippedAccounts.join('、')}'),
                  for (final w in r.warnings)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(w, style: TextStyle(color: scheme.error)),
                    ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _detection.found
                        ? '检测到 PCL-CE 的配置：${_detection.folders} 个游戏文件夹${_detection.hasAccounts ? '，有账户' : ''}'
                        : r'没有在 %APPDATA%\PCLCE 找到 PCL-CE 的配置，可以选择 PCL-CE 所在目录导入本地设置',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '版本独立设置无需导入，两者直接共用。',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings,
                    onChanged: (v) => setState(() => _settings = v!),
                    title: const Text('启动设置'),
                    subtitle: const Text('内存、JVM 参数等需要选择 PCL-CE 所在目录'),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _folders,
                    onChanged: (v) => setState(() => _folders = v!),
                    title: const Text('游戏文件夹'),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _accounts,
                    onChanged: (v) => setState(() => _accounts = v!),
                    title: const Text('账户'),
                    subtitle: const Text('导入的微软账户过期后需要在这里重新登录'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _pclDir == null ? 'PCL-CE 所在目录：未选择（可选）' : 'PCL-CE 所在目录：$_pclDir',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(onPressed: _pickDir, child: const Text('选择')),
                    ],
                  ),
                  if (_error != null) Text(_error!, style: TextStyle(color: scheme.error)),
                  if (_running) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
                ],
              ),
      ),
      actions: r != null
          ? [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('完成'))]
          : [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              FilledButton(
                onPressed: _running || (!_detection.found && _pclDir == null) || !(_settings || _folders || _accounts)
                    ? null
                    : _run,
                child: const Text('导入'),
              ),
            ],
    );
  }
}
