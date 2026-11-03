import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/ai_client.dart';

/// 模拟接口：按路径返回预先写好的事件流，并记录收到的请求
Future<(HttpServer, List<Map<String, dynamic>>)> _server(List<String> Function(String path) events) async {
  final requests = <Map<String, dynamic>>[];
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((req) async {
    requests.add(jsonDecode(await utf8.decoder.bind(req).join()) as Map<String, dynamic>);
    final res = req.response..headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
    for (final e in events(req.uri.path)) {
      res.write('data: $e\n\n');
    }
    await res.close();
  });
  return (server, requests);
}

const _tool = AiTool('list_mods', '列出模组', {
  'type': 'object',
  'properties': {
    'version': {'type': 'string'},
  },
});

void main() {
  test('OpenAI 兼容接口：分段的工具调用', () async {
    final (server, requests) = await _server(
      (_) => [
        jsonEncode({
          'choices': [
            {
              'delta': {'content': '我先看看'},
            },
          ],
        }),
        jsonEncode({
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'function': {'name': 'list_mods', 'arguments': '{"vers'},
                  },
                ],
              },
            },
          ],
        }),
        jsonEncode({
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'function': {'arguments': 'ion":"1.20.1"}'},
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        }),
        '[DONE]',
      ],
    );
    addTearDown(() => server.close(force: true));
    final s = AiSettings(
      provider: AiProvider.openai,
      baseUrl: 'http://127.0.0.1:${server.port}/v1',
      model: 'm',
      apiKey: '',
    );
    final events = await aiStream(s, 'sys', const [AiMessage('user', 'hi')], tools: const [_tool]).toList();
    final end = events.whereType<AiTurnEnd>().single;
    expect(end.message.content, '我先看看');
    expect(end.message.toolCalls.single.name, 'list_mods');
    expect(end.message.toolCalls.single.args, {'version': '1.20.1'});
    expect(end.stopReason, 'tool_calls');
    expect(((requests.single['tools'] as List).single as Map)['type'], 'function');

    // 工具结果的格式
    await aiStream(s, 'sys', [
      const AiMessage('user', 'hi'),
      end.message,
      const AiMessage('tool', 'a.jar', toolCallId: 'call_1'),
    ]).handleError((_) {}).toList();
    final msgs = requests.last['messages'] as List;
    expect((msgs[2] as Map)['tool_calls'], isNotEmpty);
    expect(msgs[3], {'role': 'tool', 'tool_call_id': 'call_1', 'content': 'a.jar'});
  });

  test('Anthropic 接口：思考块与工具调用原样传回', () async {
    final (server, requests) = await _server(
      (_) => [
        for (final e in [
          {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {'type': 'thinking', 'thinking': ''},
          },
          {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'signature_delta', 'signature': 'sig'},
          },
          {'type': 'content_block_stop', 'index': 0},
          {
            'type': 'content_block_start',
            'index': 1,
            'content_block': {'type': 'text', 'text': ''},
          },
          {
            'type': 'content_block_delta',
            'index': 1,
            'delta': {'type': 'text_delta', 'text': '查看模组'},
          },
          {'type': 'content_block_stop', 'index': 1},
          {
            'type': 'content_block_start',
            'index': 2,
            'content_block': {'type': 'tool_use', 'id': 'tu_1', 'name': 'list_mods', 'input': {}},
          },
          {
            'type': 'content_block_delta',
            'index': 2,
            'delta': {'type': 'input_json_delta', 'partial_json': '{"version":'},
          },
          {
            'type': 'content_block_delta',
            'index': 2,
            'delta': {'type': 'input_json_delta', 'partial_json': '"1.20.1"}'},
          },
          {'type': 'content_block_stop', 'index': 2},
          {
            'type': 'message_delta',
            'delta': {'stop_reason': 'tool_use'},
          },
        ])
          jsonEncode(e),
      ],
    );
    addTearDown(() => server.close(force: true));
    final s = AiSettings(
      provider: AiProvider.anthropic,
      baseUrl: 'http://127.0.0.1:${server.port}',
      model: 'm',
      apiKey: 'k',
    );
    final events = await aiStream(s, 'sys', const [AiMessage('user', 'hi')], tools: const [_tool]).toList();
    final end = events.whereType<AiTurnEnd>().single;
    expect(end.message.toolCalls.single.args, {'version': '1.20.1'});
    expect(end.message.blocks!.first, {'type': 'thinking', 'thinking': '', 'signature': 'sig'});
    expect(((requests.single['tools'] as List).single as Map)['input_schema'], isNotNull);

    // 两个工具结果合并到同一条用户消息；助手消息带着思考块原样传回
    await aiStream(s, 'sys', [
      const AiMessage('user', 'hi'),
      end.message,
      const AiMessage('tool', 'a.jar', toolCallId: 'tu_1'),
      const AiMessage('tool', '拒绝', toolCallId: 'tu_2', isError: true),
    ]).toList();
    final msgs = requests.last['messages'] as List;
    expect(msgs, hasLength(3));
    expect(((msgs[1] as Map)['content'] as List).first, containsPair('signature', 'sig'));
    expect((msgs[2] as Map)['content'], [
      {'type': 'tool_result', 'tool_use_id': 'tu_1', 'content': 'a.jar'},
      {'type': 'tool_result', 'tool_use_id': 'tu_2', 'content': '拒绝', 'is_error': true},
    ]);
  });

  test('获取模型列表：新的在前，去掉非对话模型', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final auth = <String?>[];
    server.listen((req) async {
      auth.add(req.headers.value('authorization') ?? req.headers.value('x-api-key'));
      req.response.headers.contentType = ContentType.json;
      req.response.write(
        jsonEncode(
          req.uri.path == '/v1/models'
              ? {
                  'data': [
                    {'id': 'old-chat', 'created': 1},
                    {'id': 'text-embedding-x', 'created': 9},
                    {'id': 'new-chat', 'created': 5},
                  ],
                }
              : {'error': 'x'},
        ),
      );
      await req.response.close();
    });
    final base = 'http://127.0.0.1:${server.port}/v1';
    expect(await aiListModels(AiSettings(provider: AiProvider.openai, baseUrl: base, model: '', apiKey: 'k1')), [
      'new-chat',
      'old-chat',
    ]);
    expect(auth.last, 'Bearer k1');
    // Anthropic：保持接口返回的顺序（已是新的在前），使用 x-api-key
    expect(await aiListModels(AiSettings(provider: AiProvider.anthropic, baseUrl: base, model: '', apiKey: 'k2')), [
      'old-chat',
      'new-chat',
    ]);
    expect(auth.last, 'k2');
  });
}
