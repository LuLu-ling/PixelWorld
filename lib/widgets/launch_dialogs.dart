import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_state.dart';
import '../core/accounts.dart';
import '../core/precheck.dart';
import '../l10n/l10n.dart';

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
        title: Text(context.l10n.launchDialogsSupportFullGame),
        content: SizedBox(width: 400, child: Text(context.l10n.launchDialogsYouHaventSignedMicrosoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.cancel),
            child: Text(context.l10n.tooltipBack),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.demo),
            child: Text(context.l10n.launchDialogsDemo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.launch),
            child: Text(context.l10n.launchDialogsLaunchTime),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, OwnershipChoice.store),
            child: Text(context.l10n.launchDialogsTakeMeStore),
          ),
        ],
      ),
    );
    // 只打开购买页面，不启动游戏
    if (choice == OwnershipChoice.store) await launchUrl(Uri.parse(buyMinecraftUrl));
    if (choice == OwnershipChoice.demo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.launchDialogsGameWillStartDemo),
          behavior: SnackBarBehavior.floating,
          width: 420,
        ),
      );
    }
    return choice ?? OwnershipChoice.cancel;
  }

  @override
  Future<String?> askPassword(Account acc) =>
      showDialog<String>(context: context, barrierDismissible: false, builder: (_) => _PasswordDialog(acc));

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

/// 外置登录的令牌无法续期时重新输入密码；返回密码，取消时返回 null
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog(this.acc);

  final Account acc;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text.isNotEmpty) Navigator.pop(context, _password.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.lock_outline),
    title: Text(context.l10n.launchDialogsSignAgain(widget.acc.serverName ?? '')),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.launchDialogsSignHasExpiredEnter(widget.acc.name, widget.acc.login ?? '')),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            autofocus: true,
            obscureText: true,
            decoration: InputDecoration(labelText: context.l10n.commonPassword, border: const OutlineInputBorder()),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.launchDialogsCancelLaunch)),
      FilledButton(onPressed: _submit, child: Text(context.l10n.commonSign)),
    ],
  );
}
