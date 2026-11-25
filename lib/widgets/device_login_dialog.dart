import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../core/accounts.dart';
import '../core/auth/auth.dart';
import '../core/auth/oauth.dart';
import '../core/microsoft.dart';
import '../l10n/l10n.dart';

/// 设备代码登录对话框（微软）。[create] 用展示代码的回调创建登录命令
Future<void> showDeviceLogin(
  BuildContext context, {
  required String title,
  required LoginCommand Function(void Function(DeviceCode) onCode) create,
}) {
  final run = AppScope.read(context).login;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.account_circle_outlined),
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: DeviceLoginPanel(create: create, run: run, onDone: (acc) => loggedIn(context, acc), autoStart: true),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel))],
    ),
  );
}

/// 启动器上次退出前还有没完成的微软登录（安卓上去浏览器授权时启动器可能被系统杀掉）：
/// 重新打开登录对话框，接着等同一个代码，用户已经授权过的话马上就能登录
Future<void> resumePendingMicrosoftLogin(BuildContext context) async {
  final clientId = AppScope.read(context).config.effectiveMsClientId;
  if (clientId.trim().isEmpty) return;
  final pending = await PendingMicrosoftLogin.load(clientId);
  if (pending == null || !context.mounted) return;
  await showDeviceLogin(
    context,
    title: context.l10n.commonSignMicrosoft,
    create: (onCode) => MicrosoftLogin(clientId, onCode, resume: pending),
  );
}

void loggedIn(BuildContext context, Account acc) {
  Navigator.pop(context);
  toast(context, context.l10n.deviceLoginDialogSignedAs(acc.name));
}

/// 设备代码登录的内容：用户点「开始」（或 [autoStart] 时创建后立即）开始，显示代码并打开授权页面，
/// 用户在浏览器中完成后调用 [onDone]；失败或超时可以重试。可以放进任意登录对话框
class DeviceLoginPanel extends StatefulWidget {
  const DeviceLoginPanel({
    super.key,
    required this.create,
    required this.run,
    required this.onDone,
    this.autoStart = false,
    this.intro,
    this.startLabel,
  });

  final LoginCommand Function(void Function(DeviceCode) onCode) create;
  final LoginRunner run;
  final void Function(Account acc) onDone;
  final bool autoStart;

  /// 开始前显示的说明
  final String? intro;

  /// 开始按钮的文字，默认「开始登录」
  final String? startLabel;

  @override
  State<DeviceLoginPanel> createState() => _DeviceLoginPanelState();
}

class _DeviceLoginPanelState extends State<DeviceLoginPanel> with WidgetsBindingObserver {
  LoginCommand? _login;
  DeviceCode? _code;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoStart) _start();
  }

  /// 从浏览器切回启动器时马上查一次，不用等下一个轮询间隔
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) OAuthClient.wakeUp();
  }

  void _start() {
    final login = _login = widget.create(_onCode);
    _code = null;
    _error = null;
    widget
        .run(login)
        .then((acc) {
          if (mounted && identical(login, _login)) widget.onDone(acc);
        })
        .catchError((Object e) {
          if (e is! LoginCancelled && mounted && identical(login, _login)) setState(() => _error = errorText(e));
        });
  }

  void _onCode(DeviceCode c) {
    if (mounted) setState(() => _code = c);
    Clipboard.setData(ClipboardData(text: c.userCode));
    // 接着上次的登录时用户多半已经授权过了，不再自动打开浏览器；需要时点下面的链接
    if (!c.resumed) launchUrl(Uri.parse(c.completeUri ?? c.verificationUri));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _login?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = _code;
    if (_login == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.intro != null) ...[Text(widget.intro!), const SizedBox(height: 16)],
          FilledButton.icon(
            onPressed: () => setState(_start),
            icon: const Icon(Icons.open_in_browser),
            label: Text(widget.startLabel ?? context.l10n.deviceLoginDialogStartSign),
          ),
        ],
      );
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(_start),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.deviceLoginDialogRetry),
          ),
        ],
      );
    }
    if (code == null) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LinearProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          code.resumed
              ? context.l10n.deviceLoginDialogResumed
              : code.completeUri != null
              ? context.l10n.deviceLoginDialogAuthorizationPageHasOpened
              : context.l10n.deviceLoginDialogSignPageHasOpened,
        ),
        const SizedBox(height: 16),
        SelectableText(
          code.userCode,
          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => launchUrl(Uri.parse(code.completeUri ?? code.verificationUri)),
          child: Text(code.verificationUri),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text(context.l10n.deviceLoginDialogWaitingSign),
          ],
        ),
      ],
    );
  }
}
