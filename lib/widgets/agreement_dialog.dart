import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';

/// 用户协议与隐私说明的版本：改了 assets/legal 里的内容就加 1，启动时会请用户重新确认
const agreementVersion = 1;

/// 第一次打开（或协议更新后）请用户确认用户协议和隐私说明；不同意就退出启动器。
/// 返回 true 表示已经同意，可以继续后面的首次运行流程
Future<bool> ensureAgreement(BuildContext context) async {
  final config = AppScope.read(context).config;
  if (config.agreementVersion >= agreementVersion) return true;
  final updated = config.agreementVersion > 0;
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AgreementDialog(confirm: true, updated: updated),
  );
  if (ok != true) {
    // 不同意：退出启动器
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
    }
    exit(0);
  }
  await config.update({'agreementVersion': agreementVersion});
  return true;
}

/// 只查看（设置 → 关于与致谢）；[tab] 为 0 打开用户协议，1 打开隐私说明
Future<void> showAgreement(BuildContext context, {int tab = 0}) => showDialog<void>(
  context: context,
  builder: (context) => _AgreementDialog(confirm: false, initialTab: tab),
);

class _AgreementDialog extends StatelessWidget {
  const _AgreementDialog({required this.confirm, this.updated = false, this.initialTab = 0});

  /// 需要用户选择同意或不同意（否则只有「关闭」）
  final bool confirm;

  /// 以前同意过旧版本，这次是协议更新后的重新确认
  final bool updated;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: !confirm,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 680, maxHeight: size.height - 32),
          child: DefaultTabController(
            length: 2,
            initialIndex: initialTab,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    confirm ? (updated ? '用户协议与隐私说明已更新' : '欢迎使用 Pixel World') : '用户协议与隐私说明',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (confirm) ...[
                    const SizedBox(height: 6),
                    Text(
                      '使用前请阅读下面的用户协议和隐私说明。简单来说：本软件免费开源，按原样提供；'
                      '我们不收集你的信息，账户和设置都只保存在你的设备上；游戏和模组来自第三方。',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const TabBar(
                    tabs: [
                      Tab(text: '用户协议'),
                      Tab(text: '隐私说明'),
                    ],
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 420,
                      child: TabBarView(children: const [_LegalText('terms'), _LegalText('privacy')]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: confirm
                        ? [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('不同意并退出')),
                            const SizedBox(width: 8),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('同意并继续')),
                          ]
                        : [FilledButton.tonal(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 打包在启动器里的协议正文（`assets/legal/<name>.md`），没网也能看
class _LegalText extends StatelessWidget {
  const _LegalText(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/legal/$name.md'),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        // 标题和生效日期在对话框里已经有了，去掉第一行的大标题
        final text = snap.data!.replaceFirst(RegExp(r'^# .*\n+'), '');
        return Markdown(
          data: text,
          padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
          selectable: true,
          onTapLink: (_, href, _) {
            if (href != null) launchUrl(Uri.parse(href));
          },
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            h2: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        );
      },
    );
  }
}
