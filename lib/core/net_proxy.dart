import 'dart:io';

/// 系统代理。Dart 的 HttpClient 默认只认环境变量，不认 Windows / macOS 的系统代理设置，
/// 用户开着 Clash 等工具的「系统代理」时请求会直连而失败。这里读取系统设置，
/// 返回给 [HttpClient.findProxy] 的字符串；代理连不上时回落直连。
class SystemProxy {
  SystemProxy._();

  static ({String? http, String? https, List<String> bypass})? _cached;
  static DateTime _readAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// 用作 `HttpClient.findProxy`
  static String find(Uri uri) {
    final env = HttpClient.findProxyFromEnvironment(uri);
    if (env != 'DIRECT') return '$env; DIRECT';
    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host.startsWith('127.') || host == '::1') return 'DIRECT';
    final cfg = _config();
    if (cfg == null) return 'DIRECT';
    if (cfg.bypass.any((b) => _matches(b, host))) return 'DIRECT';
    final proxy = uri.scheme == 'https' ? (cfg.https ?? cfg.http) : (cfg.http ?? cfg.https);
    return proxy == null ? 'DIRECT' : 'PROXY $proxy; DIRECT';
  }

  static bool _matches(String rule, String host) {
    final r = rule.trim().toLowerCase();
    if (r.isEmpty) return false;
    if (r == '<local>') return !host.contains('.');
    final re = RegExp('^${RegExp.escape(r).replaceAll(r'\*', '.*')}\$');
    return re.hasMatch(host);
  }

  static ({String? http, String? https, List<String> bypass})? _config() {
    // 用户可能随时开关代理，隔一会儿重新读一次
    if (DateTime.now().difference(_readAt) < const Duration(seconds: 30)) return _cached;
    _readAt = DateTime.now();
    try {
      if (Platform.isWindows) {
        final r = Process.runSync('reg', [
          'query',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
        ]);
        _cached = parseWindowsProxy('${r.stdout}');
      } else if (Platform.isMacOS) {
        _cached = parseScutilProxy('${Process.runSync('scutil', ['--proxy']).stdout}');
      } else {
        _cached = null;
      }
    } catch (_) {
      _cached = null;
    }
    return _cached;
  }
}

/// 解析 `reg query ...\Internet Settings` 的输出
({String? http, String? https, List<String> bypass})? parseWindowsProxy(String out) {
  String? value(String name) {
    final m = RegExp('^\\s*$name\\s+REG_\\w+\\s+(.*)\$', multiLine: true, caseSensitive: false).firstMatch(out);
    return m?.group(1)?.trim();
  }

  final enable = value('ProxyEnable');
  if (enable == null || int.tryParse(enable.replaceFirst('0x', ''), radix: 16) != 1) return null;
  final server = value('ProxyServer');
  if (server == null || server.isEmpty) return null;
  String? http, https;
  if (server.contains('=')) {
    // http=127.0.0.1:7890;https=127.0.0.1:7890;socks=...（Dart 不支持 SOCKS，忽略）
    for (final part in server.split(';')) {
      final kv = part.split('=');
      if (kv.length != 2) continue;
      final k = kv[0].trim().toLowerCase();
      final v = kv[1].trim().replaceFirst(RegExp(r'^https?://'), '');
      if (k == 'http') http = v;
      if (k == 'https') https = v;
    }
  } else {
    http = https = server.replaceFirst(RegExp(r'^https?://'), '');
  }
  if (http == null && https == null) return null;
  final bypass = (value('ProxyOverride') ?? '').split(';').where((s) => s.trim().isNotEmpty).toList();
  return (http: http, https: https, bypass: bypass);
}

/// 解析 `scutil --proxy` 的输出
({String? http, String? https, List<String> bypass})? parseScutilProxy(String out) {
  String? value(String name) => RegExp('^\\s*$name\\s*:\\s*(.+)\$', multiLine: true).firstMatch(out)?.group(1)?.trim();
  String? pick(String kind) {
    if (value('${kind}Enable') != '1') return null;
    final host = value('${kind}Proxy');
    final port = value('${kind}Port');
    return host == null || port == null ? null : '$host:$port';
  }

  final http = pick('HTTP');
  final https = pick('HTTPS');
  if (http == null && https == null) return null;
  final bypass = RegExp(r'^\s*\d+\s*:\s*(\S+)$', multiLine: true)
      .allMatches(out.split('ExceptionsList').skip(1).join().split('}').first)
      .map((m) => m.group(1)!)
      .toList();
  return (http: http, https: https, bypass: bypass);
}
