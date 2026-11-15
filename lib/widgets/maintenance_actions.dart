import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/toolbox.dart';
import '../pages/versions_page.dart';
import 'format.dart';

/// 清理游戏垃圾：日志、崩溃报告与解压出的本地库（设置 → 游戏管理）
Future<void> cleanGameJunk(BuildContext context) async {
  final state = AppScope.read(context);
  final folders = VersionsPage.folders(state.config).map((f) => f.path).toList();
  final junk = findGameJunk(folders);
  final size = junk.fold<int>(0, (s, e) => s + sizeOf(e));
  if (junk.isEmpty) return toast(context, '没有需要清理的文件');
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.cleaning_services_outlined),
      title: const Text('清理游戏垃圾'),
      content: Text(
        '将删除 ${junk.length} 项，共 ${formatSize(size)}：\n'
        '游戏文件夹与各实例文件夹中的日志（logs、*.log）、崩溃报告（crash-reports、hs_err_pid*）'
        '与解压出的本地库（natives，启动时会重新生成）。\n\n存档、模组与设置不会被删除。',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('清理')),
      ],
    ),
  );
  if (ok != true) return;
  final failed = await deleteAll(junk);
  if (context.mounted) {
    toast(context, failed == 0 ? '已清理 ${formatSize(size)}' : '已清理，$failed 项正在被使用，没有删除');
  }
}

/// 在桌面创建启动器的快捷方式（设置 → 其他，仅 Windows）
Future<void> createShortcutWithToast(BuildContext context) async {
  try {
    final path = await createDesktopShortcut();
    if (context.mounted) toast(context, '已创建 $path');
  } catch (e) {
    if (context.mounted) toast(context, errorText(e));
  }
}
