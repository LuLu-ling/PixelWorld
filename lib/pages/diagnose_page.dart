import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/ai_client.dart';
import '../core/crash.dart';
import '../shell.dart';
import 'ai_page.dart';
import '../widgets/settings_group.dart';
import '../widgets/side_nav.dart';

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
      title: const Text('游戏崩溃了'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${report.title} 非正常退出。'),
            const SizedBox(height: 12),
            if (report.findings.isEmpty)
              Text('没有匹配到已知的问题，可以查看日志，或使用 AI 分析。', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            else
              for (final f in report.findings.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${f.title}：',
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        TextButton(onPressed: () => Navigator.pop(context, 'log'), child: const Text('查看日志')),
        TextButton(onPressed: () => Navigator.pop(context, 'diagnose'), child: const Text('错误分析')),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, 'ai'),
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('AI 分析'),
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
      return const ContentPanel(child: Center(child: Text('没有要分析的内容')));
    }
    final ai = AiSettings.load(state.config);
    final session = report.sessionId == null ? null : state.chats.byId(report.sessionId!);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ContentPanel(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            SettingsGroup(
              title: '环境',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SelectableText(report.environment.join('\n'), style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            SettingsGroup(
              title: '初步判断',
              children: [
                if (report.findings.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Icon(Icons.help_outline),
                    title: Text('没有匹配到已知的问题'),
                    subtitle: Text('可以使用下面的 AI 分析，或查看日志摘录自行判断'),
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
              title: 'AI 分析',
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Icon(Icons.auto_awesome, color: scheme.primary),
                  title: Text(session != null ? '已有 AI 对话' : '用 AI 分析'),
                  subtitle: Text(
                    session != null
                        ? '在 AI 页面继续这次崩溃的对话'
                        : ai.ready
                        ? '新建一个对话，把下面的日志摘录与环境信息发送给 ${ai.host}（${ai.model}）'
                        : '使用你自己的 AI 服务分析日志，需要先填写接口地址、模型和 API Key',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => startAiDiagnosis(context, report),
                    child: Text(session != null ? '查看对话' : 'AI 分析'),
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: '日志摘录',
              children: [
                if (report.sources.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text('没有找到日志'),
                  ),
                for (final s in report.sources)
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(s.name),
                    subtitle: Text('${s.text.length} 个字符，已截取并去除隐私信息'),
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
                    title: const Text('模组列表'),
                    subtitle: Text('${report.mods.length} 个已启用的模组'),
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
