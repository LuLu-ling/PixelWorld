import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../core/android_storage.dart';
import '../core/instance_files.dart';
import '../core/paths.dart';
import '../pages/file_manager_page.dart';
import '../platform.dart';
import 'settings_group.dart';

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
      title: const Text('游戏文件放在哪里？'),
      content: const SizedBox(
        width: 560,
        child: Text(
          '放在手机存储（Pixel World/.minecraft）：卸载或重装启动器后游戏、存档仍然保留，'
          '也可以用其他应用管理这些文件。需要授予「所有文件访问权限」。\n\n'
          '放在应用内部：不需要权限，但卸载启动器时游戏、存档会一起被删除。\n\n'
          '之后可以在「设置 → 游戏管理」中更改。',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('应用内部')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('手机存储（推荐）')),
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
      if (context.mounted) toast(context, '没有获得「所有文件访问权限」，游戏文件夹没有更改');
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
        title: const Text('移动游戏文件'),
        content: Text('把现在游戏文件夹中的版本、存档与资源移到新位置吗？\n\n$from\n→ $to'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('只切换，不移动')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('移动')),
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
  if (context.mounted) toast(context, '游戏文件夹已更改为 $to');
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
      title: Text(_error == null ? '正在移动游戏文件' : '移动失败'),
      content: SizedBox(
        width: 480,
        child: _error != null
            ? Text('${errorText(_error!)}\n\n已经移动的文件在新位置，其余文件仍在原位置。')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
                  const SizedBox(height: 12),
                  Text(_total == 0 ? '正在统计文件…' : '$_done / $_total 个文件，请不要关闭启动器'),
                ],
              ),
      ),
      actions: [
        if (_error != null) TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('关闭')),
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
          title: '游戏文件夹',
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.folder_outlined),
              title: const Text('当前游戏文件夹'),
              subtitle: Text(dir),
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: () => openInFileManager(dir), child: const Text('打开')),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await pickFolder(context, start: dir);
                      if (picked != null) await state.selectFolder(picked);
                    },
                    child: const Text('更改'),
                  ),
                ],
              ),
            ),
            if (Platform.isAndroid)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.smartphone),
                title: const Text('存放位置'),
                subtitle: Text(
                  shared ? '手机存储：卸载启动器后仍然保留' : '应用内部：卸载启动器时会一起删除，建议移到手机存储',
                ),
                trailing: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('手机存储')),
                    ButtonSegment(value: false, label: Text('应用内部')),
                  ],
                  selected: {shared},
                  onSelectionChanged: (s) => changeStorage(context, toShared: s.first),
                ),
              ),
          ],
        ),
        if (!isDesktop)
          SettingsGroup(
            title: '文件',
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.folder_copy_outlined),
                title: const Text('文件管理'),
                subtitle: const Text('浏览、导入、复制或删除游戏文件；删除的文件会先放进回收站'),
                trailing: FilledButton.tonal(onPressed: () => openInFileManager(dir), child: const Text('打开')),
              ),
            ],
          ),
      ],
    );
  }
}
