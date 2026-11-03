import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'accounts.dart' show newId;
import 'ai_client.dart';
import 'ai_prompt.dart';
import 'ai_tools.dart';
import 'paths.dart';

/// 工具调用的结果状态
enum ToolStatus { done, denied, error, cancelled }

class ChatMessage {
  ChatMessage(
    this.role,
    this.content, {
    DateTime? time,
    this.toolCalls = const [],
    this.blocks,
    this.reasoning,
    this.toolCallId,
    this.status,
    this.title,
    this.details = const [],
  }) : time = time ?? DateTime.now();

  /// user、assistant 或 tool（工具结果，显示在对应的工具卡片里）
  final String role;

  /// 文字；工具结果为返回给模型的内容
  final String content;
  final DateTime time;

  /// assistant：请求调用的工具
  final List<AiToolCall> toolCalls;

  /// assistant：需要原样传回接口的内容（见 [AiMessage]）
  final List<Map<String, dynamic>>? blocks;
  final String? reasoning;

  /// tool：对应的调用、状态，以及确认卡片上的标题与详情
  final String? toolCallId;
  final ToolStatus? status;
  final String? title;
  final List<String> details;

  bool get isUser => role == 'user';
  bool get isTool => role == 'tool';

  AiMessage toAi() => AiMessage(
    role,
    content,
    toolCalls: toolCalls,
    blocks: blocks,
    reasoning: reasoning,
    toolCallId: toolCallId,
    isError: status == ToolStatus.error,
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'time': time.toIso8601String(),
    if (toolCalls.isNotEmpty) 'toolCalls': [for (final c in toolCalls) c.toJson()],
    'blocks': ?blocks,
    'reasoning': ?reasoning,
    'toolCallId': ?toolCallId,
    'status': ?status?.name,
    'title': ?title,
    if (details.isNotEmpty) 'details': details,
  };

  static ChatMessage fromJson(Map<String, dynamic> j) => ChatMessage(
    '${j['role']}',
    '${j['content']}',
    time: DateTime.tryParse('${j['time']}'),
    toolCalls: [
      for (final c in (j['toolCalls'] as List? ?? const []).whereType<Map<String, dynamic>>()) AiToolCall.fromJson(c),
    ],
    blocks: (j['blocks'] as List?)?.whereType<Map<String, dynamic>>().toList(),
    reasoning: j['reasoning'] as String?,
    toolCallId: j['toolCallId'] as String?,
    status: ToolStatus.values.asNameMap()[j['status']],
    title: j['title'] as String?,
    details: (j['details'] as List? ?? const []).map((e) => '$e').toList(),
  );
}

/// 一次对话，保存在应用数据目录的 `ai_sessions/<id>.json`
class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.created,
    required this.updated,
    required this.messages,
  });

  final String id;
  String title;
  final DateTime created;
  DateTime updated;
  final List<ChatMessage> messages;

  /// 某个工具调用的结果
  ChatMessage? resultOf(String callId) => messages.where((m) => m.isTool && m.toolCallId == callId).firstOrNull;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'created': created.toIso8601String(),
    'updated': updated.toIso8601String(),
    'messages': [for (final m in messages) m.toJson()],
  };

  static ChatSession fromJson(Map<String, dynamic> j) => ChatSession(
    id: '${j['id']}',
    title: '${j['title']}',
    created: DateTime.tryParse('${j['created']}') ?? DateTime.now(),
    updated: DateTime.tryParse('${j['updated']}') ?? DateTime.now(),
    messages: [
      for (final m in (j['messages'] as List? ?? const []).whereType<Map<String, dynamic>>()) ChatMessage.fromJson(m),
    ],
  );
}

/// 进行中的工具调用：准备中、等待用户确认或执行中
class PendingTool {
  PendingTool(this.sessionId, this.call, this.def);

  final String sessionId;
  final AiToolCall call;
  final AiToolDef? def;
  ToolPlan? plan;
  bool running = false;
  Completer<bool>? _decision;

  bool get waiting => _decision != null && !_decision!.isCompleted;
}

/// AI 对话的会话列表、正在进行的回答与工具调用
class ChatStore extends ChangeNotifier {
  ChatStore._(this.sessions);

  /// 按最后更新时间排序，新的在前
  final List<ChatSession> sessions;

  /// 可用的启动器操作，由 AppState 设置
  AiToolbox? toolbox;

  /// 是否向模型提供操作，以及只读操作是否也需要确认
  bool Function() toolsEnabled = () => true;
  bool Function() confirmRead = () => false;

  /// 当前打开的会话；null 表示新对话（发送第一条消息时创建）
  String? currentId;

  final _streaming = <String, String>{};
  final _errors = <String, String>{};
  final _busy = <String>{};

  /// 每次停止时加一，用来丢弃已停止的请求的后续结果
  final _gen = <String, int>{};
  final _pending = <String, PendingTool>{};

  /// 本次对话中已允许的操作（只限 write 类）
  final _allowed = <String, Set<String>>{};

  static Directory get _dir => Directory(p.join(Paths.appData, 'ai_sessions'));

  static ChatStore load() {
    final list = <ChatSession>[];
    try {
      if (_dir.existsSync()) {
        for (final f in _dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'))) {
          try {
            list.add(ChatSession.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>));
          } catch (_) {
            // 损坏的会话文件跳过
          }
        }
      }
    } catch (_) {
      // 目录无法读取
    }
    return ChatStore._(list..sort((a, b) => b.updated.compareTo(a.updated)));
  }

  ChatSession? get current => sessions.where((s) => s.id == currentId).firstOrNull;
  ChatSession? byId(String id) => sessions.where((s) => s.id == id).firstOrNull;

  bool isBusy(String id) => _busy.contains(id);

  /// 正在生成的回答（尚未完成）
  String? streamingOf(String id) => _streaming[id];
  String? errorOf(String id) => _errors[id];
  PendingTool? pendingOf(String callId) => _pending[callId];

  /// 正在执行操作时不能停止，避免操作实际执行了却被记为取消
  bool isExecuting(String id) => _pending.values.any((t) => t.sessionId == id && t.running);

  void open(String? id) {
    currentId = id;
    notifyListeners();
  }

  Future<void> _save(ChatSession s) async {
    try {
      await _dir.create(recursive: true);
      await File(p.join(_dir.path, '${s.id}.json')).writeAsString(jsonEncode(s.toJson()));
    } catch (_) {
      // 保存失败不影响对话
    }
  }

  /// 第一条消息的第一行作为标题
  static String titleFrom(String text) {
    final line = text.trim().split('\n').first.trim();
    return line.length > 30 ? '${line.substring(0, 30)}…' : (line.isEmpty ? '新对话' : line);
  }

  /// 发送消息；session 为 null 时新建会话。返回消息所在的会话
  ChatSession send(ChatSession? session, String text, AiSettings ai, {String? title}) {
    final now = DateTime.now();
    final s =
        session ?? ChatSession(id: newId(), title: title ?? titleFrom(text), created: now, updated: now, messages: []);
    if (session == null) sessions.insert(0, s);
    s.messages.add(ChatMessage('user', text));
    currentId = s.id;
    unawaited(_run(s, ai));
    return s;
  }

  /// 重新生成：去掉最后一条文字回答（如果有），再次请求
  void retry(ChatSession s, AiSettings ai) {
    if (isBusy(s.id) || s.messages.isEmpty) return;
    final last = s.messages.last;
    if (last.role == 'assistant' && last.toolCalls.isEmpty) s.messages.removeLast();
    unawaited(_run(s, ai));
  }

  /// 发给接口的历史：没有结果的工具调用（例如确认时关闭了启动器）补上「已取消」
  List<AiMessage> _history(ChatSession s) {
    final out = <AiMessage>[];
    for (var i = 0; i < s.messages.length; i++) {
      final m = s.messages[i];
      out.add(m.toAi());
      if (m.toolCalls.isEmpty) continue;
      // 这条回答之后紧跟的工具结果
      final answered = <String>{};
      for (var j = i + 1; j < s.messages.length && s.messages[j].isTool; j++) {
        answered.add(s.messages[j].toolCallId ?? '');
      }
      for (final c in m.toolCalls.where((c) => !answered.contains(c.id))) {
        out.add(AiMessage('tool', '操作已取消，没有执行。', toolCallId: c.id, isError: true));
      }
    }
    return out;
  }

  Future<void> _run(ChatSession s, AiSettings ai) async {
    final gen = _gen[s.id] ?? 0;
    bool stopped() => (_gen[s.id] ?? 0) != gen;
    _errors.remove(s.id);
    _busy.add(s.id);
    _bump(s);
    unawaited(_save(s));
    notifyListeners();
    final tools = toolbox != null && toolsEnabled() ? toolbox!.specs : const <AiTool>[];
    try {
      for (var round = 0; round < 16; round++) {
        _streaming[s.id] = '';
        notifyListeners();
        AiTurnEnd? end;
        await for (final e in aiStream(ai, assistantSystemPrompt, _history(s), tools: tools)) {
          if (stopped()) return;
          switch (e) {
            case AiText(:final text):
              _streaming[s.id] = (_streaming[s.id] ?? '') + text;
              notifyListeners();
            case AiTurnEnd():
              end = e;
          }
        }
        if (stopped() || end == null) return;
        final m = end.message;
        _streaming.remove(s.id);
        // 部分 OpenAI 兼容服务的调用 ID 会重复或缺失，在会话内改成唯一的
        // （Anthropic 的 ID 本身唯一，并且要与原始内容块一致，不改）
        final used = {for (final x in s.messages) ...x.toolCalls.map((c) => c.id)};
        final calls = m.blocks != null
            ? m.toolCalls
            : [for (final c in m.toolCalls) used.add(c.id) ? c : AiToolCall('call_${newId()}', c.name, c.args)];
        s.messages.add(ChatMessage('assistant', m.content, toolCalls: calls, blocks: m.blocks, reasoning: m.reasoning));
        s.updated = DateTime.now();
        unawaited(_save(s));
        notifyListeners();
        if (calls.isEmpty) return;

        // 依次处理工具调用；只读操作直接执行，其余等用户确认
        for (final call in calls) {
          if (stopped()) return;
          final result = await _handle(s, call, stopped);
          if (stopped()) return;
          s.messages.add(result);
          unawaited(_save(s));
          notifyListeners();
        }
      }
      _errors[s.id] = '这一轮的操作次数过多，已暂停。可以发送消息让 AI 继续';
    } catch (e) {
      if (!stopped()) _errors[s.id] = '$e';
    } finally {
      if (!stopped()) {
        _busy.remove(s.id);
        // 失败时保留已生成的文字
        final partial = _streaming.remove(s.id) ?? '';
        if (partial.isNotEmpty) s.messages.add(ChatMessage('assistant', partial));
        s.updated = DateTime.now();
        unawaited(_save(s));
        notifyListeners();
      }
    }
  }

  Future<ChatMessage> _handle(ChatSession s, AiToolCall call, bool Function() stopped) async {
    final def = toolbox?.find(call.name);
    final pending = _pending[call.id] = PendingTool(s.id, call, def);
    notifyListeners();
    ChatMessage result(ToolStatus status, String content, {String? title, List<String> details = const []}) =>
        ChatMessage(
          'tool',
          content,
          toolCallId: call.id,
          status: status,
          title: title ?? def?.label ?? call.name,
          details: details,
        );
    try {
      if (def == null) return result(ToolStatus.error, '没有名为 ${call.name} 的工具');
      final ToolPlan plan;
      try {
        plan = await def.prepare(call.args);
      } catch (e) {
        return result(ToolStatus.error, '$e');
      }
      pending.plan = plan;
      final needsApproval = switch (def.kind) {
        ToolKind.read => confirmRead(),
        ToolKind.write => !(_allowed[s.id]?.contains(call.name) ?? false),
        ToolKind.danger => true,
      };
      if (needsApproval) {
        pending._decision = Completer<bool>();
        notifyListeners();
        final ok = await pending._decision!.future;
        if (stopped()) return result(ToolStatus.cancelled, '操作已取消，没有执行。', title: plan.title, details: plan.details);
        if (!ok) {
          return result(
            ToolStatus.denied,
            '用户拒绝了这个操作，没有执行。不要再次请求同样的操作；可以询问用户的想法，或提供其他办法。',
            title: plan.title,
            details: plan.details,
          );
        }
      }
      pending.running = true;
      notifyListeners();
      try {
        final out = await plan.run();
        if (def.kind != ToolKind.read) unawaited(logAiOperation(plan.title, out));
        return result(ToolStatus.done, out, title: plan.title, details: plan.details);
      } catch (e) {
        return result(ToolStatus.error, '执行失败：$e', title: plan.title, details: plan.details);
      }
    } finally {
      _pending.remove(call.id);
    }
  }

  /// 用户对确认卡片的选择；always 表示本次对话中允许同类操作
  void decide(ChatSession s, String callId, bool allow, {bool always = false}) {
    final pending = _pending[callId];
    if (pending == null || !pending.waiting) return;
    if (allow && always) (_allowed[s.id] ??= {}).add(pending.call.name);
    pending._decision!.complete(allow);
    notifyListeners();
  }

  void stop(ChatSession s) {
    if (!isBusy(s.id) || isExecuting(s.id)) return;
    _gen[s.id] = (_gen[s.id] ?? 0) + 1;
    _busy.remove(s.id);
    final partial = _streaming.remove(s.id) ?? '';
    if (partial.isNotEmpty) s.messages.add(ChatMessage('assistant', '$partial\n\n（已停止）'));
    // 等待确认的操作视为取消（发送下一条消息时会补上「已取消」的结果）
    for (final m in _pending.values.toList()) {
      if (m.waiting) m._decision!.complete(false);
    }
    s.updated = DateTime.now();
    unawaited(_save(s));
    notifyListeners();
  }

  /// 最近更新的会话排到最前
  void _bump(ChatSession s) {
    sessions
      ..remove(s)
      ..insert(0, s);
  }

  Future<void> rename(ChatSession s, String title) async {
    s.title = title.trim().isEmpty ? s.title : title.trim();
    notifyListeners();
    await _save(s);
  }

  Future<void> delete(ChatSession s) async {
    stop(s);
    sessions.remove(s);
    _errors.remove(s.id);
    _allowed.remove(s.id);
    if (currentId == s.id) currentId = null;
    notifyListeners();
    try {
      await File(p.join(_dir.path, '${s.id}.json')).delete();
    } catch (_) {
      // 文件已不存在
    }
  }
}
