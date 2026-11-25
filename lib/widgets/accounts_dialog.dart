import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/accounts.dart';
import '../core/microsoft.dart';
import 'device_login_dialog.dart';
import 'yggdrasil_login_dialog.dart';
import '../l10n/l10n.dart';

/// 账户管理：切换、添加离线 / 微软 / 外置登录账户、移除
Future<void> showAccountsDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _AccountsDialog());

class _AccountsDialog extends StatefulWidget {
  const _AccountsDialog();

  @override
  State<_AccountsDialog> createState() => _AccountsDialogState();
}

class _AccountsDialogState extends State<_AccountsDialog> {
  final _name = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    final error = AccountStore.validateOfflineName(name);
    if (error != null) return setState(() => _error = error);
    await AppScope.read(context).addOfflineAccount(name);
    _name.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final selected = state.selectedAccount?.id;
    // 验证过正版后才能添加离线账户和外置登录（见 precheck.dart）
    final verified = state.config.hintBuy;
    return AlertDialog(
      title: Text(context.l10n.oobeAccount),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.accounts.accounts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(context.l10n.accountsDialogNoAccountsYet, style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            for (final a in state.accounts.accounts)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: a.id == selected,
                selectedTileColor: scheme.secondaryContainer,
                leading: CircleAvatar(child: Text(a.name.characters.first.toUpperCase())),
                title: Text(a.name),
                subtitle: Text(a.typeLabel),
                onTap: () => state.selectAccount(a.id),
                trailing: IconButton(
                  tooltip: context.l10n.bgImageRemove,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => state.removeAccount(a.id),
                ),
              ),
            if (!verified) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  context.l10n.precheckOwnershipRequired,
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(context.l10n.accountsDialogMicrosoftAccounts, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => showDeviceLogin(
                  context,
                  title: context.l10n.commonSignMicrosoft,
                  create: (onCode) => MicrosoftLogin(state.config.effectiveMsClientId, onCode),
                ),
                icon: const Icon(Icons.login),
                label: Text(context.l10n.commonSignMicrosoft),
              ),
            ),
            if (state.config.effectiveMsClientId.trim().isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.accountsDialogMicrosoftSignNeedsAzure,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 20),
            Text(context.l10n.accountsDialogAddOfflineAccount, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    enabled: verified,
                    decoration: InputDecoration(
                      labelText: context.l10n.accountsDialogUsername,
                      errorText: _error,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: verified ? (_) => _add() : null,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: FilledButton.tonal(onPressed: verified ? _add : null, child: Text(context.l10n.oobeAdd)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(context.l10n.accountsDialogThirdPartyAccounts, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: verified ? () => showYggdrasilLogin(context) : null,
                icon: const Icon(Icons.dns_outlined),
                label: Text(context.l10n.oobeExternalSign),
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.oobeDone))],
    );
  }
}
