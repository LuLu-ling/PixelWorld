import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../app_scope.dart';
import '../core/ai_chat.dart';
import '../core/ai_client.dart';
import '../core/ai_prompt.dart';
import '../core/crash.dart';
import '../shell.dart';
import '../widgets/ai_settings.dart';
import '../widgets/side_nav.dart';

const _mono = TextStyle(
  fontFamily: 'Consolas',
  fontFamilyFallback: ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
  fontSize: 12.5,
  height: 1.45,
);

/// 新对话页显示的示例问题
const _suggestions = ['游戏启动后闪退，应该从哪里查原因？', '1.20.1 的 Fabric 有哪些常用的优化模组？', 'Forge 和 NeoForge 有什么区别？', '怎么给某个版本分配更多内存？'];

/// 用 AI 分析崩溃：确认发送内容后新建会话，并切换到 AI 页
Future<void> startAiDiagnosis(BuildContext context, CrashReport report) async {
  final state = AppScope.read(context);
  final nav = ShellNav.of(context);
  final existing = report.sessionId == null ? null : state.chats.byId(report.sessionId!);
  if (existing != null) {
    state.chats.open(existing.id);
    nav.goMain(MainPage.ai);
    return;
  }
  var ai = AiSettings.load(state.config);
  if (!ai.ready) {
    await showAiSettingsDialog(context);
    ai = AiSettings.load(state.config);
    if (!ai.ready || !context.mounted) return;
  }
  final text = '$crashMessageLead\n\n${report.toPrompt()}';
  if (!await confirmAiSend(context, ai, text)) return;
  final s = state.chats.send(null, text, ai, title: '崩溃分析 · ${report.title}');
  report.sessionId = s.id;
  nav.goMain(MainPage.ai);
}

/// 发送日志前让用户看到将要发送的内容（可在设置中关闭）
Future<bool> confirmAiSend(BuildContext context, AiSettings ai, String text) async {
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
              Text('将发送 ${text.length} 个字符到 ${ai.host}（模型 ${ai.model}）。玩家名、令牌、UUID、用户目录与 IP 地址已替换。'),
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

/// AI 助手：左侧会话列表，右侧对话
class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = AppScope.read(context).chats;
    return ListenableBuilder(
      listenable: chats,
      builder: (context, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SessionList(chats: chats),
          Expanded(
            child: ContentPanel(
              child: _ChatView(key: ValueKey(chats.currentId), chats: chats, session: chats.current),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- 会话列表 ----------

class _SessionList extends StatelessWidget {
  const _SessionList({required this.chats});

  final ChatStore chats;

  Future<void> _rename(BuildContext context, ChatSession s) async {
    final ctrl = TextEditingController(text: s.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('确定')),
        ],
      ),
    );
    ctrl.dispose();
    if (title != null) await chats.rename(s, title);
  }

  Future<void> _delete(BuildContext context, ChatSession s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('删除「${s.title}」？删除后无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) await chats.delete(s);
  }

  static String _when(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(t.year, t.month, t.day)).inDays;
    if (days == 0) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (days == 1) return '昨天';
    if (days < 7) return '$days 天前';
    return '${t.month} 月 ${t.day} 日';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 248,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: FilledButton.tonalIcon(
              onPressed: () => chats.open(null),
              icon: const Icon(Icons.add),
              label: const Text('新对话'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 16, 8),
            child: Text('历史对话', style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: chats.sessions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text('还没有对话', style: TextStyle(color: scheme.onSurfaceVariant)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: chats.sessions.length,
                    itemBuilder: (context, i) {
                      final s = chats.sessions[i];
                      final selected = s.id == chats.currentId;
                      final fg = selected ? scheme.onSecondaryContainer : scheme.onSurface;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Material(
                          color: selected ? scheme.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => chats.open(s.id),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge?.copyWith(color: fg),
                                        ),
                                        Text(
                                          chats.isBusy(s.id) ? '正在回答…' : _when(s.updated),
                                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: '更多',
                                    icon: Icon(Icons.more_horiz, size: 18, color: scheme.onSurfaceVariant),
                                    onSelected: (v) => v == 'rename' ? _rename(context, s) : _delete(context, s),
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'rename', child: Text('重命名')),
                                      PopupMenuItem(value: 'delete', child: Text('删除')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------- 对话 ----------

class _ChatView extends StatefulWidget {
  const _ChatView({super.key, required this.chats, required this.session});

  final ChatStore chats;
  final ChatSession? session;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  /// 用户往上翻看时不自动滚到底部
  bool _follow = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      _follow = _scroll.position.maxScrollExtent - _scroll.offset < 80;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    final s = widget.session;
    if (text.isEmpty || (s != null && widget.chats.isBusy(s.id))) return;
    final state = AppScope.read(context);
    var ai = AiSettings.load(state.config);
    if (!ai.ready) {
      await showAiSettingsDialog(context);
      ai = AiSettings.load(state.config);
      if (!ai.ready) return;
    }
    _input.clear();
    _follow = true;
    widget.chats.send(s, text, ai);
  }

  void _retry() {
    final s = widget.session;
    if (s == null) return;
    final ai = AiSettings.load(AppScope.read(context).config);
    if (!ai.ready) {
      showAiSettingsDialog(context);
      return;
    }
    widget.chats.retry(s, ai);
  }

  /// Enter 发送，Shift + Enter 换行；输入法正在输入时不处理
  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent || e.logicalKey != LogicalKeyboardKey.enter) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isShiftPressed || _input.value.composing.isValid) return KeyEventResult.ignored;
    _send();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final ai = AiSettings.load(state.config);
    final s = widget.session;
    final busy = s != null && widget.chats.isBusy(s.id);
    final streaming = s == null ? null : widget.chats.streamingOf(s.id);
    final error = s == null ? null : widget.chats.errorOf(s.id);
    if (_follow) WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());

    final messages = s?.messages ?? const <ChatMessage>[];

    return Column(
      children: [
        // 标题栏：会话名与当前模型
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(s?.title ?? '新对话', overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
              ),
              if (ai.ready)
                Text(ai.model, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
              IconButton(
                tooltip: 'AI 设置',
                icon: const Icon(Icons.tune),
                onPressed: () => showAiSettingsDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty && !busy
              ? _Welcome(ready: ai.ready, onPick: _send)
              : SelectionArea(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
                    children: [
                      for (var i = 0; i < messages.length; i++)
                        messages[i].isUser
                            ? _UserMessage(text: messages[i].content)
                            : _AssistantMessage(
                                text: messages[i].content,
                                // 只有最后一条是回答时才能重新生成
                                onRetry: i == messages.length - 1 && !busy ? _retry : null,
                              ),
                      if (busy)
                        (streaming ?? '').isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('正在思考…'),
                                  ],
                                ),
                              )
                            : _AssistantMessage(text: streaming!),
                      if (error != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(error, style: TextStyle(color: scheme.onErrorContainer)),
                              ),
                              TextButton(onPressed: () => showAiSettingsDialog(context), child: const Text('设置')),
                              TextButton(onPressed: _retry, child: const Text('重试')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        // 输入框
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
          child: Container(
            decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: '输入问题，Enter 发送，Shift + Enter 换行',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: busy
                      ? IconButton.filledTonal(
                          tooltip: '停止',
                          onPressed: () => widget.chats.stop(s),
                          icon: const Icon(Icons.stop),
                        )
                      : ListenableBuilder(
                          listenable: _input,
                          builder: (context, _) => IconButton.filled(
                            tooltip: '发送',
                            onPressed: _input.text.trim().isEmpty ? null : _send,
                            icon: const Icon(Icons.arrow_upward),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.ready, required this.onPick});

  final bool ready;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 40, color: scheme.primary),
              const SizedBox(height: 12),
              Text('有什么可以帮你？', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '可以问我 Minecraft 和启动器的问题；游戏崩溃时，在错误分析中选择「AI 分析」会自动带上日志。',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (!ready)
                Card.filled(
                  color: scheme.surfaceContainerHigh,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.key_outlined),
                    title: const Text('先设置 AI 服务'),
                    subtitle: const Text('填写你自己的 AI 服务的接口地址、模型和 API Key'),
                    trailing: FilledButton.tonal(
                      onPressed: () => showAiSettingsDialog(context),
                      child: const Text('设置'),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [for (final q in _suggestions) ActionChip(label: Text(q), onPressed: () => onPick(q))],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户消息：右侧气泡；很长的内容（例如崩溃日志）默认折叠
class _UserMessage extends StatefulWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  State<_UserMessage> createState() => _UserMessageState();
}

class _UserMessageState extends State<_UserMessage> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = widget.text.split('\n');
    final long = widget.text.length > 600 || lines.length > 12;
    final shown = long && !_expanded ? '${lines.take(6).join('\n')}\n…' : widget.text;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shown, style: TextStyle(color: scheme.onPrimaryContainer, height: 1.45)),
            if (long)
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? '收起' : '展开全部（${widget.text.length} 个字符）'),
              ),
          ],
        ),
      ),
    );
  }
}

/// AI 回答：Markdown，下方有复制与重新生成
class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                code: _mono.copyWith(backgroundColor: scheme.surfaceContainerHighest),
                codeblockDecoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '复制',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_outlined),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  toast(context, '已复制');
                },
              ),
              if (onRetry != null)
                IconButton(
                  tooltip: '重新生成',
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
