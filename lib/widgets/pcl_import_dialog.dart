import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/pcl_import.dart';
import '../pages/file_manager_page.dart';
import '../l10n/l10n.dart';

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
      title: Text(context.l10n.pclImport),
      content: SizedBox(
        width: 460,
        child: r != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.pclImportDialogImportComplete, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (r.settings.isNotEmpty)
                    Text(context.l10n.pclImportDialogSettings(r.settings.join(context.l10n.commonListSeparator))),
                  Text(context.l10n.pclImportDialogAddedGameFoldersAccounts(r.folders, r.accounts)),
                  if (r.skippedAccounts.isNotEmpty)
                    Text(
                      context.l10n.pclImportDialogNotImported(r.skippedAccounts.join(context.l10n.commonListSeparator)),
                    ),
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
                        ? context.l10n.pclImportDialogFoundPCLCEConfiguration(
                            _detection.folders,
                            _detection.hasAccounts ? context.l10n.pclImportDialogAccounts : '',
                          )
                        : context.l10n.pclImportDialogNoPCLCEConfiguration,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.pclImportDialogPerInstanceSettingsDont,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _settings,
                    onChanged: (v) => setState(() => _settings = v!),
                    title: Text(context.l10n.pclImportDialogLaunchSettings),
                    subtitle: Text(context.l10n.pclImportDialogMemoryJVMArgumentsMore),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _folders,
                    onChanged: (v) => setState(() => _folders = v!),
                    title: Text(context.l10n.oobeGameFolder),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _accounts,
                    onChanged: (v) => setState(() => _accounts = v!),
                    title: Text(context.l10n.oobeAccount),
                    subtitle: Text(context.l10n.pclImportDialogImportedMicrosoftAccountsNeed),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _pclDir == null
                              ? context.l10n.pclImportDialogPCLCEFolderNot
                              : context.l10n.pclImportDialogPCLCEFolder(_pclDir!),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(onPressed: _pickDir, child: Text(context.l10n.commonChoose)),
                    ],
                  ),
                  if (_error != null) Text(_error!, style: TextStyle(color: scheme.error)),
                  if (_running) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
                ],
              ),
      ),
      actions: r != null
          ? [FilledButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.oobeDone))]
          : [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
              FilledButton(
                onPressed: _running || (!_detection.found && _pclDir == null) || !(_settings || _folders || _accounts)
                    ? null
                    : _run,
                child: Text(context.l10n.pclImportButton),
              ),
            ],
    );
  }
}
