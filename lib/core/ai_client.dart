import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'paths.dart';
import 'secure.dart';

/// 接口格式：OpenAI 兼容（DeepSeek、通义千问、Kimi、OpenRouter、Ollama 等）或 Anthropic
enum AiProvider { openai, anthropic }

/// 常用服务的预设：只填写接口地址，部分附带推荐的模型
const aiPresets = [
  (label: 'DeepSeek', provider: AiProvider.openai, url: 'https://api.deepseek.com/v1', model: 'deepseek-chat'),
  (
    label: '通义千问',
    provider: AiProvider.openai,
    url: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    model: 'qwen-plus',
  ),
  (label: 'Kimi', provider: AiProvider.openai, url: 'https://api.moonshot.cn/v1', model: ''),
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

class AiMessage {
  const AiMessage(this.role, this.content);

  /// user 或 assistant
  final String role;
  final String content;
}

class AiException implements Exception {
  AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 流式对话，逐段返回模型输出的文字
Stream<String> aiChat(AiSettings s, String system, List<AiMessage> messages) async* {
  final base = s.baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  final anthropic = s.provider == AiProvider.anthropic;
  final url = Uri.parse(anthropic ? '${base.endsWith('/v1') ? base : '$base/v1'}/messages' : '$base/chat/completions');
  final body = anthropic
      ? {
          'model': s.model,
          'max_tokens': 16000,
          'stream': true,
          'system': system,
          'messages': [
            for (final m in messages) {'role': m.role, 'content': m.content},
          ],
        }
      : {
          'model': s.model,
          'stream': true,
          'messages': [
            {'role': 'system', 'content': system},
            for (final m in messages) {'role': m.role, 'content': m.content},
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

    var gotText = false;
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
        switch (ev['type']) {
          case 'content_block_delta':
            final delta = ev['delta'] as Map?;
            if (delta?['type'] == 'text_delta') {
              gotText = true;
              yield '${delta!['text']}';
            }
          case 'message_delta':
            final stop = (ev['delta'] as Map?)?['stop_reason'];
            if (stop == 'refusal') throw AiException('模型拒绝回答这个请求');
            if (stop == 'max_tokens') yield '\n\n（回答达到长度上限，已截断）';
        }
      } else {
        final choice = (ev['choices'] as List?)?.firstOrNull as Map?;
        final content = (choice?['delta'] as Map?)?['content'];
        if (content is String && content.isNotEmpty) {
          gotText = true;
          yield content;
        }
        if (choice?['finish_reason'] == 'length') yield '\n\n（回答达到长度上限，已截断）';
      }
    }
    if (!gotText) throw AiException('模型没有返回内容，请检查接口地址和模型名');
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
