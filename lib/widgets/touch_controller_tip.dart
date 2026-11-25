import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/modrinth.dart';
import '../core/task.dart';
import '../l10n/l10n.dart';

/// TouchController 在 Modrinth 上的项目 id
const touchControllerProject = 'U7KwGAnT';

/// 推荐 TouchController（安卓上用自带虚拟按键玩了一会儿、正常退出后，见 AppState.touchControllerTips）。
/// 先查 Modrinth 上有没有适合这个实例的版本，没有或查不到就不打扰；每个实例只推荐一次
Future<void> showTouchControllerTip(BuildContext context, String instanceId) async {
  final state = AppScope.read(context);
  final inst = state.instance(instanceId);
  if (inst == null) return;
  final List<ResourceVersion> candidates;
  try {
    candidates = await Modrinth.versions(
      touchControllerProject,
      gameVersion: inst.gameVersion,
      loaders: modrinthLoaders(inst.loader),
    );
  } catch (_) {
    return; // 网络不通时下次退出游戏再说
  }
  final best = candidates.where((v) => v.type == 'release').firstOrNull ?? candidates.firstOrNull;
  if (!context.mounted) return;
  await state.config.update({
    'touchControllerTipped': [...state.config.touchControllerTipped, instanceId],
  });
  if (best == null || !context.mounted) return;

  final choice = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.touch_app_outlined),
      title: Text(context.l10n.touchTipTitle),
      content: SizedBox(width: 420, child: Text(context.l10n.touchTipBody(inst.id))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, 'never'), child: Text(context.l10n.touchTipNever)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.updateDialogLater)),
        FilledButton(onPressed: () => Navigator.pop(context, 'install'), child: Text(context.l10n.touchTipInstall)),
      ],
    ),
  );
  if (choice == 'never') {
    await state.config.update({'touchControllerTip': false});
    return;
  }
  if (choice != 'install') return;
  try {
    await state.installResource(best, ResourceType.mod, inst);
    if (context.mounted) toast(context, context.l10n.touchTipInstalled(inst.id));
  } catch (e) {
    if (context.mounted) {
      toast(
        context,
        e is TaskCancelled ? context.l10n.commonTaskCanceled : context.l10n.commonInstallationFailed(errorText(e)),
      );
    }
  }
}
