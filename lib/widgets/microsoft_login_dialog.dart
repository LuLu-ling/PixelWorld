import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../core/microsoft.dart';

/// 微软设备代码登录：显示代码，用户在浏览器中输入后自动完成
Future<void> showMicrosoftLogin(BuildContext context) =>
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _MicrosoftLoginDialog());

class _MicrosoftLoginDialog extends StatefulWidget {
  const _MicrosoftLoginDialog();

  @override
  State<_MicrosoftLoginDialog> createState() => _MicrosoftLoginDialogState();
}

class _MicrosoftLoginDialogState extends State<_MicrosoftLoginDialog> {
  late final MicrosoftLogin _login;
  DeviceCode? _code;
  String? _error;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _login = MicrosoftLogin(state.config.msClientId);
    state
        .loginMicrosoft(_login, (c) {
          if (mounted) setState(() => _code = c);
          Clipboard.setData(ClipboardData(text: c.userCode));
          launchUrl(Uri.parse(c.verificationUri));
        })
        .then((acc) {
          if (!mounted) return;
          Navigator.pop(context);
          toast(context, '已登录 ${acc.name}');
        })
        .catchError((Object e) {
          if (e is! LoginCancelled && mounted) setState(() => _error = errorText(e));
        });
  }

  @override
  void dispose() {
    _login.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = _code;
    return AlertDialog(
      icon: const Icon(Icons.account_circle_outlined),
      title: const Text('微软登录'),
      content: SizedBox(
        width: 400,
        child: _error != null
            ? Text(_error!, style: TextStyle(color: theme.colorScheme.error))
            : code == null
            ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LinearProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('已在浏览器中打开登录页面，请输入下面的代码（已复制到剪贴板）：'),
                  const SizedBox(height: 16),
                  SelectableText(
                    code.userCode,
                    style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(code.verificationUri)),
                    child: Text(code.verificationUri),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('等待登录完成'),
                    ],
                  ),
                ],
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(_error != null ? '关闭' : '取消'))],
    );
  }
}
