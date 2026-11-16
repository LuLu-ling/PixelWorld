// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonAuto => '自动';

  @override
  String get commonCustom => '自定义';

  @override
  String get commonDefault => '默认';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get commonDownload => '下载';

  @override
  String get commonOpen => '打开';

  @override
  String get commonView => '查看';

  @override
  String commonDeleteFailed(String error) {
    return '删除失败：$error';
  }

  @override
  String get navHome => '启动';

  @override
  String get navDownload => '下载';

  @override
  String get navTools => '工具';

  @override
  String get navFiles => '文件';

  @override
  String get navSettings => '设置';

  @override
  String get navAiAssistant => 'AI 助手';

  @override
  String get subVersions => '实例';

  @override
  String get subLog => '游戏日志';

  @override
  String get subInstance => '实例详情';

  @override
  String get subTasks => '任务';

  @override
  String get subDiagnose => '错误分析';

  @override
  String get tooltipBack => '返回';

  @override
  String get tooltipInstances => '实例列表';

  @override
  String get tooltipNotices => '公告';

  @override
  String get greetingLateNight => '夜深了';

  @override
  String get greetingMorning => '早上好';

  @override
  String get greetingNoon => '中午好';

  @override
  String get greetingAfternoon => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting，$name';
  }

  @override
  String get greetingAdventure => '准备好冒险了吗？';

  @override
  String get tasksIdle => '当前无后台任务';

  @override
  String tasksGamesRunning(int count) {
    return '$count 个游戏实例运行中';
  }

  @override
  String tasksMore(String title, int count) {
    return '$title · 共 $count 个任务';
  }

  @override
  String get accountAdd => '添加账户';

  @override
  String get accountMicrosoft => '正版';

  @override
  String get accountOffline => '离线';

  @override
  String get accountExternal => '外置';

  @override
  String get windowMinimize => '最小化';

  @override
  String get windowMaximize => '最大化';

  @override
  String get windowRestore => '还原';

  @override
  String get windowClose => '关闭';

  @override
  String get comingSoon => '这部分功能正在迁移中';

  @override
  String get settingsGroupGame => '游戏';

  @override
  String get settingsLaunch => '启动';

  @override
  String get settingsManage => '游戏管理';

  @override
  String get settingsGroupLauncher => '启动器';

  @override
  String get settingsAppearance => '个性化';

  @override
  String get settingsMisc => '其他';

  @override
  String get settingsAiModel => '模型与接口';

  @override
  String get settingsAiTools => '工具与服务';

  @override
  String get settingsAiWorkspace => '工作区与联网';

  @override
  String get settingsGroupAbout => '关于';

  @override
  String get settingsAbout => '关于与致谢';

  @override
  String get settingsDocs => '使用文档';

  @override
  String get settingsAiIntro =>
      'AI 助手使用你自己的 AI 服务。支持 OpenAI 兼容接口（DeepSeek、通义千问、Kimi、OpenRouter、本机 Ollama 等）和 Anthropic 接口；费用由你的 AI 服务商收取。';

  @override
  String get languageGroup => '语言';

  @override
  String get language => '界面语言';

  @override
  String get languageHint => '启动器界面使用的语言；「自动设置游戏语言」也会跟随它';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get colorMode => '颜色模式';

  @override
  String get colorModeHint => '启动器界面的明暗模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get uiScale => '界面缩放';

  @override
  String get uiScaleFixed => '整个启动器按这个比例显示';

  @override
  String uiScaleAuto(int percent) {
    return '自动：按屏幕尺寸计算，当前为 $percent%';
  }

  @override
  String get themeColor => '主题色';

  @override
  String get themeColorAuto => '跟随背景：按 Material Design 3 从背景图片取色，换图片后自动更新';

  @override
  String get themeColorManual => '按 Material Design 3 从主题色生成整套浅色与深色配色';

  @override
  String get themeFollowBackground => '跟随背景';

  @override
  String get themeManual => '手动选择';

  @override
  String get themeRecommended => '推荐';

  @override
  String themeCandidate(int index) {
    return '候选 $index';
  }

  @override
  String get homeGroup => '首页';

  @override
  String get homeLayout => '首页布局';

  @override
  String get homeLayoutStandard => '标准';

  @override
  String get homeLayoutSplit => '上下';

  @override
  String get homeLayoutMinimal => '极简';

  @override
  String get homeLayoutStandardHint => '标准：大卡片、公告与快捷按钮、最近游玩';

  @override
  String get homeLayoutSplitHint => '上下：当前实例在顶部，开始游戏和存档在底部，中间留给背景；选背景图片时自动切到这个布局';

  @override
  String get homeLayoutMinimalHint => '极简：只在底部留一条，放当前实例和开始游戏';

  @override
  String get homeHints => '显示使用提示';

  @override
  String get homeHintsHint => '正在使用的版本与免费声明';

  @override
  String get homeNews => '显示 Minecraft 版本动态';

  @override
  String get homeNewsHint => '最新的正式版与快照，简介来自中文 Minecraft Wiki';

  @override
  String get bgImage => '背景图片';

  @override
  String get bgImageFiles => '图片';

  @override
  String bgImageInvalid(String error) {
    return '无法使用这张图片：$error';
  }

  @override
  String get bgImageSet => '显示在整个窗口后面，界面面板会变成毛玻璃';

  @override
  String get bgImageUnset => '选择一张图片作为启动器的背景（只在电脑上生效）';

  @override
  String get bgImageChange => '换一张…';

  @override
  String get bgImageChoose => '选择图片…';

  @override
  String get bgImageRemove => '移除';

  @override
  String get bgFit => '契合度';

  @override
  String get bgFitFill => '填充';

  @override
  String get bgFitFit => '适应';

  @override
  String get bgFitStretch => '拉伸';

  @override
  String get bgFitTile => '平铺';

  @override
  String get bgFitCenter => '居中';

  @override
  String get bgFitSpan => '跨区';

  @override
  String get bgFitFillHint => '填充：铺满整个窗口，多出来的部分裁掉';

  @override
  String get bgFitFitHint => '适应：完整显示整张图片，空出来的地方用图片的颜色填上';

  @override
  String get bgFitStretchHint => '拉伸：拉伸到窗口大小，图片可能变形';

  @override
  String get bgFitTileHint => '平铺：按图片原来的大小重复铺满窗口';

  @override
  String get bgFitCenterHint => '居中：按图片原来的大小放在窗口中间';

  @override
  String get bgFitSpanHint => '跨区：图片铺满整个桌面（所有屏幕），窗口只显示自己所在位置的那一块，移动窗口时背景不动';

  @override
  String get bgBlur => '背景模糊';

  @override
  String get bgBlurHint => '整张背景图片的模糊程度；为 0 时背景保持清晰';

  @override
  String get bgDim => '背景暗化';

  @override
  String get bgDimDarkHint => '在背景图片上压一层黑色，图片很亮或很花时调高，界面和文字更清楚';

  @override
  String get bgDimLightHint => '在背景图片上压一层白色，图片很暗或很花时调高，界面和文字更清楚';

  @override
  String get bgPanelBlur => '面板模糊';

  @override
  String get bgPanelBlurHint => '只模糊面板后面的部分（毛玻璃），与背景模糊互不影响；为 0 时面板后面也是清晰的';

  @override
  String get bgOpacity => '面板不透明度';

  @override
  String get bgOpacityHint => '面板越透明，背景图片越明显';

  @override
  String get bgGlow => '封面色散';

  @override
  String get bgGlowHint => '最近游玩的卡片上，从封面取出的颜色向外扩散的强弱';

  @override
  String get bgSolid => '降低透明度';

  @override
  String get bgSolidHint => '保留背景图片，但面板几乎不透明，适合图片很花或者想要更清楚的文字';

  @override
  String get aboutDeveloper => 'Pixel World 的开发者';

  @override
  String get aboutSponsor => '赞助作者';

  @override
  String aboutAppVersion(String version) {
    return 'Pixel World 启动器 $version';
  }

  @override
  String get aboutDisclaimer =>
      'Pixel World 是第三方 Minecraft 启动器，本项目为轻度使用 PCL 仓储库，界面布局参考 PCL 社区版（PCL-CE）。PCL 由龙腾猫跃开发，本软件与 PCL 及其作者无关，也不代表 PCL 官方。请勿就本软件的问题打扰 PCL 作者。';

  @override
  String get aboutSource => '源代码';

  @override
  String get aboutSourceHint => 'Pixel World 以 Apache-2.0 协议开源';

  @override
  String get aboutGuide => 'PCL 存储库合理使用指南';

  @override
  String get aboutGuideHint => '本项目遵循的命名、署名与使用规则，随源代码一同发布';

  @override
  String get aboutCredits => '致谢';

  @override
  String get aboutPclCeHint => 'PCL 社区版（PCL-CE）的开发者们，本软件与 PCL-CE 的数据兼容';

  @override
  String get aboutAndroidRuntime => '安卓版游戏运行时';

  @override
  String get aboutAndroidRuntimeHint =>
      '基于 Amethyst-Android（LGPL-3.0）、MobileGlues、Krypton Wrapper、LWJGL 与 OpenJDK，单独以 LGPL-3.0 开源';

  @override
  String get aboutFlutterHint => '跨平台界面框架';

  @override
  String get aboutMaterialHint => '界面设计语言与配色算法';

  @override
  String get aboutTrademark => 'Minecraft 是 Mojang Studios 的商标。本软件不是官方 Minecraft 产品，未经 Mojang 或 Microsoft 批准，也与其无关。';

  @override
  String renderScale(int percent) {
    return '渲染比例：$percent%';
  }

  @override
  String renderScaleHint(int width, int height) {
    return '游戏分辨率 $width × $height。降低后画面更模糊，但帧率更高、发热更少';
  }

  @override
  String get renderer => '渲染器';

  @override
  String rendererGpu(String gpu) {
    return '显卡：$gpu';
  }

  @override
  String rendererAuto(String renderer, String reason) {
    return '当前会使用：$renderer（$reason）';
  }

  @override
  String get rendererPerInstance => '可以在实例设置里为单个实例另选渲染器';

  @override
  String get isolation => '实例隔离';

  @override
  String get isolationHint => '新实例首次启动时按此规则决定，之后在实例设置中单独修改';

  @override
  String get isolationOff => '关闭';

  @override
  String get isolationModable => '隔离可安装模组的实例';

  @override
  String get isolationUnstable => '隔离非正式版';

  @override
  String get isolationModableUnstable => '隔离可安装模组的实例与非正式版';

  @override
  String get isolationAll => '隔离所有实例';

  @override
  String get gameHud => '游戏内叠加层';

  @override
  String get gameHudHint => '在游戏画面上显示一个可拖动的小球，点开可以看基础信息、问 AI';

  @override
  String get gameHudAi => '游戏内 AI';

  @override
  String get gameHudAiHint => '在小球菜单里显示「问 AI」，使用「设置 → AI 排障」里的接口和模型';

  @override
  String get gameHudAiLog => '提问时附带最近日志';

  @override
  String get gameHudAiLogHint => '把游戏日志末尾一起发给 AI，方便排查崩溃；日志可能包含服务器地址和聊天内容';

  @override
  String get gameWindow => '游戏窗口';

  @override
  String get gameWindowDefault => '默认（854 × 480）';

  @override
  String get gameWindowLauncher => '与启动器一致';

  @override
  String get gameWindowMaximized => '最大化';

  @override
  String get gameWindowFullscreen => '全屏';

  @override
  String get gameWindowCustom => '自定义大小';

  @override
  String get gameWindowWidth => '窗口宽度';

  @override
  String get gameWindowHeight => '窗口高度';

  @override
  String get afterLaunch => '游戏启动后';

  @override
  String get afterLaunchKeep => '保持不变';

  @override
  String get afterLaunchMinimize => '最小化，游戏退出后恢复';

  @override
  String get afterLaunchHide => '隐藏，游戏退出后恢复';

  @override
  String get afterLaunchHideExit => '隐藏，游戏退出后关闭';

  @override
  String get afterLaunchExit => '直接关闭启动器';

  @override
  String get priority => '进程优先级';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityAboveNormal => '较高';

  @override
  String get priorityNormal => '中';

  @override
  String get priorityBelowNormal => '较低';

  @override
  String get versionType => '版本类型显示';

  @override
  String get versionTypeHint => '显示在游戏主界面左下角，留空则不显示';

  @override
  String get autoGameLanguage => '自动设置游戏语言';

  @override
  String get autoGameLanguageHint => '新实例或没有存档时，把游戏语言设为与启动器一致';

  @override
  String get memory => '游戏内存';

  @override
  String get memoryMode => '分配方式';

  @override
  String memorySummary(String allocated, String free, String total) {
    return '将分配 $allocated GB · 系统空闲 $free / $total GB';
  }

  @override
  String get memoryLock => '锁定内存';

  @override
  String get memoryLockHint => '初始内存与最大内存相同（-Xms 等于 -Xmx）';

  @override
  String get advanced => '高级';

  @override
  String get jvmArgs => 'JVM 参数';

  @override
  String get gameArgs => '游戏参数';

  @override
  String get preLaunchCommand => '启动前执行命令';

  @override
  String get preLaunchCommandHint => '在游戏文件夹中执行';

  @override
  String get preLaunchWait => '等待命令执行完毕再启动游戏';

  @override
  String get ipStack => '网络协议偏好';

  @override
  String get ipStackV4 => '优先 IPv4';

  @override
  String get ipStackV6 => '优先 IPv6';

  @override
  String get gpuPreference => '使用高性能显卡';

  @override
  String get gpuPreferenceHint => '仅 Windows：让 Java 使用独立显卡';

  @override
  String get javaUnusable => '无法运行这个 Java';

  @override
  String get javaAuto => '自动选择';

  @override
  String get javaAutoHint => '按版本要求选择，找不到时自动下载 Mojang 提供的 Java';

  @override
  String javaEntry(int major, String version) {
    return 'Java $major（$version）';
  }

  @override
  String get javaManaged => '启动器下载';

  @override
  String get javaManual => '手动指定';

  @override
  String get javaPick => '手动选择';

  @override
  String get javaRescan => '重新检测';

  @override
  String get javaPerInstance => '实例设置里可以为单个实例指定 Java，优先于这里的设置。';

  @override
  String get javaAndroidAutoHint => '按版本要求选择 Java 8 / 17 / 21 / 25，没有安装时自动下载';

  @override
  String javaAndroidTask(int major) {
    return '下载 Java $major（安卓版）';
  }

  @override
  String javaDownloadFailed(int major, String error) {
    return '下载 Java $major 失败：$error';
  }

  @override
  String javaDeleteTitle(int major) {
    return '删除 Java $major？';
  }

  @override
  String get javaDeleteBody => '之后需要时会重新下载。指定使用它的实例要重新选择 Java，或改为自动选择。';

  @override
  String javaInstalled(String size) {
    return '已安装 · $size';
  }

  @override
  String get javaNotInstalled => '未安装';

  @override
  String get javaInUse => '游戏或任务运行时不能删除';

  @override
  String get javaManualAndroid => '手动指定（安卓上不可用）';

  @override
  String get javaAndroidNote =>
      '安卓版 Java 来自 AngelAuraMC 的 OpenJDK 构建（GPLv2 + Classpath Exception）。实例设置里可以为单个实例指定 Java，优先于这里的设置。';

  @override
  String get updates => '更新';

  @override
  String get updateChannel => '更新通道';

  @override
  String get updateChannelHint => '正式版最稳定；预览版包含测试中的版本；Nightly 为 main 分支的每次更新，可能不稳定';

  @override
  String get updateChannelStable => '正式版';

  @override
  String get updateChannelPreview => '预览版';

  @override
  String get updateAutoCheck => '启动时检查更新';

  @override
  String get updateCheck => '检查更新';

  @override
  String get updateCheckButton => '检查';

  @override
  String updateCurrentLocal(String version) {
    return '当前版本 $version（本地构建）';
  }

  @override
  String updateCurrentBuild(String version, String channel, String commit) {
    return '当前版本 $version（$channel，$commit）';
  }

  @override
  String get pclImport => '从 PCL-CE 导入';

  @override
  String get pclImportHint => '导入启动设置、游戏文件夹与账户；实例独立设置两者直接共用';

  @override
  String get pclImportButton => '导入';

  @override
  String get system => '系统';

  @override
  String get shortcut => '创建桌面快捷方式';

  @override
  String get shortcutHint => '在桌面创建启动器的快捷方式';

  @override
  String get shortcutButton => '创建';

  @override
  String get downloadSource => '下载源';

  @override
  String get downloadSourceOfficial => '官方源';

  @override
  String get downloadSourceMirror => 'BMCLAPI 镜像（官方源失败时自动回退）';

  @override
  String get downloadConcurrency => '同时下载的文件数';

  @override
  String get msLogin => '正版登录';

  @override
  String get msClientId => 'Azure 应用 Client ID';

  @override
  String get msClientIdHint => '微软登录需要 Azure 公共客户端应用；留空时使用启动器内置的 Client ID';

  @override
  String get msClientIdEmpty => '未填写';

  @override
  String get msClientIdBuiltIn => '留空时使用内置 Client ID';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get commonAuto => '自動';

  @override
  String get commonCustom => '自訂';

  @override
  String get commonDefault => '預設';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDownload => '下載';

  @override
  String get commonOpen => '開啟';

  @override
  String get commonView => '檢視';

  @override
  String commonDeleteFailed(String error) {
    return '刪除失敗：$error';
  }

  @override
  String get navHome => '啟動';

  @override
  String get navDownload => '下載';

  @override
  String get navTools => '工具';

  @override
  String get navFiles => '檔案';

  @override
  String get navSettings => '設定';

  @override
  String get navAiAssistant => 'AI 助理';

  @override
  String get subVersions => '實例';

  @override
  String get subLog => '遊戲日誌';

  @override
  String get subInstance => '實例詳情';

  @override
  String get subTasks => '任務';

  @override
  String get subDiagnose => '錯誤分析';

  @override
  String get tooltipBack => '返回';

  @override
  String get tooltipInstances => '實例列表';

  @override
  String get tooltipNotices => '公告';

  @override
  String get greetingLateNight => '夜深了';

  @override
  String get greetingMorning => '早安';

  @override
  String get greetingNoon => '午安';

  @override
  String get greetingAfternoon => '午安';

  @override
  String get greetingEvening => '晚上好';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting，$name';
  }

  @override
  String get greetingAdventure => '準備好冒險了嗎？';

  @override
  String get tasksIdle => '目前沒有背景任務';

  @override
  String tasksGamesRunning(int count) {
    return '$count 個遊戲實例執行中';
  }

  @override
  String tasksMore(String title, int count) {
    return '$title · 共 $count 個任務';
  }

  @override
  String get accountAdd => '新增帳戶';

  @override
  String get accountMicrosoft => '正版';

  @override
  String get accountOffline => '離線';

  @override
  String get accountExternal => '外置';

  @override
  String get windowMinimize => '最小化';

  @override
  String get windowMaximize => '最大化';

  @override
  String get windowRestore => '還原';

  @override
  String get windowClose => '關閉';

  @override
  String get comingSoon => '這部分功能正在遷移中';

  @override
  String get settingsGroupGame => '遊戲';

  @override
  String get settingsLaunch => '啟動';

  @override
  String get settingsManage => '遊戲管理';

  @override
  String get settingsGroupLauncher => '啟動器';

  @override
  String get settingsAppearance => '個人化';

  @override
  String get settingsMisc => '其他';

  @override
  String get settingsAiModel => '模型與介面';

  @override
  String get settingsAiTools => '工具與服務';

  @override
  String get settingsAiWorkspace => '工作區與連網';

  @override
  String get settingsGroupAbout => '關於';

  @override
  String get settingsAbout => '關於與致謝';

  @override
  String get settingsDocs => '使用說明';

  @override
  String get settingsAiIntro =>
      'AI 助理使用你自己的 AI 服務。支援 OpenAI 相容介面（DeepSeek、通義千問、Kimi、OpenRouter、本機 Ollama 等）和 Anthropic 介面；費用由你的 AI 服務商收取。';

  @override
  String get languageGroup => '語言';

  @override
  String get language => '介面語言';

  @override
  String get languageHint => '啟動器介面使用的語言；「自動設定遊戲語言」也會跟隨它';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get colorMode => '顏色模式';

  @override
  String get colorModeHint => '啟動器介面的明暗模式';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get uiScale => '介面縮放';

  @override
  String get uiScaleFixed => '整個啟動器依這個比例顯示';

  @override
  String uiScaleAuto(int percent) {
    return '自動：依螢幕尺寸計算，目前為 $percent%';
  }

  @override
  String get themeColor => '主題色';

  @override
  String get themeColorAuto => '跟隨背景：依 Material Design 3 從背景圖片取色，換圖片後自動更新';

  @override
  String get themeColorManual => '依 Material Design 3 從主題色產生整套淺色與深色配色';

  @override
  String get themeFollowBackground => '跟隨背景';

  @override
  String get themeManual => '手動選擇';

  @override
  String get themeRecommended => '推薦';

  @override
  String themeCandidate(int index) {
    return '候選 $index';
  }

  @override
  String get homeGroup => '首頁';

  @override
  String get homeLayout => '首頁版面';

  @override
  String get homeLayoutStandard => '標準';

  @override
  String get homeLayoutSplit => '上下';

  @override
  String get homeLayoutMinimal => '極簡';

  @override
  String get homeLayoutStandardHint => '標準：大卡片、公告與快捷按鈕、最近遊玩';

  @override
  String get homeLayoutSplitHint => '上下：目前實例在頂部，開始遊戲和存檔在底部，中間留給背景；選擇背景圖片時自動切換到這個版面';

  @override
  String get homeLayoutMinimalHint => '極簡：只在底部留一條，放目前實例和開始遊戲';

  @override
  String get homeHints => '顯示使用提示';

  @override
  String get homeHintsHint => '正在使用的版本與免費聲明';

  @override
  String get homeNews => '顯示 Minecraft 版本動態';

  @override
  String get homeNewsHint => '最新的正式版與快照，簡介來自中文 Minecraft Wiki';

  @override
  String get bgImage => '背景圖片';

  @override
  String get bgImageFiles => '圖片';

  @override
  String bgImageInvalid(String error) {
    return '無法使用這張圖片：$error';
  }

  @override
  String get bgImageSet => '顯示在整個視窗後面，介面面板會變成毛玻璃';

  @override
  String get bgImageUnset => '選擇一張圖片作為啟動器的背景（只在電腦上生效）';

  @override
  String get bgImageChange => '換一張…';

  @override
  String get bgImageChoose => '選擇圖片…';

  @override
  String get bgImageRemove => '移除';

  @override
  String get bgFit => '契合度';

  @override
  String get bgFitFill => '填滿';

  @override
  String get bgFitFit => '適應';

  @override
  String get bgFitStretch => '延展';

  @override
  String get bgFitTile => '並排';

  @override
  String get bgFitCenter => '置中';

  @override
  String get bgFitSpan => '跨螢幕';

  @override
  String get bgFitFillHint => '填滿：鋪滿整個視窗，多出來的部分裁掉';

  @override
  String get bgFitFitHint => '適應：完整顯示整張圖片，空出來的地方用圖片的顏色填上';

  @override
  String get bgFitStretchHint => '延展：延展到視窗大小，圖片可能變形';

  @override
  String get bgFitTileHint => '並排：依圖片原來的大小重複鋪滿視窗';

  @override
  String get bgFitCenterHint => '置中：依圖片原來的大小放在視窗中間';

  @override
  String get bgFitSpanHint => '跨螢幕：圖片鋪滿整個桌面（所有螢幕），視窗只顯示自己所在位置的那一塊，移動視窗時背景不動';

  @override
  String get bgBlur => '背景模糊';

  @override
  String get bgBlurHint => '整張背景圖片的模糊程度；為 0 時背景保持清晰';

  @override
  String get bgDim => '背景暗化';

  @override
  String get bgDimDarkHint => '在背景圖片上疊一層黑色，圖片很亮或很花時調高，介面和文字更清楚';

  @override
  String get bgDimLightHint => '在背景圖片上疊一層白色，圖片很暗或很花時調高，介面和文字更清楚';

  @override
  String get bgPanelBlur => '面板模糊';

  @override
  String get bgPanelBlurHint => '只模糊面板後面的部分（毛玻璃），與背景模糊互不影響；為 0 時面板後面也是清晰的';

  @override
  String get bgOpacity => '面板不透明度';

  @override
  String get bgOpacityHint => '面板越透明，背景圖片越明顯';

  @override
  String get bgGlow => '封面色散';

  @override
  String get bgGlowHint => '最近遊玩的卡片上，從封面取出的顏色向外擴散的強弱';

  @override
  String get bgSolid => '降低透明度';

  @override
  String get bgSolidHint => '保留背景圖片，但面板幾乎不透明，適合圖片很花或者想要更清楚的文字';

  @override
  String get aboutDeveloper => 'Pixel World 的開發者';

  @override
  String get aboutSponsor => '贊助作者';

  @override
  String aboutAppVersion(String version) {
    return 'Pixel World 啟動器 $version';
  }

  @override
  String get aboutDisclaimer =>
      'Pixel World 是第三方 Minecraft 啟動器，本專案為輕度使用 PCL 存放庫，介面版面參考 PCL 社群版（PCL-CE）。PCL 由龍騰貓躍開發，本軟體與 PCL 及其作者無關，也不代表 PCL 官方。請勿就本軟體的問題打擾 PCL 作者。';

  @override
  String get aboutSource => '原始碼';

  @override
  String get aboutSourceHint => 'Pixel World 以 Apache-2.0 授權條款開源';

  @override
  String get aboutGuide => 'PCL 存放庫合理使用指南';

  @override
  String get aboutGuideHint => '本專案遵循的命名、署名與使用規則，隨原始碼一同發布';

  @override
  String get aboutCredits => '致謝';

  @override
  String get aboutPclCeHint => 'PCL 社群版（PCL-CE）的開發者們，本軟體與 PCL-CE 的資料相容';

  @override
  String get aboutAndroidRuntime => 'Android 版遊戲執行環境';

  @override
  String get aboutAndroidRuntimeHint =>
      '基於 Amethyst-Android（LGPL-3.0）、MobileGlues、Krypton Wrapper、LWJGL 與 OpenJDK，單獨以 LGPL-3.0 開源';

  @override
  String get aboutFlutterHint => '跨平台介面框架';

  @override
  String get aboutMaterialHint => '介面設計語言與配色演算法';

  @override
  String get aboutTrademark => 'Minecraft 是 Mojang Studios 的商標。本軟體不是官方 Minecraft 產品，未經 Mojang 或 Microsoft 核准，也與其無關。';

  @override
  String renderScale(int percent) {
    return '渲染比例：$percent%';
  }

  @override
  String renderScaleHint(int width, int height) {
    return '遊戲解析度 $width × $height。降低後畫面更模糊，但影格率更高、發熱更少';
  }

  @override
  String get renderer => '渲染器';

  @override
  String rendererGpu(String gpu) {
    return '顯示卡：$gpu';
  }

  @override
  String rendererAuto(String renderer, String reason) {
    return '目前會使用：$renderer（$reason）';
  }

  @override
  String get rendererPerInstance => '可以在實例設定裡為單一實例另選渲染器';

  @override
  String get isolation => '實例隔離';

  @override
  String get isolationHint => '新實例首次啟動時依此規則決定，之後在實例設定中單獨修改';

  @override
  String get isolationOff => '關閉';

  @override
  String get isolationModable => '隔離可安裝模組的實例';

  @override
  String get isolationUnstable => '隔離非正式版';

  @override
  String get isolationModableUnstable => '隔離可安裝模組的實例與非正式版';

  @override
  String get isolationAll => '隔離所有實例';

  @override
  String get gameHud => '遊戲內疊加層';

  @override
  String get gameHudHint => '在遊戲畫面上顯示一個可拖曳的小球，點開可以查看基本資訊、問 AI';

  @override
  String get gameHudAi => '遊戲內 AI';

  @override
  String get gameHudAiHint => '在小球選單裡顯示「問 AI」，使用「設定 → AI 排障」裡的介面和模型';

  @override
  String get gameHudAiLog => '提問時附帶最近日誌';

  @override
  String get gameHudAiLogHint => '把遊戲日誌末尾一起傳給 AI，方便排查當機；日誌可能包含伺服器位址和聊天內容';

  @override
  String get gameWindow => '遊戲視窗';

  @override
  String get gameWindowDefault => '預設（854 × 480）';

  @override
  String get gameWindowLauncher => '與啟動器一致';

  @override
  String get gameWindowMaximized => '最大化';

  @override
  String get gameWindowFullscreen => '全螢幕';

  @override
  String get gameWindowCustom => '自訂大小';

  @override
  String get gameWindowWidth => '視窗寬度';

  @override
  String get gameWindowHeight => '視窗高度';

  @override
  String get afterLaunch => '遊戲啟動後';

  @override
  String get afterLaunchKeep => '保持不變';

  @override
  String get afterLaunchMinimize => '最小化，遊戲結束後還原';

  @override
  String get afterLaunchHide => '隱藏，遊戲結束後還原';

  @override
  String get afterLaunchHideExit => '隱藏，遊戲結束後關閉';

  @override
  String get afterLaunchExit => '直接關閉啟動器';

  @override
  String get priority => '處理程序優先順序';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityAboveNormal => '較高';

  @override
  String get priorityNormal => '中';

  @override
  String get priorityBelowNormal => '較低';

  @override
  String get versionType => '版本類型顯示';

  @override
  String get versionTypeHint => '顯示在遊戲主畫面左下角，留空則不顯示';

  @override
  String get autoGameLanguage => '自動設定遊戲語言';

  @override
  String get autoGameLanguageHint => '新實例或沒有存檔時，把遊戲語言設為與啟動器一致';

  @override
  String get memory => '遊戲記憶體';

  @override
  String get memoryMode => '分配方式';

  @override
  String memorySummary(String allocated, String free, String total) {
    return '將分配 $allocated GB · 系統可用 $free / $total GB';
  }

  @override
  String get memoryLock => '鎖定記憶體';

  @override
  String get memoryLockHint => '初始記憶體與最大記憶體相同（-Xms 等於 -Xmx）';

  @override
  String get advanced => '進階';

  @override
  String get jvmArgs => 'JVM 參數';

  @override
  String get gameArgs => '遊戲參數';

  @override
  String get preLaunchCommand => '啟動前執行命令';

  @override
  String get preLaunchCommandHint => '在遊戲資料夾中執行';

  @override
  String get preLaunchWait => '等待命令執行完畢再啟動遊戲';

  @override
  String get ipStack => '網路協定偏好';

  @override
  String get ipStackV4 => '優先 IPv4';

  @override
  String get ipStackV6 => '優先 IPv6';

  @override
  String get gpuPreference => '使用高效能顯示卡';

  @override
  String get gpuPreferenceHint => '僅 Windows：讓 Java 使用獨立顯示卡';

  @override
  String get javaUnusable => '無法執行這個 Java';

  @override
  String get javaAuto => '自動選擇';

  @override
  String get javaAutoHint => '依版本需求選擇，找不到時自動下載 Mojang 提供的 Java';

  @override
  String javaEntry(int major, String version) {
    return 'Java $major（$version）';
  }

  @override
  String get javaManaged => '啟動器下載';

  @override
  String get javaManual => '手動指定';

  @override
  String get javaPick => '手動選擇';

  @override
  String get javaRescan => '重新偵測';

  @override
  String get javaPerInstance => '實例設定裡可以為單一實例指定 Java，優先於這裡的設定。';

  @override
  String get javaAndroidAutoHint => '依版本需求選擇 Java 8 / 17 / 21 / 25，沒有安裝時自動下載';

  @override
  String javaAndroidTask(int major) {
    return '下載 Java $major（Android 版）';
  }

  @override
  String javaDownloadFailed(int major, String error) {
    return '下載 Java $major 失敗：$error';
  }

  @override
  String javaDeleteTitle(int major) {
    return '刪除 Java $major？';
  }

  @override
  String get javaDeleteBody => '之後需要時會重新下載。指定使用它的實例要重新選擇 Java，或改為自動選擇。';

  @override
  String javaInstalled(String size) {
    return '已安裝 · $size';
  }

  @override
  String get javaNotInstalled => '未安裝';

  @override
  String get javaInUse => '遊戲或任務執行時不能刪除';

  @override
  String get javaManualAndroid => '手動指定（Android 上無法使用）';

  @override
  String get javaAndroidNote =>
      'Android 版 Java 來自 AngelAuraMC 的 OpenJDK 建置（GPLv2 + Classpath Exception）。實例設定裡可以為單一實例指定 Java，優先於這裡的設定。';

  @override
  String get updates => '更新';

  @override
  String get updateChannel => '更新通道';

  @override
  String get updateChannelHint => '正式版最穩定；預覽版包含測試中的版本；Nightly 為 main 分支的每次更新，可能不穩定';

  @override
  String get updateChannelStable => '正式版';

  @override
  String get updateChannelPreview => '預覽版';

  @override
  String get updateAutoCheck => '啟動時檢查更新';

  @override
  String get updateCheck => '檢查更新';

  @override
  String get updateCheckButton => '檢查';

  @override
  String updateCurrentLocal(String version) {
    return '目前版本 $version（本機建置）';
  }

  @override
  String updateCurrentBuild(String version, String channel, String commit) {
    return '目前版本 $version（$channel，$commit）';
  }

  @override
  String get pclImport => '從 PCL-CE 匯入';

  @override
  String get pclImportHint => '匯入啟動設定、遊戲資料夾與帳戶；實例獨立設定兩者直接共用';

  @override
  String get pclImportButton => '匯入';

  @override
  String get system => '系統';

  @override
  String get shortcut => '建立桌面捷徑';

  @override
  String get shortcutHint => '在桌面建立啟動器的捷徑';

  @override
  String get shortcutButton => '建立';

  @override
  String get downloadSource => '下載來源';

  @override
  String get downloadSourceOfficial => '官方來源';

  @override
  String get downloadSourceMirror => 'BMCLAPI 鏡像（官方來源失敗時自動回退）';

  @override
  String get downloadConcurrency => '同時下載的檔案數';

  @override
  String get msLogin => '正版登入';

  @override
  String get msClientId => 'Azure 應用程式 Client ID';

  @override
  String get msClientIdHint => '微軟登入需要 Azure 公用用戶端應用程式；留空時使用啟動器內建的 Client ID';

  @override
  String get msClientIdEmpty => '未填寫';

  @override
  String get msClientIdBuiltIn => '留空時使用內建 Client ID';
}
