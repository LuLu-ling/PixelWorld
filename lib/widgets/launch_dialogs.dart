import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_state.dart';
import '../core/precheck.dart';

/// 正版购买劝导与赞助劝导的对话框
class DialogLaunchPrompts implements LaunchPrompts {
  DialogLaunchPrompts(this.context);

  final BuildContext context;

  @override
  Future<OwnershipChoice> askOwnership() async {
    final choice = await showDialog<OwnershipChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.verified_user_outlined),
        title: const Text('需要正版账号'),
        content: const SizedBox(
          width: 400,
          child: Text(
            '登录过一次正版账号后，才能使用离线账户启动游戏。\n\n'
            '还没有 Minecraft 的话，可以先购买正版支持开发者，或者以试玩模式体验。'
            '登录一次正版账号后，就不会再出现这个提示了。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, OwnershipChoice.cancel), child: const Text('返回')),
          TextButton(onPressed: () => Navigator.pop(context, OwnershipChoice.demo), child: const Text('试玩')),
          FilledButton(onPressed: () => Navigator.pop(context, OwnershipChoice.buy), child: const Text('购买正版')),
        ],
      ),
    );
    if (choice == OwnershipChoice.buy) await launchUrl(Uri.parse(buyMinecraftUrl));
    if (choice == OwnershipChoice.demo && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('游戏将以试玩模式启动'), behavior: SnackBarBehavior.floating, width: 420));
    }
    return choice ?? OwnershipChoice.cancel;
  }

  @override
  Future<void> askSponsor(int launchCount) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.favorite_outline),
        title: Text('已经启动 $launchCount 次游戏啦'),
        content: const SizedBox(
          width: 400,
          child: Text(
            '${AppInfo.name} 基于 PCL 二次创作。如果觉得好用，'
            '能否考虑赞助一下 PCL 的作者${AppInfo.pclAuthor}？\n\n'
            'PCL 一直免费、没有广告，离不开大家的支持。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('下次再说')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('赞助作者')),
        ],
      ),
    );
    if (ok == true) await launchUrl(Uri.parse(AppInfo.pclSponsorUrl));
  }
}
