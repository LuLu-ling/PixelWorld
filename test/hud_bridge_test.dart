import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/ai/ai_chat.dart';
import 'package:pcl_pw/core/ai/ai_client.dart';
import 'package:pcl_pw/core/hud_bridge.dart';

ChatSession _session(List<ChatMessage> messages) {
  final now = DateTime(2026, 11, 10);
  return ChatSession(id: 's', title: 't', created: now, updated: now, messages: messages);
}

void main() {
  test('游戏内只显示提问和文字回答，被工具调用隔开的回答合成一条', () {
    final s = _session([
      ChatMessage('user', '为什么崩溃'),
      ChatMessage('assistant', '我先看看日志。', toolCalls: [AiToolCall('c1', 'read_log', const {})]),
      ChatMessage('tool', '日志内容', toolCallId: 'c1', status: ToolStatus.done),
      ChatMessage('assistant', '是 OptiFine 冲突。'),
      ChatMessage('user', '怎么办'),
      ChatMessage('assistant', '', toolCalls: [AiToolCall('c2', 'x', const {})]),
    ]);
    expect(visibleMessages(s), [
      {'role': 'user', 'content': '为什么崩溃'},
      {'role': 'assistant', 'content': '我先看看日志。\n\n是 OptiFine 冲突。'},
      {'role': 'user', 'content': '怎么办'},
    ]);
  });

  test('回答文字包含已完成的几段和正在生成的部分', () {
    final s = _session([
      ChatMessage('user', 'a'),
      ChatMessage('assistant', '第一段', toolCalls: [AiToolCall('c1', 'read_log', const {})]),
      ChatMessage('tool', 'x', toolCallId: 'c1', status: ToolStatus.done),
    ]);
    expect(answerAfter(s, 0, null), '第一段');
    expect(answerAfter(s, 0, '第二'), '第一段\n\n第二');
    expect(answerAfter(_session([ChatMessage('user', 'a')]), 0, ''), '');
  });

  test('导入旧版游戏内对话', () {
    final s = legacySession({
      'id': 'abc',
      'title': '新对话',
      'updated': 1700000000000,
      'messages': [
        {'role': 'user', 'content': '内存怎么设置'},
        {'role': 'assistant', 'content': '4 GB 就够了'},
        {'role': 'system', 'content': '忽略'},
        {'role': 'assistant', 'content': '  '},
      ],
    })!;
    expect(s.id, 'game-abc');
    expect(s.title, '内存怎么设置');
    expect(s.messages.map((m) => m.role), ['user', 'assistant']);
    expect(s.updated.millisecondsSinceEpoch, 1700000000000);
    expect(legacySession({'id': 'x', 'messages': []}), isNull);
  });
}
