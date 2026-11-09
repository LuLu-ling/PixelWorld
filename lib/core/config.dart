import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../app_info.dart';
import 'paths.dart';

/// 默认 JVM 参数
const defaultJvmArgs =
    '-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true -Dlog4j2.formatMsgNoLookups=true';

/// 旧版启动器的默认参数名，保留给已有配置重置逻辑使用
const pclDefaultJvmArgs = defaultJvmArgs;

/// 版本隔离默认策略：
/// 0 关闭 / 1 仅隔离可安装 Mod 的版本 / 2 仅隔离非正式版 / 3 隔离非正式版与可安装 Mod 的版本 / 4 隔离所有版本
const isolationModes = {0: '关闭', 1: '隔离可安装 Mod 的版本', 2: '隔离非正式版', 3: '隔离可安装 Mod 的版本与非正式版', 4: '隔离所有版本'};

class GameFolder {
  GameFolder({required this.name, required this.path, required this.custom});

  final String name;
  final String path;

  /// false：自动发现；true：用户添加或从 PCL-CE 导入
  final bool custom;

  Map<String, dynamic> toJson() => {'name': name, 'path': path, 'type': custom ? 'custom' : 'original'};

  static GameFolder fromJson(Map<String, dynamic> j) =>
      GameFolder(name: '${j['name']}', path: '${j['path']}', custom: j['type'] != 'original');
}

/// 启动器全局设置，保存在应用数据目录的 config.json
class LauncherConfig extends ChangeNotifier {
  LauncherConfig._(this._data);

  final Map<String, dynamic> _data;

  static Map<String, dynamic> _defaults() => {
    'gameDir': p.join(Paths.appData, '.minecraft'),
    'gameFolders': <dynamic>[],
    'isolationMode': 4,
    'javaPath': '',
    'memoryMode': 'auto',
    'memoryTick': 15,
    'memoryInitialTick': 0,
    'lockMemory': false,
    'jvmArgs': defaultJvmArgs,
    'gameArgs': '',
    'preferredIpStack': 'default',
    'windowMode': 'default',
    'windowWidth': 854,
    'windowHeight': 480,
    'versionType': 'Pixel World',
    'preLaunchCommand': '',
    'preLaunchWait': true,
    'processPriority': 'normal',
    'autoGameLanguage': true,
    'gpuPreference': true,
    'downloadSource': Platform.localeName.startsWith('zh') ? 'bmclapi' : 'official',
    'concurrency': 16,
    'themeMode': 'system',
    // 主题色种子，按 MD3 生成整套浅色/深色配色
    'themeColor': 0xFF2F6B4F,
    'selectedVersion': '',
    'selectedAccount': '',
    'msClientId': '',
    'afterLaunch': 'keep',
    // 启动次数，用于正版购买劝导与赞助劝导（与 PCL 的 SystemLaunchCount 对应）
    'launchCount': 0,
    // 登录过一次正版账号后不再进行正版购买劝导（与 PCL 的 HintBuy 对应）
    'hintBuy': false,
    // 首页的使用提示与 Minecraft 版本动态
    'homeHints': true,
    'homeNews': true,
    // AI 排障：接口格式、地址与模型（API Key 加密保存在 ai.dat）；发送前是否让用户确认内容
    'aiProvider': 'openai',
    'aiBaseUrl': '',
    'aiModel': '',
    'aiConfirm': true,
    // 允许 AI 执行启动器操作（修改操作都需要用户确认）；只读操作是否也需要确认
    'aiTools': true,
    'aiConfirmRead': false,
    // 上下文长度（0 表示按模型自动判断）与自动压缩的阈值（0 表示不自动压缩）
    'aiContextWindow': 0,
    'aiCompactAt': 64000,
    // 安卓：首次打开时已经询问过游戏文件夹放在哪里
    'storageAsked': false,
    // 安卓：游戏的渲染分辨率相对屏幕分辨率的比例（代替桌面端的窗口大小）
    'renderScale': 1.0,
    // 安卓：渲染器（见 android_runtime.dart 的 androidRenderers），版本设置可以单独覆盖
    'androidRenderer': 'auto',
    // 安卓：游戏内叠加层（可拖动的小球，点开可以看基础信息、问 AI）
    'gameHud': true,
    // 安卓：游戏内 AI 与提问时附带的日志
    'gameHudAi': true,
    'gameHudAiLog': true,
    // 启动器更新：通道为空时跟随这个构建自己的通道（见 AppInfo.channel）；启动时自动检查
    'updateChannel': '',
    'updateAutoCheck': true,
    // 跳过的版本（标签或 nightly 的提交号），自动检查时不再提示
    'updateSkipped': '',
    // 已关闭的公告编号，不再显示
    'dismissedNotices': <String>[],
    // 已关闭的更新日志版本，关闭后同一个版本不再显示（换版本后重新出现）
    'dismissedChangelog': '',
  };

  static File get _file => File(p.join(Paths.appData, 'config.json'));

  static LauncherConfig load() {
    final data = _defaults();
    try {
      if (_file.existsSync()) {
        final saved = jsonDecode(_file.readAsStringSync());
        if (saved is Map<String, dynamic>) data.addAll(saved);
        // 旧配置里的版本类型是旧品牌名，读取时迁移
        if (data['versionType'] == 'PCL.PW') data['versionType'] = 'Pixel World';
      }
    } catch (_) {
      // 配置损坏时回落到默认值
    }
    return LauncherConfig._(data);
  }

  Future<void> _save() async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(const JsonEncoder.withIndent('  ').convert(_data));
  }

  Future<void> update(Map<String, dynamic> patch) async {
    _data.addAll(patch);
    notifyListeners();
    await _save();
  }

  T _get<T>(String key) => _data[key] as T;

  String get gameDir => _get('gameDir');
  String get updateChannel => _get('updateChannel');
  bool get updateAutoCheck => _get('updateAutoCheck');
  String get updateSkipped => _get('updateSkipped');
  List<String> get dismissedNotices => [for (final x in (_data['dismissedNotices'] as List? ?? const [])) '$x'];
  String get dismissedChangelog => _get('dismissedChangelog');
  bool get storageAsked => _get('storageAsked');
  double get renderScale => (_data['renderScale'] as num).toDouble().clamp(0.25, 1.0);
  String get androidRenderer => _get('androidRenderer');
  bool get gameHud => _data['gameHud'] as bool? ?? true;
  bool get gameHudAi => _data['gameHudAi'] as bool? ?? true;
  bool get gameHudAiLog => _data['gameHudAiLog'] as bool? ?? true;
  List<GameFolder> get gameFolders =>
      (_data['gameFolders'] as List).whereType<Map<String, dynamic>>().map(GameFolder.fromJson).toList();
  int get isolationMode => (_data['isolationMode'] as num).toInt();
  String get javaPath => _get('javaPath');
  String get memoryMode => _get('memoryMode');
  int get memoryTick => (_data['memoryTick'] as num).toInt();
  int get memoryInitialTick => (_data['memoryInitialTick'] as num).toInt();
  bool get lockMemory => _get('lockMemory');
  String get jvmArgs => _get('jvmArgs');
  String get gameArgs => _get('gameArgs');
  String get preferredIpStack => _get('preferredIpStack');
  String get windowMode => _get('windowMode');
  int get windowWidth => (_data['windowWidth'] as num).toInt();
  int get windowHeight => (_data['windowHeight'] as num).toInt();
  String get versionType => _get('versionType');
  String get preLaunchCommand => _get('preLaunchCommand');
  bool get preLaunchWait => _get('preLaunchWait');
  String get processPriority => _get('processPriority');
  bool get autoGameLanguage => _get('autoGameLanguage');
  bool get gpuPreference => _get('gpuPreference');
  String get downloadSource => _get('downloadSource');
  int get concurrency => (_data['concurrency'] as num).toInt();
  String get themeMode => _get('themeMode');
  int get themeColor => (_data['themeColor'] as num?)?.toInt() ?? 0xFF2F6B4F;
  String get selectedVersion => _get('selectedVersion');
  String get selectedAccount => _get('selectedAccount');
  String get msClientId => _get('msClientId');

  /// 用户没有填写时使用 CI 注入的默认 Client ID
  String get effectiveMsClientId {
    final custom = msClientId.trim();
    return custom.isEmpty ? AppInfo.msClientId : custom;
  }
  String get afterLaunch => _get('afterLaunch');
  int get launchCount => (_data['launchCount'] as num).toInt();
  bool get hintBuy => _get('hintBuy');
  bool get homeHints => _get('homeHints');
  bool get homeNews => _get('homeNews');
  String get aiProvider => _get('aiProvider');
  String get aiBaseUrl => _get('aiBaseUrl');
  String get aiModel => _get('aiModel');
  bool get aiConfirm => _get('aiConfirm');
  bool get aiTools => _get('aiTools');
  bool get aiConfirmRead => _get('aiConfirmRead');
  int get aiContextWindow => (_data['aiContextWindow'] as num).toInt();
  int get aiCompactAt => (_data['aiCompactAt'] as num).toInt();
}
