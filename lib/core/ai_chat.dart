import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'accounts.dart' show newId;
import 'ai_client.dart';
import 'ai_prompt.dart';
import 'paths.dart';

class ChatMessage {
  ChatMessage(this.role, this.content, {DateTime? time}) : time = time ?? DateTime.now();

  /// user 或 assistant
  final String role;
  final String content;
  final DateTime time;

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {'role': role, 'content': content, 'time': time.toIso8601String()};

  static ChatMessage fromJson(Map<String, dynamic> j) =>
      ChatMessage('${j['role']}', '${j['content']}', time: DateTime.tryParse('${j['time']}'));
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

/// AI 对话的会话列表与正在进行的回答
class ChatStore extends ChangeNotifier {
  ChatStore._(this.sessions);

  /// 按最后更新时间排序，新的在前
  final List<ChatSession> sessions;

  /// 当前打开的会话；null 表示新对话（发送第一条消息时创建）
  String? currentId;

  final _streaming = <String, String>{};
  final _subs = <String, StreamSubscription<String>>{};
  final _errors = <String, String>{};

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

  bool isBusy(String id) => _subs.containsKey(id);

  /// 正在生成的回答（尚未完成）
  String? streamingOf(String id) => _streaming[id];
  String? errorOf(String id) => _errors[id];

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
    _start(s, ai);
    return s;
  }

  /// 重新生成：去掉最后一条回答（如果有），再次请求
  void retry(ChatSession s, AiSettings ai) {
    if (isBusy(s.id) || s.messages.isEmpty) return;
    if (!s.messages.last.isUser) s.messages.removeLast();
    _start(s, ai);
  }

  void _start(ChatSession s, AiSettings ai) {
    _errors.remove(s.id);
    _streaming[s.id] = '';
    s.updated = DateTime.now();
    _bump(s);
    unawaited(_save(s));
    final history = [for (final m in s.messages) AiMessage(m.role, m.content)];
    _subs[s.id] = aiChat(ai, assistantSystemPrompt, history).listen(
      (chunk) {
        _streaming[s.id] = (_streaming[s.id] ?? '') + chunk;
        notifyListeners();
      },
      onError: (Object e) {
        _errors[s.id] = '$e';
        _finish(s);
      },
      onDone: () => _finish(s),
      cancelOnError: true,
    );
    notifyListeners();
  }

  void _finish(ChatSession s, {String suffix = ''}) {
    _subs.remove(s.id);
    final text = _streaming.remove(s.id) ?? '';
    if (text.isNotEmpty) {
      s.messages.add(ChatMessage('assistant', text + suffix));
      s.updated = DateTime.now();
      unawaited(_save(s));
    }
    notifyListeners();
  }

  void stop(ChatSession s) {
    final sub = _subs[s.id];
    if (sub == null) return;
    unawaited(sub.cancel());
    _finish(s, suffix: (_streaming[s.id] ?? '').isEmpty ? '' : '\n\n（已停止）');
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
    if (currentId == s.id) currentId = null;
    notifyListeners();
    try {
      await File(p.join(_dir.path, '${s.id}.json')).delete();
    } catch (_) {
      // 文件已不存在
    }
  }
}
