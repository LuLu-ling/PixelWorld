import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../l10n/l10n.dart';

/// 用户协议与隐私说明的版本：改了 assets/legal 里的内容就加 1，启动时会请用户重新确认
const agreementVersion = 1;

/// 第一次打开（或协议更新后）请用户确认用户协议和隐私说明；不同意就退出启动器。
/// 返回 true 表示已经同意，可以继续后面的首次运行流程
Future<bool> ensureAgreement(BuildContext context) async {
  final config = AppScope.read(context).config;
  // 全新安装在首次设置里同意（见 oobe.dart）
  if (config.agreementVersion >= agreementVersion || !config.oobeDone) return true;
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
                    confirm
                        ? (updated
                              ? context.l10n.agreementDialogTermsUsePrivacyNotice
                              : context.l10n.commonWelcomePixelWorld)
                        : context.l10n.commonTermsUsePrivacyNotice,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (confirm) ...[
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.agreementDialogPleaseReadTermsUse,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TabBar(
                    tabs: [
                      Tab(text: context.l10n.helpTerms),
                      Tab(text: context.l10n.helpPrivacy),
                    ],
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 420,
                      child: TabBarView(children: [LegalText('terms'), LegalText('privacy')]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: confirm
                        ? [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.commonDeclineQuit),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.l10n.agreementDialogAcceptContinue),
                            ),
                          ]
                        : [
                            FilledButton.tonal(
                              onPressed: () => Navigator.pop(context),
                              child: Text(context.l10n.windowClose),
                            ),
                          ],
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

/// 打包在启动器里的协议正文（对话框和首次设置都用；对话框和首次设置都用）（`assets/legal/<name>.md`），没网也能看
class LegalText extends StatelessWidget {
  const LegalText(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/legal/$name.md'),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        // 标题在外面已经有了，去掉第一行的大标题（文件可能是 CRLF 换行）
        final text = snap.data!.replaceFirst(RegExp(r'^# [^\n]*\n\s*'), '');
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
