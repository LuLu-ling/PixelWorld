import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'app_info.dart';
import 'core/accounts.dart';
import 'core/cat_ini.dart';
import 'core/config.dart';
import 'core/download.dart';
import 'core/install.dart';
import 'core/instance.dart';
import 'core/instance_config.dart';
import 'core/java.dart';
import 'core/launch.dart';
import 'core/memory.dart';
import 'core/paths.dart';
import 'core/precheck.dart';
import 'core/task.dart';

enum GameState { idle, preparing, running }

/// 启动过程中需要界面参与的决定（正版验证、赞助劝导）
abstract interface class LaunchPrompts {
  Future<OwnershipChoice> askOwnership();
  Future<void> askSponsor(int launchCount);
}

/// 全局状态：设置、账户、版本列表、游戏进程与日志
class AppState extends ChangeNotifier {
  AppState._(this.config, this.accounts) {
    config.addListener(notifyListeners);
  }

  static Future<AppState> create() async {
    await Paths.init();
    final s = AppState._(LauncherConfig.load(), AccountStore.load());
    await s.refreshVersions();
    return s;
  }

  final LauncherConfig config;
  final AccountStore accounts;

  GamePaths get paths => GamePaths(config.gameDir);

  List<InstanceInfo> versions = [];
  bool loadingVersions = false;

  GameState gameState = GameState.idle;
  TaskProgress? task;
  Process? _game;
  int? lastExitCode;

  /// 最近的游戏日志（最多保留 5000 行）
  final log = ValueNotifier<List<String>>(const []);

  Downloader get downloader =>
      Downloader(useMirror: config.downloadSource == 'bmclapi', concurrency: config.concurrency);

  Account? get selectedAccount => accounts.find(config.selectedAccount);

  InstanceInfo? get selectedVersion => versions.where((v) => v.id == config.selectedVersion).firstOrNull;

  Future<void> refreshVersions() async {
    loadingVersions = true;
    notifyListeners();
    try {
      versions = await installedVersions(paths);
      // 当前选择的版本不存在时，按 PCL.ini 记录的上次版本或第一个版本选择
      if (selectedVersion == null && versions.isNotEmpty) {
        final last = readCatIni(p.join(config.gameDir, 'PCL.ini'))['Version'];
        final pick = versions.where((v) => v.id == last).firstOrNull ?? versions.first;
        await config.update({'selectedVersion': pick.id});
      }
    } finally {
      loadingVersions = false;
      notifyListeners();
    }
  }

  Future<void> selectVersion(String id) async {
    await config.update({'selectedVersion': id});
    // 记住当前文件夹选择的版本，PCL-CE 也会读取
    await writeCatIni(p.join(config.gameDir, 'PCL.ini'), 'Version', id).catchError((_) {});
  }

  /// 切换游戏文件夹，并读取该文件夹在 PCL.ini 中记录的上次选择的版本
  Future<void> selectFolder(String path) async {
    path = p.normalize(p.absolute(path));
    await Directory(p.join(path, 'versions')).create(recursive: true);
    final last = readCatIni(p.join(path, 'PCL.ini'))['Version'] ?? '';
    await config.update({
      'gameDir': path,
      'selectedVersion': last.isNotEmpty && Directory(p.join(path, 'versions', last)).existsSync() ? last : '',
    });
    await refreshVersions();
  }

  Future<Account> addOfflineAccount(String name) async {
    final acc = await accounts.addOffline(name);
    await config.update({'selectedAccount': acc.id});
    return acc;
  }

  Future<void> removeAccount(String id) async {
    await accounts.remove(id);
    if (config.selectedAccount == id) {
      await config.update({'selectedAccount': accounts.accounts.firstOrNull?.id ?? ''});
    } else {
      notifyListeners();
    }
  }

  Future<void> selectAccount(String id) => config.update({'selectedAccount': id});

  void _log(List<String> lines) {
    final next = [...log.value, ...lines];
    log.value = next.length > 5000 ? next.sublist(next.length - 5000) : next;
  }

  void _launcherLog(String line) => _log(['[${AppInfo.name}] $line']);

  void killGame() => _game?.kill();

  /// 启动当前选择的版本。返回 false 表示用户在劝导中取消了启动。
  Future<bool> launch(
    LaunchPrompts prompts, {
    required ({int width, int height}) launcherSize,
    required ({int width, int height}) screenSize,
  }) async {
    if (gameState != GameState.idle) throw Exception('游戏已在运行');
    final id = config.selectedVersion;
    if (id.isEmpty) throw Exception('请先选择一个游戏版本');
    final acc = selectedAccount;
    if (acc == null) throw Exception('请先添加一个账户');

    // ---- 正版购买劝导与赞助劝导 ----
    var demo = false;
    if (needsOwnershipCheck(acc, hintBuy: config.hintBuy)) {
      switch (await prompts.askOwnership()) {
        case OwnershipChoice.cancel:
        case OwnershipChoice.buy:
          return false;
        case OwnershipChoice.demo:
          demo = true;
      }
    }
    final count = config.launchCount + 1;
    if (shouldAskSponsor(count)) unawaited(prompts.askSponsor(count));

    final g = paths;
    final cfg = config;
    final t = TaskProgress('启动 $id');
    task = t;
    gameState = GameState.preparing;
    log.value = const [];
    notifyListeners();
    try {
      final dl = downloader;
      t.setStage('分析版本');
      final info = await analyzeInstance(g, id);
      final inst = readInstanceSettings(g.versionDir(id));
      // 首次启动时决定并记录版本隔离
      final gameDir = await gameDirFor(g, info, cfg.isolationMode, persist: true);
      await Directory(gameDir).create(recursive: true);

      final v = await ensureVersionFiles(g, id, dl, t, resourcesDir: () => p.join(gameDir, 'resources'));
      final java = await ensureJava(v, inst.java, cfg.javaPath, dl, t);

      t.setStage('解压本地库');
      final nativesDir = nativesDirFor(g, id);
      await extractNatives(g, v, nativesDir);

      final memory = planMemory(
        cfg,
        inst,
        modable: info.modable,
        optifine: info.optifine,
        gameDir: gameDir,
        is64BitJava: java.is64,
      );
      final size = switch (cfg.windowMode) {
        'custom' => (width: cfg.windowWidth.clamp(100, 100000), height: cfg.windowHeight.clamp(100, 100000)),
        'launcher' => launcherSize,
        'maximized' => screenSize,
        _ => (width: 854, height: 480),
      };
      final ctx = LaunchContext(
        g: g,
        cfg: cfg,
        v: v,
        id: id,
        acc: acc,
        java: java,
        memory: memory,
        inst: inst,
        nativesDir: nativesDir,
        gameDir: gameDir,
        windowSize: size,
        demo: demo,
      );
      final args = buildArgs(ctx);

      t.setStage('准备启动');
      await prepareOptions(cfg, gameDir, v.releaseTime).catchError((_) {});
      await writeCatIni(p.join(g.root, 'PCL.ini'), 'Version', id).catchError((_) {});
      if (cfg.gpuPreference) await setGpuPreference(java.path);
      await writeLaunchScript(java.path, args, gameDir, acc, '启动 - $id');
      await runPreLaunch(cfg.preLaunchCommand, cfg.preLaunchWait, g.root, _launcherLog);
      await runPreLaunch(inst.preLaunchCommand, inst.preLaunchWait, g.root, _launcherLog);

      t.setStage('启动游戏');
      _launcherLog('Java: ${java.path}（Java ${java.major}，${java.is64 ? 64 : 32} 位）');
      _launcherLog(
        '内存: ${memory.max.toStringAsFixed(1)} GB'
        '${memory.initial != null ? '，初始 ${memory.initial!.toStringAsFixed(1)} GB' : ''}',
      );
      _launcherLog('工作目录: $gameDir');
      if (demo) _launcherLog('以试玩模式启动');

      final detached = cfg.afterLaunch == 'exit';
      final proc = await startGame(ctx, args, detached: detached);
      await config.update({'launchCount': count});
      await setPriority(proc.pid, cfg.processPriority);

      if (detached) {
        gameState = GameState.idle;
      } else {
        _game = proc;
        gameState = GameState.running;
        final parser = LogParser(_log);
        decodeOutput(proc.stdout).listen(parser.push);
        decodeOutput(proc.stderr).listen(parser.push);
        unawaited(
          proc.exitCode.then((code) {
            parser.push('\n');
            _launcherLog('游戏已退出，代码 $code');
            _game = null;
            lastExitCode = code;
            gameState = GameState.idle;
            notifyListeners();
          }),
        );
      }
      return true;
    } catch (e) {
      if (_game == null) gameState = GameState.idle;
      _launcherLog('启动失败：$e');
      rethrow;
    } finally {
      task = null;
      notifyListeners();
    }
  }

  /// 设置页显示用：按当前设置计算出的内存
  ({double allocated, double free, double total}) memoryPreview() {
    final mem = systemMemory();
    final v = selectedVersion;
    final plan = planMemory(
      config,
      readInstanceSettings(v == null ? null : paths.versionDir(v.id)),
      modable: v?.modable ?? false,
      optifine: v?.optifine ?? false,
      gameDir: config.gameDir,
    );
    return (allocated: plan.max, free: mem.free, total: mem.total);
  }

  Future<List<JavaInfo>> javas() => listJavas();
}
