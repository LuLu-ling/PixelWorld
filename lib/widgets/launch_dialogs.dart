import 'dart:async';

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
        title: const Text('支持正版游戏'),
        content: const SizedBox(
          width: 400,
          child: Text(
            '你还没有登录过正版账号。Minecraft 是付费游戏，请购买正版支持开发者。\n\n'
            '可以先去购买页面看看，也可以这次先以离线模式开始游戏，或者以试玩模式体验。'
            '登录一次正版账号后，就不会再出现这个提示了。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, OwnershipChoice.cancel), child: const Text('返回')),
          TextButton(onPressed: () => Navigator.pop(context, OwnershipChoice.demo), child: const Text('试玩')),
          TextButton(onPressed: () => Navigator.pop(context, OwnershipChoice.launch), child: const Text('这次先启动')),
          FilledButton(onPressed: () => Navigator.pop(context, OwnershipChoice.store), child: const Text('带我去商店')),
        ],
      ),
    );
    // 只打开购买页面，不启动游戏
    if (choice == OwnershipChoice.store) await launchUrl(Uri.parse(buyMinecraftUrl));
    if (choice == OwnershipChoice.demo && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('游戏将以试玩模式启动'), behavior: SnackBarBehavior.floating, width: 420));
    }
    return choice ?? OwnershipChoice.cancel;
  }

  @override
  Future<bool> confirmJava(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Java 版本可能不兼容'),
        content: SizedBox(width: 400, child: Text('$message\n\n可以在版本设置中把 Java 改为 Java 8 或自动选择。')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('返回')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('仍然启动')),
        ],
      ),
    );
    return ok == true;
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
            '${AppInfo.name} 由 ${AppInfo.authorName} 维护。如果觉得好用，'
            '能否考虑赞助一下作者？\n\n'
            '本项目免费、没有广告，离不开大家的支持。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('下次再说')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('赞助作者')),
        ],
      ),
    );
    if (ok == true) await launchUrl(Uri.parse(AppInfo.sponsorUrl));
  }
}
