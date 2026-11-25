import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/modrinth.dart';
import '../core/task.dart';
import '../l10n/l10n.dart';

/// TouchController 在 Modrinth 上的项目 id
const touchControllerProject = 'U7KwGAnT';

/// 游戏退出后推荐 TouchController（安卓上用自带虚拟按键玩了一会儿、正常退出后，见 AppState.touchControllerTips）
Future<void> showTouchControllerTip(BuildContext context, String instanceId) =>
    _suggest(context, instanceId, beforeLaunch: false);

/// 启动前推荐 TouchController（DialogLaunchPrompts.suggestTouchController）；选择安装时等装好再返回，这次启动就用上
Future<void> suggestTouchControllerBeforeLaunch(BuildContext context, String instanceId) =>
    _suggest(context, instanceId, beforeLaunch: true);

/// 先查 Modrinth 上有没有适合这个实例的版本，没有或查不到就不打扰；启动前、退出后各推荐一次
Future<void> _suggest(BuildContext context, String instanceId, {required bool beforeLaunch}) async {
  final state = AppScope.read(context);
  final inst = state.instance(instanceId);
  if (inst == null) return;
  final List<ResourceVersion> candidates;
  try {
    candidates = await Modrinth.versions(
      touchControllerProject,
      gameVersion: inst.gameVersion,
      loaders: modrinthLoaders(inst.loader),
    ).timeout(const Duration(seconds: 8));
  } catch (_) {
    return; // 网络不通时下次再说，不耽误启动
  }
  final best = candidates.where((v) => v.type == 'release').firstOrNull ?? candidates.firstOrNull;
  if (!context.mounted) return;
  final config = state.config;
  await config.update(
    beforeLaunch
        ? {
            'touchControllerLaunchTipped': [...config.touchControllerLaunchTipped, instanceId],
          }
        : {
            'touchControllerTipped': [...config.touchControllerTipped, instanceId],
          },
  );
  if (best == null || !context.mounted) return;

  final choice = await showDialog<String>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      return AlertDialog(
        icon: const Icon(Icons.touch_app_outlined),
        title: Text(l10n.touchTipTitle),
        content: SizedBox(
          width: 420,
          child: Text(beforeLaunch ? l10n.touchTipBodyLaunch(inst.id) : l10n.touchTipBody(inst.id)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'never'), child: Text(l10n.touchTipNever)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(beforeLaunch ? l10n.touchTipLaunchAnyway : l10n.updateDialogLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'install'),
            child: Text(beforeLaunch ? l10n.touchTipInstallAndLaunch : l10n.touchTipInstall),
          ),
        ],
      );
    },
  );
  if (choice == 'never') {
    await config.update({'touchControllerTip': false});
    return;
  }
  if (choice != 'install') return;
  try {
    await state.installResource(best, ResourceType.mod, inst);
    // 启动前装的马上就用上，不用提示「下次启动生效」
    if (!beforeLaunch && context.mounted) toast(context, context.l10n.touchTipInstalled(inst.id));
  } catch (e) {
    // 装不上时照常启动，用自带的虚拟按键
    if (context.mounted) {
      toast(
        context,
        e is TaskCancelled ? context.l10n.commonTaskCanceled : context.l10n.commonInstallationFailed(errorText(e)),
      );
    }
  }
}
