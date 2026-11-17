import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../core/android_storage.dart';
import '../core/instance_files.dart';
import '../core/paths.dart';
import '../pages/file_manager_page.dart';
import '../platform.dart';
import 'maintenance_actions.dart';
import 'settings_group.dart';
import '../l10n/l10n.dart';

String get _internalGameDir => p.join(Paths.appData, '.minecraft');

bool _hasContent(String dir) {
  try {
    return Directory(dir).existsSync() && Directory(dir).listSync().isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// 安卓首次打开时询问游戏文件夹放在哪里
Future<void> askStorageOnFirstRun(BuildContext context) async {
  final state = AppScope.read(context);
  if (!Platform.isAndroid || state.config.storageAsked) return;
  final shared = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.oobeWhereShouldGameFiles),
      content: SizedBox(width: 560, child: Text(context.l10n.storageLocationPhoneStoragePixelWorld)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.oobeAppStorage)),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.storageLocationPhoneStorageRecommended),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  await state.config.update({'storageAsked': true});
  if (shared == true && context.mounted) await changeStorage(context, toShared: true);
}

/// 把游戏文件夹移到手机存储或应用内部
Future<void> changeStorage(BuildContext context, {required bool toShared}) async {
  final state = AppScope.read(context);
  if (toShared && !await AndroidStorage.hasAccess()) {
    if (!await AndroidStorage.requestAccess()) {
      if (context.mounted) toast(context, context.l10n.storageLocationAllFilesAccessWasnt);
      return;
    }
  }
  if (!context.mounted) return;
  final from = state.config.gameDir;
  final to = toShared ? AndroidStorage.gameDir : _internalGameDir;
  if (p.equals(from, to)) return;
  if (_hasContent(from)) {
    final move = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.storageLocationMoveGameFiles),
        content: Text(context.l10n.storageLocationMoveInstancesWorldsResources(from, to)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.storageLocationJustSwitchDontMove),
          ),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.storageLocationMove)),
        ],
      ),
    );
    if (move == null || !context.mounted) return;
    if (move) {
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _MoveDialog(from: from, to: to),
      );
      if (ok != true) return;
    }
  }
  await state.selectFolder(to);
  if (context.mounted) toast(context, context.l10n.storageLocationGameFolderChanged(to));
}

class _MoveDialog extends StatefulWidget {
  const _MoveDialog({required this.from, required this.to});

  final String from;
  final String to;

  @override
  State<_MoveDialog> createState() => _MoveDialogState();
}

class _MoveDialogState extends State<_MoveDialog> {
  int _done = 0;
  int _total = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final total = await Future(() => countFiles(widget.from));
    if (!mounted) return;
    setState(() => _total = total);
    try {
      await mergeMove(
        widget.from,
        widget.to,
        onFile: (_) {
          _done++;
          if (mounted && (_done % 25 == 0 || _done == _total)) setState(() {});
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _error == null ? context.l10n.storageLocationMovingGameFiles : context.l10n.storageLocationMoveFailed,
      ),
      content: SizedBox(
        width: 480,
        child: _error != null
            ? Text(context.l10n.storageLocationFilesWereAlreadyMoved(errorText(_error!)))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
                  const SizedBox(height: 12),
                  Text(
                    _total == 0
                        ? context.l10n.storageLocationCountingFiles
                        : context.l10n.storageLocationFilesPleaseDontClose(_done, _total),
                  ),
                ],
              ),
      ),
      actions: [
        if (_error != null)
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.windowClose)),
      ],
    );
  }
}

/// 设置 → 游戏管理
class GameStorageSection extends StatelessWidget {
  const GameStorageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dir = state.config.gameDir;
    final shared = AndroidStorage.isShared(dir);
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: context.l10n.oobeGameFolder,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.folder_outlined),
              title: Text(context.l10n.storageLocationCurrentGameFolder),
              subtitle: Text(dir),
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: () => openInFileManager(dir), child: Text(context.l10n.commonOpen)),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await pickFolder(context, start: dir);
                      if (picked != null) await state.selectFolder(picked);
                    },
                    child: Text(context.l10n.storageLocationChange),
                  ),
                ],
              ),
            ),
            if (Platform.isAndroid)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.smartphone),
                title: Text(context.l10n.storageLocationStorageLocation),
                subtitle: Text(
                  shared
                      ? context.l10n.storageLocationPhoneStorageKeptWhen
                      : context.l10n.storageLocationAppStorageDeletedWhen,
                ),
                trailing: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(context.l10n.oobePhoneStorage)),
                    ButtonSegment(value: false, label: Text(context.l10n.oobeAppStorage)),
                  ],
                  selected: {shared},
                  onSelectionChanged: (s) => changeStorage(context, toShared: s.first),
                ),
              ),
          ],
        ),
        SettingsGroup(
          title: context.l10n.storageLocationMaintenance,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(context.l10n.commonCleanUpGameJunk),
              subtitle: Text(context.l10n.storageLocationDeletesLogsCrashReports),
              trailing: FilledButton.tonal(
                onPressed: () => cleanGameJunk(context),
                child: Text(context.l10n.commonCleanUp),
              ),
            ),
          ],
        ),
        if (!isDesktop)
          SettingsGroup(
            title: context.l10n.navFiles,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.folder_copy_outlined),
                title: Text(context.l10n.storageLocationFileManager),
                subtitle: Text(context.l10n.storageLocationBrowseImportCopyDelete),
                trailing: FilledButton.tonal(
                  onPressed: () => openInFileManager(dir),
                  child: Text(context.l10n.commonOpen),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
