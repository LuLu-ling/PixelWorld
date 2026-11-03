import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'core/accounts.dart';
import 'core/ai_chat.dart';
import 'core/ai_context.dart';
import 'core/ai_tools.dart';
import 'core/cat_ini.dart';
import 'core/config.dart';
import 'core/crash.dart';
import 'core/download.dart';
import 'core/extra_loaders.dart';
import 'core/install.dart';
import 'core/instance_files.dart';
import 'core/instance.dart';
import 'core/instance_config.dart';
import 'core/java.dart';
import 'core/launch.dart';
import 'core/loaders.dart';
import 'core/memory.dart';
import 'core/microsoft.dart';
import 'core/modrinth.dart';
import 'core/paths.dart';
import 'core/precheck.dart';
import 'core/task.dart';
import 'platform.dart';
import 'widgets/loader_label.dart';

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
    chats
      ..toolbox = AiToolbox(this)
      ..toolsEnabled = (() => config.aiTools)
      ..confirmRead = (() => config.aiConfirmRead)
      ..contextWindow = ((ai) =>
          config.aiContextWindow > 0 ? config.aiContextWindow : knownContextWindow(ai.model) ?? defaultContextWindow)
      ..compactAt = (() => config.aiCompactAt);
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

  /// 所有任务（安装、下载、启动），新的在前；完成的任务保留到手动清除
  final tasks = <TaskProgress>[];

  List<TaskProgress> get runningTasks => tasks.where((t) => t.state == TaskState.running).toList();

  /// 登记并执行一个任务，结束时记录成功或失败
  Future<T> track<T>(TaskProgress t, Future<T> Function() body) async {
    tasks.insert(0, t);
    notifyListeners();
    try {
      final r = await body();
      t.complete();
      return r;
    } catch (e) {
      t.fail(e);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void clearFinishedTasks() {
    tasks.removeWhere((t) => t.state != TaskState.running);
    notifyListeners();
  }

  void removeTask(TaskProgress t) {
    tasks.remove(t);
    notifyListeners();
  }

  /// 资源收藏夹
  List<ResourceHit> favorites = Favorites.load();

  /// 版本设置页正在查看的版本
  String instanceId = '';

  /// AI 助手的对话（单独通知，避免回答生成时整个界面重建）
  final chats = ChatStore.load();

  /// 最近一次启动的游戏，用于崩溃分析
  GameRun? lastRun;

  final _crashes = StreamController<CrashReport>.broadcast();

  /// 游戏崩溃（非正常退出）时发出收集到的崩溃信息
  Stream<CrashReport> get crashes => _crashes.stream;

  /// 错误分析页正在查看的内容
  CrashReport? diagnosis;

  /// 从日志中去掉的隐私信息：所有账户的玩家名、UUID 与令牌
  Redactor redactor({List<String> extra = const []}) => Redactor(
    tokens: [
      for (final a in accounts.accounts) ...[a.accessToken, ?a.refreshToken],
    ],
    names: [for (final a in accounts.accounts) a.name, ...extra],
    uuids: [for (final a in accounts.accounts) a.uuid],
  );

  /// 重新收集最近一次游戏的信息
  Future<CrashReport?> analyzeLastRun() async {
    final run = lastRun;
    return run == null ? null : collectCrash(run, log.value);
  }

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

  /// 微软登录。登录过一次正版账号后，不再进行正版购买劝导
  Future<Account> loginMicrosoft(MicrosoftLogin login, void Function(DeviceCode) onCode) async {
    final acc = await accounts.upsert(await login.run(onCode));
    await config.update({'selectedAccount': acc.id, 'hintBuy': true});
    return acc;
  }

  bool isFavorite(String id) => favorites.any((f) => f.id == id);

  Future<void> toggleFavorite(ResourceHit hit) async {
    favorites = isFavorite(hit.id) ? favorites.where((f) => f.id != hit.id).toList() : [hit, ...favorites];
    notifyListeners();
    await Favorites.save(favorites);
  }

  InstanceInfo? instance(String id) => versions.where((v) => v.id == id).firstOrNull;

  /// 版本的实际运行目录（考虑版本隔离）；persist 时把首次决定的隔离结果写入实例配置
  Future<String> gameDirOf(InstanceInfo info, {bool persist = false}) =>
      gameDirFor(paths, info, config.isolationMode, persist: persist);

  /// 把 Modrinth 资源安装到指定版本
  Future<InstallResult> installResource(
    ResourceVersion version,
    ResourceType type,
    InstanceInfo instance, {
    String? world,
  }) async {
    final t = TaskProgress(
      '安装 ${version.fileName}',
      steps: [if (type == ResourceType.mod) '解析前置', '下载文件'],
      retry: () => installResource(version, type, instance, world: world).catchError((_) => InstallResult([], [], [])),
    );
    return track(t, () async {
      // 安装资源时确定版本隔离，与启动时一致
      final dir = await gameDirOf(instance, persist: true);
      final r = await Modrinth.install(
        version: version,
        type: type,
        instance: instance,
        gameDir: dir,
        world: world,
        dl: downloader,
        task: t,
      );
      t.output(
        '已安装 ${r.installed.length} 个文件，跳过 ${r.skipped.length} 个已存在的文件'
        '${r.missing.isEmpty ? '' : '，找不到兼容的前置：${r.missing.join('、')}'}',
      );
      return r;
    });
  }

  /// 给已安装的版本添加 OptiFine（作为模组）
  Future<void> addOptiFineMod(InstanceInfo instance, String version) {
    final t = TaskProgress(
      '为 ${instance.id} 添加 OptiFine',
      steps: [
        downloadStep(loaderComponent(LoaderKind.optifine, instance.gameVersion, version)),
        installStep(loaderComponent(LoaderKind.optifine, instance.gameVersion, version)),
      ],
    );
    return track(t, () async {
      final dir = await gameDirOf(instance, persist: true);
      await installOptiFineAsMod(dir, instance.gameVersion, version, downloader, t);
    });
  }

  /// 删除版本文件夹（移到回收站）
  Future<void> deleteVersion(String id) async {
    if (id.isEmpty || id.contains('..') || RegExp(r'[\\/]').hasMatch(id)) throw Exception('非法版本号');
    await moveToTrash(paths.versionDir(id));
    if (config.selectedVersion == id) await config.update({'selectedVersion': ''});
    await refreshVersions();
  }

  /// 安装原版或加载器，完成后选中新版本
  Future<String> installVersion(
    String gameVersion, {
    LoaderKind? loader,
    String loaderVersion = '',
    String? name,

    /// 同时安装的 OptiFine 版本；有加载器时作为模组放进 mods
    String? optifine,
  }) async {
    // 计划的步骤：原版没装过时先下载、安装原版，再下载、安装加载器
    final vanillaMissing = !File(paths.versionJson(gameVersion)).existsSync();
    final component = loader == null ? null : loaderComponent(loader, gameVersion, loaderVersion);
    final t = TaskProgress(
      '安装 ${name ?? defaultVersionName(loader, gameVersion, loaderVersion)}',
      steps: [
        if (loader == null || vanillaMissing) ...[
          downloadStep('Minecraft $gameVersion'),
          installStep('Minecraft $gameVersion'),
        ],
        if (component != null) ...[downloadStep(component), installStep(component)],
        if (optifine != null) ...[
          downloadStep(loaderComponent(LoaderKind.optifine, gameVersion, optifine)),
          installStep(loaderComponent(LoaderKind.optifine, gameVersion, optifine)),
        ],
      ],
      retry: () => installVersion(
        gameVersion,
        loader: loader,
        loaderVersion: loaderVersion,
        name: name,
        optifine: optifine,
      ).catchError((_) => ''),
    );
    return track(t, () async {
      final g = paths;
      final id = loader == null
          ? await installVanilla(g, gameVersion, downloader, t, name: name)
          : await installLoader(g, loader, gameVersion, loaderVersion, downloader, t, name: name);
      if (optifine != null) {
        // 安装资源时确定版本隔离，与启动时一致
        final dir = await gameDirOf(await analyzeInstance(g, id), persist: true);
        await installOptiFineAsMod(dir, gameVersion, optifine, downloader, t);
      }
      await refreshVersions();
      await selectVersion(id);
      t.output('已安装为 $id');
      return id;
    });
  }

  void _log(List<String> lines) {
    final next = [...log.value, ...lines];
    log.value = next.length > 5000 ? next.sublist(next.length - 5000) : next;
  }

  void _launcherLog(String line) => _log(['[${AppInfo.name}] $line']);

  void killGame() {
    lastRun?.killed = true;
    _game?.kill();
  }

  /// 启动当前选择的版本。返回 false 表示用户在劝导中取消了启动。
  Future<bool> launch(
    LaunchPrompts prompts, {
    required ({int width, int height}) launcherSize,
    required ({int width, int height}) screenSize,
  }) async {
    if (!isDesktop) throw Exception(mobileLaunchUnsupported);
    if (gameState != GameState.idle) throw Exception('游戏已在运行');
    final id = config.selectedVersion;
    if (id.isEmpty) throw Exception('请先选择一个游戏版本');
    var acc = selectedAccount;
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
    final t = TaskProgress('启动 $id', steps: const ['检查文件', '准备启动', '启动游戏']);
    task = t;
    tasks.insert(0, t);
    gameState = GameState.preparing;
    log.value = const [];
    notifyListeners();
    try {
      final dl = downloader;
      if (acc.type == AccountType.microsoft) {
        t.setStage('验证账户');
        final refreshed = await refreshIfNeeded(acc, cfg.msClientId);
        if (!identical(refreshed, acc)) acc = await accounts.upsert(refreshed);
      }
      t.setStage('分析版本');
      final info = await analyzeInstance(g, id);
      final inst = readInstanceSettings(g.versionDir(id));
      // 首次启动时决定并记录版本隔离
      final gameDir = await gameDirFor(g, info, cfg.isolationMode, persist: true);
      await Directory(gameDir).create(recursive: true);

      t.beginStep('检查文件');
      final v = await ensureVersionFiles(g, id, dl, t, resourcesDir: () => p.join(gameDir, 'resources'));
      final java = await ensureJava(v, inst.java, cfg.javaPath, dl, t);

      t.beginStep('准备启动');
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

      t.beginStep('启动游戏');
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

      _afterLaunched(cfg.afterLaunch);
      if (detached) {
        gameState = GameState.idle;
      } else {
        _game = proc;
        gameState = GameState.running;
        final run = lastRun = GameRun(
          versionId: id,
          description: describeVersion(info),
          gameDir: gameDir,
          loaderLibs: [
            for (final l in v.libraries)
              if (RegExp(
                r'^(net\.fabricmc:fabric-loader|org\.quiltmc:quilt-loader|net\.minecraftforge:(forge|fmlloader)|net\.neoforged:(neoforge|forge|fancymodloader)|com\.cleanroommc:cleanroom|optifine:optifine|net\.labymod:)',
              ).hasMatch('${l['name']}'))
                '${l['name']}',
          ],
          javaPath: java.path,
          javaMajor: java.major,
          memoryGb: memory.max,
          startedAt: DateTime.now(),
          secrets: redactor(extra: [if (inst.server.trim().isNotEmpty) inst.server.trim().split(':').first]),
        );
        final parser = LogParser(_log);
        decodeOutput(proc.stdout).listen(parser.push);
        decodeOutput(proc.stderr).listen(parser.push);
        unawaited(
          proc.exitCode.then((code) {
            parser.push('\n');
            _launcherLog('游戏已退出，代码 $code');
            _game = null;
            lastExitCode = code;
            run.exitCode = code;
            gameState = GameState.idle;
            notifyListeners();
            unawaited(_checkCrash(run));
          }),
        );
      }
      t.complete();
      return true;
    } catch (e) {
      t.fail(e);
      if (_game == null) gameState = GameState.idle;
      _launcherLog('启动失败：$e');
      rethrow;
    } finally {
      task = null;
      notifyListeners();
    }
  }

  /// 游戏退出后检查是否崩溃：退出代码非 0（不是用户结束的），或生成了崩溃报告
  Future<void> _checkCrash(GameRun run) async {
    var crashed = false;
    try {
      final report = await collectCrash(run, log.value);
      crashed = !run.killed && (run.exitCode != 0 || report.sources.any((s) => s.name != '游戏输出'));
      if (crashed) {
        _launcherLog('游戏崩溃了，可以在错误分析中查看原因');
        _crashes.add(report);
      }
    } catch (e) {
      _launcherLog('收集崩溃信息失败：$e');
    } finally {
      _afterExited(config.afterLaunch, crashed: crashed);
    }
  }

  // ---------- 启动器可见性，与 PCL-CE 的 LauncherVisibility 一致 ----------

  Window? get _window => isDesktop ? WindowManager.instance.getCurrent() : null;

  void _afterLaunched(String after) {
    switch (after) {
      case 'exit':
        // 游戏以独立进程启动，启动器直接退出
        exit(0);
      case 'minimizeAndReopen':
        _window?.minimize();
      case 'hideAndExit' || 'hideAndReopen':
        _window?.hide();
    }
  }

  void _afterExited(String after, {bool crashed = false}) {
    switch (after) {
      // 崩溃时不退出，显示启动器以便查看原因
      case 'hideAndExit' when !crashed:
        exit(0);
      case 'hideAndExit':
        _window
          ?..show()
          ..restore()
          ..focus();
      case 'hideAndReopen' || 'minimizeAndReopen':
        _window
          ?..show()
          ..restore()
          ..focus();
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
