import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'paths.dart';
import 'secure.dart';

/// 接口格式：OpenAI 兼容（DeepSeek、通义千问、Kimi、OpenRouter、Ollama 等）或 Anthropic
enum AiProvider { openai, anthropic }

/// 常用服务的预设：接口地址与推荐的模型（2026-11 按各家文档核对）。
/// 模型更新很快，设置页可以从接口获取最新的模型列表
const aiPresets = [
  (label: 'DeepSeek', provider: AiProvider.openai, url: 'https://api.deepseek.com/v1', model: 'deepseek-flash'),
  (
    label: '通义千问',
    provider: AiProvider.openai,
    url: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    model: 'qwen3.8-flash',
  ),
  (label: 'Kimi', provider: AiProvider.openai, url: 'https://api.moonshot.cn/v1', model: 'kimi-k3.1-pro'),
  (label: 'OpenRouter', provider: AiProvider.openai, url: 'https://openrouter.ai/api/v1', model: ''),
  (label: 'OpenAI', provider: AiProvider.openai, url: 'https://api.openai.com/v1', model: ''),
  (label: 'Claude', provider: AiProvider.anthropic, url: 'https://api.anthropic.com', model: 'claude-opus-5-5'),
  (label: 'Ollama（本机）', provider: AiProvider.openai, url: 'http://localhost:11434/v1', model: ''),
];

class AiSettings {
  const AiSettings({required this.provider, required this.baseUrl, required this.model, required this.apiKey});

  final AiProvider provider;
  final String baseUrl;
  final String model;
  final String apiKey;

  /// 本机服务（Ollama、LM Studio）可以不填 API Key
  bool get isLocal {
    final host = Uri.tryParse(baseUrl)?.host ?? '';
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }

  bool get ready => baseUrl.isNotEmpty && model.isNotEmpty && (apiKey.isNotEmpty || isLocal);

  String get host => Uri.tryParse(baseUrl)?.host ?? baseUrl;

  /// 读取设置；API Key 单独加密保存在 ai.dat
  static AiSettings load(LauncherConfig cfg) => AiSettings(
    provider: cfg.aiProvider == 'anthropic' ? AiProvider.anthropic : AiProvider.openai,
    baseUrl: cfg.aiBaseUrl,
    model: cfg.aiModel,
    apiKey: _readKey(),
  );

  Future<void> save(LauncherConfig cfg) async {
    await cfg.update({'aiProvider': provider.name, 'aiBaseUrl': baseUrl.trim(), 'aiModel': model.trim()});
    final f = _keyFile;
    await f.parent.create(recursive: true);
    await f.writeAsBytes(SecureData.protect(Uint8List.fromList(utf8.encode(apiKey.trim()))));
  }

  static File get _keyFile => File(p.join(Paths.appData, 'ai.dat'));

  static String _readKey() {
    try {
      final f = _keyFile;
      return f.existsSync() ? utf8.decode(SecureData.unprotect(f.readAsBytesSync())) : '';
    } catch (_) {
      return '';
    }
  }
}

/// 模型请求调用的工具
class AiToolCall {
  const AiToolCall(this.id, this.name, this.args);

  final String id;
  final String name;
  final Map<String, dynamic> args;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'args': args};

  static AiToolCall fromJson(Map<String, dynamic> j) =>
      AiToolCall('${j['id']}', '${j['name']}', (j['args'] as Map?)?.cast<String, dynamic>() ?? {});
}

/// 对话中的一条消息
class AiMessage {
  const AiMessage(
    this.role,
    this.content, {
    this.toolCalls = const [],
    this.blocks,
    this.reasoning,
    this.toolCallId,
    this.isError = false,
  });

  /// user、assistant 或 tool（工具结果）
  final String role;
  final String content;

  /// assistant：请求调用的工具
  final List<AiToolCall> toolCalls;

  /// assistant：Anthropic 接口返回的原始内容块（含思考块，继续对话时需要原样传回）
  final List<Map<String, dynamic>>? blocks;

  /// assistant：部分 OpenAI 兼容接口（如 DeepSeek）的思考内容，调用工具后需要传回
  final String? reasoning;

  /// tool：对应的工具调用
  final String? toolCallId;
  final bool isError;
}

/// 提供给模型的工具
class AiTool {
  const AiTool(this.name, this.description, this.schema);

  final String name;
  final String description;

  /// JSON Schema（object）
  final Map<String, dynamic> schema;
}

sealed class AiEvent {}

/// 回答的文字片段
class AiText extends AiEvent {
  AiText(this.text);
  final String text;
}

/// 一轮回答结束：完整的文字、工具调用与需要传回的内容
class AiTurnEnd extends AiEvent {
  AiTurnEnd(this.message, this.stopReason);
  final AiMessage message;
  final String? stopReason;
}

class AiException implements Exception {
  AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 不是对话模型的名称特征（向量、语音、图像、审核等）
final _nonChat = RegExp(
  r'embed|whisper|tts|speech|audio|dall-e|image|moderation|rerank|transcribe|realtime|ocr',
  caseSensitive: false,
);

/// 从接口获取可用的模型：OpenAI 兼容接口为 GET /models，Anthropic 为 GET /v1/models（新的在前）
Future<List<String>> aiListModels(AiSettings s) async {
  final base = s.baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  if (base.isEmpty) throw AiException('请先填写接口地址');
  final anthropic = s.provider == AiProvider.anthropic;
  final url = Uri.parse(anthropic ? '${base.endsWith('/v1') ? base : '$base/v1'}/models?limit=1000' : '$base/models');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final req = await client.getUrl(url);
    if (anthropic) {
      req.headers.set('x-api-key', s.apiKey);
      req.headers.set('anthropic-version', '2026-10-21');
    } else if (s.apiKey.isNotEmpty) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${s.apiKey}');
    }
    final res = await req.close().timeout(const Duration(seconds: 20));
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) throw AiException('获取模型列表失败（HTTP ${res.statusCode}）：${_errorMessage(body)}');
    final data = (jsonDecode(body) as Map)['data'] as List? ?? const [];
    final models = data.whereType<Map>().where((m) => m['id'] != null).toList();
    // OpenAI 兼容接口按创建时间从新到旧排列（有时间时）
    if (!anthropic) {
      models.sort((a, b) => ((b['created'] as num?) ?? 0).compareTo((a['created'] as num?) ?? 0));
    }
    return [
      for (final m in models)
        if (!_nonChat.hasMatch('${m['id']}')) '${m['id']}',
    ];
  } on SocketException catch (e) {
    throw AiException('无法连接 ${s.host}：${e.message}');
  } on HandshakeException {
    throw AiException('与 ${s.host} 的安全连接失败');
  } on FormatException {
    throw AiException('接口返回的不是模型列表，请检查接口地址');
  } on TimeoutException {
    throw AiException('连接 ${s.host} 超时');
  } finally {
    client.close(force: true);
  }
}

/// 只要文字的流式对话（用于测试连接）
Stream<String> aiChat(AiSettings s, String system, List<AiMessage> messages) async* {
  await for (final e in aiStream(s, system, messages)) {
    if (e is AiText) yield e.text;
  }
}

List<Map<String, dynamic>> _openAiMessages(String system, List<AiMessage> messages) => [
  {'role': 'system', 'content': system},
  for (final m in messages)
    switch (m.role) {
      'tool' => {'role': 'tool', 'tool_call_id': m.toolCallId, 'content': m.content},
      'assistant' => {
        'role': 'assistant',
        'content': m.content.isEmpty && m.toolCalls.isNotEmpty ? null : m.content,
        if (m.reasoning != null && m.reasoning!.isNotEmpty) 'reasoning_content': m.reasoning,
        if (m.toolCalls.isNotEmpty)
          'tool_calls': [
            for (final c in m.toolCalls)
              {
                'id': c.id,
                'type': 'function',
                'function': {'name': c.name, 'arguments': jsonEncode(c.args)},
              },
          ],
      },
      _ => {'role': 'user', 'content': m.content},
    },
];

List<Map<String, dynamic>> _anthropicMessages(List<AiMessage> messages) {
  final out = <Map<String, dynamic>>[];
  for (final m in messages) {
    switch (m.role) {
      case 'tool':
        final block = {
          'type': 'tool_result',
          'tool_use_id': m.toolCallId,
          'content': m.content,
          if (m.isError) 'is_error': true,
        };
        // 同一轮的多个工具结果放在同一条用户消息里
        final last = out.lastOrNull;
        if (last != null && last['role'] == 'user' && last['content'] is List) {
          (last['content'] as List).add(block);
        } else {
          out.add({
            'role': 'user',
            'content': [block],
          });
        }
      case 'assistant':
        final content = m.blocks != null && m.blocks!.isNotEmpty
            ? m.blocks!
            : [
                if (m.content.isNotEmpty) {'type': 'text', 'text': m.content},
                for (final c in m.toolCalls) {'type': 'tool_use', 'id': c.id, 'name': c.name, 'input': c.args},
              ];
        if (content.isNotEmpty) out.add({'role': 'assistant', 'content': content});
      default:
        out.add({'role': 'user', 'content': m.content});
    }
  }
  return out;
}

/// 流式对话：逐段返回文字，最后返回完整的一轮回答（可能包含工具调用）
Stream<AiEvent> aiStream(
  AiSettings s,
  String system,
  List<AiMessage> messages, {
  List<AiTool> tools = const [],
}) async* {
  final base = s.baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  final anthropic = s.provider == AiProvider.anthropic;
  final url = Uri.parse(anthropic ? '${base.endsWith('/v1') ? base : '$base/v1'}/messages' : '$base/chat/completions');
  final body = anthropic
      ? {
          'model': s.model,
          'max_tokens': 16000,
          'stream': true,
          'system': system,
          'messages': _anthropicMessages(messages),
          if (tools.isNotEmpty)
            'tools': [
              for (final t in tools) {'name': t.name, 'description': t.description, 'input_schema': t.schema},
            ],
        }
      : {
          'model': s.model,
          'stream': true,
          'messages': _openAiMessages(system, messages),
          if (tools.isNotEmpty)
            'tools': [
              for (final t in tools)
                {
                  'type': 'function',
                  'function': {'name': t.name, 'description': t.description, 'parameters': t.schema},
                },
            ],
        };

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final req = await client.postUrl(url);
    req.headers.contentType = ContentType.json;
    req.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
    if (anthropic) {
      req.headers.set('x-api-key', s.apiKey);
      req.headers.set('anthropic-version', '2026-10-21');
    } else if (s.apiKey.isNotEmpty) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${s.apiKey}');
    }
    req.add(utf8.encode(jsonEncode(body)));
    final res = await req.close();
    if (res.statusCode != 200) {
      final text = await res.transform(utf8.decoder).join();
      throw AiException('请求失败（HTTP ${res.statusCode}）：${_errorMessage(text)}');
    }

    final text = StringBuffer();
    String? stop;
    // Anthropic：按序号记录内容块；工具参数是分段的 JSON
    final blocks = <int, Map<String, dynamic>>{};
    final partial = <int, StringBuffer>{};
    // OpenAI：按序号累积工具调用
    final calls = <int, ({StringBuffer id, StringBuffer name, StringBuffer args})>{};
    final reasoning = StringBuffer();

    await for (final line in res.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data.isEmpty || data == '[DONE]') continue;
      final Map<String, dynamic> ev;
      try {
        ev = jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      if (ev['error'] != null) throw AiException(_errorMessage(data));
      if (anthropic) {
        final index = (ev['index'] as num?)?.toInt() ?? 0;
        switch (ev['type']) {
          case 'content_block_start':
            final block = Map<String, dynamic>.from(ev['content_block'] as Map? ?? {'type': 'text', 'text': ''});
            if (block['type'] == 'tool_use') {
              block['input'] = <String, dynamic>{};
              partial[index] = StringBuffer();
            }
            blocks[index] = block;
          case 'content_block_delta':
            final delta = ev['delta'] as Map;
            final block = blocks[index];
            if (block == null) continue;
            switch (delta['type']) {
              case 'text_delta':
                block['text'] = '${block['text'] ?? ''}${delta['text']}';
                text.write(delta['text']);
                yield AiText('${delta['text']}');
              case 'thinking_delta':
                block['thinking'] = '${block['thinking'] ?? ''}${delta['thinking']}';
              case 'signature_delta':
                block['signature'] = delta['signature'];
              case 'input_json_delta':
                partial[index]?.write(delta['partial_json']);
            }
          case 'content_block_stop':
            final buf = partial.remove(index);
            if (buf != null && buf.isNotEmpty) {
              try {
                blocks[index]!['input'] = jsonDecode(buf.toString());
              } catch (_) {
                blocks[index]!['input'] = <String, dynamic>{};
              }
            }
          case 'message_delta':
            stop = (ev['delta'] as Map?)?['stop_reason'] as String? ?? stop;
        }
      } else {
        final choice = (ev['choices'] as List?)?.firstOrNull as Map?;
        final delta = choice?['delta'] as Map?;
        final content = delta?['content'];
        if (content is String && content.isNotEmpty) {
          text.write(content);
          yield AiText(content);
        }
        final r = delta?['reasoning_content'];
        if (r is String) reasoning.write(r);
        for (final c in (delta?['tool_calls'] as List? ?? const []).whereType<Map>()) {
          final i = (c['index'] as num?)?.toInt() ?? calls.length;
          final acc = calls.putIfAbsent(i, () => (id: StringBuffer(), name: StringBuffer(), args: StringBuffer()));
          final fn = c['function'] as Map?;
          if (c['id'] != null) acc.id.write(c['id']);
          if (fn?['name'] != null) acc.name.write(fn!['name']);
          if (fn?['arguments'] != null) acc.args.write(fn!['arguments']);
        }
        stop = choice?['finish_reason'] as String? ?? stop;
      }
    }

    Map<String, dynamic> parseArgs(String s) {
      try {
        final v = jsonDecode(s.isEmpty ? '{}' : s);
        return v is Map<String, dynamic> ? v : {};
      } catch (_) {
        return {};
      }
    }

    final ordered = (blocks.keys.toList()..sort()).map((k) => blocks[k]!).toList();
    final toolCalls = anthropic
        ? [
            for (final b in ordered)
              if (b['type'] == 'tool_use')
                AiToolCall('${b['id']}', '${b['name']}', (b['input'] as Map?)?.cast<String, dynamic>() ?? {}),
          ]
        : [
            for (final k in calls.keys.toList()..sort())
              AiToolCall(
                calls[k]!.id.isEmpty ? 'call_$k' : calls[k]!.id.toString(),
                calls[k]!.name.toString(),
                parseArgs(calls[k]!.args.toString()),
              ),
          ];
    if (stop == 'refusal') throw AiException('模型拒绝回答这个请求');
    if (text.isEmpty && toolCalls.isEmpty) throw AiException('模型没有返回内容，请检查接口地址和模型名');
    if (stop == 'max_tokens' || stop == 'length') yield AiText('\n\n（回答达到长度上限，已截断）');
    yield AiTurnEnd(
      AiMessage(
        'assistant',
        text.toString(),
        toolCalls: toolCalls,
        blocks: anthropic ? ordered : null,
        reasoning: reasoning.isEmpty ? null : reasoning.toString(),
      ),
      stop,
    );
  } on SocketException catch (e) {
    throw AiException('无法连接 ${s.host}：${e.message}');
  } on HandshakeException {
    throw AiException('与 ${s.host} 的安全连接失败');
  } finally {
    client.close(force: true);
  }
}

/// 从错误响应中取出说明文字
String _errorMessage(String body) {
  try {
    final j = jsonDecode(body);
    final e = j is Map ? j['error'] : null;
    if (e is Map && e['message'] != null) return '${e['message']}';
    if (e is String) return e;
    if (j is Map && j['message'] != null) return '${j['message']}';
  } catch (_) {
    // 不是 JSON
  }
  final t = body.trim();
  return t.isEmpty ? '没有返回说明' : (t.length > 300 ? '${t.substring(0, 300)}…' : t);
}
