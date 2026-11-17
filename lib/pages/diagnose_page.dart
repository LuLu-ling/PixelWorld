import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/ai/ai_client.dart';
import '../core/crash.dart';
import '../shell.dart';
import 'ai_page.dart';
import '../widgets/settings_group.dart';
import '../widgets/side_nav.dart';
import '../l10n/l10n.dart';

const _mono = TextStyle(
  fontFamily: 'Consolas',
  fontFamilyFallback: ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
  fontSize: 12.5,
  height: 1.45,
);

/// 打开错误分析页
void openDiagnosis(BuildContext context, CrashReport report) {
  AppScope.read(context).diagnosis = report;
  ShellNav.of(context).open(SubPage.diagnose);
}

/// 游戏崩溃时弹出：显示本地规则的结论，可进入错误分析页
Future<void> showCrashDialog(BuildContext context, CrashReport report) async {
  final theme = Theme.of(context);
  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.error_outline, color: theme.colorScheme.error),
      title: Text(context.l10n.diagnoseGameCrashed),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.diagnoseExitedAbnormally(report.title)),
            const SizedBox(height: 12),
            if (report.findings.isEmpty)
              Text(
                context.l10n.diagnoseNoKnownProblemMatched,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            else
              for (final f in report.findings.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${f.title}${context.l10n.commonColon}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: f.detail),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.windowClose)),
        TextButton(onPressed: () => Navigator.pop(context, 'log'), child: Text(context.l10n.commonViewLog)),
        TextButton(onPressed: () => Navigator.pop(context, 'diagnose'), child: Text(context.l10n.subDiagnose)),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, 'ai'),
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: Text(context.l10n.diagnoseAIAnalysis),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  if (action == 'log') ShellNav.of(context).open(SubPage.log);
  if (action == 'diagnose') openDiagnosis(context, report);
  if (action == 'ai') await startAiDiagnosis(context, report);
}

/// 错误分析：环境、本地规则的结论、日志摘录与 AI 分析
class DiagnosePage extends StatelessWidget {
  const DiagnosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final report = state.diagnosis;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (report == null) {
      return ContentPanel(child: Center(child: Text(context.l10n.diagnoseNothingAnalyze)));
    }
    final ai = AiSettings.load(state.config);
    final session = report.sessionId == null ? null : state.chats.byId(report.sessionId!);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ContentPanel(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            SettingsGroup(
              title: context.l10n.diagnoseEnvironment,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SelectableText(report.environment.join('\n'), style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            SettingsGroup(
              title: context.l10n.diagnoseInitialFindings,
              children: [
                if (report.findings.isEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Icon(Icons.help_outline),
                    title: Text(context.l10n.diagnoseNoKnownProblemMatched2),
                    subtitle: Text(context.l10n.diagnoseUseAIAnalysisBelow),
                  ),
                for (final f in report.findings)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Icon(Icons.lightbulb_outline, color: scheme.primary),
                    title: Text(f.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.detail),
                        if (f.evidence.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          SelectableText(f.evidence.join('\n'), style: _mono.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            SettingsGroup(
              title: context.l10n.diagnoseAIAnalysis,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Icon(Icons.auto_awesome, color: scheme.primary),
                  title: Text(
                    session != null ? context.l10n.diagnoseExistingAIConversation : context.l10n.diagnoseAnalyzeAI,
                  ),
                  subtitle: Text(
                    session != null
                        ? context.l10n.diagnoseContinueCrashsConversationAI
                        : ai.ready
                        ? context.l10n.diagnoseStartsNewConversationSends(ai.host, ai.model)
                        : context.l10n.diagnoseAnalyzeLogYourOwn,
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => startAiDiagnosis(context, report),
                    child: Text(
                      session != null ? context.l10n.diagnoseViewConversation : context.l10n.diagnoseAIAnalysis,
                    ),
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: context.l10n.diagnoseLogExcerpt,
              children: [
                if (report.sources.isEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(context.l10n.diagnoseNoLogsFound),
                  ),
                for (final s in report.sources)
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(s.name),
                    subtitle: Text(context.l10n.diagnoseCharactersTrimmedPrivateInformation(s.text.length)),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 420),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(child: SelectableText(s.text, style: _mono)),
                      ),
                    ],
                  ),
                if (report.mods.isNotEmpty)
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(context.l10n.diagnoseModList),
                    subtitle: Text(context.l10n.diagnoseOtherEnabledMods(report.mods.length)),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(report.mods.join('\n'), style: _mono),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
