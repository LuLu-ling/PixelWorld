import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/ai/ai_chat.dart';
import 'package:pcl_pw/core/ai/ai_client.dart';
import 'package:pcl_pw/core/ai/ai_context.dart';

void main() {
  test('估算与已知的上下文长度', () {
    expect(estimateTokens('a' * 350), 100);
    expect(estimateTokens('崩' * 100), 70);
    expect(knownContextWindow('deepseek-flash'), 1000000);
    expect(knownContextWindow('claude-haiku-4-5'), 200000);
    expect(knownContextWindow('some-model'), isNull);
  });

  test('自动压缩：保留最近两轮，较早的对话换成摘要', () async {
    final requests = <Map<String, dynamic>>[];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((req) async {
      final body = jsonDecode(await utf8.decoder.bind(req).join()) as Map<String, dynamic>;
      requests.add(body);
      final system = ((body['messages'] as List).first as Map)['content'] as String;
      final reply = system.contains('压缩对话记录') ? '- 用户在排查 1.20.1 的崩溃' : '好的';
      req.response.headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
      req.response.write(
        'data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': reply},
            },
          ],
          'usage': {'prompt_tokens': 50000, 'completion_tokens': 10},
        })}\n\ndata: [DONE]\n\n',
      );
      await req.response.close();
    });
    final ai = AiSettings(
      provider: AiProvider.openai,
      baseUrl: 'http://127.0.0.1:${server.port}/v1',
      model: 'm',
      apiKey: '',
    );
    final store = ChatStore.load()
      ..toolsEnabled = (() => false)
      ..compactAt = (() => 32000);

    Future<void> idle(ChatSession s) async {
      while (store.isBusy(s.id) || store.isCompacting(s.id)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    // 三轮对话，每轮回答都报告 5 万 tokens 的输入
    final s = store.send(null, '第一个问题', ai);
    await idle(s);
    store.send(s, '第二个问题', ai);
    await idle(s);
    expect(s.summary, isNull, reason: '只有两轮时不压缩');
    expect(store.contextOf(s, ai).used, greaterThan(32000));

    store.send(s, '第三个问题', ai);
    await idle(s);
    expect(s.summary, '- 用户在排查 1.20.1 的崩溃');
    // 第二轮开始的用户消息之前的内容被压缩
    expect(s.summaryUntil, s.messages.indexWhere((m) => m.content == '第二个问题'));

    // 压缩请求包含第一轮；之后的回答请求以摘要开头，不再包含第一轮原文
    final compactReq = requests.firstWhere(
      (r) => (((r['messages'] as List).first as Map)['content'] as String).contains('压缩对话记录'),
    );
    expect(jsonEncode(compactReq), contains('第一个问题'));
    final last = (requests.last['messages'] as List).cast<Map>();
    expect(last[1]['content'], startsWith(summaryLead));
    expect(last.map((m) => m['content']), isNot(contains('第一个问题')));
    expect(last.map((m) => m['content']), containsAll(['第二个问题', '第三个问题']));
  });
}
