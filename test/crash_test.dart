import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/ai_client.dart';
import 'package:pcl_pw/core/crash.dart';

void main() {
  test('本地规则', () {
    String titles(String log) => analyzeLogs(log).map((f) => f.title).join(',');
    expect(
      titles(
        'java.lang.UnsupportedClassVersionError: a/B has been compiled by a more recent version of the Java Runtime '
        '(class file version 65.0), this version of the Java Runtime only recognizes class file versions up to 52.0',
      ),
      'Java 版本过低',
    );
    expect(
      analyzeLogs(
        '(class file version 65.0), this version of the Java Runtime only recognizes class file versions up to 52.0',
      ).first.detail,
      contains('Java 21'),
    );
    expect(titles('java.lang.OutOfMemoryError: Java heap space'), '内存不足');
    expect(
      titles(" - Mod 'Sodium Extra' (sodium-extra) 0.5.1 requires any version of mod 'sodium', which is missing!"),
      '缺少前置模组或版本不对',
    );
    expect(
      titles('org.spongepowered.asm.mixin.transformer.throwables.MixinTransformerError: An unexpected issue'),
      'Mixin 注入失败',
    );
    expect(titles('# C  [ig9icd64.dll+0x12345]'), '显卡驱动问题');
    expect(titles('Suspected Mods: NONE'), '');
    expect(titles('Suspected Mods: Create (create), Version: 0.5.1'), '崩溃报告怀疑的模组');
    expect(titles('[main/INFO]: Loading 12 mods'), '');
  });

  test('去除隐私信息', () {
    final r = Redactor(
      tokens: ['secret-token-123'],
      names: ['Steve_X'],
      uuids: ['0123abcd-0000-1111-2222-333344445555'],
    );
    final out = r.apply(
      'Setting user: Steve_X\n'
      '--accessToken secret-token-123 --uuid 0123abcd000011112222333344445555\n'
      r'C:\Users\zhuzhi\AppData\Roaming\.minecraft'
      '\n'
      'Connecting to 203.0.113.9, 25565; local 192.168.1.2; version 14.23.5.2860; 1.20.1',
    );
    expect(out, isNot(contains('Steve_X')));
    expect(out, isNot(contains('secret-token')));
    expect(out, isNot(contains('0123abcd')));
    expect(out, isNot(contains('zhuzhi')));
    expect(out, contains('<IP>'));
    expect(out, contains('192.168.1.2'));
    expect(out, contains('14.23.5.2860'));
  });

  test('截取日志', () {
    final lines = [
      for (var i = 0; i < 3000; i++) '[12:00:00] [main/INFO]: line $i',
      'java.lang.NullPointerException: boom',
      for (var i = 0; i < 40; i++) '\tat a.b.C.m$i(C.java:$i)',
      for (var i = 0; i < 500; i++) 'spam',
      for (var i = 0; i < 2000; i++) '[12:00:01] [main/INFO]: tail $i',
    ];
    final out = excerptLog(lines.join('\n'), budget: 20000);
    expect(out.length, lessThan(21000));
    expect(out, contains('NullPointerException: boom'));
    expect(out, contains('C.m14'));
    expect(out, isNot(contains('C.m20(')));
    expect(out, contains('tail 1999'));
  });

  test('合并重复行', () {
    expect(excerptLog(['a', for (var i = 0; i < 5; i++) 'spam', 'b'].join('\n')), 'a\nspam\n（上一行重复 4 次）\nb');
  });

  test('收集崩溃现场', () async {
    final dir = await Directory.systemTemp.createTemp('pw-crash');
    addTearDown(() => dir.delete(recursive: true));
    await Directory(p.join(dir.path, 'crash-reports')).create();
    await File(p.join(dir.path, 'crash-reports', 'crash-1.txt')).writeAsString(
      '---- Minecraft Crash Report ----\nDescription: Mod loading error\nSuspected Mods: Bad Mod (badmod)\n',
    );
    await Directory(p.join(dir.path, 'mods')).create();
    await File(p.join(dir.path, 'mods', 'badmod-1.0.jar')).writeAsString('');
    await File(p.join(dir.path, 'mods', 'off.jar.disabled')).writeAsString('');
    final run = GameRun(
      versionId: 'test',
      description: 'Forge · 1.20.1',
      gameDir: dir.path,
      loaderLibs: ['net.minecraftforge:forge:1.20.1-47.2.18'],
      javaPath: 'java',
      javaMajor: 17,
      memoryGb: 4,
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      secrets: Redactor(),
    )..exitCode = 1;
    final report = await collectCrash(run, ['[main/INFO]: hello']);
    expect(report.sources.map((s) => s.name), ['崩溃报告 crash-1.txt', '游戏输出']);
    expect(report.mods, ['badmod-1.0.jar']);
    expect(report.findings.map((f) => f.title), ['崩溃报告怀疑的模组']);
    expect(report.toPrompt(), contains('退出代码：1'));
  });

  group('AI 流式接口', () {
    late HttpServer server;
    final requests = <Map<String, dynamic>>[];
    final headers = <HttpHeaders>[];

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        requests.add(jsonDecode(await utf8.decoder.bind(req).join()) as Map<String, dynamic>);
        headers.add(req.headers);
        final res = req.response..headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
        if (req.uri.path == '/v1/messages') {
          for (final ev in [
            {'type': 'message_start'},
            {'type': 'content_block_start', 'index': 0},
            {
              'type': 'content_block_delta',
              'index': 0,
              'delta': {'type': 'text_delta', 'text': '你好'},
            },
            {
              'type': 'content_block_delta',
              'index': 0,
              'delta': {'type': 'text_delta', 'text': '，世界'},
            },
            {
              'type': 'message_delta',
              'delta': {'stop_reason': 'end_turn'},
            },
          ]) {
            res.write('event: ${ev['type']}\ndata: ${jsonEncode(ev)}\n\n');
          }
        } else if (req.uri.path == '/v1/chat/completions') {
          for (final c in ['你好', '，世界']) {
            res.write(
              'data: ${jsonEncode({
                'choices': [
                  {
                    'delta': {'content': c},
                  },
                ],
              })}\n\n',
            );
          }
          res.write('data: [DONE]\n\n');
        } else {
          res.statusCode = 401;
          res.write(
            jsonEncode({
              'error': {'message': 'invalid api key'},
            }),
          );
        }
        await res.close();
      });
    });
    tearDown(() => server.close(force: true));

    test('Anthropic', () async {
      final s = AiSettings(
        provider: AiProvider.anthropic,
        baseUrl: 'http://127.0.0.1:${server.port}',
        model: 'm',
        apiKey: 'k',
      );
      expect(await aiChat(s, 'sys', const [AiMessage('user', 'hi')]).join(), '你好，世界');
      expect(requests.last['system'], 'sys');
      expect(headers.last.value('x-api-key'), 'k');
      expect(headers.last.value('anthropic-version'), isNotNull);
    });

    test('OpenAI 兼容', () async {
      final s = AiSettings(
        provider: AiProvider.openai,
        baseUrl: 'http://127.0.0.1:${server.port}/v1/',
        model: 'm',
        apiKey: '',
      );
      expect(s.ready, isTrue);
      expect(await aiChat(s, 'sys', const [AiMessage('user', 'hi')]).join(), '你好，世界');
      expect((requests.last['messages'] as List).first, {'role': 'system', 'content': 'sys'});
    });

    test('错误信息', () async {
      final s = AiSettings(
        provider: AiProvider.openai,
        baseUrl: 'http://127.0.0.1:${server.port}/bad',
        model: 'm',
        apiKey: 'k',
      );
      expect(
        () => aiChat(s, 'sys', const [AiMessage('user', 'hi')]).join(),
        throwsA(predicate((e) => '$e'.contains('HTTP 401') && '$e'.contains('invalid api key'))),
      );
    });
  });
}
