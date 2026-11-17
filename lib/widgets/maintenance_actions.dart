import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/toolbox.dart';
import '../pages/versions_page.dart';
import 'format.dart';
import '../l10n/l10n.dart';

/// 清理游戏垃圾：日志、崩溃报告与解压出的本地库（设置 → 游戏管理）
Future<void> cleanGameJunk(BuildContext context) async {
  final state = AppScope.read(context);
  final folders = VersionsPage.folders(state.config, context.l10n).map((f) => f.path).toList();
  final junk = findGameJunk(folders);
  final size = junk.fold<int>(0, (s, e) => s + sizeOf(e));
  if (junk.isEmpty) return toast(context, context.l10n.maintenanceActionsNothingCleanUp);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.cleaning_services_outlined),
      title: Text(context.l10n.commonCleanUpGameJunk),
      content: Text(context.l10n.maintenanceActionsItemsWillDeletedLogs(junk.length, formatSize(size))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.commonCleanUp)),
      ],
    ),
  );
  if (ok != true) return;
  final failed = await deleteAll(junk);
  if (context.mounted) {
    toast(
      context,
      failed == 0
          ? context.l10n.maintenanceActionsCleanedUp(formatSize(size))
          : context.l10n.maintenanceActionsOtherItemsUseWerent(failed),
    );
  }
}

/// 在桌面创建启动器的快捷方式（设置 → 其他，仅 Windows）
Future<void> createShortcutWithToast(BuildContext context) async {
  try {
    final path = await createDesktopShortcut();
    if (context.mounted) toast(context, context.l10n.maintenanceActionsCreated(path));
  } catch (e) {
    if (context.mounted) toast(context, errorText(e));
  }
}
