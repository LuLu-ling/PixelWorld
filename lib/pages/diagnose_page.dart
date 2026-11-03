import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../app_scope.dart';
import '../core/ai_client.dart';
import '../core/crash.dart';
import '../shell.dart';
import '../widgets/ai_settings.dart';
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
        FilledButton(onPressed: () => Navigator.pop(context, 'diagnose'), child: const Text('错误分析')),
      ],
    ),
  );
  if (!context.mounted) return;
  if (action == 'log') ShellNav.of(context).open(SubPage.log);
  if (action == 'diagnose') openDiagnosis(context, report);
}

/// 错误分析：环境、本地规则的结论、日志摘录与 AI 分析
class DiagnosePage extends StatefulWidget {
  const DiagnosePage({super.key});

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  final _input = TextEditingController();
  StreamSubscription<String>? _sub;
  String _streaming = '';
  String? _error;

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    super.dispose();
  }

  bool get _busy => _sub != null;

  /// 发送前让用户看到将要发送的内容
  Future<bool> _confirm(AiSettings s, String text) async {
    final cfg = AppScope.read(context).config;
    if (!cfg.aiConfirm) return true;
    var remember = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('发送以下内容'),
          content: SizedBox(
            width: 640,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('将发送 ${text.length} 个字符到 ${s.host}（模型 ${s.model}）。玩家名、令牌、UUID、用户目录与 IP 地址已替换。'),
                const SizedBox(height: 12),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(child: SelectableText(text, style: _mono)),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('以后不再询问'),
                  value: remember,
                  onChanged: (v) => setLocal(() => remember = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('发送')),
          ],
        ),
      ),
    );
    if (ok == true && remember) await cfg.update({'aiConfirm': false});
    return ok == true;
  }

  Future<void> _send(CrashReport report, String text) async {
    final state = AppScope.read(context);
    final s = AiSettings.load(state.config);
    if (!s.ready) {
      await showAiSettingsDialog(context);
      return;
    }
    // 只有第一次发送日志时确认，之后的追问是用户自己输入的
    if (report.chat.isEmpty && !await _confirm(s, text)) return;
    if (!mounted) return;
    setState(() {
      report.chat.add((role: 'user', content: text));
      _streaming = '';
      _error = null;
    });
    final history = [for (final m in report.chat) AiMessage(m.role, m.content)];
    _sub = aiChat(s, diagnoseSystemPrompt, history).listen(
      (chunk) => setState(() => _streaming += chunk),
      onError: (Object e) => setState(() {
        _error = errorText(e);
        // 失败的提问撤回，可以重试
        report.chat.removeLast();
        _finish(report, keep: false);
      }),
      onDone: () => setState(() => _finish(report)),
      cancelOnError: true,
    );
  }

  void _finish(CrashReport report, {bool keep = true}) {
    if (keep && _streaming.isNotEmpty) report.chat.add((role: 'assistant', content: _streaming));
    _streaming = '';
    _sub = null;
  }

  void _stop(CrashReport report) {
    _sub?.cancel();
    setState(() {
      if (_streaming.isNotEmpty) _streaming += '\n\n（已停止）';
      _finish(report);
    });
  }

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
    // 第一条是自动生成的日志内容，不显示
    final visible = report.chat.skip(1).toList();

    Widget bubble(String role, String text) {
      final user = role == 'user';
      return Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: user ? scheme.primaryContainer : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: user
              ? SelectableText(text, style: TextStyle(color: scheme.onPrimaryContainer))
              : MarkdownBody(
                  data: text,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    code: _mono.copyWith(backgroundColor: scheme.surfaceContainerHighest),
                    codeblockDecoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
        ),
      );
    }

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (report.chat.isEmpty && !_busy)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ai.ready
                                    ? '将日志摘录与环境信息发送给 ${ai.host}（${ai.model}）分析。'
                                    : '使用你自己的 AI 服务分析日志：需要先填写接口地址、模型和 API Key。',
                                style: TextStyle(color: scheme.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (!ai.ready)
                              FilledButton.tonal(
                                onPressed: () async {
                                  await showAiSettingsDialog(context);
                                  setState(() {});
                                },
                                child: const Text('设置'),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _send(report, report.toPrompt()),
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('开始分析'),
                              ),
                          ],
                        ),
                      for (final m in visible) bubble(m.role, m.content),
                      if (_busy)
                        _streaming.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('正在分析…'),
                                  ],
                                ),
                              )
                            : bubble('assistant', _streaming),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('分析失败：$_error', style: TextStyle(color: scheme.error)),
                        ),
                      if (report.chat.isNotEmpty || _busy)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _input,
                                enabled: !_busy,
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: '继续提问，例如“具体要删除哪个模组？”',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _ask(report),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_busy)
                              OutlinedButton(onPressed: () => _stop(report), child: const Text('停止'))
                            else ...[
                              FilledButton(onPressed: () => _ask(report), child: const Text('发送')),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: '复制最后的回答',
                                icon: const Icon(Icons.copy_outlined),
                                onPressed: visible.isEmpty
                                    ? null
                                    : () {
                                        Clipboard.setData(ClipboardData(text: visible.last.content));
                                        toast(context, '已复制');
                                      },
                              ),
                            ],
                          ],
                        ),
                      if (report.chat.isEmpty && _error != null && ai.ready)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => showAiSettingsDialog(context),
                            child: const Text('检查 AI 设置'),
                          ),
                        ),
                    ],
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

  void _ask(CrashReport report) {
    final q = _input.text.trim();
    if (q.isEmpty || _busy) return;
    _input.clear();
    _send(report, q);
  }
}
