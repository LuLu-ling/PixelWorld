// 手动运行的启动测试：按启动器的流程启动 PW_TEST_GAME_DIR 中的版本（试玩模式），60 秒后检查是否仍在运行。
//   PW_TEST_GAME_DIR=... PW_TEST_VERSIONS=a,b flutter test test/manual/launch_manual_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/accounts.dart';
import 'package:pcl_pw/core/config.dart';
import 'package:pcl_pw/core/download.dart';
import 'package:pcl_pw/core/install.dart';
import 'package:pcl_pw/core/instance.dart';
import 'package:pcl_pw/core/instance_config.dart';
import 'package:pcl_pw/core/java.dart';
import 'package:pcl_pw/core/launch.dart';
import 'package:pcl_pw/core/memory.dart';
import 'package:pcl_pw/core/paths.dart';
import 'package:pcl_pw/core/task.dart';

void main() {
  final dir = Platform.environment['PW_TEST_GAME_DIR'];
  final ids = (Platform.environment['PW_TEST_VERSIONS'] ?? '').split(',').where((s) => s.isNotEmpty);
  setUpAll(() => Paths.appData = Directory.systemTemp.createTempSync('pclpw-launch').path);

  for (final id in ids) {
    test(
      '启动 $id',
      () async {
        final g = GamePaths(dir!);
        final cfg = LauncherConfig.load();
        final dl = Downloader(useMirror: false, concurrency: 16);
        final t = TaskProgress('test');
        final info = await analyzeInstance(g, id);
        final inst = readInstanceSettings(g.versionDir(id));
        final gameDir = await gameDirFor(g, info, 4);
        final v = await ensureVersionFiles(g, id, dl, t, resourcesDir: () => p.join(gameDir, 'resources'));
        final java = await ensureJava(v, inst.java, '', dl, t);
        final natives = nativesDirFor(g, id);
        await extractNatives(g, v, natives);
        final memory = planMemory(cfg, inst, modable: info.modable, optifine: info.optifine, gameDir: gameDir);
        final acc = Account(
          id: 'x',
          type: AccountType.offline,
          name: 'Steve',
          uuid: offlineUuid('Steve'),
          accessToken: newId(),
        );
        final ctx = LaunchContext(
          g: g,
          cfg: cfg,
          v: v,
          id: id,
          acc: acc,
          java: java,
          memory: memory,
          inst: inst,
          nativesDir: natives,
          gameDir: gameDir,
          windowSize: (width: 854, height: 480),
          demo: true,
        );
        final proc = await startGame(ctx, buildArgs(ctx), detached: false);
        final out = <String>[];
        proc.stdout.transform(const Utf8Decoder(allowMalformed: true)).listen(out.add);
        proc.stderr.transform(const Utf8Decoder(allowMalformed: true)).listen(out.add);
        int? code;
        proc.exitCode.then((c) => code = c);
        await Future<void>.delayed(const Duration(seconds: 60));
        final alive = code == null;
        proc.kill();
        final tail = out.join().split('\n').where((l) => l.trim().isNotEmpty).toList();
        // ignore: avoid_print
        print(
          '$id：Java ${java.major}，内存 ${memory.max} GB，${alive ? '60 秒后仍在运行' : '已退出，代码 $code'}\n'
          '  ${tail.skip(tail.length > 6 ? tail.length - 6 : 0).join('\n  ')}',
        );
        expect(alive, isTrue);
      },
      skip: dir == null,
      timeout: const Timeout(Duration(minutes: 8)),
    );
  }
}
