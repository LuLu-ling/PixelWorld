import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/auth/auth.dart';
import 'package:pcl_pw/core/auth/oauth.dart';

/// 本机假的令牌服务：按顺序处理每次轮询，'drop' 表示直接断开连接（模拟后台断网）
Future<(HttpServer, List<String>)> _server(List<String> replies) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final seen = <String>[];
  var i = 0;
  server.listen((req) async {
    final body = await utf8.decoder.bind(req).join();
    seen.add('${req.uri.path} $body');
    final reply = i < replies.length ? replies[i++] : 'pending';
    if (reply == 'drop') {
      final socket = await req.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    req.response.headers.contentType = ContentType.json;
    if (req.uri.path == '/device') {
      req.response.write(
        jsonEncode({
          'device_code': 'dev-1',
          'user_code': 'ABCD-EFGH',
          'verification_uri': 'https://example.com/device',
          'expires_in': 900,
          'interval': 1,
        }),
      );
    } else if (reply == 'ok') {
      req.response.write(jsonEncode({'access_token': 'at', 'refresh_token': 'rt', 'expires_in': 3600}));
    } else {
      req.response.statusCode = 400;
      req.response.write(jsonEncode({'error': 'authorization_pending'}));
    }
    await req.response.close();
  });
  return (server, seen);
}

void main() {
  test('保存的设备代码可以还原', () {
    final c = PendingDeviceCode(
      deviceCode: 'dev',
      code: DeviceCode(userCode: 'ABCD', verificationUri: 'https://e/x', completeUri: 'https://e/x?c=ABCD'),
      interval: 5,
      expiresAt: DateTime.now().millisecondsSinceEpoch + 600000,
    );
    final back = PendingDeviceCode.fromJson(jsonDecode(jsonEncode(c.toJson())) as Map<String, dynamic>)!;
    expect(back.deviceCode, 'dev');
    expect(back.code.userCode, 'ABCD');
    expect(back.code.completeUri, 'https://e/x?c=ABCD');
    expect(back.code.resumed, isTrue);
    expect(back.interval, 5);
    expect(back.expired, isFalse);
    expect(PendingDeviceCode.fromJson({'deviceCode': 'x'}), isNull);
  });

  test('轮询时连接断开不算失败，继续等到授权完成', () async {
    // 第一个回复给申请代码的请求，之后两次轮询断网，再一次等待中，最后成功
    final (server, seen) = await _server(['device', 'drop', 'drop', 'pending', 'ok']);
    addTearDown(server.close);
    final base = 'http://127.0.0.1:${server.port}';
    final client = OAuthClient(clientId: 'cid', deviceEndpoint: '$base/device', tokenEndpoint: '$base/token');
    PendingDeviceCode? saved;
    DeviceCode? shown;
    final t = await client
        .deviceLogin('scope', (c) => shown = c, cancelled: () => false, onPending: (c) => saved = c)
        .timeout(const Duration(seconds: 30));
    expect(t.accessToken, 'at');
    expect(shown?.userCode, 'ABCD-EFGH');
    expect(shown?.resumed, isFalse);
    expect(saved?.deviceCode, 'dev-1');
    expect(seen.where((s) => s.startsWith('/token')).length, 4);
  });

  test('接着上次的代码时不再申请新代码，马上查一次', () async {
    final (server, seen) = await _server(['ok']);
    addTearDown(server.close);
    final base = 'http://127.0.0.1:${server.port}';
    final client = OAuthClient(clientId: 'cid', deviceEndpoint: '$base/device', tokenEndpoint: '$base/token');
    final resume = PendingDeviceCode(
      deviceCode: 'old-code',
      code: DeviceCode(userCode: 'WXYZ', verificationUri: 'https://e/x', resumed: true),
      interval: 30,
      expiresAt: DateTime.now().millisecondsSinceEpoch + 600000,
    );
    final sw = Stopwatch()..start();
    final t = await client
        .deviceLogin('scope', (_) {}, cancelled: () => false, resume: resume)
        .timeout(const Duration(seconds: 10));
    expect(t.accessToken, 'at');
    expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
    expect(seen, hasLength(1));
    expect(seen.single, contains('device_code=old-code'));
  });

  test('切回启动器时不用等轮询间隔', () async {
    final (server, _) = await _server(['device', 'ok']);
    addTearDown(server.close);
    final base = 'http://127.0.0.1:${server.port}';
    final client = OAuthClient(clientId: 'cid', deviceEndpoint: '$base/device', tokenEndpoint: '$base/token');
    // 服务器给的间隔是 1 秒：拿到代码 0.2 秒后唤醒，应该提前查到结果
    final sw = Stopwatch()..start();
    final f = client.deviceLogin(
      'scope',
      (_) => Future<void>.delayed(const Duration(milliseconds: 200), OAuthClient.wakeUp),
      cancelled: () => false,
    );
    final t = await f.timeout(const Duration(seconds: 10));
    expect(t.accessToken, 'at');
    expect(sw.elapsed, lessThan(const Duration(milliseconds: 900)));
  });
}
