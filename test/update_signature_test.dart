import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/site_api.dart';

/// 一把只用于测试的临时密钥（私钥已丢弃），签名由 OpenSSL 生成：
///   openssl pkeyutl -sign -inkey key.pem -rawin -in update.json | base64 -w0
/// 与 release.yml 的签名命令相同，用来确认 OpenSSL 的签名能被启动器验证
const _opensslKey = 'ui/h6N5owBI6vmD2EsqiGON2vltqsZKTR+4T1PNlhAM=';
const _opensslData = '{"format":1}\n';
const _opensslSig = 'po9AESQ0bb1FDuKJ7M2SjRl1Cx9201jnrE8kt3k/QK4sWhnJ6OflInD7dwAz2oi2Kf1oPveEMGvNUgWrDr0FCA==';

const _update = {
  'format': 1,
  'channels': {
    'stable': {
      'tag': 'v9.9.9',
      'assets': [
        {'name': 'a.apk', 'url': 'https://example.invalid/a.apk', 'size': 1, 'sha256': null},
      ],
    },
  },
};

void main() {
  test('OpenSSL 生成的签名能验证，内容或签名改动后不通过', () async {
    final key = base64.decode(_opensslKey);
    expect(await verifySiteSignature(utf8.encode(_opensslData), _opensslSig, key), isTrue);
    expect(await verifySiteSignature(utf8.encode('{"format":2}\n'), _opensslSig, key), isFalse);
    expect(await verifySiteSignature(utf8.encode(_opensslData), _opensslSig.replaceFirst('p', 'q'), key), isFalse);
    expect(await verifySiteSignature(utf8.encode(_opensslData), 'not base64', key), isFalse);
    expect(await verifySiteSignature(utf8.encode(_opensslData), _opensslSig, key.sublist(1)), isFalse);
  });

  group('fetchUpdateChannels', () {
    late HttpServer server;
    late List<int> publicKey;
    final files = <String, List<int>>{};

    setUp(() async {
      files.clear();
      final pair = await Ed25519().newKeyPair();
      publicKey = (await pair.extractPublicKey()).bytes;
      final good = utf8.encode(jsonEncode(_update));
      final sig = base64.encode((await Ed25519().sign(good, keyPair: pair)).bytes);
      // good：签名正确；tampered：签名后内容被改；unsigned：没有签名文件
      files['/good/update.json'] = good;
      files['/good/update.json.sig'] = utf8.encode('$sig\n');
      final tampered = utf8.encode(jsonEncode(_update).replaceAll('example.invalid', 'evil.invalid'));
      files['/tampered/update.json'] = tampered;
      files['/tampered/update.json.sig'] = utf8.encode(sig);
      files['/unsigned/update.json'] = good;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) {
        final body = files[req.uri.path];
        req.response.statusCode = body == null ? 404 : 200;
        if (body != null) req.response.add(body);
        req.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    String base(String name) => 'http://127.0.0.1:${server.port}/$name';

    test('签名正确时采用', () async {
      final r = await fetchUpdateChannels(bases: [base('good')], publicKey: publicKey);
      expect(r?['stable']?.assets.single.url, 'https://example.invalid/a.apk');
    });

    test('内容被改或没有签名的地址被跳过，换下一个', () async {
      final r = await fetchUpdateChannels(
        bases: [base('tampered'), base('unsigned'), base('good')],
        publicKey: publicKey,
      );
      expect(r?['stable']?.assets.single.url, 'https://example.invalid/a.apk');
    });

    test('全部没有有效签名时返回 null（改用 GitHub API）', () async {
      expect(await fetchUpdateChannels(bases: [base('tampered'), base('unsigned')], publicKey: publicKey), isNull);
      final other = (await (await Ed25519().newKeyPair()).extractPublicKey()).bytes;
      expect(await fetchUpdateChannels(bases: [base('good')], publicKey: other), isNull);
    });
  });
}
