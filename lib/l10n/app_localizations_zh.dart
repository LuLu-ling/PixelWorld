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
  String get homeLayoutStandardMobileHint => '标准：原来的首页，不显示背景图片；要用背景图片请选「上下」或「极简」';

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
  String get bgImageUnset => '选择一张图片作为启动器的背景，界面面板会变成毛玻璃';

  @override
  String get bgImageInactive => '「标准」首页不显示背景图片，把首页布局换成「上下」或「极简」后生效';

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
  String get helpGroup => '帮助';

  @override
  String get helpTour => '新手教程';

  @override
  String get helpTourHint => '再看一遍启动器各个地方的介绍：账户、安装游戏、实例、开始游戏、工具和设置';

  @override
  String get helpTourStart => '开始';

  @override
  String get helpTerms => '用户协议';

  @override
  String get helpTermsHint => '使用规则、第三方内容与免责声明';

  @override
  String get helpPrivacy => '隐私说明';

  @override
  String get helpPrivacyHint => '不收集你的信息；保存在本地的内容与会连接的服务';

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
      'Pixel World 是第三方 Minecraft 启动器，本项目为轻度使用 PCL 仓储库，界面布局参考 PCL 社区版（PCL-CE）。PCL 由龙腾猫跃开发，本软件与 PCL 及其作者无关，也不代表 PCL 官方。请勿就本软件的问题打扰 PCL 作者。本软件不是 Mojang 或 Microsoft 的官方产品，未经它们认可，也与它们没有关联；Minecraft 是 Mojang Synergies AB 的商标。';

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
  String get downloadSourceAuto => '自动选择';

  @override
  String get downloadSourceOfficial => '官方源';

  @override
  String get downloadSourceMirror => 'BMCLAPI 镜像';

  @override
  String get downloadSourceAutoHint => '测速选择官方源或 BMCLAPI 镜像中较快的，失败时自动换另一个';

  @override
  String get downloadSourceOfficialHint => '只用 Mojang 和各加载器的官方服务器';

  @override
  String get downloadSourceMirrorHint => '优先用 BMCLAPI 镜像，失败时回退到官方源';

  @override
  String downloadSourceCurrent(String source) {
    return '（当前：$source）';
  }

  @override
  String get networkCheck => '网络检测';

  @override
  String get networkCheckHint => '测试下载源、正版登录、Modrinth 和更新服务能不能连上、有多快';

  @override
  String get networkCheckStart => '开始检测';

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

  @override
  String get oobeWelcome => '欢迎';

  @override
  String get oobeAppearance => '外观';

  @override
  String get oobeGameFolder => '游戏文件夹';

  @override
  String get oobeNetwork => '网络';

  @override
  String get oobeAccount => '账户';

  @override
  String get oobeDone => '完成';

  @override
  String oobeImportedFromPCLCE(Object folders, Object accounts) {
    return '已从 PCL-CE 导入：游戏文件夹 $folders 个，账户 $accounts 个';
  }

  @override
  String oobeCouldntImportFromPCL(Object e) {
    return '从 PCL-CE 导入失败：$e';
  }

  @override
  String get oobeAbout1Minute => '约 1 分钟';

  @override
  String get oobe6StepsAbout1 => '共 6 步，约 1 分钟';

  @override
  String get oobeAcceptAgreementContinue => '勾选同意后才能继续';

  @override
  String get oobeYouCanChangeAll => '之后都可以在「设置」里改';

  @override
  String get commonBack => '上一步';

  @override
  String get commonDeclineQuit => '不同意并退出';

  @override
  String get oobeInstallYourFirstInstance => '去安装第一个实例';

  @override
  String get oobeOpenLauncher => '进入启动器';

  @override
  String get oobeStartSetup => '开始设置';

  @override
  String get commonSkip => '跳过';

  @override
  String get commonNext => '下一步';

  @override
  String get commonWelcomePixelWorld => '欢迎使用 Pixel World';

  @override
  String get oobeFreeOpenSourceMinecraft => '免费、开源的 Minecraft 启动器。花一两分钟完成几项设置，之后都可以在「设置」里改。';

  @override
  String get oobeInstallManage => '安装与管理';

  @override
  String get oobeVanillaEveryModLoader => '原版和各种加载器，一个版本可以装多个实例，模组、存档各管各的。';

  @override
  String get oobeModsResources => '模组与资源';

  @override
  String get oobeFindModsModpacksResource => '在启动器里直接找模组、整合包、资源包和光影。';

  @override
  String get oobeAITroubleshooting => 'AI 排障';

  @override
  String get oobeGameCrashedLetAI => '游戏崩了，让 AI 读日志找原因。';

  @override
  String get commonTermsUsePrivacyNotice => '用户协议与隐私说明';

  @override
  String get oobeBeforeYouContinuePlease => '继续之前，请阅读并同意下面两份文件。';

  @override
  String get oobeSoftwareFreeOpenSource =>
      '· 本软件免费开源，按原样提供；不是 Mojang、Microsoft 或 PCL 的官方产品。\n· 我们不收集你的信息，账户和设置只保存在你的设备上。\n· 游戏、模组等内容来自第三方，下载时直接连接它们。';

  @override
  String get oobeIHaveReadAccept => '我已阅读并同意《用户协议》和《隐私说明》';

  @override
  String get oobePickLookYouLike => '选一个顺眼的样子。手机上的「标准」就是原来的首页；背景图片只在「上下」「极简」里显示。';

  @override
  String get oobePickLookYouLike2 => '选一个顺眼的样子。';

  @override
  String get oobeLightDarkLauncherAppearance => '启动器界面的明暗';

  @override
  String get oobeSelectedPanelsBecomeFrosted => '已选择 · 面板会变成毛玻璃，主题色跟随图片';

  @override
  String get oobeOptionalChooseImageShow => '可选：选一张图片放在启动器后面';

  @override
  String oobeCantUseImage(Object e) {
    return '无法使用这张图片：$e';
  }

  @override
  String get oobeGamesInstancesModsWorlds => '游戏、实例、模组和存档都放在这里。之后可以在「设置 → 游戏管理」里添加更多文件夹。';

  @override
  String get oobeUseDefaultFolder => '使用默认文件夹';

  @override
  String get oobeUseExistingMinecraftFolder => '使用已有的 .minecraft 文件夹';

  @override
  String get oobeInstalledGameAnotherLauncher => '以前用别的启动器装过游戏？直接选那个文件夹，里面的版本和存档都能用。';

  @override
  String get oobeNotChosenYet => '还没有选择';

  @override
  String get oobePCLCEDetected => '检测到 PCL-CE';

  @override
  String oobeImportsPCLCEGame(Object folders, Object hasAccounts) {
    return '导入 PCL-CE 的游戏文件夹（$folders 个）$hasAccounts和启动设置。';
  }

  @override
  String get oobeAccounts => '、账户';

  @override
  String get oobeWhereShouldGameFiles => '游戏文件放在哪里？';

  @override
  String get oobeYouCanChangeLater => '之后可以在「设置 → 游戏管理」里更改。';

  @override
  String get oobePhoneStorage => '手机存储';

  @override
  String get oobeStoredPixelWorldMinecraft => '放在「Pixel World/.minecraft」。卸载或重装启动器后游戏和存档仍然保留，也能用其他应用管理。需要授予「所有文件访问权限」。';

  @override
  String get oobeAppStorage => '应用内部';

  @override
  String get oobeNoPermissionNeededBut => '不需要权限，但卸载启动器时游戏和存档会一起删除。';

  @override
  String get oobeDecidedAfterSpeedTest => '测速后决定';

  @override
  String get oobeSpeedTestBMCLAPIMirror => '测速结果：BMCLAPI 镜像更快';

  @override
  String get oobeSpeedTestOfficialSource => '测速结果：官方源更快';

  @override
  String get oobeUsuallyFasterMainlandChina => '国内一般更快';

  @override
  String get oobeOfficialServersOnly => '只用官方服务器';

  @override
  String get oobeChooseWhereDownloadGame => '选择从哪里下载游戏文件。下面会自动检测各项服务的连接情况。';

  @override
  String get oobeAutomaticUsesFasterOne => '「自动选择」会优先用更快的一边，失败时自动换另一边。';

  @override
  String get oobeMicrosoftAccount => '微软账户';

  @override
  String get oobeSetClientIDSettings => '需要先在「设置 → 其他」填写 Client ID';

  @override
  String get oobeOfficialSignLetsYou => '正版登录，可以进正版服务器';

  @override
  String get commonSignMicrosoft => '微软登录';

  @override
  String get oobeExternalSign => '外置登录';

  @override
  String get oobeLittleSkinOtherSkinSites => 'LittleSkin 等皮肤站';

  @override
  String get oobeOfflineAccount => '离线账户';

  @override
  String get oobeJustPickNamePlay => '起个名字就能玩单机';

  @override
  String get oobeOfflineUsername => '离线用户名';

  @override
  String get oobe316LettersDigits => '3～16 个字母、数字或下划线';

  @override
  String get oobeAdd => '添加';

  @override
  String get oobeAdded => '已添加';

  @override
  String get oobeYouCanAlsoSkip => '不想现在添加也可以直接下一步。';

  @override
  String oobeAutomaticCurrently(Object preferMirror) {
    return '自动选择（当前：$preferMirror）';
  }

  @override
  String get commonAllSet => '准备好了';

  @override
  String get oobeHereYourChoicesClick => '下面是你的选择，点「修改」可以回去改。';

  @override
  String oobeLayout(Object mode, Object homeLayout) {
    return '$mode · $homeLayout布局';
  }

  @override
  String get oobeNoneYet => '还没有添加';

  @override
  String get oobeTakeGuidedTourAfter => '进入后看一遍新手教程';

  @override
  String get oobeAbout30SecondsYou => '大约 30 秒；之后可以在「设置 → 关于与致谢 → 帮助」里再看';

  @override
  String get oobeFirstTimeSetup => '首次设置';

  @override
  String get oobeDontWantSetThings => '不想现在设置？';

  @override
  String get oobeUseAllDefaults => '全部用默认';

  @override
  String get oobeYouStillNeedAccept => '（仍需同意协议）';

  @override
  String get oobeChange => '修改';

  @override
  String get oobeChoose => '选择…';

  @override
  String get oobeLargeCardAnnouncementsShortcuts => '大卡片、公告与快捷按钮、最近游玩';

  @override
  String get oobeInstanceAtTopPlay => '实例在顶部，开始游戏在底部，中间留给背景';

  @override
  String get oobeSingleBarAtBottom => '只在底部留一条';

  @override
  String get tourTakeMinuteGetKnow => '花一分钟认识一下启动器的几个主要地方。随时可以点「跳过」，之后在「设置 → 关于与致谢」里能再看一遍。';

  @override
  String get tourAddAccountFirst => '先添加账户';

  @override
  String get tourClickHereAddMicrosoft => '点这里添加微软正版账户；登录过一次正版后，也可以添加外置登录（例如 LittleSkin）和离线账户。';

  @override
  String get tourInstallGame => '安装游戏';

  @override
  String get tourUnderDownloadChooseGame =>
      '在「下载」里选游戏版本和加载器（Forge、Fabric 等）来安装。装好的一份叫「实例」，同一个版本可以装好几个，存档和模组互不影响。模组、整合包、资源包和光影也在这里找。';

  @override
  String get tourSwitchInstance => '切换实例';

  @override
  String get tourHomePageShowsCurrent => '首页显示当前实例。点「切换实例」可以在装好的实例之间切换，或者管理全部实例。';

  @override
  String get tourPlay => '开始游戏';

  @override
  String get tourPickInstanceClickHere => '选好实例后点这里启动。第一次启动会自动准备好需要的 Java。';

  @override
  String get tourInstanceSettings => '实例设置';

  @override
  String get tourEachInstancesModsWorlds => '每个实例的模组、存档、资源包、光影、内存和 Java 都在这里单独管理，也可以直接给这个实例添加模组。';

  @override
  String get tourBackgroundTasks => '后台任务';

  @override
  String get tourDownloadsInstallsRunBackground => '下载和安装都在后台进行，进度显示在这里，点开可以查看详情或者取消。';

  @override
  String get tourMultiplayerLobbyLANTransfer => '联机大厅、局域网互传、服务器查询、错误分析，还有皮肤、成就图片这些小工具。';

  @override
  String get tourFileManagerYourPhone => '手机上的文件管理器：直接管理游戏文件夹里的存档、模组和截图。';

  @override
  String get tourAskAIWhenSomething => '有问题可以问 AI，例如游戏为什么崩溃、该装哪个模组。先在设置里配置好模型就能用。';

  @override
  String get tourThemeBackgroundImageHome => '主题、背景图片和首页布局在「个性化」里；Java、内存和游戏文件夹也在这里调整。';

  @override
  String get tourHeadDownloadInstallInstance => '先去「下载」装一个实例吧！这个教程可以在「设置 → 关于与致谢」里再次打开。';

  @override
  String get tourGetStarted => '开始使用';

  @override
  String get agreementDialogTermsUsePrivacyNotice => '用户协议与隐私说明已更新';

  @override
  String get agreementDialogPleaseReadTermsUse =>
      '使用前请阅读下面的用户协议和隐私说明。简单来说：本软件免费开源，按原样提供；我们不收集你的信息，账户和设置都只保存在你的设备上；游戏和模组来自第三方。';

  @override
  String get agreementDialogAcceptContinue => '同意并继续';

  @override
  String get networkCheckPanelChecking => '检测中…';

  @override
  String get networkCheckPanelCheckingUp8Seconds => '正在检测，最多 8 秒';

  @override
  String get networkCheckPanelNeitherDownloadSourceCan => '两个下载源都连不上，请检查网络或代理设置';

  @override
  String networkCheckPanelAutomaticWillPreferSwitch(Object mirror) {
    return '「自动选择」会优先使用$mirror，失败时自动换另一个';
  }

  @override
  String get networkCheckPanelBMCLAPIMirror => ' BMCLAPI 镜像';

  @override
  String networkCheckPanelOtherConnectionsFailedRelated(num failed) {
    return '有 $failed 项连接失败，相关功能可能用不了';
  }

  @override
  String get networkCheckPanelCheckAgain => '重新检测';

  @override
  String get networkCheckPanelLauncherUpdates => '启动器更新';

  @override
  String get networkCheckPanelCheckingUp8Seconds2 => '检测中，最多 8 秒';

  @override
  String get networkCheckPanelAllGood => '全部正常';

  @override
  String get networkCheckPanelConnectionFailed => '连接失败';

  @override
  String get storageLocationPhoneStoragePixelWorld =>
      '放在手机存储（Pixel World/.minecraft）：卸载或重装启动器后游戏、存档仍然保留，也可以用其他应用管理这些文件。需要授予「所有文件访问权限」。\n\n放在应用内部：不需要权限，但卸载启动器时游戏、存档会一起被删除。\n\n之后可以在「设置 → 游戏管理」中更改。';

  @override
  String get storageLocationPhoneStorageRecommended => '手机存储（推荐）';

  @override
  String get storageLocationAllFilesAccessWasnt => '没有获得「所有文件访问权限」，游戏文件夹没有更改';

  @override
  String get storageLocationMoveGameFiles => '移动游戏文件';

  @override
  String storageLocationMoveInstancesWorldsResources(Object from, Object to) {
    return '把现在游戏文件夹中的实例、存档与资源移到新位置吗？\n\n$from\n→ $to';
  }

  @override
  String get storageLocationJustSwitchDontMove => '只切换，不移动';

  @override
  String get storageLocationMove => '移动';

  @override
  String storageLocationGameFolderChanged(Object to) {
    return '游戏文件夹已更改为 $to';
  }

  @override
  String get storageLocationMovingGameFiles => '正在移动游戏文件';

  @override
  String get storageLocationMoveFailed => '移动失败';

  @override
  String storageLocationFilesWereAlreadyMoved(Object error) {
    return '$error\n\n已经移动的文件在新位置，其余文件仍在原位置。';
  }

  @override
  String get storageLocationCountingFiles => '正在统计文件…';

  @override
  String storageLocationFilesPleaseDontClose(Object done, Object total) {
    return '$done / $total 个文件，请不要关闭启动器';
  }

  @override
  String get storageLocationCurrentGameFolder => '当前游戏文件夹';

  @override
  String get storageLocationChange => '更改';

  @override
  String get storageLocationStorageLocation => '存放位置';

  @override
  String get storageLocationPhoneStorageKeptWhen => '手机存储：卸载启动器后仍然保留';

  @override
  String get storageLocationAppStorageDeletedWhen => '应用内部：卸载启动器时会一起删除，建议移到手机存储';

  @override
  String get storageLocationMaintenance => '维护';

  @override
  String get commonCleanUpGameJunk => '清理游戏垃圾';

  @override
  String get storageLocationDeletesLogsCrashReports => '删除日志、崩溃报告与解压出的本地库，不影响存档和模组';

  @override
  String get commonCleanUp => '清理';

  @override
  String get storageLocationFileManager => '文件管理';

  @override
  String get storageLocationBrowseImportCopyDelete => '浏览、导入、复制或删除游戏文件；删除的文件会先放进回收站';

  @override
  String get launchDialogsJavaVersionMayIncompatible => 'Java 版本可能不兼容';

  @override
  String launchDialogsYouCanChangeJava(Object message) {
    return '$message\n\n可以在实例设置中把 Java 改为 Java 8 或自动选择。';
  }

  @override
  String get launchDialogsLaunchAnyway => '仍然启动';

  @override
  String launchDialogsOtherTimes(num launchCount) {
    return '已经启动 $launchCount 次游戏啦';
  }

  @override
  String launchDialogsMaintainedIfYouFind(Object name, Object authorName) {
    return '$name 由 $authorName 维护。如果觉得好用，能否考虑赞助一下作者？\n\n本项目免费、没有广告，离不开大家的支持。';
  }

  @override
  String get launchDialogsMaybeLater => '下次再说';

  @override
  String launchDialogsSignAgain(Object serverName) {
    return '重新登录 $serverName';
  }

  @override
  String launchDialogsSignHasExpiredEnter(Object name, Object login) {
    return '$name（$login）的登录已失效，请输入密码继续启动。';
  }

  @override
  String get commonPassword => '密码';

  @override
  String get launchDialogsCancelLaunch => '取消启动';

  @override
  String get commonSign => '登录';

  @override
  String updateDialogYoureLatestVersion(Object label) {
    return '已是最新版本（$label）';
  }

  @override
  String updateDialogCouldntCheckUpdates(Object error) {
    return '检查更新失败：$error';
  }

  @override
  String updateDialogNewVersionAvailable(Object label) {
    return '发现新版本：$label';
  }

  @override
  String updateDialogCurrentVersion(Object current, Object prerelease, Object date) {
    return '当前版本 $current · $prerelease$date';
  }

  @override
  String updateDialogReleased(Object date) {
    return ' · 发布于 $date';
  }

  @override
  String get updateDialogNoReleaseNotes => '没有更新说明';

  @override
  String get updateDialogNoPackageHasBeen => '这个平台还没有发布包，请到 GitHub 查看。';

  @override
  String get updateDialogReleaseHasNoFile => '这个发布中没有适用于当前平台的文件。';

  @override
  String get updateDialogAfterDownloadingInstallerImage => '下载后会打开安装镜像，把 Pixel World 拖进「应用程序」文件夹替换旧版本即可；游戏文件不受影响。';

  @override
  String get updateDialogAfterDownloadingSystemInstalls => '下载后由系统安装，需要在弹出的界面中确认；游戏文件不受影响。';

  @override
  String get updateDialogDownloading => '正在下载';

  @override
  String updateDialogDownloading2(Object progress) {
    return '正在下载 $progress%';
  }

  @override
  String get updateDialogInstallerHasBeenDownloaded => '安装包已经下载完成。第一次安装需要在系统设置中允许「安装未知应用」；允许后回到这里点「继续安装」，不需要重新下载。';

  @override
  String get updateDialogSkipVersion => '跳过这个版本';

  @override
  String get updateDialogViewGitHub => '在 GitHub 查看';

  @override
  String get updateDialogLater => '稍后';

  @override
  String get updateDialogContinueInstall => '继续安装';

  @override
  String get updateDialogUpdateRestart => '更新并重启';

  @override
  String get updateDialogDownloadInstall => '下载并安装';

  @override
  String get pclImportDialogImportComplete => '导入完成';

  @override
  String pclImportDialogSettings(Object settings) {
    return '设置：$settings';
  }

  @override
  String pclImportDialogAddedGameFoldersAccounts(Object folders, Object accounts) {
    return '新增游戏文件夹 $folders 个，账户 $accounts 个';
  }

  @override
  String pclImportDialogNotImported(Object skippedAccounts) {
    return '未导入：$skippedAccounts';
  }

  @override
  String pclImportDialogFoundPCLCEConfiguration(Object folders, Object hasAccounts) {
    return '检测到 PCL-CE 的配置：$folders 个游戏文件夹$hasAccounts';
  }

  @override
  String get pclImportDialogAccounts => '，有账户';

  @override
  String get pclImportDialogNoPCLCEConfiguration => '没有在 %APPDATA%\\PCLCE 找到 PCL-CE 的配置，可以选择 PCL-CE 所在目录导入本地设置';

  @override
  String get pclImportDialogPerInstanceSettingsDont => '实例独立设置无需导入，两者直接共用。';

  @override
  String get pclImportDialogLaunchSettings => '启动设置';

  @override
  String get pclImportDialogMemoryJVMArgumentsMore => '内存、JVM 参数等需要选择 PCL-CE 所在目录';

  @override
  String get pclImportDialogImportedMicrosoftAccountsNeed => '导入的微软账户过期后需要在这里重新登录';

  @override
  String get pclImportDialogPCLCEFolderNot => 'PCL-CE 所在目录：未选择（可选）';

  @override
  String pclImportDialogPCLCEFolder(Object pclDir) {
    return 'PCL-CE 所在目录：$pclDir';
  }

  @override
  String get commonChoose => '选择';

  @override
  String get yggdrasilLoginDialogAuthenticationServerAddress => '验证服务器地址';

  @override
  String get yggdrasilLoginDialogEnterAddressPickOne => '输入地址，或从列表中选择';

  @override
  String get yggdrasilLoginDialogChooseProfile => '选择角色';

  @override
  String yggdrasilLoginDialogAuthenticationServer(Object server) {
    return '验证服务器：$server';
  }

  @override
  String get yggdrasilLoginDialogAddressIsntEncryptedYour => '这个地址没有加密，密码会以明文传输';

  @override
  String get yggdrasilLoginDialogEmailUsername => '邮箱或用户名';

  @override
  String get yggdrasilLoginDialogPasswordSign => '账户密码登录';

  @override
  String get yggdrasilLoginDialogOAuthAuthorization => 'OAuth 授权';

  @override
  String get yggdrasilLoginDialogAccountPassword => '账户密码';

  @override
  String yggdrasilLoginDialogClickingStartOpensAuthorization(Object site) {
    return '点击开始后会在浏览器中打开 $site 的授权页面，确认授权并选择角色即可，启动器不会接触你的密码。';
  }

  @override
  String get yggdrasilLoginDialogStartOAuthSign => '开始 OAuth 登录';

  @override
  String get accountsDialogNoAccountsYet => '还没有账户';

  @override
  String get accountsDialogAddOfflineAccount => '添加离线账户';

  @override
  String get accountsDialogUsername => '用户名';

  @override
  String get accountsDialogMicrosoftAccounts => '正版账户';

  @override
  String get accountsDialogMicrosoftSignNeedsAzure => '微软登录需要先在「设置 - 其他」中填写 Azure 应用 Client ID。';

  @override
  String get accountsDialogThirdPartyAccounts => '第三方账户';

  @override
  String get maintenanceActionsNothingCleanUp => '没有需要清理的文件';

  @override
  String maintenanceActionsItemsWillDeletedLogs(Object count, Object size) {
    return '将删除 $count 项，共 $size：\n游戏文件夹与各实例文件夹中的日志（logs、*.log）、崩溃报告（crash-reports、hs_err_pid*）与解压出的本地库（natives，启动时会重新生成）。\n\n存档、模组与设置不会被删除。';
  }

  @override
  String maintenanceActionsCleanedUp(Object size) {
    return '已清理 $size';
  }

  @override
  String maintenanceActionsOtherItemsUseWerent(num failed) {
    return '已清理，$failed 项正在被使用，没有删除';
  }

  @override
  String maintenanceActionsCreated(Object path) {
    return '已创建 $path';
  }

  @override
  String get fileViewerFileDoesntExist => '文件不存在';

  @override
  String get fileViewerPreview => '预览';

  @override
  String get fileViewerSource => '源码';

  @override
  String get fileViewerRefresh => '刷新';

  @override
  String get fileViewerCopyAll => '复制全文';

  @override
  String get fileViewerCopied => '已复制';

  @override
  String get fileViewerShowFileManager => '在文件管理器中打开';

  @override
  String fileViewerCantOpen(Object error) {
    return '打不开：$error';
  }

  @override
  String get fileViewerFileIsntTextLarger => '这个文件不是文本，或者超过 2 MB，不能在这里查看';

  @override
  String get deviceStatusMobileData => '移动数据';

  @override
  String get deviceStatusEthernet => '有线网络';

  @override
  String get deviceStatusConnected => '已联网';

  @override
  String get deviceStatusOffline => '未联网';

  @override
  String get deviceStatusFullyCharged => '已充满';

  @override
  String get deviceStatusCharging => '正在充电';

  @override
  String get deviceStatusPlugged => '已接通电源';

  @override
  String get deviceStatusBattery => '电量';

  @override
  String deviceLoginDialogSignedAs(Object name) {
    return '已登录 $name';
  }

  @override
  String get deviceLoginDialogStartSign => '开始登录';

  @override
  String get deviceLoginDialogRetry => '重试';

  @override
  String get deviceLoginDialogAuthorizationPageHasOpened => '已在浏览器中打开授权页面，请确认页面上的代码与下面一致后完成授权：';

  @override
  String get deviceLoginDialogSignPageHasOpened => '已在浏览器中打开登录页面，请输入下面的代码（已复制到剪贴板）：';

  @override
  String get deviceLoginDialogResumed => '接着完成上次的登录：在浏览器里用下面的代码完成授权后回到启动器，会自动登录。授权页面关掉了可以点下面的链接重新打开：';

  @override
  String get deviceLoginDialogWaitingSign => '等待登录完成';

  @override
  String formatOtherYearsAgo(num inDays) {
    return '$inDays 年前';
  }

  @override
  String formatOtherMonthsAgo(num inDays) {
    return '$inDays 个月前';
  }

  @override
  String formatOtherDaysAgo(num inDays) {
    return '$inDays 天前';
  }

  @override
  String formatOtherHoursAgo(num inHours) {
    return '$inHours 小时前';
  }

  @override
  String get formatJustNow => '刚刚';

  @override
  String get themeColorDialogCustomThemeColor => '自定义主题色';

  @override
  String get themeColorDialogR => '红';

  @override
  String get themeColorDialogG => '绿';

  @override
  String get themeColorDialogB => '蓝';

  @override
  String get themeColorDialogUse => '使用';

  @override
  String homeCouldntLaunch(Object error) {
    return '启动失败：$error';
  }

  @override
  String homeCantOpenFolder(Object error) {
    return '打不开文件夹：$error';
  }

  @override
  String get homeRecentlyPlayed => '最近游玩';

  @override
  String get homeAllWorlds => '全部存档 ›';

  @override
  String homeOtherMinutesAgo(num inMinutes) {
    return '$inMinutes 分钟前';
  }

  @override
  String homeMonthDay(Object month, Object day) {
    return '$month月$day日';
  }

  @override
  String get homeNoInstanceSelected => '还没有选择实例';

  @override
  String get homeInstallChooseInstanceFirst => '先安装或选择一个实例，准备好就开始';

  @override
  String get homeMore => '更多';

  @override
  String get homeOpenInstanceFolder => '打开实例文件夹';

  @override
  String commonModCount(num data) {
    return '$data 个模组';
  }

  @override
  String homeRenderer(Object renderer) {
    return '$renderer 渲染';
  }

  @override
  String homePlayed(Object modified) {
    return '$modified玩过';
  }

  @override
  String get homeBackGame => '返回游戏';

  @override
  String get commonStopGame => '结束游戏';

  @override
  String get homeAddMods => '装模组';

  @override
  String get homeManageMods => '管理模组';

  @override
  String get homeFolder => '文件夹';

  @override
  String get commonViewLog => '查看日志';

  @override
  String get homeLauncherAnnouncements => '启动器公告';

  @override
  String get homeLoading => '正在获取…';

  @override
  String get commonNoAnnouncements => '暂无公告';

  @override
  String get homeView => '查看 ›';

  @override
  String get homeSwitchInstanceWorld => '切换到这个存档所在的实例';

  @override
  String get homeYourRecentWorldsWill => '开始一次游戏后，最近的存档会出现在这里。';

  @override
  String get homeScrollDownMore => '向下滚动查看更多';

  @override
  String get homeSwipeUpMore => '上滑查看更多';

  @override
  String get homeInstallChooseInstanceFirst2 => '先安装或选择一个实例';

  @override
  String get homeNoRecentlyPlayedWorlds => '还没有最近游玩的存档';

  @override
  String get homeAllWorlds2 => '全部存档';

  @override
  String get homeOpenFolder => '打开文件夹';

  @override
  String get homeCurrentInstance => '当前实例';

  @override
  String get homeInstanceSettings => '实例设置 ›';

  @override
  String get homeType => '类型';

  @override
  String get homeMods => '模组';

  @override
  String get homeVanillaNoMods => '原版，不加载模组';

  @override
  String homeModCountValue(Object data) {
    return '$data 个';
  }

  @override
  String get homeNotPlayedYet => '还没玩过';

  @override
  String get homeInstanceID => '实例 ID';

  @override
  String get homeManageAllInstances => '管理全部实例';

  @override
  String homeFeedYoureUsingBetaThird(Object name, Object version) {
    return '你正在使用 $name $version 测试版。这是第三方 Minecraft 启动器，功能还在完善中，遇到问题请到 GitHub 反馈。';
  }

  @override
  String get homeFeedReportProblem => '反馈问题';

  @override
  String get homeFeedSoftwareCompletelyFreeOpen => '本软件完全免费、开源。如果你是付费购买或下载的，那么你可能被骗了，请向卖家申请退款，并从 GitHub 获取正版。';

  @override
  String get homeFeedGetGenuineVersion => '获取正版';

  @override
  String homeFeedBetaThatsStillBeing(Object name, Object version) {
    return '$name $version 测试版，功能还在完善中，遇到问题请到 GitHub 反馈。';
  }

  @override
  String get homeFeedSoftwareCompletelyFreeOpen2 => '本软件完全免费、开源。如果你是付费获得的，请向卖家申请退款，并从 GitHub 获取正版。';

  @override
  String get homeFeedHideBetaNoticeFree => '关闭测试版提示（免费声明会保留）';

  @override
  String homeFeedChangelogV(Object version, Object channel) {
    return '更新日志 · v$version$channel';
  }

  @override
  String get homeFeedCollapse => '收起';

  @override
  String get homeFeedExpand => '展开';

  @override
  String get homeFeedLoadingAnnouncements => '正在获取公告…';

  @override
  String get homeFeedViewDetails => '查看详情';

  @override
  String get homeFeedMinecraftVersionNews => 'Minecraft 版本动态';

  @override
  String get homeFeedFromMinecraftWiki => '来自 Minecraft Wiki';

  @override
  String homeFeedCouldntLoad(Object error) {
    return '加载失败：$error';
  }

  @override
  String get homeFeedSnapshot => '快照';

  @override
  String get homeFeedMinecraftWikiDoesntHave => 'Minecraft Wiki 还没有这个版本的介绍，点击查看页面。';

  @override
  String get versionsCurrentFolder => '当前文件夹';

  @override
  String get versionsOfficialLauncherFolder => '官方启动器文件夹';

  @override
  String get versionsLauncherDefaultFolder => '启动器默认文件夹';

  @override
  String get versionsRemoveFromListFiles => '从列表移除（不会删除文件）';

  @override
  String get versionsAddFolder => '添加文件夹';

  @override
  String get versionsNoInstancesFolderYet => '这个文件夹中还没有实例';

  @override
  String versionsOtherInstances(num count) {
    return '$count 个实例';
  }

  @override
  String get versionsNewInstance => '新建实例';

  @override
  String get versionsSearchInstances => '搜索实例';

  @override
  String get versionsNoMatchingInstances => '没有匹配的实例';

  @override
  String tasksProgress(Object count) {
    return '$count 个进行中';
  }

  @override
  String get tasksClearFinishedTasks => '清除已结束的任务';

  @override
  String get tasksNoTasksYetInstalling => '还没有任务。安装实例、下载资源或启动游戏时会显示在这里';

  @override
  String tasksMinS(Object inMinutes, Object inSeconds) {
    return '$inMinutes 分 $inSeconds 秒';
  }

  @override
  String tasksS(Object inSeconds) {
    return '$inSeconds 秒';
  }

  @override
  String get tasksCanceling => '正在中断';

  @override
  String get tasksProgress2 => '进行中';

  @override
  String get tasksCompleted => '已完成';

  @override
  String get tasksFailed => '失败';

  @override
  String get tasksCanceled => '已中断';

  @override
  String get tasksCanceling2 => '中断中…';

  @override
  String get tasksCancel => '中断';

  @override
  String get tasksCopyLog => '复制日志';

  @override
  String get commonLogCopied => '已复制日志';

  @override
  String get logGameRunning => '游戏运行中';

  @override
  String get logStarting => '正在启动';

  @override
  String get logGameNotRunning => '游戏未运行';

  @override
  String logGameExitedCode(Object lastExitCode) {
    return '游戏已退出，代码 $lastExitCode';
  }

  @override
  String get logAutoScroll => '自动滚动';

  @override
  String get logCopyAll => '复制全部';

  @override
  String get logLogWillAppearHere => '启动游戏后，日志会显示在这里';

  @override
  String get diagnoseGameCrashed => '游戏崩溃了';

  @override
  String diagnoseExitedAbnormally(Object title) {
    return '$title 非正常退出。';
  }

  @override
  String get diagnoseNoKnownProblemMatched => '没有匹配到已知的问题，可以查看日志，或使用 AI 分析。';

  @override
  String get diagnoseAIAnalysis => 'AI 分析';

  @override
  String get diagnoseNothingAnalyze => '没有要分析的内容';

  @override
  String get diagnoseEnvironment => '环境';

  @override
  String get diagnoseInitialFindings => '初步判断';

  @override
  String get diagnoseNoKnownProblemMatched2 => '没有匹配到已知的问题';

  @override
  String get diagnoseUseAIAnalysisBelow => '可以使用下面的 AI 分析，或查看日志摘录自行判断';

  @override
  String get diagnoseExistingAIConversation => '已有 AI 对话';

  @override
  String get diagnoseAnalyzeAI => '用 AI 分析';

  @override
  String get diagnoseContinueCrashsConversationAI => '在 AI 页面继续这次崩溃的对话';

  @override
  String diagnoseStartsNewConversationSends(Object host, Object model) {
    return '新建一个对话，把下面的日志摘录与环境信息发送给 $host（$model）';
  }

  @override
  String get diagnoseAnalyzeLogYourOwn => '使用你自己的 AI 服务分析日志，需要先填写接口地址、模型和 API Key';

  @override
  String get diagnoseViewConversation => '查看对话';

  @override
  String get diagnoseLogExcerpt => '日志摘录';

  @override
  String get diagnoseNoLogsFound => '没有找到日志';

  @override
  String diagnoseCharactersTrimmedPrivateInformation(Object count) {
    return '$count 个字符，已截取并去除隐私信息';
  }

  @override
  String get diagnoseModList => '模组列表';

  @override
  String diagnoseOtherEnabledMods(num count) {
    return '$count 个已启用的模组';
  }

  @override
  String get docsFromPixelworldZhuzhiSite => '来自 pixelworld.paperzhu.com · 断网时显示最近一次缓存';

  @override
  String get docsOpenBrowser => '在浏览器打开';

  @override
  String get instanceInstanceNoLongerExists => '这个实例已不存在';

  @override
  String get instanceWorlds => '存档';

  @override
  String get commonResourcePacks => '资源包';

  @override
  String get commonShaders => '光影';

  @override
  String get instanceScreenshots => '截图';

  @override
  String get instanceSchematics => '投影';

  @override
  String get instanceServers => '服务器';

  @override
  String get instanceOverview => '概览';

  @override
  String get instanceChangeIcon => '更换图标';

  @override
  String instanceCouldntChangeIcon(Object error) {
    return '更换图标失败：$error';
  }

  @override
  String get instanceChangeIcon2 => '更换图标…';

  @override
  String get instanceRestoreDefaultIcon => '恢复默认图标';

  @override
  String instanceBackList(Object label) {
    return '返回$label列表';
  }

  @override
  String instanceDelete(Object id) {
    return '删除 $id？';
  }

  @override
  String get instanceInstanceFolderWillMoved => '实例文件夹会移到回收站。开启实例隔离时，其中的存档和模组也会一并删除。';

  @override
  String instanceDeleted(Object id) {
    return '已删除 $id';
  }

  @override
  String get instanceSetAsCurrentInstance => '设为当前实例';

  @override
  String get commonGameVersion => '游戏版本';

  @override
  String get instanceDecidedAtFirstLaunch => '首次启动时决定';

  @override
  String get instanceText => '已开启';

  @override
  String get instanceOff => '已关闭';

  @override
  String get instanceWorkingDirectory => '运行目录';

  @override
  String get instanceReleaseDate => '发布时间';

  @override
  String get instanceShortcuts => '快捷方式';

  @override
  String get instanceInstanceFolder => '实例文件夹';

  @override
  String instanceFolder(Object label) {
    return '$label文件夹';
  }

  @override
  String get instanceManage => '管理';

  @override
  String get instanceSendInstance => '发送这个实例';

  @override
  String get instanceSendWholeInstanceAnother => '通过局域网把整个实例传到另一台设备';

  @override
  String get instanceSend => '发送';

  @override
  String get instanceDeleteInstance => '删除这个实例';

  @override
  String get instanceMovesRecycleBinIf => '移到回收站；开启实例隔离时，其中的存档和模组也会一并删除';

  @override
  String get instanceUseGlobalSetting => '跟随全局设置';

  @override
  String instanceNotInstalled(Object javaKey) {
    return '$javaKey（未安装）';
  }

  @override
  String get instanceChooseManually => '手动选择…';

  @override
  String get instanceTheseSettingsStoredPCL => '这些设置保存在实例文件夹的 PCL/config.v1.yml 中，与 PCL-CE 互通';

  @override
  String instanceNotDecidedYetSet(Object isolationMode) {
    return '尚未决定：首次启动时按全局策略「$isolationMode」决定，之后固定';
  }

  @override
  String get instanceWorkingDirectoryInstanceFolder => '运行目录为实例文件夹';

  @override
  String get instanceText2 => '开启';

  @override
  String instanceGlobal(Object javaPath) {
    return '跟随全局：$javaPath';
  }

  @override
  String instanceGlobalSetting(Object androidRenderer) {
    return '跟随全局设置「$androidRenderer」';
  }

  @override
  String instanceGlobalCustomGB(Object memoryTick) {
    return '跟随全局：自定义 $memoryTick GB';
  }

  @override
  String get instanceGlobalAutomatic => '跟随全局：自动分配';

  @override
  String get instanceGlobal2 => '跟随全局';

  @override
  String get instanceMaximumMemory => '最大内存';

  @override
  String get instanceInitialMemory => '初始内存';

  @override
  String get instanceNotSet => '不设置';

  @override
  String get instanceJoinServerAutomatically => '自动进入服务器';

  @override
  String get instanceLeaveEmptyUseGlobal => '留空则使用全局设置';

  @override
  String instanceMovedRecycleBin(Object name) {
    return '已将 $name 移到回收站';
  }

  @override
  String instanceTotalEnabled(Object count, Object enabledMods) {
    return '$count 个，已启用 $enabledMods 个';
  }

  @override
  String instanceItemCount(Object count) {
    return '$count 个';
  }

  @override
  String get instanceFilter => '筛选';

  @override
  String get instanceSendWorld => '发送存档';

  @override
  String instanceAdd(Object label) {
    return '添加$label';
  }

  @override
  String get instanceAddOptiFine => '添加 OptiFine';

  @override
  String instanceNoHereYet(Object label) {
    return '这里还没有$label';
  }

  @override
  String get instanceDisabled => ' · 已禁用';

  @override
  String get instanceMoveRecycleBin => '移到回收站';

  @override
  String get instanceServersSavedGameMultiplayer => '游戏内多人游戏列表中保存的服务器（servers.dat）';

  @override
  String get instanceNoSavedServersYet => '还没有保存的服务器';

  @override
  String get instanceCantConnect => '无法连接';

  @override
  String instanceOnlineMs(Object online, Object max, Object latency) {
    return '在线 $online/$max · $latency ms';
  }

  @override
  String instanceCouldntGetOptiFineVersions(Object error) {
    return '获取 OptiFine 版本失败：$error';
  }

  @override
  String instanceNoOptiFineCompatibleForge(Object gameVersion) {
    return '没有与 Forge 兼容的 OptiFine（$gameVersion）';
  }

  @override
  String instanceNoOptiFineAvailable(Object gameVersion) {
    return '$gameVersion 没有可用的 OptiFine';
  }

  @override
  String get commonOptiFineVersion => 'OptiFine 版本';

  @override
  String get commonPreview => '（预览版）';

  @override
  String commonRequiresForge(Object requiredForge) {
    return ' · 需要 Forge $requiredForge';
  }

  @override
  String get downloadModpacks => '整合包';

  @override
  String get downloadDataPacks => '数据包';

  @override
  String get commonFavorites => '收藏';

  @override
  String get downloadOldVersions => '远古版';

  @override
  String get downloadAprilFools => '愚人节';

  @override
  String downloadCouldntGetVersionList(Object error) {
    return '获取版本列表失败：$error';
  }

  @override
  String get downloadLoadingVersionList => '正在获取版本列表…';

  @override
  String get downloadSearchVersions => '搜索版本号';

  @override
  String get downloadNoMatchingVersions => '没有符合条件的版本';

  @override
  String get downloadLatest => '最新';

  @override
  String get downloadInstalled => '已安装';

  @override
  String get downloadChooseVersionLeft => '选择左边的版本';

  @override
  String get downloadPlainMinecraft => '纯净的 Minecraft';

  @override
  String get downloadOldestLoaderMostMods => '历史最久、模组最多的加载器';

  @override
  String get downloadCommunityForkForgeAvailable => '从 Forge 分出的社区版，1.20.1 起可用';

  @override
  String get downloadModernized1122 => '基于 Forge 的 1.12.2 现代化分支，需要 Java 21';

  @override
  String get downloadAllOneClientLots => '自带大量功能的整合客户端（LabyMod 4）';

  @override
  String get downloadLightweightFastUpdatingMod => '轻量、更新快的模组加载器';

  @override
  String get downloadCompatibleMostFabricMods => '兼容大部分 Fabric 模组';

  @override
  String get downloadFabricPorted113 => '为 1.13.2 及更早版本移植的 Fabric';

  @override
  String get downloadLightweightLoader112 => '1.12.2 及更早版本的轻量加载器';

  @override
  String get downloadInstallationStartedSeeBackground => '已开始安装，进度见顶栏的后台任务';

  @override
  String downloadInstalled2(Object id) {
    return '$id 安装完成';
  }

  @override
  String get commonTaskCanceled => '任务已中断';

  @override
  String commonInstallationFailed(Object error) {
    return '安装失败：$error';
  }

  @override
  String downloadIsntSupported(Object id) {
    return '不支持 $id';
  }

  @override
  String get downloadNone => '不加装';

  @override
  String downloadInstall(Object id) {
    return '安装 $id';
  }

  @override
  String downloadLoadingLoaders(Object count, Object count2) {
    return '正在获取加载器 $count/$count2';
  }

  @override
  String get downloadInstanceName => '实例名称';

  @override
  String downloadInstancesAlreadyInstalledInstalls(Object same, Object id) {
    return '已经有 $same 个 $id 的实例；这次会再装一个独立的实例，存档和模组互不影响';
  }

  @override
  String get downloadVanilla => '原版';

  @override
  String downloadVersion(Object label) {
    return '$label 版本';
  }

  @override
  String downloadBeta(Object label) {
    return '$label（测试版）';
  }

  @override
  String get downloadInstallOptiFineToo => '同时安装 OptiFine';

  @override
  String get downloadLoadingOptiFineVersions => '正在获取 OptiFine 版本…';

  @override
  String downloadCantInstalledTogetherOptiFine(Object label) {
    return '$label 不支持与 OptiFine 一起安装';
  }

  @override
  String get downloadNoOptiFineCompatibleForge => '没有与 Forge 兼容的 OptiFine';

  @override
  String get downloadNoOptiFineVersion => '该版本没有 OptiFine';

  @override
  String get downloadSelectedForgeDiffersFrom => '当前选择的 Forge 与 OptiFine 要求的版本不同，较新的 Forge 可能与它不兼容';

  @override
  String downloadInstallAs(Object text) {
    return '安装为 $text';
  }

  @override
  String get commonInstall => '安装';

  @override
  String get resourcesModrinthModpacks => 'Modrinth 整合包';

  @override
  String resourcesInstalledModpackAs(Object id) {
    return '已安装整合包为 $id';
  }

  @override
  String resourcesAddingOnlyCompatibleShown(Object id, Object label, Object gameVersion) {
    return '正在为 $id 添加$label · 只显示适配 $gameVersion 的$label，安装时直接装进这个实例';
  }

  @override
  String get resourcesBrowseNormally => '改为普通浏览';

  @override
  String resourcesSearchModrinth(Object label) {
    return '在 Modrinth 搜索$label';
  }

  @override
  String resourcesText(Object id) {
    return '适配 $id';
  }

  @override
  String get resourcesSort => '排序';

  @override
  String get resourcesRelevance => '相关性';

  @override
  String get resourcesDownloads => '下载量';

  @override
  String get resourcesFollows => '关注数';

  @override
  String get resourcesNewest => '最新发布';

  @override
  String get resourcesRecentlyUpdated => '最近更新';

  @override
  String resourcesSort2(Object sort) {
    return '排序 $sort';
  }

  @override
  String get resourcesInstallFromFile => '从文件安装';

  @override
  String get resourcesNoResults => '没有找到结果';

  @override
  String get resourcesLoadMore => '加载更多';

  @override
  String get resourcesRemoveFromFavorites => '取消收藏';

  @override
  String get resourcesNoInstancesInstalledYet => '还没有安装任何实例';

  @override
  String resourcesHasNoModLoader(Object id) {
    return '$id 没有安装模组加载器，模组不会生效';
  }

  @override
  String resourcesHasNoWorldsYet(Object id) {
    return '$id 还没有存档，请先进入游戏创建一个世界';
  }

  @override
  String resourcesInstalledFiles(Object count) {
    return '已安装 $count 个文件';
  }

  @override
  String resourcesAlreadyPresent(Object count) {
    return '$count 个已存在';
  }

  @override
  String resourcesNoCompatibleDependencyFound(Object missing) {
    return '找不到兼容的前置：$missing';
  }

  @override
  String resourcesDownloads2(Object author, Object label, Object downloads, Object updated) {
    return '$author · $label · $downloads 次下载$updated';
  }

  @override
  String resourcesUpdated(Object updated) {
    return ' · 更新于 $updated';
  }

  @override
  String get resourcesViewModrinth => '在 Modrinth 查看';

  @override
  String resourcesInstall(Object target) {
    return '安装到 $target';
  }

  @override
  String get resourcesInstall2 => '安装到';

  @override
  String get resourcesWillInstalledAsNew => '将安装为新的实例';

  @override
  String get resourcesWorld => '世界';

  @override
  String get resourcesShowAllFiles => '显示全部文件';

  @override
  String get resourcesNoFilesAvailable => '没有可用的文件';

  @override
  String resourcesNoFilesYouCan(Object gameVersion) {
    return '没有适配 $gameVersion 的文件，可以打开「显示全部文件」';
  }

  @override
  String get resourcesRelease => '正式';

  @override
  String resourcesVersions(Object list, Object list2, Object count) {
    return '$list ~ $list2（$count 个版本）';
  }

  @override
  String get resourcesFavorites => '收藏夹';

  @override
  String get resourcesNoFavoritesYetClick => '还没有收藏，点击资源右侧的心形图标即可收藏';

  @override
  String get toolsMultiplayer => '联机';

  @override
  String get toolsLANTransfer => '局域网互传';

  @override
  String get toolsSendModsWorldsWhole => '在两台设备之间传模组、存档、整个实例';

  @override
  String get toolsServerLookup => '服务器查询';

  @override
  String get toolsCheckServersPlayerCount => '查询服务器在线人数和延迟';

  @override
  String get toolsMultiplayerLobby => '联机大厅';

  @override
  String get toolsPlanned => '规划中';

  @override
  String get toolsTroubleshooting => '排错';

  @override
  String get toolsReadLogsFindCause => '查看日志，自动找出崩溃原因';

  @override
  String get toolsUtilities => '实用';

  @override
  String get toolsCustomDownload => '自定义下载';

  @override
  String get toolsDownloadFileFromLink => '按链接下载文件到指定位置';

  @override
  String get toolsFun => '趣味';

  @override
  String get toolsSkinsAvatars => '皮肤与头像';

  @override
  String get toolsViewDownloadMinecraftPlayers => '查看和下载正版玩家的皮肤';

  @override
  String get toolsAchievementImage => '成就图片';

  @override
  String get toolsMakeCustomAchievementToast => '生成自定义的成就弹窗图片';

  @override
  String get toolsTodaysLuck => '今日人品';

  @override
  String get toolsSeeHowLuckyYou => '看看今天的运气，每人每天固定';

  @override
  String get toolsBackTools => '返回工具';

  @override
  String get toolsPNGImage => 'PNG 图片';

  @override
  String get toolsLetsFewPlayersForm => '让几位玩家组成虚拟局域网一起游戏，正在规划中';

  @override
  String get toolsNoGameHasBeen => '本次打开启动器后还没有启动过游戏';

  @override
  String get toolsLog => '日志';

  @override
  String get toolsEmpty => '内容为空';

  @override
  String get toolsPasteLog => '粘贴日志';

  @override
  String get toolsPasteCrashReportLog => '粘贴崩溃报告或日志内容';

  @override
  String get toolsAnalyze => '分析';

  @override
  String get toolsPastedLog => '粘贴的日志';

  @override
  String get toolsLastGame => '最近一次游戏';

  @override
  String get toolsAnalyzeMostRecentGame => '分析本次打开启动器后最近一次运行的游戏';

  @override
  String get toolsLogFile => '日志文件';

  @override
  String get toolsChooseCrashReportCrash => '选择崩溃报告（crash-reports）或日志文件（logs）';

  @override
  String get toolsPasteCrashReportLog2 => '粘贴别人发给你的崩溃报告或日志';

  @override
  String get toolsPaste => '粘贴';

  @override
  String get toolsLauncherFirstMatchesCommon => '启动器先用本地规则匹配常见问题；在「设置 → AI 排障」填写自己的 AI 服务后，还可以让 AI 分析日志。游戏崩溃时会自动弹出提示。';

  @override
  String get toolsPlayer => '玩家';

  @override
  String toolsSLuckToday(Object name) {
    return '$name 的今日人品';
  }

  @override
  String get toolsFixedEachPlayerEach => '每人每天固定';

  @override
  String get toolsLaunchCount => '启动次数';

  @override
  String toolsYouveLaunchedGameTimes(num launchCount) {
    return '已经通过启动器启动了 $launchCount 次游戏';
  }

  @override
  String get toolsSave => '保存到';

  @override
  String toolsDownload(Object name) {
    return '下载 $name';
  }

  @override
  String toolsDownloadFailed(Object error) {
    return '下载失败：$error';
  }

  @override
  String get toolsDownloadAnyFileProgress => '下载任意文件，进度显示在任务页';

  @override
  String get toolsDownloadURL => '下载地址';

  @override
  String get toolsFileNameOptional => '文件名（可选）';

  @override
  String get toolsSaveLocationChosenWhen => '保存位置：开始下载时选择';

  @override
  String toolsSaveLocation(Object dir) {
    return '保存位置：$dir';
  }

  @override
  String get toolsStartDownload => '开始下载';

  @override
  String get toolsSkinImage => '皮肤图片';

  @override
  String toolsSaved(Object path) {
    return '已保存 $path';
  }

  @override
  String get toolsPlayerSkins => '正版皮肤';

  @override
  String get toolsMinecraftPlayerName => '正版玩家名';

  @override
  String get toolsGet => '获取';

  @override
  String get toolsAlexModelSlimArms => 'Alex 模型（细手臂）';

  @override
  String get toolsSteveModel => 'Steve 模型';

  @override
  String get toolsSaveSkin => '保存皮肤';

  @override
  String get toolsAvatarMaker => '头像生成';

  @override
  String get toolsCropsHeadHatLayer => '从皮肤截取头部（含帽子层）并放大，可用上面获取的正版皮肤或本地皮肤文件';

  @override
  String get toolsChooseLocalSkin => '选择本地皮肤';

  @override
  String toolsLocal(Object localName) {
    return '本地：$localName';
  }

  @override
  String toolsSaveAvatar(Object size) {
    return '保存 $size×$size 头像';
  }

  @override
  String get toolsFetchPlayersSkinChoose => '先获取正版皮肤或选择本地皮肤';

  @override
  String get toolsServerAddress => '服务器地址';

  @override
  String get toolsMcExampleCom1 => 'mc.example.com 或 1.2.3.4:25565';

  @override
  String get toolsLookUp => '查询';

  @override
  String toolsOnlineMsLatency(Object online, Object max, Object version, Object latency) {
    return '在线 $online / $max · $version · 延迟 $latency ms';
  }

  @override
  String get toolsAchievementGet => '获得成就！';

  @override
  String get toolsFillTitleFirstLine => '请填写标题和第一行文字';

  @override
  String get toolsMakesMinecraftStyleAchievement =>
      '生成 Minecraft 风格的成就提示图片。优先由第三方服务 minecraft-api.com 生成（填写的文字会发送给它）；该服务拒绝请求时在本地绘制，本地绘制使用系统字体和你选择的图标';

  @override
  String get toolsItemIDOnline => '物品 ID（在线生成）';

  @override
  String get toolsEGDiamondGrass => '例如 diamond、grass、golden_apple';

  @override
  String get toolsIcon => '图标';

  @override
  String get toolsIconLocalDrawing => '图标（本地绘制）';

  @override
  String get toolsTitle => '标题';

  @override
  String get toolsFirstLine => '第一行';

  @override
  String get toolsSecondLineOptional => '第二行（可选）';

  @override
  String get toolsGenerate => '生成';

  @override
  String get toolsSaveImage => '保存图片';

  @override
  String get toolsOnlineServiceIsntAvailable => '在线服务不可用，以下为本地绘制';

  @override
  String get fileManagerSave => '保存';

  @override
  String get fileManagerEnterValidFileName => '请填写有效的文件名';

  @override
  String get fileManagerFolderSameNameAlready => '已经有同名的文件夹';

  @override
  String get fileManagerReplaceExistingFile => '替换已有的文件？';

  @override
  String fileManagerAlreadyExistsFolderSaving(Object name) {
    return '这个文件夹里已经有「$name」，保存后会替换它。';
  }

  @override
  String get fileManagerReplace => '替换';

  @override
  String get fileManagerName => '名称';

  @override
  String get fileManagerOK => '确定';

  @override
  String get fileManagerNamesCantContain => '名称不能包含 / 或 \\';

  @override
  String get fileManagerNewFolder => '新建文件夹';

  @override
  String get fileManagerFileFolderSameName => '已有同名的文件或文件夹';

  @override
  String get fileManagerRename => '重命名';

  @override
  String get fileManagerDeletePermanently => '彻底删除';

  @override
  String fileManagerWillPermanentlyDeletedCant(Object name) {
    return '「$name」会被彻底删除，不能恢复。';
  }

  @override
  String fileManagerMovedRecycleBin(Object name) {
    return '「$name」已移到回收站';
  }

  @override
  String get fileManagerCantPasteFolderInto => '不能把文件夹粘贴到它自己里面';

  @override
  String fileManagerPasting(Object done, Object total) {
    return '正在粘贴（$done / $total）';
  }

  @override
  String get commonCopy => '复制';

  @override
  String fileManagerImportedFiles(num count) {
    return '已导入 $count 个文件';
  }

  @override
  String get fileManagerLargeFileOnlyFirst => '\n\n…（文件较大，只显示前 512 KB）';

  @override
  String fileManagerCantRead(Object error) {
    return '无法读取：$error';
  }

  @override
  String get fileManagerKindFileCantPreviewed => '不能预览这种文件。可以复制、剪切、重命名或删除';

  @override
  String get fileManagerAppData => '应用数据';

  @override
  String get fileManagerRecycleBin => '回收站';

  @override
  String get fileManagerUp => '上一级';

  @override
  String get fileManagerImportFilesFromPhone => '从手机导入文件';

  @override
  String fileManagerOpenDestinationFolderPaste(Object cut, Object paths, Object length) {
    return '已$cut「$paths」$length，打开目标文件夹后粘贴';
  }

  @override
  String get fileManagerCut => '剪切';

  @override
  String fileManagerMore(Object count) {
    return ' 等 $count 项';
  }

  @override
  String get fileManagerPasteHere => '粘贴到这里';

  @override
  String fileManagerFolder(Object confirm) {
    return '$confirm这个文件夹';
  }

  @override
  String fileManagerTapFile(Object confirm) {
    return '点一个文件来$confirm';
  }

  @override
  String fileManagerTapFile2(Object e, Object confirm) {
    return '点一个 $e 文件来$confirm';
  }

  @override
  String get fileManagerFileName => '文件名';

  @override
  String get fileManagerSaveHere => '保存到这里';

  @override
  String get fileManagerLocation => '位置';

  @override
  String get fileManagerChooseFolder => '选择文件夹';

  @override
  String fileManagerChoose(Object label) {
    return '选择$label';
  }

  @override
  String fileManagerSave2(Object label) {
    return '保存$label';
  }

  @override
  String get fileManagerAccessingPhoneStorageRequires => '需要「所有文件访问权限」才能访问手机存储';

  @override
  String fileManagerCantOpenFolder(Object error) {
    return '无法打开这个文件夹：$error';
  }

  @override
  String get fileManagerGrantPermission => '去授予权限';

  @override
  String get fileManagerEmptyFolder => '空文件夹';

  @override
  String get fileManagerMoreActions => '更多操作';

  @override
  String lanTransferReceivedFrom(Object from, Object version) {
    return '收到来自 $from 的「$version」';
  }

  @override
  String lanTransferCouldntStartReceiving(Object e) {
    return '无法开始接收：$e';
  }

  @override
  String get lanTransferImportAsNewInstance => '导入为新实例';

  @override
  String lanTransferImportAsNewInstance2(Object version, Object count, Object size, Object parents) {
    return '将「$version」导入为新实例，并开启实例隔离。\n共 $count 个文件，$size。\n\n$parents游戏本体依赖的库文件和资源文件没有一起传输，第一次启动时会自动补全。';
  }

  @override
  String lanTransferVanillaVersionDependsImported(Object parents) {
    return '依赖的原版 $parents 也会一起导入（本机已有时保留本机的）。\n';
  }

  @override
  String lanTransferImporting(Object version) {
    return '正在导入「$version」';
  }

  @override
  String lanTransferImportedInstance(Object id) {
    return '已导入实例「$id」';
  }

  @override
  String lanTransferImportingInto(Object id) {
    return '正在导入到「$id」';
  }

  @override
  String lanTransferImportedInto(Object id) {
    return '已导入到「$id」';
  }

  @override
  String lanTransferImportedIntoPreviousContents(Object id, Object backup) {
    return '已导入到「$id」，原来的内容已备份到 $backup';
  }

  @override
  String lanTransferImportFailed(Object e) {
    return '导入失败：$e';
  }

  @override
  String get lanTransferPreparing => '正在准备…';

  @override
  String get lanTransferNoInstancesYetInstall => '还没有实例，请先安装一个实例再导入';

  @override
  String get lanTransferSendersInstance => '发送方的实例';

  @override
  String lanTransferTheseModsComeFrom(Object from, Object id, Object v) {
    return '这些模组来自 $from，但「$id」是 $v，导入后模组不会被加载。建议先在这台设备上安装相同的加载器，或者让对方改用「整个实例」发送。';
  }

  @override
  String lanTransferSendersInstanceLoadersDiffer(Object from, Object id, Object v) {
    return '发送方的实例是 $from，「$id」是 $v，加载器不同。';
  }

  @override
  String lanTransferSendersInstanceGameVersions(Object from, Object id, Object v) {
    return '发送方的实例是 $from，「$id」是 $v，游戏版本不同，模组和存档可能不兼容。';
  }

  @override
  String get lanTransferImportIntoWhichInstance => '导入到哪个实例';

  @override
  String lanTransferReplacesInstancesPreviousContents(Object what) {
    return '将替换这个实例的：$what\n原来的内容会先备份到游戏文件夹的 backups 中。';
  }

  @override
  String get lanTransferChooseInstanceSend => '请选择要发送的实例';

  @override
  String get lanTransferPairingCode6Digits => '配对码是 6 位数字';

  @override
  String get lanTransferConnecting => '正在连接…';

  @override
  String lanTransferConnectedPacking(Object name) {
    return '已连接到 $name，正在打包…';
  }

  @override
  String lanTransferPackingFilesAdded(Object n) {
    return '正在打包…已加入 $n 个文件';
  }

  @override
  String lanTransferSending(Object size) {
    return '正在发送 $size…';
  }

  @override
  String lanTransferSent(Object size, Object reply) {
    return '发送完成（$size）：$reply';
  }

  @override
  String lanTransferSendingFailed(Object e) {
    return '发送失败：$e';
  }

  @override
  String get lanTransferTransferInstancesModsConfigs => '在同一个局域网（同一个 Wi-Fi）中的两台设备之间传输实例、模组、配置和存档。';

  @override
  String get lanTransferReceive => '接收';

  @override
  String get lanTransferAfterYouStartReceiving => '开始接收后，在另一台设备上输入下面显示的地址和配对码。离开这个页面会停止接收。';

  @override
  String get lanTransferStartReceiving => '开始接收';

  @override
  String get lanTransferPairingCode => '配对码';

  @override
  String get lanTransferAddressIPPort => '地址（IP:端口）';

  @override
  String get lanTransferNoLocalNetworkAddress => '没有找到局域网地址，请确认已连接 Wi-Fi 或网线';

  @override
  String get lanTransferIfThereSeveralAddresses => '有多个地址时，通常用 192.168 开头的那个';

  @override
  String get lanTransferIfWindowsFirewallAsks => '如果 Windows 防火墙弹出提示，请允许 Pixel World 访问专用网络';

  @override
  String lanTransferReceiving(Object size, Object size2) {
    return '正在接收 $size / $size2';
  }

  @override
  String get lanTransferStopReceiving => '停止接收';

  @override
  String lanTransferWholeInstance(Object version) {
    return '整个实例「$version」';
  }

  @override
  String lanTransferText(Object version, Object i) {
    return '「$version」的$i';
  }

  @override
  String lanTransferFrom(Object from, Object address, Object describe, Object size) {
    return '来自 $from（$address）$describe，$size';
  }

  @override
  String get lanTransferNoInstancesSendYet => '还没有可以发送的实例';

  @override
  String get lanTransferChooseContent => '选择内容';

  @override
  String get lanTransferWholeInstance2 => '整个实例';

  @override
  String get lanTransferPacksInstanceFolderWithout =>
      '打包实例文件夹（不含日志和崩溃报告）。对方会导入为新实例并开启实例隔离。\n如果这个实例没有开启实例隔离，还会附带下面选中的内容。';

  @override
  String get lanTransferReceiverReplacesSelectedContent => '对方导入时会替换选中的内容，替换前自动备份。';

  @override
  String get lanTransferReceiversAddress => '对方地址';

  @override
  String fileManagerFailed(Object label, Object error) {
    return '$label失败：$error';
  }

  @override
  String get aiGameClosesRightAfter => '游戏启动后闪退，应该从哪里查原因？';

  @override
  String get aiWhatSomeCommonPerformance => '1.20.1 的 Fabric 有哪些常用的优化模组？';

  @override
  String get aiWhatsDifferenceBetweenForge => 'Forge 和 NeoForge 有什么区别？';

  @override
  String get aiHowDoIGive => '怎么给某个版本分配更多内存？';

  @override
  String aiCrashAnalysis(Object title) {
    return '崩溃分析 · $title';
  }

  @override
  String get aiSendFollowing => '发送以下内容';

  @override
  String aiCharactersWillSentModel(Object count, Object host, Object model) {
    return '将发送 $count 个字符到 $host（模型 $model）。玩家名、令牌、UUID、用户目录与 IP 地址已替换。';
  }

  @override
  String get aiDontAskAgain => '以后不再询问';

  @override
  String get aiDeleteConversation => '删除对话';

  @override
  String aiDeleteCantUndone(Object title) {
    return '删除「$title」？删除后无法恢复。';
  }

  @override
  String get aiYesterday => '昨天';

  @override
  String aiDaysAgo(num days) {
    return '$days 天前';
  }

  @override
  String aiMonthDay(Object month, Object day) {
    return '$month 月 $day 日';
  }

  @override
  String get aiNewChat => '新对话';

  @override
  String get aiHistory => '历史对话';

  @override
  String get aiNoConversationsYet => '还没有对话';

  @override
  String get aiAnswering => '正在回答…';

  @override
  String get aiCompactContextSummarizeEarlier => '压缩上下文：把较早的对话压缩成摘要';

  @override
  String get aiConversationShortNoNeed => '对话较短，暂时不需要压缩';

  @override
  String get aiAISettings => 'AI 设置';

  @override
  String get commonHideSidePanel => '收起侧边栏';

  @override
  String get aiShowSidePanelEnvironment => '展开侧边栏（环境、上下文、文件）';

  @override
  String get aiCompactingContext => '正在压缩上下文…';

  @override
  String get aiThinking => '正在思考…';

  @override
  String get aiAskQuestion => '输入问题';

  @override
  String get aiActionRunningYouCan => '操作执行中，完成后才能停止';

  @override
  String get aiStop => '停止';

  @override
  String get aiHowCanIHelp => '有什么可以帮你？';

  @override
  String get aiAskMeAboutMinecraft => '可以问我 Minecraft 和启动器的问题；游戏崩溃时，在错误分析中选择「AI 分析」会自动带上日志。';

  @override
  String get aiSetUpAIService => '先设置 AI 服务';

  @override
  String get aiEnterAPIAddressModel => '填写你自己的 AI 服务的接口地址、模型和 API Key';

  @override
  String aiShowAllCharacters(Object count) {
    return '展开全部（$count 个字符）';
  }

  @override
  String get aiRegenerate => '重新生成';

  @override
  String get aiDeny => '拒绝';

  @override
  String aiAllowConversation(Object label) {
    return '本次对话中允许$label';
  }

  @override
  String get aiAllow => '允许';

  @override
  String get aiRunning => '正在执行';

  @override
  String get aiPreparing => '正在准备';

  @override
  String get aiDenied => '已拒绝';

  @override
  String get aiWaitingEarlierActions => '等待前面的操作';

  @override
  String get aiCanceled => '已取消';

  @override
  String aiInputOutputTokens(Object input, Object output) {
    return '输入 $input · 输出 $output tokens';
  }

  @override
  String aiS(Object ms) {
    return '用时 $ms 秒';
  }

  @override
  String aiRequests(num count) {
    return '$count 次请求';
  }

  @override
  String get aiUsageReportedAIService => '用量由 AI 服务返回，多次请求（例如调用工具）时为合计；用时不包括等待你确认的时间';

  @override
  String aiContextTokensIncludesSystem(Object estimated, Object used, Object window, Object summary) {
    return '上下文：$estimated$used / $window tokens\n包括系统提示、工具说明和发给模型的对话$summary';
  }

  @override
  String get commonAbout => '约 ';

  @override
  String get aiEarlierPartsWereSummarized => '（较早的部分已压缩为摘要）';

  @override
  String get aiConversationAboveWasSummarized => '以上的对话已压缩为摘要';

  @override
  String get aiConversationSummary => '对话摘要';

  @override
  String get aiViewSummary => '查看摘要';

  @override
  String get aiSettingsSaved => '已保存';

  @override
  String aiSettingsFillAPIAddressModel(Object isLocal) {
    return '请填写接口地址、模型$isLocal';
  }

  @override
  String get aiSettingsAPIKey => '和 API Key';

  @override
  String aiSettingsConnectedModelReplied(Object characters) {
    return '连接成功，模型回复：$characters';
  }

  @override
  String get aiSettingsClipboardEmpty => '剪贴板是空的';

  @override
  String get aiSettingsPasted => '已粘贴';

  @override
  String get aiSettingsAPIReturnedNoUsable => '接口没有返回可用的模型';

  @override
  String get commonTestConnection => '测试连接';

  @override
  String get aiSettingsPopularServices => '常用服务';

  @override
  String get aiSettingsOpenAICompatibleAPI => 'OpenAI 兼容接口';

  @override
  String get aiSettingsAnthropicAPI => 'Anthropic 接口';

  @override
  String get aiSettingsAPIAddress => '接口地址';

  @override
  String aiSettingsOnlySentAPIAddress(Object available) {
    return '$available，只会发送给上面填写的接口地址；本机运行的服务可以不填';
  }

  @override
  String get aiSettingsStoredEncryptedDevice => '加密保存在本机';

  @override
  String get aiSettingsStoredLaunchersPrivateData => '保存在启动器的私有数据目录（未加密）';

  @override
  String get aiSettingsHide => '隐藏';

  @override
  String get aiSettingsShow => '显示';

  @override
  String get aiSettingsModel => '模型';

  @override
  String get aiSettingsUseButtonRightFetch => '点右侧按钮从接口获取可用的模型';

  @override
  String get aiSettingsFetchModelList => '获取模型列表';

  @override
  String get aiSettingsContextLengthTokens => '上下文长度（tokens）';

  @override
  String aiSettingsEmptyAutomatic(Object defaultContextWindow) {
    return '留空自动：$defaultContextWindow';
  }

  @override
  String aiSettingsSeeYourProvidersDocs(Object defaultContextWindow) {
    return '见服务商文档；未知的模型默认按 $defaultContextWindow 计算';
  }

  @override
  String get aiSettingsCompactContextAutomatically => '自动压缩上下文';

  @override
  String get aiSettingsSummarizeEarlierMessagesOnce => '超过后把较早的对话压缩成摘要，节省费用';

  @override
  String get aiSettingsAbove32kTokens => '超过 32k tokens 时';

  @override
  String get aiSettingsAbove64kTokens => '超过 64k tokens 时';

  @override
  String get aiSettingsAbove128kTokens => '超过 128k tokens 时';

  @override
  String get aiSettingsAbove256kTokens => '超过 256k tokens 时';

  @override
  String get aiSettingsNever => '不自动压缩';

  @override
  String get aiSettingsConfirmBeforeSending => '发送前确认内容';

  @override
  String get aiSettingsShowLogEnvironmentInfo => '每次分析前显示将要发送的日志与环境信息';

  @override
  String get aiSettingsAllowAIUseTools => '允许 AI 使用工具';

  @override
  String get aiSettingsViewInstancesModsLogs => '查看实例、模组与日志，安装或禁用模组，联网搜索，以及下面的 MCP 服务；会修改内容的操作都需要你确认';

  @override
  String get aiSettingsConfirmReadOnlyActions => '查看类操作也需要确认';

  @override
  String get aiSettingsWhenOffAICan => '关闭时，AI 查看实例、模组、文件与日志不需要确认';

  @override
  String get aiSettingsAITroubleshootingSettings => 'AI 排障设置';

  @override
  String aiSettingsChooseModel(Object count) {
    return '选择模型（$count 个）';
  }

  @override
  String get aiSettingsNoMatchingModels => '没有匹配的模型';

  @override
  String get aiMcpSettingsRemoveMCPService => '移除 MCP 服务';

  @override
  String aiMcpSettingsRemoveItsSavedAccess(Object name) {
    return '移除「$name」？保存的访问令牌也会一起删除。';
  }

  @override
  String get aiMcpSettingsReadOnlyActionsOnly => '只有查看类操作';

  @override
  String get aiMcpSettingsPermissions => '权限';

  @override
  String get aiMcpSettingsToolServicesMCP => '工具服务（MCP）';

  @override
  String get aiMcpSettingsEverythingAIDoesGoes =>
      'AI 的所有操作都通过这些服务完成。设为「只读」的服务会直接拒绝会修改内容的操作，不再询问。外部服务只由启动器主动连接，启动器不对外开放任何端口。';

  @override
  String get commonBuilt => '内置';

  @override
  String get aiMcpSettingsBuiltTurnedOffAbove => '内置 · 已在上方关闭';

  @override
  String get aiMcpSettingsTrustReadOnlyClaims => '信任只读声明';

  @override
  String aiMcpSettingsConnectionFailed(Object split) {
    return '连接失败：$split';
  }

  @override
  String commonTools(num toolCount) {
    return '$toolCount 个工具';
  }

  @override
  String get aiMcpSettingsEdit => '编辑';

  @override
  String get aiMcpSettingsAddMCPService => '添加 MCP 服务';

  @override
  String get aiMcpSettingsRefreshStatus => '刷新状态';

  @override
  String get aiMcpSettingsEnterName => '请填写名称';

  @override
  String get aiMcpSettingsLocalJarServicesCant => '安卓上暂时还不能运行本机 jar 服务';

  @override
  String get aiMcpSettingsChooseJarFile => '请选择 jar 文件';

  @override
  String aiMcpSettingsConnectedToolsAvailable(Object server, Object count, Object names) {
    return '连接成功$server，提供 $count 个工具$names';
  }

  @override
  String get aiMcpSettingsJarFile => 'jar 文件';

  @override
  String get aiMcpSettingsEditMCPService => '编辑 MCP 服务';

  @override
  String get aiMcpSettingsRemoteHTTP => '远程（HTTP）';

  @override
  String get aiMcpSettingsLocalJar => '本机 jar';

  @override
  String get aiMcpSettingsServiceURL => '服务地址';

  @override
  String get aiMcpSettingsRemoteServicesNeedHttps => '远程服务需要 https；本机服务（例如 Termux 里运行的）可以填 http://127.0.0.1:端口/mcp';

  @override
  String get aiMcpSettingsAccessTokenOptional => '访问令牌（可选）';

  @override
  String get aiMcpSettingsStoredEncryptedDeviceOnly => '加密保存在本机，只会发给这个服务（Authorization: Bearer）';

  @override
  String get aiMcpSettingsLaunchArgumentsOptional => '启动参数（可选）';

  @override
  String get aiMcpSettingsSeparatedSpacesAppendedAfter => '用空格分隔，附加在 java -jar 文件 之后；Java 由启动器自动选择（Java 21）';

  @override
  String get aiMcpSettingsTrustServicesReadOnly => '信任这个服务的只读声明';

  @override
  String get aiMcpSettingsWhenToolsServiceDeclares =>
      '打开后，服务声明只读的工具直接执行，不用确认；关闭时，每个工具在本次对话中第一次使用都要确认。声明会删除内容的工具始终每次确认。只对你信任的服务打开';

  @override
  String aiSidePanelFileGone(Object path) {
    return '文件已经不在了：$path';
  }

  @override
  String get aiSidePanelNoModelSetUp => '还没有设置模型';

  @override
  String get aiSidePanelNoInstanceSelected => '没有选择实例';

  @override
  String get commonAIWorkspace => 'AI 工作区';

  @override
  String get aiSidePanelText => '开';

  @override
  String get aiSidePanelOff => '关';

  @override
  String get commonWebSearch => '联网搜索';

  @override
  String get aiSidePanelNotConnected => '未连接';

  @override
  String get aiSidePanelContext => '上下文';

  @override
  String aiSidePanelUsed(Object window) {
    return '$window% 已用';
  }

  @override
  String get aiSidePanelCompact => '压缩';

  @override
  String get aiSidePanelFilesConversation => '本次对话的文件';

  @override
  String get aiSidePanelFilesAIWritesChanges => 'AI 在这次对话里写入或修改的文件会出现在这里';

  @override
  String get aiSidePanelWorkspace => '工作区';

  @override
  String get aiSidePanelStillEmptyYouCan => '还是空的。可以让 AI 把整理结果写到这里';

  @override
  String get aiWorkspaceSettingsLetAIAccessFolder => '让 AI 访问这个文件夹';

  @override
  String get aiWorkspaceSettingsFolderHasAlreadyBeen => '这个文件夹已经添加过了';

  @override
  String get aiWorkspaceSettingsAllowAccessWholeDrive => '允许访问整个磁盘？';

  @override
  String aiWorkspaceSettingsRootDriveSoAI(Object real) {
    return '$real 是磁盘的根目录，AI 将能看到其中所有文件。建议只添加需要的文件夹。';
  }

  @override
  String get aiWorkspaceSettingsAddAnyway => '仍然添加';

  @override
  String get aiWorkspaceSettingsAIHasItsOwn => 'AI 有一个自己的文件夹可以随意读写，并能查看当前实例的游戏文件（只读）';

  @override
  String get aiWorkspaceSettingsAfterGrantingAllFiles => '授予「所有文件访问」后，AI 也能读写系统下载目录。';

  @override
  String get aiWorkspaceSettingsYouCanAddOther => '还可以添加其他文件夹；默认只读，打开「允许修改」后 AI 才能改动其中的文件。';

  @override
  String get aiWorkspaceSettingsAllowChanges => '允许修改';

  @override
  String get aiWorkspaceSettingsRemoveFolderIsntDeleted => '移除（不会删除文件夹）';

  @override
  String get aiWorkspaceSettingsOpenWorkspace => '打开工作区';

  @override
  String get aiWorkspaceSettingsAICanSearchWeb => 'AI 可以搜索网页、打开网址、查 Minecraft Wiki；请求会跟随系统代理';

  @override
  String get aiWorkspaceSettingsSearchEngine => '搜索引擎';

  @override
  String get aiWorkspaceSettingsSearXNGURL => 'SearXNG 地址';

  @override
  String get aiWorkspaceSettingsInstanceNeedsJSONOutput => '实例需要开启 JSON 格式输出';

  @override
  String get aiWorkspaceSettingsExaAPIKeyOptional => 'Exa 的 API Key（可以不填）';

  @override
  String get aiWorkspaceSettingsSearchServiceAPIKey => '搜索服务的 API Key';

  @override
  String get aiWorkspaceSettingsWorksWithoutOneRate => '不填也能用，有频率限制；填了之后额度更高。只会发给 Exa';

  @override
  String get aiWorkspaceSettingsStoredSeparatelyFromModels => '和模型的 Key 分开保存，只会发给所选的搜索服务';

  @override
  String installerAppInstall(Object name) {
    return '安装 $name';
  }

  @override
  String installerAppUninstall(Object name) {
    return '卸载 $name';
  }

  @override
  String get installerAppUninstalling => '正在卸载…';

  @override
  String get installerAppUpdate => '更新';

  @override
  String installerAppVersionInstalledCurrentUser(Object version) {
    return '版本 $version · 只为当前用户安装，不需要管理员权限';
  }

  @override
  String get installerAppInstallLocation => '安装位置';

  @override
  String get installerAppAddStartMenu => '添加到开始菜单';

  @override
  String installerAppThirdPartyMinecraftLauncher(Object name) {
    return '$name 是第三方 Minecraft 启动器，与 Mojang 或 Microsoft 无关。';
  }

  @override
  String get installerAppUpdating => '正在更新';

  @override
  String get installerAppInstalling => '正在安装';

  @override
  String get installerAppInstallationComplete => '安装完成';

  @override
  String installerAppInstalled(Object dir) {
    return '已安装到 $dir';
  }

  @override
  String installerAppLaunch(Object name) {
    return '启动 $name';
  }

  @override
  String get installerAppInstallationFailed => '安装失败';

  @override
  String get installerAppOnlyFilesWrittenDuring => '只删除安装时写入的文件，放在程序文件夹里的其他文件不会动';

  @override
  String get installerAppAlsoDeleteLauncherData => '同时删除启动器数据';

  @override
  String installerAppSettingsAccountsDefaultGame(Object userDataDirs) {
    return '设置、账户与默认游戏文件夹（$userDataDirs）。默认游戏文件夹中的存档也会被删除';
  }

  @override
  String get installerAppUninstall2 => '卸载';

  @override
  String get installerAppUninstalling2 => '正在卸载';

  @override
  String get installerAppUninstallFailed => '卸载失败';

  @override
  String installerCoreRunningCloseBeforeInstalling(Object name) {
    return '$name 正在运行，请先关闭它再安装';
  }

  @override
  String installerCoreCouldntCreateShortcut(Object path) {
    return '无法创建快捷方式：$path';
  }

  @override
  String get installerCoreCouldntWriteUninstallInformation => '写入卸载信息失败';

  @override
  String get installerCoreCantInstallIntoInstallers => '不能安装到安装程序所在的文件夹';

  @override
  String installerCoreCopying(Object rel) {
    return '正在复制 $rel';
  }

  @override
  String get installerCoreFinishingInstallation => '正在完成安装…';

  @override
  String get installerCoreInstallManifestWasntFound => '找不到安装清单，无法确定要删除哪些文件';

  @override
  String appStateRemovedFilesFoldersCreated(Object removed) {
    return '已清理 $removed 个由本次任务创建的文件或目录';
  }

  @override
  String appStateInstall(Object fileName) {
    return '安装 $fileName';
  }

  @override
  String get commonResolveDependencies => '解析前置';

  @override
  String get commonDownloadFiles => '下载文件';

  @override
  String appStateInstalledFilesSkippedExisting(Object count, Object count2, Object missing) {
    return '已安装 $count 个文件，跳过 $count2 个已存在的文件$missing';
  }

  @override
  String appStateNoCompatibleDependencyFound(Object missing) {
    return '，找不到兼容的前置：$missing';
  }

  @override
  String appStateInstallModpack(Object name) {
    return '安装整合包 $name';
  }

  @override
  String get commonDownloadModpack => '下载整合包';

  @override
  String get commonInstallGameLoader => '安装游戏与加载器';

  @override
  String get commonDownloadModpackFiles => '下载整合包文件';

  @override
  String get commonExtractModpackConfigs => '解压整合包配置';

  @override
  String appStateInstalledAs(Object id) {
    return '已安装为 $id';
  }

  @override
  String appStateInstallModpack2(Object path) {
    return '安装整合包 $path';
  }

  @override
  String get commonReadModpack => '读取整合包';

  @override
  String appStateAddOptiFine(Object id) {
    return '为 $id 添加 OptiFine';
  }

  @override
  String get appStateInvalidInstanceName => '实例名称不合法';

  @override
  String appStateInstall2(Object loaderVersion) {
    return '安装 $loaderVersion';
  }

  @override
  String get appStateGameAlreadyRunning => '游戏已在运行';

  @override
  String get appStateChooseInstanceFirst => '请先选择一个实例';

  @override
  String get appStateAddAccountFirst => '请先添加一个账户';

  @override
  String appStateLaunch(Object id) {
    return '启动 $id';
  }

  @override
  String get appStateCheckFiles => '检查文件';

  @override
  String get appStatePrepareLaunch => '准备启动';

  @override
  String get appStateStartGame => '启动游戏';

  @override
  String get appStateVerifyAccount => '验证账户';

  @override
  String get appStateAnalyzeInstance => '分析实例';

  @override
  String get appStateExtractNativeLibraries => '解压本地库';

  @override
  String appStateJavaAndroidJava(Object path, Object major) {
    return 'Java: $path（安卓版 Java $major）';
  }

  @override
  String appStateMemoryGB(Object max) {
    return '内存: $max GB';
  }

  @override
  String appStateWorkingDirectory(Object gameDir) {
    return '工作目录: $gameDir';
  }

  @override
  String appStateRenderScale(Object renderScale) {
    return '渲染比例: $renderScale%';
  }

  @override
  String appStateGPU(Object gpu) {
    return '显卡: $gpu';
  }

  @override
  String appStateRendererLWJGL(
    Object renderer,
    Object reason,
    Object sfpew,
    Object turnip,
    Object lwjgl,
    Object lwjgl2,
    Object sdl,
  ) {
    return '渲染器: $renderer（$reason）$sfpew$turnip，LWJGL $lwjgl$lwjgl2$sdl';
  }

  @override
  String get appStateSFPEWFixedFunctionEmulation => ' + SFPEW（固定管线模拟）';

  @override
  String get appStateTurnipDriver => ' + Turnip 驱动';

  @override
  String get appStateLWJGL2CompatibilityLayer => '（LWJGL 2 兼容层）';

  @override
  String get appStateWarningDeviceDoesntReport => '警告：这台设备没有声明 Vulkan 1.1，所选渲染器可能无法启动';

  @override
  String get appStateTouchControllerModDetectedUsing => '检测到 TouchController 模组：使用它的触控方式';

  @override
  String get appStateWarningKryptonWrapperCrashes => '警告：Krypton Wrapper 在 26.3 快照及之后的版本上会崩溃，出现问题请换用 MobileGlues';

  @override
  String appStateGameExitedCode(Object code) {
    return '游戏已退出，代码 $code';
  }

  @override
  String appStateLaunch2(Object id) {
    return '启动 - $id';
  }

  @override
  String appStateJavaJavaBit(Object path, Object major, Object is64) {
    return 'Java: $path（Java $major，$is64 位）';
  }

  @override
  String appStateMemoryGB2(Object max, Object initial) {
    return '内存: $max GB$initial';
  }

  @override
  String appStateInitialGB(Object initial) {
    return '，初始 $initial GB';
  }

  @override
  String appStateLaunchFailed(Object e) {
    return '启动失败：$e';
  }

  @override
  String get appStateGameCrashedSeeCrash => '游戏崩溃了，可以在错误分析中查看原因';

  @override
  String appStateCouldntCollectCrashInformation(Object e) {
    return '收集崩溃信息失败：$e';
  }

  @override
  String get appInfoPixelWorldLauncher => 'Pixel World 启动器';

  @override
  String get crashEnvironment => '## 环境';

  @override
  String get crashInitialFindingsFromLaunchers => '## 启动器本地规则的初步判断';

  @override
  String crashEnabledModFiles(Object count) {
    return '## 已启用的模组文件（$count 个）';
  }

  @override
  String crashCrashReport(Object path) {
    return '崩溃报告 $path';
  }

  @override
  String crashJVMErrorLog(Object path) {
    return 'JVM 错误日志 $path';
  }

  @override
  String get crashGameOutput => '游戏输出';

  @override
  String crashInstance(Object versionId, Object description) {
    return '实例：$versionId（$description）';
  }

  @override
  String crashLoader(Object loaderLibs) {
    return '加载器：$loaderLibs';
  }

  @override
  String crashAllocatedMemoryGB(Object memoryGb) {
    return '分配内存：$memoryGb GB';
  }

  @override
  String crashSystem(Object operatingSystem, Object operatingSystemVersion) {
    return '系统：$operatingSystem $operatingSystemVersion';
  }

  @override
  String crashExitCode(Object exitCode) {
    return '退出代码：$exitCode';
  }

  @override
  String crashMoreCharactersOmitted(Object max, Object max2) {
    return '$max\n...（以下省略 $max2 个字符）';
  }

  @override
  String crashPreviousLineRepeatedTimes(Object repeat) {
    return '（上一行重复 $repeat 次）';
  }

  @override
  String crashLinesOmitted(Object skipped) {
    return '...（省略 $skipped 行）';
  }

  @override
  String crashCharactersOmitted(Object head, Object budget, Object end) {
    return '$head\n...（中间省略 $budget 个字符）\n$end';
  }

  @override
  String get crashToken => '<令牌>';

  @override
  String crashToken2(Object m) {
    return '$m <令牌>';
  }

  @override
  String get crashPlayer => '<玩家>';

  @override
  String crashUser(Object m) {
    return '$m<用户>';
  }

  @override
  String get crashJavaVersionTooOld => 'Java 版本过低';

  @override
  String crashJavaNewerRequiredBut(Object version, Object version2) {
    return '需要 Java $version 或更高，当前 Java 只支持到 Java $version2。请在实例设置中选择更新的 Java。';
  }

  @override
  String get crashSomeModsGameFiles => '有模组或游戏文件需要更新的 Java，请在实例设置中选择更新的 Java。';

  @override
  String get crashJava8Required => '需要 Java 8';

  @override
  String get crashOldForge112 => '旧版 Forge（1.12.2 及更早）只能在 Java 8 上运行，请在实例设置中选择 Java 8。';

  @override
  String get crashOutMemory => '内存不足';

  @override
  String get crashGameDoesntHaveEnough => '游戏可用的内存不够。可以在实例设置中加大内存，或减少模组、光影与高清材质。';

  @override
  String get crashInvalidMemorySetting => '内存设置无效';

  @override
  String get crashAllocatedMemoryExceedsLimit => '分配的内存超出了系统或 32 位 Java 的上限，请调小内存，或换用 64 位 Java。';

  @override
  String get crashMissingWrongDependency => '缺少前置模组或版本不对';

  @override
  String get crashModsRequiredDependencyIsnt => '有模组需要的前置模组没有安装，或版本不符合要求。按下面的日志行安装或更新对应模组。';

  @override
  String get crashDuplicateMods => '模组重复';

  @override
  String get crashSameModInstalledMore => '同一个模组装了多份（可能是不同版本），请删除多余的文件。';

  @override
  String get crashMixinInjectionFailed => 'Mixin 注入失败';

  @override
  String get crashUsuallyModsIncompatibleEach => '通常是模组之间不兼容，或模组与当前 Minecraft、加载器版本不匹配。日志中会写出出错的模组。';

  @override
  String get crashModsDontMatchLoader => '模组与加载器不匹配';

  @override
  String get crashModsAnotherLoaderInstalled => '装了其他加载器的模组，例如在 Fabric 上装了 Forge 模组。';

  @override
  String get crashOptiFineIncompatible => 'OptiFine 不兼容';

  @override
  String get crashOptiFineIsntCompatibleCurrent =>
      'OptiFine 与当前的 Forge 或其他模组不兼容。可以换用 OptiFine 要求的 Forge 版本，或移除 OptiFine。';

  @override
  String get crashGraphicsDriverProblem => '显卡驱动问题';

  @override
  String get crashGraphicsDriverDoesntSupport => '显卡驱动不支持或出错。请到显卡厂商官网更新驱动；笔记本可以让游戏使用独立显卡。';

  @override
  String get crashMainClassNotFound => '找不到主类';

  @override
  String get crashGameFilesMayIncomplete => '游戏文件可能不完整，或路径中含有特殊字符。可以尝试补全文件或换一个不含特殊字符的文件夹。';

  @override
  String get crashManuallyTriggeredCrash => '手动触发的崩溃';

  @override
  String get crashDebugCrashTriggeredHolding => '这是按住 F3 + C 触发的调试崩溃，不是错误。';

  @override
  String get crashModSuspectedCrashReport => '崩溃报告怀疑的模组';

  @override
  String get crashCrashReportNamesMod => '崩溃报告指出了可能导致崩溃的模组，可以先禁用它试试。';

  @override
  String get taskCancelingTask => '正在中断任务…';

  @override
  String taskFilesDownload(num t) {
    return '共 $t 个文件需要下载';
  }

  @override
  String taskFailed(Object error) {
    return '失败：$error';
  }

  @override
  String javaGetJavaRuntime(Object component) {
    return '获取 Java 运行时 ($component)';
  }

  @override
  String javaDownloadJavaRuntime(Object component, Object useMirror) {
    return '下载 Java 运行时 ($component，$useMirror)';
  }

  @override
  String javaDownloadedFiles(Object done, Object total) {
    return '已下载 $done / $total 个文件';
  }

  @override
  String javaAverageS(Object speed) {
    return ' · 平均 $speed/s';
  }

  @override
  String get javaGetJava8Azul => '获取 Java 8（Azul Zulu，Apple 芯片）';

  @override
  String get javaDownloadJava8Azul => '下载 Java 8（Azul Zulu）';

  @override
  String get javaJava8DownloadFailed => 'Java 8 下载校验失败（SHA-256 不匹配）';

  @override
  String get javaExtractJava8 => '解压 Java 8';

  @override
  String javaCouldntExtractJava8(Object stderr) {
    return '解压 Java 8 失败：$stderr';
  }

  @override
  String get javaJava8ArchiveHas => 'Java 8 压缩包的结构无法识别';

  @override
  String javaJavaPathDoesntExist(Object path) {
    return 'Java 路径不存在：$path';
  }

  @override
  String javaCantRunJava(Object path) {
    return '无法运行 Java：$path';
  }

  @override
  String javaInstanceStartsThroughLaunchWrapper(Object javaMajor) {
    return '这个实例通过 LaunchWrapper 启动（Forge 1.12.2 及更早、OptiFine、LiteLoader 等），只能在 Java 8 上运行，使用 Java $javaMajor 很可能在加载时崩溃。';
  }

  @override
  String get javaUseEnsureAndroidJavaAndroid => '安卓上请使用 ensureAndroidJava';

  @override
  String javaJavaSetDoesntExist(Object where, Object path) {
    return '$where指定的 Java 不存在：$path。请重新选择 Java，或改为自动选择';
  }

  @override
  String javaJavaSetButInstance(Object where, Object major, Object major2) {
    return '$where指定的是 Java $major，这个实例至少需要 Java $major2。请重新选择 Java，或改为自动选择';
  }

  @override
  String get javaInstanceSettings => '实例设置中';

  @override
  String get javaGlobalSettings => '全局设置中';

  @override
  String get javaDetectJava => '检测 Java';

  @override
  String javaAutomaticallyDownloadedJavaOlder(Object major, Object major2) {
    return '自动下载的 Java $major 低于需要的 Java $major2';
  }

  @override
  String javaJavaWasntFoundSet(Object major, Object downloadError) {
    return '找不到 Java $major，请在设置中手动指定 Java 路径$downloadError';
  }

  @override
  String javaAutomaticDownloadFailed(Object downloadError) {
    return '（自动下载失败：$downloadError）';
  }

  @override
  String installFilesGeneratedInstallerMissing(Object missingLocal) {
    return '缺少由安装器生成的文件：$missingLocal，请重新安装这个实例';
  }

  @override
  String get installDownloadGameLibraries => '下载游戏本体与依赖库';

  @override
  String get installDownloadAssetIndex => '下载资源索引';

  @override
  String get installDownloadAssets => '下载资源文件';

  @override
  String get installOrganizeLegacyAssets => '整理旧版资源';

  @override
  String get installInstanceNameCantEmpty => '实例名称不能为空，且不能包含 \\ / : * ? \" < > |';

  @override
  String installInstanceNamedAlreadyExists(Object n) {
    return '已存在名为 $n 的实例';
  }

  @override
  String installDownload(Object component) {
    return '下载 $component';
  }

  @override
  String installInstall(Object component) {
    return '安装 $component';
  }

  @override
  String get installGetVersionInfo => '获取版本信息';

  @override
  String installVersionNotFound(Object id) {
    return '找不到版本 $id';
  }

  @override
  String installDownloadMinecraft(Object gameVersion) {
    return '下载 Minecraft $gameVersion 本体';
  }

  @override
  String downloadDownloadFailed(Object url) {
    return '下载失败：$url';
  }

  @override
  String downloadDownloadTooSlowRetrying(Object target) {
    return '下载速度过慢，更换节点重试：$target';
  }

  @override
  String downloadVerificationFailedSHA1(Object path) {
    return '校验失败（SHA-1 不匹配）：$path';
  }

  @override
  String downloadVerificationFailedSizeShould(Object size, Object count, Object path) {
    return '校验失败（大小应为 $size，实际 $count）：$path';
  }

  @override
  String downloadChunkSizeMismatch(Object path) {
    return '分块大小不符：$path';
  }

  @override
  String downloadSizeMismatchAfterMerging(Object path) {
    return '分块合并后大小不符：$path';
  }

  @override
  String downloadDownloadFailedHTTP(Object statusCode) {
    return '下载失败（HTTP $statusCode）';
  }

  @override
  String downloadConnected(Object host, Object total) {
    return '已连接 $host$total';
  }

  @override
  String downloadFileSizeMB(Object total) {
    return '，文件大小 $total MB';
  }

  @override
  String get downloadServerDidntReportFile => '，服务器没有提供文件大小';

  @override
  String downloadDownloadTooSlowKB(Object secs) {
    return '下载速度过慢（$secs KB/s）';
  }

  @override
  String get downloadNoDataReceived => '没有收到数据';

  @override
  String downloadIncompleteDownloadBytes(Object received, Object total) {
    return '下载不完整（$received / $total 字节）';
  }

  @override
  String downloadIncompleteDownloadExpectedBytes(Object size, Object received) {
    return '下载不完整（应为 $size 字节，实际 $received）';
  }

  @override
  String downloadFilesFailedDownloadE(Object count, Object errors) {
    return '$count 个文件下载失败，例如：$errors';
  }

  @override
  String get modpackModpackDoesntSpecifyMinecraft => '整合包没有标明 Minecraft 版本';

  @override
  String get modpackNotValidModrinthModpack => '不是有效的 Modrinth 整合包：缺少 modrinth.index.json';

  @override
  String modpackInstallMinecraft(Object minecraft) {
    return '安装 Minecraft $minecraft';
  }

  @override
  String modpackModpackContainsUnsafePath(Object message) {
    return '整合包包含不安全的路径：$message';
  }

  @override
  String modpackSkippedUnneededFiles(Object skipped) {
    return '跳过 $skipped 个不需要的文件';
  }

  @override
  String modpackExtractedConfigOverrideFiles(Object extracted) {
    return '已解压 $extracted 个配置与覆盖文件';
  }

  @override
  String forgeDownloadInstaller(Object label) {
    return '下载 $label 安装器';
  }

  @override
  String forgeInstallerCorruptedInstallProfile(Object label) {
    return '$label 安装器已损坏：找不到 install_profile.json';
  }

  @override
  String forgeOfflineInstallFailedInstalling(Object e) {
    return '离线安装失败，改为联网安装：$e';
  }

  @override
  String forgeInstallerNeedsDownloadMojang(Object label) {
    return '$label 安装器需要联网下载 Mojang 映射，无法完全离线安装';
  }

  @override
  String forgeDownloadFilesNeededInstaller(Object label) {
    return '下载 $label 安装器需要的文件';
  }

  @override
  String forgeSomeFilesDidntDownload(Object e) {
    return '部分文件没有下载成功，交给安装器重试：$e';
  }

  @override
  String forgeRunInstallerProcessingFiles(Object label) {
    return '运行 $label 安装器（处理文件，可能需要几分钟）';
  }

  @override
  String forgeRunInstallerDownloadingDependencies(Object label) {
    return '运行 $label 安装器（下载依赖并处理文件，可能需要几分钟）';
  }

  @override
  String forgeInstallerFailedExitCode(Object label, Object code, Object tail) {
    return '$label 安装器运行失败（退出代码 $code）\n$tail';
  }

  @override
  String forgeInstallerFailed(Object label, Object tail) {
    return '$label 安装器运行失败\n$tail';
  }

  @override
  String forgeSeveralNewVersionsAppeared(Object label, Object candidates) {
    return '$label 安装器之后出现了多个新版本（$candidates），无法确定是哪一个';
  }

  @override
  String forgeInstallerDidntCreateNew(Object label) {
    return '$label 安装器没有生成新的版本';
  }

  @override
  String forgeInstall(Object label) {
    return '安装 $label';
  }

  @override
  String forgeInstallerCorruptedMissing(Object label, Object install) {
    return '$label 安装器已损坏：找不到 $install';
  }

  @override
  String get modrinthShaderPacks => '光影包';

  @override
  String get modrinthTooManyRequestsPlease => '请求过于频繁，请稍后再试';

  @override
  String modrinthModrinthRequestFailed(Object statusCode) {
    return 'Modrinth 请求失败（$statusCode）';
  }

  @override
  String get modrinthResourceWasntFoundModrinth => 'Modrinth 上找不到该资源';

  @override
  String get modrinthModpackInstallationWillCome => '整合包安装将在后续版本提供';

  @override
  String get modrinthChooseWorldInstallData => '请选择要安装数据包的世界';

  @override
  String modrinthResolveDependencies(Object length) {
    return '解析前置（$length）';
  }

  @override
  String get extraLoadersDownloadOptiFine => '下载 OptiFine';

  @override
  String get extraLoadersPutIntoModsFolder => '放入 mods 文件夹';

  @override
  String extraLoadersPutInto(Object path) {
    return '已放入 $path';
  }

  @override
  String get extraLoadersDownloadOptiFineInstaller => '下载 OptiFine 安装包';

  @override
  String get extraLoadersGenerateOptiFineLibrary => '生成 OptiFine 库';

  @override
  String extraLoadersOptiFinePatcherFailedExit(Object code, Object tail) {
    return 'OptiFine Patcher 运行失败（退出代码 $code）\n$tail';
  }

  @override
  String extraLoadersOptiFineInstallerCorruptedLaunchwrapper(Object lwVersion) {
    return 'OptiFine 安装包已损坏：找不到 launchwrapper-of-$lwVersion.jar';
  }

  @override
  String get extraLoadersGetLabyModVersionList => '获取 LabyMod 版本清单';

  @override
  String loadersLiteLoaderNotFound(Object version) {
    return '找不到 LiteLoader $version';
  }

  @override
  String get loadersLiteLoaderOnlySupports1 => 'LiteLoader 只支持 1.12.2 及更早的版本';

  @override
  String get loadersInstallLiteLoader => '安装 LiteLoader';

  @override
  String loadersGetConfiguration(Object label) {
    return '获取 $label 配置';
  }

  @override
  String get loaderNamesUnknown => '未知';

  @override
  String get optifineCompatWillInstalledAsSeparate => '将安装为独立的 OptiFine 版本';

  @override
  String optifineCompatGoesIntoModsAs(Object requiredForge) {
    return '作为模组放进 mods；适配 Forge $requiredForge，较新的 Forge 可能不兼容';
  }

  @override
  String get optifineCompatGoesIntoModsAs2 => '作为模组放进 mods';

  @override
  String get optifineCompatGoesIntoModsAs3 => '作为模组放进 mods；OptiFine 官方不支持 NeoForge，可能无法加载';

  @override
  String get optifineCompatGoesIntoModsAs4 => '作为模组放进 mods；还需要另外安装 OptiFabric 模组才能加载';

  @override
  String launchRunningPreLaunchCommand(Object command) {
    return '执行启动前命令：$command';
  }

  @override
  String versionVersionIsntInstalled(Object id) {
    return '版本 $id 未安装';
  }

  @override
  String get lanTransferModConfigs => '模组配置';

  @override
  String get lanTransferGameOptions => '游戏设置';

  @override
  String get lanTransferUnsupportedTransferFormatUpdate => '不支持的传输格式，请把两边的启动器更新到同一版本';

  @override
  String get lanTransferInvalidTransferManifest => '传输清单无效';

  @override
  String lanTransferInvalidInstanceName(Object version) {
    return '实例名无效：$version';
  }

  @override
  String lanTransferInvalidDependencyVersionName(Object id) {
    return '依赖版本名无效：$id';
  }

  @override
  String get lanTransferTransferManifestContainsUnsupported => '传输清单中有不支持的内容';

  @override
  String get lanTransferUnknownDevice => '未知设备';

  @override
  String get lanTransferChooseAtLeastOne => '请至少选择一项内容';

  @override
  String get lanTransferNoneSelectedItemsExist => '选中的内容都不存在';

  @override
  String get lanTransferReceivedFileIsntPixel => '收到的文件不是 Pixel World 的传输包';

  @override
  String get lanTransferTransferManifestCantRead => '传输清单无法读取';

  @override
  String get lanTransferTransferPackageMissingFiles => '传输包缺少文件，可能没有传输完整';

  @override
  String lanTransferTransferPackageContainsSymbolic(Object name) {
    return '传输包中有符号链接：$name';
  }

  @override
  String lanTransferTransferPackageContainsFile(Object name) {
    return '传输包中有清单以外的文件：$name';
  }

  @override
  String lanTransferFileSizeDoesntMatch(Object name) {
    return '文件大小与清单不符：$name';
  }

  @override
  String lanTransferInvalidTransferPackage(Object name) {
    return '传输包无效：$name';
  }

  @override
  String commonTemporaryFolderAlreadyExists(Object staging) {
    return '临时文件夹已存在：$staging';
  }

  @override
  String lanTransferTransferPackageContainsDuplicate(Object rel) {
    return '传输包中有重复的文件：$rel';
  }

  @override
  String lanTransferFileSizeDoesntMatch2(Object rel) {
    return '文件大小与清单不符：$rel';
  }

  @override
  String get lanTransferTransferPackageIsntWhole => '这个传输包不是整个实例';

  @override
  String lanTransferInstanceNamedAlreadyExists(Object id) {
    return '已经有名为「$id」的实例，请先在实例设置里重命名或删除它';
  }

  @override
  String lanTransferTransferPackageHasNo(Object id) {
    return '传输包中没有版本文件 $id.json';
  }

  @override
  String get lanTransferTransferPackageWholeInstance => '这个传输包是整个实例，请导入为新实例';

  @override
  String lanTransferWrongPairingCodeAttempts(num left) {
    return '配对码不正确，还可以再试 $left 次';
  }

  @override
  String get lanTransferTooManyWrongPairing => '配对码错误次数太多，对方已停止接收';

  @override
  String get lanTransferTooManyWrongPairing2 => '配对码错误次数太多，已停止接收。需要时重新开始接收，会生成新的配对码。';

  @override
  String get lanTransferOtherDeviceReceivingAnother => '对方正在接收另一个传输，请稍后再试';

  @override
  String get lanTransferMissingFileSize => '缺少文件大小';

  @override
  String get lanTransferFileTooLargeAt => '文件太大，单次最多 32 GB';

  @override
  String get lanTransferReceivedMoreDataThan => '收到的数据比声明的多';

  @override
  String lanTransferTransferInterruptedOnlyBytes(Object got, Object total) {
    return '传输中断，只收到 $got / $total 字节';
  }

  @override
  String get lanTransferReceivedOtherDeviceWaiting => '对方已收到，等待对方确认导入';

  @override
  String lanTransferReceivingFailed(Object e) {
    return '接收失败：$e';
  }

  @override
  String get lanTransferAddressShouldIPPort => '地址格式应为「IP:端口」，例如 192.168.1.5:43567';

  @override
  String lanTransferConnectionFailed(Object statusCode) {
    return '连接失败（$statusCode）';
  }

  @override
  String get lanTransferOtherDevice => '对方设备';

  @override
  String lanTransferCantReachMakeSure(Object host, Object port) {
    return '连不上 $host:$port。请确认两台设备在同一个局域网，对方正在接收，且防火墙允许 Pixel World 联网';
  }

  @override
  String lanTransferSendingFailed2(Object statusCode) {
    return '发送失败（$statusCode）';
  }

  @override
  String lanTransferTransferInterrupted(Object message) {
    return '传输中断：$message';
  }

  @override
  String get toolboxPerfectScoreEverythingGoes => '满分！今天做什么都会顺利';

  @override
  String get toolboxGreatLuckEveryChest => '大吉，开箱必出钻石';

  @override
  String get toolboxPrettyLuckyGoodDay => '运气不错，适合去下界走走';

  @override
  String get toolboxSteadyCalmNoLava => '平平稳稳，挖矿不会挖到岩浆';

  @override
  String get toolboxSoSoRememberBring => '一般般，记得多带几个床';

  @override
  String get toolboxWatchOutCreepersSave => '小心苦力怕，出门前先存档';

  @override
  String get toolboxGoodDayStayHome => '今天适合在家种田';

  @override
  String get toolboxZeroBetterStayOut => '零分……今天还是别下矿了';

  @override
  String get toolboxOnlyWindowsSupportedNow => '目前只支持 Windows';

  @override
  String get toolboxCouldntCreateShortcut => '创建快捷方式失败';

  @override
  String get toolboxEnterURLStartingHttp => '请输入 http 或 https 开头的网址';

  @override
  String toolboxConnect(Object host) {
    return '连接 $host';
  }

  @override
  String toolboxDownload(Object path) {
    return '下载 $path';
  }

  @override
  String toolboxSavedMB(Object path, Object done) {
    return '已保存到 $path（$done MB）';
  }

  @override
  String get toolboxPlayerNamesCanOnly => '玩家名只能包含字母、数字和下划线';

  @override
  String toolboxNoMinecraftPlayerNamed(Object n) {
    return '找不到正版玩家 $n';
  }

  @override
  String toolboxPlayerLookupFailed(Object s1) {
    return '查询玩家失败（$s1）';
  }

  @override
  String toolboxCouldntGetSkinInfo(Object s2) {
    return '获取皮肤信息失败（$s2）';
  }

  @override
  String toolboxUsesDefaultSkin(Object n) {
    return '$n 使用的是默认皮肤';
  }

  @override
  String toolboxCouldntDownloadSkin(Object s3) {
    return '下载皮肤失败（$s3）';
  }

  @override
  String get toolboxItemNotFoundCheck => '找不到这个物品，请检查物品 ID';

  @override
  String toolboxGenerationFailed(Object status) {
    return '生成失败（$status）';
  }

  @override
  String get toolboxServerReturnedInvalidData => '服务器返回的数据无效';

  @override
  String get toolboxInvalidServerAddress => '服务器地址格式不正确';

  @override
  String toolboxCantConnect(Object e) {
    return '无法连接：$e';
  }

  @override
  String toolboxConnectionInterrupted(Object e) {
    return '连接中断：$e';
  }

  @override
  String get toolboxServerClosedConnection => '服务器关闭了连接';

  @override
  String get toolboxConnectionTimedOut => '连接超时';

  @override
  String androidRuntimeCouldntReadSystemLog(Object e) {
    return '读取系统日志失败：$e';
  }

  @override
  String get androidRuntimePixelWorldGameProcess => '\n[Pixel World] 游戏进程没有启动，或启动后立即退出了。\n';

  @override
  String androidRuntimeSystemLogLogcat(Object systemLog) {
    return '\n---------- 系统日志（logcat） ----------\n$systemLog\n';
  }

  @override
  String get androidRuntimePixelWorldJarRunner => '[Pixel World] jar 运行进程没有启动';

  @override
  String get androidRuntimePixelWorldJarRunner2 => '[Pixel World] jar 运行进程在启动 Java 前退出了';

  @override
  String get androidRuntimeZinkOpenGLVulkan => 'Zink（OpenGL 转 Vulkan）';

  @override
  String get androidRuntimeKryptonWrapperRecommended => 'Krypton Wrapper（推荐）';

  @override
  String get androidRuntimeSystemGLESDriverGLES => '系统 GLES 驱动（仅限支持 GLES 的模组）';

  @override
  String get androidRuntimeUsesKryptonWrapperDefault =>
      '默认用 Krypton Wrapper；26.x 版本改用 MobileGlues，显卡不支持 OpenGL ES 3 时用 Zink';

  @override
  String get androidRuntimeOpenGLOpenGLESSupports => 'OpenGL 转 OpenGL ES，支持所有版本，包括 26.x（旧版本自动加 SFPEW 模拟固定管线）';

  @override
  String get androidRuntimeMesaZinkFullOpenGL =>
      'Mesa Zink：完整的 OpenGL 4.6，需要 Vulkan 1.1。骁龙（Adreno）上自动改用自带的开源驱动 Turnip，适合 MobileGlues 画面出错时使用';

  @override
  String get androidRuntimeNGGL4ESOpenGLOpenGL =>
      'NG-GL4ES：OpenGL 转 OpenGL ES，效率高，新旧版本都能用，能运行 Sodium 和部分光影。26.3 快照起的版本暂不可用';

  @override
  String get androidRuntimeUsesSystemGLESDriver => '直接使用系统 GLES 驱动，不做转译。原版 Minecraft 无法以此运行';

  @override
  String get androidRuntimeNoVulkan => '无 Vulkan';

  @override
  String get androidRuntimeSetSettings => '设置指定';

  @override
  String get androidRuntimeGPUDoesntSupportOpenGL => '显卡不支持 OpenGL ES 3';

  @override
  String get androidRuntime26XVersionKrypton => '26.x 版本，Krypton Wrapper 暂不支持';

  @override
  String androidRuntimeExtractJava(Object major) {
    return '解压 Java $major';
  }

  @override
  String androidRuntimeExtractingMB(Object size) {
    return '正在解压 $size MB…';
  }

  @override
  String androidRuntimeExtracting(Object total) {
    return '解压中 $total%';
  }

  @override
  String androidRuntimeDownloadJava(Object major, Object name) {
    return '下载 Java $major（$name）';
  }

  @override
  String get androidRuntimeDownloadIsntValidArchive => '下载到的不是有效的压缩包';

  @override
  String androidRuntimeJavaDownloadedMBFrom(Object major, Object lengthSync, Object name) {
    return 'Java $major 下载完成（$lengthSync MB，来源 $name）';
  }

  @override
  String androidRuntimeDownloadFailed(Object name, Object e) {
    return '$name 下载失败：$e';
  }

  @override
  String androidRuntimeJavaDownloadFailedTried(Object major, Object failures) {
    return 'Java $major 下载失败，已尝试 GitHub 与镜像：\n$failures';
  }

  @override
  String androidRuntimeJavaSetIsntInstalled(Object where, Object home) {
    return '$where指定的 Java 没有安装：$home。请在设置的 Java 页面下载，或改为自动选择';
  }

  @override
  String androidRuntimeJavaSetButInstance(Object where, Object major, Object requiredValue) {
    return '$where指定的是 Java $major，这个实例至少需要 Java $requiredValue。请重新选择 Java，或改为自动选择';
  }

  @override
  String get importInvalidEncryptedDataLength => '加密数据长度无效';

  @override
  String get importUnrecognizedCNGProtectedData => '无法识别的 CNG 保护数据';

  @override
  String get importPCLCEAccountKeys => 'PCL-CE 的账户密钥只能在 Windows 上解开';

  @override
  String get importPCLCEUserKey => '找不到 PCL-CE 用户密钥 UserKey.bin';

  @override
  String get importUnrecognizedUserKeyBinFormat => 'UserKey.bin 格式无法识别';

  @override
  String importUnsupportedUserKeyVersion(Object version) {
    return '不支持的 UserKey 版本 $version';
  }

  @override
  String get importOldEncryptionFormatImport => '旧版加密格式，不支持导入';

  @override
  String importUnsupportedEncryptionVersion(Object version) {
    return '不支持的加密版本 $version';
  }

  @override
  String get importNoPCLCEConfiguration => '没有找到 PCL-CE 的配置（%APPDATA%\\PCLCE）';

  @override
  String get importIPProtocolPreference => 'IP 协议偏好';

  @override
  String get importHighPerformanceGPU => '高性能显卡';

  @override
  String get importLauncherBehaviorAfterLaunch => '启动后启动器行为';

  @override
  String get importJavaChoice => 'Java 选择';

  @override
  String get importMemoryMode => '内存模式';

  @override
  String get importCustomMemory => '自定义内存';

  @override
  String get importPreLaunchCommand => '启动前命令';

  @override
  String get importWaitPreLaunchCommand => '等待启动前命令';

  @override
  String get importVersionType => '版本类型';

  @override
  String get importWindowMode => '窗口模式';

  @override
  String get importMemoryJVMArgumentsInstance => '内存、JVM 参数、实例隔离等设置保存在 PCL-CE 程序目录中，选择该目录后才能导入';

  @override
  String get importPCLCEFolder => 'PCL-CE 文件夹';

  @override
  String importIncompleteAccountInfoSign(Object name) {
    return '$name（账户信息不完整，请在账户中重新登录）';
  }

  @override
  String importAccountImportFailed(Object e) {
    return '账户导入失败：$e';
  }

  @override
  String backupBackupFileCorrupted(Object e) {
    return '备份文件已损坏：$e';
  }

  @override
  String get backupBackupWasntCreatedPixel => '这个备份不是由 Pixel World 创建的，无法恢复';

  @override
  String get backupInvalidBackupManifest => '备份清单无效';

  @override
  String backupBackupManifestContainsUnsafe(Object e) {
    return '备份清单中有不安全的路径：$e';
  }

  @override
  String get backupBackupManifestContainsDuplicate => '备份清单中有重复或互相包含的路径';

  @override
  String get backupBackupSignatureMismatchBackup => '备份签名不匹配：备份被修改过，或者不是在这台设备上创建的';

  @override
  String backupBackupContainsSymbolicLink(Object name) {
    return '备份中有符号链接，不能恢复：$name';
  }

  @override
  String backupBackupContainsUnsafePath(Object name) {
    return '备份中有不安全的路径：$name';
  }

  @override
  String backupBackupContainsFileNot(Object name) {
    return '备份中有清单以外的文件：$name';
  }

  @override
  String backupBackupContainsDuplicateFile(Object name) {
    return '备份中有重复的文件：$name';
  }

  @override
  String backupBackupContentsDontMatch(Object name) {
    return '备份内容与清单不符：$name';
  }

  @override
  String get backupBackupMissingFilesListed => '备份缺少清单中的文件';

  @override
  String backupBackupContainsSymbolicLink2(Object name) {
    return '备份中有符号链接：$name';
  }

  @override
  String backupFileContentsDontMatch(Object rel) {
    return '文件内容与备份清单不符：$rel';
  }

  @override
  String get networkCheckMojangOfficial => 'Mojang 官方源';

  @override
  String get networkCheckGameLibraryDownloads => '下载游戏和运行库';

  @override
  String get networkCheckGameLoaderDownloadsMainland => '国内下载游戏、加载器';

  @override
  String get networkCheckMicrosoftSign => 'Microsoft 登录';

  @override
  String get networkCheckMicrosoftAccountSign => '正版账户登录';

  @override
  String get networkCheckModsModpacksResourcePacks => '模组、整合包、资源包';

  @override
  String get networkCheckPixelWorldUpdates => 'Pixel World 更新';

  @override
  String get networkCheckUpdateChecksAnnouncementsDocs => '检查更新、公告和文档';

  @override
  String get networkCheckTimedOut => '超时';

  @override
  String get networkCheckSecureConnectionFailed => '安全连接失败';

  @override
  String networkCheckConnectionFailed(Object error) {
    return '连接失败（$error）';
  }

  @override
  String get microsoftMicrosoftAccountDoesntHave => '该微软账户尚未创建 Xbox 档案';

  @override
  String get microsoftUnderageAccountsNeedJoin => '未成年账户需要加入家庭组后才能登录';

  @override
  String microsoftMinecraftRejectedAzureApp(Object status) {
    return 'Minecraft 拒绝了这个 Azure 应用（$status Invalid app registration）。新应用需要先通过 Mojang 的审核（https://aka.ms/mce-reviewappid），审核通过后要用同一个 Client ID 重新登录；刚通过时可能要等一段时间才生效';
  }

  @override
  String microsoftRequestFailed(Object status, Object url, Object reason) {
    return '请求失败（$status）：$url$reason';
  }

  @override
  String get microsoftAccountDoesntOwnMinecraft => '该账户没有购买 Minecraft: Java Edition';

  @override
  String microsoftCouldntGetProfile(Object status, Object reason) {
    return '获取档案失败（$status）$reason';
  }

  @override
  String get microsoftSetAzureAppClient => '请先在「设置 - 其他」中填写 Azure 应用 Client ID';

  @override
  String microsoftSignAccountHasExpired(Object name) {
    return '账户 $name 的登录已过期（导入自 PCL-CE，无法续期），请使用微软登录重新添加';
  }

  @override
  String get microsoftMicrosoftAccountHasExpired => '微软账户已过期，请重新登录';

  @override
  String get docsOverview => '总览';

  @override
  String get docsDownloadInstall => '下载与安装';

  @override
  String get docsFirstLaunch => '第一次启动';

  @override
  String get docsVersionsLoaders => '版本与加载器';

  @override
  String get docsAndroid => '安卓版';

  @override
  String get docsFAQTroubleshooting => '常见问题与排错';

  @override
  String get docsLauncherAPI => '启动器接口';

  @override
  String get docsDocumentEmpty => '文档内容为空';

  @override
  String docsCouldntLoadDocsCheck(Object error) {
    return '无法获取文档（$error），请检查网络后重试';
  }

  @override
  String get docsNoCache => '没有缓存';

  @override
  String get instanceFilesFoldersCantOpenedPhones => '手机上暂时不能打开文件夹';

  @override
  String instanceFilesCouldntMoveRecycleBin(Object stderr) {
    return '无法移到回收站：$stderr';
  }

  @override
  String get instanceFilesCouldntMoveTrash => '无法移到废纸篓';

  @override
  String get instanceFilesCouldntMoveRecycleBin2 => '无法移到回收站';

  @override
  String instanceFilesUnknownNBTType(Object typeValue) {
    return '未知的 NBT 类型 $typeValue';
  }

  @override
  String safePathOnlyFilesVersionsWorking(Object rel) {
    return '只能访问版本运行目录中的文件：$rel';
  }

  @override
  String safePathInvalidPath(Object rel) {
    return '路径无效：$rel';
  }

  @override
  String get safePathOnlyFilesVersionsWorking2 => '只能访问版本运行目录中的文件';

  @override
  String safePathPathContainsSymbolicLink(Object root) {
    return '路径中有符号链接，为安全起见不能操作：$root';
  }

  @override
  String safePathCantDetermineRealLocation(Object root) {
    return '无法确认路径的真实位置：$root';
  }

  @override
  String safePathPathActuallyPointsOutside(Object root) {
    return '路径实际指向版本运行目录之外：$root';
  }

  @override
  String get updaterGitHubRateLimitExceeded => 'GitHub 访问次数超出限制，请稍后再试';

  @override
  String updaterCouldntGetUpdateInfo(Object statusCode) {
    return '无法获取更新信息（HTTP $statusCode）';
  }

  @override
  String get updaterInstallingUnknownAppsNeeds => '需要允许安装未知应用';

  @override
  String updaterIncompleteDownloadBytes(Object received, Object size) {
    return '下载不完整（$received / $size 字节）';
  }

  @override
  String get updaterFileVerificationFailedSHA => '文件校验失败（SHA-256 不匹配）';

  @override
  String get updaterAutomaticUpdatesArentSupported => '这个平台暂不支持自动更新';

  @override
  String updaterUpdatePackageDoesntContain(Object appExeNames) {
    return '更新包中找不到主程序（$appExeNames）';
  }

  @override
  String get updaterText => ' 或 ';

  @override
  String get hudBridgeConversationNoLongerExists => '这个对话已经不存在了。';

  @override
  String get hudBridgeQuestionCantEmpty => '问题不能为空。';

  @override
  String get hudBridgeAIIsntSetUp => '还没有配置 AI。请回到启动器，在「设置 → AI」里填写接口、模型和 API Key。';

  @override
  String get hudBridgeConversationStillBeingAnswered => '这个对话还在回答，请稍等一下。';

  @override
  String hudBridgeWaitingConfirmation(Object label) {
    return '等待确认：$label';
  }

  @override
  String hudBridgeRunning(Object label) {
    return '正在执行：$label';
  }

  @override
  String yggdrasilConnectDoesntSupportYggdrasilConnect(Object name) {
    return '$name 不支持 Yggdrasil Connect';
  }

  @override
  String yggdrasilConnectHasInvalidYggdrasilConnect(Object name) {
    return '$name 的 Yggdrasil Connect 配置无效';
  }

  @override
  String yggdrasilConnectLauncherHasntRegisteredApp(Object name) {
    return '启动器尚未在 $name 注册应用，暂时无法使用 OAuth 登录';
  }

  @override
  String get yggdrasilConnectMalformedIDToken => 'ID 令牌格式错误';

  @override
  String get yggdrasilConnectInvalidIDTokenIssuer => 'ID 令牌无效（签发者、受众或有效期不符）';

  @override
  String yggdrasilConnectDoesntSupportDeviceCode(Object name) {
    return '$name 不支持设备代码登录';
  }

  @override
  String get yggdrasilConnectNoProfileWasChosen => '授权时没有选择角色';

  @override
  String yggdrasilConnectAuthorizationAccountHasExpired(Object typeLabel, Object name) {
    return '$typeLabel 账户 $name 的授权已过期，请在账户中重新登录';
  }

  @override
  String oauthCantStartSign(Object status) {
    return '无法开始登录：$status';
  }

  @override
  String get oauthAuthorizationDenied => '已拒绝授权';

  @override
  String get oauthSignTimedOutPlease => '登录超时，请重试';

  @override
  String oauthSignFailed(Object status) {
    return '登录失败：$status';
  }

  @override
  String oauthAuthenticationServerTemporarilyUnavailable(Object status) {
    return '验证服务器暂时不可用（$status），请稍后再试';
  }

  @override
  String accountsExternal(Object host) {
    return '外置登录 · $host';
  }

  @override
  String get accountsUsernamesMust316 => '用户名需为 3-16 位字母、数字或下划线';

  @override
  String get yggdrasilAccountHasNoProfile => '该账户还没有角色，请先到皮肤站创建角色';

  @override
  String get yggdrasilAuthenticationServerDidntReturn => '验证服务器没有返回所选角色';

  @override
  String yggdrasilProfileNoLongerBelongs(Object name) {
    return '角色 $name 已不在该账户下，请重新添加账户';
  }

  @override
  String get yggdrasilApiEnterAuthenticationServerAddress => '请输入验证服务器地址';

  @override
  String yggdrasilApiIsntValidAuthenticationServer(Object url) {
    return '$url 不是有效的验证服务器';
  }

  @override
  String yggdrasilApiAuthenticationServerReturnedHTTP(Object status) {
    return '验证服务器返回 HTTP $status';
  }

  @override
  String newsMinecraftWikiRequestFailed(Object statusCode) {
    return 'Minecraft Wiki 请求失败（$statusCode）';
  }

  @override
  String get secureEncryptionFailed => '加密失败';

  @override
  String get secureDecryptionFailed => '解密失败';

  @override
  String get authlibInjectorVerificationFailedSHA256 => '校验失败（SHA-256 不匹配）';

  @override
  String authlibInjectorCouldntDownloadAuthlibInjector(Object e) {
    return '无法下载 authlib-injector：$e';
  }

  @override
  String get authSignCanceled => '已取消登录';

  @override
  String get aiToolsViewInstanceList => '查看实例列表';

  @override
  String get aiToolsViewInstanceInfo => '查看实例信息';

  @override
  String aiToolsViewInfo(Object id) {
    return '查看 $id 的信息';
  }

  @override
  String get aiToolsViewModList => '查看模组列表';

  @override
  String aiToolsViewMods(Object id) {
    return '查看 $id 的模组';
  }

  @override
  String get aiToolsViewFiles => '查看文件';

  @override
  String aiToolsView(Object id, Object rel) {
    return '查看 $id/$rel';
  }

  @override
  String get aiToolsReadLog => '读取日志';

  @override
  String aiToolsRead(Object id, Object kind) {
    return '读取 $id 的$kind';
  }

  @override
  String get aiToolsCrashReport => '崩溃报告';

  @override
  String get aiToolsDebugLog => '调试日志';

  @override
  String get aiToolsSearchMods => '搜索模组';

  @override
  String aiToolsSearchModrinth(Object q) {
    return '在 Modrinth 搜索「$q」';
  }

  @override
  String get aiToolsViewInstallableVersions => '查看可安装的版本';

  @override
  String get aiToolsViewInstallableMinecraftVersions => '查看可安装的 Minecraft 版本';

  @override
  String get aiToolsViewLoaderVersions => '查看加载器版本';

  @override
  String aiToolsViewVersions(Object game, Object label) {
    return '查看 $game 的 $label 版本';
  }

  @override
  String get aiToolsInstallNewInstance => '安装新实例';

  @override
  String aiToolsSwitchCurrentInstance(Object id) {
    return '把当前实例切换为 $id';
  }

  @override
  String get aiToolsSearchResources => '搜索资源';

  @override
  String aiToolsSearchModrinth2(Object f, Object label, Object q) {
    return '在 Modrinth 搜索$f$label$q';
  }

  @override
  String aiToolsText(Object label) {
    return '$label 的';
  }

  @override
  String get aiToolsViewProjectDetails => '查看项目详情';

  @override
  String aiToolsViewModrinthProject(Object ids) {
    return '查看 Modrinth 项目 $ids';
  }

  @override
  String aiToolsCompareModrinthProjects(Object count) {
    return '比较 $count 个 Modrinth 项目';
  }

  @override
  String get aiToolsInstallResource => '安装资源';

  @override
  String aiToolsInstall(Object label, Object name) {
    return '安装$label $name';
  }

  @override
  String aiToolsInstance(Object id) {
    return '实例：$id';
  }

  @override
  String aiToolsFileInto(Object fileName, Object fileSize, Object folder) {
    return '文件：$fileName（$fileSize），放进 $folder';
  }

  @override
  String get aiToolsSourceModrinth => '来源：Modrinth';

  @override
  String get aiToolsViewJava => '查看 Java';

  @override
  String get aiToolsViewInstalledJava => '查看已安装的 Java';

  @override
  String get aiToolsViewSystemInfo => '查看系统信息';

  @override
  String get aiToolsSetInstanceJava => '设置实例的 Java';

  @override
  String aiToolsChangeJava(Object id, Object label) {
    return '把 $id 的 Java 改为$label';
  }

  @override
  String aiToolsBefore(Object old) {
    return '原来：$old';
  }

  @override
  String aiToolsAfter(Object label) {
    return '改为：$label';
  }

  @override
  String get aiToolsSetInstanceMemory => '设置实例的内存';

  @override
  String aiToolsChangeMemory(Object id, Object label) {
    return '把 $id 的内存改为$label';
  }

  @override
  String aiToolsBefore2(Object s) {
    return '原来：$s';
  }

  @override
  String aiToolsSystemMemoryGBTotal(Object total, Object free) {
    return '系统内存：共 $total GB，当前空闲 $free GB';
  }

  @override
  String get aiToolsReadConfigFile => '读取配置文件';

  @override
  String commonRead(Object rel) {
    return '读取 $rel';
  }

  @override
  String get aiToolsEditConfigFile => '修改配置文件';

  @override
  String aiToolsEditChanges(Object rel, Object count) {
    return '修改 $rel（$count 处）';
  }

  @override
  String get aiToolsOriginalFileBackedUp => '修改前会备份原文件';

  @override
  String get aiToolsInstallMod => '安装模组';

  @override
  String aiToolsInstallMod2(Object name) {
    return '安装模组 $name';
  }

  @override
  String aiToolsFile(Object fileName, Object fileSize) {
    return '文件：$fileName（$fileSize）';
  }

  @override
  String get aiToolsRequiredDependenciesInstalledToo => '会同时安装必需的前置模组';

  @override
  String get aiToolsEnableDisableMods => '启用或禁用模组';

  @override
  String aiToolsMods(Object enabled, Object count) {
    return '$enabled $count 个模组';
  }

  @override
  String get aiToolsEnable => '启用';

  @override
  String get aiToolsDisable => '禁用';

  @override
  String get aiToolsBackUp => '备份';

  @override
  String aiToolsBackUpItems(Object count) {
    return '备份 $count 项';
  }

  @override
  String aiToolsAboutSavedBackupsGame(Object size) {
    return '大小约 $size，保存到游戏文件夹的 backups 中';
  }

  @override
  String get aiToolsViewBackups => '查看备份';

  @override
  String aiToolsViewBackups2(Object id) {
    return '查看 $id 的备份';
  }

  @override
  String get commonDeleteFiles => '删除文件';

  @override
  String aiToolsDeleteItemsMoveRecycle(Object count) {
    return '删除 $count 项（移到回收站）';
  }

  @override
  String get aiToolsReplaceMod => '替换模组';

  @override
  String aiToolsReplaceMod2(Object name) {
    return '替换模组 $name';
  }

  @override
  String aiToolsOldFile(Object name) {
    return '旧文件：$name';
  }

  @override
  String aiToolsNewFileFromModrinth(Object fileName, Object name) {
    return '新文件：$fileName（$name，来自 Modrinth）';
  }

  @override
  String get aiToolsOldFileBackedUp => '旧文件会先备份，再移到回收站';

  @override
  String get aiToolsRestoreFromBackup => '从备份恢复';

  @override
  String aiToolsRestoreFromBackup2(Object name) {
    return '从备份 $name 恢复';
  }

  @override
  String aiToolsWillRestoreFiles(Object paths, Object files, Object bytes) {
    return '将恢复：$paths（$files 个文件，$bytes）';
  }

  @override
  String get aiToolsNoteBackupWasCreated => '注意：这是旧版 Pixel World 创建的备份，没有签名，无法确认内容未被修改过';

  @override
  String get aiToolsItsExtractedTemporaryFolder => '先解压到临时文件夹并校验，成功后才把当前的对应内容备份并移到回收站';

  @override
  String aiToolsInstall2(Object shown) {
    return '安装 $shown';
  }

  @override
  String aiToolsInstanceName(Object shown) {
    return '实例名称：$shown';
  }

  @override
  String aiToolsDownloadsFromMayTake(Object useMirror) {
    return '从$useMirror下载，可能需要几分钟；进度可以在任务页查看';
  }

  @override
  String aiToolsNoteHasNoIris(Object id) {
    return '注意：$id 中没有找到 Iris 或 OptiFine，光影包需要它们才能使用';
  }

  @override
  String get workspaceToolsViewAccessibleFolders => '查看可访问的文件夹';

  @override
  String get workspaceToolsViewFolder => '查看目录';

  @override
  String workspaceToolsView(Object rel) {
    return '查看 $rel';
  }

  @override
  String get workspaceToolsFindFiles => '查找文件';

  @override
  String workspaceToolsFind(Object rel, Object pattern) {
    return '在 $rel 中查找 $pattern';
  }

  @override
  String get workspaceToolsSearchFileContents => '搜索文件内容';

  @override
  String workspaceToolsSearch(Object rel, Object pattern) {
    return '在 $rel 中搜索「$pattern」';
  }

  @override
  String get workspaceToolsReadFile => '读取文件';

  @override
  String get workspaceToolsWriteFile => '写入文件';

  @override
  String workspaceToolsLines(Object length, Object count) {
    return '$length，$count 行';
  }

  @override
  String get workspaceToolsOriginalFileWillReplaced => '原文件会被替换';

  @override
  String get workspaceToolsEditFile => '修改文件';

  @override
  String workspaceToolsEdit(Object rel, Object count) {
    return '修改 $rel$count';
  }

  @override
  String workspaceToolsOriginal(Object oldText) {
    return '原文：\n$oldText';
  }

  @override
  String workspaceToolsChange(Object newText) {
    return '改为：\n$newText';
  }

  @override
  String get workspaceToolsMoveFile => '移动文件';

  @override
  String workspaceToolsMove(Object rel, Object rel2) {
    return '把 $rel 移动到 $rel2';
  }

  @override
  String workspaceToolsDelete(Object rel) {
    return '删除 $rel';
  }

  @override
  String get workspaceToolsWholeFolderItsContents => '整个文件夹及其中的内容';

  @override
  String workspaceToolsFile(Object lengthSync) {
    return '文件，$lengthSync';
  }

  @override
  String get workspaceToolsMovedRecycleBin => '会移到回收站';

  @override
  String webToolsSearch(Object q) {
    return '搜索「$q」';
  }

  @override
  String get webToolsOpenWebPage => '打开网页';

  @override
  String webToolsOpen(Object host, Object path) {
    return '打开 $host$path';
  }

  @override
  String get webToolsSearchMinecraftWiki => '搜索 Minecraft Wiki';

  @override
  String webToolsSearchMinecraftWiki2(Object q) {
    return '在 Minecraft Wiki 中搜索「$q」';
  }

  @override
  String get aiClientQwen => '通义千问';

  @override
  String get aiClientOllamaLocal => 'Ollama（本机）';

  @override
  String get aiClientEnterAPIAddressFirst => '请先填写接口地址';

  @override
  String aiClientCouldntGetModelList(Object s) {
    return '获取模型列表失败：$s';
  }

  @override
  String aiClientCantConnect(Object host, Object message) {
    return '无法连接 $host：$message';
  }

  @override
  String aiClientSecureConnectionFailed(Object host) {
    return '与 $host 的安全连接失败';
  }

  @override
  String get aiClientAPIDidntReturnModel => '接口返回的不是模型列表，请检查接口地址';

  @override
  String aiClientConnectionTimedOut(Object host) {
    return '连接 $host 超时';
  }

  @override
  String get aiClientModelRefusedAnswerRequest => '模型拒绝回答这个请求';

  @override
  String get aiClientModelReturnedNothingCheck => '模型没有返回内容，请检查接口地址和模型名';

  @override
  String get aiClientAnswerHitLengthLimit => '\n\n（回答达到长度上限，已截断）';

  @override
  String aiClientConnectionWasInterrupted(Object host, Object message) {
    return '与 $host 的连接中断：$message';
  }

  @override
  String aiClientSecureConnectionFailedCheck(Object host) {
    return '与 $host 的安全连接失败，请检查接口地址或网络代理';
  }

  @override
  String aiClientHasntRespondedLongTime(Object host) {
    return '$host 长时间没有响应，请稍后重试';
  }

  @override
  String get aiClientConversationLongerThanModel => '对话内容超出了模型能处理的长度，请点对话上方的「压缩上下文」按钮，或新建一个对话';

  @override
  String aiClientModelDoesntExistIsnt(Object model) {
    return '模型「$model」不存在或不可用，请检查模型名，或点模型旁的按钮获取可用的模型';
  }

  @override
  String get aiClientInsufficientBalanceQuotaTop => '账户余额或额度不足，请到服务商的控制台充值或检查额度';

  @override
  String get aiClientAIServiceOverloadedPlease => 'AI 服务当前过载，请稍后重试';

  @override
  String get aiClientRequestRejectedModelProvider => '请求被拒绝，可能是这个模型或服务商不支持当前的请求方式';

  @override
  String get aiClientAPIKeyInvalidExpired => 'API Key 无效或已过期，请在设置中检查';

  @override
  String get aiClientNoPermissionUseModel => '没有权限使用这个模型或接口，请检查账户权限或地区限制';

  @override
  String get aiClientAPIAddressModelDoesnt => '接口地址或模型不存在，请检查接口地址（OpenAI 兼容接口通常以 /v1 结尾）';

  @override
  String get aiClientAIServiceTimedOut => 'AI 服务响应超时，请稍后重试';

  @override
  String get aiClientContentSentTooLong => '发送的内容太长，请新建一个对话';

  @override
  String get aiClientTooManyRequestsPlease => '请求太频繁，请稍后再试';

  @override
  String get aiClientAIServiceTemporarilyUnavailable => 'AI 服务暂时不可用，请稍后重试';

  @override
  String aiClientRequestFailed(Object code, Object raw) {
    return '请求失败（$code）：$raw';
  }

  @override
  String get aiClientNoDetailsReturned => '没有返回说明';

  @override
  String get mcpClientExaSearch => 'Exa 搜索';

  @override
  String get mcpClientInvalidURL => '网址无效';

  @override
  String get mcpClientOnlyHttpHttpsSupported => '只支持 http / https';

  @override
  String get mcpClientRemoteServicesMustUse => '远程服务请使用 https；http 只能连接本机（127.0.0.1 / localhost）';

  @override
  String mcpClientServiceReturnedError(Object err) {
    return '服务返回错误：$err';
  }

  @override
  String get mcpClientAccessDeniedCheckAccess => '访问被拒绝，检查访问令牌';

  @override
  String get mcpClientWrongAddressServiceClosed => '地址不对，或服务已经关闭了这个会话';

  @override
  String get mcpClientResponseTooLarge => '响应太大';

  @override
  String get mcpClientMalformedResponse => '响应格式不对';

  @override
  String get mcpClientTimedOutWaitingService => '等待服务响应超时';

  @override
  String get mcpClientServicesResponseIsntValid => '服务的响应不是有效的 JSON';

  @override
  String mcpClientCantReachService(Object message) {
    return '连不上服务：$message';
  }

  @override
  String mcpClientConnectionError(Object message) {
    return '连接出错：$message';
  }

  @override
  String get mcpClientServiceDisconnectedWithoutResponding => '服务没有返回响应就断开了';

  @override
  String get mcpClientServiceProcessHasExited => '服务进程已经退出';

  @override
  String mcpClientServiceProcessHasExited2(Object code) {
    return '服务进程已经退出（退出代码 $code）';
  }

  @override
  String get mcpClientPixelWorldDoesntSupport => 'Pixel World 不支持这个请求';

  @override
  String get mcpClientServiceProvidesNoTools => '这个服务没有提供工具';

  @override
  String get mcpHubAskEveryTime => '每次询问';

  @override
  String get mcpHubReadOnlyRejectChanges => '只读（直接拒绝修改）';

  @override
  String mcpHubCall(Object name, Object name2) {
    return '调用「$name」的 $name2';
  }

  @override
  String get mcpHubServiceDeclaresToolRead => '服务声明这个工具只读取，不做修改';

  @override
  String mcpHubArguments(Object shown) {
    return '参数：$shown';
  }

  @override
  String get mcpHubExited => '退出';

  @override
  String get mcpHubUnreachable => '连不上';

  @override
  String get mcpHubLocalJarServicesCant => '安卓上暂时还不能运行本机 jar 服务，可以改用远程（HTTP）服务';

  @override
  String mcpHubJarFileNotFound(Object jar) {
    return '找不到 jar 文件：$jar';
  }

  @override
  String get mcpHubPrepareJavaMCPService => '准备 MCP 服务的 Java';

  @override
  String get aiChatModelReturnedNoSummary => '模型没有返回摘要';

  @override
  String aiChatCouldntCompactContext(Object e) {
    return '压缩上下文失败：$e';
  }

  @override
  String get aiChatTooManyActionsRound => '这一轮的操作次数过多，已暂停。可以发送消息让 AI 继续';

  @override
  String aiChatAnswerInterrupted(Object partial) {
    return '$partial\n\n（回答中断）';
  }

  @override
  String get aiChatNoToolsAvailable => '没有可用的工具';

  @override
  String aiChatStopped(Object partial) {
    return '$partial\n\n（已停止）';
  }

  @override
  String agentRootCurrentInstance(Object id) {
    return '当前实例（$id）';
  }

  @override
  String get agentRootDownloads => '下载目录';

  @override
  String get aiPromptMyGameCrashedBelow => '我的游戏崩溃了，下面是启动器收集的崩溃信息，请帮我分析原因并告诉我怎么解决。';

  @override
  String get aiReplyLanguage => '简体中文';

  @override
  String get commonListSeparator => '、';

  @override
  String get commonClauseSeparator => '；';

  @override
  String get commonComma => '，';

  @override
  String get commonColon => '：';

  @override
  String commonParenthesized(Object text) {
    return '（$text）';
  }

  @override
  String get aiSearchEngineAuto => '内置（Exa，失败时 DuckDuckGo、必应）';

  @override
  String get aiSearchEngineExa => 'Exa（Key 可以不填）';

  @override
  String get aiSearchEngineBing => '必应（英文结果更可靠）';

  @override
  String get aiSearchEngineSearxng => 'SearXNG（自建或公共实例）';

  @override
  String get aiSearchEngineTavily => 'Tavily（需要 Key）';

  @override
  String get aiSearchEngineBrave => 'Brave Search（需要 Key）';

  @override
  String get aiSearchEngineSerper => 'Serper / Google（需要 Key）';

  @override
  String get downloadLoadFailedRetry => '连不上 · 重试';

  @override
  String get precheckOwnershipRequired => '为了正版验证，需要先登录一次购买了 Minecraft 的微软账户，才能使用离线账户和外置登录。';

  @override
  String get launchDialogsVerifyOwnershipFirst => '需要先验证正版';

  @override
  String get launchDialogsOwnershipRequiredBody =>
      'Minecraft 是付费游戏。按照 Mojang 的规定，需要先登录一次购买了 Minecraft 的微软账户，才能用离线账户或外置登录开始游戏。\n\n验证一次之后，离线账户和外置登录就可以一直使用了。';

  @override
  String get launchDialogsBuyGame => '去购买';

  @override
  String get launchDialogsSignInMicrosoft => '登录微软账户';

  @override
  String get oobeAccountHintVerified => '玩正版用微软账户，也可以用离线账户或外置登录。';

  @override
  String get oobeAccountHintUnverified => '为了正版验证，请先登录购买了 Minecraft 的微软账户，之后也能用离线账户和外置登录。';

  @override
  String get oobeAvailableAfterVerification => '验证正版后可用';

  @override
  String get accountsOwnershipNotice => '说明：为了正版验证，离线账户和外置登录需要先登录一次拥有 Minecraft 的微软账户，确认你购买了游戏后才能添加和使用。';

  @override
  String get touchTipTitle => '试试 TouchController';

  @override
  String touchTipBody(Object instance) {
    return 'TouchController 是第三方模组，给 Java 版带来基岩版风格的触屏操作，按键布局可以自己调整。它还在早期开发阶段，可能会遇到问题。\n\n装进「$instance」后，下次启动时启动器会把游戏内的触摸交给它，并隐藏自带的虚拟按键；想换回来，在模组里禁用它就行。';
  }

  @override
  String get touchTipInstall => '安装';

  @override
  String get touchTipNever => '不再推荐';

  @override
  String touchTipInstalled(Object instance) {
    return '已为 $instance 安装 TouchController，下次启动生效';
  }

  @override
  String touchTipBodyLaunch(Object instance) {
    return 'TouchController 是第三方模组，给 Java 版带来基岩版风格的触屏操作，按键布局可以自己调整。它还在早期开发阶段，可能会遇到问题。\n\n装进「$instance」后，这次启动就由它接管游戏内的触摸，并隐藏自带的虚拟按键；想换回来，在模组里禁用它就行。';
  }

  @override
  String get touchTipLaunchAnyway => '直接启动';

  @override
  String get touchTipInstallAndLaunch => '安装并启动';
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
  String get navAiAssistant => 'AI 助手';

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
  String get homeLayout => '首頁佈局';

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
  String get homeLayoutStandardMobileHint => '標準：原來的首頁，不顯示背景圖片；要使用背景圖片請選「上下」或「極簡」';

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
  String get bgImageUnset => '選擇一張圖片作為啟動器的背景，介面面板會變成毛玻璃';

  @override
  String get bgImageInactive => '「標準」首頁不顯示背景圖片，把首頁版面換成「上下」或「極簡」後生效';

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
  String get helpGroup => '說明';

  @override
  String get helpTour => '新手教學';

  @override
  String get helpTourHint => '再看一遍啟動器各個地方的介紹：帳戶、安裝遊戲、實例、開始遊戲、工具和設定';

  @override
  String get helpTourStart => '開始';

  @override
  String get helpTerms => '使用者協議';

  @override
  String get helpTermsHint => '使用規則、第三方內容與免責聲明';

  @override
  String get helpPrivacy => '隱私說明';

  @override
  String get helpPrivacyHint => '不收集你的資訊；儲存在本機的內容與會連線的服務';

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
      'Pixel World 是第三方 Minecraft 啟動器，本專案為輕度使用 PCL 存放庫，介面版面參考 PCL 社群版（PCL-CE）。PCL 由龍騰貓躍開發，本軟體與 PCL 及其作者無關，也不代表 PCL 官方。請勿就本軟體的問題打擾 PCL 作者。本軟體不是 Mojang 或 Microsoft 的官方產品，未經它們認可，也與它們沒有關聯；Minecraft 是 Mojang Synergies AB 的商標。';

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
  String get downloadSourceAuto => '自動選擇';

  @override
  String get downloadSourceOfficial => '官方來源';

  @override
  String get downloadSourceMirror => 'BMCLAPI 鏡像';

  @override
  String get downloadSourceAutoHint => '測速選擇官方來源或 BMCLAPI 鏡像中較快的，失敗時自動換另一個';

  @override
  String get downloadSourceOfficialHint => '只使用 Mojang 和各載入器的官方伺服器';

  @override
  String get downloadSourceMirrorHint => '優先使用 BMCLAPI 鏡像，失敗時回退到官方來源';

  @override
  String downloadSourceCurrent(String source) {
    return '（目前：$source）';
  }

  @override
  String get networkCheck => '網路檢測';

  @override
  String get networkCheckHint => '測試下載來源、正版登入、Modrinth 和更新服務能否連線、速度多快';

  @override
  String get networkCheckStart => '開始檢測';

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

  @override
  String get oobeWelcome => '歡迎';

  @override
  String get oobeAppearance => '外觀';

  @override
  String get oobeGameFolder => '遊戲資料夾';

  @override
  String get oobeNetwork => '網路';

  @override
  String get oobeAccount => '帳戶';

  @override
  String get oobeDone => '完成';

  @override
  String oobeImportedFromPCLCE(Object folders, Object accounts) {
    return '已從 PCL-CE 匯入：遊戲資料夾 $folders 個，帳戶 $accounts 個';
  }

  @override
  String oobeCouldntImportFromPCL(Object e) {
    return '從 PCL-CE 匯入失敗：$e';
  }

  @override
  String get oobeAbout1Minute => '約 1 分鐘';

  @override
  String get oobe6StepsAbout1 => '共 6 步，約 1 分鐘';

  @override
  String get oobeAcceptAgreementContinue => '勾選同意後才能繼續';

  @override
  String get oobeYouCanChangeAll => '之後都可以在「設定」裡改';

  @override
  String get commonBack => '上一步';

  @override
  String get commonDeclineQuit => '不同意並退出';

  @override
  String get oobeInstallYourFirstInstance => '去安裝第一個實例';

  @override
  String get oobeOpenLauncher => '進入啟動器';

  @override
  String get oobeStartSetup => '開始設定';

  @override
  String get commonSkip => '跳過';

  @override
  String get commonNext => '下一步';

  @override
  String get commonWelcomePixelWorld => '歡迎使用 Pixel World';

  @override
  String get oobeFreeOpenSourceMinecraft => '免費、開源的 Minecraft 啟動器。花一兩分鐘完成幾項設定，之後都可以在「設定」裡改。';

  @override
  String get oobeInstallManage => '安裝與管理';

  @override
  String get oobeVanillaEveryModLoader => '原版和各種載入器，一個版本可以裝多個實例，模組、存檔各管各的。';

  @override
  String get oobeModsResources => '模組與資源';

  @override
  String get oobeFindModsModpacksResource => '在啟動器裡直接找模組、整合包、資源包和光影。';

  @override
  String get oobeAITroubleshooting => 'AI 排障';

  @override
  String get oobeGameCrashedLetAI => '遊戲崩了，讓 AI 讀日誌找原因。';

  @override
  String get commonTermsUsePrivacyNotice => '使用者協議與隱私說明';

  @override
  String get oobeBeforeYouContinuePlease => '繼續之前，請閱讀並同意下面兩份檔案。';

  @override
  String get oobeSoftwareFreeOpenSource =>
      '· 本軟體免費開源，按原樣提供；不是 Mojang、Microsoft 或 PCL 的官方產品。\n· 我們不收集你的資訊，帳戶和設定只儲存在你的裝置上。\n· 遊戲、模組等內容來自第三方，下載時直接連線它們。';

  @override
  String get oobeIHaveReadAccept => '我已閱讀並同意《使用者協議》和《隱私說明》';

  @override
  String get oobePickLookYouLike => '選一個順眼的樣子。手機上的「標準」就是原來的首頁；背景圖片只在「上下」「極簡」裡顯示。';

  @override
  String get oobePickLookYouLike2 => '選一個順眼的樣子。';

  @override
  String get oobeLightDarkLauncherAppearance => '啟動器介面的明暗';

  @override
  String get oobeSelectedPanelsBecomeFrosted => '已選擇 · 面板會變成毛玻璃，主題色跟隨圖片';

  @override
  String get oobeOptionalChooseImageShow => '可選：選一張圖片放在啟動器後面';

  @override
  String oobeCantUseImage(Object e) {
    return '無法使用這張圖片：$e';
  }

  @override
  String get oobeGamesInstancesModsWorlds => '遊戲、實例、模組和存檔都放在這裡。之後可以在「設定 → 遊戲管理」裡新增更多資料夾。';

  @override
  String get oobeUseDefaultFolder => '使用預設資料夾';

  @override
  String get oobeUseExistingMinecraftFolder => '使用已有的 .minecraft 資料夾';

  @override
  String get oobeInstalledGameAnotherLauncher => '以前用別的啟動器裝過遊戲？直接選那個資料夾，裡面的版本和存檔都能用。';

  @override
  String get oobeNotChosenYet => '還沒有選擇';

  @override
  String get oobePCLCEDetected => '檢測到 PCL-CE';

  @override
  String oobeImportsPCLCEGame(Object folders, Object hasAccounts) {
    return '匯入 PCL-CE 的遊戲資料夾（$folders 個）$hasAccounts和啟動設定。';
  }

  @override
  String get oobeAccounts => '、帳戶';

  @override
  String get oobeWhereShouldGameFiles => '遊戲檔案放在哪裡？';

  @override
  String get oobeYouCanChangeLater => '之後可以在「設定 → 遊戲管理」裡更改。';

  @override
  String get oobePhoneStorage => '手機儲存空間';

  @override
  String get oobeStoredPixelWorldMinecraft =>
      '放在「Pixel World/.minecraft」。解除安裝或重裝啟動器後遊戲和存檔仍然保留，也能用其他應用管理。需要授予「所有檔案存取權限」。';

  @override
  String get oobeAppStorage => '應用內部';

  @override
  String get oobeNoPermissionNeededBut => '不需要權限，但解除安裝啟動器時遊戲和存檔會一起刪除。';

  @override
  String get oobeDecidedAfterSpeedTest => '測速後決定';

  @override
  String get oobeSpeedTestBMCLAPIMirror => '測速結果：BMCLAPI 鏡像更快';

  @override
  String get oobeSpeedTestOfficialSource => '測速結果：官方來源更快';

  @override
  String get oobeUsuallyFasterMainlandChina => '國內一般更快';

  @override
  String get oobeOfficialServersOnly => '只用官方伺服器';

  @override
  String get oobeChooseWhereDownloadGame => '選擇從哪裡下載遊戲檔案。下面會自動檢測各項服務的連線情況。';

  @override
  String get oobeAutomaticUsesFasterOne => '「自動選擇」會優先用更快的一邊，失敗時自動換另一邊。';

  @override
  String get oobeMicrosoftAccount => '微軟帳戶';

  @override
  String get oobeSetClientIDSettings => '需要先在「設定 → 其他」填寫 Client ID';

  @override
  String get oobeOfficialSignLetsYou => '正版登入，可以進正版伺服器';

  @override
  String get commonSignMicrosoft => '微軟登入';

  @override
  String get oobeExternalSign => '外置登入';

  @override
  String get oobeLittleSkinOtherSkinSites => 'LittleSkin 等皮膚站';

  @override
  String get oobeOfflineAccount => '離線帳戶';

  @override
  String get oobeJustPickNamePlay => '起個名字就能玩單機';

  @override
  String get oobeOfflineUsername => '離線使用者名';

  @override
  String get oobe316LettersDigits => '3～16 個字母、數字或下划線';

  @override
  String get oobeAdd => '新增';

  @override
  String get oobeAdded => '已新增';

  @override
  String get oobeYouCanAlsoSkip => '不想現在新增也可以直接下一步。';

  @override
  String oobeAutomaticCurrently(Object preferMirror) {
    return '自動選擇（目前：$preferMirror）';
  }

  @override
  String get commonAllSet => '準備好了';

  @override
  String get oobeHereYourChoicesClick => '下面是你的選擇，點「修改」可以回去改。';

  @override
  String oobeLayout(Object mode, Object homeLayout) {
    return '$mode · $homeLayout佈局';
  }

  @override
  String get oobeNoneYet => '還沒有新增';

  @override
  String get oobeTakeGuidedTourAfter => '進入後看一遍新手教程';

  @override
  String get oobeAbout30SecondsYou => '大約 30 秒；之後可以在「設定 → 關於與致謝 → 幫助」裡再看';

  @override
  String get oobeFirstTimeSetup => '首次設定';

  @override
  String get oobeDontWantSetThings => '不想現在設定？';

  @override
  String get oobeUseAllDefaults => '全部用預設';

  @override
  String get oobeYouStillNeedAccept => '（仍需同意協議）';

  @override
  String get oobeChange => '修改';

  @override
  String get oobeChoose => '選擇…';

  @override
  String get oobeLargeCardAnnouncementsShortcuts => '大卡片、公告與快捷按鈕、最近遊玩';

  @override
  String get oobeInstanceAtTopPlay => '實例在頂部，開始遊戲在底部，中間留給背景';

  @override
  String get oobeSingleBarAtBottom => '只在底部留一條';

  @override
  String get tourTakeMinuteGetKnow => '花一分鐘認識一下啟動器的幾個主要地方。隨時可以點「跳過」，之後在「設定 → 關於與致謝」裡能再看一遍。';

  @override
  String get tourAddAccountFirst => '先新增帳戶';

  @override
  String get tourClickHereAddMicrosoft => '點這裡新增微軟正版帳戶；登入過一次正版後，也可以新增外置登入（例如 LittleSkin）和離線帳戶。';

  @override
  String get tourInstallGame => '安裝遊戲';

  @override
  String get tourUnderDownloadChooseGame =>
      '在「下載」裡選遊戲版本和載入器（Forge、Fabric 等）來安裝。裝好的一份叫「實例」，同一個版本可以裝好幾個，存檔和模組互不影響。模組、整合包、資源包和光影也在這裡找。';

  @override
  String get tourSwitchInstance => '切換實例';

  @override
  String get tourHomePageShowsCurrent => '首頁顯示目前實例。點「切換實例」可以在裝好的實例之間切換，或者管理全部實例。';

  @override
  String get tourPlay => '開始遊戲';

  @override
  String get tourPickInstanceClickHere => '選好實例後點這裡啟動。第一次啟動會自動準備好需要的 Java。';

  @override
  String get tourInstanceSettings => '實例設定';

  @override
  String get tourEachInstancesModsWorlds => '每個實例的模組、存檔、資源包、光影、記憶體和 Java 都在這裡單獨管理，也可以直接給這個實例新增模組。';

  @override
  String get tourBackgroundTasks => '背景任務';

  @override
  String get tourDownloadsInstallsRunBackground => '下載和安裝都在背景進行，進度顯示在這裡，點開可以查看詳情或者取消。';

  @override
  String get tourMultiplayerLobbyLANTransfer => '聯機大廳、區域網路互傳、伺服器查詢、錯誤分析，還有皮膚、成就圖片這些小工具。';

  @override
  String get tourFileManagerYourPhone => '手機上的檔案管理器：直接管理遊戲資料夾裡的存檔、模組和截圖。';

  @override
  String get tourAskAIWhenSomething => '有問題可以問 AI，例如遊戲為什麼崩潰、該裝哪個模組。先在設定裡設定好模型就能用。';

  @override
  String get tourThemeBackgroundImageHome => '主題、背景圖片和首頁佈局在「個性化」裡；Java、記憶體和遊戲資料夾也在這裡調整。';

  @override
  String get tourHeadDownloadInstallInstance => '先去「下載」裝一個實例吧！這個教程可以在「設定 → 關於與致謝」裡再次開啟。';

  @override
  String get tourGetStarted => '開始使用';

  @override
  String get agreementDialogTermsUsePrivacyNotice => '使用者協議與隱私說明已更新';

  @override
  String get agreementDialogPleaseReadTermsUse =>
      '使用前請閱讀下面的使用者協議和隱私說明。簡單來說：本軟體免費開源，按原樣提供；我們不收集你的資訊，帳戶和設定都只儲存在你的裝置上；遊戲和模組來自第三方。';

  @override
  String get agreementDialogAcceptContinue => '同意並繼續';

  @override
  String get networkCheckPanelChecking => '檢測中…';

  @override
  String get networkCheckPanelCheckingUp8Seconds => '正在檢測，最多 8 秒';

  @override
  String get networkCheckPanelNeitherDownloadSourceCan => '兩個下載來源都連不上，請檢查網路或代理設定';

  @override
  String networkCheckPanelAutomaticWillPreferSwitch(Object mirror) {
    return '「自動選擇」會優先使用$mirror，失敗時自動換另一個';
  }

  @override
  String get networkCheckPanelBMCLAPIMirror => ' BMCLAPI 鏡像';

  @override
  String networkCheckPanelOtherConnectionsFailedRelated(num failed) {
    return '有 $failed 項連線失敗，相關功能可能用不了';
  }

  @override
  String get networkCheckPanelCheckAgain => '重新檢測';

  @override
  String get networkCheckPanelLauncherUpdates => '啟動器更新';

  @override
  String get networkCheckPanelCheckingUp8Seconds2 => '檢測中，最多 8 秒';

  @override
  String get networkCheckPanelAllGood => '全部正常';

  @override
  String get networkCheckPanelConnectionFailed => '連線失敗';

  @override
  String get storageLocationPhoneStoragePixelWorld =>
      '放在手機儲存空間（Pixel World/.minecraft）：解除安裝或重裝啟動器後遊戲、存檔仍然保留，也可以用其他應用管理這些檔案。需要授予「所有檔案存取權限」。\n\n放在應用內部：不需要權限，但解除安裝啟動器時遊戲、存檔會一起被刪除。\n\n之後可以在「設定 → 遊戲管理」中更改。';

  @override
  String get storageLocationPhoneStorageRecommended => '手機儲存空間（推薦）';

  @override
  String get storageLocationAllFilesAccessWasnt => '沒有獲得「所有檔案存取權限」，遊戲資料夾沒有更改';

  @override
  String get storageLocationMoveGameFiles => '移動遊戲檔案';

  @override
  String storageLocationMoveInstancesWorldsResources(Object from, Object to) {
    return '把現在遊戲資料夾中的實例、存檔與資源移到新位置嗎？\n\n$from\n→ $to';
  }

  @override
  String get storageLocationJustSwitchDontMove => '只切換，不移動';

  @override
  String get storageLocationMove => '移動';

  @override
  String storageLocationGameFolderChanged(Object to) {
    return '遊戲資料夾已更改為 $to';
  }

  @override
  String get storageLocationMovingGameFiles => '正在移動遊戲檔案';

  @override
  String get storageLocationMoveFailed => '移動失敗';

  @override
  String storageLocationFilesWereAlreadyMoved(Object error) {
    return '$error\n\n已經移動的檔案在新位置，其餘檔案仍在原位置。';
  }

  @override
  String get storageLocationCountingFiles => '正在統計檔案…';

  @override
  String storageLocationFilesPleaseDontClose(Object done, Object total) {
    return '$done / $total 個檔案，請不要關閉啟動器';
  }

  @override
  String get storageLocationCurrentGameFolder => '目前遊戲資料夾';

  @override
  String get storageLocationChange => '更改';

  @override
  String get storageLocationStorageLocation => '存放位置';

  @override
  String get storageLocationPhoneStorageKeptWhen => '手機儲存空間：解除安裝啟動器後仍然保留';

  @override
  String get storageLocationAppStorageDeletedWhen => '應用內部：解除安裝啟動器時會一起刪除，建議移到手機儲存空間';

  @override
  String get storageLocationMaintenance => '維護';

  @override
  String get commonCleanUpGameJunk => '清理遊戲垃圾';

  @override
  String get storageLocationDeletesLogsCrashReports => '刪除日誌、崩潰報告與解壓出的本機庫，不影響存檔和模組';

  @override
  String get commonCleanUp => '清理';

  @override
  String get storageLocationFileManager => '檔案管理';

  @override
  String get storageLocationBrowseImportCopyDelete => '瀏覽、匯入、複製或刪除遊戲檔案；刪除的檔案會先放進資源回收筒';

  @override
  String get launchDialogsJavaVersionMayIncompatible => 'Java 版本可能不相容';

  @override
  String launchDialogsYouCanChangeJava(Object message) {
    return '$message\n\n可以在實例設定中把 Java 改為 Java 8 或自動選擇。';
  }

  @override
  String get launchDialogsLaunchAnyway => '仍然啟動';

  @override
  String launchDialogsOtherTimes(num launchCount) {
    return '已經啟動 $launchCount 次遊戲啦';
  }

  @override
  String launchDialogsMaintainedIfYouFind(Object name, Object authorName) {
    return '$name 由 $authorName 維護。如果覺得好用，能否考慮贊助一下作者？\n\n本專案免費、沒有廣告，離不開大家的支援。';
  }

  @override
  String get launchDialogsMaybeLater => '下次再說';

  @override
  String launchDialogsSignAgain(Object serverName) {
    return '重新登入 $serverName';
  }

  @override
  String launchDialogsSignHasExpiredEnter(Object name, Object login) {
    return '$name（$login）的登入已失效，請輸入密碼繼續啟動。';
  }

  @override
  String get commonPassword => '密碼';

  @override
  String get launchDialogsCancelLaunch => '取消啟動';

  @override
  String get commonSign => '登入';

  @override
  String updateDialogYoureLatestVersion(Object label) {
    return '已是最新版本（$label）';
  }

  @override
  String updateDialogCouldntCheckUpdates(Object error) {
    return '檢查更新失敗：$error';
  }

  @override
  String updateDialogNewVersionAvailable(Object label) {
    return '發現新版本：$label';
  }

  @override
  String updateDialogCurrentVersion(Object current, Object prerelease, Object date) {
    return '目前版本 $current · $prerelease$date';
  }

  @override
  String updateDialogReleased(Object date) {
    return ' · 發布於 $date';
  }

  @override
  String get updateDialogNoReleaseNotes => '沒有更新說明';

  @override
  String get updateDialogNoPackageHasBeen => '這個平台還沒有發布包，請到 GitHub 查看。';

  @override
  String get updateDialogReleaseHasNoFile => '這個發布中沒有適用於目前平台的檔案。';

  @override
  String get updateDialogAfterDownloadingInstallerImage => '下載後會開啟安裝鏡像，把 Pixel World 拖進「應用程式」資料夾替換舊版本即可；遊戲檔案不受影響。';

  @override
  String get updateDialogAfterDownloadingSystemInstalls => '下載後由系統安裝，需要在彈出的介面中確認；遊戲檔案不受影響。';

  @override
  String get updateDialogDownloading => '正在下載';

  @override
  String updateDialogDownloading2(Object progress) {
    return '正在下載 $progress%';
  }

  @override
  String get updateDialogInstallerHasBeenDownloaded => '安裝包已經下載完成。第一次安裝需要在系統設定中允許「安裝未知應用」；允許後回到這裡點「繼續安裝」，不需要重新下載。';

  @override
  String get updateDialogSkipVersion => '跳過這個版本';

  @override
  String get updateDialogViewGitHub => '在 GitHub 查看';

  @override
  String get updateDialogLater => '稍後';

  @override
  String get updateDialogContinueInstall => '繼續安裝';

  @override
  String get updateDialogUpdateRestart => '更新並重啟';

  @override
  String get updateDialogDownloadInstall => '下載並安裝';

  @override
  String get pclImportDialogImportComplete => '匯入完成';

  @override
  String pclImportDialogSettings(Object settings) {
    return '設定：$settings';
  }

  @override
  String pclImportDialogAddedGameFoldersAccounts(Object folders, Object accounts) {
    return '新增遊戲資料夾 $folders 個，帳戶 $accounts 個';
  }

  @override
  String pclImportDialogNotImported(Object skippedAccounts) {
    return '未匯入：$skippedAccounts';
  }

  @override
  String pclImportDialogFoundPCLCEConfiguration(Object folders, Object hasAccounts) {
    return '檢測到 PCL-CE 的設定：$folders 個遊戲資料夾$hasAccounts';
  }

  @override
  String get pclImportDialogAccounts => '，有帳戶';

  @override
  String get pclImportDialogNoPCLCEConfiguration => '沒有在 %APPDATA%\\PCLCE 找到 PCL-CE 的設定，可以選擇 PCL-CE 所在目錄匯入本機設定';

  @override
  String get pclImportDialogPerInstanceSettingsDont => '實例獨立設定無需匯入，兩者直接共用。';

  @override
  String get pclImportDialogLaunchSettings => '啟動設定';

  @override
  String get pclImportDialogMemoryJVMArgumentsMore => '記憶體、JVM 參數等需要選擇 PCL-CE 所在目錄';

  @override
  String get pclImportDialogImportedMicrosoftAccountsNeed => '匯入的微軟帳戶過期後需要在這裡重新登入';

  @override
  String get pclImportDialogPCLCEFolderNot => 'PCL-CE 所在目錄：未選擇（可選）';

  @override
  String pclImportDialogPCLCEFolder(Object pclDir) {
    return 'PCL-CE 所在目錄：$pclDir';
  }

  @override
  String get commonChoose => '選擇';

  @override
  String get yggdrasilLoginDialogAuthenticationServerAddress => '驗證伺服器位址';

  @override
  String get yggdrasilLoginDialogEnterAddressPickOne => '輸入位址，或從列表中選擇';

  @override
  String get yggdrasilLoginDialogChooseProfile => '選擇角色';

  @override
  String yggdrasilLoginDialogAuthenticationServer(Object server) {
    return '驗證伺服器：$server';
  }

  @override
  String get yggdrasilLoginDialogAddressIsntEncryptedYour => '這個位址沒有加密，密碼會以明文傳輸';

  @override
  String get yggdrasilLoginDialogEmailUsername => '郵箱或使用者名';

  @override
  String get yggdrasilLoginDialogPasswordSign => '帳戶密碼登入';

  @override
  String get yggdrasilLoginDialogOAuthAuthorization => 'OAuth 授權';

  @override
  String get yggdrasilLoginDialogAccountPassword => '帳戶密碼';

  @override
  String yggdrasilLoginDialogClickingStartOpensAuthorization(Object site) {
    return '點擊開始後會在瀏覽器中開啟 $site 的授權頁面，確認授權並選擇角色即可，啟動器不會接觸你的密碼。';
  }

  @override
  String get yggdrasilLoginDialogStartOAuthSign => '開始 OAuth 登入';

  @override
  String get accountsDialogNoAccountsYet => '還沒有帳戶';

  @override
  String get accountsDialogAddOfflineAccount => '新增離線帳戶';

  @override
  String get accountsDialogUsername => '使用者名';

  @override
  String get accountsDialogMicrosoftAccounts => '正版帳戶';

  @override
  String get accountsDialogMicrosoftSignNeedsAzure => '微軟登入需要先在「設定 - 其他」中填寫 Azure 應用 Client ID。';

  @override
  String get accountsDialogThirdPartyAccounts => '第三方帳戶';

  @override
  String get maintenanceActionsNothingCleanUp => '沒有需要清理的檔案';

  @override
  String maintenanceActionsItemsWillDeletedLogs(Object count, Object size) {
    return '將刪除 $count 項，共 $size：\n遊戲資料夾與各實例資料夾中的日誌（logs、*.log）、崩潰報告（crash-reports、hs_err_pid*）與解壓出的本機庫（natives，啟動時會重新生成）。\n\n存檔、模組與設定不會被刪除。';
  }

  @override
  String maintenanceActionsCleanedUp(Object size) {
    return '已清理 $size';
  }

  @override
  String maintenanceActionsOtherItemsUseWerent(num failed) {
    return '已清理，$failed 項正在被使用，沒有刪除';
  }

  @override
  String maintenanceActionsCreated(Object path) {
    return '已建立 $path';
  }

  @override
  String get fileViewerFileDoesntExist => '檔案不存在';

  @override
  String get fileViewerPreview => '預覽';

  @override
  String get fileViewerSource => '源碼';

  @override
  String get fileViewerRefresh => '重新整理';

  @override
  String get fileViewerCopyAll => '複製全文';

  @override
  String get fileViewerCopied => '已複製';

  @override
  String get fileViewerShowFileManager => '在檔案管理器中開啟';

  @override
  String fileViewerCantOpen(Object error) {
    return '打不開：$error';
  }

  @override
  String get fileViewerFileIsntTextLarger => '這個檔案不是文字，或者超過 2 MB，不能在這裡查看';

  @override
  String get deviceStatusMobileData => '移動資料';

  @override
  String get deviceStatusEthernet => '有線網路';

  @override
  String get deviceStatusConnected => '已聯網';

  @override
  String get deviceStatusOffline => '未聯網';

  @override
  String get deviceStatusFullyCharged => '已充滿';

  @override
  String get deviceStatusCharging => '正在充電';

  @override
  String get deviceStatusPlugged => '已接通電源';

  @override
  String get deviceStatusBattery => '電量';

  @override
  String deviceLoginDialogSignedAs(Object name) {
    return '已登入 $name';
  }

  @override
  String get deviceLoginDialogStartSign => '開始登入';

  @override
  String get deviceLoginDialogRetry => '重試';

  @override
  String get deviceLoginDialogAuthorizationPageHasOpened => '已在瀏覽器中開啟授權頁面，請確認頁面上的程式碼與下面一致後完成授權：';

  @override
  String get deviceLoginDialogSignPageHasOpened => '已在瀏覽器中開啟登入頁面，請輸入下面的程式碼（已複製到剪貼簿）：';

  @override
  String get deviceLoginDialogResumed => '接著完成上次的登入：在瀏覽器裡用下面的代碼完成授權後回到啟動器，會自動登入。授權頁面關掉了可以點下面的連結重新打開：';

  @override
  String get deviceLoginDialogWaitingSign => '等待登入完成';

  @override
  String formatOtherYearsAgo(num inDays) {
    return '$inDays 年前';
  }

  @override
  String formatOtherMonthsAgo(num inDays) {
    return '$inDays 個月前';
  }

  @override
  String formatOtherDaysAgo(num inDays) {
    return '$inDays 天前';
  }

  @override
  String formatOtherHoursAgo(num inHours) {
    return '$inHours 小時前';
  }

  @override
  String get formatJustNow => '剛剛';

  @override
  String get themeColorDialogCustomThemeColor => '自訂主題色';

  @override
  String get themeColorDialogR => '紅';

  @override
  String get themeColorDialogG => '綠';

  @override
  String get themeColorDialogB => '藍';

  @override
  String get themeColorDialogUse => '使用';

  @override
  String homeCouldntLaunch(Object error) {
    return '啟動失敗：$error';
  }

  @override
  String homeCantOpenFolder(Object error) {
    return '打不開資料夾：$error';
  }

  @override
  String get homeRecentlyPlayed => '最近遊玩';

  @override
  String get homeAllWorlds => '全部存檔 ›';

  @override
  String homeOtherMinutesAgo(num inMinutes) {
    return '$inMinutes 分鐘前';
  }

  @override
  String homeMonthDay(Object month, Object day) {
    return '$month月$day日';
  }

  @override
  String get homeNoInstanceSelected => '還沒有選擇實例';

  @override
  String get homeInstallChooseInstanceFirst => '先安裝或選擇一個實例，準備好就開始';

  @override
  String get homeMore => '更多';

  @override
  String get homeOpenInstanceFolder => '開啟實例資料夾';

  @override
  String commonModCount(num data) {
    return '$data 個模組';
  }

  @override
  String homeRenderer(Object renderer) {
    return '$renderer 渲染';
  }

  @override
  String homePlayed(Object modified) {
    return '$modified玩過';
  }

  @override
  String get homeBackGame => '返回遊戲';

  @override
  String get commonStopGame => '結束遊戲';

  @override
  String get homeAddMods => '裝模組';

  @override
  String get homeManageMods => '管理模組';

  @override
  String get homeFolder => '資料夾';

  @override
  String get commonViewLog => '查看日誌';

  @override
  String get homeLauncherAnnouncements => '啟動器公告';

  @override
  String get homeLoading => '正在取得…';

  @override
  String get commonNoAnnouncements => '暫無公告';

  @override
  String get homeView => '查看 ›';

  @override
  String get homeSwitchInstanceWorld => '切換到這個存檔所在的實例';

  @override
  String get homeYourRecentWorldsWill => '開始一次遊戲後，最近的存檔會出現在這裡。';

  @override
  String get homeScrollDownMore => '向下滾動查看更多';

  @override
  String get homeSwipeUpMore => '上滑查看更多';

  @override
  String get homeInstallChooseInstanceFirst2 => '先安裝或選擇一個實例';

  @override
  String get homeNoRecentlyPlayedWorlds => '還沒有最近遊玩的存檔';

  @override
  String get homeAllWorlds2 => '全部存檔';

  @override
  String get homeOpenFolder => '開啟資料夾';

  @override
  String get homeCurrentInstance => '目前實例';

  @override
  String get homeInstanceSettings => '實例設定 ›';

  @override
  String get homeType => '類型';

  @override
  String get homeMods => '模組';

  @override
  String get homeVanillaNoMods => '原版，不載入模組';

  @override
  String homeModCountValue(Object data) {
    return '$data 個';
  }

  @override
  String get homeNotPlayedYet => '還沒玩過';

  @override
  String get homeInstanceID => '實例 ID';

  @override
  String get homeManageAllInstances => '管理全部實例';

  @override
  String homeFeedYoureUsingBetaThird(Object name, Object version) {
    return '你正在使用 $name $version 測試版。這是第三方 Minecraft 啟動器，功能還在完善中，遇到問題請到 GitHub 反饋。';
  }

  @override
  String get homeFeedReportProblem => '反饋問題';

  @override
  String get homeFeedSoftwareCompletelyFreeOpen => '本軟體完全免費、開源。如果你是付費購買或下載的，那麼你可能被騙了，請向賣家申請退款，並從 GitHub 取得正版。';

  @override
  String get homeFeedGetGenuineVersion => '取得正版';

  @override
  String homeFeedBetaThatsStillBeing(Object name, Object version) {
    return '$name $version 測試版，功能還在完善中，遇到問題請到 GitHub 反饋。';
  }

  @override
  String get homeFeedSoftwareCompletelyFreeOpen2 => '本軟體完全免費、開源。如果你是付費獲得的，請向賣家申請退款，並從 GitHub 取得正版。';

  @override
  String get homeFeedHideBetaNoticeFree => '關閉測試版提示（免費聲明會保留）';

  @override
  String homeFeedChangelogV(Object version, Object channel) {
    return '更新日誌 · v$version$channel';
  }

  @override
  String get homeFeedCollapse => '收起';

  @override
  String get homeFeedExpand => '展開';

  @override
  String get homeFeedLoadingAnnouncements => '正在取得公告…';

  @override
  String get homeFeedViewDetails => '查看詳情';

  @override
  String get homeFeedMinecraftVersionNews => 'Minecraft 版本動態';

  @override
  String get homeFeedFromMinecraftWiki => '來自 Minecraft Wiki';

  @override
  String homeFeedCouldntLoad(Object error) {
    return '載入失敗：$error';
  }

  @override
  String get homeFeedSnapshot => '快照';

  @override
  String get homeFeedMinecraftWikiDoesntHave => 'Minecraft Wiki 還沒有這個版本的介紹，點擊查看頁面。';

  @override
  String get versionsCurrentFolder => '目前資料夾';

  @override
  String get versionsOfficialLauncherFolder => '官方啟動器資料夾';

  @override
  String get versionsLauncherDefaultFolder => '啟動器預設資料夾';

  @override
  String get versionsRemoveFromListFiles => '從列表移除（不會刪除檔案）';

  @override
  String get versionsAddFolder => '新增資料夾';

  @override
  String get versionsNoInstancesFolderYet => '這個資料夾中還沒有實例';

  @override
  String versionsOtherInstances(num count) {
    return '$count 個實例';
  }

  @override
  String get versionsNewInstance => '新建實例';

  @override
  String get versionsSearchInstances => '搜尋實例';

  @override
  String get versionsNoMatchingInstances => '沒有符合條件的實例';

  @override
  String tasksProgress(Object count) {
    return '$count 個進行中';
  }

  @override
  String get tasksClearFinishedTasks => '清除已結束的任務';

  @override
  String get tasksNoTasksYetInstalling => '還沒有任務。安裝實例、下載資源或啟動遊戲時會顯示在這裡';

  @override
  String tasksMinS(Object inMinutes, Object inSeconds) {
    return '$inMinutes 分 $inSeconds 秒';
  }

  @override
  String tasksS(Object inSeconds) {
    return '$inSeconds 秒';
  }

  @override
  String get tasksCanceling => '正在中斷';

  @override
  String get tasksProgress2 => '進行中';

  @override
  String get tasksCompleted => '已完成';

  @override
  String get tasksFailed => '失敗';

  @override
  String get tasksCanceled => '已中斷';

  @override
  String get tasksCanceling2 => '中斷中…';

  @override
  String get tasksCancel => '中斷';

  @override
  String get tasksCopyLog => '複製日誌';

  @override
  String get commonLogCopied => '已複製日誌';

  @override
  String get logGameRunning => '遊戲執行中';

  @override
  String get logStarting => '正在啟動';

  @override
  String get logGameNotRunning => '遊戲未執行';

  @override
  String logGameExitedCode(Object lastExitCode) {
    return '遊戲已退出，程式碼 $lastExitCode';
  }

  @override
  String get logAutoScroll => '自動滾動';

  @override
  String get logCopyAll => '複製全部';

  @override
  String get logLogWillAppearHere => '啟動遊戲後，日誌會顯示在這裡';

  @override
  String get diagnoseGameCrashed => '遊戲崩潰了';

  @override
  String diagnoseExitedAbnormally(Object title) {
    return '$title 非正常退出。';
  }

  @override
  String get diagnoseNoKnownProblemMatched => '沒有匹配到已知的問題，可以查看日誌，或使用 AI 分析。';

  @override
  String get diagnoseAIAnalysis => 'AI 分析';

  @override
  String get diagnoseNothingAnalyze => '沒有要分析的內容';

  @override
  String get diagnoseEnvironment => '環境';

  @override
  String get diagnoseInitialFindings => '初步判斷';

  @override
  String get diagnoseNoKnownProblemMatched2 => '沒有匹配到已知的問題';

  @override
  String get diagnoseUseAIAnalysisBelow => '可以使用下面的 AI 分析，或查看日誌摘錄自行判斷';

  @override
  String get diagnoseExistingAIConversation => '已有 AI 對話';

  @override
  String get diagnoseAnalyzeAI => '用 AI 分析';

  @override
  String get diagnoseContinueCrashsConversationAI => '在 AI 頁面繼續這次崩潰的對話';

  @override
  String diagnoseStartsNewConversationSends(Object host, Object model) {
    return '新建一個對話，把下面的日誌摘錄與環境資訊傳送給 $host（$model）';
  }

  @override
  String get diagnoseAnalyzeLogYourOwn => '使用你自己的 AI 服務分析日誌，需要先填寫介面位址、模型和 API Key';

  @override
  String get diagnoseViewConversation => '查看對話';

  @override
  String get diagnoseLogExcerpt => '日誌摘錄';

  @override
  String get diagnoseNoLogsFound => '沒有找到日誌';

  @override
  String diagnoseCharactersTrimmedPrivateInformation(Object count) {
    return '$count 個字元，已截取並去除隱私資訊';
  }

  @override
  String get diagnoseModList => '模組列表';

  @override
  String diagnoseOtherEnabledMods(num count) {
    return '$count 個已啟用的模組';
  }

  @override
  String get docsFromPixelworldZhuzhiSite => '來自 pixelworld.paperzhu.com · 斷網時顯示最近一次快取';

  @override
  String get docsOpenBrowser => '在瀏覽器開啟';

  @override
  String get instanceInstanceNoLongerExists => '這個實例已不存在';

  @override
  String get instanceWorlds => '存檔';

  @override
  String get commonResourcePacks => '資源包';

  @override
  String get commonShaders => '光影';

  @override
  String get instanceScreenshots => '截圖';

  @override
  String get instanceSchematics => '投影';

  @override
  String get instanceServers => '伺服器';

  @override
  String get instanceOverview => '概覽';

  @override
  String get instanceChangeIcon => '更換圖示';

  @override
  String instanceCouldntChangeIcon(Object error) {
    return '更換圖示失敗：$error';
  }

  @override
  String get instanceChangeIcon2 => '更換圖示…';

  @override
  String get instanceRestoreDefaultIcon => '恢復預設圖示';

  @override
  String instanceBackList(Object label) {
    return '返回$label列表';
  }

  @override
  String instanceDelete(Object id) {
    return '刪除 $id？';
  }

  @override
  String get instanceInstanceFolderWillMoved => '實例資料夾會移到資源回收筒。開啟實例隔離時，其中的存檔和模組也會一併刪除。';

  @override
  String instanceDeleted(Object id) {
    return '已刪除 $id';
  }

  @override
  String get instanceSetAsCurrentInstance => '設為目前實例';

  @override
  String get commonGameVersion => '遊戲版本';

  @override
  String get instanceDecidedAtFirstLaunch => '首次啟動時決定';

  @override
  String get instanceText => '已開啟';

  @override
  String get instanceOff => '已關閉';

  @override
  String get instanceWorkingDirectory => '執行目錄';

  @override
  String get instanceReleaseDate => '發布時間';

  @override
  String get instanceShortcuts => '捷徑';

  @override
  String get instanceInstanceFolder => '實例資料夾';

  @override
  String instanceFolder(Object label) {
    return '$label資料夾';
  }

  @override
  String get instanceManage => '管理';

  @override
  String get instanceSendInstance => '傳送這個實例';

  @override
  String get instanceSendWholeInstanceAnother => '透過區域網路把整個實例傳到另一台裝置';

  @override
  String get instanceSend => '傳送';

  @override
  String get instanceDeleteInstance => '刪除這個實例';

  @override
  String get instanceMovesRecycleBinIf => '移到資源回收筒；開啟實例隔離時，其中的存檔和模組也會一併刪除';

  @override
  String get instanceUseGlobalSetting => '跟隨全局設定';

  @override
  String instanceNotInstalled(Object javaKey) {
    return '$javaKey（未安裝）';
  }

  @override
  String get instanceChooseManually => '手動選擇…';

  @override
  String get instanceTheseSettingsStoredPCL => '這些設定儲存在實例資料夾的 PCL/config.v1.yml 中，與 PCL-CE 互通';

  @override
  String instanceNotDecidedYetSet(Object isolationMode) {
    return '尚未決定：首次啟動時按全局策略「$isolationMode」決定，之後固定';
  }

  @override
  String get instanceWorkingDirectoryInstanceFolder => '執行目錄為實例資料夾';

  @override
  String get instanceText2 => '開啟';

  @override
  String instanceGlobal(Object javaPath) {
    return '跟隨全局：$javaPath';
  }

  @override
  String instanceGlobalSetting(Object androidRenderer) {
    return '跟隨全局設定「$androidRenderer」';
  }

  @override
  String instanceGlobalCustomGB(Object memoryTick) {
    return '跟隨全局：自訂 $memoryTick GB';
  }

  @override
  String get instanceGlobalAutomatic => '跟隨全局：自動分配';

  @override
  String get instanceGlobal2 => '跟隨全局';

  @override
  String get instanceMaximumMemory => '最大記憶體';

  @override
  String get instanceInitialMemory => '初始記憶體';

  @override
  String get instanceNotSet => '不設定';

  @override
  String get instanceJoinServerAutomatically => '自動進入伺服器';

  @override
  String get instanceLeaveEmptyUseGlobal => '留空則使用全局設定';

  @override
  String instanceMovedRecycleBin(Object name) {
    return '已將 $name 移到資源回收筒';
  }

  @override
  String instanceTotalEnabled(Object count, Object enabledMods) {
    return '$count 個，已啟用 $enabledMods 個';
  }

  @override
  String instanceItemCount(Object count) {
    return '$count 個';
  }

  @override
  String get instanceFilter => '篩選';

  @override
  String get instanceSendWorld => '傳送存檔';

  @override
  String instanceAdd(Object label) {
    return '新增$label';
  }

  @override
  String get instanceAddOptiFine => '新增 OptiFine';

  @override
  String instanceNoHereYet(Object label) {
    return '這裡還沒有$label';
  }

  @override
  String get instanceDisabled => ' · 已停用';

  @override
  String get instanceMoveRecycleBin => '移到資源回收筒';

  @override
  String get instanceServersSavedGameMultiplayer => '遊戲內多人遊戲列表中儲存的伺服器（servers.dat）';

  @override
  String get instanceNoSavedServersYet => '還沒有儲存的伺服器';

  @override
  String get instanceCantConnect => '無法連線';

  @override
  String instanceOnlineMs(Object online, Object max, Object latency) {
    return '線上 $online/$max · $latency ms';
  }

  @override
  String instanceCouldntGetOptiFineVersions(Object error) {
    return '取得 OptiFine 版本失敗：$error';
  }

  @override
  String instanceNoOptiFineCompatibleForge(Object gameVersion) {
    return '沒有與 Forge 相容的 OptiFine（$gameVersion）';
  }

  @override
  String instanceNoOptiFineAvailable(Object gameVersion) {
    return '$gameVersion 沒有可用的 OptiFine';
  }

  @override
  String get commonOptiFineVersion => 'OptiFine 版本';

  @override
  String get commonPreview => '（預覽版）';

  @override
  String commonRequiresForge(Object requiredForge) {
    return ' · 需要 Forge $requiredForge';
  }

  @override
  String get downloadModpacks => '整合包';

  @override
  String get downloadDataPacks => '資料包';

  @override
  String get commonFavorites => '收藏';

  @override
  String get downloadOldVersions => '遠古版';

  @override
  String get downloadAprilFools => '愚人節';

  @override
  String downloadCouldntGetVersionList(Object error) {
    return '取得版本列表失敗：$error';
  }

  @override
  String get downloadLoadingVersionList => '正在取得版本列表…';

  @override
  String get downloadSearchVersions => '搜尋版本號';

  @override
  String get downloadNoMatchingVersions => '沒有符合條件的版本';

  @override
  String get downloadLatest => '最新';

  @override
  String get downloadInstalled => '已安裝';

  @override
  String get downloadChooseVersionLeft => '選擇左邊的版本';

  @override
  String get downloadPlainMinecraft => '純淨的 Minecraft';

  @override
  String get downloadOldestLoaderMostMods => '歷史最久、模組最多的載入器';

  @override
  String get downloadCommunityForkForgeAvailable => '從 Forge 分出的社區版，1.20.1 起可用';

  @override
  String get downloadModernized1122 => '基於 Forge 的 1.12.2 現代化分支，需要 Java 21';

  @override
  String get downloadAllOneClientLots => '自帶大量功能的整合客戶端（LabyMod 4）';

  @override
  String get downloadLightweightFastUpdatingMod => '輕量、更新快的模組載入器';

  @override
  String get downloadCompatibleMostFabricMods => '相容大部分 Fabric 模組';

  @override
  String get downloadFabricPorted113 => '為 1.13.2 及更早版本移植的 Fabric';

  @override
  String get downloadLightweightLoader112 => '1.12.2 及更早版本的輕量載入器';

  @override
  String get downloadInstallationStartedSeeBackground => '已開始安裝，進度見頂欄的背景任務';

  @override
  String downloadInstalled2(Object id) {
    return '$id 安裝完成';
  }

  @override
  String get commonTaskCanceled => '任務已中斷';

  @override
  String commonInstallationFailed(Object error) {
    return '安裝失敗：$error';
  }

  @override
  String downloadIsntSupported(Object id) {
    return '不支援 $id';
  }

  @override
  String get downloadNone => '不加裝';

  @override
  String downloadInstall(Object id) {
    return '安裝 $id';
  }

  @override
  String downloadLoadingLoaders(Object count, Object count2) {
    return '正在取得載入器 $count/$count2';
  }

  @override
  String get downloadInstanceName => '實例名稱';

  @override
  String downloadInstancesAlreadyInstalledInstalls(Object same, Object id) {
    return '已經有 $same 個 $id 的實例；這次會再裝一個獨立的實例，存檔和模組互不影響';
  }

  @override
  String get downloadVanilla => '原版';

  @override
  String downloadVersion(Object label) {
    return '$label 版本';
  }

  @override
  String downloadBeta(Object label) {
    return '$label（測試版）';
  }

  @override
  String get downloadInstallOptiFineToo => '同時安裝 OptiFine';

  @override
  String get downloadLoadingOptiFineVersions => '正在取得 OptiFine 版本…';

  @override
  String downloadCantInstalledTogetherOptiFine(Object label) {
    return '$label 不支援與 OptiFine 一起安裝';
  }

  @override
  String get downloadNoOptiFineCompatibleForge => '沒有與 Forge 相容的 OptiFine';

  @override
  String get downloadNoOptiFineVersion => '該版本沒有 OptiFine';

  @override
  String get downloadSelectedForgeDiffersFrom => '目前選擇的 Forge 與 OptiFine 要求的版本不同，較新的 Forge 可能與它不相容';

  @override
  String downloadInstallAs(Object text) {
    return '安裝為 $text';
  }

  @override
  String get commonInstall => '安裝';

  @override
  String get resourcesModrinthModpacks => 'Modrinth 整合包';

  @override
  String resourcesInstalledModpackAs(Object id) {
    return '已安裝整合包為 $id';
  }

  @override
  String resourcesAddingOnlyCompatibleShown(Object id, Object label, Object gameVersion) {
    return '正在為 $id 新增$label · 只顯示適配 $gameVersion 的$label，安裝時直接裝進這個實例';
  }

  @override
  String get resourcesBrowseNormally => '改為普通瀏覽';

  @override
  String resourcesSearchModrinth(Object label) {
    return '在 Modrinth 搜尋$label';
  }

  @override
  String resourcesText(Object id) {
    return '適配 $id';
  }

  @override
  String get resourcesSort => '排序';

  @override
  String get resourcesRelevance => '相關性';

  @override
  String get resourcesDownloads => '下載量';

  @override
  String get resourcesFollows => '關注數';

  @override
  String get resourcesNewest => '最新發布';

  @override
  String get resourcesRecentlyUpdated => '最近更新';

  @override
  String resourcesSort2(Object sort) {
    return '排序 $sort';
  }

  @override
  String get resourcesInstallFromFile => '從檔案安裝';

  @override
  String get resourcesNoResults => '沒有找到結果';

  @override
  String get resourcesLoadMore => '載入更多';

  @override
  String get resourcesRemoveFromFavorites => '取消收藏';

  @override
  String get resourcesNoInstancesInstalledYet => '還沒有安裝任何實例';

  @override
  String resourcesHasNoModLoader(Object id) {
    return '$id 沒有安裝模組載入器，模組不會生效';
  }

  @override
  String resourcesHasNoWorldsYet(Object id) {
    return '$id 還沒有存檔，請先進入遊戲建立一個世界';
  }

  @override
  String resourcesInstalledFiles(Object count) {
    return '已安裝 $count 個檔案';
  }

  @override
  String resourcesAlreadyPresent(Object count) {
    return '$count 個已存在';
  }

  @override
  String resourcesNoCompatibleDependencyFound(Object missing) {
    return '找不到相容的前置：$missing';
  }

  @override
  String resourcesDownloads2(Object author, Object label, Object downloads, Object updated) {
    return '$author · $label · $downloads 次下載$updated';
  }

  @override
  String resourcesUpdated(Object updated) {
    return ' · 更新於 $updated';
  }

  @override
  String get resourcesViewModrinth => '在 Modrinth 查看';

  @override
  String resourcesInstall(Object target) {
    return '安裝到 $target';
  }

  @override
  String get resourcesInstall2 => '安裝到';

  @override
  String get resourcesWillInstalledAsNew => '將安裝為新的實例';

  @override
  String get resourcesWorld => '世界';

  @override
  String get resourcesShowAllFiles => '顯示全部檔案';

  @override
  String get resourcesNoFilesAvailable => '沒有可用的檔案';

  @override
  String resourcesNoFilesYouCan(Object gameVersion) {
    return '沒有適配 $gameVersion 的檔案，可以開啟「顯示全部檔案」';
  }

  @override
  String get resourcesRelease => '正式';

  @override
  String resourcesVersions(Object list, Object list2, Object count) {
    return '$list ~ $list2（$count 個版本）';
  }

  @override
  String get resourcesFavorites => '收藏夾';

  @override
  String get resourcesNoFavoritesYetClick => '還沒有收藏，點擊資源右側的心形圖示即可收藏';

  @override
  String get toolsMultiplayer => '聯機';

  @override
  String get toolsLANTransfer => '區域網路互傳';

  @override
  String get toolsSendModsWorldsWhole => '在兩台裝置之間傳模組、存檔、整個實例';

  @override
  String get toolsServerLookup => '伺服器查詢';

  @override
  String get toolsCheckServersPlayerCount => '查詢伺服器線上人數和延遲';

  @override
  String get toolsMultiplayerLobby => '聯機大廳';

  @override
  String get toolsPlanned => '規劃中';

  @override
  String get toolsTroubleshooting => '排錯';

  @override
  String get toolsReadLogsFindCause => '查看日誌，自動找出崩潰原因';

  @override
  String get toolsUtilities => '實用';

  @override
  String get toolsCustomDownload => '自訂下載';

  @override
  String get toolsDownloadFileFromLink => '按連結下載檔案到指定位置';

  @override
  String get toolsFun => '趣味';

  @override
  String get toolsSkinsAvatars => '皮膚與頭像';

  @override
  String get toolsViewDownloadMinecraftPlayers => '查看和下載正版玩家的皮膚';

  @override
  String get toolsAchievementImage => '成就圖片';

  @override
  String get toolsMakeCustomAchievementToast => '生成自訂的成就彈出視窗圖片';

  @override
  String get toolsTodaysLuck => '今日人品';

  @override
  String get toolsSeeHowLuckyYou => '看看今天的運氣，每人每天固定';

  @override
  String get toolsBackTools => '返回工具';

  @override
  String get toolsPNGImage => 'PNG 圖片';

  @override
  String get toolsLetsFewPlayersForm => '讓幾位玩家組成虛擬區域網路一起遊戲，正在規劃中';

  @override
  String get toolsNoGameHasBeen => '本次開啟啟動器後還沒有啟動過遊戲';

  @override
  String get toolsLog => '日誌';

  @override
  String get toolsEmpty => '內容為空';

  @override
  String get toolsPasteLog => '貼上日誌';

  @override
  String get toolsPasteCrashReportLog => '貼上崩潰報告或日誌內容';

  @override
  String get toolsAnalyze => '分析';

  @override
  String get toolsPastedLog => '貼上的日誌';

  @override
  String get toolsLastGame => '最近一次遊戲';

  @override
  String get toolsAnalyzeMostRecentGame => '分析本次開啟啟動器後最近一次執行的遊戲';

  @override
  String get toolsLogFile => '日誌檔案';

  @override
  String get toolsChooseCrashReportCrash => '選擇崩潰報告（crash-reports）或日誌檔案（logs）';

  @override
  String get toolsPasteCrashReportLog2 => '貼上別人發給你的崩潰報告或日誌';

  @override
  String get toolsPaste => '貼上';

  @override
  String get toolsLauncherFirstMatchesCommon => '啟動器先用本機規則匹配常見問題；在「設定 → AI 排障」填寫自己的 AI 服務後，還可以讓 AI 分析日誌。遊戲崩潰時會自動彈出提示。';

  @override
  String get toolsPlayer => '玩家';

  @override
  String toolsSLuckToday(Object name) {
    return '$name 的今日人品';
  }

  @override
  String get toolsFixedEachPlayerEach => '每人每天固定';

  @override
  String get toolsLaunchCount => '啟動次數';

  @override
  String toolsYouveLaunchedGameTimes(num launchCount) {
    return '已經透過啟動器啟動了 $launchCount 次遊戲';
  }

  @override
  String get toolsSave => '儲存到';

  @override
  String toolsDownload(Object name) {
    return '下載 $name';
  }

  @override
  String toolsDownloadFailed(Object error) {
    return '下載失敗：$error';
  }

  @override
  String get toolsDownloadAnyFileProgress => '下載任意檔案，進度顯示在任務頁';

  @override
  String get toolsDownloadURL => '下載位址';

  @override
  String get toolsFileNameOptional => '檔案名（可選）';

  @override
  String get toolsSaveLocationChosenWhen => '儲存位置：開始下載時選擇';

  @override
  String toolsSaveLocation(Object dir) {
    return '儲存位置：$dir';
  }

  @override
  String get toolsStartDownload => '開始下載';

  @override
  String get toolsSkinImage => '皮膚圖片';

  @override
  String toolsSaved(Object path) {
    return '已儲存 $path';
  }

  @override
  String get toolsPlayerSkins => '正版皮膚';

  @override
  String get toolsMinecraftPlayerName => '正版玩家名';

  @override
  String get toolsGet => '取得';

  @override
  String get toolsAlexModelSlimArms => 'Alex 模型（細手臂）';

  @override
  String get toolsSteveModel => 'Steve 模型';

  @override
  String get toolsSaveSkin => '儲存皮膚';

  @override
  String get toolsAvatarMaker => '頭像生成';

  @override
  String get toolsCropsHeadHatLayer => '從皮膚截取頭部（含帽子層）並放大，可用上面取得的正版皮膚或本機皮膚檔案';

  @override
  String get toolsChooseLocalSkin => '選擇本機皮膚';

  @override
  String toolsLocal(Object localName) {
    return '本機：$localName';
  }

  @override
  String toolsSaveAvatar(Object size) {
    return '儲存 $size×$size 頭像';
  }

  @override
  String get toolsFetchPlayersSkinChoose => '先取得正版皮膚或選擇本機皮膚';

  @override
  String get toolsServerAddress => '伺服器位址';

  @override
  String get toolsMcExampleCom1 => 'mc.example.com 或 1.2.3.4:25565';

  @override
  String get toolsLookUp => '查詢';

  @override
  String toolsOnlineMsLatency(Object online, Object max, Object version, Object latency) {
    return '線上 $online / $max · $version · 延遲 $latency ms';
  }

  @override
  String get toolsAchievementGet => '獲得成就！';

  @override
  String get toolsFillTitleFirstLine => '請填寫標題和第一行文字';

  @override
  String get toolsMakesMinecraftStyleAchievement =>
      '生成 Minecraft 風格的成就提示圖片。優先由第三方服務 minecraft-api.com 生成（填寫的文字會傳送給它）；該服務拒絕請求時在本機繪制，本機繪制使用系統字型和你選擇的圖示';

  @override
  String get toolsItemIDOnline => '物品 ID（線上生成）';

  @override
  String get toolsEGDiamondGrass => '例如 diamond、grass、golden_apple';

  @override
  String get toolsIcon => '圖示';

  @override
  String get toolsIconLocalDrawing => '圖示（本機繪制）';

  @override
  String get toolsTitle => '標題';

  @override
  String get toolsFirstLine => '第一行';

  @override
  String get toolsSecondLineOptional => '第二行（可選）';

  @override
  String get toolsGenerate => '生成';

  @override
  String get toolsSaveImage => '儲存圖片';

  @override
  String get toolsOnlineServiceIsntAvailable => '線上服務不可用，以下為本機繪制';

  @override
  String get fileManagerSave => '儲存';

  @override
  String get fileManagerEnterValidFileName => '請填寫有效的檔案名';

  @override
  String get fileManagerFolderSameNameAlready => '已經有同名的資料夾';

  @override
  String get fileManagerReplaceExistingFile => '替換已有的檔案？';

  @override
  String fileManagerAlreadyExistsFolderSaving(Object name) {
    return '這個資料夾裡已經有「$name」，儲存後會替換它。';
  }

  @override
  String get fileManagerReplace => '替換';

  @override
  String get fileManagerName => '名稱';

  @override
  String get fileManagerOK => '確定';

  @override
  String get fileManagerNamesCantContain => '名稱不能包含 / 或 \\';

  @override
  String get fileManagerNewFolder => '新建資料夾';

  @override
  String get fileManagerFileFolderSameName => '已有同名的檔案或資料夾';

  @override
  String get fileManagerRename => '重命名';

  @override
  String get fileManagerDeletePermanently => '徹底刪除';

  @override
  String fileManagerWillPermanentlyDeletedCant(Object name) {
    return '「$name」會被徹底刪除，不能恢復。';
  }

  @override
  String fileManagerMovedRecycleBin(Object name) {
    return '「$name」已移到資源回收筒';
  }

  @override
  String get fileManagerCantPasteFolderInto => '不能把資料夾貼上到它自己裡面';

  @override
  String fileManagerPasting(Object done, Object total) {
    return '正在貼上（$done / $total）';
  }

  @override
  String get commonCopy => '複製';

  @override
  String fileManagerImportedFiles(num count) {
    return '已匯入 $count 個檔案';
  }

  @override
  String get fileManagerLargeFileOnlyFirst => '\n\n…（檔案較大，只顯示前 512 KB）';

  @override
  String fileManagerCantRead(Object error) {
    return '無法讀取：$error';
  }

  @override
  String get fileManagerKindFileCantPreviewed => '不能預覽這種檔案。可以複製、剪切、重命名或刪除';

  @override
  String get fileManagerAppData => '應用資料';

  @override
  String get fileManagerRecycleBin => '資源回收筒';

  @override
  String get fileManagerUp => '上一級';

  @override
  String get fileManagerImportFilesFromPhone => '從手機匯入檔案';

  @override
  String fileManagerOpenDestinationFolderPaste(Object cut, Object paths, Object length) {
    return '已$cut「$paths」$length，開啟目標資料夾後貼上';
  }

  @override
  String get fileManagerCut => '剪切';

  @override
  String fileManagerMore(Object count) {
    return ' 等 $count 項';
  }

  @override
  String get fileManagerPasteHere => '貼上到這裡';

  @override
  String fileManagerFolder(Object confirm) {
    return '$confirm這個資料夾';
  }

  @override
  String fileManagerTapFile(Object confirm) {
    return '點一個檔案來$confirm';
  }

  @override
  String fileManagerTapFile2(Object e, Object confirm) {
    return '點一個 $e 檔案來$confirm';
  }

  @override
  String get fileManagerFileName => '檔案名';

  @override
  String get fileManagerSaveHere => '儲存到這裡';

  @override
  String get fileManagerLocation => '位置';

  @override
  String get fileManagerChooseFolder => '選擇資料夾';

  @override
  String fileManagerChoose(Object label) {
    return '選擇$label';
  }

  @override
  String fileManagerSave2(Object label) {
    return '儲存$label';
  }

  @override
  String get fileManagerAccessingPhoneStorageRequires => '需要「所有檔案存取權限」才能存取手機儲存空間';

  @override
  String fileManagerCantOpenFolder(Object error) {
    return '無法開啟這個資料夾：$error';
  }

  @override
  String get fileManagerGrantPermission => '去授予權限';

  @override
  String get fileManagerEmptyFolder => '空資料夾';

  @override
  String get fileManagerMoreActions => '更多操作';

  @override
  String lanTransferReceivedFrom(Object from, Object version) {
    return '收到來自 $from 的「$version」';
  }

  @override
  String lanTransferCouldntStartReceiving(Object e) {
    return '無法開始接收：$e';
  }

  @override
  String get lanTransferImportAsNewInstance => '匯入為新實例';

  @override
  String lanTransferImportAsNewInstance2(Object version, Object count, Object size, Object parents) {
    return '將「$version」匯入為新實例，並開啟實例隔離。\n共 $count 個檔案，$size。\n\n$parents遊戲本體依賴的庫檔案和資源檔案沒有一起傳輸，第一次啟動時會自動補全。';
  }

  @override
  String lanTransferVanillaVersionDependsImported(Object parents) {
    return '依賴的原版 $parents 也會一起匯入（本機已有時保留本機的）。\n';
  }

  @override
  String lanTransferImporting(Object version) {
    return '正在匯入「$version」';
  }

  @override
  String lanTransferImportedInstance(Object id) {
    return '已匯入實例「$id」';
  }

  @override
  String lanTransferImportingInto(Object id) {
    return '正在匯入到「$id」';
  }

  @override
  String lanTransferImportedInto(Object id) {
    return '已匯入到「$id」';
  }

  @override
  String lanTransferImportedIntoPreviousContents(Object id, Object backup) {
    return '已匯入到「$id」，原來的內容已備份到 $backup';
  }

  @override
  String lanTransferImportFailed(Object e) {
    return '匯入失敗：$e';
  }

  @override
  String get lanTransferPreparing => '正在準備…';

  @override
  String get lanTransferNoInstancesYetInstall => '還沒有實例，請先安裝一個實例再匯入';

  @override
  String get lanTransferSendersInstance => '傳送方的實例';

  @override
  String lanTransferTheseModsComeFrom(Object from, Object id, Object v) {
    return '這些模組來自 $from，但「$id」是 $v，匯入後模組不會被載入。建議先在這台裝置上安裝相同的載入器，或者讓對方改用「整個實例」傳送。';
  }

  @override
  String lanTransferSendersInstanceLoadersDiffer(Object from, Object id, Object v) {
    return '傳送方的實例是 $from，「$id」是 $v，載入器不同。';
  }

  @override
  String lanTransferSendersInstanceGameVersions(Object from, Object id, Object v) {
    return '傳送方的實例是 $from，「$id」是 $v，遊戲版本不同，模組和存檔可能不相容。';
  }

  @override
  String get lanTransferImportIntoWhichInstance => '匯入到哪個實例';

  @override
  String lanTransferReplacesInstancesPreviousContents(Object what) {
    return '將替換這個實例的：$what\n原來的內容會先備份到遊戲資料夾的 backups 中。';
  }

  @override
  String get lanTransferChooseInstanceSend => '請選擇要傳送的實例';

  @override
  String get lanTransferPairingCode6Digits => '配對碼是 6 位數字';

  @override
  String get lanTransferConnecting => '正在連線…';

  @override
  String lanTransferConnectedPacking(Object name) {
    return '已連線到 $name，正在打包…';
  }

  @override
  String lanTransferPackingFilesAdded(Object n) {
    return '正在打包…已加入 $n 個檔案';
  }

  @override
  String lanTransferSending(Object size) {
    return '正在傳送 $size…';
  }

  @override
  String lanTransferSent(Object size, Object reply) {
    return '傳送完成（$size）：$reply';
  }

  @override
  String lanTransferSendingFailed(Object e) {
    return '傳送失敗：$e';
  }

  @override
  String get lanTransferTransferInstancesModsConfigs => '在同一個區域網路（同一個 Wi-Fi）中的兩台裝置之間傳輸實例、模組、設定和存檔。';

  @override
  String get lanTransferReceive => '接收';

  @override
  String get lanTransferAfterYouStartReceiving => '開始接收後，在另一台裝置上輸入下面顯示的位址和配對碼。離開這個頁面會停止接收。';

  @override
  String get lanTransferStartReceiving => '開始接收';

  @override
  String get lanTransferPairingCode => '配對碼';

  @override
  String get lanTransferAddressIPPort => '位址（IP:連接埠）';

  @override
  String get lanTransferNoLocalNetworkAddress => '沒有找到區域網路位址，請確認已連線 Wi-Fi 或網線';

  @override
  String get lanTransferIfThereSeveralAddresses => '有多個位址時，通常用 192.168 開頭的那個';

  @override
  String get lanTransferIfWindowsFirewallAsks => '如果 Windows 防火牆彈出提示，請允許 Pixel World 存取專用網路';

  @override
  String lanTransferReceiving(Object size, Object size2) {
    return '正在接收 $size / $size2';
  }

  @override
  String get lanTransferStopReceiving => '停止接收';

  @override
  String lanTransferWholeInstance(Object version) {
    return '整個實例「$version」';
  }

  @override
  String lanTransferText(Object version, Object i) {
    return '「$version」的$i';
  }

  @override
  String lanTransferFrom(Object from, Object address, Object describe, Object size) {
    return '來自 $from（$address）$describe，$size';
  }

  @override
  String get lanTransferNoInstancesSendYet => '還沒有可以傳送的實例';

  @override
  String get lanTransferChooseContent => '選擇內容';

  @override
  String get lanTransferWholeInstance2 => '整個實例';

  @override
  String get lanTransferPacksInstanceFolderWithout =>
      '打包實例資料夾（不含日誌和崩潰報告）。對方會匯入為新實例並開啟實例隔離。\n如果這個實例沒有開啟實例隔離，還會附帶下面選中的內容。';

  @override
  String get lanTransferReceiverReplacesSelectedContent => '對方匯入時會替換選中的內容，替換前自動備份。';

  @override
  String get lanTransferReceiversAddress => '對方位址';

  @override
  String fileManagerFailed(Object label, Object error) {
    return '$label失敗：$error';
  }

  @override
  String get aiGameClosesRightAfter => '遊戲啟動後閃退，應該從哪裡查原因？';

  @override
  String get aiWhatSomeCommonPerformance => '1.20.1 的 Fabric 有哪些常用的最佳化模組？';

  @override
  String get aiWhatsDifferenceBetweenForge => 'Forge 和 NeoForge 有什麼區別？';

  @override
  String get aiHowDoIGive => '怎麼給某個版本分配更多記憶體？';

  @override
  String aiCrashAnalysis(Object title) {
    return '崩潰分析 · $title';
  }

  @override
  String get aiSendFollowing => '傳送以下內容';

  @override
  String aiCharactersWillSentModel(Object count, Object host, Object model) {
    return '將傳送 $count 個字元到 $host（模型 $model）。玩家名、令牌、UUID、使用者目錄與 IP 位址已替換。';
  }

  @override
  String get aiDontAskAgain => '以後不再詢問';

  @override
  String get aiDeleteConversation => '刪除對話';

  @override
  String aiDeleteCantUndone(Object title) {
    return '刪除「$title」？刪除後無法恢復。';
  }

  @override
  String get aiYesterday => '昨天';

  @override
  String aiDaysAgo(num days) {
    return '$days 天前';
  }

  @override
  String aiMonthDay(Object month, Object day) {
    return '$month 月 $day 日';
  }

  @override
  String get aiNewChat => '新對話';

  @override
  String get aiHistory => '歷史對話';

  @override
  String get aiNoConversationsYet => '還沒有對話';

  @override
  String get aiAnswering => '正在回答…';

  @override
  String get aiCompactContextSummarizeEarlier => '壓縮上下文：把較早的對話壓縮成摘要';

  @override
  String get aiConversationShortNoNeed => '對話較短，暫時不需要壓縮';

  @override
  String get aiAISettings => 'AI 設定';

  @override
  String get commonHideSidePanel => '收起側邊欄';

  @override
  String get aiShowSidePanelEnvironment => '展開側邊欄（環境、上下文、檔案）';

  @override
  String get aiCompactingContext => '正在壓縮上下文…';

  @override
  String get aiThinking => '正在思考…';

  @override
  String get aiAskQuestion => '輸入問題';

  @override
  String get aiActionRunningYouCan => '操作執行中，完成後才能停止';

  @override
  String get aiStop => '停止';

  @override
  String get aiHowCanIHelp => '有什麼可以幫你？';

  @override
  String get aiAskMeAboutMinecraft => '可以問我 Minecraft 和啟動器的問題；遊戲崩潰時，在錯誤分析中選擇「AI 分析」會自動帶上日誌。';

  @override
  String get aiSetUpAIService => '先設定 AI 服務';

  @override
  String get aiEnterAPIAddressModel => '填寫你自己的 AI 服務的介面位址、模型和 API Key';

  @override
  String aiShowAllCharacters(Object count) {
    return '展開全部（$count 個字元）';
  }

  @override
  String get aiRegenerate => '重新生成';

  @override
  String get aiDeny => '拒絕';

  @override
  String aiAllowConversation(Object label) {
    return '本次對話中允許$label';
  }

  @override
  String get aiAllow => '允許';

  @override
  String get aiRunning => '正在執行';

  @override
  String get aiPreparing => '正在準備';

  @override
  String get aiDenied => '已拒絕';

  @override
  String get aiWaitingEarlierActions => '等待前面的操作';

  @override
  String get aiCanceled => '已取消';

  @override
  String aiInputOutputTokens(Object input, Object output) {
    return '輸入 $input · 輸出 $output tokens';
  }

  @override
  String aiS(Object ms) {
    return '用時 $ms 秒';
  }

  @override
  String aiRequests(num count) {
    return '$count 次請求';
  }

  @override
  String get aiUsageReportedAIService => '用量由 AI 服務返回，多次請求（例如調用工具）時為合計；用時不包括等待你確認的時間';

  @override
  String aiContextTokensIncludesSystem(Object estimated, Object used, Object window, Object summary) {
    return '上下文：$estimated$used / $window tokens\n包括系統提示、工具說明和發給模型的對話$summary';
  }

  @override
  String get commonAbout => '約 ';

  @override
  String get aiEarlierPartsWereSummarized => '（較早的部分已壓縮為摘要）';

  @override
  String get aiConversationAboveWasSummarized => '以上的對話已壓縮為摘要';

  @override
  String get aiConversationSummary => '對話摘要';

  @override
  String get aiViewSummary => '查看摘要';

  @override
  String get aiSettingsSaved => '已儲存';

  @override
  String aiSettingsFillAPIAddressModel(Object isLocal) {
    return '請填寫介面位址、模型$isLocal';
  }

  @override
  String get aiSettingsAPIKey => '和 API Key';

  @override
  String aiSettingsConnectedModelReplied(Object characters) {
    return '連線成功，模型回覆：$characters';
  }

  @override
  String get aiSettingsClipboardEmpty => '剪貼簿是空的';

  @override
  String get aiSettingsPasted => '已貼上';

  @override
  String get aiSettingsAPIReturnedNoUsable => '介面沒有返回可用的模型';

  @override
  String get commonTestConnection => '測試連線';

  @override
  String get aiSettingsPopularServices => '常用服務';

  @override
  String get aiSettingsOpenAICompatibleAPI => 'OpenAI 相容介面';

  @override
  String get aiSettingsAnthropicAPI => 'Anthropic 介面';

  @override
  String get aiSettingsAPIAddress => '介面位址';

  @override
  String aiSettingsOnlySentAPIAddress(Object available) {
    return '$available，只會傳送給上面填寫的介面位址；本機執行的服務可以不填';
  }

  @override
  String get aiSettingsStoredEncryptedDevice => '加密儲存在本機';

  @override
  String get aiSettingsStoredLaunchersPrivateData => '儲存在啟動器的私有資料目錄（未加密）';

  @override
  String get aiSettingsHide => '隱藏';

  @override
  String get aiSettingsShow => '顯示';

  @override
  String get aiSettingsModel => '模型';

  @override
  String get aiSettingsUseButtonRightFetch => '點右側按鈕從介面取得可用的模型';

  @override
  String get aiSettingsFetchModelList => '取得模型列表';

  @override
  String get aiSettingsContextLengthTokens => '上下文長度（tokens）';

  @override
  String aiSettingsEmptyAutomatic(Object defaultContextWindow) {
    return '留空自動：$defaultContextWindow';
  }

  @override
  String aiSettingsSeeYourProvidersDocs(Object defaultContextWindow) {
    return '見服務商文檔；未知的模型預設按 $defaultContextWindow 計算';
  }

  @override
  String get aiSettingsCompactContextAutomatically => '自動壓縮上下文';

  @override
  String get aiSettingsSummarizeEarlierMessagesOnce => '超過後把較早的對話壓縮成摘要，節省費用';

  @override
  String get aiSettingsAbove32kTokens => '超過 32k tokens 時';

  @override
  String get aiSettingsAbove64kTokens => '超過 64k tokens 時';

  @override
  String get aiSettingsAbove128kTokens => '超過 128k tokens 時';

  @override
  String get aiSettingsAbove256kTokens => '超過 256k tokens 時';

  @override
  String get aiSettingsNever => '不自動壓縮';

  @override
  String get aiSettingsConfirmBeforeSending => '傳送前確認內容';

  @override
  String get aiSettingsShowLogEnvironmentInfo => '每次分析前顯示將要傳送的日誌與環境資訊';

  @override
  String get aiSettingsAllowAIUseTools => '允許 AI 使用工具';

  @override
  String get aiSettingsViewInstancesModsLogs => '查看實例、模組與日誌，安裝或停用模組，聯網搜尋，以及下面的 MCP 服務；會修改內容的操作都需要你確認';

  @override
  String get aiSettingsConfirmReadOnlyActions => '查看類操作也需要確認';

  @override
  String get aiSettingsWhenOffAICan => '關閉時，AI 查看實例、模組、檔案與日誌不需要確認';

  @override
  String get aiSettingsAITroubleshootingSettings => 'AI 排障設定';

  @override
  String aiSettingsChooseModel(Object count) {
    return '選擇模型（$count 個）';
  }

  @override
  String get aiSettingsNoMatchingModels => '沒有匹配的模型';

  @override
  String get aiMcpSettingsRemoveMCPService => '移除 MCP 服務';

  @override
  String aiMcpSettingsRemoveItsSavedAccess(Object name) {
    return '移除「$name」？儲存的存取令牌也會一起刪除。';
  }

  @override
  String get aiMcpSettingsReadOnlyActionsOnly => '只有查看類操作';

  @override
  String get aiMcpSettingsPermissions => '權限';

  @override
  String get aiMcpSettingsToolServicesMCP => '工具服務（MCP）';

  @override
  String get aiMcpSettingsEverythingAIDoesGoes =>
      'AI 的所有操作都透過這些服務完成。設為「唯讀」的服務會直接拒絕會修改內容的操作，不再詢問。外部服務只由啟動器主動連線，啟動器不對外開放任何連接埠。';

  @override
  String get commonBuilt => '內建';

  @override
  String get aiMcpSettingsBuiltTurnedOffAbove => '內建 · 已在上方關閉';

  @override
  String get aiMcpSettingsTrustReadOnlyClaims => '信任唯讀聲明';

  @override
  String aiMcpSettingsConnectionFailed(Object split) {
    return '連線失敗：$split';
  }

  @override
  String commonTools(num toolCount) {
    return '$toolCount 個工具';
  }

  @override
  String get aiMcpSettingsEdit => '編輯';

  @override
  String get aiMcpSettingsAddMCPService => '新增 MCP 服務';

  @override
  String get aiMcpSettingsRefreshStatus => '重新整理狀態';

  @override
  String get aiMcpSettingsEnterName => '請填寫名稱';

  @override
  String get aiMcpSettingsLocalJarServicesCant => '安卓上暫時還不能執行本機 jar 服務';

  @override
  String get aiMcpSettingsChooseJarFile => '請選擇 jar 檔案';

  @override
  String aiMcpSettingsConnectedToolsAvailable(Object server, Object count, Object names) {
    return '連線成功$server，提供 $count 個工具$names';
  }

  @override
  String get aiMcpSettingsJarFile => 'jar 檔案';

  @override
  String get aiMcpSettingsEditMCPService => '編輯 MCP 服務';

  @override
  String get aiMcpSettingsRemoteHTTP => '遠程（HTTP）';

  @override
  String get aiMcpSettingsLocalJar => '本機 jar';

  @override
  String get aiMcpSettingsServiceURL => '服務位址';

  @override
  String get aiMcpSettingsRemoteServicesNeedHttps => '遠程服務需要 https；本機服務（例如 Termux 裡執行的）可以填 http://127.0.0.1:連接埠/mcp';

  @override
  String get aiMcpSettingsAccessTokenOptional => '存取令牌（可選）';

  @override
  String get aiMcpSettingsStoredEncryptedDeviceOnly => '加密儲存在本機，只會發給這個服務（Authorization: Bearer）';

  @override
  String get aiMcpSettingsLaunchArgumentsOptional => '啟動參數（可選）';

  @override
  String get aiMcpSettingsSeparatedSpacesAppendedAfter => '用空格分隔，附加在 java -jar 檔案 之後；Java 由啟動器自動選擇（Java 21）';

  @override
  String get aiMcpSettingsTrustServicesReadOnly => '信任這個服務的唯讀聲明';

  @override
  String get aiMcpSettingsWhenToolsServiceDeclares =>
      '開啟後，服務聲明唯讀的工具直接執行，不用確認；關閉時，每個工具在本次對話中第一次使用都要確認。聲明會刪除內容的工具始終每次確認。只對你信任的服務開啟';

  @override
  String aiSidePanelFileGone(Object path) {
    return '檔案已經不在了：$path';
  }

  @override
  String get aiSidePanelNoModelSetUp => '還沒有設定模型';

  @override
  String get aiSidePanelNoInstanceSelected => '沒有選擇實例';

  @override
  String get commonAIWorkspace => 'AI 工作區';

  @override
  String get aiSidePanelText => '開';

  @override
  String get aiSidePanelOff => '關';

  @override
  String get commonWebSearch => '聯網搜尋';

  @override
  String get aiSidePanelNotConnected => '未連線';

  @override
  String get aiSidePanelContext => '上下文';

  @override
  String aiSidePanelUsed(Object window) {
    return '$window% 已用';
  }

  @override
  String get aiSidePanelCompact => '壓縮';

  @override
  String get aiSidePanelFilesConversation => '本次對話的檔案';

  @override
  String get aiSidePanelFilesAIWritesChanges => 'AI 在這次對話裡寫入或修改的檔案會出現在這裡';

  @override
  String get aiSidePanelWorkspace => '工作區';

  @override
  String get aiSidePanelStillEmptyYouCan => '還是空的。可以讓 AI 把整理結果寫到這裡';

  @override
  String get aiWorkspaceSettingsLetAIAccessFolder => '讓 AI 存取這個資料夾';

  @override
  String get aiWorkspaceSettingsFolderHasAlreadyBeen => '這個資料夾已經新增過了';

  @override
  String get aiWorkspaceSettingsAllowAccessWholeDrive => '允許存取整個磁碟？';

  @override
  String aiWorkspaceSettingsRootDriveSoAI(Object real) {
    return '$real 是磁碟的根目錄，AI 將能看到其中所有檔案。建議只新增需要的資料夾。';
  }

  @override
  String get aiWorkspaceSettingsAddAnyway => '仍然新增';

  @override
  String get aiWorkspaceSettingsAIHasItsOwn => 'AI 有一個自己的資料夾可以隨意讀寫，並能查看目前實例的遊戲檔案（唯讀）';

  @override
  String get aiWorkspaceSettingsAfterGrantingAllFiles => '授予「所有檔案存取」後，AI 也能讀寫系統下載目錄。';

  @override
  String get aiWorkspaceSettingsYouCanAddOther => '還可以新增其他資料夾；預設唯讀，開啟「允許修改」後 AI 才能改動其中的檔案。';

  @override
  String get aiWorkspaceSettingsAllowChanges => '允許修改';

  @override
  String get aiWorkspaceSettingsRemoveFolderIsntDeleted => '移除（不會刪除資料夾）';

  @override
  String get aiWorkspaceSettingsOpenWorkspace => '開啟工作區';

  @override
  String get aiWorkspaceSettingsAICanSearchWeb => 'AI 可以搜尋網頁、開啟網址、查 Minecraft Wiki；請求會跟隨系統代理';

  @override
  String get aiWorkspaceSettingsSearchEngine => '搜尋引擎';

  @override
  String get aiWorkspaceSettingsSearXNGURL => 'SearXNG 位址';

  @override
  String get aiWorkspaceSettingsInstanceNeedsJSONOutput => '實例需要開啟 JSON 格式輸出';

  @override
  String get aiWorkspaceSettingsExaAPIKeyOptional => 'Exa 的 API Key（可以不填）';

  @override
  String get aiWorkspaceSettingsSearchServiceAPIKey => '搜尋服務的 API Key';

  @override
  String get aiWorkspaceSettingsWorksWithoutOneRate => '不填也能用，有頻率限制；填了之後額度更高。只會發給 Exa';

  @override
  String get aiWorkspaceSettingsStoredSeparatelyFromModels => '和模型的 Key 分開儲存，只會發給所選的搜尋服務';

  @override
  String installerAppInstall(Object name) {
    return '安裝 $name';
  }

  @override
  String installerAppUninstall(Object name) {
    return '解除安裝 $name';
  }

  @override
  String get installerAppUninstalling => '正在解除安裝…';

  @override
  String get installerAppUpdate => '更新';

  @override
  String installerAppVersionInstalledCurrentUser(Object version) {
    return '版本 $version · 只為目前使用者安裝，不需要管理員權限';
  }

  @override
  String get installerAppInstallLocation => '安裝位置';

  @override
  String get installerAppAddStartMenu => '新增到開始選單';

  @override
  String installerAppThirdPartyMinecraftLauncher(Object name) {
    return '$name 是第三方 Minecraft 啟動器，與 Mojang 或 Microsoft 無關。';
  }

  @override
  String get installerAppUpdating => '正在更新';

  @override
  String get installerAppInstalling => '正在安裝';

  @override
  String get installerAppInstallationComplete => '安裝完成';

  @override
  String installerAppInstalled(Object dir) {
    return '已安裝到 $dir';
  }

  @override
  String installerAppLaunch(Object name) {
    return '啟動 $name';
  }

  @override
  String get installerAppInstallationFailed => '安裝失敗';

  @override
  String get installerAppOnlyFilesWrittenDuring => '只刪除安裝時寫入的檔案，放在程式資料夾裡的其他檔案不會動';

  @override
  String get installerAppAlsoDeleteLauncherData => '同時刪除啟動器資料';

  @override
  String installerAppSettingsAccountsDefaultGame(Object userDataDirs) {
    return '設定、帳戶與預設遊戲資料夾（$userDataDirs）。預設遊戲資料夾中的存檔也會被刪除';
  }

  @override
  String get installerAppUninstall2 => '解除安裝';

  @override
  String get installerAppUninstalling2 => '正在解除安裝';

  @override
  String get installerAppUninstallFailed => '解除安裝失敗';

  @override
  String installerCoreRunningCloseBeforeInstalling(Object name) {
    return '$name 正在執行，請先關閉它再安裝';
  }

  @override
  String installerCoreCouldntCreateShortcut(Object path) {
    return '無法建立捷徑：$path';
  }

  @override
  String get installerCoreCouldntWriteUninstallInformation => '寫入解除安裝資訊失敗';

  @override
  String get installerCoreCantInstallIntoInstallers => '不能安裝到安裝程式所在的資料夾';

  @override
  String installerCoreCopying(Object rel) {
    return '正在複製 $rel';
  }

  @override
  String get installerCoreFinishingInstallation => '正在完成安裝…';

  @override
  String get installerCoreInstallManifestWasntFound => '找不到安裝清單，無法確定要刪除哪些檔案';

  @override
  String appStateRemovedFilesFoldersCreated(Object removed) {
    return '已清理 $removed 個由本次任務建立的檔案或目錄';
  }

  @override
  String appStateInstall(Object fileName) {
    return '安裝 $fileName';
  }

  @override
  String get commonResolveDependencies => '解析前置';

  @override
  String get commonDownloadFiles => '下載檔案';

  @override
  String appStateInstalledFilesSkippedExisting(Object count, Object count2, Object missing) {
    return '已安裝 $count 個檔案，跳過 $count2 個已存在的檔案$missing';
  }

  @override
  String appStateNoCompatibleDependencyFound(Object missing) {
    return '，找不到相容的前置：$missing';
  }

  @override
  String appStateInstallModpack(Object name) {
    return '安裝整合包 $name';
  }

  @override
  String get commonDownloadModpack => '下載整合包';

  @override
  String get commonInstallGameLoader => '安裝遊戲與載入器';

  @override
  String get commonDownloadModpackFiles => '下載整合包檔案';

  @override
  String get commonExtractModpackConfigs => '解壓整合包設定';

  @override
  String appStateInstalledAs(Object id) {
    return '已安裝為 $id';
  }

  @override
  String appStateInstallModpack2(Object path) {
    return '安裝整合包 $path';
  }

  @override
  String get commonReadModpack => '讀取整合包';

  @override
  String appStateAddOptiFine(Object id) {
    return '為 $id 新增 OptiFine';
  }

  @override
  String get appStateInvalidInstanceName => '實例名稱不合法';

  @override
  String appStateInstall2(Object loaderVersion) {
    return '安裝 $loaderVersion';
  }

  @override
  String get appStateGameAlreadyRunning => '遊戲已在執行';

  @override
  String get appStateChooseInstanceFirst => '請先選擇一個實例';

  @override
  String get appStateAddAccountFirst => '請先新增一個帳戶';

  @override
  String appStateLaunch(Object id) {
    return '啟動 $id';
  }

  @override
  String get appStateCheckFiles => '檢查檔案';

  @override
  String get appStatePrepareLaunch => '準備啟動';

  @override
  String get appStateStartGame => '啟動遊戲';

  @override
  String get appStateVerifyAccount => '驗證帳戶';

  @override
  String get appStateAnalyzeInstance => '分析實例';

  @override
  String get appStateExtractNativeLibraries => '解壓本機庫';

  @override
  String appStateJavaAndroidJava(Object path, Object major) {
    return 'Java: $path（安卓版 Java $major）';
  }

  @override
  String appStateMemoryGB(Object max) {
    return '記憶體: $max GB';
  }

  @override
  String appStateWorkingDirectory(Object gameDir) {
    return '工作目錄: $gameDir';
  }

  @override
  String appStateRenderScale(Object renderScale) {
    return '渲染比例: $renderScale%';
  }

  @override
  String appStateGPU(Object gpu) {
    return '顯示卡: $gpu';
  }

  @override
  String appStateRendererLWJGL(
    Object renderer,
    Object reason,
    Object sfpew,
    Object turnip,
    Object lwjgl,
    Object lwjgl2,
    Object sdl,
  ) {
    return '渲染器: $renderer（$reason）$sfpew$turnip，LWJGL $lwjgl$lwjgl2$sdl';
  }

  @override
  String get appStateSFPEWFixedFunctionEmulation => ' + SFPEW（固定管線模擬）';

  @override
  String get appStateTurnipDriver => ' + Turnip 驅動程式';

  @override
  String get appStateLWJGL2CompatibilityLayer => '（LWJGL 2 相容層）';

  @override
  String get appStateWarningDeviceDoesntReport => '警告：這台裝置沒有聲明 Vulkan 1.1，所選渲染器可能無法啟動';

  @override
  String get appStateTouchControllerModDetectedUsing => '檢測到 TouchController 模組：使用它的觸控方式';

  @override
  String get appStateWarningKryptonWrapperCrashes => '警告：Krypton Wrapper 在 26.3 快照及之後的版本上會崩潰，出現問題請換用 MobileGlues';

  @override
  String appStateGameExitedCode(Object code) {
    return '遊戲已退出，程式碼 $code';
  }

  @override
  String appStateLaunch2(Object id) {
    return '啟動 - $id';
  }

  @override
  String appStateJavaJavaBit(Object path, Object major, Object is64) {
    return 'Java: $path（Java $major，$is64 位）';
  }

  @override
  String appStateMemoryGB2(Object max, Object initial) {
    return '記憶體: $max GB$initial';
  }

  @override
  String appStateInitialGB(Object initial) {
    return '，初始 $initial GB';
  }

  @override
  String appStateLaunchFailed(Object e) {
    return '啟動失敗：$e';
  }

  @override
  String get appStateGameCrashedSeeCrash => '遊戲崩潰了，可以在錯誤分析中查看原因';

  @override
  String appStateCouldntCollectCrashInformation(Object e) {
    return '收集崩潰資訊失敗：$e';
  }

  @override
  String get appInfoPixelWorldLauncher => 'Pixel World 啟動器';

  @override
  String get crashEnvironment => '## 環境';

  @override
  String get crashInitialFindingsFromLaunchers => '## 啟動器本機規則的初步判斷';

  @override
  String crashEnabledModFiles(Object count) {
    return '## 已啟用的模組檔案（$count 個）';
  }

  @override
  String crashCrashReport(Object path) {
    return '崩潰報告 $path';
  }

  @override
  String crashJVMErrorLog(Object path) {
    return 'JVM 錯誤日誌 $path';
  }

  @override
  String get crashGameOutput => '遊戲輸出';

  @override
  String crashInstance(Object versionId, Object description) {
    return '實例：$versionId（$description）';
  }

  @override
  String crashLoader(Object loaderLibs) {
    return '載入器：$loaderLibs';
  }

  @override
  String crashAllocatedMemoryGB(Object memoryGb) {
    return '分配記憶體：$memoryGb GB';
  }

  @override
  String crashSystem(Object operatingSystem, Object operatingSystemVersion) {
    return '系統：$operatingSystem $operatingSystemVersion';
  }

  @override
  String crashExitCode(Object exitCode) {
    return '退出程式碼：$exitCode';
  }

  @override
  String crashMoreCharactersOmitted(Object max, Object max2) {
    return '$max\n...（以下省略 $max2 個字元）';
  }

  @override
  String crashPreviousLineRepeatedTimes(Object repeat) {
    return '（上一行重複 $repeat 次）';
  }

  @override
  String crashLinesOmitted(Object skipped) {
    return '...（省略 $skipped 行）';
  }

  @override
  String crashCharactersOmitted(Object head, Object budget, Object end) {
    return '$head\n...（中間省略 $budget 個字元）\n$end';
  }

  @override
  String get crashToken => '<令牌>';

  @override
  String crashToken2(Object m) {
    return '$m <令牌>';
  }

  @override
  String get crashPlayer => '<玩家>';

  @override
  String crashUser(Object m) {
    return '$m<使用者>';
  }

  @override
  String get crashJavaVersionTooOld => 'Java 版本過低';

  @override
  String crashJavaNewerRequiredBut(Object version, Object version2) {
    return '需要 Java $version 或更高，目前 Java 只支援到 Java $version2。請在實例設定中選擇更新的 Java。';
  }

  @override
  String get crashSomeModsGameFiles => '有模組或遊戲檔案需要更新的 Java，請在實例設定中選擇更新的 Java。';

  @override
  String get crashJava8Required => '需要 Java 8';

  @override
  String get crashOldForge112 => '舊版 Forge（1.12.2 及更早）只能在 Java 8 上執行，請在實例設定中選擇 Java 8。';

  @override
  String get crashOutMemory => '記憶體不足';

  @override
  String get crashGameDoesntHaveEnough => '遊戲可用的記憶體不夠。可以在實例設定中加大記憶體，或減少模組、光影與高清材質。';

  @override
  String get crashInvalidMemorySetting => '記憶體設定無效';

  @override
  String get crashAllocatedMemoryExceedsLimit => '分配的記憶體超出了系統或 32 位 Java 的上限，請調小記憶體，或換用 64 位 Java。';

  @override
  String get crashMissingWrongDependency => '缺少前置模組或版本不對';

  @override
  String get crashModsRequiredDependencyIsnt => '有模組需要的前置模組沒有安裝，或版本不符合要求。按下面的日誌行安裝或更新對應模組。';

  @override
  String get crashDuplicateMods => '模組重複';

  @override
  String get crashSameModInstalledMore => '同一個模組裝了多份（可能是不同版本），請刪除多餘的檔案。';

  @override
  String get crashMixinInjectionFailed => 'Mixin 注入失敗';

  @override
  String get crashUsuallyModsIncompatibleEach => '通常是模組之間不相容，或模組與目前 Minecraft、載入器版本不匹配。日誌中會寫出出錯的模組。';

  @override
  String get crashModsDontMatchLoader => '模組與載入器不匹配';

  @override
  String get crashModsAnotherLoaderInstalled => '裝了其他載入器的模組，例如在 Fabric 上裝了 Forge 模組。';

  @override
  String get crashOptiFineIncompatible => 'OptiFine 不相容';

  @override
  String get crashOptiFineIsntCompatibleCurrent =>
      'OptiFine 與目前的 Forge 或其他模組不相容。可以換用 OptiFine 要求的 Forge 版本，或移除 OptiFine。';

  @override
  String get crashGraphicsDriverProblem => '顯示卡驅動程式問題';

  @override
  String get crashGraphicsDriverDoesntSupport => '顯示卡驅動程式不支援或出錯。請到顯示卡廠商官網更新驅動程式；筆電可以讓遊戲使用獨立顯示卡。';

  @override
  String get crashMainClassNotFound => '找不到主類';

  @override
  String get crashGameFilesMayIncomplete => '遊戲檔案可能不完整，或路徑中含有特殊字元。可以嘗試補全檔案或換一個不含特殊字元的資料夾。';

  @override
  String get crashManuallyTriggeredCrash => '手動觸發的崩潰';

  @override
  String get crashDebugCrashTriggeredHolding => '這是按住 F3 + C 觸發的除錯崩潰，不是錯誤。';

  @override
  String get crashModSuspectedCrashReport => '崩潰報告懷疑的模組';

  @override
  String get crashCrashReportNamesMod => '崩潰報告指出了可能導致崩潰的模組，可以先停用它試試。';

  @override
  String get taskCancelingTask => '正在中斷任務…';

  @override
  String taskFilesDownload(num t) {
    return '共 $t 個檔案需要下載';
  }

  @override
  String taskFailed(Object error) {
    return '失敗：$error';
  }

  @override
  String javaGetJavaRuntime(Object component) {
    return '取得 Java 執行時 ($component)';
  }

  @override
  String javaDownloadJavaRuntime(Object component, Object useMirror) {
    return '下載 Java 執行時 ($component，$useMirror)';
  }

  @override
  String javaDownloadedFiles(Object done, Object total) {
    return '已下載 $done / $total 個檔案';
  }

  @override
  String javaAverageS(Object speed) {
    return ' · 平均 $speed/s';
  }

  @override
  String get javaGetJava8Azul => '取得 Java 8（Azul Zulu，Apple 芯片）';

  @override
  String get javaDownloadJava8Azul => '下載 Java 8（Azul Zulu）';

  @override
  String get javaJava8DownloadFailed => 'Java 8 下載校驗失敗（SHA-256 不匹配）';

  @override
  String get javaExtractJava8 => '解壓 Java 8';

  @override
  String javaCouldntExtractJava8(Object stderr) {
    return '解壓 Java 8 失敗：$stderr';
  }

  @override
  String get javaJava8ArchiveHas => 'Java 8 壓縮包的結構無法辨識';

  @override
  String javaJavaPathDoesntExist(Object path) {
    return 'Java 路徑不存在：$path';
  }

  @override
  String javaCantRunJava(Object path) {
    return '無法執行 Java：$path';
  }

  @override
  String javaInstanceStartsThroughLaunchWrapper(Object javaMajor) {
    return '這個實例透過 LaunchWrapper 啟動（Forge 1.12.2 及更早、OptiFine、LiteLoader 等），只能在 Java 8 上執行，使用 Java $javaMajor 很可能在載入時崩潰。';
  }

  @override
  String get javaUseEnsureAndroidJavaAndroid => '安卓上請使用 ensureAndroidJava';

  @override
  String javaJavaSetDoesntExist(Object where, Object path) {
    return '$where指定的 Java 不存在：$path。請重新選擇 Java，或改為自動選擇';
  }

  @override
  String javaJavaSetButInstance(Object where, Object major, Object major2) {
    return '$where指定的是 Java $major，這個實例至少需要 Java $major2。請重新選擇 Java，或改為自動選擇';
  }

  @override
  String get javaInstanceSettings => '實例設定中';

  @override
  String get javaGlobalSettings => '全局設定中';

  @override
  String get javaDetectJava => '檢測 Java';

  @override
  String javaAutomaticallyDownloadedJavaOlder(Object major, Object major2) {
    return '自動下載的 Java $major 低於需要的 Java $major2';
  }

  @override
  String javaJavaWasntFoundSet(Object major, Object downloadError) {
    return '找不到 Java $major，請在設定中手動指定 Java 路徑$downloadError';
  }

  @override
  String javaAutomaticDownloadFailed(Object downloadError) {
    return '（自動下載失敗：$downloadError）';
  }

  @override
  String installFilesGeneratedInstallerMissing(Object missingLocal) {
    return '缺少由安裝器生成的檔案：$missingLocal，請重新安裝這個實例';
  }

  @override
  String get installDownloadGameLibraries => '下載遊戲本體與依賴庫';

  @override
  String get installDownloadAssetIndex => '下載資源索引';

  @override
  String get installDownloadAssets => '下載資源檔案';

  @override
  String get installOrganizeLegacyAssets => '整理舊版資源';

  @override
  String get installInstanceNameCantEmpty => '實例名稱不能為空，且不能包含 \\ / : * ? \" < > |';

  @override
  String installInstanceNamedAlreadyExists(Object n) {
    return '已存在名為 $n 的實例';
  }

  @override
  String installDownload(Object component) {
    return '下載 $component';
  }

  @override
  String installInstall(Object component) {
    return '安裝 $component';
  }

  @override
  String get installGetVersionInfo => '取得版本資訊';

  @override
  String installVersionNotFound(Object id) {
    return '找不到版本 $id';
  }

  @override
  String installDownloadMinecraft(Object gameVersion) {
    return '下載 Minecraft $gameVersion 本體';
  }

  @override
  String downloadDownloadFailed(Object url) {
    return '下載失敗：$url';
  }

  @override
  String downloadDownloadTooSlowRetrying(Object target) {
    return '下載速度過慢，更換節點重試：$target';
  }

  @override
  String downloadVerificationFailedSHA1(Object path) {
    return '校驗失敗（SHA-1 不匹配）：$path';
  }

  @override
  String downloadVerificationFailedSizeShould(Object size, Object count, Object path) {
    return '校驗失敗（大小應為 $size，實際 $count）：$path';
  }

  @override
  String downloadChunkSizeMismatch(Object path) {
    return '分塊大小不符：$path';
  }

  @override
  String downloadSizeMismatchAfterMerging(Object path) {
    return '分塊合併後大小不符：$path';
  }

  @override
  String downloadDownloadFailedHTTP(Object statusCode) {
    return '下載失敗（HTTP $statusCode）';
  }

  @override
  String downloadConnected(Object host, Object total) {
    return '已連線 $host$total';
  }

  @override
  String downloadFileSizeMB(Object total) {
    return '，檔案大小 $total MB';
  }

  @override
  String get downloadServerDidntReportFile => '，伺服器沒有提供檔案大小';

  @override
  String downloadDownloadTooSlowKB(Object secs) {
    return '下載速度過慢（$secs KB/s）';
  }

  @override
  String get downloadNoDataReceived => '沒有收到資料';

  @override
  String downloadIncompleteDownloadBytes(Object received, Object total) {
    return '下載不完整（$received / $total 位元組）';
  }

  @override
  String downloadIncompleteDownloadExpectedBytes(Object size, Object received) {
    return '下載不完整（應為 $size 位元組，實際 $received）';
  }

  @override
  String downloadFilesFailedDownloadE(Object count, Object errors) {
    return '$count 個檔案下載失敗，例如：$errors';
  }

  @override
  String get modpackModpackDoesntSpecifyMinecraft => '整合包沒有標明 Minecraft 版本';

  @override
  String get modpackNotValidModrinthModpack => '不是有效的 Modrinth 整合包：缺少 modrinth.index.json';

  @override
  String modpackInstallMinecraft(Object minecraft) {
    return '安裝 Minecraft $minecraft';
  }

  @override
  String modpackModpackContainsUnsafePath(Object message) {
    return '整合包包含不安全的路徑：$message';
  }

  @override
  String modpackSkippedUnneededFiles(Object skipped) {
    return '跳過 $skipped 個不需要的檔案';
  }

  @override
  String modpackExtractedConfigOverrideFiles(Object extracted) {
    return '已解壓 $extracted 個設定與覆蓋檔案';
  }

  @override
  String forgeDownloadInstaller(Object label) {
    return '下載 $label 安裝器';
  }

  @override
  String forgeInstallerCorruptedInstallProfile(Object label) {
    return '$label 安裝器已損壞：找不到 install_profile.json';
  }

  @override
  String forgeOfflineInstallFailedInstalling(Object e) {
    return '離線安裝失敗，改為聯網安裝：$e';
  }

  @override
  String forgeInstallerNeedsDownloadMojang(Object label) {
    return '$label 安裝器需要聯網下載 Mojang 映射，無法完全離線安裝';
  }

  @override
  String forgeDownloadFilesNeededInstaller(Object label) {
    return '下載 $label 安裝器需要的檔案';
  }

  @override
  String forgeSomeFilesDidntDownload(Object e) {
    return '部分檔案沒有下載成功，交給安裝器重試：$e';
  }

  @override
  String forgeRunInstallerProcessingFiles(Object label) {
    return '執行 $label 安裝器（處理檔案，可能需要幾分鐘）';
  }

  @override
  String forgeRunInstallerDownloadingDependencies(Object label) {
    return '執行 $label 安裝器（下載依賴並處理檔案，可能需要幾分鐘）';
  }

  @override
  String forgeInstallerFailedExitCode(Object label, Object code, Object tail) {
    return '$label 安裝器執行失敗（退出程式碼 $code）\n$tail';
  }

  @override
  String forgeInstallerFailed(Object label, Object tail) {
    return '$label 安裝器執行失敗\n$tail';
  }

  @override
  String forgeSeveralNewVersionsAppeared(Object label, Object candidates) {
    return '$label 安裝器之後出現了多個新版本（$candidates），無法確定是哪一個';
  }

  @override
  String forgeInstallerDidntCreateNew(Object label) {
    return '$label 安裝器沒有生成新的版本';
  }

  @override
  String forgeInstall(Object label) {
    return '安裝 $label';
  }

  @override
  String forgeInstallerCorruptedMissing(Object label, Object install) {
    return '$label 安裝器已損壞：找不到 $install';
  }

  @override
  String get modrinthShaderPacks => '光影包';

  @override
  String get modrinthTooManyRequestsPlease => '請求過於頻繁，請稍後再試';

  @override
  String modrinthModrinthRequestFailed(Object statusCode) {
    return 'Modrinth 請求失敗（$statusCode）';
  }

  @override
  String get modrinthResourceWasntFoundModrinth => 'Modrinth 上找不到該資源';

  @override
  String get modrinthModpackInstallationWillCome => '整合包安裝將在後續版本提供';

  @override
  String get modrinthChooseWorldInstallData => '請選擇要安裝資料包的世界';

  @override
  String modrinthResolveDependencies(Object length) {
    return '解析前置（$length）';
  }

  @override
  String get extraLoadersDownloadOptiFine => '下載 OptiFine';

  @override
  String get extraLoadersPutIntoModsFolder => '放入 mods 資料夾';

  @override
  String extraLoadersPutInto(Object path) {
    return '已放入 $path';
  }

  @override
  String get extraLoadersDownloadOptiFineInstaller => '下載 OptiFine 安裝包';

  @override
  String get extraLoadersGenerateOptiFineLibrary => '生成 OptiFine 庫';

  @override
  String extraLoadersOptiFinePatcherFailedExit(Object code, Object tail) {
    return 'OptiFine Patcher 執行失敗（退出程式碼 $code）\n$tail';
  }

  @override
  String extraLoadersOptiFineInstallerCorruptedLaunchwrapper(Object lwVersion) {
    return 'OptiFine 安裝包已損壞：找不到 launchwrapper-of-$lwVersion.jar';
  }

  @override
  String get extraLoadersGetLabyModVersionList => '取得 LabyMod 版本清單';

  @override
  String loadersLiteLoaderNotFound(Object version) {
    return '找不到 LiteLoader $version';
  }

  @override
  String get loadersLiteLoaderOnlySupports1 => 'LiteLoader 只支援 1.12.2 及更早的版本';

  @override
  String get loadersInstallLiteLoader => '安裝 LiteLoader';

  @override
  String loadersGetConfiguration(Object label) {
    return '取得 $label 設定';
  }

  @override
  String get loaderNamesUnknown => '未知';

  @override
  String get optifineCompatWillInstalledAsSeparate => '將安裝為獨立的 OptiFine 版本';

  @override
  String optifineCompatGoesIntoModsAs(Object requiredForge) {
    return '作為模組放進 mods；適配 Forge $requiredForge，較新的 Forge 可能不相容';
  }

  @override
  String get optifineCompatGoesIntoModsAs2 => '作為模組放進 mods';

  @override
  String get optifineCompatGoesIntoModsAs3 => '作為模組放進 mods；OptiFine 官方不支援 NeoForge，可能無法載入';

  @override
  String get optifineCompatGoesIntoModsAs4 => '作為模組放進 mods；還需要另外安裝 OptiFabric 模組才能載入';

  @override
  String launchRunningPreLaunchCommand(Object command) {
    return '執行啟動前命令：$command';
  }

  @override
  String versionVersionIsntInstalled(Object id) {
    return '版本 $id 未安裝';
  }

  @override
  String get lanTransferModConfigs => '模組設定';

  @override
  String get lanTransferGameOptions => '遊戲設定';

  @override
  String get lanTransferUnsupportedTransferFormatUpdate => '不支援的傳輸格式，請把兩邊的啟動器更新到同一版本';

  @override
  String get lanTransferInvalidTransferManifest => '傳輸清單無效';

  @override
  String lanTransferInvalidInstanceName(Object version) {
    return '實例名無效：$version';
  }

  @override
  String lanTransferInvalidDependencyVersionName(Object id) {
    return '依賴版本名無效：$id';
  }

  @override
  String get lanTransferTransferManifestContainsUnsupported => '傳輸清單中有不支援的內容';

  @override
  String get lanTransferUnknownDevice => '未知裝置';

  @override
  String get lanTransferChooseAtLeastOne => '請至少選擇一項內容';

  @override
  String get lanTransferNoneSelectedItemsExist => '選中的內容都不存在';

  @override
  String get lanTransferReceivedFileIsntPixel => '收到的檔案不是 Pixel World 的傳輸包';

  @override
  String get lanTransferTransferManifestCantRead => '傳輸清單無法讀取';

  @override
  String get lanTransferTransferPackageMissingFiles => '傳輸包缺少檔案，可能沒有傳輸完整';

  @override
  String lanTransferTransferPackageContainsSymbolic(Object name) {
    return '傳輸包中有符號連結：$name';
  }

  @override
  String lanTransferTransferPackageContainsFile(Object name) {
    return '傳輸包中有清單以外的檔案：$name';
  }

  @override
  String lanTransferFileSizeDoesntMatch(Object name) {
    return '檔案大小與清單不符：$name';
  }

  @override
  String lanTransferInvalidTransferPackage(Object name) {
    return '傳輸包無效：$name';
  }

  @override
  String commonTemporaryFolderAlreadyExists(Object staging) {
    return '暫存資料夾已存在：$staging';
  }

  @override
  String lanTransferTransferPackageContainsDuplicate(Object rel) {
    return '傳輸包中有重複的檔案：$rel';
  }

  @override
  String lanTransferFileSizeDoesntMatch2(Object rel) {
    return '檔案大小與清單不符：$rel';
  }

  @override
  String get lanTransferTransferPackageIsntWhole => '這個傳輸包不是整個實例';

  @override
  String lanTransferInstanceNamedAlreadyExists(Object id) {
    return '已經有名為「$id」的實例，請先在實例設定裡重命名或刪除它';
  }

  @override
  String lanTransferTransferPackageHasNo(Object id) {
    return '傳輸包中沒有版本檔案 $id.json';
  }

  @override
  String get lanTransferTransferPackageWholeInstance => '這個傳輸包是整個實例，請匯入為新實例';

  @override
  String lanTransferWrongPairingCodeAttempts(num left) {
    return '配對碼不正確，還可以再試 $left 次';
  }

  @override
  String get lanTransferTooManyWrongPairing => '配對碼錯誤次數太多，對方已停止接收';

  @override
  String get lanTransferTooManyWrongPairing2 => '配對碼錯誤次數太多，已停止接收。需要時重新開始接收，會生成新的配對碼。';

  @override
  String get lanTransferOtherDeviceReceivingAnother => '對方正在接收另一個傳輸，請稍後再試';

  @override
  String get lanTransferMissingFileSize => '缺少檔案大小';

  @override
  String get lanTransferFileTooLargeAt => '檔案太大，單次最多 32 GB';

  @override
  String get lanTransferReceivedMoreDataThan => '收到的資料比聲明的多';

  @override
  String lanTransferTransferInterruptedOnlyBytes(Object got, Object total) {
    return '傳輸中斷，只收到 $got / $total 位元組';
  }

  @override
  String get lanTransferReceivedOtherDeviceWaiting => '對方已收到，等待對方確認匯入';

  @override
  String lanTransferReceivingFailed(Object e) {
    return '接收失敗：$e';
  }

  @override
  String get lanTransferAddressShouldIPPort => '位址格式應為「IP:連接埠」，例如 192.168.1.5:43567';

  @override
  String lanTransferConnectionFailed(Object statusCode) {
    return '連線失敗（$statusCode）';
  }

  @override
  String get lanTransferOtherDevice => '對方裝置';

  @override
  String lanTransferCantReachMakeSure(Object host, Object port) {
    return '連不上 $host:$port。請確認兩台裝置在同一個區域網路，對方正在接收，且防火牆允許 Pixel World 聯網';
  }

  @override
  String lanTransferSendingFailed2(Object statusCode) {
    return '傳送失敗（$statusCode）';
  }

  @override
  String lanTransferTransferInterrupted(Object message) {
    return '傳輸中斷：$message';
  }

  @override
  String get toolboxPerfectScoreEverythingGoes => '滿分！今天做什麼都會順利';

  @override
  String get toolboxGreatLuckEveryChest => '大吉，開箱必出鑽石';

  @override
  String get toolboxPrettyLuckyGoodDay => '運氣不錯，適合去下界走走';

  @override
  String get toolboxSteadyCalmNoLava => '平平穩穩，挖礦不會挖到岩漿';

  @override
  String get toolboxSoSoRememberBring => '一般般，記得多帶幾個床';

  @override
  String get toolboxWatchOutCreepersSave => '小心苦力怕，出門前先存檔';

  @override
  String get toolboxGoodDayStayHome => '今天適合在家種田';

  @override
  String get toolboxZeroBetterStayOut => '零分……今天還是別下礦了';

  @override
  String get toolboxOnlyWindowsSupportedNow => '目前只支援 Windows';

  @override
  String get toolboxCouldntCreateShortcut => '建立捷徑失敗';

  @override
  String get toolboxEnterURLStartingHttp => '請輸入 http 或 https 開頭的網址';

  @override
  String toolboxConnect(Object host) {
    return '連線 $host';
  }

  @override
  String toolboxDownload(Object path) {
    return '下載 $path';
  }

  @override
  String toolboxSavedMB(Object path, Object done) {
    return '已儲存到 $path（$done MB）';
  }

  @override
  String get toolboxPlayerNamesCanOnly => '玩家名只能包含字母、數字和下划線';

  @override
  String toolboxNoMinecraftPlayerNamed(Object n) {
    return '找不到正版玩家 $n';
  }

  @override
  String toolboxPlayerLookupFailed(Object s1) {
    return '查詢玩家失敗（$s1）';
  }

  @override
  String toolboxCouldntGetSkinInfo(Object s2) {
    return '取得皮膚資訊失敗（$s2）';
  }

  @override
  String toolboxUsesDefaultSkin(Object n) {
    return '$n 使用的是預設皮膚';
  }

  @override
  String toolboxCouldntDownloadSkin(Object s3) {
    return '下載皮膚失敗（$s3）';
  }

  @override
  String get toolboxItemNotFoundCheck => '找不到這個物品，請檢查物品 ID';

  @override
  String toolboxGenerationFailed(Object status) {
    return '生成失敗（$status）';
  }

  @override
  String get toolboxServerReturnedInvalidData => '伺服器返回的資料無效';

  @override
  String get toolboxInvalidServerAddress => '伺服器位址格式不正確';

  @override
  String toolboxCantConnect(Object e) {
    return '無法連線：$e';
  }

  @override
  String toolboxConnectionInterrupted(Object e) {
    return '連線中斷：$e';
  }

  @override
  String get toolboxServerClosedConnection => '伺服器關閉了連線';

  @override
  String get toolboxConnectionTimedOut => '連線超時';

  @override
  String androidRuntimeCouldntReadSystemLog(Object e) {
    return '讀取系統日誌失敗：$e';
  }

  @override
  String get androidRuntimePixelWorldGameProcess => '\n[Pixel World] 遊戲處理程序沒有啟動，或啟動後立即退出了。\n';

  @override
  String androidRuntimeSystemLogLogcat(Object systemLog) {
    return '\n---------- 系統日誌（logcat） ----------\n$systemLog\n';
  }

  @override
  String get androidRuntimePixelWorldJarRunner => '[Pixel World] jar 執行處理程序沒有啟動';

  @override
  String get androidRuntimePixelWorldJarRunner2 => '[Pixel World] jar 執行處理程序在啟動 Java 前退出了';

  @override
  String get androidRuntimeZinkOpenGLVulkan => 'Zink（OpenGL 轉 Vulkan）';

  @override
  String get androidRuntimeKryptonWrapperRecommended => 'Krypton Wrapper（推薦）';

  @override
  String get androidRuntimeSystemGLESDriverGLES => '系統 GLES 驅動程式（僅限支援 GLES 的模組）';

  @override
  String get androidRuntimeUsesKryptonWrapperDefault =>
      '預設用 Krypton Wrapper；26.x 版本改用 MobileGlues，顯示卡不支援 OpenGL ES 3 時用 Zink';

  @override
  String get androidRuntimeOpenGLOpenGLESSupports => 'OpenGL 轉 OpenGL ES，支援所有版本，包括 26.x（舊版本自動加 SFPEW 模擬固定管線）';

  @override
  String get androidRuntimeMesaZinkFullOpenGL =>
      'Mesa Zink：完整的 OpenGL 4.6，需要 Vulkan 1.1。驍龍（Adreno）上自動改用自帶的開源驅動程式 Turnip，適合 MobileGlues 畫面出錯時使用';

  @override
  String get androidRuntimeNGGL4ESOpenGLOpenGL =>
      'NG-GL4ES：OpenGL 轉 OpenGL ES，效率高，新舊版本都能用，能執行 Sodium 和部分光影。26.3 快照起的版本暫不可用';

  @override
  String get androidRuntimeUsesSystemGLESDriver => '直接使用系統 GLES 驅動程式，不做轉譯。原版 Minecraft 無法以此執行';

  @override
  String get androidRuntimeNoVulkan => '無 Vulkan';

  @override
  String get androidRuntimeSetSettings => '設定指定';

  @override
  String get androidRuntimeGPUDoesntSupportOpenGL => '顯示卡不支援 OpenGL ES 3';

  @override
  String get androidRuntime26XVersionKrypton => '26.x 版本，Krypton Wrapper 暫不支援';

  @override
  String androidRuntimeExtractJava(Object major) {
    return '解壓 Java $major';
  }

  @override
  String androidRuntimeExtractingMB(Object size) {
    return '正在解壓 $size MB…';
  }

  @override
  String androidRuntimeExtracting(Object total) {
    return '解壓中 $total%';
  }

  @override
  String androidRuntimeDownloadJava(Object major, Object name) {
    return '下載 Java $major（$name）';
  }

  @override
  String get androidRuntimeDownloadIsntValidArchive => '下載到的不是有效的壓縮包';

  @override
  String androidRuntimeJavaDownloadedMBFrom(Object major, Object lengthSync, Object name) {
    return 'Java $major 下載完成（$lengthSync MB，來源 $name）';
  }

  @override
  String androidRuntimeDownloadFailed(Object name, Object e) {
    return '$name 下載失敗：$e';
  }

  @override
  String androidRuntimeJavaDownloadFailedTried(Object major, Object failures) {
    return 'Java $major 下載失敗，已嘗試 GitHub 與鏡像：\n$failures';
  }

  @override
  String androidRuntimeJavaSetIsntInstalled(Object where, Object home) {
    return '$where指定的 Java 沒有安裝：$home。請在設定的 Java 頁面下載，或改為自動選擇';
  }

  @override
  String androidRuntimeJavaSetButInstance(Object where, Object major, Object requiredValue) {
    return '$where指定的是 Java $major，這個實例至少需要 Java $requiredValue。請重新選擇 Java，或改為自動選擇';
  }

  @override
  String get importInvalidEncryptedDataLength => '加密資料長度無效';

  @override
  String get importUnrecognizedCNGProtectedData => '無法辨識的 CNG 保護資料';

  @override
  String get importPCLCEAccountKeys => 'PCL-CE 的帳戶密鑰只能在 Windows 上解開';

  @override
  String get importPCLCEUserKey => '找不到 PCL-CE 使用者密鑰 UserKey.bin';

  @override
  String get importUnrecognizedUserKeyBinFormat => 'UserKey.bin 格式無法辨識';

  @override
  String importUnsupportedUserKeyVersion(Object version) {
    return '不支援的 UserKey 版本 $version';
  }

  @override
  String get importOldEncryptionFormatImport => '舊版加密格式，不支援匯入';

  @override
  String importUnsupportedEncryptionVersion(Object version) {
    return '不支援的加密版本 $version';
  }

  @override
  String get importNoPCLCEConfiguration => '沒有找到 PCL-CE 的設定（%APPDATA%\\PCLCE）';

  @override
  String get importIPProtocolPreference => 'IP 協議偏好';

  @override
  String get importHighPerformanceGPU => '高效能顯示卡';

  @override
  String get importLauncherBehaviorAfterLaunch => '啟動後啟動器行為';

  @override
  String get importJavaChoice => 'Java 選擇';

  @override
  String get importMemoryMode => '記憶體模式';

  @override
  String get importCustomMemory => '自訂記憶體';

  @override
  String get importPreLaunchCommand => '啟動前命令';

  @override
  String get importWaitPreLaunchCommand => '等待啟動前命令';

  @override
  String get importVersionType => '版本類型';

  @override
  String get importWindowMode => '視窗模式';

  @override
  String get importMemoryJVMArgumentsInstance => '記憶體、JVM 參數、實例隔離等設定儲存在 PCL-CE 程式目錄中，選擇該目錄後才能匯入';

  @override
  String get importPCLCEFolder => 'PCL-CE 資料夾';

  @override
  String importIncompleteAccountInfoSign(Object name) {
    return '$name（帳戶資訊不完整，請在帳戶中重新登入）';
  }

  @override
  String importAccountImportFailed(Object e) {
    return '帳戶匯入失敗：$e';
  }

  @override
  String backupBackupFileCorrupted(Object e) {
    return '備份檔案已損壞：$e';
  }

  @override
  String get backupBackupWasntCreatedPixel => '這個備份不是由 Pixel World 建立的，無法恢復';

  @override
  String get backupInvalidBackupManifest => '備份清單無效';

  @override
  String backupBackupManifestContainsUnsafe(Object e) {
    return '備份清單中有不安全的路徑：$e';
  }

  @override
  String get backupBackupManifestContainsDuplicate => '備份清單中有重複或互相包含的路徑';

  @override
  String get backupBackupSignatureMismatchBackup => '備份簽名不匹配：備份被修改過，或者不是在這台裝置上建立的';

  @override
  String backupBackupContainsSymbolicLink(Object name) {
    return '備份中有符號連結，不能恢復：$name';
  }

  @override
  String backupBackupContainsUnsafePath(Object name) {
    return '備份中有不安全的路徑：$name';
  }

  @override
  String backupBackupContainsFileNot(Object name) {
    return '備份中有清單以外的檔案：$name';
  }

  @override
  String backupBackupContainsDuplicateFile(Object name) {
    return '備份中有重複的檔案：$name';
  }

  @override
  String backupBackupContentsDontMatch(Object name) {
    return '備份內容與清單不符：$name';
  }

  @override
  String get backupBackupMissingFilesListed => '備份缺少清單中的檔案';

  @override
  String backupBackupContainsSymbolicLink2(Object name) {
    return '備份中有符號連結：$name';
  }

  @override
  String backupFileContentsDontMatch(Object rel) {
    return '檔案內容與備份清單不符：$rel';
  }

  @override
  String get networkCheckMojangOfficial => 'Mojang 官方來源';

  @override
  String get networkCheckGameLibraryDownloads => '下載遊戲和執行庫';

  @override
  String get networkCheckGameLoaderDownloadsMainland => '國內下載遊戲、載入器';

  @override
  String get networkCheckMicrosoftSign => 'Microsoft 登入';

  @override
  String get networkCheckMicrosoftAccountSign => '正版帳戶登入';

  @override
  String get networkCheckModsModpacksResourcePacks => '模組、整合包、資源包';

  @override
  String get networkCheckPixelWorldUpdates => 'Pixel World 更新';

  @override
  String get networkCheckUpdateChecksAnnouncementsDocs => '檢查更新、公告和文檔';

  @override
  String get networkCheckTimedOut => '超時';

  @override
  String get networkCheckSecureConnectionFailed => '安全連線失敗';

  @override
  String networkCheckConnectionFailed(Object error) {
    return '連線失敗（$error）';
  }

  @override
  String get microsoftMicrosoftAccountDoesntHave => '該微軟帳戶尚未建立 Xbox 檔案';

  @override
  String get microsoftUnderageAccountsNeedJoin => '未成年帳戶需要加入家庭組後才能登入';

  @override
  String microsoftMinecraftRejectedAzureApp(Object status) {
    return 'Minecraft 拒絕了這個 Azure 應用（$status Invalid app registration）。新應用需要先透過 Mojang 的審核（https://aka.ms/mce-reviewappid），審核透過後要用同一個 Client ID 重新登入；剛透過時可能要等一段時間才生效';
  }

  @override
  String microsoftRequestFailed(Object status, Object url, Object reason) {
    return '請求失敗（$status）：$url$reason';
  }

  @override
  String get microsoftAccountDoesntOwnMinecraft => '該帳戶沒有購買 Minecraft: Java Edition';

  @override
  String microsoftCouldntGetProfile(Object status, Object reason) {
    return '取得檔案失敗（$status）$reason';
  }

  @override
  String get microsoftSetAzureAppClient => '請先在「設定 - 其他」中填寫 Azure 應用 Client ID';

  @override
  String microsoftSignAccountHasExpired(Object name) {
    return '帳戶 $name 的登入已過期（匯入自 PCL-CE，無法續期），請使用微軟登入重新新增';
  }

  @override
  String get microsoftMicrosoftAccountHasExpired => '微軟帳戶已過期，請重新登入';

  @override
  String get docsOverview => '總覽';

  @override
  String get docsDownloadInstall => '下載與安裝';

  @override
  String get docsFirstLaunch => '第一次啟動';

  @override
  String get docsVersionsLoaders => '版本與載入器';

  @override
  String get docsAndroid => '安卓版';

  @override
  String get docsFAQTroubleshooting => '常見問題與排錯';

  @override
  String get docsLauncherAPI => '啟動器介面';

  @override
  String get docsDocumentEmpty => '文檔內容為空';

  @override
  String docsCouldntLoadDocsCheck(Object error) {
    return '無法取得文檔（$error），請檢查網路後重試';
  }

  @override
  String get docsNoCache => '沒有快取';

  @override
  String get instanceFilesFoldersCantOpenedPhones => '手機上暫時不能開啟資料夾';

  @override
  String instanceFilesCouldntMoveRecycleBin(Object stderr) {
    return '無法移到資源回收筒：$stderr';
  }

  @override
  String get instanceFilesCouldntMoveTrash => '無法移到廢紙簍';

  @override
  String get instanceFilesCouldntMoveRecycleBin2 => '無法移到資源回收筒';

  @override
  String instanceFilesUnknownNBTType(Object typeValue) {
    return '未知的 NBT 類型 $typeValue';
  }

  @override
  String safePathOnlyFilesVersionsWorking(Object rel) {
    return '只能存取版本執行目錄中的檔案：$rel';
  }

  @override
  String safePathInvalidPath(Object rel) {
    return '路徑無效：$rel';
  }

  @override
  String get safePathOnlyFilesVersionsWorking2 => '只能存取版本執行目錄中的檔案';

  @override
  String safePathPathContainsSymbolicLink(Object root) {
    return '路徑中有符號連結，為安全起見不能操作：$root';
  }

  @override
  String safePathCantDetermineRealLocation(Object root) {
    return '無法確認路徑的真實位置：$root';
  }

  @override
  String safePathPathActuallyPointsOutside(Object root) {
    return '路徑實際指向版本執行目錄之外：$root';
  }

  @override
  String get updaterGitHubRateLimitExceeded => 'GitHub 存取次數超出限制，請稍後再試';

  @override
  String updaterCouldntGetUpdateInfo(Object statusCode) {
    return '無法取得更新資訊（HTTP $statusCode）';
  }

  @override
  String get updaterInstallingUnknownAppsNeeds => '需要允許安裝未知應用';

  @override
  String updaterIncompleteDownloadBytes(Object received, Object size) {
    return '下載不完整（$received / $size 位元組）';
  }

  @override
  String get updaterFileVerificationFailedSHA => '檔案校驗失敗（SHA-256 不匹配）';

  @override
  String get updaterAutomaticUpdatesArentSupported => '這個平台暫不支援自動更新';

  @override
  String updaterUpdatePackageDoesntContain(Object appExeNames) {
    return '更新包中找不到主程式（$appExeNames）';
  }

  @override
  String get updaterText => ' 或 ';

  @override
  String get hudBridgeConversationNoLongerExists => '這個對話已經不存在了。';

  @override
  String get hudBridgeQuestionCantEmpty => '問題不能為空。';

  @override
  String get hudBridgeAIIsntSetUp => '還沒有設定 AI。請回到啟動器，在「設定 → AI」裡填寫介面、模型和 API Key。';

  @override
  String get hudBridgeConversationStillBeingAnswered => '這個對話還在回答，請稍等一下。';

  @override
  String hudBridgeWaitingConfirmation(Object label) {
    return '等待確認：$label';
  }

  @override
  String hudBridgeRunning(Object label) {
    return '正在執行：$label';
  }

  @override
  String yggdrasilConnectDoesntSupportYggdrasilConnect(Object name) {
    return '$name 不支援 Yggdrasil Connect';
  }

  @override
  String yggdrasilConnectHasInvalidYggdrasilConnect(Object name) {
    return '$name 的 Yggdrasil Connect 設定無效';
  }

  @override
  String yggdrasilConnectLauncherHasntRegisteredApp(Object name) {
    return '啟動器尚未在 $name 註冊應用，暫時無法使用 OAuth 登入';
  }

  @override
  String get yggdrasilConnectMalformedIDToken => 'ID 令牌格式錯誤';

  @override
  String get yggdrasilConnectInvalidIDTokenIssuer => 'ID 令牌無效（簽發者、受眾或有效期不符）';

  @override
  String yggdrasilConnectDoesntSupportDeviceCode(Object name) {
    return '$name 不支援裝置程式碼登入';
  }

  @override
  String get yggdrasilConnectNoProfileWasChosen => '授權時沒有選擇角色';

  @override
  String yggdrasilConnectAuthorizationAccountHasExpired(Object typeLabel, Object name) {
    return '$typeLabel 帳戶 $name 的授權已過期，請在帳戶中重新登入';
  }

  @override
  String oauthCantStartSign(Object status) {
    return '無法開始登入：$status';
  }

  @override
  String get oauthAuthorizationDenied => '已拒絕授權';

  @override
  String get oauthSignTimedOutPlease => '登入超時，請重試';

  @override
  String oauthSignFailed(Object status) {
    return '登入失敗：$status';
  }

  @override
  String oauthAuthenticationServerTemporarilyUnavailable(Object status) {
    return '驗證伺服器暫時不可用（$status），請稍後再試';
  }

  @override
  String accountsExternal(Object host) {
    return '外置登入 · $host';
  }

  @override
  String get accountsUsernamesMust316 => '使用者名需為 3-16 位字母、數字或下划線';

  @override
  String get yggdrasilAccountHasNoProfile => '該帳戶還沒有角色，請先到皮膚站建立角色';

  @override
  String get yggdrasilAuthenticationServerDidntReturn => '驗證伺服器沒有返回所選角色';

  @override
  String yggdrasilProfileNoLongerBelongs(Object name) {
    return '角色 $name 已不在該帳戶下，請重新新增帳戶';
  }

  @override
  String get yggdrasilApiEnterAuthenticationServerAddress => '請輸入驗證伺服器位址';

  @override
  String yggdrasilApiIsntValidAuthenticationServer(Object url) {
    return '$url 不是有效的驗證伺服器';
  }

  @override
  String yggdrasilApiAuthenticationServerReturnedHTTP(Object status) {
    return '驗證伺服器返回 HTTP $status';
  }

  @override
  String newsMinecraftWikiRequestFailed(Object statusCode) {
    return 'Minecraft Wiki 請求失敗（$statusCode）';
  }

  @override
  String get secureEncryptionFailed => '加密失敗';

  @override
  String get secureDecryptionFailed => '解密失敗';

  @override
  String get authlibInjectorVerificationFailedSHA256 => '校驗失敗（SHA-256 不匹配）';

  @override
  String authlibInjectorCouldntDownloadAuthlibInjector(Object e) {
    return '無法下載 authlib-injector：$e';
  }

  @override
  String get authSignCanceled => '已取消登入';

  @override
  String get aiToolsViewInstanceList => '查看實例列表';

  @override
  String get aiToolsViewInstanceInfo => '查看實例資訊';

  @override
  String aiToolsViewInfo(Object id) {
    return '查看 $id 的資訊';
  }

  @override
  String get aiToolsViewModList => '查看模組列表';

  @override
  String aiToolsViewMods(Object id) {
    return '查看 $id 的模組';
  }

  @override
  String get aiToolsViewFiles => '查看檔案';

  @override
  String aiToolsView(Object id, Object rel) {
    return '查看 $id/$rel';
  }

  @override
  String get aiToolsReadLog => '讀取日誌';

  @override
  String aiToolsRead(Object id, Object kind) {
    return '讀取 $id 的$kind';
  }

  @override
  String get aiToolsCrashReport => '崩潰報告';

  @override
  String get aiToolsDebugLog => '除錯日誌';

  @override
  String get aiToolsSearchMods => '搜尋模組';

  @override
  String aiToolsSearchModrinth(Object q) {
    return '在 Modrinth 搜尋「$q」';
  }

  @override
  String get aiToolsViewInstallableVersions => '查看可安裝的版本';

  @override
  String get aiToolsViewInstallableMinecraftVersions => '查看可安裝的 Minecraft 版本';

  @override
  String get aiToolsViewLoaderVersions => '查看載入器版本';

  @override
  String aiToolsViewVersions(Object game, Object label) {
    return '查看 $game 的 $label 版本';
  }

  @override
  String get aiToolsInstallNewInstance => '安裝新實例';

  @override
  String aiToolsSwitchCurrentInstance(Object id) {
    return '把目前實例切換為 $id';
  }

  @override
  String get aiToolsSearchResources => '搜尋資源';

  @override
  String aiToolsSearchModrinth2(Object f, Object label, Object q) {
    return '在 Modrinth 搜尋$f$label$q';
  }

  @override
  String aiToolsText(Object label) {
    return '$label 的';
  }

  @override
  String get aiToolsViewProjectDetails => '查看專案詳情';

  @override
  String aiToolsViewModrinthProject(Object ids) {
    return '查看 Modrinth 專案 $ids';
  }

  @override
  String aiToolsCompareModrinthProjects(Object count) {
    return '比較 $count 個 Modrinth 專案';
  }

  @override
  String get aiToolsInstallResource => '安裝資源';

  @override
  String aiToolsInstall(Object label, Object name) {
    return '安裝$label $name';
  }

  @override
  String aiToolsInstance(Object id) {
    return '實例：$id';
  }

  @override
  String aiToolsFileInto(Object fileName, Object fileSize, Object folder) {
    return '檔案：$fileName（$fileSize），放進 $folder';
  }

  @override
  String get aiToolsSourceModrinth => '來源：Modrinth';

  @override
  String get aiToolsViewJava => '查看 Java';

  @override
  String get aiToolsViewInstalledJava => '查看已安裝的 Java';

  @override
  String get aiToolsViewSystemInfo => '查看系統資訊';

  @override
  String get aiToolsSetInstanceJava => '設定實例的 Java';

  @override
  String aiToolsChangeJava(Object id, Object label) {
    return '把 $id 的 Java 改為$label';
  }

  @override
  String aiToolsBefore(Object old) {
    return '原來：$old';
  }

  @override
  String aiToolsAfter(Object label) {
    return '改為：$label';
  }

  @override
  String get aiToolsSetInstanceMemory => '設定實例的記憶體';

  @override
  String aiToolsChangeMemory(Object id, Object label) {
    return '把 $id 的記憶體改為$label';
  }

  @override
  String aiToolsBefore2(Object s) {
    return '原來：$s';
  }

  @override
  String aiToolsSystemMemoryGBTotal(Object total, Object free) {
    return '系統記憶體：共 $total GB，目前空閒 $free GB';
  }

  @override
  String get aiToolsReadConfigFile => '讀取設定檔';

  @override
  String commonRead(Object rel) {
    return '讀取 $rel';
  }

  @override
  String get aiToolsEditConfigFile => '修改設定檔';

  @override
  String aiToolsEditChanges(Object rel, Object count) {
    return '修改 $rel（$count 處）';
  }

  @override
  String get aiToolsOriginalFileBackedUp => '修改前會備份原檔案';

  @override
  String get aiToolsInstallMod => '安裝模組';

  @override
  String aiToolsInstallMod2(Object name) {
    return '安裝模組 $name';
  }

  @override
  String aiToolsFile(Object fileName, Object fileSize) {
    return '檔案：$fileName（$fileSize）';
  }

  @override
  String get aiToolsRequiredDependenciesInstalledToo => '會同時安裝必需的前置模組';

  @override
  String get aiToolsEnableDisableMods => '啟用或停用模組';

  @override
  String aiToolsMods(Object enabled, Object count) {
    return '$enabled $count 個模組';
  }

  @override
  String get aiToolsEnable => '啟用';

  @override
  String get aiToolsDisable => '停用';

  @override
  String get aiToolsBackUp => '備份';

  @override
  String aiToolsBackUpItems(Object count) {
    return '備份 $count 項';
  }

  @override
  String aiToolsAboutSavedBackupsGame(Object size) {
    return '大小約 $size，儲存到遊戲資料夾的 backups 中';
  }

  @override
  String get aiToolsViewBackups => '查看備份';

  @override
  String aiToolsViewBackups2(Object id) {
    return '查看 $id 的備份';
  }

  @override
  String get commonDeleteFiles => '刪除檔案';

  @override
  String aiToolsDeleteItemsMoveRecycle(Object count) {
    return '刪除 $count 項（移到資源回收筒）';
  }

  @override
  String get aiToolsReplaceMod => '替換模組';

  @override
  String aiToolsReplaceMod2(Object name) {
    return '替換模組 $name';
  }

  @override
  String aiToolsOldFile(Object name) {
    return '舊檔案：$name';
  }

  @override
  String aiToolsNewFileFromModrinth(Object fileName, Object name) {
    return '新檔案：$fileName（$name，來自 Modrinth）';
  }

  @override
  String get aiToolsOldFileBackedUp => '舊檔案會先備份，再移到資源回收筒';

  @override
  String get aiToolsRestoreFromBackup => '從備份恢復';

  @override
  String aiToolsRestoreFromBackup2(Object name) {
    return '從備份 $name 恢復';
  }

  @override
  String aiToolsWillRestoreFiles(Object paths, Object files, Object bytes) {
    return '將恢復：$paths（$files 個檔案，$bytes）';
  }

  @override
  String get aiToolsNoteBackupWasCreated => '注意：這是舊版 Pixel World 建立的備份，沒有簽名，無法確認內容未被修改過';

  @override
  String get aiToolsItsExtractedTemporaryFolder => '先解壓到暫存資料夾並校驗，成功後才把目前的對應內容備份並移到資源回收筒';

  @override
  String aiToolsInstall2(Object shown) {
    return '安裝 $shown';
  }

  @override
  String aiToolsInstanceName(Object shown) {
    return '實例名稱：$shown';
  }

  @override
  String aiToolsDownloadsFromMayTake(Object useMirror) {
    return '從$useMirror下載，可能需要幾分鐘；進度可以在任務頁查看';
  }

  @override
  String aiToolsNoteHasNoIris(Object id) {
    return '注意：$id 中沒有找到 Iris 或 OptiFine，光影包需要它們才能使用';
  }

  @override
  String get workspaceToolsViewAccessibleFolders => '查看可存取的資料夾';

  @override
  String get workspaceToolsViewFolder => '查看目錄';

  @override
  String workspaceToolsView(Object rel) {
    return '查看 $rel';
  }

  @override
  String get workspaceToolsFindFiles => '查找檔案';

  @override
  String workspaceToolsFind(Object rel, Object pattern) {
    return '在 $rel 中查找 $pattern';
  }

  @override
  String get workspaceToolsSearchFileContents => '搜尋檔案內容';

  @override
  String workspaceToolsSearch(Object rel, Object pattern) {
    return '在 $rel 中搜尋「$pattern」';
  }

  @override
  String get workspaceToolsReadFile => '讀取檔案';

  @override
  String get workspaceToolsWriteFile => '寫入檔案';

  @override
  String workspaceToolsLines(Object length, Object count) {
    return '$length，$count 行';
  }

  @override
  String get workspaceToolsOriginalFileWillReplaced => '原檔案會被替換';

  @override
  String get workspaceToolsEditFile => '修改檔案';

  @override
  String workspaceToolsEdit(Object rel, Object count) {
    return '修改 $rel$count';
  }

  @override
  String workspaceToolsOriginal(Object oldText) {
    return '原文：\n$oldText';
  }

  @override
  String workspaceToolsChange(Object newText) {
    return '改為：\n$newText';
  }

  @override
  String get workspaceToolsMoveFile => '移動檔案';

  @override
  String workspaceToolsMove(Object rel, Object rel2) {
    return '把 $rel 移動到 $rel2';
  }

  @override
  String workspaceToolsDelete(Object rel) {
    return '刪除 $rel';
  }

  @override
  String get workspaceToolsWholeFolderItsContents => '整個資料夾及其中的內容';

  @override
  String workspaceToolsFile(Object lengthSync) {
    return '檔案，$lengthSync';
  }

  @override
  String get workspaceToolsMovedRecycleBin => '會移到資源回收筒';

  @override
  String webToolsSearch(Object q) {
    return '搜尋「$q」';
  }

  @override
  String get webToolsOpenWebPage => '開啟網頁';

  @override
  String webToolsOpen(Object host, Object path) {
    return '開啟 $host$path';
  }

  @override
  String get webToolsSearchMinecraftWiki => '搜尋 Minecraft Wiki';

  @override
  String webToolsSearchMinecraftWiki2(Object q) {
    return '在 Minecraft Wiki 中搜尋「$q」';
  }

  @override
  String get aiClientQwen => '通義千問';

  @override
  String get aiClientOllamaLocal => 'Ollama（本機）';

  @override
  String get aiClientEnterAPIAddressFirst => '請先填寫介面位址';

  @override
  String aiClientCouldntGetModelList(Object s) {
    return '取得模型列表失敗：$s';
  }

  @override
  String aiClientCantConnect(Object host, Object message) {
    return '無法連線 $host：$message';
  }

  @override
  String aiClientSecureConnectionFailed(Object host) {
    return '與 $host 的安全連線失敗';
  }

  @override
  String get aiClientAPIDidntReturnModel => '介面返回的不是模型列表，請檢查介面位址';

  @override
  String aiClientConnectionTimedOut(Object host) {
    return '連線 $host 超時';
  }

  @override
  String get aiClientModelRefusedAnswerRequest => '模型拒絕回答這個請求';

  @override
  String get aiClientModelReturnedNothingCheck => '模型沒有返回內容，請檢查介面位址和模型名';

  @override
  String get aiClientAnswerHitLengthLimit => '\n\n（回答達到長度上限，已截斷）';

  @override
  String aiClientConnectionWasInterrupted(Object host, Object message) {
    return '與 $host 的連線中斷：$message';
  }

  @override
  String aiClientSecureConnectionFailedCheck(Object host) {
    return '與 $host 的安全連線失敗，請檢查介面位址或網路代理';
  }

  @override
  String aiClientHasntRespondedLongTime(Object host) {
    return '$host 長時間沒有回應，請稍後重試';
  }

  @override
  String get aiClientConversationLongerThanModel => '對話內容超出了模型能處理的長度，請點對話上方的「壓縮上下文」按鈕，或新建一個對話';

  @override
  String aiClientModelDoesntExistIsnt(Object model) {
    return '模型「$model」不存在或不可用，請檢查模型名，或點模型旁的按鈕取得可用的模型';
  }

  @override
  String get aiClientInsufficientBalanceQuotaTop => '帳戶餘額或額度不足，請到服務商的控制台充值或檢查額度';

  @override
  String get aiClientAIServiceOverloadedPlease => 'AI 服務目前過載，請稍後重試';

  @override
  String get aiClientRequestRejectedModelProvider => '請求被拒絕，可能是這個模型或服務商不支援目前的請求方式';

  @override
  String get aiClientAPIKeyInvalidExpired => 'API Key 無效或已過期，請在設定中檢查';

  @override
  String get aiClientNoPermissionUseModel => '沒有權限使用這個模型或介面，請檢查帳戶權限或地區限制';

  @override
  String get aiClientAPIAddressModelDoesnt => '介面位址或模型不存在，請檢查介面位址（OpenAI 相容介面通常以 /v1 結尾）';

  @override
  String get aiClientAIServiceTimedOut => 'AI 服務回應超時，請稍後重試';

  @override
  String get aiClientContentSentTooLong => '傳送的內容太長，請新建一個對話';

  @override
  String get aiClientTooManyRequestsPlease => '請求太頻繁，請稍後再試';

  @override
  String get aiClientAIServiceTemporarilyUnavailable => 'AI 服務暫時不可用，請稍後重試';

  @override
  String aiClientRequestFailed(Object code, Object raw) {
    return '請求失敗（$code）：$raw';
  }

  @override
  String get aiClientNoDetailsReturned => '沒有返回說明';

  @override
  String get mcpClientExaSearch => 'Exa 搜尋';

  @override
  String get mcpClientInvalidURL => '網址無效';

  @override
  String get mcpClientOnlyHttpHttpsSupported => '只支援 http / https';

  @override
  String get mcpClientRemoteServicesMustUse => '遠程服務請使用 https；http 只能連線本機（127.0.0.1 / localhost）';

  @override
  String mcpClientServiceReturnedError(Object err) {
    return '服務返回錯誤：$err';
  }

  @override
  String get mcpClientAccessDeniedCheckAccess => '存取被拒絕，檢查存取令牌';

  @override
  String get mcpClientWrongAddressServiceClosed => '位址不對，或服務已經關閉了這個會話';

  @override
  String get mcpClientResponseTooLarge => '回應太大';

  @override
  String get mcpClientMalformedResponse => '回應格式不對';

  @override
  String get mcpClientTimedOutWaitingService => '等待服務回應超時';

  @override
  String get mcpClientServicesResponseIsntValid => '服務的回應不是有效的 JSON';

  @override
  String mcpClientCantReachService(Object message) {
    return '連不上服務：$message';
  }

  @override
  String mcpClientConnectionError(Object message) {
    return '連線出錯：$message';
  }

  @override
  String get mcpClientServiceDisconnectedWithoutResponding => '服務沒有返回回應就斷開了';

  @override
  String get mcpClientServiceProcessHasExited => '服務處理程序已經退出';

  @override
  String mcpClientServiceProcessHasExited2(Object code) {
    return '服務處理程序已經退出（退出程式碼 $code）';
  }

  @override
  String get mcpClientPixelWorldDoesntSupport => 'Pixel World 不支援這個請求';

  @override
  String get mcpClientServiceProvidesNoTools => '這個服務沒有提供工具';

  @override
  String get mcpHubAskEveryTime => '每次詢問';

  @override
  String get mcpHubReadOnlyRejectChanges => '唯讀（直接拒絕修改）';

  @override
  String mcpHubCall(Object name, Object name2) {
    return '調用「$name」的 $name2';
  }

  @override
  String get mcpHubServiceDeclaresToolRead => '服務聲明這個工具唯讀取，不做修改';

  @override
  String mcpHubArguments(Object shown) {
    return '參數：$shown';
  }

  @override
  String get mcpHubExited => '退出';

  @override
  String get mcpHubUnreachable => '連不上';

  @override
  String get mcpHubLocalJarServicesCant => '安卓上暫時還不能執行本機 jar 服務，可以改用遠程（HTTP）服務';

  @override
  String mcpHubJarFileNotFound(Object jar) {
    return '找不到 jar 檔案：$jar';
  }

  @override
  String get mcpHubPrepareJavaMCPService => '準備 MCP 服務的 Java';

  @override
  String get aiChatModelReturnedNoSummary => '模型沒有返回摘要';

  @override
  String aiChatCouldntCompactContext(Object e) {
    return '壓縮上下文失敗：$e';
  }

  @override
  String get aiChatTooManyActionsRound => '這一輪的操作次數過多，已暫停。可以傳送訊息讓 AI 繼續';

  @override
  String aiChatAnswerInterrupted(Object partial) {
    return '$partial\n\n（回答中斷）';
  }

  @override
  String get aiChatNoToolsAvailable => '沒有可用的工具';

  @override
  String aiChatStopped(Object partial) {
    return '$partial\n\n（已停止）';
  }

  @override
  String agentRootCurrentInstance(Object id) {
    return '目前實例（$id）';
  }

  @override
  String get agentRootDownloads => '下載目錄';

  @override
  String get aiPromptMyGameCrashedBelow => '我的遊戲崩潰了，下面是啟動器收集的崩潰資訊，請幫我分析原因並告訴我怎麼解決。';

  @override
  String get aiReplyLanguage => '繁體中文（台灣用語）';

  @override
  String get commonListSeparator => '、';

  @override
  String get commonClauseSeparator => '；';

  @override
  String get commonComma => '，';

  @override
  String get commonColon => '：';

  @override
  String commonParenthesized(Object text) {
    return '（$text）';
  }

  @override
  String get aiSearchEngineAuto => '內建（Exa，失敗時 DuckDuckGo、Bing）';

  @override
  String get aiSearchEngineExa => 'Exa（Key 可以不填）';

  @override
  String get aiSearchEngineBing => 'Bing（英文結果更可靠）';

  @override
  String get aiSearchEngineSearxng => 'SearXNG（自架或公共實例）';

  @override
  String get aiSearchEngineTavily => 'Tavily（需要 Key）';

  @override
  String get aiSearchEngineBrave => 'Brave Search（需要 Key）';

  @override
  String get aiSearchEngineSerper => 'Serper / Google（需要 Key）';

  @override
  String get downloadLoadFailedRetry => '連不上 · 重試';

  @override
  String get precheckOwnershipRequired => '為了正版驗證，需要先登入一次購買了 Minecraft 的微軟帳戶，才能使用離線帳戶和外置登入。';

  @override
  String get launchDialogsVerifyOwnershipFirst => '需要先驗證正版';

  @override
  String get launchDialogsOwnershipRequiredBody =>
      'Minecraft 是付費遊戲。按照 Mojang 的規定，需要先登入一次購買了 Minecraft 的微軟帳戶，才能用離線帳戶或外置登入開始遊戲。\n\n驗證一次之後，離線帳戶和外置登入就可以一直使用了。';

  @override
  String get launchDialogsBuyGame => '去購買';

  @override
  String get launchDialogsSignInMicrosoft => '登入微軟帳戶';

  @override
  String get oobeAccountHintVerified => '玩正版用微軟帳戶，也可以用離線帳戶或外置登入。';

  @override
  String get oobeAccountHintUnverified => '為了正版驗證，請先登入購買了 Minecraft 的微軟帳戶，之後也能用離線帳戶和外置登入。';

  @override
  String get oobeAvailableAfterVerification => '驗證正版後可用';

  @override
  String get accountsOwnershipNotice => '說明：為了正版驗證，離線帳戶和外置登入需要先登入一次擁有 Minecraft 的微軟帳戶，確認你購買了遊戲後才能新增和使用。';

  @override
  String get touchTipTitle => '試試 TouchController';

  @override
  String touchTipBody(Object instance) {
    return 'TouchController 是第三方模組，為 Java 版帶來基岩版風格的觸控操作，按鍵佈局可以自己調整。它還在早期開發階段，可能會遇到問題。\n\n裝進「$instance」後，下次啟動時啟動器會把遊戲內的觸控交給它，並隱藏內建的虛擬按鍵；想換回來，在模組裡停用它就行。';
  }

  @override
  String get touchTipInstall => '安裝';

  @override
  String get touchTipNever => '不再推薦';

  @override
  String touchTipInstalled(Object instance) {
    return '已為 $instance 安裝 TouchController，下次啟動生效';
  }

  @override
  String touchTipBodyLaunch(Object instance) {
    return 'TouchController 是第三方模組，為 Java 版帶來基岩版風格的觸控操作，按鍵佈局可以自己調整。它還在早期開發階段，可能會遇到問題。\n\n裝進「$instance」後，這次啟動就由它接管遊戲內的觸控，並隱藏內建的虛擬按鍵；想換回來，在模組裡停用它就行。';
  }

  @override
  String get touchTipLaunchAnyway => '直接啟動';

  @override
  String get touchTipInstallAndLaunch => '安裝並啟動';
}
