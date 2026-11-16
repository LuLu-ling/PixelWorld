import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @commonAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get commonAuto;

  /// No description provided for @commonCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get commonCustom;

  /// No description provided for @commonDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get commonDefault;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get commonDownload;

  /// No description provided for @commonOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get commonOpen;

  /// No description provided for @commonView.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get commonView;

  /// No description provided for @commonDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败：{error}'**
  String commonDeleteFailed(String error);

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get navHome;

  /// No description provided for @navDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get navDownload;

  /// No description provided for @navTools.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get navTools;

  /// No description provided for @navFiles.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get navFiles;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @navAiAssistant.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get navAiAssistant;

  /// No description provided for @subVersions.
  ///
  /// In zh, this message translates to:
  /// **'实例'**
  String get subVersions;

  /// No description provided for @subLog.
  ///
  /// In zh, this message translates to:
  /// **'游戏日志'**
  String get subLog;

  /// No description provided for @subInstance.
  ///
  /// In zh, this message translates to:
  /// **'实例详情'**
  String get subInstance;

  /// No description provided for @subTasks.
  ///
  /// In zh, this message translates to:
  /// **'任务'**
  String get subTasks;

  /// No description provided for @subDiagnose.
  ///
  /// In zh, this message translates to:
  /// **'错误分析'**
  String get subDiagnose;

  /// No description provided for @tooltipBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get tooltipBack;

  /// No description provided for @tooltipInstances.
  ///
  /// In zh, this message translates to:
  /// **'实例列表'**
  String get tooltipInstances;

  /// No description provided for @tooltipNotices.
  ///
  /// In zh, this message translates to:
  /// **'公告'**
  String get tooltipNotices;

  /// No description provided for @greetingLateNight.
  ///
  /// In zh, this message translates to:
  /// **'夜深了'**
  String get greetingLateNight;

  /// No description provided for @greetingMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get greetingMorning;

  /// No description provided for @greetingNoon.
  ///
  /// In zh, this message translates to:
  /// **'中午好'**
  String get greetingNoon;

  /// No description provided for @greetingAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In zh, this message translates to:
  /// **'{greeting}，{name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @greetingAdventure.
  ///
  /// In zh, this message translates to:
  /// **'准备好冒险了吗？'**
  String get greetingAdventure;

  /// No description provided for @tasksIdle.
  ///
  /// In zh, this message translates to:
  /// **'当前无后台任务'**
  String get tasksIdle;

  /// No description provided for @tasksGamesRunning.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个游戏实例运行中'**
  String tasksGamesRunning(int count);

  /// No description provided for @tasksMore.
  ///
  /// In zh, this message translates to:
  /// **'{title} · 共 {count} 个任务'**
  String tasksMore(String title, int count);

  /// No description provided for @accountAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加账户'**
  String get accountAdd;

  /// No description provided for @accountMicrosoft.
  ///
  /// In zh, this message translates to:
  /// **'正版'**
  String get accountMicrosoft;

  /// No description provided for @accountOffline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get accountOffline;

  /// No description provided for @accountExternal.
  ///
  /// In zh, this message translates to:
  /// **'外置'**
  String get accountExternal;

  /// No description provided for @windowMinimize.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get windowMinimize;

  /// No description provided for @windowMaximize.
  ///
  /// In zh, this message translates to:
  /// **'最大化'**
  String get windowMaximize;

  /// No description provided for @windowRestore.
  ///
  /// In zh, this message translates to:
  /// **'还原'**
  String get windowRestore;

  /// No description provided for @windowClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get windowClose;

  /// No description provided for @comingSoon.
  ///
  /// In zh, this message translates to:
  /// **'这部分功能正在迁移中'**
  String get comingSoon;

  /// No description provided for @settingsGroupGame.
  ///
  /// In zh, this message translates to:
  /// **'游戏'**
  String get settingsGroupGame;

  /// No description provided for @settingsLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get settingsLaunch;

  /// No description provided for @settingsManage.
  ///
  /// In zh, this message translates to:
  /// **'游戏管理'**
  String get settingsManage;

  /// No description provided for @settingsGroupLauncher.
  ///
  /// In zh, this message translates to:
  /// **'启动器'**
  String get settingsGroupLauncher;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'个性化'**
  String get settingsAppearance;

  /// No description provided for @settingsMisc.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get settingsMisc;

  /// No description provided for @settingsAiModel.
  ///
  /// In zh, this message translates to:
  /// **'模型与接口'**
  String get settingsAiModel;

  /// No description provided for @settingsAiTools.
  ///
  /// In zh, this message translates to:
  /// **'工具与服务'**
  String get settingsAiTools;

  /// No description provided for @settingsAiWorkspace.
  ///
  /// In zh, this message translates to:
  /// **'工作区与联网'**
  String get settingsAiWorkspace;

  /// No description provided for @settingsGroupAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsGroupAbout;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于与致谢'**
  String get settingsAbout;

  /// No description provided for @settingsDocs.
  ///
  /// In zh, this message translates to:
  /// **'使用文档'**
  String get settingsDocs;

  /// No description provided for @settingsAiIntro.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手使用你自己的 AI 服务。支持 OpenAI 兼容接口（DeepSeek、通义千问、Kimi、OpenRouter、本机 Ollama 等）和 Anthropic 接口；费用由你的 AI 服务商收取。'**
  String get settingsAiIntro;

  /// No description provided for @languageGroup.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageGroup;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get language;

  /// No description provided for @languageHint.
  ///
  /// In zh, this message translates to:
  /// **'启动器界面使用的语言；「自动设置游戏语言」也会跟随它'**
  String get languageHint;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @colorMode.
  ///
  /// In zh, this message translates to:
  /// **'颜色模式'**
  String get colorMode;

  /// No description provided for @colorModeHint.
  ///
  /// In zh, this message translates to:
  /// **'启动器界面的明暗模式'**
  String get colorModeHint;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @uiScale.
  ///
  /// In zh, this message translates to:
  /// **'界面缩放'**
  String get uiScale;

  /// No description provided for @uiScaleFixed.
  ///
  /// In zh, this message translates to:
  /// **'整个启动器按这个比例显示'**
  String get uiScaleFixed;

  /// No description provided for @uiScaleAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动：按屏幕尺寸计算，当前为 {percent}%'**
  String uiScaleAuto(int percent);

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get themeColor;

  /// No description provided for @themeColorAuto.
  ///
  /// In zh, this message translates to:
  /// **'跟随背景：按 Material Design 3 从背景图片取色，换图片后自动更新'**
  String get themeColorAuto;

  /// No description provided for @themeColorManual.
  ///
  /// In zh, this message translates to:
  /// **'按 Material Design 3 从主题色生成整套浅色与深色配色'**
  String get themeColorManual;

  /// No description provided for @themeFollowBackground.
  ///
  /// In zh, this message translates to:
  /// **'跟随背景'**
  String get themeFollowBackground;

  /// No description provided for @themeManual.
  ///
  /// In zh, this message translates to:
  /// **'手动选择'**
  String get themeManual;

  /// No description provided for @themeRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get themeRecommended;

  /// No description provided for @themeCandidate.
  ///
  /// In zh, this message translates to:
  /// **'候选 {index}'**
  String themeCandidate(int index);

  /// No description provided for @homeGroup.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeGroup;

  /// No description provided for @homeLayout.
  ///
  /// In zh, this message translates to:
  /// **'首页布局'**
  String get homeLayout;

  /// No description provided for @homeLayoutStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get homeLayoutStandard;

  /// No description provided for @homeLayoutSplit.
  ///
  /// In zh, this message translates to:
  /// **'上下'**
  String get homeLayoutSplit;

  /// No description provided for @homeLayoutMinimal.
  ///
  /// In zh, this message translates to:
  /// **'极简'**
  String get homeLayoutMinimal;

  /// No description provided for @homeLayoutStandardHint.
  ///
  /// In zh, this message translates to:
  /// **'标准：大卡片、公告与快捷按钮、最近游玩'**
  String get homeLayoutStandardHint;

  /// No description provided for @homeLayoutSplitHint.
  ///
  /// In zh, this message translates to:
  /// **'上下：当前实例在顶部，开始游戏和存档在底部，中间留给背景；选背景图片时自动切到这个布局'**
  String get homeLayoutSplitHint;

  /// No description provided for @homeLayoutMinimalHint.
  ///
  /// In zh, this message translates to:
  /// **'极简：只在底部留一条，放当前实例和开始游戏'**
  String get homeLayoutMinimalHint;

  /// No description provided for @homeHints.
  ///
  /// In zh, this message translates to:
  /// **'显示使用提示'**
  String get homeHints;

  /// No description provided for @homeHintsHint.
  ///
  /// In zh, this message translates to:
  /// **'正在使用的版本与免费声明'**
  String get homeHintsHint;

  /// No description provided for @homeNews.
  ///
  /// In zh, this message translates to:
  /// **'显示 Minecraft 版本动态'**
  String get homeNews;

  /// No description provided for @homeNewsHint.
  ///
  /// In zh, this message translates to:
  /// **'最新的正式版与快照，简介来自中文 Minecraft Wiki'**
  String get homeNewsHint;

  /// No description provided for @bgImage.
  ///
  /// In zh, this message translates to:
  /// **'背景图片'**
  String get bgImage;

  /// No description provided for @bgImageFiles.
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get bgImageFiles;

  /// No description provided for @bgImageInvalid.
  ///
  /// In zh, this message translates to:
  /// **'无法使用这张图片：{error}'**
  String bgImageInvalid(String error);

  /// No description provided for @bgImageSet.
  ///
  /// In zh, this message translates to:
  /// **'显示在整个窗口后面，界面面板会变成毛玻璃'**
  String get bgImageSet;

  /// No description provided for @bgImageUnset.
  ///
  /// In zh, this message translates to:
  /// **'选择一张图片作为启动器的背景（只在电脑上生效）'**
  String get bgImageUnset;

  /// No description provided for @bgImageChange.
  ///
  /// In zh, this message translates to:
  /// **'换一张…'**
  String get bgImageChange;

  /// No description provided for @bgImageChoose.
  ///
  /// In zh, this message translates to:
  /// **'选择图片…'**
  String get bgImageChoose;

  /// No description provided for @bgImageRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get bgImageRemove;

  /// No description provided for @bgFit.
  ///
  /// In zh, this message translates to:
  /// **'契合度'**
  String get bgFit;

  /// No description provided for @bgFitFill.
  ///
  /// In zh, this message translates to:
  /// **'填充'**
  String get bgFitFill;

  /// No description provided for @bgFitFit.
  ///
  /// In zh, this message translates to:
  /// **'适应'**
  String get bgFitFit;

  /// No description provided for @bgFitStretch.
  ///
  /// In zh, this message translates to:
  /// **'拉伸'**
  String get bgFitStretch;

  /// No description provided for @bgFitTile.
  ///
  /// In zh, this message translates to:
  /// **'平铺'**
  String get bgFitTile;

  /// No description provided for @bgFitCenter.
  ///
  /// In zh, this message translates to:
  /// **'居中'**
  String get bgFitCenter;

  /// No description provided for @bgFitSpan.
  ///
  /// In zh, this message translates to:
  /// **'跨区'**
  String get bgFitSpan;

  /// No description provided for @bgFitFillHint.
  ///
  /// In zh, this message translates to:
  /// **'填充：铺满整个窗口，多出来的部分裁掉'**
  String get bgFitFillHint;

  /// No description provided for @bgFitFitHint.
  ///
  /// In zh, this message translates to:
  /// **'适应：完整显示整张图片，空出来的地方用图片的颜色填上'**
  String get bgFitFitHint;

  /// No description provided for @bgFitStretchHint.
  ///
  /// In zh, this message translates to:
  /// **'拉伸：拉伸到窗口大小，图片可能变形'**
  String get bgFitStretchHint;

  /// No description provided for @bgFitTileHint.
  ///
  /// In zh, this message translates to:
  /// **'平铺：按图片原来的大小重复铺满窗口'**
  String get bgFitTileHint;

  /// No description provided for @bgFitCenterHint.
  ///
  /// In zh, this message translates to:
  /// **'居中：按图片原来的大小放在窗口中间'**
  String get bgFitCenterHint;

  /// No description provided for @bgFitSpanHint.
  ///
  /// In zh, this message translates to:
  /// **'跨区：图片铺满整个桌面（所有屏幕），窗口只显示自己所在位置的那一块，移动窗口时背景不动'**
  String get bgFitSpanHint;

  /// No description provided for @bgBlur.
  ///
  /// In zh, this message translates to:
  /// **'背景模糊'**
  String get bgBlur;

  /// No description provided for @bgBlurHint.
  ///
  /// In zh, this message translates to:
  /// **'整张背景图片的模糊程度；为 0 时背景保持清晰'**
  String get bgBlurHint;

  /// No description provided for @bgDim.
  ///
  /// In zh, this message translates to:
  /// **'背景暗化'**
  String get bgDim;

  /// No description provided for @bgDimDarkHint.
  ///
  /// In zh, this message translates to:
  /// **'在背景图片上压一层黑色，图片很亮或很花时调高，界面和文字更清楚'**
  String get bgDimDarkHint;

  /// No description provided for @bgDimLightHint.
  ///
  /// In zh, this message translates to:
  /// **'在背景图片上压一层白色，图片很暗或很花时调高，界面和文字更清楚'**
  String get bgDimLightHint;

  /// No description provided for @bgPanelBlur.
  ///
  /// In zh, this message translates to:
  /// **'面板模糊'**
  String get bgPanelBlur;

  /// No description provided for @bgPanelBlurHint.
  ///
  /// In zh, this message translates to:
  /// **'只模糊面板后面的部分（毛玻璃），与背景模糊互不影响；为 0 时面板后面也是清晰的'**
  String get bgPanelBlurHint;

  /// No description provided for @bgOpacity.
  ///
  /// In zh, this message translates to:
  /// **'面板不透明度'**
  String get bgOpacity;

  /// No description provided for @bgOpacityHint.
  ///
  /// In zh, this message translates to:
  /// **'面板越透明，背景图片越明显'**
  String get bgOpacityHint;

  /// No description provided for @bgGlow.
  ///
  /// In zh, this message translates to:
  /// **'封面色散'**
  String get bgGlow;

  /// No description provided for @bgGlowHint.
  ///
  /// In zh, this message translates to:
  /// **'最近游玩的卡片上，从封面取出的颜色向外扩散的强弱'**
  String get bgGlowHint;

  /// No description provided for @bgSolid.
  ///
  /// In zh, this message translates to:
  /// **'降低透明度'**
  String get bgSolid;

  /// No description provided for @bgSolidHint.
  ///
  /// In zh, this message translates to:
  /// **'保留背景图片，但面板几乎不透明，适合图片很花或者想要更清楚的文字'**
  String get bgSolidHint;

  /// No description provided for @aboutDeveloper.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 的开发者'**
  String get aboutDeveloper;

  /// No description provided for @aboutSponsor.
  ///
  /// In zh, this message translates to:
  /// **'赞助作者'**
  String get aboutSponsor;

  /// No description provided for @aboutAppVersion.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 启动器 {version}'**
  String aboutAppVersion(String version);

  /// No description provided for @aboutDisclaimer.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 是第三方 Minecraft 启动器，本项目为轻度使用 PCL 仓储库，界面布局参考 PCL 社区版（PCL-CE）。PCL 由龙腾猫跃开发，本软件与 PCL 及其作者无关，也不代表 PCL 官方。请勿就本软件的问题打扰 PCL 作者。'**
  String get aboutDisclaimer;

  /// No description provided for @aboutSource.
  ///
  /// In zh, this message translates to:
  /// **'源代码'**
  String get aboutSource;

  /// No description provided for @aboutSourceHint.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 以 Apache-2.0 协议开源'**
  String get aboutSourceHint;

  /// No description provided for @aboutGuide.
  ///
  /// In zh, this message translates to:
  /// **'PCL 存储库合理使用指南'**
  String get aboutGuide;

  /// No description provided for @aboutGuideHint.
  ///
  /// In zh, this message translates to:
  /// **'本项目遵循的命名、署名与使用规则，随源代码一同发布'**
  String get aboutGuideHint;

  /// No description provided for @aboutCredits.
  ///
  /// In zh, this message translates to:
  /// **'致谢'**
  String get aboutCredits;

  /// No description provided for @aboutPclCeHint.
  ///
  /// In zh, this message translates to:
  /// **'PCL 社区版（PCL-CE）的开发者们，本软件与 PCL-CE 的数据兼容'**
  String get aboutPclCeHint;

  /// No description provided for @aboutAndroidRuntime.
  ///
  /// In zh, this message translates to:
  /// **'安卓版游戏运行时'**
  String get aboutAndroidRuntime;

  /// No description provided for @aboutAndroidRuntimeHint.
  ///
  /// In zh, this message translates to:
  /// **'基于 Amethyst-Android（LGPL-3.0）、MobileGlues、Krypton Wrapper、LWJGL 与 OpenJDK，单独以 LGPL-3.0 开源'**
  String get aboutAndroidRuntimeHint;

  /// No description provided for @aboutFlutterHint.
  ///
  /// In zh, this message translates to:
  /// **'跨平台界面框架'**
  String get aboutFlutterHint;

  /// No description provided for @aboutMaterialHint.
  ///
  /// In zh, this message translates to:
  /// **'界面设计语言与配色算法'**
  String get aboutMaterialHint;

  /// No description provided for @aboutTrademark.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft 是 Mojang Studios 的商标。本软件不是官方 Minecraft 产品，未经 Mojang 或 Microsoft 批准，也与其无关。'**
  String get aboutTrademark;

  /// No description provided for @renderScale.
  ///
  /// In zh, this message translates to:
  /// **'渲染比例：{percent}%'**
  String renderScale(int percent);

  /// No description provided for @renderScaleHint.
  ///
  /// In zh, this message translates to:
  /// **'游戏分辨率 {width} × {height}。降低后画面更模糊，但帧率更高、发热更少'**
  String renderScaleHint(int width, int height);

  /// No description provided for @renderer.
  ///
  /// In zh, this message translates to:
  /// **'渲染器'**
  String get renderer;

  /// No description provided for @rendererGpu.
  ///
  /// In zh, this message translates to:
  /// **'显卡：{gpu}'**
  String rendererGpu(String gpu);

  /// No description provided for @rendererAuto.
  ///
  /// In zh, this message translates to:
  /// **'当前会使用：{renderer}（{reason}）'**
  String rendererAuto(String renderer, String reason);

  /// No description provided for @rendererPerInstance.
  ///
  /// In zh, this message translates to:
  /// **'可以在实例设置里为单个实例另选渲染器'**
  String get rendererPerInstance;

  /// No description provided for @isolation.
  ///
  /// In zh, this message translates to:
  /// **'实例隔离'**
  String get isolation;

  /// No description provided for @isolationHint.
  ///
  /// In zh, this message translates to:
  /// **'新实例首次启动时按此规则决定，之后在实例设置中单独修改'**
  String get isolationHint;

  /// No description provided for @isolationOff.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get isolationOff;

  /// No description provided for @isolationModable.
  ///
  /// In zh, this message translates to:
  /// **'隔离可安装模组的实例'**
  String get isolationModable;

  /// No description provided for @isolationUnstable.
  ///
  /// In zh, this message translates to:
  /// **'隔离非正式版'**
  String get isolationUnstable;

  /// No description provided for @isolationModableUnstable.
  ///
  /// In zh, this message translates to:
  /// **'隔离可安装模组的实例与非正式版'**
  String get isolationModableUnstable;

  /// No description provided for @isolationAll.
  ///
  /// In zh, this message translates to:
  /// **'隔离所有实例'**
  String get isolationAll;

  /// No description provided for @gameHud.
  ///
  /// In zh, this message translates to:
  /// **'游戏内叠加层'**
  String get gameHud;

  /// No description provided for @gameHudHint.
  ///
  /// In zh, this message translates to:
  /// **'在游戏画面上显示一个可拖动的小球，点开可以看基础信息、问 AI'**
  String get gameHudHint;

  /// No description provided for @gameHudAi.
  ///
  /// In zh, this message translates to:
  /// **'游戏内 AI'**
  String get gameHudAi;

  /// No description provided for @gameHudAiHint.
  ///
  /// In zh, this message translates to:
  /// **'在小球菜单里显示「问 AI」，使用「设置 → AI 排障」里的接口和模型'**
  String get gameHudAiHint;

  /// No description provided for @gameHudAiLog.
  ///
  /// In zh, this message translates to:
  /// **'提问时附带最近日志'**
  String get gameHudAiLog;

  /// No description provided for @gameHudAiLogHint.
  ///
  /// In zh, this message translates to:
  /// **'把游戏日志末尾一起发给 AI，方便排查崩溃；日志可能包含服务器地址和聊天内容'**
  String get gameHudAiLogHint;

  /// No description provided for @gameWindow.
  ///
  /// In zh, this message translates to:
  /// **'游戏窗口'**
  String get gameWindow;

  /// No description provided for @gameWindowDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认（854 × 480）'**
  String get gameWindowDefault;

  /// No description provided for @gameWindowLauncher.
  ///
  /// In zh, this message translates to:
  /// **'与启动器一致'**
  String get gameWindowLauncher;

  /// No description provided for @gameWindowMaximized.
  ///
  /// In zh, this message translates to:
  /// **'最大化'**
  String get gameWindowMaximized;

  /// No description provided for @gameWindowFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get gameWindowFullscreen;

  /// No description provided for @gameWindowCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义大小'**
  String get gameWindowCustom;

  /// No description provided for @gameWindowWidth.
  ///
  /// In zh, this message translates to:
  /// **'窗口宽度'**
  String get gameWindowWidth;

  /// No description provided for @gameWindowHeight.
  ///
  /// In zh, this message translates to:
  /// **'窗口高度'**
  String get gameWindowHeight;

  /// No description provided for @afterLaunch.
  ///
  /// In zh, this message translates to:
  /// **'游戏启动后'**
  String get afterLaunch;

  /// No description provided for @afterLaunchKeep.
  ///
  /// In zh, this message translates to:
  /// **'保持不变'**
  String get afterLaunchKeep;

  /// No description provided for @afterLaunchMinimize.
  ///
  /// In zh, this message translates to:
  /// **'最小化，游戏退出后恢复'**
  String get afterLaunchMinimize;

  /// No description provided for @afterLaunchHide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏，游戏退出后恢复'**
  String get afterLaunchHide;

  /// No description provided for @afterLaunchHideExit.
  ///
  /// In zh, this message translates to:
  /// **'隐藏，游戏退出后关闭'**
  String get afterLaunchHideExit;

  /// No description provided for @afterLaunchExit.
  ///
  /// In zh, this message translates to:
  /// **'直接关闭启动器'**
  String get afterLaunchExit;

  /// No description provided for @priority.
  ///
  /// In zh, this message translates to:
  /// **'进程优先级'**
  String get priority;

  /// No description provided for @priorityHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get priorityHigh;

  /// No description provided for @priorityAboveNormal.
  ///
  /// In zh, this message translates to:
  /// **'较高'**
  String get priorityAboveNormal;

  /// No description provided for @priorityNormal.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get priorityNormal;

  /// No description provided for @priorityBelowNormal.
  ///
  /// In zh, this message translates to:
  /// **'较低'**
  String get priorityBelowNormal;

  /// No description provided for @versionType.
  ///
  /// In zh, this message translates to:
  /// **'版本类型显示'**
  String get versionType;

  /// No description provided for @versionTypeHint.
  ///
  /// In zh, this message translates to:
  /// **'显示在游戏主界面左下角，留空则不显示'**
  String get versionTypeHint;

  /// No description provided for @autoGameLanguage.
  ///
  /// In zh, this message translates to:
  /// **'自动设置游戏语言'**
  String get autoGameLanguage;

  /// No description provided for @autoGameLanguageHint.
  ///
  /// In zh, this message translates to:
  /// **'新实例或没有存档时，把游戏语言设为与启动器一致'**
  String get autoGameLanguageHint;

  /// No description provided for @memory.
  ///
  /// In zh, this message translates to:
  /// **'游戏内存'**
  String get memory;

  /// No description provided for @memoryMode.
  ///
  /// In zh, this message translates to:
  /// **'分配方式'**
  String get memoryMode;

  /// No description provided for @memorySummary.
  ///
  /// In zh, this message translates to:
  /// **'将分配 {allocated} GB · 系统空闲 {free} / {total} GB'**
  String memorySummary(String allocated, String free, String total);

  /// No description provided for @memoryLock.
  ///
  /// In zh, this message translates to:
  /// **'锁定内存'**
  String get memoryLock;

  /// No description provided for @memoryLockHint.
  ///
  /// In zh, this message translates to:
  /// **'初始内存与最大内存相同（-Xms 等于 -Xmx）'**
  String get memoryLockHint;

  /// No description provided for @advanced.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advanced;

  /// No description provided for @jvmArgs.
  ///
  /// In zh, this message translates to:
  /// **'JVM 参数'**
  String get jvmArgs;

  /// No description provided for @gameArgs.
  ///
  /// In zh, this message translates to:
  /// **'游戏参数'**
  String get gameArgs;

  /// No description provided for @preLaunchCommand.
  ///
  /// In zh, this message translates to:
  /// **'启动前执行命令'**
  String get preLaunchCommand;

  /// No description provided for @preLaunchCommandHint.
  ///
  /// In zh, this message translates to:
  /// **'在游戏文件夹中执行'**
  String get preLaunchCommandHint;

  /// No description provided for @preLaunchWait.
  ///
  /// In zh, this message translates to:
  /// **'等待命令执行完毕再启动游戏'**
  String get preLaunchWait;

  /// No description provided for @ipStack.
  ///
  /// In zh, this message translates to:
  /// **'网络协议偏好'**
  String get ipStack;

  /// No description provided for @ipStackV4.
  ///
  /// In zh, this message translates to:
  /// **'优先 IPv4'**
  String get ipStackV4;

  /// No description provided for @ipStackV6.
  ///
  /// In zh, this message translates to:
  /// **'优先 IPv6'**
  String get ipStackV6;

  /// No description provided for @gpuPreference.
  ///
  /// In zh, this message translates to:
  /// **'使用高性能显卡'**
  String get gpuPreference;

  /// No description provided for @gpuPreferenceHint.
  ///
  /// In zh, this message translates to:
  /// **'仅 Windows：让 Java 使用独立显卡'**
  String get gpuPreferenceHint;

  /// No description provided for @javaUnusable.
  ///
  /// In zh, this message translates to:
  /// **'无法运行这个 Java'**
  String get javaUnusable;

  /// No description provided for @javaAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get javaAuto;

  /// No description provided for @javaAutoHint.
  ///
  /// In zh, this message translates to:
  /// **'按版本要求选择，找不到时自动下载 Mojang 提供的 Java'**
  String get javaAutoHint;

  /// No description provided for @javaEntry.
  ///
  /// In zh, this message translates to:
  /// **'Java {major}（{version}）'**
  String javaEntry(int major, String version);

  /// No description provided for @javaManaged.
  ///
  /// In zh, this message translates to:
  /// **'启动器下载'**
  String get javaManaged;

  /// No description provided for @javaManual.
  ///
  /// In zh, this message translates to:
  /// **'手动指定'**
  String get javaManual;

  /// No description provided for @javaPick.
  ///
  /// In zh, this message translates to:
  /// **'手动选择'**
  String get javaPick;

  /// No description provided for @javaRescan.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get javaRescan;

  /// No description provided for @javaPerInstance.
  ///
  /// In zh, this message translates to:
  /// **'实例设置里可以为单个实例指定 Java，优先于这里的设置。'**
  String get javaPerInstance;

  /// No description provided for @javaAndroidAutoHint.
  ///
  /// In zh, this message translates to:
  /// **'按版本要求选择 Java 8 / 17 / 21 / 25，没有安装时自动下载'**
  String get javaAndroidAutoHint;

  /// No description provided for @javaAndroidTask.
  ///
  /// In zh, this message translates to:
  /// **'下载 Java {major}（安卓版）'**
  String javaAndroidTask(int major);

  /// No description provided for @javaDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载 Java {major} 失败：{error}'**
  String javaDownloadFailed(int major, String error);

  /// No description provided for @javaDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除 Java {major}？'**
  String javaDeleteTitle(int major);

  /// No description provided for @javaDeleteBody.
  ///
  /// In zh, this message translates to:
  /// **'之后需要时会重新下载。指定使用它的实例要重新选择 Java，或改为自动选择。'**
  String get javaDeleteBody;

  /// No description provided for @javaInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已安装 · {size}'**
  String javaInstalled(String size);

  /// No description provided for @javaNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'未安装'**
  String get javaNotInstalled;

  /// No description provided for @javaInUse.
  ///
  /// In zh, this message translates to:
  /// **'游戏或任务运行时不能删除'**
  String get javaInUse;

  /// No description provided for @javaManualAndroid.
  ///
  /// In zh, this message translates to:
  /// **'手动指定（安卓上不可用）'**
  String get javaManualAndroid;

  /// No description provided for @javaAndroidNote.
  ///
  /// In zh, this message translates to:
  /// **'安卓版 Java 来自 AngelAuraMC 的 OpenJDK 构建（GPLv2 + Classpath Exception）。实例设置里可以为单个实例指定 Java，优先于这里的设置。'**
  String get javaAndroidNote;

  /// No description provided for @updates.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get updates;

  /// No description provided for @updateChannel.
  ///
  /// In zh, this message translates to:
  /// **'更新通道'**
  String get updateChannel;

  /// No description provided for @updateChannelHint.
  ///
  /// In zh, this message translates to:
  /// **'正式版最稳定；预览版包含测试中的版本；Nightly 为 main 分支的每次更新，可能不稳定'**
  String get updateChannelHint;

  /// No description provided for @updateChannelStable.
  ///
  /// In zh, this message translates to:
  /// **'正式版'**
  String get updateChannelStable;

  /// No description provided for @updateChannelPreview.
  ///
  /// In zh, this message translates to:
  /// **'预览版'**
  String get updateChannelPreview;

  /// No description provided for @updateAutoCheck.
  ///
  /// In zh, this message translates to:
  /// **'启动时检查更新'**
  String get updateAutoCheck;

  /// No description provided for @updateCheck.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get updateCheck;

  /// No description provided for @updateCheckButton.
  ///
  /// In zh, this message translates to:
  /// **'检查'**
  String get updateCheckButton;

  /// No description provided for @updateCurrentLocal.
  ///
  /// In zh, this message translates to:
  /// **'当前版本 {version}（本地构建）'**
  String updateCurrentLocal(String version);

  /// No description provided for @updateCurrentBuild.
  ///
  /// In zh, this message translates to:
  /// **'当前版本 {version}（{channel}，{commit}）'**
  String updateCurrentBuild(String version, String channel, String commit);

  /// No description provided for @pclImport.
  ///
  /// In zh, this message translates to:
  /// **'从 PCL-CE 导入'**
  String get pclImport;

  /// No description provided for @pclImportHint.
  ///
  /// In zh, this message translates to:
  /// **'导入启动设置、游戏文件夹与账户；实例独立设置两者直接共用'**
  String get pclImportHint;

  /// No description provided for @pclImportButton.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get pclImportButton;

  /// No description provided for @system.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get system;

  /// No description provided for @shortcut.
  ///
  /// In zh, this message translates to:
  /// **'创建桌面快捷方式'**
  String get shortcut;

  /// No description provided for @shortcutHint.
  ///
  /// In zh, this message translates to:
  /// **'在桌面创建启动器的快捷方式'**
  String get shortcutHint;

  /// No description provided for @shortcutButton.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get shortcutButton;

  /// No description provided for @downloadSource.
  ///
  /// In zh, this message translates to:
  /// **'下载源'**
  String get downloadSource;

  /// No description provided for @downloadSourceOfficial.
  ///
  /// In zh, this message translates to:
  /// **'官方源'**
  String get downloadSourceOfficial;

  /// No description provided for @downloadSourceMirror.
  ///
  /// In zh, this message translates to:
  /// **'BMCLAPI 镜像（官方源失败时自动回退）'**
  String get downloadSourceMirror;

  /// No description provided for @downloadConcurrency.
  ///
  /// In zh, this message translates to:
  /// **'同时下载的文件数'**
  String get downloadConcurrency;

  /// No description provided for @msLogin.
  ///
  /// In zh, this message translates to:
  /// **'正版登录'**
  String get msLogin;

  /// No description provided for @msClientId.
  ///
  /// In zh, this message translates to:
  /// **'Azure 应用 Client ID'**
  String get msClientId;

  /// No description provided for @msClientIdHint.
  ///
  /// In zh, this message translates to:
  /// **'微软登录需要 Azure 公共客户端应用；留空时使用启动器内置的 Client ID'**
  String get msClientIdHint;

  /// No description provided for @msClientIdEmpty.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get msClientIdEmpty;

  /// No description provided for @msClientIdBuiltIn.
  ///
  /// In zh, this message translates to:
  /// **'留空时使用内置 Client ID'**
  String get msClientIdBuiltIn;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
