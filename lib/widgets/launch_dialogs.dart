import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_state.dart';
import '../core/precheck.dart';
import '../l10n/l10n.dart';
import 'accounts_dialog.dart';

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
        title: Text(context.l10n.launchDialogsVerifyOwnershipFirst),
        content: SizedBox(width: 400, child: Text(context.l10n.launchDialogsOwnershipRequiredBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.cancel),
            child: Text(context.l10n.tooltipBack),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.store),
            child: Text(context.l10n.launchDialogsBuyGame),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.login),
            child: Text(context.l10n.launchDialogsSignInMicrosoft),
          ),
        ],
      ),
    );
    // 两个选择都不启动游戏
    if (choice == OwnershipChoice.store) await launchUrl(Uri.parse(buyMinecraftUrl));
    if (choice == OwnershipChoice.login && context.mounted) await showAccountsDialog(context);
    return choice ?? OwnershipChoice.cancel;
  }

  @override
  Future<bool> confirmJava(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(context.l10n.launchDialogsJavaVersionMayIncompatible),
        content: SizedBox(width: 400, child: Text(context.l10n.launchDialogsYouCanChangeJava(message))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.tooltipBack)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.launchDialogsLaunchAnyway),
          ),
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
        title: Text(context.l10n.launchDialogsOtherTimes(launchCount)),
        content: SizedBox(
          width: 400,
          child: Text(context.l10n.launchDialogsMaintainedIfYouFind(AppInfo.name, AppInfo.authorName)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.launchDialogsMaybeLater)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.aboutSponsor)),
        ],
      ),
    );
    if (ok == true) await launchUrl(Uri.parse(AppInfo.sponsorUrl));
  }
}
