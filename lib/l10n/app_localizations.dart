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

  /// No description provided for @homeLayoutStandardMobileHint.
  ///
  /// In zh, this message translates to:
  /// **'标准：原来的首页，不显示背景图片；要用背景图片请选「上下」或「极简」'**
  String get homeLayoutStandardMobileHint;

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
  /// **'选择一张图片作为启动器的背景，界面面板会变成毛玻璃'**
  String get bgImageUnset;

  /// No description provided for @bgImageInactive.
  ///
  /// In zh, this message translates to:
  /// **'「标准」首页不显示背景图片，把首页布局换成「上下」或「极简」后生效'**
  String get bgImageInactive;

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

  /// No description provided for @helpGroup.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get helpGroup;

  /// No description provided for @helpTour.
  ///
  /// In zh, this message translates to:
  /// **'新手教程'**
  String get helpTour;

  /// No description provided for @helpTourHint.
  ///
  /// In zh, this message translates to:
  /// **'再看一遍启动器各个地方的介绍：账户、安装游戏、实例、开始游戏、工具和设置'**
  String get helpTourHint;

  /// No description provided for @helpTourStart.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get helpTourStart;

  /// No description provided for @helpTerms.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get helpTerms;

  /// No description provided for @helpTermsHint.
  ///
  /// In zh, this message translates to:
  /// **'使用规则、第三方内容与免责声明'**
  String get helpTermsHint;

  /// No description provided for @helpPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私说明'**
  String get helpPrivacy;

  /// No description provided for @helpPrivacyHint.
  ///
  /// In zh, this message translates to:
  /// **'不收集你的信息；保存在本地的内容与会连接的服务'**
  String get helpPrivacyHint;

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
  /// **'Pixel World 是第三方 Minecraft 启动器，本项目为轻度使用 PCL 仓储库，界面布局参考 PCL 社区版（PCL-CE）。PCL 由龙腾猫跃开发，本软件与 PCL 及其作者无关，也不代表 PCL 官方。请勿就本软件的问题打扰 PCL 作者。本软件不是 Mojang 或 Microsoft 的官方产品，未经它们认可，也与它们没有关联；Minecraft 是 Mojang Synergies AB 的商标。'**
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

  /// No description provided for @downloadSourceAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get downloadSourceAuto;

  /// No description provided for @downloadSourceOfficial.
  ///
  /// In zh, this message translates to:
  /// **'官方源'**
  String get downloadSourceOfficial;

  /// No description provided for @downloadSourceMirror.
  ///
  /// In zh, this message translates to:
  /// **'BMCLAPI 镜像'**
  String get downloadSourceMirror;

  /// No description provided for @downloadSourceAutoHint.
  ///
  /// In zh, this message translates to:
  /// **'测速选择官方源或 BMCLAPI 镜像中较快的，失败时自动换另一个'**
  String get downloadSourceAutoHint;

  /// No description provided for @downloadSourceOfficialHint.
  ///
  /// In zh, this message translates to:
  /// **'只用 Mojang 和各加载器的官方服务器'**
  String get downloadSourceOfficialHint;

  /// No description provided for @downloadSourceMirrorHint.
  ///
  /// In zh, this message translates to:
  /// **'优先用 BMCLAPI 镜像，失败时回退到官方源'**
  String get downloadSourceMirrorHint;

  /// No description provided for @downloadSourceCurrent.
  ///
  /// In zh, this message translates to:
  /// **'（当前：{source}）'**
  String downloadSourceCurrent(String source);

  /// No description provided for @networkCheck.
  ///
  /// In zh, this message translates to:
  /// **'网络检测'**
  String get networkCheck;

  /// No description provided for @networkCheckHint.
  ///
  /// In zh, this message translates to:
  /// **'测试下载源、正版登录、Modrinth 和更新服务能不能连上、有多快'**
  String get networkCheckHint;

  /// No description provided for @networkCheckStart.
  ///
  /// In zh, this message translates to:
  /// **'开始检测'**
  String get networkCheckStart;

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

  /// No description provided for @oobeWelcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get oobeWelcome;

  /// No description provided for @oobeAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get oobeAppearance;

  /// No description provided for @oobeGameFolder.
  ///
  /// In zh, this message translates to:
  /// **'游戏文件夹'**
  String get oobeGameFolder;

  /// No description provided for @oobeNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get oobeNetwork;

  /// No description provided for @oobeAccount.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get oobeAccount;

  /// No description provided for @oobeDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get oobeDone;

  /// No description provided for @oobeImportedFromPCLCE.
  ///
  /// In zh, this message translates to:
  /// **'已从 PCL-CE 导入：游戏文件夹 {folders} 个，账户 {accounts} 个'**
  String oobeImportedFromPCLCE(Object folders, Object accounts);

  /// No description provided for @oobeCouldntImportFromPCL.
  ///
  /// In zh, this message translates to:
  /// **'从 PCL-CE 导入失败：{e}'**
  String oobeCouldntImportFromPCL(Object e);

  /// No description provided for @oobeAbout1Minute.
  ///
  /// In zh, this message translates to:
  /// **'约 1 分钟'**
  String get oobeAbout1Minute;

  /// No description provided for @oobe6StepsAbout1.
  ///
  /// In zh, this message translates to:
  /// **'共 6 步，约 1 分钟'**
  String get oobe6StepsAbout1;

  /// No description provided for @oobeAcceptAgreementContinue.
  ///
  /// In zh, this message translates to:
  /// **'勾选同意后才能继续'**
  String get oobeAcceptAgreementContinue;

  /// No description provided for @oobeYouCanChangeAll.
  ///
  /// In zh, this message translates to:
  /// **'之后都可以在「设置」里改'**
  String get oobeYouCanChangeAll;

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get commonBack;

  /// No description provided for @commonDeclineQuit.
  ///
  /// In zh, this message translates to:
  /// **'不同意并退出'**
  String get commonDeclineQuit;

  /// No description provided for @oobeInstallYourFirstInstance.
  ///
  /// In zh, this message translates to:
  /// **'去安装第一个实例'**
  String get oobeInstallYourFirstInstance;

  /// No description provided for @oobeOpenLauncher.
  ///
  /// In zh, this message translates to:
  /// **'进入启动器'**
  String get oobeOpenLauncher;

  /// No description provided for @oobeStartSetup.
  ///
  /// In zh, this message translates to:
  /// **'开始设置'**
  String get oobeStartSetup;

  /// No description provided for @commonSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get commonNext;

  /// No description provided for @commonWelcomePixelWorld.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 Pixel World'**
  String get commonWelcomePixelWorld;

  /// No description provided for @oobeFreeOpenSourceMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'免费、开源的 Minecraft 启动器。花一两分钟完成几项设置，之后都可以在「设置」里改。'**
  String get oobeFreeOpenSourceMinecraft;

  /// No description provided for @oobeInstallManage.
  ///
  /// In zh, this message translates to:
  /// **'安装与管理'**
  String get oobeInstallManage;

  /// No description provided for @oobeVanillaEveryModLoader.
  ///
  /// In zh, this message translates to:
  /// **'原版和各种加载器，一个版本可以装多个实例，模组、存档各管各的。'**
  String get oobeVanillaEveryModLoader;

  /// No description provided for @oobeModsResources.
  ///
  /// In zh, this message translates to:
  /// **'模组与资源'**
  String get oobeModsResources;

  /// No description provided for @oobeFindModsModpacksResource.
  ///
  /// In zh, this message translates to:
  /// **'在启动器里直接找模组、整合包、资源包和光影。'**
  String get oobeFindModsModpacksResource;

  /// No description provided for @oobeAITroubleshooting.
  ///
  /// In zh, this message translates to:
  /// **'AI 排障'**
  String get oobeAITroubleshooting;

  /// No description provided for @oobeGameCrashedLetAI.
  ///
  /// In zh, this message translates to:
  /// **'游戏崩了，让 AI 读日志找原因。'**
  String get oobeGameCrashedLetAI;

  /// No description provided for @commonTermsUsePrivacyNotice.
  ///
  /// In zh, this message translates to:
  /// **'用户协议与隐私说明'**
  String get commonTermsUsePrivacyNotice;

  /// No description provided for @oobeBeforeYouContinuePlease.
  ///
  /// In zh, this message translates to:
  /// **'继续之前，请阅读并同意下面两份文件。'**
  String get oobeBeforeYouContinuePlease;

  /// No description provided for @oobeSoftwareFreeOpenSource.
  ///
  /// In zh, this message translates to:
  /// **'· 本软件免费开源，按原样提供；不是 Mojang、Microsoft 或 PCL 的官方产品。\n· 我们不收集你的信息，账户和设置只保存在你的设备上。\n· 游戏、模组等内容来自第三方，下载时直接连接它们。'**
  String get oobeSoftwareFreeOpenSource;

  /// No description provided for @oobeIHaveReadAccept.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意《用户协议》和《隐私说明》'**
  String get oobeIHaveReadAccept;

  /// No description provided for @oobePickLookYouLike.
  ///
  /// In zh, this message translates to:
  /// **'选一个顺眼的样子。手机上的「标准」就是原来的首页；背景图片只在「上下」「极简」里显示。'**
  String get oobePickLookYouLike;

  /// No description provided for @oobePickLookYouLike2.
  ///
  /// In zh, this message translates to:
  /// **'选一个顺眼的样子。'**
  String get oobePickLookYouLike2;

  /// No description provided for @oobeLightDarkLauncherAppearance.
  ///
  /// In zh, this message translates to:
  /// **'启动器界面的明暗'**
  String get oobeLightDarkLauncherAppearance;

  /// No description provided for @oobeSelectedPanelsBecomeFrosted.
  ///
  /// In zh, this message translates to:
  /// **'已选择 · 面板会变成毛玻璃，主题色跟随图片'**
  String get oobeSelectedPanelsBecomeFrosted;

  /// No description provided for @oobeOptionalChooseImageShow.
  ///
  /// In zh, this message translates to:
  /// **'可选：选一张图片放在启动器后面'**
  String get oobeOptionalChooseImageShow;

  /// No description provided for @oobeCantUseImage.
  ///
  /// In zh, this message translates to:
  /// **'无法使用这张图片：{e}'**
  String oobeCantUseImage(Object e);

  /// No description provided for @oobeGamesInstancesModsWorlds.
  ///
  /// In zh, this message translates to:
  /// **'游戏、实例、模组和存档都放在这里。之后可以在「设置 → 游戏管理」里添加更多文件夹。'**
  String get oobeGamesInstancesModsWorlds;

  /// No description provided for @oobeUseDefaultFolder.
  ///
  /// In zh, this message translates to:
  /// **'使用默认文件夹'**
  String get oobeUseDefaultFolder;

  /// No description provided for @oobeUseExistingMinecraftFolder.
  ///
  /// In zh, this message translates to:
  /// **'使用已有的 .minecraft 文件夹'**
  String get oobeUseExistingMinecraftFolder;

  /// No description provided for @oobeInstalledGameAnotherLauncher.
  ///
  /// In zh, this message translates to:
  /// **'以前用别的启动器装过游戏？直接选那个文件夹，里面的版本和存档都能用。'**
  String get oobeInstalledGameAnotherLauncher;

  /// No description provided for @oobeNotChosenYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有选择'**
  String get oobeNotChosenYet;

  /// No description provided for @oobePCLCEDetected.
  ///
  /// In zh, this message translates to:
  /// **'检测到 PCL-CE'**
  String get oobePCLCEDetected;

  /// No description provided for @oobeImportsPCLCEGame.
  ///
  /// In zh, this message translates to:
  /// **'导入 PCL-CE 的游戏文件夹（{folders} 个）{hasAccounts}和启动设置。'**
  String oobeImportsPCLCEGame(Object folders, Object hasAccounts);

  /// No description provided for @oobeAccounts.
  ///
  /// In zh, this message translates to:
  /// **'、账户'**
  String get oobeAccounts;

  /// No description provided for @oobeWhereShouldGameFiles.
  ///
  /// In zh, this message translates to:
  /// **'游戏文件放在哪里？'**
  String get oobeWhereShouldGameFiles;

  /// No description provided for @oobeYouCanChangeLater.
  ///
  /// In zh, this message translates to:
  /// **'之后可以在「设置 → 游戏管理」里更改。'**
  String get oobeYouCanChangeLater;

  /// No description provided for @oobePhoneStorage.
  ///
  /// In zh, this message translates to:
  /// **'手机存储'**
  String get oobePhoneStorage;

  /// No description provided for @oobeStoredPixelWorldMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'放在「Pixel World/.minecraft」。卸载或重装启动器后游戏和存档仍然保留，也能用其他应用管理。需要授予「所有文件访问权限」。'**
  String get oobeStoredPixelWorldMinecraft;

  /// No description provided for @oobeAppStorage.
  ///
  /// In zh, this message translates to:
  /// **'应用内部'**
  String get oobeAppStorage;

  /// No description provided for @oobeNoPermissionNeededBut.
  ///
  /// In zh, this message translates to:
  /// **'不需要权限，但卸载启动器时游戏和存档会一起删除。'**
  String get oobeNoPermissionNeededBut;

  /// No description provided for @oobeDecidedAfterSpeedTest.
  ///
  /// In zh, this message translates to:
  /// **'测速后决定'**
  String get oobeDecidedAfterSpeedTest;

  /// No description provided for @oobeSpeedTestBMCLAPIMirror.
  ///
  /// In zh, this message translates to:
  /// **'测速结果：BMCLAPI 镜像更快'**
  String get oobeSpeedTestBMCLAPIMirror;

  /// No description provided for @oobeSpeedTestOfficialSource.
  ///
  /// In zh, this message translates to:
  /// **'测速结果：官方源更快'**
  String get oobeSpeedTestOfficialSource;

  /// No description provided for @oobeUsuallyFasterMainlandChina.
  ///
  /// In zh, this message translates to:
  /// **'国内一般更快'**
  String get oobeUsuallyFasterMainlandChina;

  /// No description provided for @oobeOfficialServersOnly.
  ///
  /// In zh, this message translates to:
  /// **'只用官方服务器'**
  String get oobeOfficialServersOnly;

  /// No description provided for @oobeChooseWhereDownloadGame.
  ///
  /// In zh, this message translates to:
  /// **'选择从哪里下载游戏文件。下面会自动检测各项服务的连接情况。'**
  String get oobeChooseWhereDownloadGame;

  /// No description provided for @oobeAutomaticUsesFasterOne.
  ///
  /// In zh, this message translates to:
  /// **'「自动选择」会优先用更快的一边，失败时自动换另一边。'**
  String get oobeAutomaticUsesFasterOne;

  /// No description provided for @oobeMicrosoftAccount.
  ///
  /// In zh, this message translates to:
  /// **'微软账户'**
  String get oobeMicrosoftAccount;

  /// No description provided for @oobeSetClientIDSettings.
  ///
  /// In zh, this message translates to:
  /// **'需要先在「设置 → 其他」填写 Client ID'**
  String get oobeSetClientIDSettings;

  /// No description provided for @oobeOfficialSignLetsYou.
  ///
  /// In zh, this message translates to:
  /// **'正版登录，可以进正版服务器'**
  String get oobeOfficialSignLetsYou;

  /// No description provided for @commonSignMicrosoft.
  ///
  /// In zh, this message translates to:
  /// **'微软登录'**
  String get commonSignMicrosoft;

  /// No description provided for @oobeExternalSign.
  ///
  /// In zh, this message translates to:
  /// **'外置登录'**
  String get oobeExternalSign;

  /// No description provided for @oobeLittleSkinOtherSkinSites.
  ///
  /// In zh, this message translates to:
  /// **'LittleSkin 等皮肤站'**
  String get oobeLittleSkinOtherSkinSites;

  /// No description provided for @oobeOfflineAccount.
  ///
  /// In zh, this message translates to:
  /// **'离线账户'**
  String get oobeOfflineAccount;

  /// No description provided for @oobeJustPickNamePlay.
  ///
  /// In zh, this message translates to:
  /// **'起个名字就能玩单机'**
  String get oobeJustPickNamePlay;

  /// No description provided for @oobeOfflineUsername.
  ///
  /// In zh, this message translates to:
  /// **'离线用户名'**
  String get oobeOfflineUsername;

  /// No description provided for @oobe316LettersDigits.
  ///
  /// In zh, this message translates to:
  /// **'3～16 个字母、数字或下划线'**
  String get oobe316LettersDigits;

  /// No description provided for @oobeAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get oobeAdd;

  /// No description provided for @oobeAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get oobeAdded;

  /// No description provided for @oobeYouCanAlsoSkip.
  ///
  /// In zh, this message translates to:
  /// **'不想现在添加也可以直接下一步。'**
  String get oobeYouCanAlsoSkip;

  /// No description provided for @oobeAutomaticCurrently.
  ///
  /// In zh, this message translates to:
  /// **'自动选择（当前：{preferMirror}）'**
  String oobeAutomaticCurrently(Object preferMirror);

  /// No description provided for @commonAllSet.
  ///
  /// In zh, this message translates to:
  /// **'准备好了'**
  String get commonAllSet;

  /// No description provided for @oobeHereYourChoicesClick.
  ///
  /// In zh, this message translates to:
  /// **'下面是你的选择，点「修改」可以回去改。'**
  String get oobeHereYourChoicesClick;

  /// No description provided for @oobeLayout.
  ///
  /// In zh, this message translates to:
  /// **'{mode} · {homeLayout}布局'**
  String oobeLayout(Object mode, Object homeLayout);

  /// No description provided for @oobeNoneYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加'**
  String get oobeNoneYet;

  /// No description provided for @oobeTakeGuidedTourAfter.
  ///
  /// In zh, this message translates to:
  /// **'进入后看一遍新手教程'**
  String get oobeTakeGuidedTourAfter;

  /// No description provided for @oobeAbout30SecondsYou.
  ///
  /// In zh, this message translates to:
  /// **'大约 30 秒；之后可以在「设置 → 关于与致谢 → 帮助」里再看'**
  String get oobeAbout30SecondsYou;

  /// No description provided for @oobeFirstTimeSetup.
  ///
  /// In zh, this message translates to:
  /// **'首次设置'**
  String get oobeFirstTimeSetup;

  /// No description provided for @oobeDontWantSetThings.
  ///
  /// In zh, this message translates to:
  /// **'不想现在设置？'**
  String get oobeDontWantSetThings;

  /// No description provided for @oobeUseAllDefaults.
  ///
  /// In zh, this message translates to:
  /// **'全部用默认'**
  String get oobeUseAllDefaults;

  /// No description provided for @oobeYouStillNeedAccept.
  ///
  /// In zh, this message translates to:
  /// **'（仍需同意协议）'**
  String get oobeYouStillNeedAccept;

  /// No description provided for @oobeChange.
  ///
  /// In zh, this message translates to:
  /// **'修改'**
  String get oobeChange;

  /// No description provided for @oobeChoose.
  ///
  /// In zh, this message translates to:
  /// **'选择…'**
  String get oobeChoose;

  /// No description provided for @oobeLargeCardAnnouncementsShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'大卡片、公告与快捷按钮、最近游玩'**
  String get oobeLargeCardAnnouncementsShortcuts;

  /// No description provided for @oobeInstanceAtTopPlay.
  ///
  /// In zh, this message translates to:
  /// **'实例在顶部，开始游戏在底部，中间留给背景'**
  String get oobeInstanceAtTopPlay;

  /// No description provided for @oobeSingleBarAtBottom.
  ///
  /// In zh, this message translates to:
  /// **'只在底部留一条'**
  String get oobeSingleBarAtBottom;

  /// No description provided for @tourTakeMinuteGetKnow.
  ///
  /// In zh, this message translates to:
  /// **'花一分钟认识一下启动器的几个主要地方。随时可以点「跳过」，之后在「设置 → 关于与致谢」里能再看一遍。'**
  String get tourTakeMinuteGetKnow;

  /// No description provided for @tourAddAccountFirst.
  ///
  /// In zh, this message translates to:
  /// **'先添加账户'**
  String get tourAddAccountFirst;

  /// No description provided for @tourClickHereAddMicrosoft.
  ///
  /// In zh, this message translates to:
  /// **'点这里添加微软正版账户；登录过一次正版后，也可以添加外置登录（例如 LittleSkin）和离线账户。'**
  String get tourClickHereAddMicrosoft;

  /// No description provided for @tourInstallGame.
  ///
  /// In zh, this message translates to:
  /// **'安装游戏'**
  String get tourInstallGame;

  /// No description provided for @tourUnderDownloadChooseGame.
  ///
  /// In zh, this message translates to:
  /// **'在「下载」里选游戏版本和加载器（Forge、Fabric 等）来安装。装好的一份叫「实例」，同一个版本可以装好几个，存档和模组互不影响。模组、整合包、资源包和光影也在这里找。'**
  String get tourUnderDownloadChooseGame;

  /// No description provided for @tourSwitchInstance.
  ///
  /// In zh, this message translates to:
  /// **'切换实例'**
  String get tourSwitchInstance;

  /// No description provided for @tourHomePageShowsCurrent.
  ///
  /// In zh, this message translates to:
  /// **'首页显示当前实例。点「切换实例」可以在装好的实例之间切换，或者管理全部实例。'**
  String get tourHomePageShowsCurrent;

  /// No description provided for @tourPlay.
  ///
  /// In zh, this message translates to:
  /// **'开始游戏'**
  String get tourPlay;

  /// No description provided for @tourPickInstanceClickHere.
  ///
  /// In zh, this message translates to:
  /// **'选好实例后点这里启动。第一次启动会自动准备好需要的 Java。'**
  String get tourPickInstanceClickHere;

  /// No description provided for @tourInstanceSettings.
  ///
  /// In zh, this message translates to:
  /// **'实例设置'**
  String get tourInstanceSettings;

  /// No description provided for @tourEachInstancesModsWorlds.
  ///
  /// In zh, this message translates to:
  /// **'每个实例的模组、存档、资源包、光影、内存和 Java 都在这里单独管理，也可以直接给这个实例添加模组。'**
  String get tourEachInstancesModsWorlds;

  /// No description provided for @tourBackgroundTasks.
  ///
  /// In zh, this message translates to:
  /// **'后台任务'**
  String get tourBackgroundTasks;

  /// No description provided for @tourDownloadsInstallsRunBackground.
  ///
  /// In zh, this message translates to:
  /// **'下载和安装都在后台进行，进度显示在这里，点开可以查看详情或者取消。'**
  String get tourDownloadsInstallsRunBackground;

  /// No description provided for @tourMultiplayerLobbyLANTransfer.
  ///
  /// In zh, this message translates to:
  /// **'联机大厅、局域网互传、服务器查询、错误分析，还有皮肤、成就图片这些小工具。'**
  String get tourMultiplayerLobbyLANTransfer;

  /// No description provided for @tourFileManagerYourPhone.
  ///
  /// In zh, this message translates to:
  /// **'手机上的文件管理器：直接管理游戏文件夹里的存档、模组和截图。'**
  String get tourFileManagerYourPhone;

  /// No description provided for @tourAskAIWhenSomething.
  ///
  /// In zh, this message translates to:
  /// **'有问题可以问 AI，例如游戏为什么崩溃、该装哪个模组。先在设置里配置好模型就能用。'**
  String get tourAskAIWhenSomething;

  /// No description provided for @tourThemeBackgroundImageHome.
  ///
  /// In zh, this message translates to:
  /// **'主题、背景图片和首页布局在「个性化」里；Java、内存和游戏文件夹也在这里调整。'**
  String get tourThemeBackgroundImageHome;

  /// No description provided for @tourHeadDownloadInstallInstance.
  ///
  /// In zh, this message translates to:
  /// **'先去「下载」装一个实例吧！这个教程可以在「设置 → 关于与致谢」里再次打开。'**
  String get tourHeadDownloadInstallInstance;

  /// No description provided for @tourGetStarted.
  ///
  /// In zh, this message translates to:
  /// **'开始使用'**
  String get tourGetStarted;

  /// No description provided for @agreementDialogTermsUsePrivacyNotice.
  ///
  /// In zh, this message translates to:
  /// **'用户协议与隐私说明已更新'**
  String get agreementDialogTermsUsePrivacyNotice;

  /// No description provided for @agreementDialogPleaseReadTermsUse.
  ///
  /// In zh, this message translates to:
  /// **'使用前请阅读下面的用户协议和隐私说明。简单来说：本软件免费开源，按原样提供；我们不收集你的信息，账户和设置都只保存在你的设备上；游戏和模组来自第三方。'**
  String get agreementDialogPleaseReadTermsUse;

  /// No description provided for @agreementDialogAcceptContinue.
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get agreementDialogAcceptContinue;

  /// No description provided for @networkCheckPanelChecking.
  ///
  /// In zh, this message translates to:
  /// **'检测中…'**
  String get networkCheckPanelChecking;

  /// No description provided for @networkCheckPanelCheckingUp8Seconds.
  ///
  /// In zh, this message translates to:
  /// **'正在检测，最多 8 秒'**
  String get networkCheckPanelCheckingUp8Seconds;

  /// No description provided for @networkCheckPanelNeitherDownloadSourceCan.
  ///
  /// In zh, this message translates to:
  /// **'两个下载源都连不上，请检查网络或代理设置'**
  String get networkCheckPanelNeitherDownloadSourceCan;

  /// No description provided for @networkCheckPanelAutomaticWillPreferSwitch.
  ///
  /// In zh, this message translates to:
  /// **'「自动选择」会优先使用{mirror}，失败时自动换另一个'**
  String networkCheckPanelAutomaticWillPreferSwitch(Object mirror);

  /// No description provided for @networkCheckPanelBMCLAPIMirror.
  ///
  /// In zh, this message translates to:
  /// **' BMCLAPI 镜像'**
  String get networkCheckPanelBMCLAPIMirror;

  /// No description provided for @networkCheckPanelOtherConnectionsFailedRelated.
  ///
  /// In zh, this message translates to:
  /// **'有 {failed} 项连接失败，相关功能可能用不了'**
  String networkCheckPanelOtherConnectionsFailedRelated(num failed);

  /// No description provided for @networkCheckPanelCheckAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get networkCheckPanelCheckAgain;

  /// No description provided for @networkCheckPanelLauncherUpdates.
  ///
  /// In zh, this message translates to:
  /// **'启动器更新'**
  String get networkCheckPanelLauncherUpdates;

  /// No description provided for @networkCheckPanelCheckingUp8Seconds2.
  ///
  /// In zh, this message translates to:
  /// **'检测中，最多 8 秒'**
  String get networkCheckPanelCheckingUp8Seconds2;

  /// No description provided for @networkCheckPanelAllGood.
  ///
  /// In zh, this message translates to:
  /// **'全部正常'**
  String get networkCheckPanelAllGood;

  /// No description provided for @networkCheckPanelConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get networkCheckPanelConnectionFailed;

  /// No description provided for @storageLocationPhoneStoragePixelWorld.
  ///
  /// In zh, this message translates to:
  /// **'放在手机存储（Pixel World/.minecraft）：卸载或重装启动器后游戏、存档仍然保留，也可以用其他应用管理这些文件。需要授予「所有文件访问权限」。\n\n放在应用内部：不需要权限，但卸载启动器时游戏、存档会一起被删除。\n\n之后可以在「设置 → 游戏管理」中更改。'**
  String get storageLocationPhoneStoragePixelWorld;

  /// No description provided for @storageLocationPhoneStorageRecommended.
  ///
  /// In zh, this message translates to:
  /// **'手机存储（推荐）'**
  String get storageLocationPhoneStorageRecommended;

  /// No description provided for @storageLocationAllFilesAccessWasnt.
  ///
  /// In zh, this message translates to:
  /// **'没有获得「所有文件访问权限」，游戏文件夹没有更改'**
  String get storageLocationAllFilesAccessWasnt;

  /// No description provided for @storageLocationMoveGameFiles.
  ///
  /// In zh, this message translates to:
  /// **'移动游戏文件'**
  String get storageLocationMoveGameFiles;

  /// No description provided for @storageLocationMoveInstancesWorldsResources.
  ///
  /// In zh, this message translates to:
  /// **'把现在游戏文件夹中的实例、存档与资源移到新位置吗？\n\n{from}\n→ {to}'**
  String storageLocationMoveInstancesWorldsResources(Object from, Object to);

  /// No description provided for @storageLocationJustSwitchDontMove.
  ///
  /// In zh, this message translates to:
  /// **'只切换，不移动'**
  String get storageLocationJustSwitchDontMove;

  /// No description provided for @storageLocationMove.
  ///
  /// In zh, this message translates to:
  /// **'移动'**
  String get storageLocationMove;

  /// No description provided for @storageLocationGameFolderChanged.
  ///
  /// In zh, this message translates to:
  /// **'游戏文件夹已更改为 {to}'**
  String storageLocationGameFolderChanged(Object to);

  /// No description provided for @storageLocationMovingGameFiles.
  ///
  /// In zh, this message translates to:
  /// **'正在移动游戏文件'**
  String get storageLocationMovingGameFiles;

  /// No description provided for @storageLocationMoveFailed.
  ///
  /// In zh, this message translates to:
  /// **'移动失败'**
  String get storageLocationMoveFailed;

  /// No description provided for @storageLocationFilesWereAlreadyMoved.
  ///
  /// In zh, this message translates to:
  /// **'{error}\n\n已经移动的文件在新位置，其余文件仍在原位置。'**
  String storageLocationFilesWereAlreadyMoved(Object error);

  /// No description provided for @storageLocationCountingFiles.
  ///
  /// In zh, this message translates to:
  /// **'正在统计文件…'**
  String get storageLocationCountingFiles;

  /// No description provided for @storageLocationFilesPleaseDontClose.
  ///
  /// In zh, this message translates to:
  /// **'{done} / {total} 个文件，请不要关闭启动器'**
  String storageLocationFilesPleaseDontClose(Object done, Object total);

  /// No description provided for @storageLocationCurrentGameFolder.
  ///
  /// In zh, this message translates to:
  /// **'当前游戏文件夹'**
  String get storageLocationCurrentGameFolder;

  /// No description provided for @storageLocationChange.
  ///
  /// In zh, this message translates to:
  /// **'更改'**
  String get storageLocationChange;

  /// No description provided for @storageLocationStorageLocation.
  ///
  /// In zh, this message translates to:
  /// **'存放位置'**
  String get storageLocationStorageLocation;

  /// No description provided for @storageLocationPhoneStorageKeptWhen.
  ///
  /// In zh, this message translates to:
  /// **'手机存储：卸载启动器后仍然保留'**
  String get storageLocationPhoneStorageKeptWhen;

  /// No description provided for @storageLocationAppStorageDeletedWhen.
  ///
  /// In zh, this message translates to:
  /// **'应用内部：卸载启动器时会一起删除，建议移到手机存储'**
  String get storageLocationAppStorageDeletedWhen;

  /// No description provided for @storageLocationMaintenance.
  ///
  /// In zh, this message translates to:
  /// **'维护'**
  String get storageLocationMaintenance;

  /// No description provided for @commonCleanUpGameJunk.
  ///
  /// In zh, this message translates to:
  /// **'清理游戏垃圾'**
  String get commonCleanUpGameJunk;

  /// No description provided for @storageLocationDeletesLogsCrashReports.
  ///
  /// In zh, this message translates to:
  /// **'删除日志、崩溃报告与解压出的本地库，不影响存档和模组'**
  String get storageLocationDeletesLogsCrashReports;

  /// No description provided for @commonCleanUp.
  ///
  /// In zh, this message translates to:
  /// **'清理'**
  String get commonCleanUp;

  /// No description provided for @storageLocationFileManager.
  ///
  /// In zh, this message translates to:
  /// **'文件管理'**
  String get storageLocationFileManager;

  /// No description provided for @storageLocationBrowseImportCopyDelete.
  ///
  /// In zh, this message translates to:
  /// **'浏览、导入、复制或删除游戏文件；删除的文件会先放进回收站'**
  String get storageLocationBrowseImportCopyDelete;

  /// No description provided for @launchDialogsJavaVersionMayIncompatible.
  ///
  /// In zh, this message translates to:
  /// **'Java 版本可能不兼容'**
  String get launchDialogsJavaVersionMayIncompatible;

  /// No description provided for @launchDialogsYouCanChangeJava.
  ///
  /// In zh, this message translates to:
  /// **'{message}\n\n可以在实例设置中把 Java 改为 Java 8 或自动选择。'**
  String launchDialogsYouCanChangeJava(Object message);

  /// No description provided for @launchDialogsLaunchAnyway.
  ///
  /// In zh, this message translates to:
  /// **'仍然启动'**
  String get launchDialogsLaunchAnyway;

  /// No description provided for @launchDialogsOtherTimes.
  ///
  /// In zh, this message translates to:
  /// **'已经启动 {launchCount} 次游戏啦'**
  String launchDialogsOtherTimes(num launchCount);

  /// No description provided for @launchDialogsMaintainedIfYouFind.
  ///
  /// In zh, this message translates to:
  /// **'{name} 由 {authorName} 维护。如果觉得好用，能否考虑赞助一下作者？\n\n本项目免费、没有广告，离不开大家的支持。'**
  String launchDialogsMaintainedIfYouFind(Object name, Object authorName);

  /// No description provided for @launchDialogsMaybeLater.
  ///
  /// In zh, this message translates to:
  /// **'下次再说'**
  String get launchDialogsMaybeLater;

  /// No description provided for @launchDialogsSignAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新登录 {serverName}'**
  String launchDialogsSignAgain(Object serverName);

  /// No description provided for @launchDialogsSignHasExpiredEnter.
  ///
  /// In zh, this message translates to:
  /// **'{name}（{login}）的登录已失效，请输入密码继续启动。'**
  String launchDialogsSignHasExpiredEnter(Object name, Object login);

  /// No description provided for @commonPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get commonPassword;

  /// No description provided for @launchDialogsCancelLaunch.
  ///
  /// In zh, this message translates to:
  /// **'取消启动'**
  String get launchDialogsCancelLaunch;

  /// No description provided for @commonSign.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get commonSign;

  /// No description provided for @updateDialogYoureLatestVersion.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本（{label}）'**
  String updateDialogYoureLatestVersion(Object label);

  /// No description provided for @updateDialogCouldntCheckUpdates.
  ///
  /// In zh, this message translates to:
  /// **'检查更新失败：{error}'**
  String updateDialogCouldntCheckUpdates(Object error);

  /// No description provided for @updateDialogNewVersionAvailable.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本：{label}'**
  String updateDialogNewVersionAvailable(Object label);

  /// No description provided for @updateDialogCurrentVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前版本 {current} · {prerelease}{date}'**
  String updateDialogCurrentVersion(Object current, Object prerelease, Object date);

  /// No description provided for @updateDialogReleased.
  ///
  /// In zh, this message translates to:
  /// **' · 发布于 {date}'**
  String updateDialogReleased(Object date);

  /// No description provided for @updateDialogNoReleaseNotes.
  ///
  /// In zh, this message translates to:
  /// **'没有更新说明'**
  String get updateDialogNoReleaseNotes;

  /// No description provided for @updateDialogNoPackageHasBeen.
  ///
  /// In zh, this message translates to:
  /// **'这个平台还没有发布包，请到 GitHub 查看。'**
  String get updateDialogNoPackageHasBeen;

  /// No description provided for @updateDialogReleaseHasNoFile.
  ///
  /// In zh, this message translates to:
  /// **'这个发布中没有适用于当前平台的文件。'**
  String get updateDialogReleaseHasNoFile;

  /// No description provided for @updateDialogAfterDownloadingInstallerImage.
  ///
  /// In zh, this message translates to:
  /// **'下载后会打开安装镜像，把 Pixel World 拖进「应用程序」文件夹替换旧版本即可；游戏文件不受影响。'**
  String get updateDialogAfterDownloadingInstallerImage;

  /// No description provided for @updateDialogAfterDownloadingSystemInstalls.
  ///
  /// In zh, this message translates to:
  /// **'下载后由系统安装，需要在弹出的界面中确认；游戏文件不受影响。'**
  String get updateDialogAfterDownloadingSystemInstalls;

  /// No description provided for @updateDialogDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载'**
  String get updateDialogDownloading;

  /// No description provided for @updateDialogDownloading2.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 {progress}%'**
  String updateDialogDownloading2(Object progress);

  /// No description provided for @updateDialogInstallerHasBeenDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'安装包已经下载完成。第一次安装需要在系统设置中允许「安装未知应用」；允许后回到这里点「继续安装」，不需要重新下载。'**
  String get updateDialogInstallerHasBeenDownloaded;

  /// No description provided for @updateDialogSkipVersion.
  ///
  /// In zh, this message translates to:
  /// **'跳过这个版本'**
  String get updateDialogSkipVersion;

  /// No description provided for @updateDialogViewGitHub.
  ///
  /// In zh, this message translates to:
  /// **'在 GitHub 查看'**
  String get updateDialogViewGitHub;

  /// No description provided for @updateDialogLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后'**
  String get updateDialogLater;

  /// No description provided for @updateDialogContinueInstall.
  ///
  /// In zh, this message translates to:
  /// **'继续安装'**
  String get updateDialogContinueInstall;

  /// No description provided for @updateDialogUpdateRestart.
  ///
  /// In zh, this message translates to:
  /// **'更新并重启'**
  String get updateDialogUpdateRestart;

  /// No description provided for @updateDialogDownloadInstall.
  ///
  /// In zh, this message translates to:
  /// **'下载并安装'**
  String get updateDialogDownloadInstall;

  /// No description provided for @pclImportDialogImportComplete.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get pclImportDialogImportComplete;

  /// No description provided for @pclImportDialogSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置：{settings}'**
  String pclImportDialogSettings(Object settings);

  /// No description provided for @pclImportDialogAddedGameFoldersAccounts.
  ///
  /// In zh, this message translates to:
  /// **'新增游戏文件夹 {folders} 个，账户 {accounts} 个'**
  String pclImportDialogAddedGameFoldersAccounts(Object folders, Object accounts);

  /// No description provided for @pclImportDialogNotImported.
  ///
  /// In zh, this message translates to:
  /// **'未导入：{skippedAccounts}'**
  String pclImportDialogNotImported(Object skippedAccounts);

  /// No description provided for @pclImportDialogFoundPCLCEConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'检测到 PCL-CE 的配置：{folders} 个游戏文件夹{hasAccounts}'**
  String pclImportDialogFoundPCLCEConfiguration(Object folders, Object hasAccounts);

  /// No description provided for @pclImportDialogAccounts.
  ///
  /// In zh, this message translates to:
  /// **'，有账户'**
  String get pclImportDialogAccounts;

  /// No description provided for @pclImportDialogNoPCLCEConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'没有在 %APPDATA%\\PCLCE 找到 PCL-CE 的配置，可以选择 PCL-CE 所在目录导入本地设置'**
  String get pclImportDialogNoPCLCEConfiguration;

  /// No description provided for @pclImportDialogPerInstanceSettingsDont.
  ///
  /// In zh, this message translates to:
  /// **'实例独立设置无需导入，两者直接共用。'**
  String get pclImportDialogPerInstanceSettingsDont;

  /// No description provided for @pclImportDialogLaunchSettings.
  ///
  /// In zh, this message translates to:
  /// **'启动设置'**
  String get pclImportDialogLaunchSettings;

  /// No description provided for @pclImportDialogMemoryJVMArgumentsMore.
  ///
  /// In zh, this message translates to:
  /// **'内存、JVM 参数等需要选择 PCL-CE 所在目录'**
  String get pclImportDialogMemoryJVMArgumentsMore;

  /// No description provided for @pclImportDialogImportedMicrosoftAccountsNeed.
  ///
  /// In zh, this message translates to:
  /// **'导入的微软账户过期后需要在这里重新登录'**
  String get pclImportDialogImportedMicrosoftAccountsNeed;

  /// No description provided for @pclImportDialogPCLCEFolderNot.
  ///
  /// In zh, this message translates to:
  /// **'PCL-CE 所在目录：未选择（可选）'**
  String get pclImportDialogPCLCEFolderNot;

  /// No description provided for @pclImportDialogPCLCEFolder.
  ///
  /// In zh, this message translates to:
  /// **'PCL-CE 所在目录：{pclDir}'**
  String pclImportDialogPCLCEFolder(Object pclDir);

  /// No description provided for @commonChoose.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get commonChoose;

  /// No description provided for @yggdrasilLoginDialogAuthenticationServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'验证服务器地址'**
  String get yggdrasilLoginDialogAuthenticationServerAddress;

  /// No description provided for @yggdrasilLoginDialogEnterAddressPickOne.
  ///
  /// In zh, this message translates to:
  /// **'输入地址，或从列表中选择'**
  String get yggdrasilLoginDialogEnterAddressPickOne;

  /// No description provided for @yggdrasilLoginDialogChooseProfile.
  ///
  /// In zh, this message translates to:
  /// **'选择角色'**
  String get yggdrasilLoginDialogChooseProfile;

  /// No description provided for @yggdrasilLoginDialogAuthenticationServer.
  ///
  /// In zh, this message translates to:
  /// **'验证服务器：{server}'**
  String yggdrasilLoginDialogAuthenticationServer(Object server);

  /// No description provided for @yggdrasilLoginDialogAddressIsntEncryptedYour.
  ///
  /// In zh, this message translates to:
  /// **'这个地址没有加密，密码会以明文传输'**
  String get yggdrasilLoginDialogAddressIsntEncryptedYour;

  /// No description provided for @yggdrasilLoginDialogEmailUsername.
  ///
  /// In zh, this message translates to:
  /// **'邮箱或用户名'**
  String get yggdrasilLoginDialogEmailUsername;

  /// No description provided for @yggdrasilLoginDialogPasswordSign.
  ///
  /// In zh, this message translates to:
  /// **'账户密码登录'**
  String get yggdrasilLoginDialogPasswordSign;

  /// No description provided for @yggdrasilLoginDialogOAuthAuthorization.
  ///
  /// In zh, this message translates to:
  /// **'OAuth 授权'**
  String get yggdrasilLoginDialogOAuthAuthorization;

  /// No description provided for @yggdrasilLoginDialogAccountPassword.
  ///
  /// In zh, this message translates to:
  /// **'账户密码'**
  String get yggdrasilLoginDialogAccountPassword;

  /// No description provided for @yggdrasilLoginDialogClickingStartOpensAuthorization.
  ///
  /// In zh, this message translates to:
  /// **'点击开始后会在浏览器中打开 {site} 的授权页面，确认授权并选择角色即可，启动器不会接触你的密码。'**
  String yggdrasilLoginDialogClickingStartOpensAuthorization(Object site);

  /// No description provided for @yggdrasilLoginDialogStartOAuthSign.
  ///
  /// In zh, this message translates to:
  /// **'开始 OAuth 登录'**
  String get yggdrasilLoginDialogStartOAuthSign;

  /// No description provided for @accountsDialogNoAccountsYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有账户'**
  String get accountsDialogNoAccountsYet;

  /// No description provided for @accountsDialogAddOfflineAccount.
  ///
  /// In zh, this message translates to:
  /// **'添加离线账户'**
  String get accountsDialogAddOfflineAccount;

  /// No description provided for @accountsDialogUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get accountsDialogUsername;

  /// No description provided for @accountsDialogMicrosoftAccounts.
  ///
  /// In zh, this message translates to:
  /// **'正版账户'**
  String get accountsDialogMicrosoftAccounts;

  /// No description provided for @accountsDialogMicrosoftSignNeedsAzure.
  ///
  /// In zh, this message translates to:
  /// **'微软登录需要先在「设置 - 其他」中填写 Azure 应用 Client ID。'**
  String get accountsDialogMicrosoftSignNeedsAzure;

  /// No description provided for @accountsDialogThirdPartyAccounts.
  ///
  /// In zh, this message translates to:
  /// **'第三方账户'**
  String get accountsDialogThirdPartyAccounts;

  /// No description provided for @maintenanceActionsNothingCleanUp.
  ///
  /// In zh, this message translates to:
  /// **'没有需要清理的文件'**
  String get maintenanceActionsNothingCleanUp;

  /// No description provided for @maintenanceActionsItemsWillDeletedLogs.
  ///
  /// In zh, this message translates to:
  /// **'将删除 {count} 项，共 {size}：\n游戏文件夹与各实例文件夹中的日志（logs、*.log）、崩溃报告（crash-reports、hs_err_pid*）与解压出的本地库（natives，启动时会重新生成）。\n\n存档、模组与设置不会被删除。'**
  String maintenanceActionsItemsWillDeletedLogs(Object count, Object size);

  /// No description provided for @maintenanceActionsCleanedUp.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {size}'**
  String maintenanceActionsCleanedUp(Object size);

  /// No description provided for @maintenanceActionsOtherItemsUseWerent.
  ///
  /// In zh, this message translates to:
  /// **'已清理，{failed} 项正在被使用，没有删除'**
  String maintenanceActionsOtherItemsUseWerent(num failed);

  /// No description provided for @maintenanceActionsCreated.
  ///
  /// In zh, this message translates to:
  /// **'已创建 {path}'**
  String maintenanceActionsCreated(Object path);

  /// No description provided for @fileViewerFileDoesntExist.
  ///
  /// In zh, this message translates to:
  /// **'文件不存在'**
  String get fileViewerFileDoesntExist;

  /// No description provided for @fileViewerPreview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get fileViewerPreview;

  /// No description provided for @fileViewerSource.
  ///
  /// In zh, this message translates to:
  /// **'源码'**
  String get fileViewerSource;

  /// No description provided for @fileViewerRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get fileViewerRefresh;

  /// No description provided for @fileViewerCopyAll.
  ///
  /// In zh, this message translates to:
  /// **'复制全文'**
  String get fileViewerCopyAll;

  /// No description provided for @fileViewerCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get fileViewerCopied;

  /// No description provided for @fileViewerShowFileManager.
  ///
  /// In zh, this message translates to:
  /// **'在文件管理器中打开'**
  String get fileViewerShowFileManager;

  /// No description provided for @fileViewerCantOpen.
  ///
  /// In zh, this message translates to:
  /// **'打不开：{error}'**
  String fileViewerCantOpen(Object error);

  /// No description provided for @fileViewerFileIsntTextLarger.
  ///
  /// In zh, this message translates to:
  /// **'这个文件不是文本，或者超过 2 MB，不能在这里查看'**
  String get fileViewerFileIsntTextLarger;

  /// No description provided for @deviceStatusMobileData.
  ///
  /// In zh, this message translates to:
  /// **'移动数据'**
  String get deviceStatusMobileData;

  /// No description provided for @deviceStatusEthernet.
  ///
  /// In zh, this message translates to:
  /// **'有线网络'**
  String get deviceStatusEthernet;

  /// No description provided for @deviceStatusConnected.
  ///
  /// In zh, this message translates to:
  /// **'已联网'**
  String get deviceStatusConnected;

  /// No description provided for @deviceStatusOffline.
  ///
  /// In zh, this message translates to:
  /// **'未联网'**
  String get deviceStatusOffline;

  /// No description provided for @deviceStatusFullyCharged.
  ///
  /// In zh, this message translates to:
  /// **'已充满'**
  String get deviceStatusFullyCharged;

  /// No description provided for @deviceStatusCharging.
  ///
  /// In zh, this message translates to:
  /// **'正在充电'**
  String get deviceStatusCharging;

  /// No description provided for @deviceStatusPlugged.
  ///
  /// In zh, this message translates to:
  /// **'已接通电源'**
  String get deviceStatusPlugged;

  /// No description provided for @deviceStatusBattery.
  ///
  /// In zh, this message translates to:
  /// **'电量'**
  String get deviceStatusBattery;

  /// No description provided for @deviceLoginDialogSignedAs.
  ///
  /// In zh, this message translates to:
  /// **'已登录 {name}'**
  String deviceLoginDialogSignedAs(Object name);

  /// No description provided for @deviceLoginDialogStartSign.
  ///
  /// In zh, this message translates to:
  /// **'开始登录'**
  String get deviceLoginDialogStartSign;

  /// No description provided for @deviceLoginDialogRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get deviceLoginDialogRetry;

  /// No description provided for @deviceLoginDialogAuthorizationPageHasOpened.
  ///
  /// In zh, this message translates to:
  /// **'已在浏览器中打开授权页面，请确认页面上的代码与下面一致后完成授权：'**
  String get deviceLoginDialogAuthorizationPageHasOpened;

  /// No description provided for @deviceLoginDialogSignPageHasOpened.
  ///
  /// In zh, this message translates to:
  /// **'已在浏览器中打开登录页面，请输入下面的代码（已复制到剪贴板）：'**
  String get deviceLoginDialogSignPageHasOpened;

  /// No description provided for @deviceLoginDialogWaitingSign.
  ///
  /// In zh, this message translates to:
  /// **'等待登录完成'**
  String get deviceLoginDialogWaitingSign;

  /// No description provided for @formatOtherYearsAgo.
  ///
  /// In zh, this message translates to:
  /// **'{inDays} 年前'**
  String formatOtherYearsAgo(num inDays);

  /// No description provided for @formatOtherMonthsAgo.
  ///
  /// In zh, this message translates to:
  /// **'{inDays} 个月前'**
  String formatOtherMonthsAgo(num inDays);

  /// No description provided for @formatOtherDaysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{inDays} 天前'**
  String formatOtherDaysAgo(num inDays);

  /// No description provided for @formatOtherHoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{inHours} 小时前'**
  String formatOtherHoursAgo(num inHours);

  /// No description provided for @formatJustNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get formatJustNow;

  /// No description provided for @themeColorDialogCustomThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'自定义主题色'**
  String get themeColorDialogCustomThemeColor;

  /// No description provided for @themeColorDialogR.
  ///
  /// In zh, this message translates to:
  /// **'红'**
  String get themeColorDialogR;

  /// No description provided for @themeColorDialogG.
  ///
  /// In zh, this message translates to:
  /// **'绿'**
  String get themeColorDialogG;

  /// No description provided for @themeColorDialogB.
  ///
  /// In zh, this message translates to:
  /// **'蓝'**
  String get themeColorDialogB;

  /// No description provided for @themeColorDialogUse.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get themeColorDialogUse;

  /// No description provided for @homeCouldntLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动失败：{error}'**
  String homeCouldntLaunch(Object error);

  /// No description provided for @homeCantOpenFolder.
  ///
  /// In zh, this message translates to:
  /// **'打不开文件夹：{error}'**
  String homeCantOpenFolder(Object error);

  /// No description provided for @homeRecentlyPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最近游玩'**
  String get homeRecentlyPlayed;

  /// No description provided for @homeAllWorlds.
  ///
  /// In zh, this message translates to:
  /// **'全部存档 ›'**
  String get homeAllWorlds;

  /// No description provided for @homeOtherMinutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes} 分钟前'**
  String homeOtherMinutesAgo(num inMinutes);

  /// No description provided for @homeMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String homeMonthDay(Object month, Object day);

  /// No description provided for @homeNoInstanceSelected.
  ///
  /// In zh, this message translates to:
  /// **'还没有选择实例'**
  String get homeNoInstanceSelected;

  /// No description provided for @homeInstallChooseInstanceFirst.
  ///
  /// In zh, this message translates to:
  /// **'先安装或选择一个实例，准备好就开始'**
  String get homeInstallChooseInstanceFirst;

  /// No description provided for @homeMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get homeMore;

  /// No description provided for @homeOpenInstanceFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开实例文件夹'**
  String get homeOpenInstanceFolder;

  /// No description provided for @commonModCount.
  ///
  /// In zh, this message translates to:
  /// **'{data} 个模组'**
  String commonModCount(num data);

  /// No description provided for @homeRenderer.
  ///
  /// In zh, this message translates to:
  /// **'{renderer} 渲染'**
  String homeRenderer(Object renderer);

  /// No description provided for @homePlayed.
  ///
  /// In zh, this message translates to:
  /// **'{modified}玩过'**
  String homePlayed(Object modified);

  /// No description provided for @homeBackGame.
  ///
  /// In zh, this message translates to:
  /// **'返回游戏'**
  String get homeBackGame;

  /// No description provided for @commonStopGame.
  ///
  /// In zh, this message translates to:
  /// **'结束游戏'**
  String get commonStopGame;

  /// No description provided for @homeAddMods.
  ///
  /// In zh, this message translates to:
  /// **'装模组'**
  String get homeAddMods;

  /// No description provided for @homeManageMods.
  ///
  /// In zh, this message translates to:
  /// **'管理模组'**
  String get homeManageMods;

  /// No description provided for @homeFolder.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get homeFolder;

  /// No description provided for @commonViewLog.
  ///
  /// In zh, this message translates to:
  /// **'查看日志'**
  String get commonViewLog;

  /// No description provided for @homeLauncherAnnouncements.
  ///
  /// In zh, this message translates to:
  /// **'启动器公告'**
  String get homeLauncherAnnouncements;

  /// No description provided for @homeLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在获取…'**
  String get homeLoading;

  /// No description provided for @commonNoAnnouncements.
  ///
  /// In zh, this message translates to:
  /// **'暂无公告'**
  String get commonNoAnnouncements;

  /// No description provided for @homeView.
  ///
  /// In zh, this message translates to:
  /// **'查看 ›'**
  String get homeView;

  /// No description provided for @homeSwitchInstanceWorld.
  ///
  /// In zh, this message translates to:
  /// **'切换到这个存档所在的实例'**
  String get homeSwitchInstanceWorld;

  /// No description provided for @homeYourRecentWorldsWill.
  ///
  /// In zh, this message translates to:
  /// **'开始一次游戏后，最近的存档会出现在这里。'**
  String get homeYourRecentWorldsWill;

  /// No description provided for @homeScrollDownMore.
  ///
  /// In zh, this message translates to:
  /// **'向下滚动查看更多'**
  String get homeScrollDownMore;

  /// No description provided for @homeSwipeUpMore.
  ///
  /// In zh, this message translates to:
  /// **'上滑查看更多'**
  String get homeSwipeUpMore;

  /// No description provided for @homeInstallChooseInstanceFirst2.
  ///
  /// In zh, this message translates to:
  /// **'先安装或选择一个实例'**
  String get homeInstallChooseInstanceFirst2;

  /// No description provided for @homeNoRecentlyPlayedWorlds.
  ///
  /// In zh, this message translates to:
  /// **'还没有最近游玩的存档'**
  String get homeNoRecentlyPlayedWorlds;

  /// No description provided for @homeAllWorlds2.
  ///
  /// In zh, this message translates to:
  /// **'全部存档'**
  String get homeAllWorlds2;

  /// No description provided for @homeOpenFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开文件夹'**
  String get homeOpenFolder;

  /// No description provided for @homeCurrentInstance.
  ///
  /// In zh, this message translates to:
  /// **'当前实例'**
  String get homeCurrentInstance;

  /// No description provided for @homeInstanceSettings.
  ///
  /// In zh, this message translates to:
  /// **'实例设置 ›'**
  String get homeInstanceSettings;

  /// No description provided for @homeType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get homeType;

  /// No description provided for @homeMods.
  ///
  /// In zh, this message translates to:
  /// **'模组'**
  String get homeMods;

  /// No description provided for @homeVanillaNoMods.
  ///
  /// In zh, this message translates to:
  /// **'原版，不加载模组'**
  String get homeVanillaNoMods;

  /// No description provided for @homeModCountValue.
  ///
  /// In zh, this message translates to:
  /// **'{data} 个'**
  String homeModCountValue(Object data);

  /// No description provided for @homeNotPlayedYet.
  ///
  /// In zh, this message translates to:
  /// **'还没玩过'**
  String get homeNotPlayedYet;

  /// No description provided for @homeInstanceID.
  ///
  /// In zh, this message translates to:
  /// **'实例 ID'**
  String get homeInstanceID;

  /// No description provided for @homeManageAllInstances.
  ///
  /// In zh, this message translates to:
  /// **'管理全部实例'**
  String get homeManageAllInstances;

  /// No description provided for @homeFeedYoureUsingBetaThird.
  ///
  /// In zh, this message translates to:
  /// **'你正在使用 {name} {version} 测试版。这是第三方 Minecraft 启动器，功能还在完善中，遇到问题请到 GitHub 反馈。'**
  String homeFeedYoureUsingBetaThird(Object name, Object version);

  /// No description provided for @homeFeedReportProblem.
  ///
  /// In zh, this message translates to:
  /// **'反馈问题'**
  String get homeFeedReportProblem;

  /// No description provided for @homeFeedSoftwareCompletelyFreeOpen.
  ///
  /// In zh, this message translates to:
  /// **'本软件完全免费、开源。如果你是付费购买或下载的，那么你可能被骗了，请向卖家申请退款，并从 GitHub 获取正版。'**
  String get homeFeedSoftwareCompletelyFreeOpen;

  /// No description provided for @homeFeedGetGenuineVersion.
  ///
  /// In zh, this message translates to:
  /// **'获取正版'**
  String get homeFeedGetGenuineVersion;

  /// No description provided for @homeFeedBetaThatsStillBeing.
  ///
  /// In zh, this message translates to:
  /// **'{name} {version} 测试版，功能还在完善中，遇到问题请到 GitHub 反馈。'**
  String homeFeedBetaThatsStillBeing(Object name, Object version);

  /// No description provided for @homeFeedSoftwareCompletelyFreeOpen2.
  ///
  /// In zh, this message translates to:
  /// **'本软件完全免费、开源。如果你是付费获得的，请向卖家申请退款，并从 GitHub 获取正版。'**
  String get homeFeedSoftwareCompletelyFreeOpen2;

  /// No description provided for @homeFeedHideBetaNoticeFree.
  ///
  /// In zh, this message translates to:
  /// **'关闭测试版提示（免费声明会保留）'**
  String get homeFeedHideBetaNoticeFree;

  /// No description provided for @homeFeedChangelogV.
  ///
  /// In zh, this message translates to:
  /// **'更新日志 · v{version}{channel}'**
  String homeFeedChangelogV(Object version, Object channel);

  /// No description provided for @homeFeedCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get homeFeedCollapse;

  /// No description provided for @homeFeedExpand.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get homeFeedExpand;

  /// No description provided for @homeFeedLoadingAnnouncements.
  ///
  /// In zh, this message translates to:
  /// **'正在获取公告…'**
  String get homeFeedLoadingAnnouncements;

  /// No description provided for @homeFeedViewDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get homeFeedViewDetails;

  /// No description provided for @homeFeedMinecraftVersionNews.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft 版本动态'**
  String get homeFeedMinecraftVersionNews;

  /// No description provided for @homeFeedFromMinecraftWiki.
  ///
  /// In zh, this message translates to:
  /// **'来自 Minecraft Wiki'**
  String get homeFeedFromMinecraftWiki;

  /// No description provided for @homeFeedCouldntLoad.
  ///
  /// In zh, this message translates to:
  /// **'加载失败：{error}'**
  String homeFeedCouldntLoad(Object error);

  /// No description provided for @homeFeedSnapshot.
  ///
  /// In zh, this message translates to:
  /// **'快照'**
  String get homeFeedSnapshot;

  /// No description provided for @homeFeedMinecraftWikiDoesntHave.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft Wiki 还没有这个版本的介绍，点击查看页面。'**
  String get homeFeedMinecraftWikiDoesntHave;

  /// No description provided for @versionsCurrentFolder.
  ///
  /// In zh, this message translates to:
  /// **'当前文件夹'**
  String get versionsCurrentFolder;

  /// No description provided for @versionsOfficialLauncherFolder.
  ///
  /// In zh, this message translates to:
  /// **'官方启动器文件夹'**
  String get versionsOfficialLauncherFolder;

  /// No description provided for @versionsLauncherDefaultFolder.
  ///
  /// In zh, this message translates to:
  /// **'启动器默认文件夹'**
  String get versionsLauncherDefaultFolder;

  /// No description provided for @versionsRemoveFromListFiles.
  ///
  /// In zh, this message translates to:
  /// **'从列表移除（不会删除文件）'**
  String get versionsRemoveFromListFiles;

  /// No description provided for @versionsAddFolder.
  ///
  /// In zh, this message translates to:
  /// **'添加文件夹'**
  String get versionsAddFolder;

  /// No description provided for @versionsNoInstancesFolderYet.
  ///
  /// In zh, this message translates to:
  /// **'这个文件夹中还没有实例'**
  String get versionsNoInstancesFolderYet;

  /// No description provided for @versionsOtherInstances.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个实例'**
  String versionsOtherInstances(num count);

  /// No description provided for @versionsNewInstance.
  ///
  /// In zh, this message translates to:
  /// **'新建实例'**
  String get versionsNewInstance;

  /// No description provided for @versionsSearchInstances.
  ///
  /// In zh, this message translates to:
  /// **'搜索实例'**
  String get versionsSearchInstances;

  /// No description provided for @versionsNoMatchingInstances.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的实例'**
  String get versionsNoMatchingInstances;

  /// No description provided for @tasksProgress.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个进行中'**
  String tasksProgress(Object count);

  /// No description provided for @tasksClearFinishedTasks.
  ///
  /// In zh, this message translates to:
  /// **'清除已结束的任务'**
  String get tasksClearFinishedTasks;

  /// No description provided for @tasksNoTasksYetInstalling.
  ///
  /// In zh, this message translates to:
  /// **'还没有任务。安装实例、下载资源或启动游戏时会显示在这里'**
  String get tasksNoTasksYetInstalling;

  /// No description provided for @tasksMinS.
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes} 分 {inSeconds} 秒'**
  String tasksMinS(Object inMinutes, Object inSeconds);

  /// No description provided for @tasksS.
  ///
  /// In zh, this message translates to:
  /// **'{inSeconds} 秒'**
  String tasksS(Object inSeconds);

  /// No description provided for @tasksCanceling.
  ///
  /// In zh, this message translates to:
  /// **'正在中断'**
  String get tasksCanceling;

  /// No description provided for @tasksProgress2.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get tasksProgress2;

  /// No description provided for @tasksCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get tasksCompleted;

  /// No description provided for @tasksFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get tasksFailed;

  /// No description provided for @tasksCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已中断'**
  String get tasksCanceled;

  /// No description provided for @tasksCanceling2.
  ///
  /// In zh, this message translates to:
  /// **'中断中…'**
  String get tasksCanceling2;

  /// No description provided for @tasksCancel.
  ///
  /// In zh, this message translates to:
  /// **'中断'**
  String get tasksCancel;

  /// No description provided for @tasksCopyLog.
  ///
  /// In zh, this message translates to:
  /// **'复制日志'**
  String get tasksCopyLog;

  /// No description provided for @commonLogCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制日志'**
  String get commonLogCopied;

  /// No description provided for @logGameRunning.
  ///
  /// In zh, this message translates to:
  /// **'游戏运行中'**
  String get logGameRunning;

  /// No description provided for @logStarting.
  ///
  /// In zh, this message translates to:
  /// **'正在启动'**
  String get logStarting;

  /// No description provided for @logGameNotRunning.
  ///
  /// In zh, this message translates to:
  /// **'游戏未运行'**
  String get logGameNotRunning;

  /// No description provided for @logGameExitedCode.
  ///
  /// In zh, this message translates to:
  /// **'游戏已退出，代码 {lastExitCode}'**
  String logGameExitedCode(Object lastExitCode);

  /// No description provided for @logAutoScroll.
  ///
  /// In zh, this message translates to:
  /// **'自动滚动'**
  String get logAutoScroll;

  /// No description provided for @logCopyAll.
  ///
  /// In zh, this message translates to:
  /// **'复制全部'**
  String get logCopyAll;

  /// No description provided for @logLogWillAppearHere.
  ///
  /// In zh, this message translates to:
  /// **'启动游戏后，日志会显示在这里'**
  String get logLogWillAppearHere;

  /// No description provided for @diagnoseGameCrashed.
  ///
  /// In zh, this message translates to:
  /// **'游戏崩溃了'**
  String get diagnoseGameCrashed;

  /// No description provided for @diagnoseExitedAbnormally.
  ///
  /// In zh, this message translates to:
  /// **'{title} 非正常退出。'**
  String diagnoseExitedAbnormally(Object title);

  /// No description provided for @diagnoseNoKnownProblemMatched.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配到已知的问题，可以查看日志，或使用 AI 分析。'**
  String get diagnoseNoKnownProblemMatched;

  /// No description provided for @diagnoseAIAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'AI 分析'**
  String get diagnoseAIAnalysis;

  /// No description provided for @diagnoseNothingAnalyze.
  ///
  /// In zh, this message translates to:
  /// **'没有要分析的内容'**
  String get diagnoseNothingAnalyze;

  /// No description provided for @diagnoseEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'环境'**
  String get diagnoseEnvironment;

  /// No description provided for @diagnoseInitialFindings.
  ///
  /// In zh, this message translates to:
  /// **'初步判断'**
  String get diagnoseInitialFindings;

  /// No description provided for @diagnoseNoKnownProblemMatched2.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配到已知的问题'**
  String get diagnoseNoKnownProblemMatched2;

  /// No description provided for @diagnoseUseAIAnalysisBelow.
  ///
  /// In zh, this message translates to:
  /// **'可以使用下面的 AI 分析，或查看日志摘录自行判断'**
  String get diagnoseUseAIAnalysisBelow;

  /// No description provided for @diagnoseExistingAIConversation.
  ///
  /// In zh, this message translates to:
  /// **'已有 AI 对话'**
  String get diagnoseExistingAIConversation;

  /// No description provided for @diagnoseAnalyzeAI.
  ///
  /// In zh, this message translates to:
  /// **'用 AI 分析'**
  String get diagnoseAnalyzeAI;

  /// No description provided for @diagnoseContinueCrashsConversationAI.
  ///
  /// In zh, this message translates to:
  /// **'在 AI 页面继续这次崩溃的对话'**
  String get diagnoseContinueCrashsConversationAI;

  /// No description provided for @diagnoseStartsNewConversationSends.
  ///
  /// In zh, this message translates to:
  /// **'新建一个对话，把下面的日志摘录与环境信息发送给 {host}（{model}）'**
  String diagnoseStartsNewConversationSends(Object host, Object model);

  /// No description provided for @diagnoseAnalyzeLogYourOwn.
  ///
  /// In zh, this message translates to:
  /// **'使用你自己的 AI 服务分析日志，需要先填写接口地址、模型和 API Key'**
  String get diagnoseAnalyzeLogYourOwn;

  /// No description provided for @diagnoseViewConversation.
  ///
  /// In zh, this message translates to:
  /// **'查看对话'**
  String get diagnoseViewConversation;

  /// No description provided for @diagnoseLogExcerpt.
  ///
  /// In zh, this message translates to:
  /// **'日志摘录'**
  String get diagnoseLogExcerpt;

  /// No description provided for @diagnoseNoLogsFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到日志'**
  String get diagnoseNoLogsFound;

  /// No description provided for @diagnoseCharactersTrimmedPrivateInformation.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个字符，已截取并去除隐私信息'**
  String diagnoseCharactersTrimmedPrivateInformation(Object count);

  /// No description provided for @diagnoseModList.
  ///
  /// In zh, this message translates to:
  /// **'模组列表'**
  String get diagnoseModList;

  /// No description provided for @diagnoseOtherEnabledMods.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个已启用的模组'**
  String diagnoseOtherEnabledMods(num count);

  /// No description provided for @docsFromPixelworldZhuzhiSite.
  ///
  /// In zh, this message translates to:
  /// **'来自 pixelworld.zhuzhi.site · 断网时显示最近一次缓存'**
  String get docsFromPixelworldZhuzhiSite;

  /// No description provided for @docsOpenBrowser.
  ///
  /// In zh, this message translates to:
  /// **'在浏览器打开'**
  String get docsOpenBrowser;

  /// No description provided for @instanceInstanceNoLongerExists.
  ///
  /// In zh, this message translates to:
  /// **'这个实例已不存在'**
  String get instanceInstanceNoLongerExists;

  /// No description provided for @instanceWorlds.
  ///
  /// In zh, this message translates to:
  /// **'存档'**
  String get instanceWorlds;

  /// No description provided for @commonResourcePacks.
  ///
  /// In zh, this message translates to:
  /// **'资源包'**
  String get commonResourcePacks;

  /// No description provided for @commonShaders.
  ///
  /// In zh, this message translates to:
  /// **'光影'**
  String get commonShaders;

  /// No description provided for @instanceScreenshots.
  ///
  /// In zh, this message translates to:
  /// **'截图'**
  String get instanceScreenshots;

  /// No description provided for @instanceSchematics.
  ///
  /// In zh, this message translates to:
  /// **'投影'**
  String get instanceSchematics;

  /// No description provided for @instanceServers.
  ///
  /// In zh, this message translates to:
  /// **'服务器'**
  String get instanceServers;

  /// No description provided for @instanceOverview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get instanceOverview;

  /// No description provided for @instanceChangeIcon.
  ///
  /// In zh, this message translates to:
  /// **'更换图标'**
  String get instanceChangeIcon;

  /// No description provided for @instanceCouldntChangeIcon.
  ///
  /// In zh, this message translates to:
  /// **'更换图标失败：{error}'**
  String instanceCouldntChangeIcon(Object error);

  /// No description provided for @instanceChangeIcon2.
  ///
  /// In zh, this message translates to:
  /// **'更换图标…'**
  String get instanceChangeIcon2;

  /// No description provided for @instanceRestoreDefaultIcon.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认图标'**
  String get instanceRestoreDefaultIcon;

  /// No description provided for @instanceBackList.
  ///
  /// In zh, this message translates to:
  /// **'返回{label}列表'**
  String instanceBackList(Object label);

  /// No description provided for @instanceDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除 {id}？'**
  String instanceDelete(Object id);

  /// No description provided for @instanceInstanceFolderWillMoved.
  ///
  /// In zh, this message translates to:
  /// **'实例文件夹会移到回收站。开启实例隔离时，其中的存档和模组也会一并删除。'**
  String get instanceInstanceFolderWillMoved;

  /// No description provided for @instanceDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {id}'**
  String instanceDeleted(Object id);

  /// No description provided for @instanceSetAsCurrentInstance.
  ///
  /// In zh, this message translates to:
  /// **'设为当前实例'**
  String get instanceSetAsCurrentInstance;

  /// No description provided for @commonGameVersion.
  ///
  /// In zh, this message translates to:
  /// **'游戏版本'**
  String get commonGameVersion;

  /// No description provided for @instanceDecidedAtFirstLaunch.
  ///
  /// In zh, this message translates to:
  /// **'首次启动时决定'**
  String get instanceDecidedAtFirstLaunch;

  /// No description provided for @instanceText.
  ///
  /// In zh, this message translates to:
  /// **'已开启'**
  String get instanceText;

  /// No description provided for @instanceOff.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get instanceOff;

  /// No description provided for @instanceWorkingDirectory.
  ///
  /// In zh, this message translates to:
  /// **'运行目录'**
  String get instanceWorkingDirectory;

  /// No description provided for @instanceReleaseDate.
  ///
  /// In zh, this message translates to:
  /// **'发布时间'**
  String get instanceReleaseDate;

  /// No description provided for @instanceShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'快捷方式'**
  String get instanceShortcuts;

  /// No description provided for @instanceInstanceFolder.
  ///
  /// In zh, this message translates to:
  /// **'实例文件夹'**
  String get instanceInstanceFolder;

  /// No description provided for @instanceFolder.
  ///
  /// In zh, this message translates to:
  /// **'{label}文件夹'**
  String instanceFolder(Object label);

  /// No description provided for @instanceManage.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get instanceManage;

  /// No description provided for @instanceSendInstance.
  ///
  /// In zh, this message translates to:
  /// **'发送这个实例'**
  String get instanceSendInstance;

  /// No description provided for @instanceSendWholeInstanceAnother.
  ///
  /// In zh, this message translates to:
  /// **'通过局域网把整个实例传到另一台设备'**
  String get instanceSendWholeInstanceAnother;

  /// No description provided for @instanceSend.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get instanceSend;

  /// No description provided for @instanceDeleteInstance.
  ///
  /// In zh, this message translates to:
  /// **'删除这个实例'**
  String get instanceDeleteInstance;

  /// No description provided for @instanceMovesRecycleBinIf.
  ///
  /// In zh, this message translates to:
  /// **'移到回收站；开启实例隔离时，其中的存档和模组也会一并删除'**
  String get instanceMovesRecycleBinIf;

  /// No description provided for @instanceUseGlobalSetting.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局设置'**
  String get instanceUseGlobalSetting;

  /// No description provided for @instanceNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'{javaKey}（未安装）'**
  String instanceNotInstalled(Object javaKey);

  /// No description provided for @instanceChooseManually.
  ///
  /// In zh, this message translates to:
  /// **'手动选择…'**
  String get instanceChooseManually;

  /// No description provided for @instanceTheseSettingsStoredPCL.
  ///
  /// In zh, this message translates to:
  /// **'这些设置保存在实例文件夹的 PCL/config.v1.yml 中，与 PCL-CE 互通'**
  String get instanceTheseSettingsStoredPCL;

  /// No description provided for @instanceNotDecidedYetSet.
  ///
  /// In zh, this message translates to:
  /// **'尚未决定：首次启动时按全局策略「{isolationMode}」决定，之后固定'**
  String instanceNotDecidedYetSet(Object isolationMode);

  /// No description provided for @instanceWorkingDirectoryInstanceFolder.
  ///
  /// In zh, this message translates to:
  /// **'运行目录为实例文件夹'**
  String get instanceWorkingDirectoryInstanceFolder;

  /// No description provided for @instanceText2.
  ///
  /// In zh, this message translates to:
  /// **'开启'**
  String get instanceText2;

  /// No description provided for @instanceGlobal.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局：{javaPath}'**
  String instanceGlobal(Object javaPath);

  /// No description provided for @instanceGlobalSetting.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局设置「{androidRenderer}」'**
  String instanceGlobalSetting(Object androidRenderer);

  /// No description provided for @instanceGlobalCustomGB.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局：自定义 {memoryTick} GB'**
  String instanceGlobalCustomGB(Object memoryTick);

  /// No description provided for @instanceGlobalAutomatic.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局：自动分配'**
  String get instanceGlobalAutomatic;

  /// No description provided for @instanceGlobal2.
  ///
  /// In zh, this message translates to:
  /// **'跟随全局'**
  String get instanceGlobal2;

  /// No description provided for @instanceMaximumMemory.
  ///
  /// In zh, this message translates to:
  /// **'最大内存'**
  String get instanceMaximumMemory;

  /// No description provided for @instanceInitialMemory.
  ///
  /// In zh, this message translates to:
  /// **'初始内存'**
  String get instanceInitialMemory;

  /// No description provided for @instanceNotSet.
  ///
  /// In zh, this message translates to:
  /// **'不设置'**
  String get instanceNotSet;

  /// No description provided for @instanceJoinServerAutomatically.
  ///
  /// In zh, this message translates to:
  /// **'自动进入服务器'**
  String get instanceJoinServerAutomatically;

  /// No description provided for @instanceLeaveEmptyUseGlobal.
  ///
  /// In zh, this message translates to:
  /// **'留空则使用全局设置'**
  String get instanceLeaveEmptyUseGlobal;

  /// No description provided for @instanceMovedRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'已将 {name} 移到回收站'**
  String instanceMovedRecycleBin(Object name);

  /// No description provided for @instanceTotalEnabled.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个，已启用 {enabledMods} 个'**
  String instanceTotalEnabled(Object count, Object enabledMods);

  /// No description provided for @instanceItemCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String instanceItemCount(Object count);

  /// No description provided for @instanceFilter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get instanceFilter;

  /// No description provided for @instanceSendWorld.
  ///
  /// In zh, this message translates to:
  /// **'发送存档'**
  String get instanceSendWorld;

  /// No description provided for @instanceAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加{label}'**
  String instanceAdd(Object label);

  /// No description provided for @instanceAddOptiFine.
  ///
  /// In zh, this message translates to:
  /// **'添加 OptiFine'**
  String get instanceAddOptiFine;

  /// No description provided for @instanceNoHereYet.
  ///
  /// In zh, this message translates to:
  /// **'这里还没有{label}'**
  String instanceNoHereYet(Object label);

  /// No description provided for @instanceDisabled.
  ///
  /// In zh, this message translates to:
  /// **' · 已禁用'**
  String get instanceDisabled;

  /// No description provided for @instanceMoveRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'移到回收站'**
  String get instanceMoveRecycleBin;

  /// No description provided for @instanceServersSavedGameMultiplayer.
  ///
  /// In zh, this message translates to:
  /// **'游戏内多人游戏列表中保存的服务器（servers.dat）'**
  String get instanceServersSavedGameMultiplayer;

  /// No description provided for @instanceNoSavedServersYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有保存的服务器'**
  String get instanceNoSavedServersYet;

  /// No description provided for @instanceCantConnect.
  ///
  /// In zh, this message translates to:
  /// **'无法连接'**
  String get instanceCantConnect;

  /// No description provided for @instanceOnlineMs.
  ///
  /// In zh, this message translates to:
  /// **'在线 {online}/{max} · {latency} ms'**
  String instanceOnlineMs(Object online, Object max, Object latency);

  /// No description provided for @instanceCouldntGetOptiFineVersions.
  ///
  /// In zh, this message translates to:
  /// **'获取 OptiFine 版本失败：{error}'**
  String instanceCouldntGetOptiFineVersions(Object error);

  /// No description provided for @instanceNoOptiFineCompatibleForge.
  ///
  /// In zh, this message translates to:
  /// **'没有与 Forge 兼容的 OptiFine（{gameVersion}）'**
  String instanceNoOptiFineCompatibleForge(Object gameVersion);

  /// No description provided for @instanceNoOptiFineAvailable.
  ///
  /// In zh, this message translates to:
  /// **'{gameVersion} 没有可用的 OptiFine'**
  String instanceNoOptiFineAvailable(Object gameVersion);

  /// No description provided for @commonOptiFineVersion.
  ///
  /// In zh, this message translates to:
  /// **'OptiFine 版本'**
  String get commonOptiFineVersion;

  /// No description provided for @commonPreview.
  ///
  /// In zh, this message translates to:
  /// **'（预览版）'**
  String get commonPreview;

  /// No description provided for @commonRequiresForge.
  ///
  /// In zh, this message translates to:
  /// **' · 需要 Forge {requiredForge}'**
  String commonRequiresForge(Object requiredForge);

  /// No description provided for @downloadModpacks.
  ///
  /// In zh, this message translates to:
  /// **'整合包'**
  String get downloadModpacks;

  /// No description provided for @downloadDataPacks.
  ///
  /// In zh, this message translates to:
  /// **'数据包'**
  String get downloadDataPacks;

  /// No description provided for @commonFavorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get commonFavorites;

  /// No description provided for @downloadOldVersions.
  ///
  /// In zh, this message translates to:
  /// **'远古版'**
  String get downloadOldVersions;

  /// No description provided for @downloadAprilFools.
  ///
  /// In zh, this message translates to:
  /// **'愚人节'**
  String get downloadAprilFools;

  /// No description provided for @downloadCouldntGetVersionList.
  ///
  /// In zh, this message translates to:
  /// **'获取版本列表失败：{error}'**
  String downloadCouldntGetVersionList(Object error);

  /// No description provided for @downloadLoadingVersionList.
  ///
  /// In zh, this message translates to:
  /// **'正在获取版本列表…'**
  String get downloadLoadingVersionList;

  /// No description provided for @downloadSearchVersions.
  ///
  /// In zh, this message translates to:
  /// **'搜索版本号'**
  String get downloadSearchVersions;

  /// No description provided for @downloadNoMatchingVersions.
  ///
  /// In zh, this message translates to:
  /// **'没有符合条件的版本'**
  String get downloadNoMatchingVersions;

  /// No description provided for @downloadLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get downloadLatest;

  /// No description provided for @downloadInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已安装'**
  String get downloadInstalled;

  /// No description provided for @downloadChooseVersionLeft.
  ///
  /// In zh, this message translates to:
  /// **'选择左边的版本'**
  String get downloadChooseVersionLeft;

  /// No description provided for @downloadPlainMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'纯净的 Minecraft'**
  String get downloadPlainMinecraft;

  /// No description provided for @downloadOldestLoaderMostMods.
  ///
  /// In zh, this message translates to:
  /// **'历史最久、模组最多的加载器'**
  String get downloadOldestLoaderMostMods;

  /// No description provided for @downloadCommunityForkForgeAvailable.
  ///
  /// In zh, this message translates to:
  /// **'从 Forge 分出的社区版，1.20.1 起可用'**
  String get downloadCommunityForkForgeAvailable;

  /// No description provided for @downloadModernized1122.
  ///
  /// In zh, this message translates to:
  /// **'基于 Forge 的 1.12.2 现代化分支，需要 Java 21'**
  String get downloadModernized1122;

  /// No description provided for @downloadAllOneClientLots.
  ///
  /// In zh, this message translates to:
  /// **'自带大量功能的整合客户端（LabyMod 4）'**
  String get downloadAllOneClientLots;

  /// No description provided for @downloadLightweightFastUpdatingMod.
  ///
  /// In zh, this message translates to:
  /// **'轻量、更新快的模组加载器'**
  String get downloadLightweightFastUpdatingMod;

  /// No description provided for @downloadCompatibleMostFabricMods.
  ///
  /// In zh, this message translates to:
  /// **'兼容大部分 Fabric 模组'**
  String get downloadCompatibleMostFabricMods;

  /// No description provided for @downloadFabricPorted113.
  ///
  /// In zh, this message translates to:
  /// **'为 1.13.2 及更早版本移植的 Fabric'**
  String get downloadFabricPorted113;

  /// No description provided for @downloadLightweightLoader112.
  ///
  /// In zh, this message translates to:
  /// **'1.12.2 及更早版本的轻量加载器'**
  String get downloadLightweightLoader112;

  /// No description provided for @downloadInstallationStartedSeeBackground.
  ///
  /// In zh, this message translates to:
  /// **'已开始安装，进度见顶栏的后台任务'**
  String get downloadInstallationStartedSeeBackground;

  /// No description provided for @downloadInstalled2.
  ///
  /// In zh, this message translates to:
  /// **'{id} 安装完成'**
  String downloadInstalled2(Object id);

  /// No description provided for @commonTaskCanceled.
  ///
  /// In zh, this message translates to:
  /// **'任务已中断'**
  String get commonTaskCanceled;

  /// No description provided for @commonInstallationFailed.
  ///
  /// In zh, this message translates to:
  /// **'安装失败：{error}'**
  String commonInstallationFailed(Object error);

  /// No description provided for @downloadIsntSupported.
  ///
  /// In zh, this message translates to:
  /// **'不支持 {id}'**
  String downloadIsntSupported(Object id);

  /// No description provided for @downloadNone.
  ///
  /// In zh, this message translates to:
  /// **'不加装'**
  String get downloadNone;

  /// No description provided for @downloadInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装 {id}'**
  String downloadInstall(Object id);

  /// No description provided for @downloadLoadingLoaders.
  ///
  /// In zh, this message translates to:
  /// **'正在获取加载器 {count}/{count2}'**
  String downloadLoadingLoaders(Object count, Object count2);

  /// No description provided for @downloadInstanceName.
  ///
  /// In zh, this message translates to:
  /// **'实例名称'**
  String get downloadInstanceName;

  /// No description provided for @downloadInstancesAlreadyInstalledInstalls.
  ///
  /// In zh, this message translates to:
  /// **'已经有 {same} 个 {id} 的实例；这次会再装一个独立的实例，存档和模组互不影响'**
  String downloadInstancesAlreadyInstalledInstalls(Object same, Object id);

  /// No description provided for @downloadVanilla.
  ///
  /// In zh, this message translates to:
  /// **'原版'**
  String get downloadVanilla;

  /// No description provided for @downloadVersion.
  ///
  /// In zh, this message translates to:
  /// **'{label} 版本'**
  String downloadVersion(Object label);

  /// No description provided for @downloadBeta.
  ///
  /// In zh, this message translates to:
  /// **'{label}（测试版）'**
  String downloadBeta(Object label);

  /// No description provided for @downloadInstallOptiFineToo.
  ///
  /// In zh, this message translates to:
  /// **'同时安装 OptiFine'**
  String get downloadInstallOptiFineToo;

  /// No description provided for @downloadLoadingOptiFineVersions.
  ///
  /// In zh, this message translates to:
  /// **'正在获取 OptiFine 版本…'**
  String get downloadLoadingOptiFineVersions;

  /// No description provided for @downloadCantInstalledTogetherOptiFine.
  ///
  /// In zh, this message translates to:
  /// **'{label} 不支持与 OptiFine 一起安装'**
  String downloadCantInstalledTogetherOptiFine(Object label);

  /// No description provided for @downloadNoOptiFineCompatibleForge.
  ///
  /// In zh, this message translates to:
  /// **'没有与 Forge 兼容的 OptiFine'**
  String get downloadNoOptiFineCompatibleForge;

  /// No description provided for @downloadNoOptiFineVersion.
  ///
  /// In zh, this message translates to:
  /// **'该版本没有 OptiFine'**
  String get downloadNoOptiFineVersion;

  /// No description provided for @downloadSelectedForgeDiffersFrom.
  ///
  /// In zh, this message translates to:
  /// **'当前选择的 Forge 与 OptiFine 要求的版本不同，较新的 Forge 可能与它不兼容'**
  String get downloadSelectedForgeDiffersFrom;

  /// No description provided for @downloadInstallAs.
  ///
  /// In zh, this message translates to:
  /// **'安装为 {text}'**
  String downloadInstallAs(Object text);

  /// No description provided for @commonInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装'**
  String get commonInstall;

  /// No description provided for @resourcesModrinthModpacks.
  ///
  /// In zh, this message translates to:
  /// **'Modrinth 整合包'**
  String get resourcesModrinthModpacks;

  /// No description provided for @resourcesInstalledModpackAs.
  ///
  /// In zh, this message translates to:
  /// **'已安装整合包为 {id}'**
  String resourcesInstalledModpackAs(Object id);

  /// No description provided for @resourcesAddingOnlyCompatibleShown.
  ///
  /// In zh, this message translates to:
  /// **'正在为 {id} 添加{label} · 只显示适配 {gameVersion} 的{label}，安装时直接装进这个实例'**
  String resourcesAddingOnlyCompatibleShown(Object id, Object label, Object gameVersion);

  /// No description provided for @resourcesBrowseNormally.
  ///
  /// In zh, this message translates to:
  /// **'改为普通浏览'**
  String get resourcesBrowseNormally;

  /// No description provided for @resourcesSearchModrinth.
  ///
  /// In zh, this message translates to:
  /// **'在 Modrinth 搜索{label}'**
  String resourcesSearchModrinth(Object label);

  /// No description provided for @resourcesText.
  ///
  /// In zh, this message translates to:
  /// **'适配 {id}'**
  String resourcesText(Object id);

  /// No description provided for @resourcesSort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get resourcesSort;

  /// No description provided for @resourcesRelevance.
  ///
  /// In zh, this message translates to:
  /// **'相关性'**
  String get resourcesRelevance;

  /// No description provided for @resourcesDownloads.
  ///
  /// In zh, this message translates to:
  /// **'下载量'**
  String get resourcesDownloads;

  /// No description provided for @resourcesFollows.
  ///
  /// In zh, this message translates to:
  /// **'关注数'**
  String get resourcesFollows;

  /// No description provided for @resourcesNewest.
  ///
  /// In zh, this message translates to:
  /// **'最新发布'**
  String get resourcesNewest;

  /// No description provided for @resourcesRecentlyUpdated.
  ///
  /// In zh, this message translates to:
  /// **'最近更新'**
  String get resourcesRecentlyUpdated;

  /// No description provided for @resourcesSort2.
  ///
  /// In zh, this message translates to:
  /// **'排序 {sort}'**
  String resourcesSort2(Object sort);

  /// No description provided for @resourcesInstallFromFile.
  ///
  /// In zh, this message translates to:
  /// **'从文件安装'**
  String get resourcesInstallFromFile;

  /// No description provided for @resourcesNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到结果'**
  String get resourcesNoResults;

  /// No description provided for @resourcesLoadMore.
  ///
  /// In zh, this message translates to:
  /// **'加载更多'**
  String get resourcesLoadMore;

  /// No description provided for @resourcesRemoveFromFavorites.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get resourcesRemoveFromFavorites;

  /// No description provided for @resourcesNoInstancesInstalledYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有安装任何实例'**
  String get resourcesNoInstancesInstalledYet;

  /// No description provided for @resourcesHasNoModLoader.
  ///
  /// In zh, this message translates to:
  /// **'{id} 没有安装模组加载器，模组不会生效'**
  String resourcesHasNoModLoader(Object id);

  /// No description provided for @resourcesHasNoWorldsYet.
  ///
  /// In zh, this message translates to:
  /// **'{id} 还没有存档，请先进入游戏创建一个世界'**
  String resourcesHasNoWorldsYet(Object id);

  /// No description provided for @resourcesInstalledFiles.
  ///
  /// In zh, this message translates to:
  /// **'已安装 {count} 个文件'**
  String resourcesInstalledFiles(Object count);

  /// No description provided for @resourcesAlreadyPresent.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个已存在'**
  String resourcesAlreadyPresent(Object count);

  /// No description provided for @resourcesNoCompatibleDependencyFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到兼容的前置：{missing}'**
  String resourcesNoCompatibleDependencyFound(Object missing);

  /// No description provided for @resourcesDownloads2.
  ///
  /// In zh, this message translates to:
  /// **'{author} · {label} · {downloads} 次下载{updated}'**
  String resourcesDownloads2(Object author, Object label, Object downloads, Object updated);

  /// No description provided for @resourcesUpdated.
  ///
  /// In zh, this message translates to:
  /// **' · 更新于 {updated}'**
  String resourcesUpdated(Object updated);

  /// No description provided for @resourcesViewModrinth.
  ///
  /// In zh, this message translates to:
  /// **'在 Modrinth 查看'**
  String get resourcesViewModrinth;

  /// No description provided for @resourcesInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装到 {target}'**
  String resourcesInstall(Object target);

  /// No description provided for @resourcesInstall2.
  ///
  /// In zh, this message translates to:
  /// **'安装到'**
  String get resourcesInstall2;

  /// No description provided for @resourcesWillInstalledAsNew.
  ///
  /// In zh, this message translates to:
  /// **'将安装为新的实例'**
  String get resourcesWillInstalledAsNew;

  /// No description provided for @resourcesWorld.
  ///
  /// In zh, this message translates to:
  /// **'世界'**
  String get resourcesWorld;

  /// No description provided for @resourcesShowAllFiles.
  ///
  /// In zh, this message translates to:
  /// **'显示全部文件'**
  String get resourcesShowAllFiles;

  /// No description provided for @resourcesNoFilesAvailable.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的文件'**
  String get resourcesNoFilesAvailable;

  /// No description provided for @resourcesNoFilesYouCan.
  ///
  /// In zh, this message translates to:
  /// **'没有适配 {gameVersion} 的文件，可以打开「显示全部文件」'**
  String resourcesNoFilesYouCan(Object gameVersion);

  /// No description provided for @resourcesRelease.
  ///
  /// In zh, this message translates to:
  /// **'正式'**
  String get resourcesRelease;

  /// No description provided for @resourcesVersions.
  ///
  /// In zh, this message translates to:
  /// **'{list} ~ {list2}（{count} 个版本）'**
  String resourcesVersions(Object list, Object list2, Object count);

  /// No description provided for @resourcesFavorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏夹'**
  String get resourcesFavorites;

  /// No description provided for @resourcesNoFavoritesYetClick.
  ///
  /// In zh, this message translates to:
  /// **'还没有收藏，点击资源右侧的心形图标即可收藏'**
  String get resourcesNoFavoritesYetClick;

  /// No description provided for @toolsMultiplayer.
  ///
  /// In zh, this message translates to:
  /// **'联机'**
  String get toolsMultiplayer;

  /// No description provided for @toolsLANTransfer.
  ///
  /// In zh, this message translates to:
  /// **'局域网互传'**
  String get toolsLANTransfer;

  /// No description provided for @toolsSendModsWorldsWhole.
  ///
  /// In zh, this message translates to:
  /// **'在两台设备之间传模组、存档、整个实例'**
  String get toolsSendModsWorldsWhole;

  /// No description provided for @toolsServerLookup.
  ///
  /// In zh, this message translates to:
  /// **'服务器查询'**
  String get toolsServerLookup;

  /// No description provided for @toolsCheckServersPlayerCount.
  ///
  /// In zh, this message translates to:
  /// **'查询服务器在线人数和延迟'**
  String get toolsCheckServersPlayerCount;

  /// No description provided for @toolsMultiplayerLobby.
  ///
  /// In zh, this message translates to:
  /// **'联机大厅'**
  String get toolsMultiplayerLobby;

  /// No description provided for @toolsPlanned.
  ///
  /// In zh, this message translates to:
  /// **'规划中'**
  String get toolsPlanned;

  /// No description provided for @toolsTroubleshooting.
  ///
  /// In zh, this message translates to:
  /// **'排错'**
  String get toolsTroubleshooting;

  /// No description provided for @toolsReadLogsFindCause.
  ///
  /// In zh, this message translates to:
  /// **'查看日志，自动找出崩溃原因'**
  String get toolsReadLogsFindCause;

  /// No description provided for @toolsUtilities.
  ///
  /// In zh, this message translates to:
  /// **'实用'**
  String get toolsUtilities;

  /// No description provided for @toolsCustomDownload.
  ///
  /// In zh, this message translates to:
  /// **'自定义下载'**
  String get toolsCustomDownload;

  /// No description provided for @toolsDownloadFileFromLink.
  ///
  /// In zh, this message translates to:
  /// **'按链接下载文件到指定位置'**
  String get toolsDownloadFileFromLink;

  /// No description provided for @toolsFun.
  ///
  /// In zh, this message translates to:
  /// **'趣味'**
  String get toolsFun;

  /// No description provided for @toolsSkinsAvatars.
  ///
  /// In zh, this message translates to:
  /// **'皮肤与头像'**
  String get toolsSkinsAvatars;

  /// No description provided for @toolsViewDownloadMinecraftPlayers.
  ///
  /// In zh, this message translates to:
  /// **'查看和下载正版玩家的皮肤'**
  String get toolsViewDownloadMinecraftPlayers;

  /// No description provided for @toolsAchievementImage.
  ///
  /// In zh, this message translates to:
  /// **'成就图片'**
  String get toolsAchievementImage;

  /// No description provided for @toolsMakeCustomAchievementToast.
  ///
  /// In zh, this message translates to:
  /// **'生成自定义的成就弹窗图片'**
  String get toolsMakeCustomAchievementToast;

  /// No description provided for @toolsTodaysLuck.
  ///
  /// In zh, this message translates to:
  /// **'今日人品'**
  String get toolsTodaysLuck;

  /// No description provided for @toolsSeeHowLuckyYou.
  ///
  /// In zh, this message translates to:
  /// **'看看今天的运气，每人每天固定'**
  String get toolsSeeHowLuckyYou;

  /// No description provided for @toolsBackTools.
  ///
  /// In zh, this message translates to:
  /// **'返回工具'**
  String get toolsBackTools;

  /// No description provided for @toolsPNGImage.
  ///
  /// In zh, this message translates to:
  /// **'PNG 图片'**
  String get toolsPNGImage;

  /// No description provided for @toolsLetsFewPlayersForm.
  ///
  /// In zh, this message translates to:
  /// **'让几位玩家组成虚拟局域网一起游戏，正在规划中'**
  String get toolsLetsFewPlayersForm;

  /// No description provided for @toolsNoGameHasBeen.
  ///
  /// In zh, this message translates to:
  /// **'本次打开启动器后还没有启动过游戏'**
  String get toolsNoGameHasBeen;

  /// No description provided for @toolsLog.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get toolsLog;

  /// No description provided for @toolsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'内容为空'**
  String get toolsEmpty;

  /// No description provided for @toolsPasteLog.
  ///
  /// In zh, this message translates to:
  /// **'粘贴日志'**
  String get toolsPasteLog;

  /// No description provided for @toolsPasteCrashReportLog.
  ///
  /// In zh, this message translates to:
  /// **'粘贴崩溃报告或日志内容'**
  String get toolsPasteCrashReportLog;

  /// No description provided for @toolsAnalyze.
  ///
  /// In zh, this message translates to:
  /// **'分析'**
  String get toolsAnalyze;

  /// No description provided for @toolsPastedLog.
  ///
  /// In zh, this message translates to:
  /// **'粘贴的日志'**
  String get toolsPastedLog;

  /// No description provided for @toolsLastGame.
  ///
  /// In zh, this message translates to:
  /// **'最近一次游戏'**
  String get toolsLastGame;

  /// No description provided for @toolsAnalyzeMostRecentGame.
  ///
  /// In zh, this message translates to:
  /// **'分析本次打开启动器后最近一次运行的游戏'**
  String get toolsAnalyzeMostRecentGame;

  /// No description provided for @toolsLogFile.
  ///
  /// In zh, this message translates to:
  /// **'日志文件'**
  String get toolsLogFile;

  /// No description provided for @toolsChooseCrashReportCrash.
  ///
  /// In zh, this message translates to:
  /// **'选择崩溃报告（crash-reports）或日志文件（logs）'**
  String get toolsChooseCrashReportCrash;

  /// No description provided for @toolsPasteCrashReportLog2.
  ///
  /// In zh, this message translates to:
  /// **'粘贴别人发给你的崩溃报告或日志'**
  String get toolsPasteCrashReportLog2;

  /// No description provided for @toolsPaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get toolsPaste;

  /// No description provided for @toolsLauncherFirstMatchesCommon.
  ///
  /// In zh, this message translates to:
  /// **'启动器先用本地规则匹配常见问题；在「设置 → AI 排障」填写自己的 AI 服务后，还可以让 AI 分析日志。游戏崩溃时会自动弹出提示。'**
  String get toolsLauncherFirstMatchesCommon;

  /// No description provided for @toolsPlayer.
  ///
  /// In zh, this message translates to:
  /// **'玩家'**
  String get toolsPlayer;

  /// No description provided for @toolsSLuckToday.
  ///
  /// In zh, this message translates to:
  /// **'{name} 的今日人品'**
  String toolsSLuckToday(Object name);

  /// No description provided for @toolsFixedEachPlayerEach.
  ///
  /// In zh, this message translates to:
  /// **'每人每天固定'**
  String get toolsFixedEachPlayerEach;

  /// No description provided for @toolsLaunchCount.
  ///
  /// In zh, this message translates to:
  /// **'启动次数'**
  String get toolsLaunchCount;

  /// No description provided for @toolsYouveLaunchedGameTimes.
  ///
  /// In zh, this message translates to:
  /// **'已经通过启动器启动了 {launchCount} 次游戏'**
  String toolsYouveLaunchedGameTimes(num launchCount);

  /// No description provided for @toolsSave.
  ///
  /// In zh, this message translates to:
  /// **'保存到'**
  String get toolsSave;

  /// No description provided for @toolsDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载 {name}'**
  String toolsDownload(Object name);

  /// No description provided for @toolsDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败：{error}'**
  String toolsDownloadFailed(Object error);

  /// No description provided for @toolsDownloadAnyFileProgress.
  ///
  /// In zh, this message translates to:
  /// **'下载任意文件，进度显示在任务页'**
  String get toolsDownloadAnyFileProgress;

  /// No description provided for @toolsDownloadURL.
  ///
  /// In zh, this message translates to:
  /// **'下载地址'**
  String get toolsDownloadURL;

  /// No description provided for @toolsFileNameOptional.
  ///
  /// In zh, this message translates to:
  /// **'文件名（可选）'**
  String get toolsFileNameOptional;

  /// No description provided for @toolsSaveLocationChosenWhen.
  ///
  /// In zh, this message translates to:
  /// **'保存位置：开始下载时选择'**
  String get toolsSaveLocationChosenWhen;

  /// No description provided for @toolsSaveLocation.
  ///
  /// In zh, this message translates to:
  /// **'保存位置：{dir}'**
  String toolsSaveLocation(Object dir);

  /// No description provided for @toolsStartDownload.
  ///
  /// In zh, this message translates to:
  /// **'开始下载'**
  String get toolsStartDownload;

  /// No description provided for @toolsSkinImage.
  ///
  /// In zh, this message translates to:
  /// **'皮肤图片'**
  String get toolsSkinImage;

  /// No description provided for @toolsSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {path}'**
  String toolsSaved(Object path);

  /// No description provided for @toolsPlayerSkins.
  ///
  /// In zh, this message translates to:
  /// **'正版皮肤'**
  String get toolsPlayerSkins;

  /// No description provided for @toolsMinecraftPlayerName.
  ///
  /// In zh, this message translates to:
  /// **'正版玩家名'**
  String get toolsMinecraftPlayerName;

  /// No description provided for @toolsGet.
  ///
  /// In zh, this message translates to:
  /// **'获取'**
  String get toolsGet;

  /// No description provided for @toolsAlexModelSlimArms.
  ///
  /// In zh, this message translates to:
  /// **'Alex 模型（细手臂）'**
  String get toolsAlexModelSlimArms;

  /// No description provided for @toolsSteveModel.
  ///
  /// In zh, this message translates to:
  /// **'Steve 模型'**
  String get toolsSteveModel;

  /// No description provided for @toolsSaveSkin.
  ///
  /// In zh, this message translates to:
  /// **'保存皮肤'**
  String get toolsSaveSkin;

  /// No description provided for @toolsAvatarMaker.
  ///
  /// In zh, this message translates to:
  /// **'头像生成'**
  String get toolsAvatarMaker;

  /// No description provided for @toolsCropsHeadHatLayer.
  ///
  /// In zh, this message translates to:
  /// **'从皮肤截取头部（含帽子层）并放大，可用上面获取的正版皮肤或本地皮肤文件'**
  String get toolsCropsHeadHatLayer;

  /// No description provided for @toolsChooseLocalSkin.
  ///
  /// In zh, this message translates to:
  /// **'选择本地皮肤'**
  String get toolsChooseLocalSkin;

  /// No description provided for @toolsLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地：{localName}'**
  String toolsLocal(Object localName);

  /// No description provided for @toolsSaveAvatar.
  ///
  /// In zh, this message translates to:
  /// **'保存 {size}×{size} 头像'**
  String toolsSaveAvatar(Object size);

  /// No description provided for @toolsFetchPlayersSkinChoose.
  ///
  /// In zh, this message translates to:
  /// **'先获取正版皮肤或选择本地皮肤'**
  String get toolsFetchPlayersSkinChoose;

  /// No description provided for @toolsServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get toolsServerAddress;

  /// No description provided for @toolsMcExampleCom1.
  ///
  /// In zh, this message translates to:
  /// **'mc.example.com 或 1.2.3.4:25565'**
  String get toolsMcExampleCom1;

  /// No description provided for @toolsLookUp.
  ///
  /// In zh, this message translates to:
  /// **'查询'**
  String get toolsLookUp;

  /// No description provided for @toolsOnlineMsLatency.
  ///
  /// In zh, this message translates to:
  /// **'在线 {online} / {max} · {version} · 延迟 {latency} ms'**
  String toolsOnlineMsLatency(Object online, Object max, Object version, Object latency);

  /// No description provided for @toolsAchievementGet.
  ///
  /// In zh, this message translates to:
  /// **'获得成就！'**
  String get toolsAchievementGet;

  /// No description provided for @toolsFillTitleFirstLine.
  ///
  /// In zh, this message translates to:
  /// **'请填写标题和第一行文字'**
  String get toolsFillTitleFirstLine;

  /// No description provided for @toolsMakesMinecraftStyleAchievement.
  ///
  /// In zh, this message translates to:
  /// **'生成 Minecraft 风格的成就提示图片。优先由第三方服务 minecraft-api.com 生成（填写的文字会发送给它）；该服务拒绝请求时在本地绘制，本地绘制使用系统字体和你选择的图标'**
  String get toolsMakesMinecraftStyleAchievement;

  /// No description provided for @toolsItemIDOnline.
  ///
  /// In zh, this message translates to:
  /// **'物品 ID（在线生成）'**
  String get toolsItemIDOnline;

  /// No description provided for @toolsEGDiamondGrass.
  ///
  /// In zh, this message translates to:
  /// **'例如 diamond、grass、golden_apple'**
  String get toolsEGDiamondGrass;

  /// No description provided for @toolsIcon.
  ///
  /// In zh, this message translates to:
  /// **'图标'**
  String get toolsIcon;

  /// No description provided for @toolsIconLocalDrawing.
  ///
  /// In zh, this message translates to:
  /// **'图标（本地绘制）'**
  String get toolsIconLocalDrawing;

  /// No description provided for @toolsTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get toolsTitle;

  /// No description provided for @toolsFirstLine.
  ///
  /// In zh, this message translates to:
  /// **'第一行'**
  String get toolsFirstLine;

  /// No description provided for @toolsSecondLineOptional.
  ///
  /// In zh, this message translates to:
  /// **'第二行（可选）'**
  String get toolsSecondLineOptional;

  /// No description provided for @toolsGenerate.
  ///
  /// In zh, this message translates to:
  /// **'生成'**
  String get toolsGenerate;

  /// No description provided for @toolsSaveImage.
  ///
  /// In zh, this message translates to:
  /// **'保存图片'**
  String get toolsSaveImage;

  /// No description provided for @toolsOnlineServiceIsntAvailable.
  ///
  /// In zh, this message translates to:
  /// **'在线服务不可用，以下为本地绘制'**
  String get toolsOnlineServiceIsntAvailable;

  /// No description provided for @fileManagerSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get fileManagerSave;

  /// No description provided for @fileManagerEnterValidFileName.
  ///
  /// In zh, this message translates to:
  /// **'请填写有效的文件名'**
  String get fileManagerEnterValidFileName;

  /// No description provided for @fileManagerFolderSameNameAlready.
  ///
  /// In zh, this message translates to:
  /// **'已经有同名的文件夹'**
  String get fileManagerFolderSameNameAlready;

  /// No description provided for @fileManagerReplaceExistingFile.
  ///
  /// In zh, this message translates to:
  /// **'替换已有的文件？'**
  String get fileManagerReplaceExistingFile;

  /// No description provided for @fileManagerAlreadyExistsFolderSaving.
  ///
  /// In zh, this message translates to:
  /// **'这个文件夹里已经有「{name}」，保存后会替换它。'**
  String fileManagerAlreadyExistsFolderSaving(Object name);

  /// No description provided for @fileManagerReplace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get fileManagerReplace;

  /// No description provided for @fileManagerName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get fileManagerName;

  /// No description provided for @fileManagerOK.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get fileManagerOK;

  /// No description provided for @fileManagerNamesCantContain.
  ///
  /// In zh, this message translates to:
  /// **'名称不能包含 / 或 \\'**
  String get fileManagerNamesCantContain;

  /// No description provided for @fileManagerNewFolder.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get fileManagerNewFolder;

  /// No description provided for @fileManagerFileFolderSameName.
  ///
  /// In zh, this message translates to:
  /// **'已有同名的文件或文件夹'**
  String get fileManagerFileFolderSameName;

  /// No description provided for @fileManagerRename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get fileManagerRename;

  /// No description provided for @fileManagerDeletePermanently.
  ///
  /// In zh, this message translates to:
  /// **'彻底删除'**
  String get fileManagerDeletePermanently;

  /// No description provided for @fileManagerWillPermanentlyDeletedCant.
  ///
  /// In zh, this message translates to:
  /// **'「{name}」会被彻底删除，不能恢复。'**
  String fileManagerWillPermanentlyDeletedCant(Object name);

  /// No description provided for @fileManagerMovedRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'「{name}」已移到回收站'**
  String fileManagerMovedRecycleBin(Object name);

  /// No description provided for @fileManagerCantPasteFolderInto.
  ///
  /// In zh, this message translates to:
  /// **'不能把文件夹粘贴到它自己里面'**
  String get fileManagerCantPasteFolderInto;

  /// No description provided for @fileManagerPasting.
  ///
  /// In zh, this message translates to:
  /// **'正在粘贴（{done} / {total}）'**
  String fileManagerPasting(Object done, Object total);

  /// No description provided for @commonCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get commonCopy;

  /// No description provided for @fileManagerImportedFiles.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个文件'**
  String fileManagerImportedFiles(num count);

  /// No description provided for @fileManagerLargeFileOnlyFirst.
  ///
  /// In zh, this message translates to:
  /// **'\n\n…（文件较大，只显示前 512 KB）'**
  String get fileManagerLargeFileOnlyFirst;

  /// No description provided for @fileManagerCantRead.
  ///
  /// In zh, this message translates to:
  /// **'无法读取：{error}'**
  String fileManagerCantRead(Object error);

  /// No description provided for @fileManagerKindFileCantPreviewed.
  ///
  /// In zh, this message translates to:
  /// **'不能预览这种文件。可以复制、剪切、重命名或删除'**
  String get fileManagerKindFileCantPreviewed;

  /// No description provided for @fileManagerAppData.
  ///
  /// In zh, this message translates to:
  /// **'应用数据'**
  String get fileManagerAppData;

  /// No description provided for @fileManagerRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'回收站'**
  String get fileManagerRecycleBin;

  /// No description provided for @fileManagerUp.
  ///
  /// In zh, this message translates to:
  /// **'上一级'**
  String get fileManagerUp;

  /// No description provided for @fileManagerImportFilesFromPhone.
  ///
  /// In zh, this message translates to:
  /// **'从手机导入文件'**
  String get fileManagerImportFilesFromPhone;

  /// No description provided for @fileManagerOpenDestinationFolderPaste.
  ///
  /// In zh, this message translates to:
  /// **'已{cut}「{paths}」{length}，打开目标文件夹后粘贴'**
  String fileManagerOpenDestinationFolderPaste(Object cut, Object paths, Object length);

  /// No description provided for @fileManagerCut.
  ///
  /// In zh, this message translates to:
  /// **'剪切'**
  String get fileManagerCut;

  /// No description provided for @fileManagerMore.
  ///
  /// In zh, this message translates to:
  /// **' 等 {count} 项'**
  String fileManagerMore(Object count);

  /// No description provided for @fileManagerPasteHere.
  ///
  /// In zh, this message translates to:
  /// **'粘贴到这里'**
  String get fileManagerPasteHere;

  /// No description provided for @fileManagerFolder.
  ///
  /// In zh, this message translates to:
  /// **'{confirm}这个文件夹'**
  String fileManagerFolder(Object confirm);

  /// No description provided for @fileManagerTapFile.
  ///
  /// In zh, this message translates to:
  /// **'点一个文件来{confirm}'**
  String fileManagerTapFile(Object confirm);

  /// No description provided for @fileManagerTapFile2.
  ///
  /// In zh, this message translates to:
  /// **'点一个 {e} 文件来{confirm}'**
  String fileManagerTapFile2(Object e, Object confirm);

  /// No description provided for @fileManagerFileName.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileManagerFileName;

  /// No description provided for @fileManagerSaveHere.
  ///
  /// In zh, this message translates to:
  /// **'保存到这里'**
  String get fileManagerSaveHere;

  /// No description provided for @fileManagerLocation.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get fileManagerLocation;

  /// No description provided for @fileManagerChooseFolder.
  ///
  /// In zh, this message translates to:
  /// **'选择文件夹'**
  String get fileManagerChooseFolder;

  /// No description provided for @fileManagerChoose.
  ///
  /// In zh, this message translates to:
  /// **'选择{label}'**
  String fileManagerChoose(Object label);

  /// No description provided for @fileManagerSave2.
  ///
  /// In zh, this message translates to:
  /// **'保存{label}'**
  String fileManagerSave2(Object label);

  /// No description provided for @fileManagerAccessingPhoneStorageRequires.
  ///
  /// In zh, this message translates to:
  /// **'需要「所有文件访问权限」才能访问手机存储'**
  String get fileManagerAccessingPhoneStorageRequires;

  /// No description provided for @fileManagerCantOpenFolder.
  ///
  /// In zh, this message translates to:
  /// **'无法打开这个文件夹：{error}'**
  String fileManagerCantOpenFolder(Object error);

  /// No description provided for @fileManagerGrantPermission.
  ///
  /// In zh, this message translates to:
  /// **'去授予权限'**
  String get fileManagerGrantPermission;

  /// No description provided for @fileManagerEmptyFolder.
  ///
  /// In zh, this message translates to:
  /// **'空文件夹'**
  String get fileManagerEmptyFolder;

  /// No description provided for @fileManagerMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get fileManagerMoreActions;

  /// No description provided for @lanTransferReceivedFrom.
  ///
  /// In zh, this message translates to:
  /// **'收到来自 {from} 的「{version}」'**
  String lanTransferReceivedFrom(Object from, Object version);

  /// No description provided for @lanTransferCouldntStartReceiving.
  ///
  /// In zh, this message translates to:
  /// **'无法开始接收：{e}'**
  String lanTransferCouldntStartReceiving(Object e);

  /// No description provided for @lanTransferImportAsNewInstance.
  ///
  /// In zh, this message translates to:
  /// **'导入为新实例'**
  String get lanTransferImportAsNewInstance;

  /// No description provided for @lanTransferImportAsNewInstance2.
  ///
  /// In zh, this message translates to:
  /// **'将「{version}」导入为新实例，并开启实例隔离。\n共 {count} 个文件，{size}。\n\n{parents}游戏本体依赖的库文件和资源文件没有一起传输，第一次启动时会自动补全。'**
  String lanTransferImportAsNewInstance2(Object version, Object count, Object size, Object parents);

  /// No description provided for @lanTransferVanillaVersionDependsImported.
  ///
  /// In zh, this message translates to:
  /// **'依赖的原版 {parents} 也会一起导入（本机已有时保留本机的）。\n'**
  String lanTransferVanillaVersionDependsImported(Object parents);

  /// No description provided for @lanTransferImporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导入「{version}」'**
  String lanTransferImporting(Object version);

  /// No description provided for @lanTransferImportedInstance.
  ///
  /// In zh, this message translates to:
  /// **'已导入实例「{id}」'**
  String lanTransferImportedInstance(Object id);

  /// No description provided for @lanTransferImportingInto.
  ///
  /// In zh, this message translates to:
  /// **'正在导入到「{id}」'**
  String lanTransferImportingInto(Object id);

  /// No description provided for @lanTransferImportedInto.
  ///
  /// In zh, this message translates to:
  /// **'已导入到「{id}」'**
  String lanTransferImportedInto(Object id);

  /// No description provided for @lanTransferImportedIntoPreviousContents.
  ///
  /// In zh, this message translates to:
  /// **'已导入到「{id}」，原来的内容已备份到 {backup}'**
  String lanTransferImportedIntoPreviousContents(Object id, Object backup);

  /// No description provided for @lanTransferImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{e}'**
  String lanTransferImportFailed(Object e);

  /// No description provided for @lanTransferPreparing.
  ///
  /// In zh, this message translates to:
  /// **'正在准备…'**
  String get lanTransferPreparing;

  /// No description provided for @lanTransferNoInstancesYetInstall.
  ///
  /// In zh, this message translates to:
  /// **'还没有实例，请先安装一个实例再导入'**
  String get lanTransferNoInstancesYetInstall;

  /// No description provided for @lanTransferSendersInstance.
  ///
  /// In zh, this message translates to:
  /// **'发送方的实例'**
  String get lanTransferSendersInstance;

  /// No description provided for @lanTransferTheseModsComeFrom.
  ///
  /// In zh, this message translates to:
  /// **'这些模组来自 {from}，但「{id}」是 {v}，导入后模组不会被加载。建议先在这台设备上安装相同的加载器，或者让对方改用「整个实例」发送。'**
  String lanTransferTheseModsComeFrom(Object from, Object id, Object v);

  /// No description provided for @lanTransferSendersInstanceLoadersDiffer.
  ///
  /// In zh, this message translates to:
  /// **'发送方的实例是 {from}，「{id}」是 {v}，加载器不同。'**
  String lanTransferSendersInstanceLoadersDiffer(Object from, Object id, Object v);

  /// No description provided for @lanTransferSendersInstanceGameVersions.
  ///
  /// In zh, this message translates to:
  /// **'发送方的实例是 {from}，「{id}」是 {v}，游戏版本不同，模组和存档可能不兼容。'**
  String lanTransferSendersInstanceGameVersions(Object from, Object id, Object v);

  /// No description provided for @lanTransferImportIntoWhichInstance.
  ///
  /// In zh, this message translates to:
  /// **'导入到哪个实例'**
  String get lanTransferImportIntoWhichInstance;

  /// No description provided for @lanTransferReplacesInstancesPreviousContents.
  ///
  /// In zh, this message translates to:
  /// **'将替换这个实例的：{what}\n原来的内容会先备份到游戏文件夹的 backups 中。'**
  String lanTransferReplacesInstancesPreviousContents(Object what);

  /// No description provided for @lanTransferChooseInstanceSend.
  ///
  /// In zh, this message translates to:
  /// **'请选择要发送的实例'**
  String get lanTransferChooseInstanceSend;

  /// No description provided for @lanTransferPairingCode6Digits.
  ///
  /// In zh, this message translates to:
  /// **'配对码是 6 位数字'**
  String get lanTransferPairingCode6Digits;

  /// No description provided for @lanTransferConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接…'**
  String get lanTransferConnecting;

  /// No description provided for @lanTransferConnectedPacking.
  ///
  /// In zh, this message translates to:
  /// **'已连接到 {name}，正在打包…'**
  String lanTransferConnectedPacking(Object name);

  /// No description provided for @lanTransferPackingFilesAdded.
  ///
  /// In zh, this message translates to:
  /// **'正在打包…已加入 {n} 个文件'**
  String lanTransferPackingFilesAdded(Object n);

  /// No description provided for @lanTransferSending.
  ///
  /// In zh, this message translates to:
  /// **'正在发送 {size}…'**
  String lanTransferSending(Object size);

  /// No description provided for @lanTransferSent.
  ///
  /// In zh, this message translates to:
  /// **'发送完成（{size}）：{reply}'**
  String lanTransferSent(Object size, Object reply);

  /// No description provided for @lanTransferSendingFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送失败：{e}'**
  String lanTransferSendingFailed(Object e);

  /// No description provided for @lanTransferTransferInstancesModsConfigs.
  ///
  /// In zh, this message translates to:
  /// **'在同一个局域网（同一个 Wi-Fi）中的两台设备之间传输实例、模组、配置和存档。'**
  String get lanTransferTransferInstancesModsConfigs;

  /// No description provided for @lanTransferReceive.
  ///
  /// In zh, this message translates to:
  /// **'接收'**
  String get lanTransferReceive;

  /// No description provided for @lanTransferAfterYouStartReceiving.
  ///
  /// In zh, this message translates to:
  /// **'开始接收后，在另一台设备上输入下面显示的地址和配对码。离开这个页面会停止接收。'**
  String get lanTransferAfterYouStartReceiving;

  /// No description provided for @lanTransferStartReceiving.
  ///
  /// In zh, this message translates to:
  /// **'开始接收'**
  String get lanTransferStartReceiving;

  /// No description provided for @lanTransferPairingCode.
  ///
  /// In zh, this message translates to:
  /// **'配对码'**
  String get lanTransferPairingCode;

  /// No description provided for @lanTransferAddressIPPort.
  ///
  /// In zh, this message translates to:
  /// **'地址（IP:端口）'**
  String get lanTransferAddressIPPort;

  /// No description provided for @lanTransferNoLocalNetworkAddress.
  ///
  /// In zh, this message translates to:
  /// **'没有找到局域网地址，请确认已连接 Wi-Fi 或网线'**
  String get lanTransferNoLocalNetworkAddress;

  /// No description provided for @lanTransferIfThereSeveralAddresses.
  ///
  /// In zh, this message translates to:
  /// **'有多个地址时，通常用 192.168 开头的那个'**
  String get lanTransferIfThereSeveralAddresses;

  /// No description provided for @lanTransferIfWindowsFirewallAsks.
  ///
  /// In zh, this message translates to:
  /// **'如果 Windows 防火墙弹出提示，请允许 Pixel World 访问专用网络'**
  String get lanTransferIfWindowsFirewallAsks;

  /// No description provided for @lanTransferReceiving.
  ///
  /// In zh, this message translates to:
  /// **'正在接收 {size} / {size2}'**
  String lanTransferReceiving(Object size, Object size2);

  /// No description provided for @lanTransferStopReceiving.
  ///
  /// In zh, this message translates to:
  /// **'停止接收'**
  String get lanTransferStopReceiving;

  /// No description provided for @lanTransferWholeInstance.
  ///
  /// In zh, this message translates to:
  /// **'整个实例「{version}」'**
  String lanTransferWholeInstance(Object version);

  /// No description provided for @lanTransferText.
  ///
  /// In zh, this message translates to:
  /// **'「{version}」的{i}'**
  String lanTransferText(Object version, Object i);

  /// No description provided for @lanTransferFrom.
  ///
  /// In zh, this message translates to:
  /// **'来自 {from}（{address}）{describe}，{size}'**
  String lanTransferFrom(Object from, Object address, Object describe, Object size);

  /// No description provided for @lanTransferNoInstancesSendYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有可以发送的实例'**
  String get lanTransferNoInstancesSendYet;

  /// No description provided for @lanTransferChooseContent.
  ///
  /// In zh, this message translates to:
  /// **'选择内容'**
  String get lanTransferChooseContent;

  /// No description provided for @lanTransferWholeInstance2.
  ///
  /// In zh, this message translates to:
  /// **'整个实例'**
  String get lanTransferWholeInstance2;

  /// No description provided for @lanTransferPacksInstanceFolderWithout.
  ///
  /// In zh, this message translates to:
  /// **'打包实例文件夹（不含日志和崩溃报告）。对方会导入为新实例并开启实例隔离。\n如果这个实例没有开启实例隔离，还会附带下面选中的内容。'**
  String get lanTransferPacksInstanceFolderWithout;

  /// No description provided for @lanTransferReceiverReplacesSelectedContent.
  ///
  /// In zh, this message translates to:
  /// **'对方导入时会替换选中的内容，替换前自动备份。'**
  String get lanTransferReceiverReplacesSelectedContent;

  /// No description provided for @lanTransferReceiversAddress.
  ///
  /// In zh, this message translates to:
  /// **'对方地址'**
  String get lanTransferReceiversAddress;

  /// No description provided for @fileManagerFailed.
  ///
  /// In zh, this message translates to:
  /// **'{label}失败：{error}'**
  String fileManagerFailed(Object label, Object error);

  /// No description provided for @aiGameClosesRightAfter.
  ///
  /// In zh, this message translates to:
  /// **'游戏启动后闪退，应该从哪里查原因？'**
  String get aiGameClosesRightAfter;

  /// No description provided for @aiWhatSomeCommonPerformance.
  ///
  /// In zh, this message translates to:
  /// **'1.20.1 的 Fabric 有哪些常用的优化模组？'**
  String get aiWhatSomeCommonPerformance;

  /// No description provided for @aiWhatsDifferenceBetweenForge.
  ///
  /// In zh, this message translates to:
  /// **'Forge 和 NeoForge 有什么区别？'**
  String get aiWhatsDifferenceBetweenForge;

  /// No description provided for @aiHowDoIGive.
  ///
  /// In zh, this message translates to:
  /// **'怎么给某个版本分配更多内存？'**
  String get aiHowDoIGive;

  /// No description provided for @aiCrashAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'崩溃分析 · {title}'**
  String aiCrashAnalysis(Object title);

  /// No description provided for @aiSendFollowing.
  ///
  /// In zh, this message translates to:
  /// **'发送以下内容'**
  String get aiSendFollowing;

  /// No description provided for @aiCharactersWillSentModel.
  ///
  /// In zh, this message translates to:
  /// **'将发送 {count} 个字符到 {host}（模型 {model}）。玩家名、令牌、UUID、用户目录与 IP 地址已替换。'**
  String aiCharactersWillSentModel(Object count, Object host, Object model);

  /// No description provided for @aiDontAskAgain.
  ///
  /// In zh, this message translates to:
  /// **'以后不再询问'**
  String get aiDontAskAgain;

  /// No description provided for @aiDeleteConversation.
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get aiDeleteConversation;

  /// No description provided for @aiDeleteCantUndone.
  ///
  /// In zh, this message translates to:
  /// **'删除「{title}」？删除后无法恢复。'**
  String aiDeleteCantUndone(Object title);

  /// No description provided for @aiYesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get aiYesterday;

  /// No description provided for @aiDaysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天前'**
  String aiDaysAgo(num days);

  /// No description provided for @aiMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month} 月 {day} 日'**
  String aiMonthDay(Object month, Object day);

  /// No description provided for @aiNewChat.
  ///
  /// In zh, this message translates to:
  /// **'新对话'**
  String get aiNewChat;

  /// No description provided for @aiHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史对话'**
  String get aiHistory;

  /// No description provided for @aiNoConversationsYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有对话'**
  String get aiNoConversationsYet;

  /// No description provided for @aiAnswering.
  ///
  /// In zh, this message translates to:
  /// **'正在回答…'**
  String get aiAnswering;

  /// No description provided for @aiCompactContextSummarizeEarlier.
  ///
  /// In zh, this message translates to:
  /// **'压缩上下文：把较早的对话压缩成摘要'**
  String get aiCompactContextSummarizeEarlier;

  /// No description provided for @aiConversationShortNoNeed.
  ///
  /// In zh, this message translates to:
  /// **'对话较短，暂时不需要压缩'**
  String get aiConversationShortNoNeed;

  /// No description provided for @aiAISettings.
  ///
  /// In zh, this message translates to:
  /// **'AI 设置'**
  String get aiAISettings;

  /// No description provided for @commonHideSidePanel.
  ///
  /// In zh, this message translates to:
  /// **'收起侧边栏'**
  String get commonHideSidePanel;

  /// No description provided for @aiShowSidePanelEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'展开侧边栏（环境、上下文、文件）'**
  String get aiShowSidePanelEnvironment;

  /// No description provided for @aiCompactingContext.
  ///
  /// In zh, this message translates to:
  /// **'正在压缩上下文…'**
  String get aiCompactingContext;

  /// No description provided for @aiThinking.
  ///
  /// In zh, this message translates to:
  /// **'正在思考…'**
  String get aiThinking;

  /// No description provided for @aiAskQuestion.
  ///
  /// In zh, this message translates to:
  /// **'输入问题'**
  String get aiAskQuestion;

  /// No description provided for @aiActionRunningYouCan.
  ///
  /// In zh, this message translates to:
  /// **'操作执行中，完成后才能停止'**
  String get aiActionRunningYouCan;

  /// No description provided for @aiStop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get aiStop;

  /// No description provided for @aiHowCanIHelp.
  ///
  /// In zh, this message translates to:
  /// **'有什么可以帮你？'**
  String get aiHowCanIHelp;

  /// No description provided for @aiAskMeAboutMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'可以问我 Minecraft 和启动器的问题；游戏崩溃时，在错误分析中选择「AI 分析」会自动带上日志。'**
  String get aiAskMeAboutMinecraft;

  /// No description provided for @aiSetUpAIService.
  ///
  /// In zh, this message translates to:
  /// **'先设置 AI 服务'**
  String get aiSetUpAIService;

  /// No description provided for @aiEnterAPIAddressModel.
  ///
  /// In zh, this message translates to:
  /// **'填写你自己的 AI 服务的接口地址、模型和 API Key'**
  String get aiEnterAPIAddressModel;

  /// No description provided for @aiShowAllCharacters.
  ///
  /// In zh, this message translates to:
  /// **'展开全部（{count} 个字符）'**
  String aiShowAllCharacters(Object count);

  /// No description provided for @aiRegenerate.
  ///
  /// In zh, this message translates to:
  /// **'重新生成'**
  String get aiRegenerate;

  /// No description provided for @aiDeny.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get aiDeny;

  /// No description provided for @aiAllowConversation.
  ///
  /// In zh, this message translates to:
  /// **'本次对话中允许{label}'**
  String aiAllowConversation(Object label);

  /// No description provided for @aiAllow.
  ///
  /// In zh, this message translates to:
  /// **'允许'**
  String get aiAllow;

  /// No description provided for @aiRunning.
  ///
  /// In zh, this message translates to:
  /// **'正在执行'**
  String get aiRunning;

  /// No description provided for @aiPreparing.
  ///
  /// In zh, this message translates to:
  /// **'正在准备'**
  String get aiPreparing;

  /// No description provided for @aiDenied.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝'**
  String get aiDenied;

  /// No description provided for @aiWaitingEarlierActions.
  ///
  /// In zh, this message translates to:
  /// **'等待前面的操作'**
  String get aiWaitingEarlierActions;

  /// No description provided for @aiCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get aiCanceled;

  /// No description provided for @aiInputOutputTokens.
  ///
  /// In zh, this message translates to:
  /// **'输入 {input} · 输出 {output} tokens'**
  String aiInputOutputTokens(Object input, Object output);

  /// No description provided for @aiS.
  ///
  /// In zh, this message translates to:
  /// **'用时 {ms} 秒'**
  String aiS(Object ms);

  /// No description provided for @aiRequests.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次请求'**
  String aiRequests(num count);

  /// No description provided for @aiUsageReportedAIService.
  ///
  /// In zh, this message translates to:
  /// **'用量由 AI 服务返回，多次请求（例如调用工具）时为合计；用时不包括等待你确认的时间'**
  String get aiUsageReportedAIService;

  /// No description provided for @aiContextTokensIncludesSystem.
  ///
  /// In zh, this message translates to:
  /// **'上下文：{estimated}{used} / {window} tokens\n包括系统提示、工具说明和发给模型的对话{summary}'**
  String aiContextTokensIncludesSystem(Object estimated, Object used, Object window, Object summary);

  /// No description provided for @commonAbout.
  ///
  /// In zh, this message translates to:
  /// **'约 '**
  String get commonAbout;

  /// No description provided for @aiEarlierPartsWereSummarized.
  ///
  /// In zh, this message translates to:
  /// **'（较早的部分已压缩为摘要）'**
  String get aiEarlierPartsWereSummarized;

  /// No description provided for @aiConversationAboveWasSummarized.
  ///
  /// In zh, this message translates to:
  /// **'以上的对话已压缩为摘要'**
  String get aiConversationAboveWasSummarized;

  /// No description provided for @aiConversationSummary.
  ///
  /// In zh, this message translates to:
  /// **'对话摘要'**
  String get aiConversationSummary;

  /// No description provided for @aiViewSummary.
  ///
  /// In zh, this message translates to:
  /// **'查看摘要'**
  String get aiViewSummary;

  /// No description provided for @aiSettingsSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get aiSettingsSaved;

  /// No description provided for @aiSettingsFillAPIAddressModel.
  ///
  /// In zh, this message translates to:
  /// **'请填写接口地址、模型{isLocal}'**
  String aiSettingsFillAPIAddressModel(Object isLocal);

  /// No description provided for @aiSettingsAPIKey.
  ///
  /// In zh, this message translates to:
  /// **'和 API Key'**
  String get aiSettingsAPIKey;

  /// No description provided for @aiSettingsConnectedModelReplied.
  ///
  /// In zh, this message translates to:
  /// **'连接成功，模型回复：{characters}'**
  String aiSettingsConnectedModelReplied(Object characters);

  /// No description provided for @aiSettingsClipboardEmpty.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板是空的'**
  String get aiSettingsClipboardEmpty;

  /// No description provided for @aiSettingsPasted.
  ///
  /// In zh, this message translates to:
  /// **'已粘贴'**
  String get aiSettingsPasted;

  /// No description provided for @aiSettingsAPIReturnedNoUsable.
  ///
  /// In zh, this message translates to:
  /// **'接口没有返回可用的模型'**
  String get aiSettingsAPIReturnedNoUsable;

  /// No description provided for @commonTestConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get commonTestConnection;

  /// No description provided for @aiSettingsPopularServices.
  ///
  /// In zh, this message translates to:
  /// **'常用服务'**
  String get aiSettingsPopularServices;

  /// No description provided for @aiSettingsOpenAICompatibleAPI.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI 兼容接口'**
  String get aiSettingsOpenAICompatibleAPI;

  /// No description provided for @aiSettingsAnthropicAPI.
  ///
  /// In zh, this message translates to:
  /// **'Anthropic 接口'**
  String get aiSettingsAnthropicAPI;

  /// No description provided for @aiSettingsAPIAddress.
  ///
  /// In zh, this message translates to:
  /// **'接口地址'**
  String get aiSettingsAPIAddress;

  /// No description provided for @aiSettingsOnlySentAPIAddress.
  ///
  /// In zh, this message translates to:
  /// **'{available}，只会发送给上面填写的接口地址；本机运行的服务可以不填'**
  String aiSettingsOnlySentAPIAddress(Object available);

  /// No description provided for @aiSettingsStoredEncryptedDevice.
  ///
  /// In zh, this message translates to:
  /// **'加密保存在本机'**
  String get aiSettingsStoredEncryptedDevice;

  /// No description provided for @aiSettingsStoredLaunchersPrivateData.
  ///
  /// In zh, this message translates to:
  /// **'保存在启动器的私有数据目录（未加密）'**
  String get aiSettingsStoredLaunchersPrivateData;

  /// No description provided for @aiSettingsHide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get aiSettingsHide;

  /// No description provided for @aiSettingsShow.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get aiSettingsShow;

  /// No description provided for @aiSettingsModel.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get aiSettingsModel;

  /// No description provided for @aiSettingsUseButtonRightFetch.
  ///
  /// In zh, this message translates to:
  /// **'点右侧按钮从接口获取可用的模型'**
  String get aiSettingsUseButtonRightFetch;

  /// No description provided for @aiSettingsFetchModelList.
  ///
  /// In zh, this message translates to:
  /// **'获取模型列表'**
  String get aiSettingsFetchModelList;

  /// No description provided for @aiSettingsContextLengthTokens.
  ///
  /// In zh, this message translates to:
  /// **'上下文长度（tokens）'**
  String get aiSettingsContextLengthTokens;

  /// No description provided for @aiSettingsEmptyAutomatic.
  ///
  /// In zh, this message translates to:
  /// **'留空自动：{defaultContextWindow}'**
  String aiSettingsEmptyAutomatic(Object defaultContextWindow);

  /// No description provided for @aiSettingsSeeYourProvidersDocs.
  ///
  /// In zh, this message translates to:
  /// **'见服务商文档；未知的模型默认按 {defaultContextWindow} 计算'**
  String aiSettingsSeeYourProvidersDocs(Object defaultContextWindow);

  /// No description provided for @aiSettingsCompactContextAutomatically.
  ///
  /// In zh, this message translates to:
  /// **'自动压缩上下文'**
  String get aiSettingsCompactContextAutomatically;

  /// No description provided for @aiSettingsSummarizeEarlierMessagesOnce.
  ///
  /// In zh, this message translates to:
  /// **'超过后把较早的对话压缩成摘要，节省费用'**
  String get aiSettingsSummarizeEarlierMessagesOnce;

  /// No description provided for @aiSettingsAbove32kTokens.
  ///
  /// In zh, this message translates to:
  /// **'超过 32k tokens 时'**
  String get aiSettingsAbove32kTokens;

  /// No description provided for @aiSettingsAbove64kTokens.
  ///
  /// In zh, this message translates to:
  /// **'超过 64k tokens 时'**
  String get aiSettingsAbove64kTokens;

  /// No description provided for @aiSettingsAbove128kTokens.
  ///
  /// In zh, this message translates to:
  /// **'超过 128k tokens 时'**
  String get aiSettingsAbove128kTokens;

  /// No description provided for @aiSettingsAbove256kTokens.
  ///
  /// In zh, this message translates to:
  /// **'超过 256k tokens 时'**
  String get aiSettingsAbove256kTokens;

  /// No description provided for @aiSettingsNever.
  ///
  /// In zh, this message translates to:
  /// **'不自动压缩'**
  String get aiSettingsNever;

  /// No description provided for @aiSettingsConfirmBeforeSending.
  ///
  /// In zh, this message translates to:
  /// **'发送前确认内容'**
  String get aiSettingsConfirmBeforeSending;

  /// No description provided for @aiSettingsShowLogEnvironmentInfo.
  ///
  /// In zh, this message translates to:
  /// **'每次分析前显示将要发送的日志与环境信息'**
  String get aiSettingsShowLogEnvironmentInfo;

  /// No description provided for @aiSettingsAllowAIUseTools.
  ///
  /// In zh, this message translates to:
  /// **'允许 AI 使用工具'**
  String get aiSettingsAllowAIUseTools;

  /// No description provided for @aiSettingsViewInstancesModsLogs.
  ///
  /// In zh, this message translates to:
  /// **'查看实例、模组与日志，安装或禁用模组，联网搜索，以及下面的 MCP 服务；会修改内容的操作都需要你确认'**
  String get aiSettingsViewInstancesModsLogs;

  /// No description provided for @aiSettingsConfirmReadOnlyActions.
  ///
  /// In zh, this message translates to:
  /// **'查看类操作也需要确认'**
  String get aiSettingsConfirmReadOnlyActions;

  /// No description provided for @aiSettingsWhenOffAICan.
  ///
  /// In zh, this message translates to:
  /// **'关闭时，AI 查看实例、模组、文件与日志不需要确认'**
  String get aiSettingsWhenOffAICan;

  /// No description provided for @aiSettingsAITroubleshootingSettings.
  ///
  /// In zh, this message translates to:
  /// **'AI 排障设置'**
  String get aiSettingsAITroubleshootingSettings;

  /// No description provided for @aiSettingsChooseModel.
  ///
  /// In zh, this message translates to:
  /// **'选择模型（{count} 个）'**
  String aiSettingsChooseModel(Object count);

  /// No description provided for @aiSettingsNoMatchingModels.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的模型'**
  String get aiSettingsNoMatchingModels;

  /// No description provided for @aiMcpSettingsRemoveMCPService.
  ///
  /// In zh, this message translates to:
  /// **'移除 MCP 服务'**
  String get aiMcpSettingsRemoveMCPService;

  /// No description provided for @aiMcpSettingsRemoveItsSavedAccess.
  ///
  /// In zh, this message translates to:
  /// **'移除「{name}」？保存的访问令牌也会一起删除。'**
  String aiMcpSettingsRemoveItsSavedAccess(Object name);

  /// No description provided for @aiMcpSettingsReadOnlyActionsOnly.
  ///
  /// In zh, this message translates to:
  /// **'只有查看类操作'**
  String get aiMcpSettingsReadOnlyActionsOnly;

  /// No description provided for @aiMcpSettingsPermissions.
  ///
  /// In zh, this message translates to:
  /// **'权限'**
  String get aiMcpSettingsPermissions;

  /// No description provided for @aiMcpSettingsToolServicesMCP.
  ///
  /// In zh, this message translates to:
  /// **'工具服务（MCP）'**
  String get aiMcpSettingsToolServicesMCP;

  /// No description provided for @aiMcpSettingsEverythingAIDoesGoes.
  ///
  /// In zh, this message translates to:
  /// **'AI 的所有操作都通过这些服务完成。设为「只读」的服务会直接拒绝会修改内容的操作，不再询问。外部服务只由启动器主动连接，启动器不对外开放任何端口。'**
  String get aiMcpSettingsEverythingAIDoesGoes;

  /// No description provided for @commonBuilt.
  ///
  /// In zh, this message translates to:
  /// **'内置'**
  String get commonBuilt;

  /// No description provided for @aiMcpSettingsBuiltTurnedOffAbove.
  ///
  /// In zh, this message translates to:
  /// **'内置 · 已在上方关闭'**
  String get aiMcpSettingsBuiltTurnedOffAbove;

  /// No description provided for @aiMcpSettingsTrustReadOnlyClaims.
  ///
  /// In zh, this message translates to:
  /// **'信任只读声明'**
  String get aiMcpSettingsTrustReadOnlyClaims;

  /// No description provided for @aiMcpSettingsConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败：{split}'**
  String aiMcpSettingsConnectionFailed(Object split);

  /// No description provided for @commonTools.
  ///
  /// In zh, this message translates to:
  /// **'{toolCount} 个工具'**
  String commonTools(num toolCount);

  /// No description provided for @aiMcpSettingsEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get aiMcpSettingsEdit;

  /// No description provided for @aiMcpSettingsAddMCPService.
  ///
  /// In zh, this message translates to:
  /// **'添加 MCP 服务'**
  String get aiMcpSettingsAddMCPService;

  /// No description provided for @aiMcpSettingsRefreshStatus.
  ///
  /// In zh, this message translates to:
  /// **'刷新状态'**
  String get aiMcpSettingsRefreshStatus;

  /// No description provided for @aiMcpSettingsEnterName.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称'**
  String get aiMcpSettingsEnterName;

  /// No description provided for @aiMcpSettingsLocalJarServicesCant.
  ///
  /// In zh, this message translates to:
  /// **'安卓上暂时还不能运行本机 jar 服务'**
  String get aiMcpSettingsLocalJarServicesCant;

  /// No description provided for @aiMcpSettingsChooseJarFile.
  ///
  /// In zh, this message translates to:
  /// **'请选择 jar 文件'**
  String get aiMcpSettingsChooseJarFile;

  /// No description provided for @aiMcpSettingsConnectedToolsAvailable.
  ///
  /// In zh, this message translates to:
  /// **'连接成功{server}，提供 {count} 个工具{names}'**
  String aiMcpSettingsConnectedToolsAvailable(Object server, Object count, Object names);

  /// No description provided for @aiMcpSettingsJarFile.
  ///
  /// In zh, this message translates to:
  /// **'jar 文件'**
  String get aiMcpSettingsJarFile;

  /// No description provided for @aiMcpSettingsEditMCPService.
  ///
  /// In zh, this message translates to:
  /// **'编辑 MCP 服务'**
  String get aiMcpSettingsEditMCPService;

  /// No description provided for @aiMcpSettingsRemoteHTTP.
  ///
  /// In zh, this message translates to:
  /// **'远程（HTTP）'**
  String get aiMcpSettingsRemoteHTTP;

  /// No description provided for @aiMcpSettingsLocalJar.
  ///
  /// In zh, this message translates to:
  /// **'本机 jar'**
  String get aiMcpSettingsLocalJar;

  /// No description provided for @aiMcpSettingsServiceURL.
  ///
  /// In zh, this message translates to:
  /// **'服务地址'**
  String get aiMcpSettingsServiceURL;

  /// No description provided for @aiMcpSettingsRemoteServicesNeedHttps.
  ///
  /// In zh, this message translates to:
  /// **'远程服务需要 https；本机服务（例如 Termux 里运行的）可以填 http://127.0.0.1:端口/mcp'**
  String get aiMcpSettingsRemoteServicesNeedHttps;

  /// No description provided for @aiMcpSettingsAccessTokenOptional.
  ///
  /// In zh, this message translates to:
  /// **'访问令牌（可选）'**
  String get aiMcpSettingsAccessTokenOptional;

  /// No description provided for @aiMcpSettingsStoredEncryptedDeviceOnly.
  ///
  /// In zh, this message translates to:
  /// **'加密保存在本机，只会发给这个服务（Authorization: Bearer）'**
  String get aiMcpSettingsStoredEncryptedDeviceOnly;

  /// No description provided for @aiMcpSettingsLaunchArgumentsOptional.
  ///
  /// In zh, this message translates to:
  /// **'启动参数（可选）'**
  String get aiMcpSettingsLaunchArgumentsOptional;

  /// No description provided for @aiMcpSettingsSeparatedSpacesAppendedAfter.
  ///
  /// In zh, this message translates to:
  /// **'用空格分隔，附加在 java -jar 文件 之后；Java 由启动器自动选择（Java 21）'**
  String get aiMcpSettingsSeparatedSpacesAppendedAfter;

  /// No description provided for @aiMcpSettingsTrustServicesReadOnly.
  ///
  /// In zh, this message translates to:
  /// **'信任这个服务的只读声明'**
  String get aiMcpSettingsTrustServicesReadOnly;

  /// No description provided for @aiMcpSettingsWhenToolsServiceDeclares.
  ///
  /// In zh, this message translates to:
  /// **'打开后，服务声明只读的工具直接执行，不用确认；关闭时，每个工具在本次对话中第一次使用都要确认。声明会删除内容的工具始终每次确认。只对你信任的服务打开'**
  String get aiMcpSettingsWhenToolsServiceDeclares;

  /// No description provided for @aiSidePanelFileGone.
  ///
  /// In zh, this message translates to:
  /// **'文件已经不在了：{path}'**
  String aiSidePanelFileGone(Object path);

  /// No description provided for @aiSidePanelNoModelSetUp.
  ///
  /// In zh, this message translates to:
  /// **'还没有设置模型'**
  String get aiSidePanelNoModelSetUp;

  /// No description provided for @aiSidePanelNoInstanceSelected.
  ///
  /// In zh, this message translates to:
  /// **'没有选择实例'**
  String get aiSidePanelNoInstanceSelected;

  /// No description provided for @commonAIWorkspace.
  ///
  /// In zh, this message translates to:
  /// **'AI 工作区'**
  String get commonAIWorkspace;

  /// No description provided for @aiSidePanelText.
  ///
  /// In zh, this message translates to:
  /// **'开'**
  String get aiSidePanelText;

  /// No description provided for @aiSidePanelOff.
  ///
  /// In zh, this message translates to:
  /// **'关'**
  String get aiSidePanelOff;

  /// No description provided for @commonWebSearch.
  ///
  /// In zh, this message translates to:
  /// **'联网搜索'**
  String get commonWebSearch;

  /// No description provided for @aiSidePanelNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get aiSidePanelNotConnected;

  /// No description provided for @aiSidePanelContext.
  ///
  /// In zh, this message translates to:
  /// **'上下文'**
  String get aiSidePanelContext;

  /// No description provided for @aiSidePanelUsed.
  ///
  /// In zh, this message translates to:
  /// **'{window}% 已用'**
  String aiSidePanelUsed(Object window);

  /// No description provided for @aiSidePanelCompact.
  ///
  /// In zh, this message translates to:
  /// **'压缩'**
  String get aiSidePanelCompact;

  /// No description provided for @aiSidePanelFilesConversation.
  ///
  /// In zh, this message translates to:
  /// **'本次对话的文件'**
  String get aiSidePanelFilesConversation;

  /// No description provided for @aiSidePanelFilesAIWritesChanges.
  ///
  /// In zh, this message translates to:
  /// **'AI 在这次对话里写入或修改的文件会出现在这里'**
  String get aiSidePanelFilesAIWritesChanges;

  /// No description provided for @aiSidePanelWorkspace.
  ///
  /// In zh, this message translates to:
  /// **'工作区'**
  String get aiSidePanelWorkspace;

  /// No description provided for @aiSidePanelStillEmptyYouCan.
  ///
  /// In zh, this message translates to:
  /// **'还是空的。可以让 AI 把整理结果写到这里'**
  String get aiSidePanelStillEmptyYouCan;

  /// No description provided for @aiWorkspaceSettingsLetAIAccessFolder.
  ///
  /// In zh, this message translates to:
  /// **'让 AI 访问这个文件夹'**
  String get aiWorkspaceSettingsLetAIAccessFolder;

  /// No description provided for @aiWorkspaceSettingsFolderHasAlreadyBeen.
  ///
  /// In zh, this message translates to:
  /// **'这个文件夹已经添加过了'**
  String get aiWorkspaceSettingsFolderHasAlreadyBeen;

  /// No description provided for @aiWorkspaceSettingsAllowAccessWholeDrive.
  ///
  /// In zh, this message translates to:
  /// **'允许访问整个磁盘？'**
  String get aiWorkspaceSettingsAllowAccessWholeDrive;

  /// No description provided for @aiWorkspaceSettingsRootDriveSoAI.
  ///
  /// In zh, this message translates to:
  /// **'{real} 是磁盘的根目录，AI 将能看到其中所有文件。建议只添加需要的文件夹。'**
  String aiWorkspaceSettingsRootDriveSoAI(Object real);

  /// No description provided for @aiWorkspaceSettingsAddAnyway.
  ///
  /// In zh, this message translates to:
  /// **'仍然添加'**
  String get aiWorkspaceSettingsAddAnyway;

  /// No description provided for @aiWorkspaceSettingsAIHasItsOwn.
  ///
  /// In zh, this message translates to:
  /// **'AI 有一个自己的文件夹可以随意读写，并能查看当前实例的游戏文件（只读）'**
  String get aiWorkspaceSettingsAIHasItsOwn;

  /// No description provided for @aiWorkspaceSettingsAfterGrantingAllFiles.
  ///
  /// In zh, this message translates to:
  /// **'授予「所有文件访问」后，AI 也能读写系统下载目录。'**
  String get aiWorkspaceSettingsAfterGrantingAllFiles;

  /// No description provided for @aiWorkspaceSettingsYouCanAddOther.
  ///
  /// In zh, this message translates to:
  /// **'还可以添加其他文件夹；默认只读，打开「允许修改」后 AI 才能改动其中的文件。'**
  String get aiWorkspaceSettingsYouCanAddOther;

  /// No description provided for @aiWorkspaceSettingsAllowChanges.
  ///
  /// In zh, this message translates to:
  /// **'允许修改'**
  String get aiWorkspaceSettingsAllowChanges;

  /// No description provided for @aiWorkspaceSettingsRemoveFolderIsntDeleted.
  ///
  /// In zh, this message translates to:
  /// **'移除（不会删除文件夹）'**
  String get aiWorkspaceSettingsRemoveFolderIsntDeleted;

  /// No description provided for @aiWorkspaceSettingsOpenWorkspace.
  ///
  /// In zh, this message translates to:
  /// **'打开工作区'**
  String get aiWorkspaceSettingsOpenWorkspace;

  /// No description provided for @aiWorkspaceSettingsAICanSearchWeb.
  ///
  /// In zh, this message translates to:
  /// **'AI 可以搜索网页、打开网址、查 Minecraft Wiki；请求会跟随系统代理'**
  String get aiWorkspaceSettingsAICanSearchWeb;

  /// No description provided for @aiWorkspaceSettingsSearchEngine.
  ///
  /// In zh, this message translates to:
  /// **'搜索引擎'**
  String get aiWorkspaceSettingsSearchEngine;

  /// No description provided for @aiWorkspaceSettingsSearXNGURL.
  ///
  /// In zh, this message translates to:
  /// **'SearXNG 地址'**
  String get aiWorkspaceSettingsSearXNGURL;

  /// No description provided for @aiWorkspaceSettingsInstanceNeedsJSONOutput.
  ///
  /// In zh, this message translates to:
  /// **'实例需要开启 JSON 格式输出'**
  String get aiWorkspaceSettingsInstanceNeedsJSONOutput;

  /// No description provided for @aiWorkspaceSettingsExaAPIKeyOptional.
  ///
  /// In zh, this message translates to:
  /// **'Exa 的 API Key（可以不填）'**
  String get aiWorkspaceSettingsExaAPIKeyOptional;

  /// No description provided for @aiWorkspaceSettingsSearchServiceAPIKey.
  ///
  /// In zh, this message translates to:
  /// **'搜索服务的 API Key'**
  String get aiWorkspaceSettingsSearchServiceAPIKey;

  /// No description provided for @aiWorkspaceSettingsWorksWithoutOneRate.
  ///
  /// In zh, this message translates to:
  /// **'不填也能用，有频率限制；填了之后额度更高。只会发给 Exa'**
  String get aiWorkspaceSettingsWorksWithoutOneRate;

  /// No description provided for @aiWorkspaceSettingsStoredSeparatelyFromModels.
  ///
  /// In zh, this message translates to:
  /// **'和模型的 Key 分开保存，只会发给所选的搜索服务'**
  String get aiWorkspaceSettingsStoredSeparatelyFromModels;

  /// No description provided for @installerAppInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装 {name}'**
  String installerAppInstall(Object name);

  /// No description provided for @installerAppUninstall.
  ///
  /// In zh, this message translates to:
  /// **'卸载 {name}'**
  String installerAppUninstall(Object name);

  /// No description provided for @installerAppUninstalling.
  ///
  /// In zh, this message translates to:
  /// **'正在卸载…'**
  String get installerAppUninstalling;

  /// No description provided for @installerAppUpdate.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get installerAppUpdate;

  /// No description provided for @installerAppVersionInstalledCurrentUser.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version} · 只为当前用户安装，不需要管理员权限'**
  String installerAppVersionInstalledCurrentUser(Object version);

  /// No description provided for @installerAppInstallLocation.
  ///
  /// In zh, this message translates to:
  /// **'安装位置'**
  String get installerAppInstallLocation;

  /// No description provided for @installerAppAddStartMenu.
  ///
  /// In zh, this message translates to:
  /// **'添加到开始菜单'**
  String get installerAppAddStartMenu;

  /// No description provided for @installerAppThirdPartyMinecraftLauncher.
  ///
  /// In zh, this message translates to:
  /// **'{name} 是第三方 Minecraft 启动器，与 Mojang 或 Microsoft 无关。'**
  String installerAppThirdPartyMinecraftLauncher(Object name);

  /// No description provided for @installerAppUpdating.
  ///
  /// In zh, this message translates to:
  /// **'正在更新'**
  String get installerAppUpdating;

  /// No description provided for @installerAppInstalling.
  ///
  /// In zh, this message translates to:
  /// **'正在安装'**
  String get installerAppInstalling;

  /// No description provided for @installerAppInstallationComplete.
  ///
  /// In zh, this message translates to:
  /// **'安装完成'**
  String get installerAppInstallationComplete;

  /// No description provided for @installerAppInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已安装到 {dir}'**
  String installerAppInstalled(Object dir);

  /// No description provided for @installerAppLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动 {name}'**
  String installerAppLaunch(Object name);

  /// No description provided for @installerAppInstallationFailed.
  ///
  /// In zh, this message translates to:
  /// **'安装失败'**
  String get installerAppInstallationFailed;

  /// No description provided for @installerAppOnlyFilesWrittenDuring.
  ///
  /// In zh, this message translates to:
  /// **'只删除安装时写入的文件，放在程序文件夹里的其他文件不会动'**
  String get installerAppOnlyFilesWrittenDuring;

  /// No description provided for @installerAppAlsoDeleteLauncherData.
  ///
  /// In zh, this message translates to:
  /// **'同时删除启动器数据'**
  String get installerAppAlsoDeleteLauncherData;

  /// No description provided for @installerAppSettingsAccountsDefaultGame.
  ///
  /// In zh, this message translates to:
  /// **'设置、账户与默认游戏文件夹（{userDataDirs}）。默认游戏文件夹中的存档也会被删除'**
  String installerAppSettingsAccountsDefaultGame(Object userDataDirs);

  /// No description provided for @installerAppUninstall2.
  ///
  /// In zh, this message translates to:
  /// **'卸载'**
  String get installerAppUninstall2;

  /// No description provided for @installerAppUninstalling2.
  ///
  /// In zh, this message translates to:
  /// **'正在卸载'**
  String get installerAppUninstalling2;

  /// No description provided for @installerAppUninstallFailed.
  ///
  /// In zh, this message translates to:
  /// **'卸载失败'**
  String get installerAppUninstallFailed;

  /// No description provided for @installerCoreRunningCloseBeforeInstalling.
  ///
  /// In zh, this message translates to:
  /// **'{name} 正在运行，请先关闭它再安装'**
  String installerCoreRunningCloseBeforeInstalling(Object name);

  /// No description provided for @installerCoreCouldntCreateShortcut.
  ///
  /// In zh, this message translates to:
  /// **'无法创建快捷方式：{path}'**
  String installerCoreCouldntCreateShortcut(Object path);

  /// No description provided for @installerCoreCouldntWriteUninstallInformation.
  ///
  /// In zh, this message translates to:
  /// **'写入卸载信息失败'**
  String get installerCoreCouldntWriteUninstallInformation;

  /// No description provided for @installerCoreCantInstallIntoInstallers.
  ///
  /// In zh, this message translates to:
  /// **'不能安装到安装程序所在的文件夹'**
  String get installerCoreCantInstallIntoInstallers;

  /// No description provided for @installerCoreCopying.
  ///
  /// In zh, this message translates to:
  /// **'正在复制 {rel}'**
  String installerCoreCopying(Object rel);

  /// No description provided for @installerCoreFinishingInstallation.
  ///
  /// In zh, this message translates to:
  /// **'正在完成安装…'**
  String get installerCoreFinishingInstallation;

  /// No description provided for @installerCoreInstallManifestWasntFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到安装清单，无法确定要删除哪些文件'**
  String get installerCoreInstallManifestWasntFound;

  /// No description provided for @appStateRemovedFilesFoldersCreated.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {removed} 个由本次任务创建的文件或目录'**
  String appStateRemovedFilesFoldersCreated(Object removed);

  /// No description provided for @appStateInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装 {fileName}'**
  String appStateInstall(Object fileName);

  /// No description provided for @commonResolveDependencies.
  ///
  /// In zh, this message translates to:
  /// **'解析前置'**
  String get commonResolveDependencies;

  /// No description provided for @commonDownloadFiles.
  ///
  /// In zh, this message translates to:
  /// **'下载文件'**
  String get commonDownloadFiles;

  /// No description provided for @appStateInstalledFilesSkippedExisting.
  ///
  /// In zh, this message translates to:
  /// **'已安装 {count} 个文件，跳过 {count2} 个已存在的文件{missing}'**
  String appStateInstalledFilesSkippedExisting(Object count, Object count2, Object missing);

  /// No description provided for @appStateNoCompatibleDependencyFound.
  ///
  /// In zh, this message translates to:
  /// **'，找不到兼容的前置：{missing}'**
  String appStateNoCompatibleDependencyFound(Object missing);

  /// No description provided for @appStateInstallModpack.
  ///
  /// In zh, this message translates to:
  /// **'安装整合包 {name}'**
  String appStateInstallModpack(Object name);

  /// No description provided for @commonDownloadModpack.
  ///
  /// In zh, this message translates to:
  /// **'下载整合包'**
  String get commonDownloadModpack;

  /// No description provided for @commonInstallGameLoader.
  ///
  /// In zh, this message translates to:
  /// **'安装游戏与加载器'**
  String get commonInstallGameLoader;

  /// No description provided for @commonDownloadModpackFiles.
  ///
  /// In zh, this message translates to:
  /// **'下载整合包文件'**
  String get commonDownloadModpackFiles;

  /// No description provided for @commonExtractModpackConfigs.
  ///
  /// In zh, this message translates to:
  /// **'解压整合包配置'**
  String get commonExtractModpackConfigs;

  /// No description provided for @appStateInstalledAs.
  ///
  /// In zh, this message translates to:
  /// **'已安装为 {id}'**
  String appStateInstalledAs(Object id);

  /// No description provided for @appStateInstallModpack2.
  ///
  /// In zh, this message translates to:
  /// **'安装整合包 {path}'**
  String appStateInstallModpack2(Object path);

  /// No description provided for @commonReadModpack.
  ///
  /// In zh, this message translates to:
  /// **'读取整合包'**
  String get commonReadModpack;

  /// No description provided for @appStateAddOptiFine.
  ///
  /// In zh, this message translates to:
  /// **'为 {id} 添加 OptiFine'**
  String appStateAddOptiFine(Object id);

  /// No description provided for @appStateInvalidInstanceName.
  ///
  /// In zh, this message translates to:
  /// **'实例名称不合法'**
  String get appStateInvalidInstanceName;

  /// No description provided for @appStateInstall2.
  ///
  /// In zh, this message translates to:
  /// **'安装 {loaderVersion}'**
  String appStateInstall2(Object loaderVersion);

  /// No description provided for @appStateGameAlreadyRunning.
  ///
  /// In zh, this message translates to:
  /// **'游戏已在运行'**
  String get appStateGameAlreadyRunning;

  /// No description provided for @appStateChooseInstanceFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个实例'**
  String get appStateChooseInstanceFirst;

  /// No description provided for @appStateAddAccountFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先添加一个账户'**
  String get appStateAddAccountFirst;

  /// No description provided for @appStateLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动 {id}'**
  String appStateLaunch(Object id);

  /// No description provided for @appStateCheckFiles.
  ///
  /// In zh, this message translates to:
  /// **'检查文件'**
  String get appStateCheckFiles;

  /// No description provided for @appStatePrepareLaunch.
  ///
  /// In zh, this message translates to:
  /// **'准备启动'**
  String get appStatePrepareLaunch;

  /// No description provided for @appStateStartGame.
  ///
  /// In zh, this message translates to:
  /// **'启动游戏'**
  String get appStateStartGame;

  /// No description provided for @appStateVerifyAccount.
  ///
  /// In zh, this message translates to:
  /// **'验证账户'**
  String get appStateVerifyAccount;

  /// No description provided for @appStateAnalyzeInstance.
  ///
  /// In zh, this message translates to:
  /// **'分析实例'**
  String get appStateAnalyzeInstance;

  /// No description provided for @appStateExtractNativeLibraries.
  ///
  /// In zh, this message translates to:
  /// **'解压本地库'**
  String get appStateExtractNativeLibraries;

  /// No description provided for @appStateJavaAndroidJava.
  ///
  /// In zh, this message translates to:
  /// **'Java: {path}（安卓版 Java {major}）'**
  String appStateJavaAndroidJava(Object path, Object major);

  /// No description provided for @appStateMemoryGB.
  ///
  /// In zh, this message translates to:
  /// **'内存: {max} GB'**
  String appStateMemoryGB(Object max);

  /// No description provided for @appStateWorkingDirectory.
  ///
  /// In zh, this message translates to:
  /// **'工作目录: {gameDir}'**
  String appStateWorkingDirectory(Object gameDir);

  /// No description provided for @appStateRenderScale.
  ///
  /// In zh, this message translates to:
  /// **'渲染比例: {renderScale}%'**
  String appStateRenderScale(Object renderScale);

  /// No description provided for @appStateGPU.
  ///
  /// In zh, this message translates to:
  /// **'显卡: {gpu}'**
  String appStateGPU(Object gpu);

  /// No description provided for @appStateRendererLWJGL.
  ///
  /// In zh, this message translates to:
  /// **'渲染器: {renderer}（{reason}）{sfpew}{turnip}，LWJGL {lwjgl}{lwjgl2}{sdl}'**
  String appStateRendererLWJGL(
    Object renderer,
    Object reason,
    Object sfpew,
    Object turnip,
    Object lwjgl,
    Object lwjgl2,
    Object sdl,
  );

  /// No description provided for @appStateSFPEWFixedFunctionEmulation.
  ///
  /// In zh, this message translates to:
  /// **' + SFPEW（固定管线模拟）'**
  String get appStateSFPEWFixedFunctionEmulation;

  /// No description provided for @appStateTurnipDriver.
  ///
  /// In zh, this message translates to:
  /// **' + Turnip 驱动'**
  String get appStateTurnipDriver;

  /// No description provided for @appStateLWJGL2CompatibilityLayer.
  ///
  /// In zh, this message translates to:
  /// **'（LWJGL 2 兼容层）'**
  String get appStateLWJGL2CompatibilityLayer;

  /// No description provided for @appStateWarningDeviceDoesntReport.
  ///
  /// In zh, this message translates to:
  /// **'警告：这台设备没有声明 Vulkan 1.1，所选渲染器可能无法启动'**
  String get appStateWarningDeviceDoesntReport;

  /// No description provided for @appStateTouchControllerModDetectedUsing.
  ///
  /// In zh, this message translates to:
  /// **'检测到 TouchController 模组：使用它的触控方式'**
  String get appStateTouchControllerModDetectedUsing;

  /// No description provided for @appStateWarningKryptonWrapperCrashes.
  ///
  /// In zh, this message translates to:
  /// **'警告：Krypton Wrapper 在 26.3 快照及之后的版本上会崩溃，出现问题请换用 MobileGlues'**
  String get appStateWarningKryptonWrapperCrashes;

  /// No description provided for @appStateGameExitedCode.
  ///
  /// In zh, this message translates to:
  /// **'游戏已退出，代码 {code}'**
  String appStateGameExitedCode(Object code);

  /// No description provided for @appStateLaunch2.
  ///
  /// In zh, this message translates to:
  /// **'启动 - {id}'**
  String appStateLaunch2(Object id);

  /// No description provided for @appStateJavaJavaBit.
  ///
  /// In zh, this message translates to:
  /// **'Java: {path}（Java {major}，{is64} 位）'**
  String appStateJavaJavaBit(Object path, Object major, Object is64);

  /// No description provided for @appStateMemoryGB2.
  ///
  /// In zh, this message translates to:
  /// **'内存: {max} GB{initial}'**
  String appStateMemoryGB2(Object max, Object initial);

  /// No description provided for @appStateInitialGB.
  ///
  /// In zh, this message translates to:
  /// **'，初始 {initial} GB'**
  String appStateInitialGB(Object initial);

  /// No description provided for @appStateLaunchFailed.
  ///
  /// In zh, this message translates to:
  /// **'启动失败：{e}'**
  String appStateLaunchFailed(Object e);

  /// No description provided for @appStateGameCrashedSeeCrash.
  ///
  /// In zh, this message translates to:
  /// **'游戏崩溃了，可以在错误分析中查看原因'**
  String get appStateGameCrashedSeeCrash;

  /// No description provided for @appStateCouldntCollectCrashInformation.
  ///
  /// In zh, this message translates to:
  /// **'收集崩溃信息失败：{e}'**
  String appStateCouldntCollectCrashInformation(Object e);

  /// No description provided for @appInfoPixelWorldLauncher.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 启动器'**
  String get appInfoPixelWorldLauncher;

  /// No description provided for @crashEnvironment.
  ///
  /// In zh, this message translates to:
  /// **'## 环境'**
  String get crashEnvironment;

  /// No description provided for @crashInitialFindingsFromLaunchers.
  ///
  /// In zh, this message translates to:
  /// **'## 启动器本地规则的初步判断'**
  String get crashInitialFindingsFromLaunchers;

  /// No description provided for @crashEnabledModFiles.
  ///
  /// In zh, this message translates to:
  /// **'## 已启用的模组文件（{count} 个）'**
  String crashEnabledModFiles(Object count);

  /// No description provided for @crashCrashReport.
  ///
  /// In zh, this message translates to:
  /// **'崩溃报告 {path}'**
  String crashCrashReport(Object path);

  /// No description provided for @crashJVMErrorLog.
  ///
  /// In zh, this message translates to:
  /// **'JVM 错误日志 {path}'**
  String crashJVMErrorLog(Object path);

  /// No description provided for @crashGameOutput.
  ///
  /// In zh, this message translates to:
  /// **'游戏输出'**
  String get crashGameOutput;

  /// No description provided for @crashInstance.
  ///
  /// In zh, this message translates to:
  /// **'实例：{versionId}（{description}）'**
  String crashInstance(Object versionId, Object description);

  /// No description provided for @crashLoader.
  ///
  /// In zh, this message translates to:
  /// **'加载器：{loaderLibs}'**
  String crashLoader(Object loaderLibs);

  /// No description provided for @crashAllocatedMemoryGB.
  ///
  /// In zh, this message translates to:
  /// **'分配内存：{memoryGb} GB'**
  String crashAllocatedMemoryGB(Object memoryGb);

  /// No description provided for @crashSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统：{operatingSystem} {operatingSystemVersion}'**
  String crashSystem(Object operatingSystem, Object operatingSystemVersion);

  /// No description provided for @crashExitCode.
  ///
  /// In zh, this message translates to:
  /// **'退出代码：{exitCode}'**
  String crashExitCode(Object exitCode);

  /// No description provided for @crashMoreCharactersOmitted.
  ///
  /// In zh, this message translates to:
  /// **'{max}\n...（以下省略 {max2} 个字符）'**
  String crashMoreCharactersOmitted(Object max, Object max2);

  /// No description provided for @crashPreviousLineRepeatedTimes.
  ///
  /// In zh, this message translates to:
  /// **'（上一行重复 {repeat} 次）'**
  String crashPreviousLineRepeatedTimes(Object repeat);

  /// No description provided for @crashLinesOmitted.
  ///
  /// In zh, this message translates to:
  /// **'...（省略 {skipped} 行）'**
  String crashLinesOmitted(Object skipped);

  /// No description provided for @crashCharactersOmitted.
  ///
  /// In zh, this message translates to:
  /// **'{head}\n...（中间省略 {budget} 个字符）\n{end}'**
  String crashCharactersOmitted(Object head, Object budget, Object end);

  /// No description provided for @crashToken.
  ///
  /// In zh, this message translates to:
  /// **'<令牌>'**
  String get crashToken;

  /// No description provided for @crashToken2.
  ///
  /// In zh, this message translates to:
  /// **'{m} <令牌>'**
  String crashToken2(Object m);

  /// No description provided for @crashPlayer.
  ///
  /// In zh, this message translates to:
  /// **'<玩家>'**
  String get crashPlayer;

  /// No description provided for @crashUser.
  ///
  /// In zh, this message translates to:
  /// **'{m}<用户>'**
  String crashUser(Object m);

  /// No description provided for @crashJavaVersionTooOld.
  ///
  /// In zh, this message translates to:
  /// **'Java 版本过低'**
  String get crashJavaVersionTooOld;

  /// No description provided for @crashJavaNewerRequiredBut.
  ///
  /// In zh, this message translates to:
  /// **'需要 Java {version} 或更高，当前 Java 只支持到 Java {version2}。请在实例设置中选择更新的 Java。'**
  String crashJavaNewerRequiredBut(Object version, Object version2);

  /// No description provided for @crashSomeModsGameFiles.
  ///
  /// In zh, this message translates to:
  /// **'有模组或游戏文件需要更新的 Java，请在实例设置中选择更新的 Java。'**
  String get crashSomeModsGameFiles;

  /// No description provided for @crashJava8Required.
  ///
  /// In zh, this message translates to:
  /// **'需要 Java 8'**
  String get crashJava8Required;

  /// No description provided for @crashOldForge112.
  ///
  /// In zh, this message translates to:
  /// **'旧版 Forge（1.12.2 及更早）只能在 Java 8 上运行，请在实例设置中选择 Java 8。'**
  String get crashOldForge112;

  /// No description provided for @crashOutMemory.
  ///
  /// In zh, this message translates to:
  /// **'内存不足'**
  String get crashOutMemory;

  /// No description provided for @crashGameDoesntHaveEnough.
  ///
  /// In zh, this message translates to:
  /// **'游戏可用的内存不够。可以在实例设置中加大内存，或减少模组、光影与高清材质。'**
  String get crashGameDoesntHaveEnough;

  /// No description provided for @crashInvalidMemorySetting.
  ///
  /// In zh, this message translates to:
  /// **'内存设置无效'**
  String get crashInvalidMemorySetting;

  /// No description provided for @crashAllocatedMemoryExceedsLimit.
  ///
  /// In zh, this message translates to:
  /// **'分配的内存超出了系统或 32 位 Java 的上限，请调小内存，或换用 64 位 Java。'**
  String get crashAllocatedMemoryExceedsLimit;

  /// No description provided for @crashMissingWrongDependency.
  ///
  /// In zh, this message translates to:
  /// **'缺少前置模组或版本不对'**
  String get crashMissingWrongDependency;

  /// No description provided for @crashModsRequiredDependencyIsnt.
  ///
  /// In zh, this message translates to:
  /// **'有模组需要的前置模组没有安装，或版本不符合要求。按下面的日志行安装或更新对应模组。'**
  String get crashModsRequiredDependencyIsnt;

  /// No description provided for @crashDuplicateMods.
  ///
  /// In zh, this message translates to:
  /// **'模组重复'**
  String get crashDuplicateMods;

  /// No description provided for @crashSameModInstalledMore.
  ///
  /// In zh, this message translates to:
  /// **'同一个模组装了多份（可能是不同版本），请删除多余的文件。'**
  String get crashSameModInstalledMore;

  /// No description provided for @crashMixinInjectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'Mixin 注入失败'**
  String get crashMixinInjectionFailed;

  /// No description provided for @crashUsuallyModsIncompatibleEach.
  ///
  /// In zh, this message translates to:
  /// **'通常是模组之间不兼容，或模组与当前 Minecraft、加载器版本不匹配。日志中会写出出错的模组。'**
  String get crashUsuallyModsIncompatibleEach;

  /// No description provided for @crashModsDontMatchLoader.
  ///
  /// In zh, this message translates to:
  /// **'模组与加载器不匹配'**
  String get crashModsDontMatchLoader;

  /// No description provided for @crashModsAnotherLoaderInstalled.
  ///
  /// In zh, this message translates to:
  /// **'装了其他加载器的模组，例如在 Fabric 上装了 Forge 模组。'**
  String get crashModsAnotherLoaderInstalled;

  /// No description provided for @crashOptiFineIncompatible.
  ///
  /// In zh, this message translates to:
  /// **'OptiFine 不兼容'**
  String get crashOptiFineIncompatible;

  /// No description provided for @crashOptiFineIsntCompatibleCurrent.
  ///
  /// In zh, this message translates to:
  /// **'OptiFine 与当前的 Forge 或其他模组不兼容。可以换用 OptiFine 要求的 Forge 版本，或移除 OptiFine。'**
  String get crashOptiFineIsntCompatibleCurrent;

  /// No description provided for @crashGraphicsDriverProblem.
  ///
  /// In zh, this message translates to:
  /// **'显卡驱动问题'**
  String get crashGraphicsDriverProblem;

  /// No description provided for @crashGraphicsDriverDoesntSupport.
  ///
  /// In zh, this message translates to:
  /// **'显卡驱动不支持或出错。请到显卡厂商官网更新驱动；笔记本可以让游戏使用独立显卡。'**
  String get crashGraphicsDriverDoesntSupport;

  /// No description provided for @crashMainClassNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到主类'**
  String get crashMainClassNotFound;

  /// No description provided for @crashGameFilesMayIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'游戏文件可能不完整，或路径中含有特殊字符。可以尝试补全文件或换一个不含特殊字符的文件夹。'**
  String get crashGameFilesMayIncomplete;

  /// No description provided for @crashManuallyTriggeredCrash.
  ///
  /// In zh, this message translates to:
  /// **'手动触发的崩溃'**
  String get crashManuallyTriggeredCrash;

  /// No description provided for @crashDebugCrashTriggeredHolding.
  ///
  /// In zh, this message translates to:
  /// **'这是按住 F3 + C 触发的调试崩溃，不是错误。'**
  String get crashDebugCrashTriggeredHolding;

  /// No description provided for @crashModSuspectedCrashReport.
  ///
  /// In zh, this message translates to:
  /// **'崩溃报告怀疑的模组'**
  String get crashModSuspectedCrashReport;

  /// No description provided for @crashCrashReportNamesMod.
  ///
  /// In zh, this message translates to:
  /// **'崩溃报告指出了可能导致崩溃的模组，可以先禁用它试试。'**
  String get crashCrashReportNamesMod;

  /// No description provided for @taskCancelingTask.
  ///
  /// In zh, this message translates to:
  /// **'正在中断任务…'**
  String get taskCancelingTask;

  /// No description provided for @taskFilesDownload.
  ///
  /// In zh, this message translates to:
  /// **'共 {t} 个文件需要下载'**
  String taskFilesDownload(num t);

  /// No description provided for @taskFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败：{error}'**
  String taskFailed(Object error);

  /// No description provided for @javaGetJavaRuntime.
  ///
  /// In zh, this message translates to:
  /// **'获取 Java 运行时 ({component})'**
  String javaGetJavaRuntime(Object component);

  /// No description provided for @javaDownloadJavaRuntime.
  ///
  /// In zh, this message translates to:
  /// **'下载 Java 运行时 ({component}，{useMirror})'**
  String javaDownloadJavaRuntime(Object component, Object useMirror);

  /// No description provided for @javaDownloadedFiles.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {done} / {total} 个文件'**
  String javaDownloadedFiles(Object done, Object total);

  /// No description provided for @javaAverageS.
  ///
  /// In zh, this message translates to:
  /// **' · 平均 {speed}/s'**
  String javaAverageS(Object speed);

  /// No description provided for @javaGetJava8Azul.
  ///
  /// In zh, this message translates to:
  /// **'获取 Java 8（Azul Zulu，Apple 芯片）'**
  String get javaGetJava8Azul;

  /// No description provided for @javaDownloadJava8Azul.
  ///
  /// In zh, this message translates to:
  /// **'下载 Java 8（Azul Zulu）'**
  String get javaDownloadJava8Azul;

  /// No description provided for @javaJava8DownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'Java 8 下载校验失败（SHA-256 不匹配）'**
  String get javaJava8DownloadFailed;

  /// No description provided for @javaExtractJava8.
  ///
  /// In zh, this message translates to:
  /// **'解压 Java 8'**
  String get javaExtractJava8;

  /// No description provided for @javaCouldntExtractJava8.
  ///
  /// In zh, this message translates to:
  /// **'解压 Java 8 失败：{stderr}'**
  String javaCouldntExtractJava8(Object stderr);

  /// No description provided for @javaJava8ArchiveHas.
  ///
  /// In zh, this message translates to:
  /// **'Java 8 压缩包的结构无法识别'**
  String get javaJava8ArchiveHas;

  /// No description provided for @javaJavaPathDoesntExist.
  ///
  /// In zh, this message translates to:
  /// **'Java 路径不存在：{path}'**
  String javaJavaPathDoesntExist(Object path);

  /// No description provided for @javaCantRunJava.
  ///
  /// In zh, this message translates to:
  /// **'无法运行 Java：{path}'**
  String javaCantRunJava(Object path);

  /// No description provided for @javaInstanceStartsThroughLaunchWrapper.
  ///
  /// In zh, this message translates to:
  /// **'这个实例通过 LaunchWrapper 启动（Forge 1.12.2 及更早、OptiFine、LiteLoader 等），只能在 Java 8 上运行，使用 Java {javaMajor} 很可能在加载时崩溃。'**
  String javaInstanceStartsThroughLaunchWrapper(Object javaMajor);

  /// No description provided for @javaUseEnsureAndroidJavaAndroid.
  ///
  /// In zh, this message translates to:
  /// **'安卓上请使用 ensureAndroidJava'**
  String get javaUseEnsureAndroidJavaAndroid;

  /// No description provided for @javaJavaSetDoesntExist.
  ///
  /// In zh, this message translates to:
  /// **'{where}指定的 Java 不存在：{path}。请重新选择 Java，或改为自动选择'**
  String javaJavaSetDoesntExist(Object where, Object path);

  /// No description provided for @javaJavaSetButInstance.
  ///
  /// In zh, this message translates to:
  /// **'{where}指定的是 Java {major}，这个实例至少需要 Java {major2}。请重新选择 Java，或改为自动选择'**
  String javaJavaSetButInstance(Object where, Object major, Object major2);

  /// No description provided for @javaInstanceSettings.
  ///
  /// In zh, this message translates to:
  /// **'实例设置中'**
  String get javaInstanceSettings;

  /// No description provided for @javaGlobalSettings.
  ///
  /// In zh, this message translates to:
  /// **'全局设置中'**
  String get javaGlobalSettings;

  /// No description provided for @javaDetectJava.
  ///
  /// In zh, this message translates to:
  /// **'检测 Java'**
  String get javaDetectJava;

  /// No description provided for @javaAutomaticallyDownloadedJavaOlder.
  ///
  /// In zh, this message translates to:
  /// **'自动下载的 Java {major} 低于需要的 Java {major2}'**
  String javaAutomaticallyDownloadedJavaOlder(Object major, Object major2);

  /// No description provided for @javaJavaWasntFoundSet.
  ///
  /// In zh, this message translates to:
  /// **'找不到 Java {major}，请在设置中手动指定 Java 路径{downloadError}'**
  String javaJavaWasntFoundSet(Object major, Object downloadError);

  /// No description provided for @javaAutomaticDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'（自动下载失败：{downloadError}）'**
  String javaAutomaticDownloadFailed(Object downloadError);

  /// No description provided for @installFilesGeneratedInstallerMissing.
  ///
  /// In zh, this message translates to:
  /// **'缺少由安装器生成的文件：{missingLocal}，请重新安装这个实例'**
  String installFilesGeneratedInstallerMissing(Object missingLocal);

  /// No description provided for @installDownloadGameLibraries.
  ///
  /// In zh, this message translates to:
  /// **'下载游戏本体与依赖库'**
  String get installDownloadGameLibraries;

  /// No description provided for @installDownloadAssetIndex.
  ///
  /// In zh, this message translates to:
  /// **'下载资源索引'**
  String get installDownloadAssetIndex;

  /// No description provided for @installDownloadAssets.
  ///
  /// In zh, this message translates to:
  /// **'下载资源文件'**
  String get installDownloadAssets;

  /// No description provided for @installOrganizeLegacyAssets.
  ///
  /// In zh, this message translates to:
  /// **'整理旧版资源'**
  String get installOrganizeLegacyAssets;

  /// No description provided for @installInstanceNameCantEmpty.
  ///
  /// In zh, this message translates to:
  /// **'实例名称不能为空，且不能包含 \\ / : * ? \" < > |'**
  String get installInstanceNameCantEmpty;

  /// No description provided for @installInstanceNamedAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'已存在名为 {n} 的实例'**
  String installInstanceNamedAlreadyExists(Object n);

  /// No description provided for @installDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载 {component}'**
  String installDownload(Object component);

  /// No description provided for @installInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装 {component}'**
  String installInstall(Object component);

  /// No description provided for @installGetVersionInfo.
  ///
  /// In zh, this message translates to:
  /// **'获取版本信息'**
  String get installGetVersionInfo;

  /// No description provided for @installVersionNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到版本 {id}'**
  String installVersionNotFound(Object id);

  /// No description provided for @installDownloadMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'下载 Minecraft {gameVersion} 本体'**
  String installDownloadMinecraft(Object gameVersion);

  /// No description provided for @downloadDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败：{url}'**
  String downloadDownloadFailed(Object url);

  /// No description provided for @downloadDownloadTooSlowRetrying.
  ///
  /// In zh, this message translates to:
  /// **'下载速度过慢，更换节点重试：{target}'**
  String downloadDownloadTooSlowRetrying(Object target);

  /// No description provided for @downloadVerificationFailedSHA1.
  ///
  /// In zh, this message translates to:
  /// **'校验失败（SHA-1 不匹配）：{path}'**
  String downloadVerificationFailedSHA1(Object path);

  /// No description provided for @downloadVerificationFailedSizeShould.
  ///
  /// In zh, this message translates to:
  /// **'校验失败（大小应为 {size}，实际 {count}）：{path}'**
  String downloadVerificationFailedSizeShould(Object size, Object count, Object path);

  /// No description provided for @downloadChunkSizeMismatch.
  ///
  /// In zh, this message translates to:
  /// **'分块大小不符：{path}'**
  String downloadChunkSizeMismatch(Object path);

  /// No description provided for @downloadSizeMismatchAfterMerging.
  ///
  /// In zh, this message translates to:
  /// **'分块合并后大小不符：{path}'**
  String downloadSizeMismatchAfterMerging(Object path);

  /// No description provided for @downloadDownloadFailedHTTP.
  ///
  /// In zh, this message translates to:
  /// **'下载失败（HTTP {statusCode}）'**
  String downloadDownloadFailedHTTP(Object statusCode);

  /// No description provided for @downloadConnected.
  ///
  /// In zh, this message translates to:
  /// **'已连接 {host}{total}'**
  String downloadConnected(Object host, Object total);

  /// No description provided for @downloadFileSizeMB.
  ///
  /// In zh, this message translates to:
  /// **'，文件大小 {total} MB'**
  String downloadFileSizeMB(Object total);

  /// No description provided for @downloadServerDidntReportFile.
  ///
  /// In zh, this message translates to:
  /// **'，服务器没有提供文件大小'**
  String get downloadServerDidntReportFile;

  /// No description provided for @downloadDownloadTooSlowKB.
  ///
  /// In zh, this message translates to:
  /// **'下载速度过慢（{secs} KB/s）'**
  String downloadDownloadTooSlowKB(Object secs);

  /// No description provided for @downloadNoDataReceived.
  ///
  /// In zh, this message translates to:
  /// **'没有收到数据'**
  String get downloadNoDataReceived;

  /// No description provided for @downloadIncompleteDownloadBytes.
  ///
  /// In zh, this message translates to:
  /// **'下载不完整（{received} / {total} 字节）'**
  String downloadIncompleteDownloadBytes(Object received, Object total);

  /// No description provided for @downloadIncompleteDownloadExpectedBytes.
  ///
  /// In zh, this message translates to:
  /// **'下载不完整（应为 {size} 字节，实际 {received}）'**
  String downloadIncompleteDownloadExpectedBytes(Object size, Object received);

  /// No description provided for @downloadFilesFailedDownloadE.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件下载失败，例如：{errors}'**
  String downloadFilesFailedDownloadE(Object count, Object errors);

  /// No description provided for @modpackModpackDoesntSpecifyMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'整合包没有标明 Minecraft 版本'**
  String get modpackModpackDoesntSpecifyMinecraft;

  /// No description provided for @modpackNotValidModrinthModpack.
  ///
  /// In zh, this message translates to:
  /// **'不是有效的 Modrinth 整合包：缺少 modrinth.index.json'**
  String get modpackNotValidModrinthModpack;

  /// No description provided for @modpackInstallMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'安装 Minecraft {minecraft}'**
  String modpackInstallMinecraft(Object minecraft);

  /// No description provided for @modpackModpackContainsUnsafePath.
  ///
  /// In zh, this message translates to:
  /// **'整合包包含不安全的路径：{message}'**
  String modpackModpackContainsUnsafePath(Object message);

  /// No description provided for @modpackSkippedUnneededFiles.
  ///
  /// In zh, this message translates to:
  /// **'跳过 {skipped} 个不需要的文件'**
  String modpackSkippedUnneededFiles(Object skipped);

  /// No description provided for @modpackExtractedConfigOverrideFiles.
  ///
  /// In zh, this message translates to:
  /// **'已解压 {extracted} 个配置与覆盖文件'**
  String modpackExtractedConfigOverrideFiles(Object extracted);

  /// No description provided for @forgeDownloadInstaller.
  ///
  /// In zh, this message translates to:
  /// **'下载 {label} 安装器'**
  String forgeDownloadInstaller(Object label);

  /// No description provided for @forgeInstallerCorruptedInstallProfile.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器已损坏：找不到 install_profile.json'**
  String forgeInstallerCorruptedInstallProfile(Object label);

  /// No description provided for @forgeOfflineInstallFailedInstalling.
  ///
  /// In zh, this message translates to:
  /// **'离线安装失败，改为联网安装：{e}'**
  String forgeOfflineInstallFailedInstalling(Object e);

  /// No description provided for @forgeInstallerNeedsDownloadMojang.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器需要联网下载 Mojang 映射，无法完全离线安装'**
  String forgeInstallerNeedsDownloadMojang(Object label);

  /// No description provided for @forgeDownloadFilesNeededInstaller.
  ///
  /// In zh, this message translates to:
  /// **'下载 {label} 安装器需要的文件'**
  String forgeDownloadFilesNeededInstaller(Object label);

  /// No description provided for @forgeSomeFilesDidntDownload.
  ///
  /// In zh, this message translates to:
  /// **'部分文件没有下载成功，交给安装器重试：{e}'**
  String forgeSomeFilesDidntDownload(Object e);

  /// No description provided for @forgeRunInstallerProcessingFiles.
  ///
  /// In zh, this message translates to:
  /// **'运行 {label} 安装器（处理文件，可能需要几分钟）'**
  String forgeRunInstallerProcessingFiles(Object label);

  /// No description provided for @forgeRunInstallerDownloadingDependencies.
  ///
  /// In zh, this message translates to:
  /// **'运行 {label} 安装器（下载依赖并处理文件，可能需要几分钟）'**
  String forgeRunInstallerDownloadingDependencies(Object label);

  /// No description provided for @forgeInstallerFailedExitCode.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器运行失败（退出代码 {code}）\n{tail}'**
  String forgeInstallerFailedExitCode(Object label, Object code, Object tail);

  /// No description provided for @forgeInstallerFailed.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器运行失败\n{tail}'**
  String forgeInstallerFailed(Object label, Object tail);

  /// No description provided for @forgeSeveralNewVersionsAppeared.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器之后出现了多个新版本（{candidates}），无法确定是哪一个'**
  String forgeSeveralNewVersionsAppeared(Object label, Object candidates);

  /// No description provided for @forgeInstallerDidntCreateNew.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器没有生成新的版本'**
  String forgeInstallerDidntCreateNew(Object label);

  /// No description provided for @forgeInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装 {label}'**
  String forgeInstall(Object label);

  /// No description provided for @forgeInstallerCorruptedMissing.
  ///
  /// In zh, this message translates to:
  /// **'{label} 安装器已损坏：找不到 {install}'**
  String forgeInstallerCorruptedMissing(Object label, Object install);

  /// No description provided for @modrinthShaderPacks.
  ///
  /// In zh, this message translates to:
  /// **'光影包'**
  String get modrinthShaderPacks;

  /// No description provided for @modrinthTooManyRequestsPlease.
  ///
  /// In zh, this message translates to:
  /// **'请求过于频繁，请稍后再试'**
  String get modrinthTooManyRequestsPlease;

  /// No description provided for @modrinthModrinthRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'Modrinth 请求失败（{statusCode}）'**
  String modrinthModrinthRequestFailed(Object statusCode);

  /// No description provided for @modrinthResourceWasntFoundModrinth.
  ///
  /// In zh, this message translates to:
  /// **'Modrinth 上找不到该资源'**
  String get modrinthResourceWasntFoundModrinth;

  /// No description provided for @modrinthModpackInstallationWillCome.
  ///
  /// In zh, this message translates to:
  /// **'整合包安装将在后续版本提供'**
  String get modrinthModpackInstallationWillCome;

  /// No description provided for @modrinthChooseWorldInstallData.
  ///
  /// In zh, this message translates to:
  /// **'请选择要安装数据包的世界'**
  String get modrinthChooseWorldInstallData;

  /// No description provided for @modrinthResolveDependencies.
  ///
  /// In zh, this message translates to:
  /// **'解析前置（{length}）'**
  String modrinthResolveDependencies(Object length);

  /// No description provided for @extraLoadersDownloadOptiFine.
  ///
  /// In zh, this message translates to:
  /// **'下载 OptiFine'**
  String get extraLoadersDownloadOptiFine;

  /// No description provided for @extraLoadersPutIntoModsFolder.
  ///
  /// In zh, this message translates to:
  /// **'放入 mods 文件夹'**
  String get extraLoadersPutIntoModsFolder;

  /// No description provided for @extraLoadersPutInto.
  ///
  /// In zh, this message translates to:
  /// **'已放入 {path}'**
  String extraLoadersPutInto(Object path);

  /// No description provided for @extraLoadersDownloadOptiFineInstaller.
  ///
  /// In zh, this message translates to:
  /// **'下载 OptiFine 安装包'**
  String get extraLoadersDownloadOptiFineInstaller;

  /// No description provided for @extraLoadersGenerateOptiFineLibrary.
  ///
  /// In zh, this message translates to:
  /// **'生成 OptiFine 库'**
  String get extraLoadersGenerateOptiFineLibrary;

  /// No description provided for @extraLoadersOptiFinePatcherFailedExit.
  ///
  /// In zh, this message translates to:
  /// **'OptiFine Patcher 运行失败（退出代码 {code}）\n{tail}'**
  String extraLoadersOptiFinePatcherFailedExit(Object code, Object tail);

  /// No description provided for @extraLoadersOptiFineInstallerCorruptedLaunchwrapper.
  ///
  /// In zh, this message translates to:
  /// **'OptiFine 安装包已损坏：找不到 launchwrapper-of-{lwVersion}.jar'**
  String extraLoadersOptiFineInstallerCorruptedLaunchwrapper(Object lwVersion);

  /// No description provided for @extraLoadersGetLabyModVersionList.
  ///
  /// In zh, this message translates to:
  /// **'获取 LabyMod 版本清单'**
  String get extraLoadersGetLabyModVersionList;

  /// No description provided for @loadersLiteLoaderNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到 LiteLoader {version}'**
  String loadersLiteLoaderNotFound(Object version);

  /// No description provided for @loadersLiteLoaderOnlySupports1.
  ///
  /// In zh, this message translates to:
  /// **'LiteLoader 只支持 1.12.2 及更早的版本'**
  String get loadersLiteLoaderOnlySupports1;

  /// No description provided for @loadersInstallLiteLoader.
  ///
  /// In zh, this message translates to:
  /// **'安装 LiteLoader'**
  String get loadersInstallLiteLoader;

  /// No description provided for @loadersGetConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'获取 {label} 配置'**
  String loadersGetConfiguration(Object label);

  /// No description provided for @loaderNamesUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get loaderNamesUnknown;

  /// No description provided for @optifineCompatWillInstalledAsSeparate.
  ///
  /// In zh, this message translates to:
  /// **'将安装为独立的 OptiFine 版本'**
  String get optifineCompatWillInstalledAsSeparate;

  /// No description provided for @optifineCompatGoesIntoModsAs.
  ///
  /// In zh, this message translates to:
  /// **'作为模组放进 mods；适配 Forge {requiredForge}，较新的 Forge 可能不兼容'**
  String optifineCompatGoesIntoModsAs(Object requiredForge);

  /// No description provided for @optifineCompatGoesIntoModsAs2.
  ///
  /// In zh, this message translates to:
  /// **'作为模组放进 mods'**
  String get optifineCompatGoesIntoModsAs2;

  /// No description provided for @optifineCompatGoesIntoModsAs3.
  ///
  /// In zh, this message translates to:
  /// **'作为模组放进 mods；OptiFine 官方不支持 NeoForge，可能无法加载'**
  String get optifineCompatGoesIntoModsAs3;

  /// No description provided for @optifineCompatGoesIntoModsAs4.
  ///
  /// In zh, this message translates to:
  /// **'作为模组放进 mods；还需要另外安装 OptiFabric 模组才能加载'**
  String get optifineCompatGoesIntoModsAs4;

  /// No description provided for @launchRunningPreLaunchCommand.
  ///
  /// In zh, this message translates to:
  /// **'执行启动前命令：{command}'**
  String launchRunningPreLaunchCommand(Object command);

  /// No description provided for @versionVersionIsntInstalled.
  ///
  /// In zh, this message translates to:
  /// **'版本 {id} 未安装'**
  String versionVersionIsntInstalled(Object id);

  /// No description provided for @lanTransferModConfigs.
  ///
  /// In zh, this message translates to:
  /// **'模组配置'**
  String get lanTransferModConfigs;

  /// No description provided for @lanTransferGameOptions.
  ///
  /// In zh, this message translates to:
  /// **'游戏设置'**
  String get lanTransferGameOptions;

  /// No description provided for @lanTransferUnsupportedTransferFormatUpdate.
  ///
  /// In zh, this message translates to:
  /// **'不支持的传输格式，请把两边的启动器更新到同一版本'**
  String get lanTransferUnsupportedTransferFormatUpdate;

  /// No description provided for @lanTransferInvalidTransferManifest.
  ///
  /// In zh, this message translates to:
  /// **'传输清单无效'**
  String get lanTransferInvalidTransferManifest;

  /// No description provided for @lanTransferInvalidInstanceName.
  ///
  /// In zh, this message translates to:
  /// **'实例名无效：{version}'**
  String lanTransferInvalidInstanceName(Object version);

  /// No description provided for @lanTransferInvalidDependencyVersionName.
  ///
  /// In zh, this message translates to:
  /// **'依赖版本名无效：{id}'**
  String lanTransferInvalidDependencyVersionName(Object id);

  /// No description provided for @lanTransferTransferManifestContainsUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'传输清单中有不支持的内容'**
  String get lanTransferTransferManifestContainsUnsupported;

  /// No description provided for @lanTransferUnknownDevice.
  ///
  /// In zh, this message translates to:
  /// **'未知设备'**
  String get lanTransferUnknownDevice;

  /// No description provided for @lanTransferChooseAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'请至少选择一项内容'**
  String get lanTransferChooseAtLeastOne;

  /// No description provided for @lanTransferNoneSelectedItemsExist.
  ///
  /// In zh, this message translates to:
  /// **'选中的内容都不存在'**
  String get lanTransferNoneSelectedItemsExist;

  /// No description provided for @lanTransferReceivedFileIsntPixel.
  ///
  /// In zh, this message translates to:
  /// **'收到的文件不是 Pixel World 的传输包'**
  String get lanTransferReceivedFileIsntPixel;

  /// No description provided for @lanTransferTransferManifestCantRead.
  ///
  /// In zh, this message translates to:
  /// **'传输清单无法读取'**
  String get lanTransferTransferManifestCantRead;

  /// No description provided for @lanTransferTransferPackageMissingFiles.
  ///
  /// In zh, this message translates to:
  /// **'传输包缺少文件，可能没有传输完整'**
  String get lanTransferTransferPackageMissingFiles;

  /// No description provided for @lanTransferTransferPackageContainsSymbolic.
  ///
  /// In zh, this message translates to:
  /// **'传输包中有符号链接：{name}'**
  String lanTransferTransferPackageContainsSymbolic(Object name);

  /// No description provided for @lanTransferTransferPackageContainsFile.
  ///
  /// In zh, this message translates to:
  /// **'传输包中有清单以外的文件：{name}'**
  String lanTransferTransferPackageContainsFile(Object name);

  /// No description provided for @lanTransferFileSizeDoesntMatch.
  ///
  /// In zh, this message translates to:
  /// **'文件大小与清单不符：{name}'**
  String lanTransferFileSizeDoesntMatch(Object name);

  /// No description provided for @lanTransferInvalidTransferPackage.
  ///
  /// In zh, this message translates to:
  /// **'传输包无效：{name}'**
  String lanTransferInvalidTransferPackage(Object name);

  /// No description provided for @commonTemporaryFolderAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'临时文件夹已存在：{staging}'**
  String commonTemporaryFolderAlreadyExists(Object staging);

  /// No description provided for @lanTransferTransferPackageContainsDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'传输包中有重复的文件：{rel}'**
  String lanTransferTransferPackageContainsDuplicate(Object rel);

  /// No description provided for @lanTransferFileSizeDoesntMatch2.
  ///
  /// In zh, this message translates to:
  /// **'文件大小与清单不符：{rel}'**
  String lanTransferFileSizeDoesntMatch2(Object rel);

  /// No description provided for @lanTransferTransferPackageIsntWhole.
  ///
  /// In zh, this message translates to:
  /// **'这个传输包不是整个实例'**
  String get lanTransferTransferPackageIsntWhole;

  /// No description provided for @lanTransferInstanceNamedAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'已经有名为「{id}」的实例，请先在实例设置里重命名或删除它'**
  String lanTransferInstanceNamedAlreadyExists(Object id);

  /// No description provided for @lanTransferTransferPackageHasNo.
  ///
  /// In zh, this message translates to:
  /// **'传输包中没有版本文件 {id}.json'**
  String lanTransferTransferPackageHasNo(Object id);

  /// No description provided for @lanTransferTransferPackageWholeInstance.
  ///
  /// In zh, this message translates to:
  /// **'这个传输包是整个实例，请导入为新实例'**
  String get lanTransferTransferPackageWholeInstance;

  /// No description provided for @lanTransferWrongPairingCodeAttempts.
  ///
  /// In zh, this message translates to:
  /// **'配对码不正确，还可以再试 {left} 次'**
  String lanTransferWrongPairingCodeAttempts(num left);

  /// No description provided for @lanTransferTooManyWrongPairing.
  ///
  /// In zh, this message translates to:
  /// **'配对码错误次数太多，对方已停止接收'**
  String get lanTransferTooManyWrongPairing;

  /// No description provided for @lanTransferTooManyWrongPairing2.
  ///
  /// In zh, this message translates to:
  /// **'配对码错误次数太多，已停止接收。需要时重新开始接收，会生成新的配对码。'**
  String get lanTransferTooManyWrongPairing2;

  /// No description provided for @lanTransferOtherDeviceReceivingAnother.
  ///
  /// In zh, this message translates to:
  /// **'对方正在接收另一个传输，请稍后再试'**
  String get lanTransferOtherDeviceReceivingAnother;

  /// No description provided for @lanTransferMissingFileSize.
  ///
  /// In zh, this message translates to:
  /// **'缺少文件大小'**
  String get lanTransferMissingFileSize;

  /// No description provided for @lanTransferFileTooLargeAt.
  ///
  /// In zh, this message translates to:
  /// **'文件太大，单次最多 32 GB'**
  String get lanTransferFileTooLargeAt;

  /// No description provided for @lanTransferReceivedMoreDataThan.
  ///
  /// In zh, this message translates to:
  /// **'收到的数据比声明的多'**
  String get lanTransferReceivedMoreDataThan;

  /// No description provided for @lanTransferTransferInterruptedOnlyBytes.
  ///
  /// In zh, this message translates to:
  /// **'传输中断，只收到 {got} / {total} 字节'**
  String lanTransferTransferInterruptedOnlyBytes(Object got, Object total);

  /// No description provided for @lanTransferReceivedOtherDeviceWaiting.
  ///
  /// In zh, this message translates to:
  /// **'对方已收到，等待对方确认导入'**
  String get lanTransferReceivedOtherDeviceWaiting;

  /// No description provided for @lanTransferReceivingFailed.
  ///
  /// In zh, this message translates to:
  /// **'接收失败：{e}'**
  String lanTransferReceivingFailed(Object e);

  /// No description provided for @lanTransferAddressShouldIPPort.
  ///
  /// In zh, this message translates to:
  /// **'地址格式应为「IP:端口」，例如 192.168.1.5:43567'**
  String get lanTransferAddressShouldIPPort;

  /// No description provided for @lanTransferConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败（{statusCode}）'**
  String lanTransferConnectionFailed(Object statusCode);

  /// No description provided for @lanTransferOtherDevice.
  ///
  /// In zh, this message translates to:
  /// **'对方设备'**
  String get lanTransferOtherDevice;

  /// No description provided for @lanTransferCantReachMakeSure.
  ///
  /// In zh, this message translates to:
  /// **'连不上 {host}:{port}。请确认两台设备在同一个局域网，对方正在接收，且防火墙允许 Pixel World 联网'**
  String lanTransferCantReachMakeSure(Object host, Object port);

  /// No description provided for @lanTransferSendingFailed2.
  ///
  /// In zh, this message translates to:
  /// **'发送失败（{statusCode}）'**
  String lanTransferSendingFailed2(Object statusCode);

  /// No description provided for @lanTransferTransferInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'传输中断：{message}'**
  String lanTransferTransferInterrupted(Object message);

  /// No description provided for @toolboxPerfectScoreEverythingGoes.
  ///
  /// In zh, this message translates to:
  /// **'满分！今天做什么都会顺利'**
  String get toolboxPerfectScoreEverythingGoes;

  /// No description provided for @toolboxGreatLuckEveryChest.
  ///
  /// In zh, this message translates to:
  /// **'大吉，开箱必出钻石'**
  String get toolboxGreatLuckEveryChest;

  /// No description provided for @toolboxPrettyLuckyGoodDay.
  ///
  /// In zh, this message translates to:
  /// **'运气不错，适合去下界走走'**
  String get toolboxPrettyLuckyGoodDay;

  /// No description provided for @toolboxSteadyCalmNoLava.
  ///
  /// In zh, this message translates to:
  /// **'平平稳稳，挖矿不会挖到岩浆'**
  String get toolboxSteadyCalmNoLava;

  /// No description provided for @toolboxSoSoRememberBring.
  ///
  /// In zh, this message translates to:
  /// **'一般般，记得多带几个床'**
  String get toolboxSoSoRememberBring;

  /// No description provided for @toolboxWatchOutCreepersSave.
  ///
  /// In zh, this message translates to:
  /// **'小心苦力怕，出门前先存档'**
  String get toolboxWatchOutCreepersSave;

  /// No description provided for @toolboxGoodDayStayHome.
  ///
  /// In zh, this message translates to:
  /// **'今天适合在家种田'**
  String get toolboxGoodDayStayHome;

  /// No description provided for @toolboxZeroBetterStayOut.
  ///
  /// In zh, this message translates to:
  /// **'零分……今天还是别下矿了'**
  String get toolboxZeroBetterStayOut;

  /// No description provided for @toolboxOnlyWindowsSupportedNow.
  ///
  /// In zh, this message translates to:
  /// **'目前只支持 Windows'**
  String get toolboxOnlyWindowsSupportedNow;

  /// No description provided for @toolboxCouldntCreateShortcut.
  ///
  /// In zh, this message translates to:
  /// **'创建快捷方式失败'**
  String get toolboxCouldntCreateShortcut;

  /// No description provided for @toolboxEnterURLStartingHttp.
  ///
  /// In zh, this message translates to:
  /// **'请输入 http 或 https 开头的网址'**
  String get toolboxEnterURLStartingHttp;

  /// No description provided for @toolboxConnect.
  ///
  /// In zh, this message translates to:
  /// **'连接 {host}'**
  String toolboxConnect(Object host);

  /// No description provided for @toolboxDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载 {path}'**
  String toolboxDownload(Object path);

  /// No description provided for @toolboxSavedMB.
  ///
  /// In zh, this message translates to:
  /// **'已保存到 {path}（{done} MB）'**
  String toolboxSavedMB(Object path, Object done);

  /// No description provided for @toolboxPlayerNamesCanOnly.
  ///
  /// In zh, this message translates to:
  /// **'玩家名只能包含字母、数字和下划线'**
  String get toolboxPlayerNamesCanOnly;

  /// No description provided for @toolboxNoMinecraftPlayerNamed.
  ///
  /// In zh, this message translates to:
  /// **'找不到正版玩家 {n}'**
  String toolboxNoMinecraftPlayerNamed(Object n);

  /// No description provided for @toolboxPlayerLookupFailed.
  ///
  /// In zh, this message translates to:
  /// **'查询玩家失败（{s1}）'**
  String toolboxPlayerLookupFailed(Object s1);

  /// No description provided for @toolboxCouldntGetSkinInfo.
  ///
  /// In zh, this message translates to:
  /// **'获取皮肤信息失败（{s2}）'**
  String toolboxCouldntGetSkinInfo(Object s2);

  /// No description provided for @toolboxUsesDefaultSkin.
  ///
  /// In zh, this message translates to:
  /// **'{n} 使用的是默认皮肤'**
  String toolboxUsesDefaultSkin(Object n);

  /// No description provided for @toolboxCouldntDownloadSkin.
  ///
  /// In zh, this message translates to:
  /// **'下载皮肤失败（{s3}）'**
  String toolboxCouldntDownloadSkin(Object s3);

  /// No description provided for @toolboxItemNotFoundCheck.
  ///
  /// In zh, this message translates to:
  /// **'找不到这个物品，请检查物品 ID'**
  String get toolboxItemNotFoundCheck;

  /// No description provided for @toolboxGenerationFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成失败（{status}）'**
  String toolboxGenerationFailed(Object status);

  /// No description provided for @toolboxServerReturnedInvalidData.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回的数据无效'**
  String get toolboxServerReturnedInvalidData;

  /// No description provided for @toolboxInvalidServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址格式不正确'**
  String get toolboxInvalidServerAddress;

  /// No description provided for @toolboxCantConnect.
  ///
  /// In zh, this message translates to:
  /// **'无法连接：{e}'**
  String toolboxCantConnect(Object e);

  /// No description provided for @toolboxConnectionInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'连接中断：{e}'**
  String toolboxConnectionInterrupted(Object e);

  /// No description provided for @toolboxServerClosedConnection.
  ///
  /// In zh, this message translates to:
  /// **'服务器关闭了连接'**
  String get toolboxServerClosedConnection;

  /// No description provided for @toolboxConnectionTimedOut.
  ///
  /// In zh, this message translates to:
  /// **'连接超时'**
  String get toolboxConnectionTimedOut;

  /// No description provided for @androidRuntimeCouldntReadSystemLog.
  ///
  /// In zh, this message translates to:
  /// **'读取系统日志失败：{e}'**
  String androidRuntimeCouldntReadSystemLog(Object e);

  /// No description provided for @androidRuntimePixelWorldGameProcess.
  ///
  /// In zh, this message translates to:
  /// **'\n[Pixel World] 游戏进程没有启动，或启动后立即退出了。\n'**
  String get androidRuntimePixelWorldGameProcess;

  /// No description provided for @androidRuntimeSystemLogLogcat.
  ///
  /// In zh, this message translates to:
  /// **'\n---------- 系统日志（logcat） ----------\n{systemLog}\n'**
  String androidRuntimeSystemLogLogcat(Object systemLog);

  /// No description provided for @androidRuntimePixelWorldJarRunner.
  ///
  /// In zh, this message translates to:
  /// **'[Pixel World] jar 运行进程没有启动'**
  String get androidRuntimePixelWorldJarRunner;

  /// No description provided for @androidRuntimePixelWorldJarRunner2.
  ///
  /// In zh, this message translates to:
  /// **'[Pixel World] jar 运行进程在启动 Java 前退出了'**
  String get androidRuntimePixelWorldJarRunner2;

  /// No description provided for @androidRuntimeZinkOpenGLVulkan.
  ///
  /// In zh, this message translates to:
  /// **'Zink（OpenGL 转 Vulkan）'**
  String get androidRuntimeZinkOpenGLVulkan;

  /// No description provided for @androidRuntimeKryptonWrapperRecommended.
  ///
  /// In zh, this message translates to:
  /// **'Krypton Wrapper（推荐）'**
  String get androidRuntimeKryptonWrapperRecommended;

  /// No description provided for @androidRuntimeSystemGLESDriverGLES.
  ///
  /// In zh, this message translates to:
  /// **'系统 GLES 驱动（仅限支持 GLES 的模组）'**
  String get androidRuntimeSystemGLESDriverGLES;

  /// No description provided for @androidRuntimeUsesKryptonWrapperDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认用 Krypton Wrapper；26.x 版本改用 MobileGlues，显卡不支持 OpenGL ES 3 时用 Zink'**
  String get androidRuntimeUsesKryptonWrapperDefault;

  /// No description provided for @androidRuntimeOpenGLOpenGLESSupports.
  ///
  /// In zh, this message translates to:
  /// **'OpenGL 转 OpenGL ES，支持所有版本，包括 26.x（旧版本自动加 SFPEW 模拟固定管线）'**
  String get androidRuntimeOpenGLOpenGLESSupports;

  /// No description provided for @androidRuntimeMesaZinkFullOpenGL.
  ///
  /// In zh, this message translates to:
  /// **'Mesa Zink：完整的 OpenGL 4.6，需要 Vulkan 1.1。骁龙（Adreno）上自动改用自带的开源驱动 Turnip，适合 MobileGlues 画面出错时使用'**
  String get androidRuntimeMesaZinkFullOpenGL;

  /// No description provided for @androidRuntimeNGGL4ESOpenGLOpenGL.
  ///
  /// In zh, this message translates to:
  /// **'NG-GL4ES：OpenGL 转 OpenGL ES，效率高，新旧版本都能用，能运行 Sodium 和部分光影。26.3 快照起的版本暂不可用'**
  String get androidRuntimeNGGL4ESOpenGLOpenGL;

  /// No description provided for @androidRuntimeUsesSystemGLESDriver.
  ///
  /// In zh, this message translates to:
  /// **'直接使用系统 GLES 驱动，不做转译。原版 Minecraft 无法以此运行'**
  String get androidRuntimeUsesSystemGLESDriver;

  /// No description provided for @androidRuntimeNoVulkan.
  ///
  /// In zh, this message translates to:
  /// **'无 Vulkan'**
  String get androidRuntimeNoVulkan;

  /// No description provided for @androidRuntimeSetSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置指定'**
  String get androidRuntimeSetSettings;

  /// No description provided for @androidRuntimeGPUDoesntSupportOpenGL.
  ///
  /// In zh, this message translates to:
  /// **'显卡不支持 OpenGL ES 3'**
  String get androidRuntimeGPUDoesntSupportOpenGL;

  /// No description provided for @androidRuntime26XVersionKrypton.
  ///
  /// In zh, this message translates to:
  /// **'26.x 版本，Krypton Wrapper 暂不支持'**
  String get androidRuntime26XVersionKrypton;

  /// No description provided for @androidRuntimeExtractJava.
  ///
  /// In zh, this message translates to:
  /// **'解压 Java {major}'**
  String androidRuntimeExtractJava(Object major);

  /// No description provided for @androidRuntimeExtractingMB.
  ///
  /// In zh, this message translates to:
  /// **'正在解压 {size} MB…'**
  String androidRuntimeExtractingMB(Object size);

  /// No description provided for @androidRuntimeExtracting.
  ///
  /// In zh, this message translates to:
  /// **'解压中 {total}%'**
  String androidRuntimeExtracting(Object total);

  /// No description provided for @androidRuntimeDownloadJava.
  ///
  /// In zh, this message translates to:
  /// **'下载 Java {major}（{name}）'**
  String androidRuntimeDownloadJava(Object major, Object name);

  /// No description provided for @androidRuntimeDownloadIsntValidArchive.
  ///
  /// In zh, this message translates to:
  /// **'下载到的不是有效的压缩包'**
  String get androidRuntimeDownloadIsntValidArchive;

  /// No description provided for @androidRuntimeJavaDownloadedMBFrom.
  ///
  /// In zh, this message translates to:
  /// **'Java {major} 下载完成（{lengthSync} MB，来源 {name}）'**
  String androidRuntimeJavaDownloadedMBFrom(Object major, Object lengthSync, Object name);

  /// No description provided for @androidRuntimeDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'{name} 下载失败：{e}'**
  String androidRuntimeDownloadFailed(Object name, Object e);

  /// No description provided for @androidRuntimeJavaDownloadFailedTried.
  ///
  /// In zh, this message translates to:
  /// **'Java {major} 下载失败，已尝试 GitHub 与镜像：\n{failures}'**
  String androidRuntimeJavaDownloadFailedTried(Object major, Object failures);

  /// No description provided for @androidRuntimeJavaSetIsntInstalled.
  ///
  /// In zh, this message translates to:
  /// **'{where}指定的 Java 没有安装：{home}。请在设置的 Java 页面下载，或改为自动选择'**
  String androidRuntimeJavaSetIsntInstalled(Object where, Object home);

  /// No description provided for @androidRuntimeJavaSetButInstance.
  ///
  /// In zh, this message translates to:
  /// **'{where}指定的是 Java {major}，这个实例至少需要 Java {requiredValue}。请重新选择 Java，或改为自动选择'**
  String androidRuntimeJavaSetButInstance(Object where, Object major, Object requiredValue);

  /// No description provided for @importInvalidEncryptedDataLength.
  ///
  /// In zh, this message translates to:
  /// **'加密数据长度无效'**
  String get importInvalidEncryptedDataLength;

  /// No description provided for @importUnrecognizedCNGProtectedData.
  ///
  /// In zh, this message translates to:
  /// **'无法识别的 CNG 保护数据'**
  String get importUnrecognizedCNGProtectedData;

  /// No description provided for @importPCLCEAccountKeys.
  ///
  /// In zh, this message translates to:
  /// **'PCL-CE 的账户密钥只能在 Windows 上解开'**
  String get importPCLCEAccountKeys;

  /// No description provided for @importPCLCEUserKey.
  ///
  /// In zh, this message translates to:
  /// **'找不到 PCL-CE 用户密钥 UserKey.bin'**
  String get importPCLCEUserKey;

  /// No description provided for @importUnrecognizedUserKeyBinFormat.
  ///
  /// In zh, this message translates to:
  /// **'UserKey.bin 格式无法识别'**
  String get importUnrecognizedUserKeyBinFormat;

  /// No description provided for @importUnsupportedUserKeyVersion.
  ///
  /// In zh, this message translates to:
  /// **'不支持的 UserKey 版本 {version}'**
  String importUnsupportedUserKeyVersion(Object version);

  /// No description provided for @importOldEncryptionFormatImport.
  ///
  /// In zh, this message translates to:
  /// **'旧版加密格式，不支持导入'**
  String get importOldEncryptionFormatImport;

  /// No description provided for @importUnsupportedEncryptionVersion.
  ///
  /// In zh, this message translates to:
  /// **'不支持的加密版本 {version}'**
  String importUnsupportedEncryptionVersion(Object version);

  /// No description provided for @importNoPCLCEConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'没有找到 PCL-CE 的配置（%APPDATA%\\PCLCE）'**
  String get importNoPCLCEConfiguration;

  /// No description provided for @importIPProtocolPreference.
  ///
  /// In zh, this message translates to:
  /// **'IP 协议偏好'**
  String get importIPProtocolPreference;

  /// No description provided for @importHighPerformanceGPU.
  ///
  /// In zh, this message translates to:
  /// **'高性能显卡'**
  String get importHighPerformanceGPU;

  /// No description provided for @importLauncherBehaviorAfterLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动后启动器行为'**
  String get importLauncherBehaviorAfterLaunch;

  /// No description provided for @importJavaChoice.
  ///
  /// In zh, this message translates to:
  /// **'Java 选择'**
  String get importJavaChoice;

  /// No description provided for @importMemoryMode.
  ///
  /// In zh, this message translates to:
  /// **'内存模式'**
  String get importMemoryMode;

  /// No description provided for @importCustomMemory.
  ///
  /// In zh, this message translates to:
  /// **'自定义内存'**
  String get importCustomMemory;

  /// No description provided for @importPreLaunchCommand.
  ///
  /// In zh, this message translates to:
  /// **'启动前命令'**
  String get importPreLaunchCommand;

  /// No description provided for @importWaitPreLaunchCommand.
  ///
  /// In zh, this message translates to:
  /// **'等待启动前命令'**
  String get importWaitPreLaunchCommand;

  /// No description provided for @importVersionType.
  ///
  /// In zh, this message translates to:
  /// **'版本类型'**
  String get importVersionType;

  /// No description provided for @importWindowMode.
  ///
  /// In zh, this message translates to:
  /// **'窗口模式'**
  String get importWindowMode;

  /// No description provided for @importMemoryJVMArgumentsInstance.
  ///
  /// In zh, this message translates to:
  /// **'内存、JVM 参数、实例隔离等设置保存在 PCL-CE 程序目录中，选择该目录后才能导入'**
  String get importMemoryJVMArgumentsInstance;

  /// No description provided for @importPCLCEFolder.
  ///
  /// In zh, this message translates to:
  /// **'PCL-CE 文件夹'**
  String get importPCLCEFolder;

  /// No description provided for @importIncompleteAccountInfoSign.
  ///
  /// In zh, this message translates to:
  /// **'{name}（账户信息不完整，请在账户中重新登录）'**
  String importIncompleteAccountInfoSign(Object name);

  /// No description provided for @importAccountImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'账户导入失败：{e}'**
  String importAccountImportFailed(Object e);

  /// No description provided for @backupBackupFileCorrupted.
  ///
  /// In zh, this message translates to:
  /// **'备份文件已损坏：{e}'**
  String backupBackupFileCorrupted(Object e);

  /// No description provided for @backupBackupWasntCreatedPixel.
  ///
  /// In zh, this message translates to:
  /// **'这个备份不是由 Pixel World 创建的，无法恢复'**
  String get backupBackupWasntCreatedPixel;

  /// No description provided for @backupInvalidBackupManifest.
  ///
  /// In zh, this message translates to:
  /// **'备份清单无效'**
  String get backupInvalidBackupManifest;

  /// No description provided for @backupBackupManifestContainsUnsafe.
  ///
  /// In zh, this message translates to:
  /// **'备份清单中有不安全的路径：{e}'**
  String backupBackupManifestContainsUnsafe(Object e);

  /// No description provided for @backupBackupManifestContainsDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'备份清单中有重复或互相包含的路径'**
  String get backupBackupManifestContainsDuplicate;

  /// No description provided for @backupBackupSignatureMismatchBackup.
  ///
  /// In zh, this message translates to:
  /// **'备份签名不匹配：备份被修改过，或者不是在这台设备上创建的'**
  String get backupBackupSignatureMismatchBackup;

  /// No description provided for @backupBackupContainsSymbolicLink.
  ///
  /// In zh, this message translates to:
  /// **'备份中有符号链接，不能恢复：{name}'**
  String backupBackupContainsSymbolicLink(Object name);

  /// No description provided for @backupBackupContainsUnsafePath.
  ///
  /// In zh, this message translates to:
  /// **'备份中有不安全的路径：{name}'**
  String backupBackupContainsUnsafePath(Object name);

  /// No description provided for @backupBackupContainsFileNot.
  ///
  /// In zh, this message translates to:
  /// **'备份中有清单以外的文件：{name}'**
  String backupBackupContainsFileNot(Object name);

  /// No description provided for @backupBackupContainsDuplicateFile.
  ///
  /// In zh, this message translates to:
  /// **'备份中有重复的文件：{name}'**
  String backupBackupContainsDuplicateFile(Object name);

  /// No description provided for @backupBackupContentsDontMatch.
  ///
  /// In zh, this message translates to:
  /// **'备份内容与清单不符：{name}'**
  String backupBackupContentsDontMatch(Object name);

  /// No description provided for @backupBackupMissingFilesListed.
  ///
  /// In zh, this message translates to:
  /// **'备份缺少清单中的文件'**
  String get backupBackupMissingFilesListed;

  /// No description provided for @backupBackupContainsSymbolicLink2.
  ///
  /// In zh, this message translates to:
  /// **'备份中有符号链接：{name}'**
  String backupBackupContainsSymbolicLink2(Object name);

  /// No description provided for @backupFileContentsDontMatch.
  ///
  /// In zh, this message translates to:
  /// **'文件内容与备份清单不符：{rel}'**
  String backupFileContentsDontMatch(Object rel);

  /// No description provided for @networkCheckMojangOfficial.
  ///
  /// In zh, this message translates to:
  /// **'Mojang 官方源'**
  String get networkCheckMojangOfficial;

  /// No description provided for @networkCheckGameLibraryDownloads.
  ///
  /// In zh, this message translates to:
  /// **'下载游戏和运行库'**
  String get networkCheckGameLibraryDownloads;

  /// No description provided for @networkCheckGameLoaderDownloadsMainland.
  ///
  /// In zh, this message translates to:
  /// **'国内下载游戏、加载器'**
  String get networkCheckGameLoaderDownloadsMainland;

  /// No description provided for @networkCheckMicrosoftSign.
  ///
  /// In zh, this message translates to:
  /// **'Microsoft 登录'**
  String get networkCheckMicrosoftSign;

  /// No description provided for @networkCheckMicrosoftAccountSign.
  ///
  /// In zh, this message translates to:
  /// **'正版账户登录'**
  String get networkCheckMicrosoftAccountSign;

  /// No description provided for @networkCheckModsModpacksResourcePacks.
  ///
  /// In zh, this message translates to:
  /// **'模组、整合包、资源包'**
  String get networkCheckModsModpacksResourcePacks;

  /// No description provided for @networkCheckPixelWorldUpdates.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 更新'**
  String get networkCheckPixelWorldUpdates;

  /// No description provided for @networkCheckUpdateChecksAnnouncementsDocs.
  ///
  /// In zh, this message translates to:
  /// **'检查更新、公告和文档'**
  String get networkCheckUpdateChecksAnnouncementsDocs;

  /// No description provided for @networkCheckTimedOut.
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get networkCheckTimedOut;

  /// No description provided for @networkCheckSecureConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'安全连接失败'**
  String get networkCheckSecureConnectionFailed;

  /// No description provided for @networkCheckConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败（{error}）'**
  String networkCheckConnectionFailed(Object error);

  /// No description provided for @microsoftMicrosoftAccountDoesntHave.
  ///
  /// In zh, this message translates to:
  /// **'该微软账户尚未创建 Xbox 档案'**
  String get microsoftMicrosoftAccountDoesntHave;

  /// No description provided for @microsoftUnderageAccountsNeedJoin.
  ///
  /// In zh, this message translates to:
  /// **'未成年账户需要加入家庭组后才能登录'**
  String get microsoftUnderageAccountsNeedJoin;

  /// No description provided for @microsoftMinecraftRejectedAzureApp.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft 拒绝了这个 Azure 应用（{status} Invalid app registration）。新应用需要先通过 Mojang 的审核（https://aka.ms/mce-reviewappid），审核通过后要用同一个 Client ID 重新登录；刚通过时可能要等一段时间才生效'**
  String microsoftMinecraftRejectedAzureApp(Object status);

  /// No description provided for @microsoftRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（{status}）：{url}{reason}'**
  String microsoftRequestFailed(Object status, Object url, Object reason);

  /// No description provided for @microsoftAccountDoesntOwnMinecraft.
  ///
  /// In zh, this message translates to:
  /// **'该账户没有购买 Minecraft: Java Edition'**
  String get microsoftAccountDoesntOwnMinecraft;

  /// No description provided for @microsoftCouldntGetProfile.
  ///
  /// In zh, this message translates to:
  /// **'获取档案失败（{status}）{reason}'**
  String microsoftCouldntGetProfile(Object status, Object reason);

  /// No description provided for @microsoftSetAzureAppClient.
  ///
  /// In zh, this message translates to:
  /// **'请先在「设置 - 其他」中填写 Azure 应用 Client ID'**
  String get microsoftSetAzureAppClient;

  /// No description provided for @microsoftSignAccountHasExpired.
  ///
  /// In zh, this message translates to:
  /// **'账户 {name} 的登录已过期（导入自 PCL-CE，无法续期），请使用微软登录重新添加'**
  String microsoftSignAccountHasExpired(Object name);

  /// No description provided for @microsoftMicrosoftAccountHasExpired.
  ///
  /// In zh, this message translates to:
  /// **'微软账户已过期，请重新登录'**
  String get microsoftMicrosoftAccountHasExpired;

  /// No description provided for @docsOverview.
  ///
  /// In zh, this message translates to:
  /// **'总览'**
  String get docsOverview;

  /// No description provided for @docsDownloadInstall.
  ///
  /// In zh, this message translates to:
  /// **'下载与安装'**
  String get docsDownloadInstall;

  /// No description provided for @docsFirstLaunch.
  ///
  /// In zh, this message translates to:
  /// **'第一次启动'**
  String get docsFirstLaunch;

  /// No description provided for @docsVersionsLoaders.
  ///
  /// In zh, this message translates to:
  /// **'版本与加载器'**
  String get docsVersionsLoaders;

  /// No description provided for @docsAndroid.
  ///
  /// In zh, this message translates to:
  /// **'安卓版'**
  String get docsAndroid;

  /// No description provided for @docsFAQTroubleshooting.
  ///
  /// In zh, this message translates to:
  /// **'常见问题与排错'**
  String get docsFAQTroubleshooting;

  /// No description provided for @docsLauncherAPI.
  ///
  /// In zh, this message translates to:
  /// **'启动器接口'**
  String get docsLauncherAPI;

  /// No description provided for @docsDocumentEmpty.
  ///
  /// In zh, this message translates to:
  /// **'文档内容为空'**
  String get docsDocumentEmpty;

  /// No description provided for @docsCouldntLoadDocsCheck.
  ///
  /// In zh, this message translates to:
  /// **'无法获取文档（{error}），请检查网络后重试'**
  String docsCouldntLoadDocsCheck(Object error);

  /// No description provided for @docsNoCache.
  ///
  /// In zh, this message translates to:
  /// **'没有缓存'**
  String get docsNoCache;

  /// No description provided for @instanceFilesFoldersCantOpenedPhones.
  ///
  /// In zh, this message translates to:
  /// **'手机上暂时不能打开文件夹'**
  String get instanceFilesFoldersCantOpenedPhones;

  /// No description provided for @instanceFilesCouldntMoveRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'无法移到回收站：{stderr}'**
  String instanceFilesCouldntMoveRecycleBin(Object stderr);

  /// No description provided for @instanceFilesCouldntMoveTrash.
  ///
  /// In zh, this message translates to:
  /// **'无法移到废纸篓'**
  String get instanceFilesCouldntMoveTrash;

  /// No description provided for @instanceFilesCouldntMoveRecycleBin2.
  ///
  /// In zh, this message translates to:
  /// **'无法移到回收站'**
  String get instanceFilesCouldntMoveRecycleBin2;

  /// No description provided for @instanceFilesUnknownNBTType.
  ///
  /// In zh, this message translates to:
  /// **'未知的 NBT 类型 {typeValue}'**
  String instanceFilesUnknownNBTType(Object typeValue);

  /// No description provided for @safePathOnlyFilesVersionsWorking.
  ///
  /// In zh, this message translates to:
  /// **'只能访问版本运行目录中的文件：{rel}'**
  String safePathOnlyFilesVersionsWorking(Object rel);

  /// No description provided for @safePathInvalidPath.
  ///
  /// In zh, this message translates to:
  /// **'路径无效：{rel}'**
  String safePathInvalidPath(Object rel);

  /// No description provided for @safePathOnlyFilesVersionsWorking2.
  ///
  /// In zh, this message translates to:
  /// **'只能访问版本运行目录中的文件'**
  String get safePathOnlyFilesVersionsWorking2;

  /// No description provided for @safePathPathContainsSymbolicLink.
  ///
  /// In zh, this message translates to:
  /// **'路径中有符号链接，为安全起见不能操作：{root}'**
  String safePathPathContainsSymbolicLink(Object root);

  /// No description provided for @safePathCantDetermineRealLocation.
  ///
  /// In zh, this message translates to:
  /// **'无法确认路径的真实位置：{root}'**
  String safePathCantDetermineRealLocation(Object root);

  /// No description provided for @safePathPathActuallyPointsOutside.
  ///
  /// In zh, this message translates to:
  /// **'路径实际指向版本运行目录之外：{root}'**
  String safePathPathActuallyPointsOutside(Object root);

  /// No description provided for @updaterGitHubRateLimitExceeded.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 访问次数超出限制，请稍后再试'**
  String get updaterGitHubRateLimitExceeded;

  /// No description provided for @updaterCouldntGetUpdateInfo.
  ///
  /// In zh, this message translates to:
  /// **'无法获取更新信息（HTTP {statusCode}）'**
  String updaterCouldntGetUpdateInfo(Object statusCode);

  /// No description provided for @updaterInstallingUnknownAppsNeeds.
  ///
  /// In zh, this message translates to:
  /// **'需要允许安装未知应用'**
  String get updaterInstallingUnknownAppsNeeds;

  /// No description provided for @updaterIncompleteDownloadBytes.
  ///
  /// In zh, this message translates to:
  /// **'下载不完整（{received} / {size} 字节）'**
  String updaterIncompleteDownloadBytes(Object received, Object size);

  /// No description provided for @updaterFileVerificationFailedSHA.
  ///
  /// In zh, this message translates to:
  /// **'文件校验失败（SHA-256 不匹配）'**
  String get updaterFileVerificationFailedSHA;

  /// No description provided for @updaterAutomaticUpdatesArentSupported.
  ///
  /// In zh, this message translates to:
  /// **'这个平台暂不支持自动更新'**
  String get updaterAutomaticUpdatesArentSupported;

  /// No description provided for @updaterUpdatePackageDoesntContain.
  ///
  /// In zh, this message translates to:
  /// **'更新包中找不到主程序（{appExeNames}）'**
  String updaterUpdatePackageDoesntContain(Object appExeNames);

  /// No description provided for @updaterText.
  ///
  /// In zh, this message translates to:
  /// **' 或 '**
  String get updaterText;

  /// No description provided for @hudBridgeConversationNoLongerExists.
  ///
  /// In zh, this message translates to:
  /// **'这个对话已经不存在了。'**
  String get hudBridgeConversationNoLongerExists;

  /// No description provided for @hudBridgeQuestionCantEmpty.
  ///
  /// In zh, this message translates to:
  /// **'问题不能为空。'**
  String get hudBridgeQuestionCantEmpty;

  /// No description provided for @hudBridgeAIIsntSetUp.
  ///
  /// In zh, this message translates to:
  /// **'还没有配置 AI。请回到启动器，在「设置 → AI」里填写接口、模型和 API Key。'**
  String get hudBridgeAIIsntSetUp;

  /// No description provided for @hudBridgeConversationStillBeingAnswered.
  ///
  /// In zh, this message translates to:
  /// **'这个对话还在回答，请稍等一下。'**
  String get hudBridgeConversationStillBeingAnswered;

  /// No description provided for @hudBridgeWaitingConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'等待确认：{label}'**
  String hudBridgeWaitingConfirmation(Object label);

  /// No description provided for @hudBridgeRunning.
  ///
  /// In zh, this message translates to:
  /// **'正在执行：{label}'**
  String hudBridgeRunning(Object label);

  /// No description provided for @yggdrasilConnectDoesntSupportYggdrasilConnect.
  ///
  /// In zh, this message translates to:
  /// **'{name} 不支持 Yggdrasil Connect'**
  String yggdrasilConnectDoesntSupportYggdrasilConnect(Object name);

  /// No description provided for @yggdrasilConnectHasInvalidYggdrasilConnect.
  ///
  /// In zh, this message translates to:
  /// **'{name} 的 Yggdrasil Connect 配置无效'**
  String yggdrasilConnectHasInvalidYggdrasilConnect(Object name);

  /// No description provided for @yggdrasilConnectLauncherHasntRegisteredApp.
  ///
  /// In zh, this message translates to:
  /// **'启动器尚未在 {name} 注册应用，暂时无法使用 OAuth 登录'**
  String yggdrasilConnectLauncherHasntRegisteredApp(Object name);

  /// No description provided for @yggdrasilConnectMalformedIDToken.
  ///
  /// In zh, this message translates to:
  /// **'ID 令牌格式错误'**
  String get yggdrasilConnectMalformedIDToken;

  /// No description provided for @yggdrasilConnectInvalidIDTokenIssuer.
  ///
  /// In zh, this message translates to:
  /// **'ID 令牌无效（签发者、受众或有效期不符）'**
  String get yggdrasilConnectInvalidIDTokenIssuer;

  /// No description provided for @yggdrasilConnectDoesntSupportDeviceCode.
  ///
  /// In zh, this message translates to:
  /// **'{name} 不支持设备代码登录'**
  String yggdrasilConnectDoesntSupportDeviceCode(Object name);

  /// No description provided for @yggdrasilConnectNoProfileWasChosen.
  ///
  /// In zh, this message translates to:
  /// **'授权时没有选择角色'**
  String get yggdrasilConnectNoProfileWasChosen;

  /// No description provided for @yggdrasilConnectAuthorizationAccountHasExpired.
  ///
  /// In zh, this message translates to:
  /// **'{typeLabel} 账户 {name} 的授权已过期，请在账户中重新登录'**
  String yggdrasilConnectAuthorizationAccountHasExpired(Object typeLabel, Object name);

  /// No description provided for @oauthCantStartSign.
  ///
  /// In zh, this message translates to:
  /// **'无法开始登录：{status}'**
  String oauthCantStartSign(Object status);

  /// No description provided for @oauthAuthorizationDenied.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝授权'**
  String get oauthAuthorizationDenied;

  /// No description provided for @oauthSignTimedOutPlease.
  ///
  /// In zh, this message translates to:
  /// **'登录超时，请重试'**
  String get oauthSignTimedOutPlease;

  /// No description provided for @oauthSignFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败：{status}'**
  String oauthSignFailed(Object status);

  /// No description provided for @oauthAuthenticationServerTemporarilyUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'验证服务器暂时不可用（{status}），请稍后再试'**
  String oauthAuthenticationServerTemporarilyUnavailable(Object status);

  /// No description provided for @accountsExternal.
  ///
  /// In zh, this message translates to:
  /// **'外置登录 · {host}'**
  String accountsExternal(Object host);

  /// No description provided for @accountsUsernamesMust316.
  ///
  /// In zh, this message translates to:
  /// **'用户名需为 3-16 位字母、数字或下划线'**
  String get accountsUsernamesMust316;

  /// No description provided for @yggdrasilAccountHasNoProfile.
  ///
  /// In zh, this message translates to:
  /// **'该账户还没有角色，请先到皮肤站创建角色'**
  String get yggdrasilAccountHasNoProfile;

  /// No description provided for @yggdrasilAuthenticationServerDidntReturn.
  ///
  /// In zh, this message translates to:
  /// **'验证服务器没有返回所选角色'**
  String get yggdrasilAuthenticationServerDidntReturn;

  /// No description provided for @yggdrasilProfileNoLongerBelongs.
  ///
  /// In zh, this message translates to:
  /// **'角色 {name} 已不在该账户下，请重新添加账户'**
  String yggdrasilProfileNoLongerBelongs(Object name);

  /// No description provided for @yggdrasilApiEnterAuthenticationServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证服务器地址'**
  String get yggdrasilApiEnterAuthenticationServerAddress;

  /// No description provided for @yggdrasilApiIsntValidAuthenticationServer.
  ///
  /// In zh, this message translates to:
  /// **'{url} 不是有效的验证服务器'**
  String yggdrasilApiIsntValidAuthenticationServer(Object url);

  /// No description provided for @yggdrasilApiAuthenticationServerReturnedHTTP.
  ///
  /// In zh, this message translates to:
  /// **'验证服务器返回 HTTP {status}'**
  String yggdrasilApiAuthenticationServerReturnedHTTP(Object status);

  /// No description provided for @newsMinecraftWikiRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft Wiki 请求失败（{statusCode}）'**
  String newsMinecraftWikiRequestFailed(Object statusCode);

  /// No description provided for @secureEncryptionFailed.
  ///
  /// In zh, this message translates to:
  /// **'加密失败'**
  String get secureEncryptionFailed;

  /// No description provided for @secureDecryptionFailed.
  ///
  /// In zh, this message translates to:
  /// **'解密失败'**
  String get secureDecryptionFailed;

  /// No description provided for @authlibInjectorVerificationFailedSHA256.
  ///
  /// In zh, this message translates to:
  /// **'校验失败（SHA-256 不匹配）'**
  String get authlibInjectorVerificationFailedSHA256;

  /// No description provided for @authlibInjectorCouldntDownloadAuthlibInjector.
  ///
  /// In zh, this message translates to:
  /// **'无法下载 authlib-injector：{e}'**
  String authlibInjectorCouldntDownloadAuthlibInjector(Object e);

  /// No description provided for @authSignCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消登录'**
  String get authSignCanceled;

  /// No description provided for @aiToolsViewInstanceList.
  ///
  /// In zh, this message translates to:
  /// **'查看实例列表'**
  String get aiToolsViewInstanceList;

  /// No description provided for @aiToolsViewInstanceInfo.
  ///
  /// In zh, this message translates to:
  /// **'查看实例信息'**
  String get aiToolsViewInstanceInfo;

  /// No description provided for @aiToolsViewInfo.
  ///
  /// In zh, this message translates to:
  /// **'查看 {id} 的信息'**
  String aiToolsViewInfo(Object id);

  /// No description provided for @aiToolsViewModList.
  ///
  /// In zh, this message translates to:
  /// **'查看模组列表'**
  String get aiToolsViewModList;

  /// No description provided for @aiToolsViewMods.
  ///
  /// In zh, this message translates to:
  /// **'查看 {id} 的模组'**
  String aiToolsViewMods(Object id);

  /// No description provided for @aiToolsViewFiles.
  ///
  /// In zh, this message translates to:
  /// **'查看文件'**
  String get aiToolsViewFiles;

  /// No description provided for @aiToolsView.
  ///
  /// In zh, this message translates to:
  /// **'查看 {id}/{rel}'**
  String aiToolsView(Object id, Object rel);

  /// No description provided for @aiToolsReadLog.
  ///
  /// In zh, this message translates to:
  /// **'读取日志'**
  String get aiToolsReadLog;

  /// No description provided for @aiToolsRead.
  ///
  /// In zh, this message translates to:
  /// **'读取 {id} 的{kind}'**
  String aiToolsRead(Object id, Object kind);

  /// No description provided for @aiToolsCrashReport.
  ///
  /// In zh, this message translates to:
  /// **'崩溃报告'**
  String get aiToolsCrashReport;

  /// No description provided for @aiToolsDebugLog.
  ///
  /// In zh, this message translates to:
  /// **'调试日志'**
  String get aiToolsDebugLog;

  /// No description provided for @aiToolsSearchMods.
  ///
  /// In zh, this message translates to:
  /// **'搜索模组'**
  String get aiToolsSearchMods;

  /// No description provided for @aiToolsSearchModrinth.
  ///
  /// In zh, this message translates to:
  /// **'在 Modrinth 搜索「{q}」'**
  String aiToolsSearchModrinth(Object q);

  /// No description provided for @aiToolsViewInstallableVersions.
  ///
  /// In zh, this message translates to:
  /// **'查看可安装的版本'**
  String get aiToolsViewInstallableVersions;

  /// No description provided for @aiToolsViewInstallableMinecraftVersions.
  ///
  /// In zh, this message translates to:
  /// **'查看可安装的 Minecraft 版本'**
  String get aiToolsViewInstallableMinecraftVersions;

  /// No description provided for @aiToolsViewLoaderVersions.
  ///
  /// In zh, this message translates to:
  /// **'查看加载器版本'**
  String get aiToolsViewLoaderVersions;

  /// No description provided for @aiToolsViewVersions.
  ///
  /// In zh, this message translates to:
  /// **'查看 {game} 的 {label} 版本'**
  String aiToolsViewVersions(Object game, Object label);

  /// No description provided for @aiToolsInstallNewInstance.
  ///
  /// In zh, this message translates to:
  /// **'安装新实例'**
  String get aiToolsInstallNewInstance;

  /// No description provided for @aiToolsSwitchCurrentInstance.
  ///
  /// In zh, this message translates to:
  /// **'把当前实例切换为 {id}'**
  String aiToolsSwitchCurrentInstance(Object id);

  /// No description provided for @aiToolsSearchResources.
  ///
  /// In zh, this message translates to:
  /// **'搜索资源'**
  String get aiToolsSearchResources;

  /// No description provided for @aiToolsSearchModrinth2.
  ///
  /// In zh, this message translates to:
  /// **'在 Modrinth 搜索{f}{label}{q}'**
  String aiToolsSearchModrinth2(Object f, Object label, Object q);

  /// No description provided for @aiToolsText.
  ///
  /// In zh, this message translates to:
  /// **'{label} 的'**
  String aiToolsText(Object label);

  /// No description provided for @aiToolsViewProjectDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看项目详情'**
  String get aiToolsViewProjectDetails;

  /// No description provided for @aiToolsViewModrinthProject.
  ///
  /// In zh, this message translates to:
  /// **'查看 Modrinth 项目 {ids}'**
  String aiToolsViewModrinthProject(Object ids);

  /// No description provided for @aiToolsCompareModrinthProjects.
  ///
  /// In zh, this message translates to:
  /// **'比较 {count} 个 Modrinth 项目'**
  String aiToolsCompareModrinthProjects(Object count);

  /// No description provided for @aiToolsInstallResource.
  ///
  /// In zh, this message translates to:
  /// **'安装资源'**
  String get aiToolsInstallResource;

  /// No description provided for @aiToolsInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装{label} {name}'**
  String aiToolsInstall(Object label, Object name);

  /// No description provided for @aiToolsInstance.
  ///
  /// In zh, this message translates to:
  /// **'实例：{id}'**
  String aiToolsInstance(Object id);

  /// No description provided for @aiToolsFileInto.
  ///
  /// In zh, this message translates to:
  /// **'文件：{fileName}（{fileSize}），放进 {folder}'**
  String aiToolsFileInto(Object fileName, Object fileSize, Object folder);

  /// No description provided for @aiToolsSourceModrinth.
  ///
  /// In zh, this message translates to:
  /// **'来源：Modrinth'**
  String get aiToolsSourceModrinth;

  /// No description provided for @aiToolsViewJava.
  ///
  /// In zh, this message translates to:
  /// **'查看 Java'**
  String get aiToolsViewJava;

  /// No description provided for @aiToolsViewInstalledJava.
  ///
  /// In zh, this message translates to:
  /// **'查看已安装的 Java'**
  String get aiToolsViewInstalledJava;

  /// No description provided for @aiToolsViewSystemInfo.
  ///
  /// In zh, this message translates to:
  /// **'查看系统信息'**
  String get aiToolsViewSystemInfo;

  /// No description provided for @aiToolsSetInstanceJava.
  ///
  /// In zh, this message translates to:
  /// **'设置实例的 Java'**
  String get aiToolsSetInstanceJava;

  /// No description provided for @aiToolsChangeJava.
  ///
  /// In zh, this message translates to:
  /// **'把 {id} 的 Java 改为{label}'**
  String aiToolsChangeJava(Object id, Object label);

  /// No description provided for @aiToolsBefore.
  ///
  /// In zh, this message translates to:
  /// **'原来：{old}'**
  String aiToolsBefore(Object old);

  /// No description provided for @aiToolsAfter.
  ///
  /// In zh, this message translates to:
  /// **'改为：{label}'**
  String aiToolsAfter(Object label);

  /// No description provided for @aiToolsSetInstanceMemory.
  ///
  /// In zh, this message translates to:
  /// **'设置实例的内存'**
  String get aiToolsSetInstanceMemory;

  /// No description provided for @aiToolsChangeMemory.
  ///
  /// In zh, this message translates to:
  /// **'把 {id} 的内存改为{label}'**
  String aiToolsChangeMemory(Object id, Object label);

  /// No description provided for @aiToolsBefore2.
  ///
  /// In zh, this message translates to:
  /// **'原来：{s}'**
  String aiToolsBefore2(Object s);

  /// No description provided for @aiToolsSystemMemoryGBTotal.
  ///
  /// In zh, this message translates to:
  /// **'系统内存：共 {total} GB，当前空闲 {free} GB'**
  String aiToolsSystemMemoryGBTotal(Object total, Object free);

  /// No description provided for @aiToolsReadConfigFile.
  ///
  /// In zh, this message translates to:
  /// **'读取配置文件'**
  String get aiToolsReadConfigFile;

  /// No description provided for @commonRead.
  ///
  /// In zh, this message translates to:
  /// **'读取 {rel}'**
  String commonRead(Object rel);

  /// No description provided for @aiToolsEditConfigFile.
  ///
  /// In zh, this message translates to:
  /// **'修改配置文件'**
  String get aiToolsEditConfigFile;

  /// No description provided for @aiToolsEditChanges.
  ///
  /// In zh, this message translates to:
  /// **'修改 {rel}（{count} 处）'**
  String aiToolsEditChanges(Object rel, Object count);

  /// No description provided for @aiToolsOriginalFileBackedUp.
  ///
  /// In zh, this message translates to:
  /// **'修改前会备份原文件'**
  String get aiToolsOriginalFileBackedUp;

  /// No description provided for @aiToolsInstallMod.
  ///
  /// In zh, this message translates to:
  /// **'安装模组'**
  String get aiToolsInstallMod;

  /// No description provided for @aiToolsInstallMod2.
  ///
  /// In zh, this message translates to:
  /// **'安装模组 {name}'**
  String aiToolsInstallMod2(Object name);

  /// No description provided for @aiToolsFile.
  ///
  /// In zh, this message translates to:
  /// **'文件：{fileName}（{fileSize}）'**
  String aiToolsFile(Object fileName, Object fileSize);

  /// No description provided for @aiToolsRequiredDependenciesInstalledToo.
  ///
  /// In zh, this message translates to:
  /// **'会同时安装必需的前置模组'**
  String get aiToolsRequiredDependenciesInstalledToo;

  /// No description provided for @aiToolsEnableDisableMods.
  ///
  /// In zh, this message translates to:
  /// **'启用或禁用模组'**
  String get aiToolsEnableDisableMods;

  /// No description provided for @aiToolsMods.
  ///
  /// In zh, this message translates to:
  /// **'{enabled} {count} 个模组'**
  String aiToolsMods(Object enabled, Object count);

  /// No description provided for @aiToolsEnable.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get aiToolsEnable;

  /// No description provided for @aiToolsDisable.
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get aiToolsDisable;

  /// No description provided for @aiToolsBackUp.
  ///
  /// In zh, this message translates to:
  /// **'备份'**
  String get aiToolsBackUp;

  /// No description provided for @aiToolsBackUpItems.
  ///
  /// In zh, this message translates to:
  /// **'备份 {count} 项'**
  String aiToolsBackUpItems(Object count);

  /// No description provided for @aiToolsAboutSavedBackupsGame.
  ///
  /// In zh, this message translates to:
  /// **'大小约 {size}，保存到游戏文件夹的 backups 中'**
  String aiToolsAboutSavedBackupsGame(Object size);

  /// No description provided for @aiToolsViewBackups.
  ///
  /// In zh, this message translates to:
  /// **'查看备份'**
  String get aiToolsViewBackups;

  /// No description provided for @aiToolsViewBackups2.
  ///
  /// In zh, this message translates to:
  /// **'查看 {id} 的备份'**
  String aiToolsViewBackups2(Object id);

  /// No description provided for @commonDeleteFiles.
  ///
  /// In zh, this message translates to:
  /// **'删除文件'**
  String get commonDeleteFiles;

  /// No description provided for @aiToolsDeleteItemsMoveRecycle.
  ///
  /// In zh, this message translates to:
  /// **'删除 {count} 项（移到回收站）'**
  String aiToolsDeleteItemsMoveRecycle(Object count);

  /// No description provided for @aiToolsReplaceMod.
  ///
  /// In zh, this message translates to:
  /// **'替换模组'**
  String get aiToolsReplaceMod;

  /// No description provided for @aiToolsReplaceMod2.
  ///
  /// In zh, this message translates to:
  /// **'替换模组 {name}'**
  String aiToolsReplaceMod2(Object name);

  /// No description provided for @aiToolsOldFile.
  ///
  /// In zh, this message translates to:
  /// **'旧文件：{name}'**
  String aiToolsOldFile(Object name);

  /// No description provided for @aiToolsNewFileFromModrinth.
  ///
  /// In zh, this message translates to:
  /// **'新文件：{fileName}（{name}，来自 Modrinth）'**
  String aiToolsNewFileFromModrinth(Object fileName, Object name);

  /// No description provided for @aiToolsOldFileBackedUp.
  ///
  /// In zh, this message translates to:
  /// **'旧文件会先备份，再移到回收站'**
  String get aiToolsOldFileBackedUp;

  /// No description provided for @aiToolsRestoreFromBackup.
  ///
  /// In zh, this message translates to:
  /// **'从备份恢复'**
  String get aiToolsRestoreFromBackup;

  /// No description provided for @aiToolsRestoreFromBackup2.
  ///
  /// In zh, this message translates to:
  /// **'从备份 {name} 恢复'**
  String aiToolsRestoreFromBackup2(Object name);

  /// No description provided for @aiToolsWillRestoreFiles.
  ///
  /// In zh, this message translates to:
  /// **'将恢复：{paths}（{files} 个文件，{bytes}）'**
  String aiToolsWillRestoreFiles(Object paths, Object files, Object bytes);

  /// No description provided for @aiToolsNoteBackupWasCreated.
  ///
  /// In zh, this message translates to:
  /// **'注意：这是旧版 Pixel World 创建的备份，没有签名，无法确认内容未被修改过'**
  String get aiToolsNoteBackupWasCreated;

  /// No description provided for @aiToolsItsExtractedTemporaryFolder.
  ///
  /// In zh, this message translates to:
  /// **'先解压到临时文件夹并校验，成功后才把当前的对应内容备份并移到回收站'**
  String get aiToolsItsExtractedTemporaryFolder;

  /// No description provided for @aiToolsInstall2.
  ///
  /// In zh, this message translates to:
  /// **'安装 {shown}'**
  String aiToolsInstall2(Object shown);

  /// No description provided for @aiToolsInstanceName.
  ///
  /// In zh, this message translates to:
  /// **'实例名称：{shown}'**
  String aiToolsInstanceName(Object shown);

  /// No description provided for @aiToolsDownloadsFromMayTake.
  ///
  /// In zh, this message translates to:
  /// **'从{useMirror}下载，可能需要几分钟；进度可以在任务页查看'**
  String aiToolsDownloadsFromMayTake(Object useMirror);

  /// No description provided for @aiToolsNoteHasNoIris.
  ///
  /// In zh, this message translates to:
  /// **'注意：{id} 中没有找到 Iris 或 OptiFine，光影包需要它们才能使用'**
  String aiToolsNoteHasNoIris(Object id);

  /// No description provided for @workspaceToolsViewAccessibleFolders.
  ///
  /// In zh, this message translates to:
  /// **'查看可访问的文件夹'**
  String get workspaceToolsViewAccessibleFolders;

  /// No description provided for @workspaceToolsViewFolder.
  ///
  /// In zh, this message translates to:
  /// **'查看目录'**
  String get workspaceToolsViewFolder;

  /// No description provided for @workspaceToolsView.
  ///
  /// In zh, this message translates to:
  /// **'查看 {rel}'**
  String workspaceToolsView(Object rel);

  /// No description provided for @workspaceToolsFindFiles.
  ///
  /// In zh, this message translates to:
  /// **'查找文件'**
  String get workspaceToolsFindFiles;

  /// No description provided for @workspaceToolsFind.
  ///
  /// In zh, this message translates to:
  /// **'在 {rel} 中查找 {pattern}'**
  String workspaceToolsFind(Object rel, Object pattern);

  /// No description provided for @workspaceToolsSearchFileContents.
  ///
  /// In zh, this message translates to:
  /// **'搜索文件内容'**
  String get workspaceToolsSearchFileContents;

  /// No description provided for @workspaceToolsSearch.
  ///
  /// In zh, this message translates to:
  /// **'在 {rel} 中搜索「{pattern}」'**
  String workspaceToolsSearch(Object rel, Object pattern);

  /// No description provided for @workspaceToolsReadFile.
  ///
  /// In zh, this message translates to:
  /// **'读取文件'**
  String get workspaceToolsReadFile;

  /// No description provided for @workspaceToolsWriteFile.
  ///
  /// In zh, this message translates to:
  /// **'写入文件'**
  String get workspaceToolsWriteFile;

  /// No description provided for @workspaceToolsLines.
  ///
  /// In zh, this message translates to:
  /// **'{length}，{count} 行'**
  String workspaceToolsLines(Object length, Object count);

  /// No description provided for @workspaceToolsOriginalFileWillReplaced.
  ///
  /// In zh, this message translates to:
  /// **'原文件会被替换'**
  String get workspaceToolsOriginalFileWillReplaced;

  /// No description provided for @workspaceToolsEditFile.
  ///
  /// In zh, this message translates to:
  /// **'修改文件'**
  String get workspaceToolsEditFile;

  /// No description provided for @workspaceToolsEdit.
  ///
  /// In zh, this message translates to:
  /// **'修改 {rel}{count}'**
  String workspaceToolsEdit(Object rel, Object count);

  /// No description provided for @workspaceToolsOriginal.
  ///
  /// In zh, this message translates to:
  /// **'原文：\n{oldText}'**
  String workspaceToolsOriginal(Object oldText);

  /// No description provided for @workspaceToolsChange.
  ///
  /// In zh, this message translates to:
  /// **'改为：\n{newText}'**
  String workspaceToolsChange(Object newText);

  /// No description provided for @workspaceToolsMoveFile.
  ///
  /// In zh, this message translates to:
  /// **'移动文件'**
  String get workspaceToolsMoveFile;

  /// No description provided for @workspaceToolsMove.
  ///
  /// In zh, this message translates to:
  /// **'把 {rel} 移动到 {rel2}'**
  String workspaceToolsMove(Object rel, Object rel2);

  /// No description provided for @workspaceToolsDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除 {rel}'**
  String workspaceToolsDelete(Object rel);

  /// No description provided for @workspaceToolsWholeFolderItsContents.
  ///
  /// In zh, this message translates to:
  /// **'整个文件夹及其中的内容'**
  String get workspaceToolsWholeFolderItsContents;

  /// No description provided for @workspaceToolsFile.
  ///
  /// In zh, this message translates to:
  /// **'文件，{lengthSync}'**
  String workspaceToolsFile(Object lengthSync);

  /// No description provided for @workspaceToolsMovedRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'会移到回收站'**
  String get workspaceToolsMovedRecycleBin;

  /// No description provided for @webToolsSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索「{q}」'**
  String webToolsSearch(Object q);

  /// No description provided for @webToolsOpenWebPage.
  ///
  /// In zh, this message translates to:
  /// **'打开网页'**
  String get webToolsOpenWebPage;

  /// No description provided for @webToolsOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开 {host}{path}'**
  String webToolsOpen(Object host, Object path);

  /// No description provided for @webToolsSearchMinecraftWiki.
  ///
  /// In zh, this message translates to:
  /// **'搜索 Minecraft Wiki'**
  String get webToolsSearchMinecraftWiki;

  /// No description provided for @webToolsSearchMinecraftWiki2.
  ///
  /// In zh, this message translates to:
  /// **'在 Minecraft Wiki 中搜索「{q}」'**
  String webToolsSearchMinecraftWiki2(Object q);

  /// No description provided for @aiClientQwen.
  ///
  /// In zh, this message translates to:
  /// **'通义千问'**
  String get aiClientQwen;

  /// No description provided for @aiClientOllamaLocal.
  ///
  /// In zh, this message translates to:
  /// **'Ollama（本机）'**
  String get aiClientOllamaLocal;

  /// No description provided for @aiClientEnterAPIAddressFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先填写接口地址'**
  String get aiClientEnterAPIAddressFirst;

  /// No description provided for @aiClientCouldntGetModelList.
  ///
  /// In zh, this message translates to:
  /// **'获取模型列表失败：{s}'**
  String aiClientCouldntGetModelList(Object s);

  /// No description provided for @aiClientCantConnect.
  ///
  /// In zh, this message translates to:
  /// **'无法连接 {host}：{message}'**
  String aiClientCantConnect(Object host, Object message);

  /// No description provided for @aiClientSecureConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'与 {host} 的安全连接失败'**
  String aiClientSecureConnectionFailed(Object host);

  /// No description provided for @aiClientAPIDidntReturnModel.
  ///
  /// In zh, this message translates to:
  /// **'接口返回的不是模型列表，请检查接口地址'**
  String get aiClientAPIDidntReturnModel;

  /// No description provided for @aiClientConnectionTimedOut.
  ///
  /// In zh, this message translates to:
  /// **'连接 {host} 超时'**
  String aiClientConnectionTimedOut(Object host);

  /// No description provided for @aiClientModelRefusedAnswerRequest.
  ///
  /// In zh, this message translates to:
  /// **'模型拒绝回答这个请求'**
  String get aiClientModelRefusedAnswerRequest;

  /// No description provided for @aiClientModelReturnedNothingCheck.
  ///
  /// In zh, this message translates to:
  /// **'模型没有返回内容，请检查接口地址和模型名'**
  String get aiClientModelReturnedNothingCheck;

  /// No description provided for @aiClientAnswerHitLengthLimit.
  ///
  /// In zh, this message translates to:
  /// **'\n\n（回答达到长度上限，已截断）'**
  String get aiClientAnswerHitLengthLimit;

  /// No description provided for @aiClientConnectionWasInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'与 {host} 的连接中断：{message}'**
  String aiClientConnectionWasInterrupted(Object host, Object message);

  /// No description provided for @aiClientSecureConnectionFailedCheck.
  ///
  /// In zh, this message translates to:
  /// **'与 {host} 的安全连接失败，请检查接口地址或网络代理'**
  String aiClientSecureConnectionFailedCheck(Object host);

  /// No description provided for @aiClientHasntRespondedLongTime.
  ///
  /// In zh, this message translates to:
  /// **'{host} 长时间没有响应，请稍后重试'**
  String aiClientHasntRespondedLongTime(Object host);

  /// No description provided for @aiClientConversationLongerThanModel.
  ///
  /// In zh, this message translates to:
  /// **'对话内容超出了模型能处理的长度，请点对话上方的「压缩上下文」按钮，或新建一个对话'**
  String get aiClientConversationLongerThanModel;

  /// No description provided for @aiClientModelDoesntExistIsnt.
  ///
  /// In zh, this message translates to:
  /// **'模型「{model}」不存在或不可用，请检查模型名，或点模型旁的按钮获取可用的模型'**
  String aiClientModelDoesntExistIsnt(Object model);

  /// No description provided for @aiClientInsufficientBalanceQuotaTop.
  ///
  /// In zh, this message translates to:
  /// **'账户余额或额度不足，请到服务商的控制台充值或检查额度'**
  String get aiClientInsufficientBalanceQuotaTop;

  /// No description provided for @aiClientAIServiceOverloadedPlease.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务当前过载，请稍后重试'**
  String get aiClientAIServiceOverloadedPlease;

  /// No description provided for @aiClientRequestRejectedModelProvider.
  ///
  /// In zh, this message translates to:
  /// **'请求被拒绝，可能是这个模型或服务商不支持当前的请求方式'**
  String get aiClientRequestRejectedModelProvider;

  /// No description provided for @aiClientAPIKeyInvalidExpired.
  ///
  /// In zh, this message translates to:
  /// **'API Key 无效或已过期，请在设置中检查'**
  String get aiClientAPIKeyInvalidExpired;

  /// No description provided for @aiClientNoPermissionUseModel.
  ///
  /// In zh, this message translates to:
  /// **'没有权限使用这个模型或接口，请检查账户权限或地区限制'**
  String get aiClientNoPermissionUseModel;

  /// No description provided for @aiClientAPIAddressModelDoesnt.
  ///
  /// In zh, this message translates to:
  /// **'接口地址或模型不存在，请检查接口地址（OpenAI 兼容接口通常以 /v1 结尾）'**
  String get aiClientAPIAddressModelDoesnt;

  /// No description provided for @aiClientAIServiceTimedOut.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务响应超时，请稍后重试'**
  String get aiClientAIServiceTimedOut;

  /// No description provided for @aiClientContentSentTooLong.
  ///
  /// In zh, this message translates to:
  /// **'发送的内容太长，请新建一个对话'**
  String get aiClientContentSentTooLong;

  /// No description provided for @aiClientTooManyRequestsPlease.
  ///
  /// In zh, this message translates to:
  /// **'请求太频繁，请稍后再试'**
  String get aiClientTooManyRequestsPlease;

  /// No description provided for @aiClientAIServiceTemporarilyUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务暂时不可用，请稍后重试'**
  String get aiClientAIServiceTemporarilyUnavailable;

  /// No description provided for @aiClientRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（{code}）：{raw}'**
  String aiClientRequestFailed(Object code, Object raw);

  /// No description provided for @aiClientNoDetailsReturned.
  ///
  /// In zh, this message translates to:
  /// **'没有返回说明'**
  String get aiClientNoDetailsReturned;

  /// No description provided for @mcpClientExaSearch.
  ///
  /// In zh, this message translates to:
  /// **'Exa 搜索'**
  String get mcpClientExaSearch;

  /// No description provided for @mcpClientInvalidURL.
  ///
  /// In zh, this message translates to:
  /// **'网址无效'**
  String get mcpClientInvalidURL;

  /// No description provided for @mcpClientOnlyHttpHttpsSupported.
  ///
  /// In zh, this message translates to:
  /// **'只支持 http / https'**
  String get mcpClientOnlyHttpHttpsSupported;

  /// No description provided for @mcpClientRemoteServicesMustUse.
  ///
  /// In zh, this message translates to:
  /// **'远程服务请使用 https；http 只能连接本机（127.0.0.1 / localhost）'**
  String get mcpClientRemoteServicesMustUse;

  /// No description provided for @mcpClientServiceReturnedError.
  ///
  /// In zh, this message translates to:
  /// **'服务返回错误：{err}'**
  String mcpClientServiceReturnedError(Object err);

  /// No description provided for @mcpClientAccessDeniedCheckAccess.
  ///
  /// In zh, this message translates to:
  /// **'访问被拒绝，检查访问令牌'**
  String get mcpClientAccessDeniedCheckAccess;

  /// No description provided for @mcpClientWrongAddressServiceClosed.
  ///
  /// In zh, this message translates to:
  /// **'地址不对，或服务已经关闭了这个会话'**
  String get mcpClientWrongAddressServiceClosed;

  /// No description provided for @mcpClientResponseTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'响应太大'**
  String get mcpClientResponseTooLarge;

  /// No description provided for @mcpClientMalformedResponse.
  ///
  /// In zh, this message translates to:
  /// **'响应格式不对'**
  String get mcpClientMalformedResponse;

  /// No description provided for @mcpClientTimedOutWaitingService.
  ///
  /// In zh, this message translates to:
  /// **'等待服务响应超时'**
  String get mcpClientTimedOutWaitingService;

  /// No description provided for @mcpClientServicesResponseIsntValid.
  ///
  /// In zh, this message translates to:
  /// **'服务的响应不是有效的 JSON'**
  String get mcpClientServicesResponseIsntValid;

  /// No description provided for @mcpClientCantReachService.
  ///
  /// In zh, this message translates to:
  /// **'连不上服务：{message}'**
  String mcpClientCantReachService(Object message);

  /// No description provided for @mcpClientConnectionError.
  ///
  /// In zh, this message translates to:
  /// **'连接出错：{message}'**
  String mcpClientConnectionError(Object message);

  /// No description provided for @mcpClientServiceDisconnectedWithoutResponding.
  ///
  /// In zh, this message translates to:
  /// **'服务没有返回响应就断开了'**
  String get mcpClientServiceDisconnectedWithoutResponding;

  /// No description provided for @mcpClientServiceProcessHasExited.
  ///
  /// In zh, this message translates to:
  /// **'服务进程已经退出'**
  String get mcpClientServiceProcessHasExited;

  /// No description provided for @mcpClientServiceProcessHasExited2.
  ///
  /// In zh, this message translates to:
  /// **'服务进程已经退出（退出代码 {code}）'**
  String mcpClientServiceProcessHasExited2(Object code);

  /// No description provided for @mcpClientPixelWorldDoesntSupport.
  ///
  /// In zh, this message translates to:
  /// **'Pixel World 不支持这个请求'**
  String get mcpClientPixelWorldDoesntSupport;

  /// No description provided for @mcpClientServiceProvidesNoTools.
  ///
  /// In zh, this message translates to:
  /// **'这个服务没有提供工具'**
  String get mcpClientServiceProvidesNoTools;

  /// No description provided for @mcpHubAskEveryTime.
  ///
  /// In zh, this message translates to:
  /// **'每次询问'**
  String get mcpHubAskEveryTime;

  /// No description provided for @mcpHubReadOnlyRejectChanges.
  ///
  /// In zh, this message translates to:
  /// **'只读（直接拒绝修改）'**
  String get mcpHubReadOnlyRejectChanges;

  /// No description provided for @mcpHubCall.
  ///
  /// In zh, this message translates to:
  /// **'调用「{name}」的 {name2}'**
  String mcpHubCall(Object name, Object name2);

  /// No description provided for @mcpHubServiceDeclaresToolRead.
  ///
  /// In zh, this message translates to:
  /// **'服务声明这个工具只读取，不做修改'**
  String get mcpHubServiceDeclaresToolRead;

  /// No description provided for @mcpHubArguments.
  ///
  /// In zh, this message translates to:
  /// **'参数：{shown}'**
  String mcpHubArguments(Object shown);

  /// No description provided for @mcpHubExited.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get mcpHubExited;

  /// No description provided for @mcpHubUnreachable.
  ///
  /// In zh, this message translates to:
  /// **'连不上'**
  String get mcpHubUnreachable;

  /// No description provided for @mcpHubLocalJarServicesCant.
  ///
  /// In zh, this message translates to:
  /// **'安卓上暂时还不能运行本机 jar 服务，可以改用远程（HTTP）服务'**
  String get mcpHubLocalJarServicesCant;

  /// No description provided for @mcpHubJarFileNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到 jar 文件：{jar}'**
  String mcpHubJarFileNotFound(Object jar);

  /// No description provided for @mcpHubPrepareJavaMCPService.
  ///
  /// In zh, this message translates to:
  /// **'准备 MCP 服务的 Java'**
  String get mcpHubPrepareJavaMCPService;

  /// No description provided for @aiChatModelReturnedNoSummary.
  ///
  /// In zh, this message translates to:
  /// **'模型没有返回摘要'**
  String get aiChatModelReturnedNoSummary;

  /// No description provided for @aiChatCouldntCompactContext.
  ///
  /// In zh, this message translates to:
  /// **'压缩上下文失败：{e}'**
  String aiChatCouldntCompactContext(Object e);

  /// No description provided for @aiChatTooManyActionsRound.
  ///
  /// In zh, this message translates to:
  /// **'这一轮的操作次数过多，已暂停。可以发送消息让 AI 继续'**
  String get aiChatTooManyActionsRound;

  /// No description provided for @aiChatAnswerInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'{partial}\n\n（回答中断）'**
  String aiChatAnswerInterrupted(Object partial);

  /// No description provided for @aiChatNoToolsAvailable.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的工具'**
  String get aiChatNoToolsAvailable;

  /// No description provided for @aiChatStopped.
  ///
  /// In zh, this message translates to:
  /// **'{partial}\n\n（已停止）'**
  String aiChatStopped(Object partial);

  /// No description provided for @agentRootCurrentInstance.
  ///
  /// In zh, this message translates to:
  /// **'当前实例（{id}）'**
  String agentRootCurrentInstance(Object id);

  /// No description provided for @agentRootDownloads.
  ///
  /// In zh, this message translates to:
  /// **'下载目录'**
  String get agentRootDownloads;

  /// No description provided for @aiPromptMyGameCrashedBelow.
  ///
  /// In zh, this message translates to:
  /// **'我的游戏崩溃了，下面是启动器收集的崩溃信息，请帮我分析原因并告诉我怎么解决。'**
  String get aiPromptMyGameCrashedBelow;

  /// 告诉 AI 用什么语言回答（写进系统提示），跟随界面语言
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get aiReplyLanguage;

  /// 列举时的分隔符（A、B、C）
  ///
  /// In zh, this message translates to:
  /// **'、'**
  String get commonListSeparator;

  /// No description provided for @commonClauseSeparator.
  ///
  /// In zh, this message translates to:
  /// **'；'**
  String get commonClauseSeparator;

  /// No description provided for @commonComma.
  ///
  /// In zh, this message translates to:
  /// **'，'**
  String get commonComma;

  /// No description provided for @commonColon.
  ///
  /// In zh, this message translates to:
  /// **'：'**
  String get commonColon;

  /// 括号补充说明，中文用全角括号
  ///
  /// In zh, this message translates to:
  /// **'（{text}）'**
  String commonParenthesized(Object text);

  /// No description provided for @aiSearchEngineAuto.
  ///
  /// In zh, this message translates to:
  /// **'内置（Exa，失败时 DuckDuckGo、必应）'**
  String get aiSearchEngineAuto;

  /// No description provided for @aiSearchEngineExa.
  ///
  /// In zh, this message translates to:
  /// **'Exa（Key 可以不填）'**
  String get aiSearchEngineExa;

  /// No description provided for @aiSearchEngineBing.
  ///
  /// In zh, this message translates to:
  /// **'必应（英文结果更可靠）'**
  String get aiSearchEngineBing;

  /// No description provided for @aiSearchEngineSearxng.
  ///
  /// In zh, this message translates to:
  /// **'SearXNG（自建或公共实例）'**
  String get aiSearchEngineSearxng;

  /// No description provided for @aiSearchEngineTavily.
  ///
  /// In zh, this message translates to:
  /// **'Tavily（需要 Key）'**
  String get aiSearchEngineTavily;

  /// No description provided for @aiSearchEngineBrave.
  ///
  /// In zh, this message translates to:
  /// **'Brave Search（需要 Key）'**
  String get aiSearchEngineBrave;

  /// No description provided for @aiSearchEngineSerper.
  ///
  /// In zh, this message translates to:
  /// **'Serper / Google（需要 Key）'**
  String get aiSearchEngineSerper;

  /// 加载器版本列表获取失败（连不上服务器），点一下重试；手机上要短
  ///
  /// In zh, this message translates to:
  /// **'连不上 · 重试'**
  String get downloadLoadFailedRetry;

  /// No description provided for @precheckOwnershipRequired.
  ///
  /// In zh, this message translates to:
  /// **'为了正版验证，需要先登录一次购买了 Minecraft 的微软账户，才能使用离线账户和外置登录。'**
  String get precheckOwnershipRequired;

  /// No description provided for @launchDialogsVerifyOwnershipFirst.
  ///
  /// In zh, this message translates to:
  /// **'需要先验证正版'**
  String get launchDialogsVerifyOwnershipFirst;

  /// No description provided for @launchDialogsOwnershipRequiredBody.
  ///
  /// In zh, this message translates to:
  /// **'Minecraft 是付费游戏。按照 Mojang 的规定，需要先登录一次购买了 Minecraft 的微软账户，才能用离线账户或外置登录开始游戏。\n\n验证一次之后，离线账户和外置登录就可以一直使用了。'**
  String get launchDialogsOwnershipRequiredBody;

  /// No description provided for @launchDialogsBuyGame.
  ///
  /// In zh, this message translates to:
  /// **'去购买'**
  String get launchDialogsBuyGame;

  /// No description provided for @launchDialogsSignInMicrosoft.
  ///
  /// In zh, this message translates to:
  /// **'登录微软账户'**
  String get launchDialogsSignInMicrosoft;

  /// No description provided for @oobeAccountHintVerified.
  ///
  /// In zh, this message translates to:
  /// **'玩正版用微软账户，也可以用离线账户或外置登录。'**
  String get oobeAccountHintVerified;

  /// No description provided for @oobeAccountHintUnverified.
  ///
  /// In zh, this message translates to:
  /// **'为了正版验证，请先登录购买了 Minecraft 的微软账户，之后也能用离线账户和外置登录。'**
  String get oobeAccountHintUnverified;

  /// No description provided for @oobeAvailableAfterVerification.
  ///
  /// In zh, this message translates to:
  /// **'验证正版后可用'**
  String get oobeAvailableAfterVerification;

  /// No description provided for @accountsOwnershipNotice.
  ///
  /// In zh, this message translates to:
  /// **'说明：为了正版验证，离线账户和外置登录需要先登录一次拥有 Minecraft 的微软账户，确认你购买了游戏后才能添加和使用。'**
  String get accountsOwnershipNotice;

  /// No description provided for @touchTipTitle.
  ///
  /// In zh, this message translates to:
  /// **'试试 TouchController'**
  String get touchTipTitle;

  /// No description provided for @touchTipBody.
  ///
  /// In zh, this message translates to:
  /// **'TouchController 是第三方模组，给 Java 版带来基岩版风格的触屏操作，按键布局可以自己调整。它还在早期开发阶段，可能会遇到问题。\n\n装进「{instance}」后，下次启动时启动器会把游戏内的触摸交给它，并隐藏自带的虚拟按键；想换回来，在模组里禁用它就行。'**
  String touchTipBody(Object instance);

  /// No description provided for @touchTipInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装'**
  String get touchTipInstall;

  /// No description provided for @touchTipNever.
  ///
  /// In zh, this message translates to:
  /// **'不再推荐'**
  String get touchTipNever;

  /// No description provided for @touchTipInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已为 {instance} 安装 TouchController，下次启动生效'**
  String touchTipInstalled(Object instance);
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
