// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAuto => 'Auto';

  @override
  String get commonCustom => 'Custom';

  @override
  String get commonDefault => 'Default';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDownload => 'Download';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonView => 'View';

  @override
  String commonDeleteFailed(String error) {
    return 'Couldn\'t delete: $error';
  }

  @override
  String get navHome => 'Play';

  @override
  String get navDownload => 'Download';

  @override
  String get navTools => 'Tools';

  @override
  String get navFiles => 'Files';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAiAssistant => 'AI Assistant';

  @override
  String get subVersions => 'Instances';

  @override
  String get subLog => 'Game Log';

  @override
  String get subInstance => 'Instance Details';

  @override
  String get subTasks => 'Tasks';

  @override
  String get subDiagnose => 'Crash Analysis';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipInstances => 'Instances';

  @override
  String get tooltipNotices => 'Announcements';

  @override
  String get greetingLateNight => 'Up late';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingNoon => 'Good afternoon';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get greetingAdventure => 'Ready for an adventure?';

  @override
  String get tasksIdle => 'No background tasks';

  @override
  String tasksGamesRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games running',
      one: '1 game running',
    );
    return '$_temp0';
  }

  @override
  String tasksMore(String title, int count) {
    return '$title · $count tasks';
  }

  @override
  String get accountAdd => 'Add account';

  @override
  String get accountMicrosoft => 'Microsoft';

  @override
  String get accountOffline => 'Offline';

  @override
  String get accountExternal => 'External';

  @override
  String get windowMinimize => 'Minimize';

  @override
  String get windowMaximize => 'Maximize';

  @override
  String get windowRestore => 'Restore';

  @override
  String get windowClose => 'Close';

  @override
  String get comingSoon => 'This feature is still being migrated';

  @override
  String get settingsGroupGame => 'Game';

  @override
  String get settingsLaunch => 'Launch';

  @override
  String get settingsManage => 'Game Management';

  @override
  String get settingsGroupLauncher => 'Launcher';

  @override
  String get settingsAppearance => 'Personalization';

  @override
  String get settingsMisc => 'Other';

  @override
  String get settingsAiModel => 'Model & API';

  @override
  String get settingsAiTools => 'Tools & Services';

  @override
  String get settingsAiWorkspace => 'Workspace & Web';

  @override
  String get settingsGroupAbout => 'About';

  @override
  String get settingsAbout => 'About & Credits';

  @override
  String get settingsDocs => 'Documentation';

  @override
  String get settingsAiIntro =>
      'The AI assistant uses your own AI service. OpenAI-compatible APIs (DeepSeek, Qwen, Kimi, OpenRouter, local Ollama and more) and the Anthropic API are supported; usage is billed by your AI provider.';

  @override
  String get languageGroup => 'Language';

  @override
  String get language => 'Display language';

  @override
  String get languageHint => 'The language of the launcher; “Set game language automatically” follows it too';

  @override
  String get languageSystem => 'System default';

  @override
  String get colorMode => 'Color mode';

  @override
  String get colorModeHint => 'Light or dark appearance of the launcher';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get uiScale => 'Interface scale';

  @override
  String get uiScaleFixed => 'The whole launcher is shown at this scale';

  @override
  String uiScaleAuto(int percent) {
    return 'Auto: based on screen size, currently $percent%';
  }

  @override
  String get themeColor => 'Theme color';

  @override
  String get themeColorAuto =>
      'Follow background: colors are picked from the background image with Material Design 3 and update when the image changes';

  @override
  String get themeColorManual =>
      'A full light and dark palette is generated from the theme color with Material Design 3';

  @override
  String get themeFollowBackground => 'Follow background';

  @override
  String get themeManual => 'Choose manually';

  @override
  String get themeRecommended => 'Recommended';

  @override
  String themeCandidate(int index) {
    return 'Option $index';
  }

  @override
  String get homeGroup => 'Home';

  @override
  String get homeLayout => 'Home layout';

  @override
  String get homeLayoutStandard => 'Standard';

  @override
  String get homeLayoutSplit => 'Split';

  @override
  String get homeLayoutMinimal => 'Minimal';

  @override
  String get homeLayoutStandardHint => 'Standard: a large card, announcements and shortcuts, and recently played';

  @override
  String get homeLayoutSplitHint =>
      'Split: the current instance at the top, Play and worlds at the bottom, and the background in between; chosen automatically when you set a background image';

  @override
  String get homeLayoutMinimalHint => 'Minimal: a single bar at the bottom with the current instance and Play';

  @override
  String get homeLayoutStandardMobileHint =>
      'Standard: the original home page, without the background image; choose Split or Minimal to use a background image';

  @override
  String get homeHints => 'Show tips';

  @override
  String get homeHintsHint => 'The version in use and the free software notice';

  @override
  String get homeNews => 'Show Minecraft version news';

  @override
  String get homeNewsHint => 'The latest releases and snapshots, with summaries from the Chinese Minecraft Wiki';

  @override
  String get bgImage => 'Background image';

  @override
  String get bgImageFiles => 'Images';

  @override
  String bgImageInvalid(String error) {
    return 'Can\'t use this image: $error';
  }

  @override
  String get bgImageSet => 'Shown behind the whole window; panels turn into frosted glass';

  @override
  String get bgImageUnset => 'Choose an image as the launcher background; panels turn into frosted glass';

  @override
  String get bgImageInactive =>
      'The Standard home page doesn\'t show the background image; switch the home layout to Split or Minimal to use it';

  @override
  String get bgImageChange => 'Change…';

  @override
  String get bgImageChoose => 'Choose image…';

  @override
  String get bgImageRemove => 'Remove';

  @override
  String get bgFit => 'Image fit';

  @override
  String get bgFitFill => 'Fill';

  @override
  String get bgFitFit => 'Fit';

  @override
  String get bgFitStretch => 'Stretch';

  @override
  String get bgFitTile => 'Tile';

  @override
  String get bgFitCenter => 'Center';

  @override
  String get bgFitSpan => 'Span';

  @override
  String get bgFitFillHint => 'Fill: covers the whole window and crops the overflow';

  @override
  String get bgFitFitHint => 'Fit: shows the whole image and fills the gaps with its colors';

  @override
  String get bgFitStretchHint => 'Stretch: stretches to the window size; the image may be distorted';

  @override
  String get bgFitTileHint => 'Tile: repeats the image at its original size to fill the window';

  @override
  String get bgFitCenterHint => 'Center: places the image at its original size in the middle of the window';

  @override
  String get bgFitSpanHint =>
      'Span: the image covers the whole desktop (all screens) and the window shows only its own part, so the background stays put when you move the window';

  @override
  String get bgBlur => 'Background blur';

  @override
  String get bgBlurHint => 'How blurred the whole background image is; 0 keeps it sharp';

  @override
  String get bgDim => 'Background dimming';

  @override
  String get bgDimDarkHint =>
      'Lays black over the image; turn it up for bright or busy images to make the interface and text clearer';

  @override
  String get bgDimLightHint =>
      'Lays white over the image; turn it up for dark or busy images to make the interface and text clearer';

  @override
  String get bgPanelBlur => 'Panel blur';

  @override
  String get bgPanelBlurHint =>
      'Blurs only what is behind the panels (frosted glass), independently of the background blur; 0 keeps it sharp';

  @override
  String get bgOpacity => 'Panel opacity';

  @override
  String get bgOpacityHint => 'The more transparent the panels, the more the background shows through';

  @override
  String get bgGlow => 'Cover glow';

  @override
  String get bgGlowHint => 'How far the colors taken from cover art spread out on recently played cards';

  @override
  String get bgSolid => 'Reduce transparency';

  @override
  String get bgSolidHint =>
      'Keeps the background image but makes panels almost opaque, for busy images or clearer text';

  @override
  String get helpGroup => 'Help';

  @override
  String get helpTour => 'Guided tour';

  @override
  String get helpTourHint =>
      'Walk through the launcher again: accounts, installing games, instances, playing, tools and settings';

  @override
  String get helpTourStart => 'Start';

  @override
  String get helpTerms => 'Terms of use';

  @override
  String get helpTermsHint => 'Usage rules, third-party content and disclaimers';

  @override
  String get helpPrivacy => 'Privacy notice';

  @override
  String get helpPrivacyHint =>
      'Nothing about you is collected; what is stored locally and which services are contacted';

  @override
  String get aboutDeveloper => 'Developer of Pixel World';

  @override
  String get aboutSponsor => 'Sponsor the author';

  @override
  String aboutAppVersion(String version) {
    return 'Pixel World Launcher $version';
  }

  @override
  String get aboutDisclaimer =>
      'Pixel World is a third-party Minecraft launcher. This project makes light use of the PCL repository, and its layout is based on PCL Community Edition (PCL-CE). PCL is developed by LTCat (龙腾猫跃). This software is not affiliated with PCL or its author and does not represent PCL. Please don\'t contact the PCL author about issues with this software. This software is not an official product of Mojang or Microsoft and is not endorsed by or affiliated with them; Minecraft is a trademark of Mojang Synergies AB.';

  @override
  String get aboutSource => 'Source code';

  @override
  String get aboutSourceHint => 'Pixel World is open source under the Apache-2.0 license';

  @override
  String get aboutGuide => 'PCL Repository Fair Use Guide';

  @override
  String get aboutGuideHint =>
      'The naming, attribution and usage rules this project follows, published with the source code';

  @override
  String get aboutCredits => 'Credits';

  @override
  String get aboutPclCeHint =>
      'The developers of PCL Community Edition (PCL-CE); this software is data-compatible with PCL-CE';

  @override
  String get aboutAndroidRuntime => 'Android game runtime';

  @override
  String get aboutAndroidRuntimeHint =>
      'Based on Amethyst-Android (LGPL-3.0), MobileGlues, Krypton Wrapper, LWJGL and OpenJDK; separately open source under LGPL-3.0';

  @override
  String get aboutFlutterHint => 'Cross-platform UI framework';

  @override
  String get aboutMaterialHint => 'Design language and color algorithm';

  @override
  String get aboutTrademark =>
      'Minecraft is a trademark of Mojang Studios. This software is not an official Minecraft product and is not approved by or associated with Mojang or Microsoft.';

  @override
  String renderScale(int percent) {
    return 'Render scale: $percent%';
  }

  @override
  String renderScaleHint(int width, int height) {
    return 'Game resolution $width × $height. Lower values look blurrier but give higher frame rates and less heat';
  }

  @override
  String get renderer => 'Renderer';

  @override
  String rendererGpu(String gpu) {
    return 'GPU: $gpu';
  }

  @override
  String rendererAuto(String renderer, String reason) {
    return 'Will use: $renderer ($reason)';
  }

  @override
  String get rendererPerInstance => 'You can pick a different renderer for a single instance in its settings';

  @override
  String get isolation => 'Instance isolation';

  @override
  String get isolationHint => 'Applied when a new instance first launches; change it per instance afterwards';

  @override
  String get isolationOff => 'Off';

  @override
  String get isolationModable => 'Isolate instances that can load mods';

  @override
  String get isolationUnstable => 'Isolate non-release versions';

  @override
  String get isolationModableUnstable => 'Isolate modded instances and non-release versions';

  @override
  String get isolationAll => 'Isolate all instances';

  @override
  String get gameHud => 'In-game overlay';

  @override
  String get gameHudHint => 'Shows a draggable bubble over the game; tap it for basic info or to ask AI';

  @override
  String get gameHudAi => 'In-game AI';

  @override
  String get gameHudAiHint => 'Shows “Ask AI” in the bubble menu, using the API and model from Settings → AI';

  @override
  String get gameHudAiLog => 'Attach recent logs to questions';

  @override
  String get gameHudAiLogHint =>
      'Sends the end of the game log to the AI to help diagnose crashes; logs may contain server addresses and chat messages';

  @override
  String get gameWindow => 'Game window';

  @override
  String get gameWindowDefault => 'Default (854 × 480)';

  @override
  String get gameWindowLauncher => 'Same as launcher';

  @override
  String get gameWindowMaximized => 'Maximized';

  @override
  String get gameWindowFullscreen => 'Full screen';

  @override
  String get gameWindowCustom => 'Custom size';

  @override
  String get gameWindowWidth => 'Window width';

  @override
  String get gameWindowHeight => 'Window height';

  @override
  String get afterLaunch => 'After the game starts';

  @override
  String get afterLaunchKeep => 'Do nothing';

  @override
  String get afterLaunchMinimize => 'Minimize, restore when the game exits';

  @override
  String get afterLaunchHide => 'Hide, restore when the game exits';

  @override
  String get afterLaunchHideExit => 'Hide, close when the game exits';

  @override
  String get afterLaunchExit => 'Close the launcher';

  @override
  String get priority => 'Process priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityAboveNormal => 'Above normal';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityBelowNormal => 'Below normal';

  @override
  String get versionType => 'Version type label';

  @override
  String get versionTypeHint => 'Shown in the bottom-left corner of the game\'s title screen; leave empty to hide';

  @override
  String get autoGameLanguage => 'Set game language automatically';

  @override
  String get autoGameLanguageHint =>
      'For new instances or ones without worlds, set the game language to match the launcher';

  @override
  String get memory => 'Game memory';

  @override
  String get memoryMode => 'Allocation';

  @override
  String memorySummary(String allocated, String free, String total) {
    return '$allocated GB will be allocated · $free / $total GB free';
  }

  @override
  String get memoryLock => 'Lock memory';

  @override
  String get memoryLockHint => 'Initial memory equals maximum memory (-Xms equals -Xmx)';

  @override
  String get advanced => 'Advanced';

  @override
  String get jvmArgs => 'JVM arguments';

  @override
  String get gameArgs => 'Game arguments';

  @override
  String get preLaunchCommand => 'Run a command before launch';

  @override
  String get preLaunchCommandHint => 'Runs in the game folder';

  @override
  String get preLaunchWait => 'Wait for the command to finish before launching';

  @override
  String get ipStack => 'Network protocol preference';

  @override
  String get ipStackV4 => 'Prefer IPv4';

  @override
  String get ipStackV6 => 'Prefer IPv6';

  @override
  String get gpuPreference => 'Use the high-performance GPU';

  @override
  String get gpuPreferenceHint => 'Windows only: makes Java use the discrete GPU';

  @override
  String get javaUnusable => 'Can\'t run this Java';

  @override
  String get javaAuto => 'Automatic';

  @override
  String get javaAutoHint => 'Chosen to match each version; Mojang\'s Java is downloaded when none fits';

  @override
  String javaEntry(int major, String version) {
    return 'Java $major ($version)';
  }

  @override
  String get javaManaged => 'Downloaded by launcher';

  @override
  String get javaManual => 'Custom path';

  @override
  String get javaPick => 'Browse…';

  @override
  String get javaRescan => 'Rescan';

  @override
  String get javaPerInstance => 'Each instance can set its own Java in its settings, which overrides this.';

  @override
  String get javaAndroidAutoHint => 'Chooses Java 8 / 17 / 21 / 25 to match each version and downloads it when missing';

  @override
  String javaAndroidTask(int major) {
    return 'Download Java $major (Android)';
  }

  @override
  String javaDownloadFailed(int major, String error) {
    return 'Couldn\'t download Java $major: $error';
  }

  @override
  String javaDeleteTitle(int major) {
    return 'Delete Java $major?';
  }

  @override
  String get javaDeleteBody =>
      'It will be downloaded again when needed. Instances set to use it need to pick another Java or switch to automatic.';

  @override
  String javaInstalled(String size) {
    return 'Installed · $size';
  }

  @override
  String get javaNotInstalled => 'Not installed';

  @override
  String get javaInUse => 'Can\'t delete while a game or task is running';

  @override
  String get javaManualAndroid => 'Custom path (not available on Android)';

  @override
  String get javaAndroidNote =>
      'Android Java comes from AngelAuraMC\'s OpenJDK builds (GPLv2 + Classpath Exception). Each instance can set its own Java in its settings, which overrides this.';

  @override
  String get updates => 'Updates';

  @override
  String get updateChannel => 'Update channel';

  @override
  String get updateChannelHint =>
      'Stable is the most reliable; Preview includes pre-releases; Nightly follows every change on main and may be unstable';

  @override
  String get updateChannelStable => 'Stable';

  @override
  String get updateChannelPreview => 'Preview';

  @override
  String get updateAutoCheck => 'Check for updates on startup';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String get updateCheckButton => 'Check';

  @override
  String updateCurrentLocal(String version) {
    return 'Current version $version (local build)';
  }

  @override
  String updateCurrentBuild(String version, String channel, String commit) {
    return 'Current version $version ($channel, $commit)';
  }

  @override
  String get pclImport => 'Import from PCL-CE';

  @override
  String get pclImportHint =>
      'Imports launch settings, game folders and accounts; per-instance settings are shared as is';

  @override
  String get pclImportButton => 'Import';

  @override
  String get system => 'System';

  @override
  String get shortcut => 'Create desktop shortcut';

  @override
  String get shortcutHint => 'Adds a launcher shortcut to the desktop';

  @override
  String get shortcutButton => 'Create';

  @override
  String get downloadSource => 'Download source';

  @override
  String get downloadSourceAuto => 'Automatic';

  @override
  String get downloadSourceOfficial => 'Official';

  @override
  String get downloadSourceMirror => 'BMCLAPI mirror';

  @override
  String get downloadSourceAutoHint =>
      'Picks whichever of the official source and the BMCLAPI mirror is faster, and switches to the other on failure';

  @override
  String get downloadSourceOfficialHint => 'Only uses the official servers of Mojang and each mod loader';

  @override
  String get downloadSourceMirrorHint => 'Prefers the BMCLAPI mirror and falls back to the official source on failure';

  @override
  String downloadSourceCurrent(String source) {
    return ' (currently $source)';
  }

  @override
  String get networkCheck => 'Network check';

  @override
  String get networkCheckHint =>
      'Tests whether the download sources, Microsoft sign-in, Modrinth and the update service can be reached, and how fast';

  @override
  String get networkCheckStart => 'Run check';

  @override
  String get downloadConcurrency => 'Simultaneous downloads';

  @override
  String get msLogin => 'Microsoft sign-in';

  @override
  String get msClientId => 'Azure app client ID';

  @override
  String get msClientIdHint =>
      'Microsoft sign-in needs an Azure public client app; leave empty to use the launcher\'s built-in client ID';

  @override
  String get msClientIdEmpty => 'Not set';

  @override
  String get msClientIdBuiltIn => 'Leave empty to use the built-in client ID';

  @override
  String get oobeWelcome => 'Welcome';

  @override
  String get oobeAppearance => 'Appearance';

  @override
  String get oobeGameFolder => 'Game folder';

  @override
  String get oobeNetwork => 'Network';

  @override
  String get oobeAccount => 'Account';

  @override
  String get oobeDone => 'Done';

  @override
  String oobeImportedFromPCLCE(Object folders, Object accounts) {
    return 'Imported from PCL-CE: $folders game folders, $accounts accounts';
  }

  @override
  String oobeCouldntImportFromPCL(Object e) {
    return 'Couldn\'t import from PCL-CE: $e';
  }

  @override
  String get oobeAbout1Minute => 'About 1 minute';

  @override
  String get oobe6StepsAbout1 => '6 steps, about 1 minute';

  @override
  String get oobeAcceptAgreementContinue => 'Accept the agreement to continue';

  @override
  String get oobeYouCanChangeAll => 'You can change all of this later in Settings';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDeclineQuit => 'Decline and quit';

  @override
  String get oobeInstallYourFirstInstance => 'Install your first instance';

  @override
  String get oobeOpenLauncher => 'Open the launcher';

  @override
  String get oobeStartSetup => 'Start setup';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNext => 'Next';

  @override
  String get commonWelcomePixelWorld => 'Welcome to Pixel World';

  @override
  String get oobeFreeOpenSourceMinecraft =>
      'A free, open-source Minecraft launcher. Take a minute or two to set a few things up; you can change them later in Settings.';

  @override
  String get oobeInstallManage => 'Install and manage';

  @override
  String get oobeVanillaEveryModLoader =>
      'Vanilla and every mod loader. One version can have several instances, each with its own mods and worlds.';

  @override
  String get oobeModsResources => 'Mods and resources';

  @override
  String get oobeFindModsModpacksResource => 'Find mods, modpacks, resource packs and shaders right in the launcher.';

  @override
  String get oobeAITroubleshooting => 'AI troubleshooting';

  @override
  String get oobeGameCrashedLetAI => 'Game crashed? Let AI read the logs and find the cause.';

  @override
  String get commonTermsUsePrivacyNotice => 'Terms of use and privacy notice';

  @override
  String get oobeBeforeYouContinuePlease => 'Before you continue, please read and accept the two documents below.';

  @override
  String get oobeSoftwareFreeOpenSource =>
      '· This software is free and open source and provided as is; it is not an official product of Mojang, Microsoft or PCL.\n· We don\'t collect your information; accounts and settings stay on your device.\n· Games, mods and other content come from third parties, and downloads connect to them directly.';

  @override
  String get oobeIHaveReadAccept => 'I have read and accept the Terms of use and the Privacy notice';

  @override
  String get oobePickLookYouLike =>
      'Pick a look you like. On phones, Standard is the original home page; the background image only shows in Split and Minimal.';

  @override
  String get oobePickLookYouLike2 => 'Pick a look you like.';

  @override
  String get oobeLightDarkLauncherAppearance => 'Light or dark launcher appearance';

  @override
  String get oobeSelectedPanelsBecomeFrosted =>
      'Selected · panels become frosted glass and the theme color follows the image';

  @override
  String get oobeOptionalChooseImageShow => 'Optional: choose an image to show behind the launcher';

  @override
  String oobeCantUseImage(Object e) {
    return 'Can\'t use this image: $e';
  }

  @override
  String get oobeGamesInstancesModsWorlds =>
      'Games, instances, mods and worlds are all stored here. You can add more folders later in Settings → Game Management.';

  @override
  String get oobeUseDefaultFolder => 'Use the default folder';

  @override
  String get oobeUseExistingMinecraftFolder => 'Use an existing .minecraft folder';

  @override
  String get oobeInstalledGameAnotherLauncher =>
      'Installed the game with another launcher before? Pick that folder and its versions and worlds will work here.';

  @override
  String get oobeNotChosenYet => 'Not chosen yet';

  @override
  String get oobePCLCEDetected => 'PCL-CE detected';

  @override
  String oobeImportsPCLCEGame(Object folders, Object hasAccounts) {
    return 'Imports the PCL-CE game folders ($folders)$hasAccounts and launch settings.';
  }

  @override
  String get oobeAccounts => ', accounts';

  @override
  String get oobeWhereShouldGameFiles => 'Where should game files go?';

  @override
  String get oobeYouCanChangeLater => 'You can change this later in Settings → Game Management.';

  @override
  String get oobePhoneStorage => 'Phone storage';

  @override
  String get oobeStoredPixelWorldMinecraft =>
      'Stored in “Pixel World/.minecraft”. Games and worlds are kept if you uninstall or reinstall the launcher, and other apps can manage them. Requires the “All files access” permission.';

  @override
  String get oobeAppStorage => 'App storage';

  @override
  String get oobeNoPermissionNeededBut =>
      'No permission needed, but games and worlds are deleted when you uninstall the launcher.';

  @override
  String get oobeDecidedAfterSpeedTest => 'Decided after a speed test';

  @override
  String get oobeSpeedTestBMCLAPIMirror => 'Speed test: the BMCLAPI mirror is faster';

  @override
  String get oobeSpeedTestOfficialSource => 'Speed test: the official source is faster';

  @override
  String get oobeUsuallyFasterMainlandChina => 'Usually faster in mainland China';

  @override
  String get oobeOfficialServersOnly => 'Official servers only';

  @override
  String get oobeChooseWhereDownloadGame =>
      'Choose where to download game files from. The connection to each service is checked below.';

  @override
  String get oobeAutomaticUsesFasterOne =>
      '“Automatic” uses the faster one first and switches to the other on failure.';

  @override
  String get oobeMicrosoftAccount => 'Microsoft account';

  @override
  String get oobeSetClientIDSettings => 'Set a client ID in Settings → Other first';

  @override
  String get oobeOfficialSignLetsYou => 'Official sign-in; lets you join online-mode servers';

  @override
  String get commonSignMicrosoft => 'Sign in with Microsoft';

  @override
  String get oobeExternalSign => 'External sign-in';

  @override
  String get oobeLittleSkinOtherSkinSites => 'LittleSkin and other skin sites';

  @override
  String get oobeOfflineAccount => 'Offline account';

  @override
  String get oobeJustPickNamePlay => 'Just pick a name to play single-player';

  @override
  String get oobeOfflineUsername => 'Offline username';

  @override
  String get oobe316LettersDigits => '3–16 letters, digits or underscores';

  @override
  String get oobeAdd => 'Add';

  @override
  String get oobeAdded => 'Added';

  @override
  String get oobeYouCanAlsoSkip => 'You can also skip this for now.';

  @override
  String oobeAutomaticCurrently(Object preferMirror) {
    return 'Automatic (currently $preferMirror)';
  }

  @override
  String get commonAllSet => 'All set';

  @override
  String get oobeHereYourChoicesClick => 'Here are your choices; click “Change” to go back and edit them.';

  @override
  String oobeLayout(Object mode, Object homeLayout) {
    return '$mode · $homeLayout layout';
  }

  @override
  String get oobeNoneYet => 'None yet';

  @override
  String get oobeTakeGuidedTourAfter => 'Take the guided tour after entering';

  @override
  String get oobeAbout30SecondsYou => 'About 30 seconds; you can watch it again in Settings → About & Credits → Help';

  @override
  String get oobeFirstTimeSetup => 'First-time setup';

  @override
  String get oobeDontWantSetThings => 'Don\'t want to set things up now?';

  @override
  String get oobeUseAllDefaults => 'Use all defaults';

  @override
  String get oobeYouStillNeedAccept => ' (you still need to accept the agreement)';

  @override
  String get oobeChange => 'Change';

  @override
  String get oobeChoose => 'Choose…';

  @override
  String get oobeLargeCardAnnouncementsShortcuts => 'A large card, announcements and shortcuts, and recently played';

  @override
  String get oobeInstanceAtTopPlay => 'Instance at the top, Play at the bottom, background in between';

  @override
  String get oobeSingleBarAtBottom => 'A single bar at the bottom';

  @override
  String get tourTakeMinuteGetKnow =>
      'Take a minute to get to know the main parts of the launcher. You can click “Skip” at any time and watch it again in Settings → About & Credits.';

  @override
  String get tourAddAccountFirst => 'Add an account first';

  @override
  String get tourClickHereAddMicrosoft =>
      'Click here to add a Microsoft account; after signing in with it once, you can also add external accounts (e.g. LittleSkin) and offline accounts.';

  @override
  String get tourInstallGame => 'Install the game';

  @override
  String get tourUnderDownloadChooseGame =>
      'Under “Download”, choose a game version and a mod loader (Forge, Fabric, etc.) to install. Each installed copy is an “instance”; one version can have several, with separate worlds and mods. Mods, modpacks, resource packs and shaders are found here too.';

  @override
  String get tourSwitchInstance => 'Switch instance';

  @override
  String get tourHomePageShowsCurrent =>
      'The home page shows the current instance. Click “Switch instance” to change to another installed instance or to manage all of them.';

  @override
  String get tourPlay => 'Play';

  @override
  String get tourPickInstanceClickHere =>
      'Pick an instance and click here to launch it. The first launch sets up the Java it needs automatically.';

  @override
  String get tourInstanceSettings => 'Instance settings';

  @override
  String get tourEachInstancesModsWorlds =>
      'Each instance\'s mods, worlds, resource packs, shaders, memory and Java are managed separately here, and you can add mods to it directly.';

  @override
  String get tourBackgroundTasks => 'Background tasks';

  @override
  String get tourDownloadsInstallsRunBackground =>
      'Downloads and installs run in the background. Progress shows here; click to see details or cancel.';

  @override
  String get tourMultiplayerLobbyLANTransfer =>
      'Multiplayer lobby, LAN transfer, server lookup and crash analysis, plus small tools for skins and achievement images.';

  @override
  String get tourFileManagerYourPhone =>
      'The file manager on your phone: manage worlds, mods and screenshots in the game folder directly.';

  @override
  String get tourAskAIWhenSomething =>
      'Ask the AI when something goes wrong, e.g. why the game crashed or which mod to install. Set up a model in Settings first.';

  @override
  String get tourThemeBackgroundImageHome =>
      'Theme, background image and home layout are under “Personalization”; Java, memory and game folders are adjusted here too.';

  @override
  String get tourHeadDownloadInstallInstance =>
      'Head to “Download” and install an instance! You can reopen this tour in Settings → About & Credits.';

  @override
  String get tourGetStarted => 'Get started';

  @override
  String get agreementDialogTermsUsePrivacyNotice => 'The terms of use and privacy notice have been updated';

  @override
  String get agreementDialogPleaseReadTermsUse =>
      'Please read the terms of use and privacy notice below before using the launcher. In short: this software is free and open source and provided as is; we don\'t collect your information, and accounts and settings stay on your device; games and mods come from third parties.';

  @override
  String get agreementDialogAcceptContinue => 'Accept and continue';

  @override
  String get networkCheckPanelChecking => 'Checking…';

  @override
  String get networkCheckPanelCheckingUp8Seconds => 'Checking, up to 8 seconds';

  @override
  String get networkCheckPanelNeitherDownloadSourceCan =>
      'Neither download source can be reached; check your network or proxy settings';

  @override
  String networkCheckPanelAutomaticWillPreferSwitch(Object mirror) {
    return '“Automatic” will prefer $mirror and switch to the other one on failure';
  }

  @override
  String get networkCheckPanelBMCLAPIMirror => 'the BMCLAPI mirror';

  @override
  String networkCheckPanelOtherConnectionsFailedRelated(num failed) {
    String _temp0 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$failed connections failed; related features may not work',
      one: '1 connection failed; related features may not work',
    );
    return '$_temp0';
  }

  @override
  String get networkCheckPanelCheckAgain => 'Check again';

  @override
  String get networkCheckPanelLauncherUpdates => 'Launcher updates';

  @override
  String get networkCheckPanelCheckingUp8Seconds2 => 'Checking, up to 8 seconds';

  @override
  String get networkCheckPanelAllGood => 'All good';

  @override
  String get networkCheckPanelConnectionFailed => 'Connection failed';

  @override
  String get storageLocationPhoneStoragePixelWorld =>
      'Phone storage (Pixel World/.minecraft): games and worlds are kept if you uninstall or reinstall the launcher, and other apps can manage the files. Requires the “All files access” permission.\n\nApp storage: no permission needed, but games and worlds are deleted when you uninstall the launcher.\n\nYou can change this later in Settings → Game Management.';

  @override
  String get storageLocationPhoneStorageRecommended => 'Phone storage (recommended)';

  @override
  String get storageLocationAllFilesAccessWasnt =>
      '“All files access” wasn\'t granted, so the game folder wasn\'t changed';

  @override
  String get storageLocationMoveGameFiles => 'Move game files';

  @override
  String storageLocationMoveInstancesWorldsResources(Object from, Object to) {
    return 'Move the instances, worlds and resources in the current game folder to the new location?\n\n$from\n→ $to';
  }

  @override
  String get storageLocationJustSwitchDontMove => 'Just switch, don\'t move';

  @override
  String get storageLocationMove => 'Move';

  @override
  String storageLocationGameFolderChanged(Object to) {
    return 'Game folder changed to $to';
  }

  @override
  String get storageLocationMovingGameFiles => 'Moving game files';

  @override
  String get storageLocationMoveFailed => 'Move failed';

  @override
  String storageLocationFilesWereAlreadyMoved(Object error) {
    return '$error\n\nFiles that were already moved are in the new location; the rest are still in the old one.';
  }

  @override
  String get storageLocationCountingFiles => 'Counting files…';

  @override
  String storageLocationFilesPleaseDontClose(Object done, Object total) {
    return '$done / $total files. Please don\'t close the launcher';
  }

  @override
  String get storageLocationCurrentGameFolder => 'Current game folder';

  @override
  String get storageLocationChange => 'Change';

  @override
  String get storageLocationStorageLocation => 'Storage location';

  @override
  String get storageLocationPhoneStorageKeptWhen => 'Phone storage: kept when you uninstall the launcher';

  @override
  String get storageLocationAppStorageDeletedWhen =>
      'App storage: deleted when you uninstall the launcher; moving to phone storage is recommended';

  @override
  String get storageLocationMaintenance => 'Maintenance';

  @override
  String get commonCleanUpGameJunk => 'Clean up game junk';

  @override
  String get storageLocationDeletesLogsCrashReports =>
      'Deletes logs, crash reports and extracted native libraries; worlds and mods aren\'t affected';

  @override
  String get commonCleanUp => 'Clean up';

  @override
  String get storageLocationFileManager => 'File manager';

  @override
  String get storageLocationBrowseImportCopyDelete =>
      'Browse, import, copy or delete game files; deleted files go to the recycle bin first';

  @override
  String get launchDialogsJavaVersionMayIncompatible => 'The Java version may be incompatible';

  @override
  String launchDialogsYouCanChangeJava(Object message) {
    return '$message\n\nYou can change Java to Java 8 or automatic in the instance settings.';
  }

  @override
  String get launchDialogsLaunchAnyway => 'Launch anyway';

  @override
  String launchDialogsOtherTimes(num launchCount) {
    String _temp0 = intl.Intl.pluralLogic(
      launchCount,
      locale: localeName,
      other: 'You\'ve launched the game $launchCount times',
      one: 'You\'ve launched the game once',
    );
    return '$_temp0';
  }

  @override
  String launchDialogsMaintainedIfYouFind(Object name, Object authorName) {
    return '$name is maintained by $authorName. If you find it useful, would you consider sponsoring the author?\n\nThis project is free and ad-free, and it relies on your support.';
  }

  @override
  String get launchDialogsMaybeLater => 'Maybe later';

  @override
  String launchDialogsSignAgain(Object serverName) {
    return 'Sign in to $serverName again';
  }

  @override
  String launchDialogsSignHasExpiredEnter(Object name, Object login) {
    return 'The sign-in for $name ($login) has expired. Enter your password to continue launching.';
  }

  @override
  String get commonPassword => 'Password';

  @override
  String get launchDialogsCancelLaunch => 'Cancel launch';

  @override
  String get commonSign => 'Sign in';

  @override
  String updateDialogYoureLatestVersion(Object label) {
    return 'You\'re on the latest version ($label)';
  }

  @override
  String updateDialogCouldntCheckUpdates(Object error) {
    return 'Couldn\'t check for updates: $error';
  }

  @override
  String updateDialogNewVersionAvailable(Object label) {
    return 'New version available: $label';
  }

  @override
  String updateDialogCurrentVersion(Object current, Object prerelease, Object date) {
    return 'Current version $current · $prerelease$date';
  }

  @override
  String updateDialogReleased(Object date) {
    return ' · released $date';
  }

  @override
  String get updateDialogNoReleaseNotes => 'No release notes';

  @override
  String get updateDialogNoPackageHasBeen =>
      'No package has been published for this platform yet; please check GitHub.';

  @override
  String get updateDialogReleaseHasNoFile => 'This release has no file for the current platform.';

  @override
  String get updateDialogAfterDownloadingInstallerImage =>
      'After downloading, the installer image opens; drag Pixel World into the Applications folder to replace the old version. Game files aren\'t affected.';

  @override
  String get updateDialogAfterDownloadingSystemInstalls =>
      'After downloading, the system installs it; confirm in the dialog that appears. Game files aren\'t affected.';

  @override
  String get updateDialogDownloading => 'Downloading';

  @override
  String updateDialogDownloading2(Object progress) {
    return 'Downloading $progress%';
  }

  @override
  String get updateDialogInstallerHasBeenDownloaded =>
      'The installer has been downloaded. The first time, you need to allow “Install unknown apps” in system settings; then come back and tap “Continue install”. There\'s no need to download again.';

  @override
  String get updateDialogSkipVersion => 'Skip this version';

  @override
  String get updateDialogViewGitHub => 'View on GitHub';

  @override
  String get updateDialogLater => 'Later';

  @override
  String get updateDialogContinueInstall => 'Continue install';

  @override
  String get updateDialogUpdateRestart => 'Update and restart';

  @override
  String get updateDialogDownloadInstall => 'Download and install';

  @override
  String get pclImportDialogImportComplete => 'Import complete';

  @override
  String pclImportDialogSettings(Object settings) {
    return 'Settings: $settings';
  }

  @override
  String pclImportDialogAddedGameFoldersAccounts(Object folders, Object accounts) {
    return 'Added $folders game folders and $accounts accounts';
  }

  @override
  String pclImportDialogNotImported(Object skippedAccounts) {
    return 'Not imported: $skippedAccounts';
  }

  @override
  String pclImportDialogFoundPCLCEConfiguration(Object folders, Object hasAccounts) {
    return 'Found a PCL-CE configuration: $folders game folders$hasAccounts';
  }

  @override
  String get pclImportDialogAccounts => ', with accounts';

  @override
  String get pclImportDialogNoPCLCEConfiguration =>
      'No PCL-CE configuration was found in %APPDATA%\\PCLCE. You can choose the PCL-CE folder to import its local settings';

  @override
  String get pclImportDialogPerInstanceSettingsDont =>
      'Per-instance settings don\'t need importing; both launchers share them.';

  @override
  String get pclImportDialogLaunchSettings => 'Launch settings';

  @override
  String get pclImportDialogMemoryJVMArgumentsMore =>
      'Memory, JVM arguments and more need the PCL-CE folder to be chosen';

  @override
  String get pclImportDialogImportedMicrosoftAccountsNeed =>
      'Imported Microsoft accounts need to sign in again here once they expire';

  @override
  String get pclImportDialogPCLCEFolderNot => 'PCL-CE folder: not chosen (optional)';

  @override
  String pclImportDialogPCLCEFolder(Object pclDir) {
    return 'PCL-CE folder: $pclDir';
  }

  @override
  String get commonChoose => 'Choose';

  @override
  String get yggdrasilLoginDialogAuthenticationServerAddress => 'Authentication server address';

  @override
  String get yggdrasilLoginDialogEnterAddressPickOne => 'Enter an address or pick one from the list';

  @override
  String get yggdrasilLoginDialogChooseProfile => 'Choose a profile';

  @override
  String yggdrasilLoginDialogAuthenticationServer(Object server) {
    return 'Authentication server: $server';
  }

  @override
  String get yggdrasilLoginDialogAddressIsntEncryptedYour =>
      'This address isn\'t encrypted; your password will be sent in plain text';

  @override
  String get yggdrasilLoginDialogEmailUsername => 'Email or username';

  @override
  String get yggdrasilLoginDialogPasswordSign => 'Password sign-in';

  @override
  String get yggdrasilLoginDialogOAuthAuthorization => 'OAuth authorization';

  @override
  String get yggdrasilLoginDialogAccountPassword => 'Account password';

  @override
  String yggdrasilLoginDialogClickingStartOpensAuthorization(Object site) {
    return 'Clicking Start opens the $site authorization page in your browser; approve it and choose a profile. The launcher never sees your password.';
  }

  @override
  String get yggdrasilLoginDialogStartOAuthSign => 'Start OAuth sign-in';

  @override
  String get accountsDialogNoAccountsYet => 'No accounts yet';

  @override
  String get accountsDialogAddOfflineAccount => 'Add offline account';

  @override
  String get accountsDialogUsername => 'Username';

  @override
  String get accountsDialogMicrosoftAccounts => 'Microsoft accounts';

  @override
  String get accountsDialogMicrosoftSignNeedsAzure =>
      'Microsoft sign-in needs an Azure app client ID in Settings → Other first.';

  @override
  String get accountsDialogThirdPartyAccounts => 'Third-party accounts';

  @override
  String get maintenanceActionsNothingCleanUp => 'Nothing to clean up';

  @override
  String maintenanceActionsItemsWillDeletedLogs(Object count, Object size) {
    return '$count items ($size) will be deleted:\nlogs (logs, *.log), crash reports (crash-reports, hs_err_pid*) and extracted native libraries (natives, regenerated at launch) in the game folder and every instance folder.\n\nWorlds, mods and settings won\'t be deleted.';
  }

  @override
  String maintenanceActionsCleanedUp(Object size) {
    return 'Cleaned up $size';
  }

  @override
  String maintenanceActionsOtherItemsUseWerent(num failed) {
    String _temp0 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: 'Cleaned up; $failed items are in use and weren\'t deleted',
      one: 'Cleaned up; 1 item is in use and wasn\'t deleted',
    );
    return '$_temp0';
  }

  @override
  String maintenanceActionsCreated(Object path) {
    return 'Created $path';
  }

  @override
  String get fileViewerFileDoesntExist => 'The file doesn\'t exist';

  @override
  String get fileViewerPreview => 'Preview';

  @override
  String get fileViewerSource => 'Source';

  @override
  String get fileViewerRefresh => 'Refresh';

  @override
  String get fileViewerCopyAll => 'Copy all';

  @override
  String get fileViewerCopied => 'Copied';

  @override
  String get fileViewerShowFileManager => 'Show in file manager';

  @override
  String fileViewerCantOpen(Object error) {
    return 'Can\'t open: $error';
  }

  @override
  String get fileViewerFileIsntTextLarger =>
      'This file isn\'t text or is larger than 2 MB, so it can\'t be viewed here';

  @override
  String get deviceStatusMobileData => 'Mobile data';

  @override
  String get deviceStatusEthernet => 'Ethernet';

  @override
  String get deviceStatusConnected => 'Connected';

  @override
  String get deviceStatusOffline => 'Offline';

  @override
  String get deviceStatusFullyCharged => 'Fully charged';

  @override
  String get deviceStatusCharging => 'Charging';

  @override
  String get deviceStatusPlugged => 'Plugged in';

  @override
  String get deviceStatusBattery => 'Battery';

  @override
  String deviceLoginDialogSignedAs(Object name) {
    return 'Signed in as $name';
  }

  @override
  String get deviceLoginDialogStartSign => 'Start sign-in';

  @override
  String get deviceLoginDialogRetry => 'Retry';

  @override
  String get deviceLoginDialogAuthorizationPageHasOpened =>
      'The authorization page has opened in your browser. Check that the code on the page matches the one below, then approve:';

  @override
  String get deviceLoginDialogSignPageHasOpened =>
      'The sign-in page has opened in your browser. Enter the code below (already copied to the clipboard):';

  @override
  String get deviceLoginDialogWaitingSign => 'Waiting for sign-in';

  @override
  String formatOtherYearsAgo(num inDays) {
    String _temp0 = intl.Intl.pluralLogic(inDays, locale: localeName, other: '$inDays years ago', one: '1 year ago');
    return '$_temp0';
  }

  @override
  String formatOtherMonthsAgo(num inDays) {
    String _temp0 = intl.Intl.pluralLogic(inDays, locale: localeName, other: '$inDays months ago', one: '1 month ago');
    return '$_temp0';
  }

  @override
  String formatOtherDaysAgo(num inDays) {
    String _temp0 = intl.Intl.pluralLogic(inDays, locale: localeName, other: '$inDays days ago', one: '1 day ago');
    return '$_temp0';
  }

  @override
  String formatOtherHoursAgo(num inHours) {
    String _temp0 = intl.Intl.pluralLogic(inHours, locale: localeName, other: '$inHours hours ago', one: '1 hour ago');
    return '$_temp0';
  }

  @override
  String get formatJustNow => 'Just now';

  @override
  String get themeColorDialogCustomThemeColor => 'Custom theme color';

  @override
  String get themeColorDialogR => 'R';

  @override
  String get themeColorDialogG => 'G';

  @override
  String get themeColorDialogB => 'B';

  @override
  String get themeColorDialogUse => 'Use';

  @override
  String homeCouldntLaunch(Object error) {
    return 'Couldn\'t launch: $error';
  }

  @override
  String homeCantOpenFolder(Object error) {
    return 'Can\'t open the folder: $error';
  }

  @override
  String get homeRecentlyPlayed => 'Recently played';

  @override
  String get homeAllWorlds => 'All worlds ›';

  @override
  String homeOtherMinutesAgo(num inMinutes) {
    String _temp0 = intl.Intl.pluralLogic(
      inMinutes,
      locale: localeName,
      other: '$inMinutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String homeMonthDay(Object month, Object day) {
    return '$month/$day';
  }

  @override
  String get homeNoInstanceSelected => 'No instance selected';

  @override
  String get homeInstallChooseInstanceFirst => 'Install or choose an instance first, then start when you\'re ready';

  @override
  String get homeMore => 'More';

  @override
  String get homeOpenInstanceFolder => 'Open instance folder';

  @override
  String commonModCount(num data) {
    String _temp0 = intl.Intl.pluralLogic(data, locale: localeName, other: '$data mods', one: '1 mod');
    return '$_temp0';
  }

  @override
  String homeRenderer(Object renderer) {
    return '$renderer renderer';
  }

  @override
  String homePlayed(Object modified) {
    return 'Played $modified';
  }

  @override
  String get homeBackGame => 'Back to game';

  @override
  String get commonStopGame => 'Stop game';

  @override
  String get homeAddMods => 'Add mods';

  @override
  String get homeManageMods => 'Manage mods';

  @override
  String get homeFolder => 'Folder';

  @override
  String get commonViewLog => 'View log';

  @override
  String get homeLauncherAnnouncements => 'Launcher announcements';

  @override
  String get homeLoading => 'Loading…';

  @override
  String get commonNoAnnouncements => 'No announcements';

  @override
  String get homeView => 'View ›';

  @override
  String get homeSwitchInstanceWorld => 'Switch to the instance this world is in';

  @override
  String get homeYourRecentWorldsWill => 'Your recent worlds will appear here after you play.';

  @override
  String get homeScrollDownMore => 'Scroll down for more';

  @override
  String get homeSwipeUpMore => 'Swipe up for more';

  @override
  String get homeInstallChooseInstanceFirst2 => 'Install or choose an instance first';

  @override
  String get homeNoRecentlyPlayedWorlds => 'No recently played worlds yet';

  @override
  String get homeAllWorlds2 => 'All worlds';

  @override
  String get homeOpenFolder => 'Open folder';

  @override
  String get homeCurrentInstance => 'Current instance';

  @override
  String get homeInstanceSettings => 'Instance settings ›';

  @override
  String get homeType => 'Type';

  @override
  String get homeMods => 'Mods';

  @override
  String get homeVanillaNoMods => 'Vanilla, no mods';

  @override
  String homeModCountValue(Object data) {
    return '$data';
  }

  @override
  String get homeNotPlayedYet => 'Not played yet';

  @override
  String get homeInstanceID => 'Instance ID';

  @override
  String get homeManageAllInstances => 'Manage all instances';

  @override
  String homeFeedYoureUsingBetaThird(Object name, Object version) {
    return 'You\'re using $name $version, a beta. This is a third-party Minecraft launcher that\'s still being polished; please report problems on GitHub.';
  }

  @override
  String get homeFeedReportProblem => 'Report a problem';

  @override
  String get homeFeedSoftwareCompletelyFreeOpen =>
      'This software is completely free and open source. If you paid for it or downloaded it from a paid source, you may have been scammed; ask the seller for a refund and get the genuine version from GitHub.';

  @override
  String get homeFeedGetGenuineVersion => 'Get the genuine version';

  @override
  String homeFeedBetaThatsStillBeing(Object name, Object version) {
    return '$name $version is a beta that\'s still being polished; please report problems on GitHub.';
  }

  @override
  String get homeFeedSoftwareCompletelyFreeOpen2 =>
      'This software is completely free and open source. If you paid for it, ask the seller for a refund and get the genuine version from GitHub.';

  @override
  String get homeFeedHideBetaNoticeFree => 'Hide the beta notice (the free software notice stays)';

  @override
  String homeFeedChangelogV(Object version, Object channel) {
    return 'Changelog · v$version$channel';
  }

  @override
  String get homeFeedCollapse => 'Collapse';

  @override
  String get homeFeedExpand => 'Expand';

  @override
  String get homeFeedLoadingAnnouncements => 'Loading announcements…';

  @override
  String get homeFeedViewDetails => 'View details';

  @override
  String get homeFeedMinecraftVersionNews => 'Minecraft version news';

  @override
  String get homeFeedFromMinecraftWiki => 'From the Minecraft Wiki';

  @override
  String homeFeedCouldntLoad(Object error) {
    return 'Couldn\'t load: $error';
  }

  @override
  String get homeFeedSnapshot => 'Snapshot';

  @override
  String get homeFeedMinecraftWikiDoesntHave =>
      'The Minecraft Wiki doesn\'t have an article on this version yet; click to open the page.';

  @override
  String get versionsCurrentFolder => 'Current folder';

  @override
  String get versionsOfficialLauncherFolder => 'Official launcher folder';

  @override
  String get versionsLauncherDefaultFolder => 'Launcher default folder';

  @override
  String get versionsRemoveFromListFiles => 'Remove from list (files aren\'t deleted)';

  @override
  String get versionsAddFolder => 'Add folder';

  @override
  String get versionsNoInstancesFolderYet => 'No instances in this folder yet';

  @override
  String versionsOtherInstances(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count instances', one: '1 instance');
    return '$_temp0';
  }

  @override
  String get versionsNewInstance => 'New instance';

  @override
  String get versionsSearchInstances => 'Search instances';

  @override
  String get versionsNoMatchingInstances => 'No matching instances';

  @override
  String tasksProgress(Object count) {
    return '$count in progress';
  }

  @override
  String get tasksClearFinishedTasks => 'Clear finished tasks';

  @override
  String get tasksNoTasksYetInstalling =>
      'No tasks yet. Installing instances, downloading resources and launching the game show up here';

  @override
  String tasksMinS(Object inMinutes, Object inSeconds) {
    return '$inMinutes min $inSeconds s';
  }

  @override
  String tasksS(Object inSeconds) {
    return '$inSeconds s';
  }

  @override
  String get tasksCanceling => 'Canceling';

  @override
  String get tasksProgress2 => 'In progress';

  @override
  String get tasksCompleted => 'Completed';

  @override
  String get tasksFailed => 'Failed';

  @override
  String get tasksCanceled => 'Canceled';

  @override
  String get tasksCanceling2 => 'Canceling…';

  @override
  String get tasksCancel => 'Cancel';

  @override
  String get tasksCopyLog => 'Copy log';

  @override
  String get commonLogCopied => 'Log copied';

  @override
  String get logGameRunning => 'Game running';

  @override
  String get logStarting => 'Starting';

  @override
  String get logGameNotRunning => 'Game not running';

  @override
  String logGameExitedCode(Object lastExitCode) {
    return 'Game exited with code $lastExitCode';
  }

  @override
  String get logAutoScroll => 'Auto-scroll';

  @override
  String get logCopyAll => 'Copy all';

  @override
  String get logLogWillAppearHere => 'The log will appear here after you launch the game';

  @override
  String get diagnoseGameCrashed => 'The game crashed';

  @override
  String diagnoseExitedAbnormally(Object title) {
    return '$title exited abnormally.';
  }

  @override
  String get diagnoseNoKnownProblemMatched => 'No known problem matched; you can check the log or analyze it with AI.';

  @override
  String get diagnoseAIAnalysis => 'AI analysis';

  @override
  String get diagnoseNothingAnalyze => 'Nothing to analyze';

  @override
  String get diagnoseEnvironment => 'Environment';

  @override
  String get diagnoseInitialFindings => 'Initial findings';

  @override
  String get diagnoseNoKnownProblemMatched2 => 'No known problem matched';

  @override
  String get diagnoseUseAIAnalysisBelow => 'Use the AI analysis below, or read the log excerpt yourself';

  @override
  String get diagnoseExistingAIConversation => 'Existing AI conversation';

  @override
  String get diagnoseAnalyzeAI => 'Analyze with AI';

  @override
  String get diagnoseContinueCrashsConversationAI => 'Continue this crash\'s conversation on the AI page';

  @override
  String diagnoseStartsNewConversationSends(Object host, Object model) {
    return 'Starts a new conversation and sends the log excerpt and environment info below to $host ($model)';
  }

  @override
  String get diagnoseAnalyzeLogYourOwn =>
      'Analyze the log with your own AI service; set the API address, model and API key first';

  @override
  String get diagnoseViewConversation => 'View conversation';

  @override
  String get diagnoseLogExcerpt => 'Log excerpt';

  @override
  String get diagnoseNoLogsFound => 'No logs found';

  @override
  String diagnoseCharactersTrimmedPrivateInformation(Object count) {
    return '$count characters, trimmed and with private information removed';
  }

  @override
  String get diagnoseModList => 'Mod list';

  @override
  String diagnoseOtherEnabledMods(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enabled mods',
      one: '1 enabled mod',
    );
    return '$_temp0';
  }

  @override
  String get docsFromPixelworldZhuzhiSite => 'From pixelworld.zhuzhi.site · shows the last cached copy when offline';

  @override
  String get docsOpenBrowser => 'Open in browser';

  @override
  String get instanceInstanceNoLongerExists => 'This instance no longer exists';

  @override
  String get instanceWorlds => 'Worlds';

  @override
  String get commonResourcePacks => 'Resource packs';

  @override
  String get commonShaders => 'Shaders';

  @override
  String get instanceScreenshots => 'Screenshots';

  @override
  String get instanceSchematics => 'Schematics';

  @override
  String get instanceServers => 'Servers';

  @override
  String get instanceOverview => 'Overview';

  @override
  String get instanceChangeIcon => 'Change icon';

  @override
  String instanceCouldntChangeIcon(Object error) {
    return 'Couldn\'t change the icon: $error';
  }

  @override
  String get instanceChangeIcon2 => 'Change icon…';

  @override
  String get instanceRestoreDefaultIcon => 'Restore default icon';

  @override
  String instanceBackList(Object label) {
    return 'Back to the $label list';
  }

  @override
  String instanceDelete(Object id) {
    return 'Delete $id?';
  }

  @override
  String get instanceInstanceFolderWillMoved =>
      'The instance folder will be moved to the recycle bin. If instance isolation is on, its worlds and mods are deleted with it.';

  @override
  String instanceDeleted(Object id) {
    return 'Deleted $id';
  }

  @override
  String get instanceSetAsCurrentInstance => 'Set as current instance';

  @override
  String get commonGameVersion => 'Game version';

  @override
  String get instanceDecidedAtFirstLaunch => 'Decided at first launch';

  @override
  String get instanceText => 'On';

  @override
  String get instanceOff => 'Off';

  @override
  String get instanceWorkingDirectory => 'Working directory';

  @override
  String get instanceReleaseDate => 'Release date';

  @override
  String get instanceShortcuts => 'Shortcuts';

  @override
  String get instanceInstanceFolder => 'Instance folder';

  @override
  String instanceFolder(Object label) {
    return '$label folder';
  }

  @override
  String get instanceManage => 'Manage';

  @override
  String get instanceSendInstance => 'Send this instance';

  @override
  String get instanceSendWholeInstanceAnother => 'Send the whole instance to another device over the local network';

  @override
  String get instanceSend => 'Send';

  @override
  String get instanceDeleteInstance => 'Delete this instance';

  @override
  String get instanceMovesRecycleBinIf =>
      'Moves it to the recycle bin; if instance isolation is on, its worlds and mods are deleted with it';

  @override
  String get instanceUseGlobalSetting => 'Use global setting';

  @override
  String instanceNotInstalled(Object javaKey) {
    return '$javaKey (not installed)';
  }

  @override
  String get instanceChooseManually => 'Choose manually…';

  @override
  String get instanceTheseSettingsStoredPCL =>
      'These settings are stored in PCL/config.v1.yml in the instance folder and shared with PCL-CE';

  @override
  String instanceNotDecidedYetSet(Object isolationMode) {
    return 'Not decided yet: set by the global policy “$isolationMode” at first launch, then fixed';
  }

  @override
  String get instanceWorkingDirectoryInstanceFolder => 'The working directory is the instance folder';

  @override
  String get instanceText2 => 'On';

  @override
  String instanceGlobal(Object javaPath) {
    return 'Global: $javaPath';
  }

  @override
  String instanceGlobalSetting(Object androidRenderer) {
    return 'Global setting “$androidRenderer”';
  }

  @override
  String instanceGlobalCustomGB(Object memoryTick) {
    return 'Global: custom $memoryTick GB';
  }

  @override
  String get instanceGlobalAutomatic => 'Global: automatic';

  @override
  String get instanceGlobal2 => 'Global';

  @override
  String get instanceMaximumMemory => 'Maximum memory';

  @override
  String get instanceInitialMemory => 'Initial memory';

  @override
  String get instanceNotSet => 'Not set';

  @override
  String get instanceJoinServerAutomatically => 'Join server automatically';

  @override
  String get instanceLeaveEmptyUseGlobal => 'Leave empty to use the global setting';

  @override
  String instanceMovedRecycleBin(Object name) {
    return 'Moved $name to the recycle bin';
  }

  @override
  String instanceTotalEnabled(Object count, Object enabledMods) {
    return '$count total, $enabledMods enabled';
  }

  @override
  String instanceItemCount(Object count) {
    return '$count';
  }

  @override
  String get instanceFilter => 'Filter';

  @override
  String get instanceSendWorld => 'Send world';

  @override
  String instanceAdd(Object label) {
    return 'Add $label';
  }

  @override
  String get instanceAddOptiFine => 'Add OptiFine';

  @override
  String instanceNoHereYet(Object label) {
    return 'No $label here yet';
  }

  @override
  String get instanceDisabled => ' · disabled';

  @override
  String get instanceMoveRecycleBin => 'Move to recycle bin';

  @override
  String get instanceServersSavedGameMultiplayer => 'Servers saved in the in-game multiplayer list (servers.dat)';

  @override
  String get instanceNoSavedServersYet => 'No saved servers yet';

  @override
  String get instanceCantConnect => 'Can\'t connect';

  @override
  String instanceOnlineMs(Object online, Object max, Object latency) {
    return '$online/$max online · $latency ms';
  }

  @override
  String instanceCouldntGetOptiFineVersions(Object error) {
    return 'Couldn\'t get OptiFine versions: $error';
  }

  @override
  String instanceNoOptiFineCompatibleForge(Object gameVersion) {
    return 'No OptiFine compatible with Forge ($gameVersion)';
  }

  @override
  String instanceNoOptiFineAvailable(Object gameVersion) {
    return 'No OptiFine available for $gameVersion';
  }

  @override
  String get commonOptiFineVersion => 'OptiFine version';

  @override
  String get commonPreview => ' (preview)';

  @override
  String commonRequiresForge(Object requiredForge) {
    return ' · requires Forge $requiredForge';
  }

  @override
  String get downloadModpacks => 'Modpacks';

  @override
  String get downloadDataPacks => 'Data packs';

  @override
  String get commonFavorites => 'Favorites';

  @override
  String get downloadOldVersions => 'Old versions';

  @override
  String get downloadAprilFools => 'April Fools';

  @override
  String downloadCouldntGetVersionList(Object error) {
    return 'Couldn\'t get the version list: $error';
  }

  @override
  String get downloadLoadingVersionList => 'Loading the version list…';

  @override
  String get downloadSearchVersions => 'Search versions';

  @override
  String get downloadNoMatchingVersions => 'No matching versions';

  @override
  String get downloadLatest => 'Latest';

  @override
  String get downloadInstalled => 'Installed';

  @override
  String get downloadChooseVersionLeft => 'Choose a version on the left';

  @override
  String get downloadPlainMinecraft => 'Plain Minecraft';

  @override
  String get downloadOldestLoaderMostMods => 'The oldest loader, with the most mods';

  @override
  String get downloadCommunityForkForgeAvailable => 'A community fork of Forge, available from 1.20.1';

  @override
  String get downloadModernized1122 => 'A modernized 1.12.2 branch based on Forge; requires Java 21';

  @override
  String get downloadAllOneClientLots => 'An all-in-one client with lots of built-in features (LabyMod 4)';

  @override
  String get downloadLightweightFastUpdatingMod => 'A lightweight, fast-updating mod loader';

  @override
  String get downloadCompatibleMostFabricMods => 'Compatible with most Fabric mods';

  @override
  String get downloadFabricPorted113 => 'Fabric ported to 1.13.2 and earlier';

  @override
  String get downloadLightweightLoader112 => 'A lightweight loader for 1.12.2 and earlier';

  @override
  String get downloadInstallationStartedSeeBackground =>
      'Installation started; see the background tasks in the top bar for progress';

  @override
  String downloadInstalled2(Object id) {
    return '$id installed';
  }

  @override
  String get commonTaskCanceled => 'Task canceled';

  @override
  String commonInstallationFailed(Object error) {
    return 'Installation failed: $error';
  }

  @override
  String downloadIsntSupported(Object id) {
    return '$id isn\'t supported';
  }

  @override
  String get downloadNone => 'None';

  @override
  String downloadInstall(Object id) {
    return 'Install $id';
  }

  @override
  String downloadLoadingLoaders(Object count, Object count2) {
    return 'Loading loaders $count/$count2';
  }

  @override
  String get downloadInstanceName => 'Instance name';

  @override
  String downloadInstancesAlreadyInstalledInstalls(Object same, Object id) {
    return 'Instances of $id already installed: $same. This installs another, separate instance with its own worlds and mods';
  }

  @override
  String get downloadVanilla => 'Vanilla';

  @override
  String downloadVersion(Object label) {
    return '$label version';
  }

  @override
  String downloadBeta(Object label) {
    return '$label (beta)';
  }

  @override
  String get downloadInstallOptiFineToo => 'Install OptiFine too';

  @override
  String get downloadLoadingOptiFineVersions => 'Loading OptiFine versions…';

  @override
  String downloadCantInstalledTogetherOptiFine(Object label) {
    return '$label can\'t be installed together with OptiFine';
  }

  @override
  String get downloadNoOptiFineCompatibleForge => 'No OptiFine compatible with Forge';

  @override
  String get downloadNoOptiFineVersion => 'No OptiFine for this version';

  @override
  String get downloadSelectedForgeDiffersFrom =>
      'The selected Forge differs from the version OptiFine requires; newer Forge versions may not be compatible with it';

  @override
  String downloadInstallAs(Object text) {
    return 'Install as $text';
  }

  @override
  String get commonInstall => 'Install';

  @override
  String get resourcesModrinthModpacks => 'Modrinth modpacks';

  @override
  String resourcesInstalledModpackAs(Object id) {
    return 'Installed the modpack as $id';
  }

  @override
  String resourcesAddingOnlyCompatibleShown(Object id, Object label, Object gameVersion) {
    return 'Adding $label to $id · only $label compatible with $gameVersion are shown, and they\'re installed straight into this instance';
  }

  @override
  String get resourcesBrowseNormally => 'Browse normally';

  @override
  String resourcesSearchModrinth(Object label) {
    return 'Search Modrinth for $label';
  }

  @override
  String resourcesText(Object id) {
    return 'For $id';
  }

  @override
  String get resourcesSort => 'Sort';

  @override
  String get resourcesRelevance => 'Relevance';

  @override
  String get resourcesDownloads => 'Downloads';

  @override
  String get resourcesFollows => 'Follows';

  @override
  String get resourcesNewest => 'Newest';

  @override
  String get resourcesRecentlyUpdated => 'Recently updated';

  @override
  String resourcesSort2(Object sort) {
    return 'Sort: $sort';
  }

  @override
  String get resourcesInstallFromFile => 'Install from file';

  @override
  String get resourcesNoResults => 'No results';

  @override
  String get resourcesLoadMore => 'Load more';

  @override
  String get resourcesRemoveFromFavorites => 'Remove from favorites';

  @override
  String get resourcesNoInstancesInstalledYet => 'No instances installed yet';

  @override
  String resourcesHasNoModLoader(Object id) {
    return '$id has no mod loader installed, so mods won\'t take effect';
  }

  @override
  String resourcesHasNoWorldsYet(Object id) {
    return '$id has no worlds yet; enter the game and create one first';
  }

  @override
  String resourcesInstalledFiles(Object count) {
    return 'Installed $count files';
  }

  @override
  String resourcesAlreadyPresent(Object count) {
    return '$count already present';
  }

  @override
  String resourcesNoCompatibleDependencyFound(Object missing) {
    return 'No compatible dependency found: $missing';
  }

  @override
  String resourcesDownloads2(Object author, Object label, Object downloads, Object updated) {
    return '$author · $label · $downloads downloads$updated';
  }

  @override
  String resourcesUpdated(Object updated) {
    return ' · updated $updated';
  }

  @override
  String get resourcesViewModrinth => 'View on Modrinth';

  @override
  String resourcesInstall(Object target) {
    return 'Install to $target';
  }

  @override
  String get resourcesInstall2 => 'Install to';

  @override
  String get resourcesWillInstalledAsNew => 'Will be installed as a new instance';

  @override
  String get resourcesWorld => 'World';

  @override
  String get resourcesShowAllFiles => 'Show all files';

  @override
  String get resourcesNoFilesAvailable => 'No files available';

  @override
  String resourcesNoFilesYouCan(Object gameVersion) {
    return 'No files for $gameVersion; you can turn on “Show all files”';
  }

  @override
  String get resourcesRelease => 'Release';

  @override
  String resourcesVersions(Object list, Object list2, Object count) {
    return '$list – $list2 ($count versions)';
  }

  @override
  String get resourcesFavorites => 'Favorites';

  @override
  String get resourcesNoFavoritesYetClick => 'No favorites yet; click the heart icon next to a resource to add it';

  @override
  String get toolsMultiplayer => 'Multiplayer';

  @override
  String get toolsLANTransfer => 'LAN transfer';

  @override
  String get toolsSendModsWorldsWhole => 'Send mods, worlds or whole instances between two devices';

  @override
  String get toolsServerLookup => 'Server lookup';

  @override
  String get toolsCheckServersPlayerCount => 'Check a server\'s player count and latency';

  @override
  String get toolsMultiplayerLobby => 'Multiplayer lobby';

  @override
  String get toolsPlanned => 'Planned';

  @override
  String get toolsTroubleshooting => 'Troubleshooting';

  @override
  String get toolsReadLogsFindCause => 'Read logs and find the cause of crashes automatically';

  @override
  String get toolsUtilities => 'Utilities';

  @override
  String get toolsCustomDownload => 'Custom download';

  @override
  String get toolsDownloadFileFromLink => 'Download a file from a link to a folder of your choice';

  @override
  String get toolsFun => 'Fun';

  @override
  String get toolsSkinsAvatars => 'Skins and avatars';

  @override
  String get toolsViewDownloadMinecraftPlayers => 'View and download Minecraft players\' skins';

  @override
  String get toolsAchievementImage => 'Achievement image';

  @override
  String get toolsMakeCustomAchievementToast => 'Make a custom achievement toast image';

  @override
  String get toolsTodaysLuck => 'Today\'s luck';

  @override
  String get toolsSeeHowLuckyYou => 'See how lucky you are today; fixed for each player each day';

  @override
  String get toolsBackTools => 'Back to tools';

  @override
  String get toolsPNGImage => 'PNG image';

  @override
  String get toolsLetsFewPlayersForm => 'Lets a few players form a virtual LAN to play together; still being planned';

  @override
  String get toolsNoGameHasBeen => 'No game has been launched since the launcher was opened';

  @override
  String get toolsLog => 'Log';

  @override
  String get toolsEmpty => 'Empty';

  @override
  String get toolsPasteLog => 'Paste log';

  @override
  String get toolsPasteCrashReportLog => 'Paste a crash report or log';

  @override
  String get toolsAnalyze => 'Analyze';

  @override
  String get toolsPastedLog => 'Pasted log';

  @override
  String get toolsLastGame => 'Last game';

  @override
  String get toolsAnalyzeMostRecentGame => 'Analyze the most recent game run since the launcher was opened';

  @override
  String get toolsLogFile => 'Log file';

  @override
  String get toolsChooseCrashReportCrash => 'Choose a crash report (crash-reports) or log file (logs)';

  @override
  String get toolsPasteCrashReportLog2 => 'Paste a crash report or log someone sent you';

  @override
  String get toolsPaste => 'Paste';

  @override
  String get toolsLauncherFirstMatchesCommon =>
      'The launcher first matches common problems with local rules; after setting up your own AI service in Settings → AI, you can also have AI analyze logs. A prompt appears automatically when the game crashes.';

  @override
  String get toolsPlayer => 'Player';

  @override
  String toolsSLuckToday(Object name) {
    return '$name\'s luck today';
  }

  @override
  String get toolsFixedEachPlayerEach => 'Fixed for each player each day';

  @override
  String get toolsLaunchCount => 'Launch count';

  @override
  String toolsYouveLaunchedGameTimes(num launchCount) {
    String _temp0 = intl.Intl.pluralLogic(
      launchCount,
      locale: localeName,
      other: 'You\'ve launched the game $launchCount times with this launcher',
      one: 'You\'ve launched the game once with this launcher',
    );
    return '$_temp0';
  }

  @override
  String get toolsSave => 'Save to';

  @override
  String toolsDownload(Object name) {
    return 'Download $name';
  }

  @override
  String toolsDownloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get toolsDownloadAnyFileProgress => 'Download any file; progress shows on the Tasks page';

  @override
  String get toolsDownloadURL => 'Download URL';

  @override
  String get toolsFileNameOptional => 'File name (optional)';

  @override
  String get toolsSaveLocationChosenWhen => 'Save location: chosen when the download starts';

  @override
  String toolsSaveLocation(Object dir) {
    return 'Save location: $dir';
  }

  @override
  String get toolsStartDownload => 'Start download';

  @override
  String get toolsSkinImage => 'Skin image';

  @override
  String toolsSaved(Object path) {
    return 'Saved $path';
  }

  @override
  String get toolsPlayerSkins => 'Player skins';

  @override
  String get toolsMinecraftPlayerName => 'Minecraft player name';

  @override
  String get toolsGet => 'Get';

  @override
  String get toolsAlexModelSlimArms => 'Alex model (slim arms)';

  @override
  String get toolsSteveModel => 'Steve model';

  @override
  String get toolsSaveSkin => 'Save skin';

  @override
  String get toolsAvatarMaker => 'Avatar maker';

  @override
  String get toolsCropsHeadHatLayer =>
      'Crops the head (with the hat layer) from a skin and scales it up; works with the skin fetched above or a local skin file';

  @override
  String get toolsChooseLocalSkin => 'Choose local skin';

  @override
  String toolsLocal(Object localName) {
    return 'Local: $localName';
  }

  @override
  String toolsSaveAvatar(Object size) {
    return 'Save $size×$size avatar';
  }

  @override
  String get toolsFetchPlayersSkinChoose => 'Fetch a player\'s skin or choose a local skin first';

  @override
  String get toolsServerAddress => 'Server address';

  @override
  String get toolsMcExampleCom1 => 'mc.example.com or 1.2.3.4:25565';

  @override
  String get toolsLookUp => 'Look up';

  @override
  String toolsOnlineMsLatency(Object online, Object max, Object version, Object latency) {
    return '$online / $max online · $version · $latency ms latency';
  }

  @override
  String get toolsAchievementGet => 'Achievement get!';

  @override
  String get toolsFillTitleFirstLine => 'Fill in the title and the first line';

  @override
  String get toolsMakesMinecraftStyleAchievement =>
      'Makes a Minecraft-style achievement toast image. It\'s generated by the third-party service minecraft-api.com when possible (the text you enter is sent to it); if the service refuses, it\'s drawn locally with system fonts and the icon you chose';

  @override
  String get toolsItemIDOnline => 'Item ID (online)';

  @override
  String get toolsEGDiamondGrass => 'e.g. diamond, grass, golden_apple';

  @override
  String get toolsIcon => 'Icon';

  @override
  String get toolsIconLocalDrawing => 'Icon (local drawing)';

  @override
  String get toolsTitle => 'Title';

  @override
  String get toolsFirstLine => 'First line';

  @override
  String get toolsSecondLineOptional => 'Second line (optional)';

  @override
  String get toolsGenerate => 'Generate';

  @override
  String get toolsSaveImage => 'Save image';

  @override
  String get toolsOnlineServiceIsntAvailable => 'The online service isn\'t available; drawn locally below';

  @override
  String get fileManagerSave => 'Save';

  @override
  String get fileManagerEnterValidFileName => 'Enter a valid file name';

  @override
  String get fileManagerFolderSameNameAlready => 'A folder with the same name already exists';

  @override
  String get fileManagerReplaceExistingFile => 'Replace the existing file?';

  @override
  String fileManagerAlreadyExistsFolderSaving(Object name) {
    return '“$name” already exists in this folder; saving will replace it.';
  }

  @override
  String get fileManagerReplace => 'Replace';

  @override
  String get fileManagerName => 'Name';

  @override
  String get fileManagerOK => 'OK';

  @override
  String get fileManagerNamesCantContain => 'Names can\'t contain / or \\';

  @override
  String get fileManagerNewFolder => 'New folder';

  @override
  String get fileManagerFileFolderSameName => 'A file or folder with the same name already exists';

  @override
  String get fileManagerRename => 'Rename';

  @override
  String get fileManagerDeletePermanently => 'Delete permanently';

  @override
  String fileManagerWillPermanentlyDeletedCant(Object name) {
    return '“$name” will be permanently deleted and can\'t be recovered.';
  }

  @override
  String fileManagerMovedRecycleBin(Object name) {
    return '“$name” moved to the recycle bin';
  }

  @override
  String get fileManagerCantPasteFolderInto => 'Can\'t paste a folder into itself';

  @override
  String fileManagerPasting(Object done, Object total) {
    return 'Pasting ($done / $total)';
  }

  @override
  String get commonCopy => 'Copy';

  @override
  String fileManagerImportedFiles(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count files',
      one: 'Imported 1 file',
    );
    return '$_temp0';
  }

  @override
  String get fileManagerLargeFileOnlyFirst => '\n\n… (large file; only the first 512 KB is shown)';

  @override
  String fileManagerCantRead(Object error) {
    return 'Can\'t read: $error';
  }

  @override
  String get fileManagerKindFileCantPreviewed =>
      'This kind of file can\'t be previewed. You can copy, cut, rename or delete it';

  @override
  String get fileManagerAppData => 'App data';

  @override
  String get fileManagerRecycleBin => 'Recycle bin';

  @override
  String get fileManagerUp => 'Up';

  @override
  String get fileManagerImportFilesFromPhone => 'Import files from phone';

  @override
  String fileManagerOpenDestinationFolderPaste(Object cut, Object paths, Object length) {
    return '$cut: “$paths”$length. Open the destination folder and paste';
  }

  @override
  String get fileManagerCut => 'Cut';

  @override
  String fileManagerMore(Object count) {
    return ' and $count more';
  }

  @override
  String get fileManagerPasteHere => 'Paste here';

  @override
  String fileManagerFolder(Object confirm) {
    return '$confirm this folder';
  }

  @override
  String fileManagerTapFile(Object confirm) {
    return '$confirm: tap a file';
  }

  @override
  String fileManagerTapFile2(Object e, Object confirm) {
    return '$confirm: tap a $e file';
  }

  @override
  String get fileManagerFileName => 'File name';

  @override
  String get fileManagerSaveHere => 'Save here';

  @override
  String get fileManagerLocation => 'Location';

  @override
  String get fileManagerChooseFolder => 'Choose folder';

  @override
  String fileManagerChoose(Object label) {
    return 'Choose $label';
  }

  @override
  String fileManagerSave2(Object label) {
    return 'Save $label';
  }

  @override
  String get fileManagerAccessingPhoneStorageRequires =>
      'Accessing phone storage requires the “All files access” permission';

  @override
  String fileManagerCantOpenFolder(Object error) {
    return 'Can\'t open this folder: $error';
  }

  @override
  String get fileManagerGrantPermission => 'Grant permission';

  @override
  String get fileManagerEmptyFolder => 'Empty folder';

  @override
  String get fileManagerMoreActions => 'More actions';

  @override
  String lanTransferReceivedFrom(Object from, Object version) {
    return 'Received “$version” from $from';
  }

  @override
  String lanTransferCouldntStartReceiving(Object e) {
    return 'Couldn\'t start receiving: $e';
  }

  @override
  String get lanTransferImportAsNewInstance => 'Import as new instance';

  @override
  String lanTransferImportAsNewInstance2(Object version, Object count, Object size, Object parents) {
    return 'Import “$version” as a new instance with instance isolation on.\n$count files, $size.\n\n${parents}Libraries and assets the game needs weren\'t transferred; they\'re downloaded automatically at first launch.';
  }

  @override
  String lanTransferVanillaVersionDependsImported(Object parents) {
    return 'The vanilla version $parents it depends on is imported too (an existing local copy is kept).\n';
  }

  @override
  String lanTransferImporting(Object version) {
    return 'Importing “$version”';
  }

  @override
  String lanTransferImportedInstance(Object id) {
    return 'Imported instance “$id”';
  }

  @override
  String lanTransferImportingInto(Object id) {
    return 'Importing into “$id”';
  }

  @override
  String lanTransferImportedInto(Object id) {
    return 'Imported into “$id”';
  }

  @override
  String lanTransferImportedIntoPreviousContents(Object id, Object backup) {
    return 'Imported into “$id”; the previous contents were backed up to $backup';
  }

  @override
  String lanTransferImportFailed(Object e) {
    return 'Import failed: $e';
  }

  @override
  String get lanTransferPreparing => 'Preparing…';

  @override
  String get lanTransferNoInstancesYetInstall => 'No instances yet; install one before importing';

  @override
  String get lanTransferSendersInstance => 'Sender\'s instance';

  @override
  String lanTransferTheseModsComeFrom(Object from, Object id, Object v) {
    return 'These mods come from $from, but “$id” is $v, so they won\'t load after importing. Install the same loader on this device first, or ask the sender to send the whole instance.';
  }

  @override
  String lanTransferSendersInstanceLoadersDiffer(Object from, Object id, Object v) {
    return 'The sender\'s instance is $from and “$id” is $v; the loaders differ.';
  }

  @override
  String lanTransferSendersInstanceGameVersions(Object from, Object id, Object v) {
    return 'The sender\'s instance is $from and “$id” is $v; the game versions differ, so mods and worlds may not be compatible.';
  }

  @override
  String get lanTransferImportIntoWhichInstance => 'Import into which instance';

  @override
  String lanTransferReplacesInstancesPreviousContents(Object what) {
    return 'This replaces the instance\'s: $what\nThe previous contents are backed up to backups in the game folder first.';
  }

  @override
  String get lanTransferChooseInstanceSend => 'Choose an instance to send';

  @override
  String get lanTransferPairingCode6Digits => 'The pairing code is 6 digits';

  @override
  String get lanTransferConnecting => 'Connecting…';

  @override
  String lanTransferConnectedPacking(Object name) {
    return 'Connected to $name; packing…';
  }

  @override
  String lanTransferPackingFilesAdded(Object n) {
    return 'Packing… $n files added';
  }

  @override
  String lanTransferSending(Object size) {
    return 'Sending $size…';
  }

  @override
  String lanTransferSent(Object size, Object reply) {
    return 'Sent ($size): $reply';
  }

  @override
  String lanTransferSendingFailed(Object e) {
    return 'Sending failed: $e';
  }

  @override
  String get lanTransferTransferInstancesModsConfigs =>
      'Transfer instances, mods, configs and worlds between two devices on the same local network (same Wi-Fi).';

  @override
  String get lanTransferReceive => 'Receive';

  @override
  String get lanTransferAfterYouStartReceiving =>
      'After you start receiving, enter the address and pairing code shown below on the other device. Leaving this page stops receiving.';

  @override
  String get lanTransferStartReceiving => 'Start receiving';

  @override
  String get lanTransferPairingCode => 'Pairing code';

  @override
  String get lanTransferAddressIPPort => 'Address (IP:port)';

  @override
  String get lanTransferNoLocalNetworkAddress =>
      'No local network address found; make sure Wi-Fi or Ethernet is connected';

  @override
  String get lanTransferIfThereSeveralAddresses =>
      'If there are several addresses, it\'s usually the one starting with 192.168';

  @override
  String get lanTransferIfWindowsFirewallAsks =>
      'If Windows Firewall asks, allow Pixel World to access private networks';

  @override
  String lanTransferReceiving(Object size, Object size2) {
    return 'Receiving $size / $size2';
  }

  @override
  String get lanTransferStopReceiving => 'Stop receiving';

  @override
  String lanTransferWholeInstance(Object version) {
    return 'Whole instance “$version”';
  }

  @override
  String lanTransferText(Object version, Object i) {
    return '$i of “$version”';
  }

  @override
  String lanTransferFrom(Object from, Object address, Object describe, Object size) {
    return 'From $from ($address)$describe, $size';
  }

  @override
  String get lanTransferNoInstancesSendYet => 'No instances to send yet';

  @override
  String get lanTransferChooseContent => 'Choose content';

  @override
  String get lanTransferWholeInstance2 => 'Whole instance';

  @override
  String get lanTransferPacksInstanceFolderWithout =>
      'Packs the instance folder (without logs and crash reports). The receiver imports it as a new instance with instance isolation on.\nIf this instance doesn\'t use instance isolation, the content selected below is included too.';

  @override
  String get lanTransferReceiverReplacesSelectedContent =>
      'The receiver replaces the selected content when importing, after backing it up automatically.';

  @override
  String get lanTransferReceiversAddress => 'Receiver\'s address';

  @override
  String fileManagerFailed(Object label, Object error) {
    return '$label failed: $error';
  }

  @override
  String get aiGameClosesRightAfter => 'The game closes right after launching. Where should I look for the cause?';

  @override
  String get aiWhatSomeCommonPerformance => 'What are some common performance mods for Fabric 1.20.1?';

  @override
  String get aiWhatsDifferenceBetweenForge => 'What\'s the difference between Forge and NeoForge?';

  @override
  String get aiHowDoIGive => 'How do I give an instance more memory?';

  @override
  String aiCrashAnalysis(Object title) {
    return 'Crash analysis · $title';
  }

  @override
  String get aiSendFollowing => 'Send the following';

  @override
  String aiCharactersWillSentModel(Object count, Object host, Object model) {
    return '$count characters will be sent to $host (model $model). Player names, tokens, UUIDs, user folders and IP addresses have been replaced.';
  }

  @override
  String get aiDontAskAgain => 'Don\'t ask again';

  @override
  String get aiDeleteConversation => 'Delete conversation';

  @override
  String aiDeleteCantUndone(Object title) {
    return 'Delete “$title”? This can\'t be undone.';
  }

  @override
  String get aiYesterday => 'Yesterday';

  @override
  String aiDaysAgo(num days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days ago', one: '1 day ago');
    return '$_temp0';
  }

  @override
  String aiMonthDay(Object month, Object day) {
    return '$month/$day';
  }

  @override
  String get aiNewChat => 'New chat';

  @override
  String get aiHistory => 'History';

  @override
  String get aiNoConversationsYet => 'No conversations yet';

  @override
  String get aiAnswering => 'Answering…';

  @override
  String get aiCompactContextSummarizeEarlier => 'Compact context: summarize earlier messages';

  @override
  String get aiConversationShortNoNeed => 'The conversation is short; no need to compact yet';

  @override
  String get aiAISettings => 'AI settings';

  @override
  String get commonHideSidePanel => 'Hide side panel';

  @override
  String get aiShowSidePanelEnvironment => 'Show side panel (environment, context, files)';

  @override
  String get aiCompactingContext => 'Compacting context…';

  @override
  String get aiThinking => 'Thinking…';

  @override
  String get aiAskQuestion => 'Ask a question';

  @override
  String get aiActionRunningYouCan => 'An action is running; you can stop after it finishes';

  @override
  String get aiStop => 'Stop';

  @override
  String get aiHowCanIHelp => 'How can I help?';

  @override
  String get aiAskMeAboutMinecraft =>
      'Ask me about Minecraft and the launcher. When the game crashes, choosing “AI analysis” in Crash Analysis brings the logs along automatically.';

  @override
  String get aiSetUpAIService => 'Set up an AI service first';

  @override
  String get aiEnterAPIAddressModel => 'Enter the API address, model and API key of your own AI service';

  @override
  String aiShowAllCharacters(Object count) {
    return 'Show all ($count characters)';
  }

  @override
  String get aiRegenerate => 'Regenerate';

  @override
  String get aiDeny => 'Deny';

  @override
  String aiAllowConversation(Object label) {
    return 'Allow $label for this conversation';
  }

  @override
  String get aiAllow => 'Allow';

  @override
  String get aiRunning => 'Running';

  @override
  String get aiPreparing => 'Preparing';

  @override
  String get aiDenied => 'Denied';

  @override
  String get aiWaitingEarlierActions => 'Waiting for earlier actions';

  @override
  String get aiCanceled => 'Canceled';

  @override
  String aiInputOutputTokens(Object input, Object output) {
    return 'Input $input · output $output tokens';
  }

  @override
  String aiS(Object ms) {
    return '$ms s';
  }

  @override
  String aiRequests(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count requests', one: '1 request');
    return '$_temp0';
  }

  @override
  String get aiUsageReportedAIService =>
      'Usage is reported by the AI service and summed over multiple requests (e.g. tool calls); the time excludes waiting for your confirmation';

  @override
  String aiContextTokensIncludesSystem(Object estimated, Object used, Object window, Object summary) {
    return 'Context: $estimated$used / $window tokens\nIncludes the system prompt, tool descriptions and the conversation sent to the model$summary';
  }

  @override
  String get commonAbout => 'about ';

  @override
  String get aiEarlierPartsWereSummarized => ' (earlier parts were summarized)';

  @override
  String get aiConversationAboveWasSummarized => 'The conversation above was summarized';

  @override
  String get aiConversationSummary => 'Conversation summary';

  @override
  String get aiViewSummary => 'View summary';

  @override
  String get aiSettingsSaved => 'Saved';

  @override
  String aiSettingsFillAPIAddressModel(Object isLocal) {
    return 'Fill in the API address, the model$isLocal';
  }

  @override
  String get aiSettingsAPIKey => ', and the API key';

  @override
  String aiSettingsConnectedModelReplied(Object characters) {
    return 'Connected; the model replied: $characters';
  }

  @override
  String get aiSettingsClipboardEmpty => 'The clipboard is empty';

  @override
  String get aiSettingsPasted => 'Pasted';

  @override
  String get aiSettingsAPIReturnedNoUsable => 'The API returned no usable models';

  @override
  String get commonTestConnection => 'Test connection';

  @override
  String get aiSettingsPopularServices => 'Popular services';

  @override
  String get aiSettingsOpenAICompatibleAPI => 'OpenAI-compatible API';

  @override
  String get aiSettingsAnthropicAPI => 'Anthropic API';

  @override
  String get aiSettingsAPIAddress => 'API address';

  @override
  String aiSettingsOnlySentAPIAddress(Object available) {
    return '$available; only sent to the API address above. Services running on this machine can leave it empty';
  }

  @override
  String get aiSettingsStoredEncryptedDevice => 'Stored encrypted on this device';

  @override
  String get aiSettingsStoredLaunchersPrivateData => 'Stored in the launcher\'s private data folder (unencrypted)';

  @override
  String get aiSettingsHide => 'Hide';

  @override
  String get aiSettingsShow => 'Show';

  @override
  String get aiSettingsModel => 'Model';

  @override
  String get aiSettingsUseButtonRightFetch => 'Use the button on the right to fetch the available models';

  @override
  String get aiSettingsFetchModelList => 'Fetch model list';

  @override
  String get aiSettingsContextLengthTokens => 'Context length (tokens)';

  @override
  String aiSettingsEmptyAutomatic(Object defaultContextWindow) {
    return 'Empty for automatic: $defaultContextWindow';
  }

  @override
  String aiSettingsSeeYourProvidersDocs(Object defaultContextWindow) {
    return 'See your provider\'s docs; unknown models default to $defaultContextWindow';
  }

  @override
  String get aiSettingsCompactContextAutomatically => 'Compact context automatically';

  @override
  String get aiSettingsSummarizeEarlierMessagesOnce =>
      'Summarize earlier messages once the limit is exceeded, to save cost';

  @override
  String get aiSettingsAbove32kTokens => 'Above 32k tokens';

  @override
  String get aiSettingsAbove64kTokens => 'Above 64k tokens';

  @override
  String get aiSettingsAbove128kTokens => 'Above 128k tokens';

  @override
  String get aiSettingsAbove256kTokens => 'Above 256k tokens';

  @override
  String get aiSettingsNever => 'Never';

  @override
  String get aiSettingsConfirmBeforeSending => 'Confirm before sending';

  @override
  String get aiSettingsShowLogEnvironmentInfo => 'Show the log and environment info to be sent before each analysis';

  @override
  String get aiSettingsAllowAIUseTools => 'Allow AI to use tools';

  @override
  String get aiSettingsViewInstancesModsLogs =>
      'View instances, mods and logs, install or disable mods, search the web, and use the MCP services below; anything that changes content needs your confirmation';

  @override
  String get aiSettingsConfirmReadOnlyActions => 'Confirm read-only actions too';

  @override
  String get aiSettingsWhenOffAICan => 'When off, AI can view instances, mods, files and logs without confirmation';

  @override
  String get aiSettingsAITroubleshootingSettings => 'AI troubleshooting settings';

  @override
  String aiSettingsChooseModel(Object count) {
    return 'Choose a model ($count)';
  }

  @override
  String get aiSettingsNoMatchingModels => 'No matching models';

  @override
  String get aiMcpSettingsRemoveMCPService => 'Remove MCP service';

  @override
  String aiMcpSettingsRemoveItsSavedAccess(Object name) {
    return 'Remove “$name”? Its saved access token is deleted too.';
  }

  @override
  String get aiMcpSettingsReadOnlyActionsOnly => 'Read-only actions only';

  @override
  String get aiMcpSettingsPermissions => 'Permissions';

  @override
  String get aiMcpSettingsToolServicesMCP => 'Tool services (MCP)';

  @override
  String get aiMcpSettingsEverythingAIDoesGoes =>
      'Everything the AI does goes through these services. Services set to “Read-only” reject any action that changes content without asking. External services are only ever connected to by the launcher; it doesn\'t open any ports.';

  @override
  String get commonBuilt => 'Built-in';

  @override
  String get aiMcpSettingsBuiltTurnedOffAbove => 'Built-in · turned off above';

  @override
  String get aiMcpSettingsTrustReadOnlyClaims => 'Trust read-only claims';

  @override
  String aiMcpSettingsConnectionFailed(Object split) {
    return 'Connection failed: $split';
  }

  @override
  String commonTools(num toolCount) {
    String _temp0 = intl.Intl.pluralLogic(toolCount, locale: localeName, other: '$toolCount tools', one: '1 tool');
    return '$_temp0';
  }

  @override
  String get aiMcpSettingsEdit => 'Edit';

  @override
  String get aiMcpSettingsAddMCPService => 'Add MCP service';

  @override
  String get aiMcpSettingsRefreshStatus => 'Refresh status';

  @override
  String get aiMcpSettingsEnterName => 'Enter a name';

  @override
  String get aiMcpSettingsLocalJarServicesCant => 'Local jar services can\'t run on Android yet';

  @override
  String get aiMcpSettingsChooseJarFile => 'Choose a jar file';

  @override
  String aiMcpSettingsConnectedToolsAvailable(Object server, Object count, Object names) {
    return 'Connected$server; $count tools available$names';
  }

  @override
  String get aiMcpSettingsJarFile => 'Jar file';

  @override
  String get aiMcpSettingsEditMCPService => 'Edit MCP service';

  @override
  String get aiMcpSettingsRemoteHTTP => 'Remote (HTTP)';

  @override
  String get aiMcpSettingsLocalJar => 'Local jar';

  @override
  String get aiMcpSettingsServiceURL => 'Service URL';

  @override
  String get aiMcpSettingsRemoteServicesNeedHttps =>
      'Remote services need https; local services (e.g. running in Termux) can use http://127.0.0.1:port/mcp';

  @override
  String get aiMcpSettingsAccessTokenOptional => 'Access token (optional)';

  @override
  String get aiMcpSettingsStoredEncryptedDeviceOnly =>
      'Stored encrypted on this device and only sent to this service (Authorization: Bearer)';

  @override
  String get aiMcpSettingsLaunchArgumentsOptional => 'Launch arguments (optional)';

  @override
  String get aiMcpSettingsSeparatedSpacesAppendedAfter =>
      'Separated by spaces and appended after java -jar file; Java is chosen by the launcher (Java 21)';

  @override
  String get aiMcpSettingsTrustServicesReadOnly => 'Trust this service\'s read-only claims';

  @override
  String get aiMcpSettingsWhenToolsServiceDeclares =>
      'When on, tools the service declares read-only run without confirmation; when off, each tool needs confirmation the first time it\'s used in a conversation. Tools declared as deleting content always need confirmation. Only turn this on for services you trust';

  @override
  String aiSidePanelFileGone(Object path) {
    return 'The file is gone: $path';
  }

  @override
  String get aiSidePanelNoModelSetUp => 'No model set up yet';

  @override
  String get aiSidePanelNoInstanceSelected => 'No instance selected';

  @override
  String get commonAIWorkspace => 'AI workspace';

  @override
  String get aiSidePanelText => 'On';

  @override
  String get aiSidePanelOff => 'Off';

  @override
  String get commonWebSearch => 'Web search';

  @override
  String get aiSidePanelNotConnected => 'Not connected';

  @override
  String get aiSidePanelContext => 'Context';

  @override
  String aiSidePanelUsed(Object window) {
    return '$window% used';
  }

  @override
  String get aiSidePanelCompact => 'Compact';

  @override
  String get aiSidePanelFilesConversation => 'Files in this conversation';

  @override
  String get aiSidePanelFilesAIWritesChanges => 'Files the AI writes or changes in this conversation appear here';

  @override
  String get aiSidePanelWorkspace => 'Workspace';

  @override
  String get aiSidePanelStillEmptyYouCan => 'Still empty. You can ask the AI to write its results here';

  @override
  String get aiWorkspaceSettingsLetAIAccessFolder => 'Let AI access this folder';

  @override
  String get aiWorkspaceSettingsFolderHasAlreadyBeen => 'This folder has already been added';

  @override
  String get aiWorkspaceSettingsAllowAccessWholeDrive => 'Allow access to the whole drive?';

  @override
  String aiWorkspaceSettingsRootDriveSoAI(Object real) {
    return '$real is the root of a drive, so the AI could see every file on it. It\'s better to add only the folders you need.';
  }

  @override
  String get aiWorkspaceSettingsAddAnyway => 'Add anyway';

  @override
  String get aiWorkspaceSettingsAIHasItsOwn =>
      'The AI has its own folder it can freely read and write, and can view the current instance\'s game files (read-only)';

  @override
  String get aiWorkspaceSettingsAfterGrantingAllFiles =>
      'After granting “All files access”, the AI can also read and write the system Download folder.';

  @override
  String get aiWorkspaceSettingsYouCanAddOther =>
      'You can add other folders too; they\'re read-only unless you turn on “Allow changes”.';

  @override
  String get aiWorkspaceSettingsAllowChanges => 'Allow changes';

  @override
  String get aiWorkspaceSettingsRemoveFolderIsntDeleted => 'Remove (the folder isn\'t deleted)';

  @override
  String get aiWorkspaceSettingsOpenWorkspace => 'Open workspace';

  @override
  String get aiWorkspaceSettingsAICanSearchWeb =>
      'The AI can search the web, open URLs and look things up on the Minecraft Wiki; requests follow the system proxy';

  @override
  String get aiWorkspaceSettingsSearchEngine => 'Search engine';

  @override
  String get aiWorkspaceSettingsSearXNGURL => 'SearXNG URL';

  @override
  String get aiWorkspaceSettingsInstanceNeedsJSONOutput => 'The instance needs JSON output enabled';

  @override
  String get aiWorkspaceSettingsExaAPIKeyOptional => 'Exa API key (optional)';

  @override
  String get aiWorkspaceSettingsSearchServiceAPIKey => 'Search service API key';

  @override
  String get aiWorkspaceSettingsWorksWithoutOneRate =>
      'Works without one, with rate limits; adding one raises the quota. Only sent to Exa';

  @override
  String get aiWorkspaceSettingsStoredSeparatelyFromModels =>
      'Stored separately from the model\'s key and only sent to the selected search service';

  @override
  String installerAppInstall(Object name) {
    return 'Install $name';
  }

  @override
  String installerAppUninstall(Object name) {
    return 'Uninstall $name';
  }

  @override
  String get installerAppUninstalling => 'Uninstalling…';

  @override
  String get installerAppUpdate => 'Update';

  @override
  String installerAppVersionInstalledCurrentUser(Object version) {
    return 'Version $version · installed for the current user only; no administrator rights needed';
  }

  @override
  String get installerAppInstallLocation => 'Install location';

  @override
  String get installerAppAddStartMenu => 'Add to Start menu';

  @override
  String installerAppThirdPartyMinecraftLauncher(Object name) {
    return '$name is a third-party Minecraft launcher and isn\'t affiliated with Mojang or Microsoft.';
  }

  @override
  String get installerAppUpdating => 'Updating';

  @override
  String get installerAppInstalling => 'Installing';

  @override
  String get installerAppInstallationComplete => 'Installation complete';

  @override
  String installerAppInstalled(Object dir) {
    return 'Installed to $dir';
  }

  @override
  String installerAppLaunch(Object name) {
    return 'Launch $name';
  }

  @override
  String get installerAppInstallationFailed => 'Installation failed';

  @override
  String get installerAppOnlyFilesWrittenDuring =>
      'Only the files written during installation are deleted; other files in the program folder are left alone';

  @override
  String get installerAppAlsoDeleteLauncherData => 'Also delete launcher data';

  @override
  String installerAppSettingsAccountsDefaultGame(Object userDataDirs) {
    return 'Settings, accounts and the default game folder ($userDataDirs). Worlds in the default game folder are deleted too';
  }

  @override
  String get installerAppUninstall2 => 'Uninstall';

  @override
  String get installerAppUninstalling2 => 'Uninstalling';

  @override
  String get installerAppUninstallFailed => 'Uninstall failed';

  @override
  String installerCoreRunningCloseBeforeInstalling(Object name) {
    return '$name is running; close it before installing';
  }

  @override
  String installerCoreCouldntCreateShortcut(Object path) {
    return 'Couldn\'t create the shortcut: $path';
  }

  @override
  String get installerCoreCouldntWriteUninstallInformation => 'Couldn\'t write the uninstall information';

  @override
  String get installerCoreCantInstallIntoInstallers => 'Can\'t install into the installer\'s own folder';

  @override
  String installerCoreCopying(Object rel) {
    return 'Copying $rel';
  }

  @override
  String get installerCoreFinishingInstallation => 'Finishing installation…';

  @override
  String get installerCoreInstallManifestWasntFound =>
      'The install manifest wasn\'t found, so the files to remove can\'t be determined';

  @override
  String appStateRemovedFilesFoldersCreated(Object removed) {
    return 'Removed $removed files or folders created by this task';
  }

  @override
  String appStateInstall(Object fileName) {
    return 'Install $fileName';
  }

  @override
  String get commonResolveDependencies => 'Resolve dependencies';

  @override
  String get commonDownloadFiles => 'Download files';

  @override
  String appStateInstalledFilesSkippedExisting(Object count, Object count2, Object missing) {
    return 'Installed $count files, skipped $count2 existing files$missing';
  }

  @override
  String appStateNoCompatibleDependencyFound(Object missing) {
    return '; no compatible dependency found: $missing';
  }

  @override
  String appStateInstallModpack(Object name) {
    return 'Install modpack $name';
  }

  @override
  String get commonDownloadModpack => 'Download modpack';

  @override
  String get commonInstallGameLoader => 'Install game and loader';

  @override
  String get commonDownloadModpackFiles => 'Download modpack files';

  @override
  String get commonExtractModpackConfigs => 'Extract modpack configs';

  @override
  String appStateInstalledAs(Object id) {
    return 'Installed as $id';
  }

  @override
  String appStateInstallModpack2(Object path) {
    return 'Install modpack $path';
  }

  @override
  String get commonReadModpack => 'Read modpack';

  @override
  String appStateAddOptiFine(Object id) {
    return 'Add OptiFine to $id';
  }

  @override
  String get appStateInvalidInstanceName => 'Invalid instance name';

  @override
  String appStateInstall2(Object loaderVersion) {
    return 'Install $loaderVersion';
  }

  @override
  String get appStateGameAlreadyRunning => 'The game is already running';

  @override
  String get appStateChooseInstanceFirst => 'Choose an instance first';

  @override
  String get appStateAddAccountFirst => 'Add an account first';

  @override
  String appStateLaunch(Object id) {
    return 'Launch $id';
  }

  @override
  String get appStateCheckFiles => 'Check files';

  @override
  String get appStatePrepareLaunch => 'Prepare launch';

  @override
  String get appStateStartGame => 'Start game';

  @override
  String get appStateVerifyAccount => 'Verify account';

  @override
  String get appStateAnalyzeInstance => 'Analyze instance';

  @override
  String get appStateExtractNativeLibraries => 'Extract native libraries';

  @override
  String appStateJavaAndroidJava(Object path, Object major) {
    return 'Java: $path (Android Java $major)';
  }

  @override
  String appStateMemoryGB(Object max) {
    return 'Memory: $max GB';
  }

  @override
  String appStateWorkingDirectory(Object gameDir) {
    return 'Working directory: $gameDir';
  }

  @override
  String appStateRenderScale(Object renderScale) {
    return 'Render scale: $renderScale%';
  }

  @override
  String appStateGPU(Object gpu) {
    return 'GPU: $gpu';
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
    return 'Renderer: $renderer ($reason)$sfpew$turnip, LWJGL $lwjgl$lwjgl2$sdl';
  }

  @override
  String get appStateSFPEWFixedFunctionEmulation => ' + SFPEW (fixed-function emulation)';

  @override
  String get appStateTurnipDriver => ' + Turnip driver';

  @override
  String get appStateLWJGL2CompatibilityLayer => ' (LWJGL 2 compatibility layer)';

  @override
  String get appStateWarningDeviceDoesntReport =>
      'Warning: this device doesn\'t report Vulkan 1.1, so the selected renderer may fail to start';

  @override
  String get appStateTouchControllerModDetectedUsing => 'TouchController mod detected: using its touch controls';

  @override
  String get appStateWarningKryptonWrapperCrashes =>
      'Warning: Krypton Wrapper crashes on 26.3 snapshots and later; switch to MobileGlues if you run into problems';

  @override
  String appStateGameExitedCode(Object code) {
    return 'Game exited with code $code';
  }

  @override
  String appStateLaunch2(Object id) {
    return 'Launch - $id';
  }

  @override
  String appStateJavaJavaBit(Object path, Object major, Object is64) {
    return 'Java: $path (Java $major, $is64-bit)';
  }

  @override
  String appStateMemoryGB2(Object max, Object initial) {
    return 'Memory: $max GB$initial';
  }

  @override
  String appStateInitialGB(Object initial) {
    return ', initial $initial GB';
  }

  @override
  String appStateLaunchFailed(Object e) {
    return 'Launch failed: $e';
  }

  @override
  String get appStateGameCrashedSeeCrash => 'The game crashed; see Crash Analysis for the cause';

  @override
  String appStateCouldntCollectCrashInformation(Object e) {
    return 'Couldn\'t collect crash information: $e';
  }

  @override
  String get appInfoPixelWorldLauncher => 'Pixel World Launcher';

  @override
  String get crashEnvironment => '## Environment';

  @override
  String get crashInitialFindingsFromLaunchers => '## Initial findings from the launcher\'s local rules';

  @override
  String crashEnabledModFiles(Object count) {
    return '## Enabled mod files ($count)';
  }

  @override
  String crashCrashReport(Object path) {
    return 'Crash report $path';
  }

  @override
  String crashJVMErrorLog(Object path) {
    return 'JVM error log $path';
  }

  @override
  String get crashGameOutput => 'Game output';

  @override
  String crashInstance(Object versionId, Object description) {
    return 'Instance: $versionId ($description)';
  }

  @override
  String crashLoader(Object loaderLibs) {
    return 'Loader: $loaderLibs';
  }

  @override
  String crashAllocatedMemoryGB(Object memoryGb) {
    return 'Allocated memory: $memoryGb GB';
  }

  @override
  String crashSystem(Object operatingSystem, Object operatingSystemVersion) {
    return 'System: $operatingSystem $operatingSystemVersion';
  }

  @override
  String crashExitCode(Object exitCode) {
    return 'Exit code: $exitCode';
  }

  @override
  String crashMoreCharactersOmitted(Object max, Object max2) {
    return '$max\n... ($max2 more characters omitted)';
  }

  @override
  String crashPreviousLineRepeatedTimes(Object repeat) {
    return '(previous line repeated $repeat times)';
  }

  @override
  String crashLinesOmitted(Object skipped) {
    return '... ($skipped lines omitted)';
  }

  @override
  String crashCharactersOmitted(Object head, Object budget, Object end) {
    return '$head\n... ($budget characters omitted)\n$end';
  }

  @override
  String get crashToken => '<token>';

  @override
  String crashToken2(Object m) {
    return '$m <token>';
  }

  @override
  String get crashPlayer => '<player>';

  @override
  String crashUser(Object m) {
    return '$m<user>';
  }

  @override
  String get crashJavaVersionTooOld => 'Java version too old';

  @override
  String crashJavaNewerRequiredBut(Object version, Object version2) {
    return 'Java $version or newer is required, but the current Java only supports up to Java $version2. Choose a newer Java in the instance settings.';
  }

  @override
  String get crashSomeModsGameFiles =>
      'Some mods or game files need a newer Java; choose a newer Java in the instance settings.';

  @override
  String get crashJava8Required => 'Java 8 required';

  @override
  String get crashOldForge112 =>
      'Old Forge (1.12.2 and earlier) only runs on Java 8; choose Java 8 in the instance settings.';

  @override
  String get crashOutMemory => 'Out of memory';

  @override
  String get crashGameDoesntHaveEnough =>
      'The game doesn\'t have enough memory. Give the instance more memory in its settings, or use fewer mods, shaders and HD textures.';

  @override
  String get crashInvalidMemorySetting => 'Invalid memory setting';

  @override
  String get crashAllocatedMemoryExceedsLimit =>
      'The allocated memory exceeds the limit of the system or of 32-bit Java; lower it or switch to 64-bit Java.';

  @override
  String get crashMissingWrongDependency => 'Missing or wrong dependency';

  @override
  String get crashModsRequiredDependencyIsnt =>
      'A mod\'s required dependency isn\'t installed or doesn\'t meet the version requirement. Install or update the mods named in the log lines below.';

  @override
  String get crashDuplicateMods => 'Duplicate mods';

  @override
  String get crashSameModInstalledMore =>
      'The same mod is installed more than once (possibly different versions); delete the extra files.';

  @override
  String get crashMixinInjectionFailed => 'Mixin injection failed';

  @override
  String get crashUsuallyModsIncompatibleEach =>
      'Usually mods are incompatible with each other, or with the current Minecraft or loader version. The log names the mod at fault.';

  @override
  String get crashModsDontMatchLoader => 'Mods don\'t match the loader';

  @override
  String get crashModsAnotherLoaderInstalled => 'Mods for another loader are installed, e.g. Forge mods on Fabric.';

  @override
  String get crashOptiFineIncompatible => 'OptiFine incompatible';

  @override
  String get crashOptiFineIsntCompatibleCurrent =>
      'OptiFine isn\'t compatible with the current Forge or with other mods. Switch to the Forge version OptiFine requires, or remove OptiFine.';

  @override
  String get crashGraphicsDriverProblem => 'Graphics driver problem';

  @override
  String get crashGraphicsDriverDoesntSupport =>
      'The graphics driver doesn\'t support the game or failed. Update it from the GPU vendor\'s website; on laptops, let the game use the discrete GPU.';

  @override
  String get crashMainClassNotFound => 'Main class not found';

  @override
  String get crashGameFilesMayIncomplete =>
      'Game files may be incomplete, or the path contains special characters. Try repairing the files or using a folder without special characters.';

  @override
  String get crashManuallyTriggeredCrash => 'Manually triggered crash';

  @override
  String get crashDebugCrashTriggeredHolding => 'This is a debug crash triggered by holding F3 + C, not an error.';

  @override
  String get crashModSuspectedCrashReport => 'Mod suspected by the crash report';

  @override
  String get crashCrashReportNamesMod =>
      'The crash report names a mod that may have caused the crash; try disabling it first.';

  @override
  String get taskCancelingTask => 'Canceling task…';

  @override
  String taskFilesDownload(num t) {
    String _temp0 = intl.Intl.pluralLogic(
      t,
      locale: localeName,
      other: '$t files to download',
      one: '1 file to download',
    );
    return '$_temp0';
  }

  @override
  String taskFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String javaGetJavaRuntime(Object component) {
    return 'Get Java runtime ($component)';
  }

  @override
  String javaDownloadJavaRuntime(Object component, Object useMirror) {
    return 'Download Java runtime ($component, $useMirror)';
  }

  @override
  String javaDownloadedFiles(Object done, Object total) {
    return 'Downloaded $done / $total files';
  }

  @override
  String javaAverageS(Object speed) {
    return ' · average $speed/s';
  }

  @override
  String get javaGetJava8Azul => 'Get Java 8 (Azul Zulu, Apple silicon)';

  @override
  String get javaDownloadJava8Azul => 'Download Java 8 (Azul Zulu)';

  @override
  String get javaJava8DownloadFailed => 'Java 8 download failed verification (SHA-256 mismatch)';

  @override
  String get javaExtractJava8 => 'Extract Java 8';

  @override
  String javaCouldntExtractJava8(Object stderr) {
    return 'Couldn\'t extract Java 8: $stderr';
  }

  @override
  String get javaJava8ArchiveHas => 'The Java 8 archive has an unrecognized layout';

  @override
  String javaJavaPathDoesntExist(Object path) {
    return 'Java path doesn\'t exist: $path';
  }

  @override
  String javaCantRunJava(Object path) {
    return 'Can\'t run Java: $path';
  }

  @override
  String javaInstanceStartsThroughLaunchWrapper(Object javaMajor) {
    return 'This instance starts through LaunchWrapper (Forge 1.12.2 and earlier, OptiFine, LiteLoader, etc.), which only runs on Java 8; with Java $javaMajor it will probably crash while loading.';
  }

  @override
  String get javaUseEnsureAndroidJavaAndroid => 'Use ensureAndroidJava on Android';

  @override
  String javaJavaSetDoesntExist(Object where, Object path) {
    return 'The Java set $where doesn\'t exist: $path. Choose Java again or switch to automatic';
  }

  @override
  String javaJavaSetButInstance(Object where, Object major, Object major2) {
    return 'Java $major is set $where, but this instance needs at least Java $major2. Choose Java again or switch to automatic';
  }

  @override
  String get javaInstanceSettings => 'in the instance settings';

  @override
  String get javaGlobalSettings => 'in the global settings';

  @override
  String get javaDetectJava => 'Detect Java';

  @override
  String javaAutomaticallyDownloadedJavaOlder(Object major, Object major2) {
    return 'The automatically downloaded Java $major is older than the required Java $major2';
  }

  @override
  String javaJavaWasntFoundSet(Object major, Object downloadError) {
    return 'Java $major wasn\'t found; set the Java path manually in settings$downloadError';
  }

  @override
  String javaAutomaticDownloadFailed(Object downloadError) {
    return ' (automatic download failed: $downloadError)';
  }

  @override
  String installFilesGeneratedInstallerMissing(Object missingLocal) {
    return 'Files generated by the installer are missing: $missingLocal; please reinstall this instance';
  }

  @override
  String get installDownloadGameLibraries => 'Download game and libraries';

  @override
  String get installDownloadAssetIndex => 'Download asset index';

  @override
  String get installDownloadAssets => 'Download assets';

  @override
  String get installOrganizeLegacyAssets => 'Organize legacy assets';

  @override
  String get installInstanceNameCantEmpty => 'The instance name can\'t be empty or contain \\ / : * ? \" < > ';

  @override
  String installInstanceNamedAlreadyExists(Object n) {
    return 'An instance named $n already exists';
  }

  @override
  String installDownload(Object component) {
    return 'Download $component';
  }

  @override
  String installInstall(Object component) {
    return 'Install $component';
  }

  @override
  String get installGetVersionInfo => 'Get version info';

  @override
  String installVersionNotFound(Object id) {
    return 'Version $id not found';
  }

  @override
  String installDownloadMinecraft(Object gameVersion) {
    return 'Download Minecraft $gameVersion';
  }

  @override
  String downloadDownloadFailed(Object url) {
    return 'Download failed: $url';
  }

  @override
  String downloadDownloadTooSlowRetrying(Object target) {
    return 'Download too slow; retrying from another server: $target';
  }

  @override
  String downloadVerificationFailedSHA1(Object path) {
    return 'Verification failed (SHA-1 mismatch): $path';
  }

  @override
  String downloadVerificationFailedSizeShould(Object size, Object count, Object path) {
    return 'Verification failed (size should be $size, actually $count): $path';
  }

  @override
  String downloadChunkSizeMismatch(Object path) {
    return 'Chunk size mismatch: $path';
  }

  @override
  String downloadSizeMismatchAfterMerging(Object path) {
    return 'Size mismatch after merging chunks: $path';
  }

  @override
  String downloadDownloadFailedHTTP(Object statusCode) {
    return 'Download failed (HTTP $statusCode)';
  }

  @override
  String downloadConnected(Object host, Object total) {
    return 'Connected to $host$total';
  }

  @override
  String downloadFileSizeMB(Object total) {
    return ', file size $total MB';
  }

  @override
  String get downloadServerDidntReportFile => ', the server didn\'t report the file size';

  @override
  String downloadDownloadTooSlowKB(Object secs) {
    return 'Download too slow ($secs KB/s)';
  }

  @override
  String get downloadNoDataReceived => 'No data received';

  @override
  String downloadIncompleteDownloadBytes(Object received, Object total) {
    return 'Incomplete download ($received / $total bytes)';
  }

  @override
  String downloadIncompleteDownloadExpectedBytes(Object size, Object received) {
    return 'Incomplete download (expected $size bytes, got $received)';
  }

  @override
  String downloadFilesFailedDownloadE(Object count, Object errors) {
    return '$count files failed to download, e.g. $errors';
  }

  @override
  String get modpackModpackDoesntSpecifyMinecraft => 'The modpack doesn\'t specify a Minecraft version';

  @override
  String get modpackNotValidModrinthModpack => 'Not a valid Modrinth modpack: modrinth.index.json is missing';

  @override
  String modpackInstallMinecraft(Object minecraft) {
    return 'Install Minecraft $minecraft';
  }

  @override
  String modpackModpackContainsUnsafePath(Object message) {
    return 'The modpack contains an unsafe path: $message';
  }

  @override
  String modpackSkippedUnneededFiles(Object skipped) {
    return 'Skipped $skipped unneeded files';
  }

  @override
  String modpackExtractedConfigOverrideFiles(Object extracted) {
    return 'Extracted $extracted config and override files';
  }

  @override
  String forgeDownloadInstaller(Object label) {
    return 'Download $label installer';
  }

  @override
  String forgeInstallerCorruptedInstallProfile(Object label) {
    return 'The $label installer is corrupted: install_profile.json is missing';
  }

  @override
  String forgeOfflineInstallFailedInstalling(Object e) {
    return 'Offline install failed; installing online instead: $e';
  }

  @override
  String forgeInstallerNeedsDownloadMojang(Object label) {
    return 'The $label installer needs to download Mojang mappings and can\'t install fully offline';
  }

  @override
  String forgeDownloadFilesNeededInstaller(Object label) {
    return 'Download files needed by the $label installer';
  }

  @override
  String forgeSomeFilesDidntDownload(Object e) {
    return 'Some files didn\'t download; leaving the retry to the installer: $e';
  }

  @override
  String forgeRunInstallerProcessingFiles(Object label) {
    return 'Run the $label installer (processing files; this may take a few minutes)';
  }

  @override
  String forgeRunInstallerDownloadingDependencies(Object label) {
    return 'Run the $label installer (downloading dependencies and processing files; this may take a few minutes)';
  }

  @override
  String forgeInstallerFailedExitCode(Object label, Object code, Object tail) {
    return 'The $label installer failed (exit code $code)\n$tail';
  }

  @override
  String forgeInstallerFailed(Object label, Object tail) {
    return 'The $label installer failed\n$tail';
  }

  @override
  String forgeSeveralNewVersionsAppeared(Object label, Object candidates) {
    return 'Several new versions appeared after running the $label installer ($candidates); can\'t tell which one it created';
  }

  @override
  String forgeInstallerDidntCreateNew(Object label) {
    return 'The $label installer didn\'t create a new version';
  }

  @override
  String forgeInstall(Object label) {
    return 'Install $label';
  }

  @override
  String forgeInstallerCorruptedMissing(Object label, Object install) {
    return 'The $label installer is corrupted: $install is missing';
  }

  @override
  String get modrinthShaderPacks => 'Shader packs';

  @override
  String get modrinthTooManyRequestsPlease => 'Too many requests; please try again later';

  @override
  String modrinthModrinthRequestFailed(Object statusCode) {
    return 'Modrinth request failed ($statusCode)';
  }

  @override
  String get modrinthResourceWasntFoundModrinth => 'The resource wasn\'t found on Modrinth';

  @override
  String get modrinthModpackInstallationWillCome => 'Modpack installation will come in a later version';

  @override
  String get modrinthChooseWorldInstallData => 'Choose the world to install the data pack into';

  @override
  String modrinthResolveDependencies(Object length) {
    return 'Resolve dependencies ($length)';
  }

  @override
  String get extraLoadersDownloadOptiFine => 'Download OptiFine';

  @override
  String get extraLoadersPutIntoModsFolder => 'Put into the mods folder';

  @override
  String extraLoadersPutInto(Object path) {
    return 'Put into $path';
  }

  @override
  String get extraLoadersDownloadOptiFineInstaller => 'Download the OptiFine installer';

  @override
  String get extraLoadersGenerateOptiFineLibrary => 'Generate the OptiFine library';

  @override
  String extraLoadersOptiFinePatcherFailedExit(Object code, Object tail) {
    return 'OptiFine Patcher failed (exit code $code)\n$tail';
  }

  @override
  String extraLoadersOptiFineInstallerCorruptedLaunchwrapper(Object lwVersion) {
    return 'The OptiFine installer is corrupted: launchwrapper-of-$lwVersion.jar is missing';
  }

  @override
  String get extraLoadersGetLabyModVersionList => 'Get the LabyMod version list';

  @override
  String loadersLiteLoaderNotFound(Object version) {
    return 'LiteLoader $version not found';
  }

  @override
  String get loadersLiteLoaderOnlySupports1 => 'LiteLoader only supports 1.12.2 and earlier';

  @override
  String get loadersInstallLiteLoader => 'Install LiteLoader';

  @override
  String loadersGetConfiguration(Object label) {
    return 'Get $label configuration';
  }

  @override
  String get loaderNamesUnknown => 'Unknown';

  @override
  String get optifineCompatWillInstalledAsSeparate => 'Will be installed as a separate OptiFine version';

  @override
  String optifineCompatGoesIntoModsAs(Object requiredForge) {
    return 'Goes into mods as a mod; made for Forge $requiredForge, newer Forge versions may not be compatible';
  }

  @override
  String get optifineCompatGoesIntoModsAs2 => 'Goes into mods as a mod';

  @override
  String get optifineCompatGoesIntoModsAs3 =>
      'Goes into mods as a mod; OptiFine doesn\'t officially support NeoForge, so it may not load';

  @override
  String get optifineCompatGoesIntoModsAs4 => 'Goes into mods as a mod; the OptiFabric mod is also needed to load it';

  @override
  String launchRunningPreLaunchCommand(Object command) {
    return 'Running the pre-launch command: $command';
  }

  @override
  String versionVersionIsntInstalled(Object id) {
    return 'Version $id isn\'t installed';
  }

  @override
  String get lanTransferModConfigs => 'Mod configs';

  @override
  String get lanTransferGameOptions => 'Game options';

  @override
  String get lanTransferUnsupportedTransferFormatUpdate =>
      'Unsupported transfer format; update both launchers to the same version';

  @override
  String get lanTransferInvalidTransferManifest => 'Invalid transfer manifest';

  @override
  String lanTransferInvalidInstanceName(Object version) {
    return 'Invalid instance name: $version';
  }

  @override
  String lanTransferInvalidDependencyVersionName(Object id) {
    return 'Invalid dependency version name: $id';
  }

  @override
  String get lanTransferTransferManifestContainsUnsupported => 'The transfer manifest contains unsupported content';

  @override
  String get lanTransferUnknownDevice => 'Unknown device';

  @override
  String get lanTransferChooseAtLeastOne => 'Choose at least one item';

  @override
  String get lanTransferNoneSelectedItemsExist => 'None of the selected items exist';

  @override
  String get lanTransferReceivedFileIsntPixel => 'The received file isn\'t a Pixel World transfer package';

  @override
  String get lanTransferTransferManifestCantRead => 'The transfer manifest can\'t be read';

  @override
  String get lanTransferTransferPackageMissingFiles =>
      'The transfer package is missing files; it may not have been fully transferred';

  @override
  String lanTransferTransferPackageContainsSymbolic(Object name) {
    return 'The transfer package contains a symbolic link: $name';
  }

  @override
  String lanTransferTransferPackageContainsFile(Object name) {
    return 'The transfer package contains a file not in the manifest: $name';
  }

  @override
  String lanTransferFileSizeDoesntMatch(Object name) {
    return 'File size doesn\'t match the manifest: $name';
  }

  @override
  String lanTransferInvalidTransferPackage(Object name) {
    return 'Invalid transfer package: $name';
  }

  @override
  String commonTemporaryFolderAlreadyExists(Object staging) {
    return 'The temporary folder already exists: $staging';
  }

  @override
  String lanTransferTransferPackageContainsDuplicate(Object rel) {
    return 'The transfer package contains a duplicate file: $rel';
  }

  @override
  String lanTransferFileSizeDoesntMatch2(Object rel) {
    return 'File size doesn\'t match the manifest: $rel';
  }

  @override
  String get lanTransferTransferPackageIsntWhole => 'This transfer package isn\'t a whole instance';

  @override
  String lanTransferInstanceNamedAlreadyExists(Object id) {
    return 'An instance named “$id” already exists; rename or delete it in the instance settings first';
  }

  @override
  String lanTransferTransferPackageHasNo(Object id) {
    return 'The transfer package has no version file $id.json';
  }

  @override
  String get lanTransferTransferPackageWholeInstance =>
      'This transfer package is a whole instance; import it as a new instance';

  @override
  String lanTransferWrongPairingCodeAttempts(num left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Wrong pairing code; $left attempts left',
      one: 'Wrong pairing code; 1 attempt left',
    );
    return '$_temp0';
  }

  @override
  String get lanTransferTooManyWrongPairing => 'Too many wrong pairing codes; the other device stopped receiving';

  @override
  String get lanTransferTooManyWrongPairing2 =>
      'Too many wrong pairing codes, so receiving stopped. Start receiving again when needed to get a new pairing code.';

  @override
  String get lanTransferOtherDeviceReceivingAnother =>
      'The other device is receiving another transfer; please try again later';

  @override
  String get lanTransferMissingFileSize => 'Missing file size';

  @override
  String get lanTransferFileTooLargeAt => 'The file is too large; at most 32 GB per transfer';

  @override
  String get lanTransferReceivedMoreDataThan => 'Received more data than declared';

  @override
  String lanTransferTransferInterruptedOnlyBytes(Object got, Object total) {
    return 'Transfer interrupted; only $got / $total bytes received';
  }

  @override
  String get lanTransferReceivedOtherDeviceWaiting =>
      'Received by the other device; waiting for it to confirm the import';

  @override
  String lanTransferReceivingFailed(Object e) {
    return 'Receiving failed: $e';
  }

  @override
  String get lanTransferAddressShouldIPPort => 'The address should be “IP:port”, e.g. 192.168.1.5:43567';

  @override
  String lanTransferConnectionFailed(Object statusCode) {
    return 'Connection failed ($statusCode)';
  }

  @override
  String get lanTransferOtherDevice => 'The other device';

  @override
  String lanTransferCantReachMakeSure(Object host, Object port) {
    return 'Can\'t reach $host:$port. Make sure both devices are on the same local network, the other device is receiving, and the firewall allows Pixel World to connect';
  }

  @override
  String lanTransferSendingFailed2(Object statusCode) {
    return 'Sending failed ($statusCode)';
  }

  @override
  String lanTransferTransferInterrupted(Object message) {
    return 'Transfer interrupted: $message';
  }

  @override
  String get toolboxPerfectScoreEverythingGoes => 'Perfect score! Everything goes your way today';

  @override
  String get toolboxGreatLuckEveryChest => 'Great luck: every chest has diamonds';

  @override
  String get toolboxPrettyLuckyGoodDay => 'Pretty lucky; a good day for a trip to the Nether';

  @override
  String get toolboxSteadyCalmNoLava => 'Steady and calm; no lava surprises while mining';

  @override
  String get toolboxSoSoRememberBring => 'So-so; remember to bring a few extra beds';

  @override
  String get toolboxWatchOutCreepersSave => 'Watch out for creepers, and save before heading out';

  @override
  String get toolboxGoodDayStayHome => 'A good day to stay home and farm';

  @override
  String get toolboxZeroBetterStayOut => 'Zero… better stay out of the mines today';

  @override
  String get toolboxOnlyWindowsSupportedNow => 'Only Windows is supported for now';

  @override
  String get toolboxCouldntCreateShortcut => 'Couldn\'t create the shortcut';

  @override
  String get toolboxEnterURLStartingHttp => 'Enter a URL starting with http or https';

  @override
  String toolboxConnect(Object host) {
    return 'Connect to $host';
  }

  @override
  String toolboxDownload(Object path) {
    return 'Download $path';
  }

  @override
  String toolboxSavedMB(Object path, Object done) {
    return 'Saved to $path ($done MB)';
  }

  @override
  String get toolboxPlayerNamesCanOnly => 'Player names can only contain letters, digits and underscores';

  @override
  String toolboxNoMinecraftPlayerNamed(Object n) {
    return 'No Minecraft player named $n';
  }

  @override
  String toolboxPlayerLookupFailed(Object s1) {
    return 'Player lookup failed ($s1)';
  }

  @override
  String toolboxCouldntGetSkinInfo(Object s2) {
    return 'Couldn\'t get skin info ($s2)';
  }

  @override
  String toolboxUsesDefaultSkin(Object n) {
    return '$n uses a default skin';
  }

  @override
  String toolboxCouldntDownloadSkin(Object s3) {
    return 'Couldn\'t download the skin ($s3)';
  }

  @override
  String get toolboxItemNotFoundCheck => 'Item not found; check the item ID';

  @override
  String toolboxGenerationFailed(Object status) {
    return 'Generation failed ($status)';
  }

  @override
  String get toolboxServerReturnedInvalidData => 'The server returned invalid data';

  @override
  String get toolboxInvalidServerAddress => 'Invalid server address';

  @override
  String toolboxCantConnect(Object e) {
    return 'Can\'t connect: $e';
  }

  @override
  String toolboxConnectionInterrupted(Object e) {
    return 'Connection interrupted: $e';
  }

  @override
  String get toolboxServerClosedConnection => 'The server closed the connection';

  @override
  String get toolboxConnectionTimedOut => 'Connection timed out';

  @override
  String androidRuntimeCouldntReadSystemLog(Object e) {
    return 'Couldn\'t read the system log: $e';
  }

  @override
  String get androidRuntimePixelWorldGameProcess =>
      '\n[Pixel World] The game process didn\'t start, or exited right after starting.\n';

  @override
  String androidRuntimeSystemLogLogcat(Object systemLog) {
    return '\n---------- System log (logcat) ----------\n$systemLog\n';
  }

  @override
  String get androidRuntimePixelWorldJarRunner => '[Pixel World] The jar runner process didn\'t start';

  @override
  String get androidRuntimePixelWorldJarRunner2 => '[Pixel World] The jar runner process exited before starting Java';

  @override
  String get androidRuntimeZinkOpenGLVulkan => 'Zink (OpenGL on Vulkan)';

  @override
  String get androidRuntimeKryptonWrapperRecommended => 'Krypton Wrapper (recommended)';

  @override
  String get androidRuntimeSystemGLESDriverGLES => 'System GLES driver (GLES-capable mods only)';

  @override
  String get androidRuntimeUsesKryptonWrapperDefault =>
      'Uses Krypton Wrapper by default; 26.x versions use MobileGlues, and GPUs without OpenGL ES 3 use Zink';

  @override
  String get androidRuntimeOpenGLOpenGLESSupports =>
      'OpenGL on OpenGL ES; supports all versions including 26.x (older versions automatically get SFPEW fixed-function emulation)';

  @override
  String get androidRuntimeMesaZinkFullOpenGL =>
      'Mesa Zink: full OpenGL 4.6, requires Vulkan 1.1. On Snapdragon (Adreno) it automatically uses the bundled open-source Turnip driver; useful when MobileGlues renders incorrectly';

  @override
  String get androidRuntimeNGGL4ESOpenGLOpenGL =>
      'NG-GL4ES: OpenGL on OpenGL ES, efficient, works with old and new versions, and can run Sodium and some shaders. Not available from the 26.3 snapshots yet';

  @override
  String get androidRuntimeUsesSystemGLESDriver =>
      'Uses the system GLES driver directly without translation. Vanilla Minecraft can\'t run this way';

  @override
  String get androidRuntimeNoVulkan => 'No Vulkan';

  @override
  String get androidRuntimeSetSettings => 'Set in settings';

  @override
  String get androidRuntimeGPUDoesntSupportOpenGL => 'GPU doesn\'t support OpenGL ES 3';

  @override
  String get androidRuntime26XVersionKrypton => '26.x version; Krypton Wrapper doesn\'t support it yet';

  @override
  String androidRuntimeExtractJava(Object major) {
    return 'Extract Java $major';
  }

  @override
  String androidRuntimeExtractingMB(Object size) {
    return 'Extracting $size MB…';
  }

  @override
  String androidRuntimeExtracting(Object total) {
    return 'Extracting $total%';
  }

  @override
  String androidRuntimeDownloadJava(Object major, Object name) {
    return 'Download Java $major ($name)';
  }

  @override
  String get androidRuntimeDownloadIsntValidArchive => 'The download isn\'t a valid archive';

  @override
  String androidRuntimeJavaDownloadedMBFrom(Object major, Object lengthSync, Object name) {
    return 'Java $major downloaded ($lengthSync MB, from $name)';
  }

  @override
  String androidRuntimeDownloadFailed(Object name, Object e) {
    return '$name download failed: $e';
  }

  @override
  String androidRuntimeJavaDownloadFailedTried(Object major, Object failures) {
    return 'Java $major download failed; tried GitHub and the mirror:\n$failures';
  }

  @override
  String androidRuntimeJavaSetIsntInstalled(Object where, Object home) {
    return 'The Java set $where isn\'t installed: $home. Download it on the Java page in settings, or switch to automatic';
  }

  @override
  String androidRuntimeJavaSetButInstance(Object where, Object major, Object requiredValue) {
    return 'Java $major is set $where, but this instance needs at least Java $requiredValue. Choose Java again or switch to automatic';
  }

  @override
  String get importInvalidEncryptedDataLength => 'Invalid encrypted data length';

  @override
  String get importUnrecognizedCNGProtectedData => 'Unrecognized CNG protected data';

  @override
  String get importPCLCEAccountKeys => 'PCL-CE account keys can only be decrypted on Windows';

  @override
  String get importPCLCEUserKey => 'PCL-CE user key UserKey.bin not found';

  @override
  String get importUnrecognizedUserKeyBinFormat => 'Unrecognized UserKey.bin format';

  @override
  String importUnsupportedUserKeyVersion(Object version) {
    return 'Unsupported UserKey version $version';
  }

  @override
  String get importOldEncryptionFormatImport => 'Old encryption format; import isn\'t supported';

  @override
  String importUnsupportedEncryptionVersion(Object version) {
    return 'Unsupported encryption version $version';
  }

  @override
  String get importNoPCLCEConfiguration => 'No PCL-CE configuration found (%APPDATA%\\PCLCE)';

  @override
  String get importIPProtocolPreference => 'IP protocol preference';

  @override
  String get importHighPerformanceGPU => 'High-performance GPU';

  @override
  String get importLauncherBehaviorAfterLaunch => 'Launcher behavior after launch';

  @override
  String get importJavaChoice => 'Java choice';

  @override
  String get importMemoryMode => 'Memory mode';

  @override
  String get importCustomMemory => 'Custom memory';

  @override
  String get importPreLaunchCommand => 'Pre-launch command';

  @override
  String get importWaitPreLaunchCommand => 'Wait for the pre-launch command';

  @override
  String get importVersionType => 'Version type';

  @override
  String get importWindowMode => 'Window mode';

  @override
  String get importMemoryJVMArgumentsInstance =>
      'Memory, JVM arguments, instance isolation and other settings are stored in the PCL-CE program folder; choose that folder to import them';

  @override
  String get importPCLCEFolder => 'PCL-CE folder';

  @override
  String importIncompleteAccountInfoSign(Object name) {
    return '$name (incomplete account info; sign in again under Accounts)';
  }

  @override
  String importAccountImportFailed(Object e) {
    return 'Account import failed: $e';
  }

  @override
  String backupBackupFileCorrupted(Object e) {
    return 'The backup file is corrupted: $e';
  }

  @override
  String get backupBackupWasntCreatedPixel => 'This backup wasn\'t created by Pixel World and can\'t be restored';

  @override
  String get backupInvalidBackupManifest => 'Invalid backup manifest';

  @override
  String backupBackupManifestContainsUnsafe(Object e) {
    return 'The backup manifest contains an unsafe path: $e';
  }

  @override
  String get backupBackupManifestContainsDuplicate => 'The backup manifest contains duplicate or nested paths';

  @override
  String get backupBackupSignatureMismatchBackup =>
      'Backup signature mismatch: the backup was modified or wasn\'t created on this device';

  @override
  String backupBackupContainsSymbolicLink(Object name) {
    return 'The backup contains a symbolic link and can\'t be restored: $name';
  }

  @override
  String backupBackupContainsUnsafePath(Object name) {
    return 'The backup contains an unsafe path: $name';
  }

  @override
  String backupBackupContainsFileNot(Object name) {
    return 'The backup contains a file not in the manifest: $name';
  }

  @override
  String backupBackupContainsDuplicateFile(Object name) {
    return 'The backup contains a duplicate file: $name';
  }

  @override
  String backupBackupContentsDontMatch(Object name) {
    return 'Backup contents don\'t match the manifest: $name';
  }

  @override
  String get backupBackupMissingFilesListed => 'The backup is missing files listed in the manifest';

  @override
  String backupBackupContainsSymbolicLink2(Object name) {
    return 'The backup contains a symbolic link: $name';
  }

  @override
  String backupFileContentsDontMatch(Object rel) {
    return 'File contents don\'t match the backup manifest: $rel';
  }

  @override
  String get networkCheckMojangOfficial => 'Mojang official';

  @override
  String get networkCheckGameLibraryDownloads => 'Game and library downloads';

  @override
  String get networkCheckGameLoaderDownloadsMainland => 'Game and loader downloads in mainland China';

  @override
  String get networkCheckMicrosoftSign => 'Microsoft sign-in';

  @override
  String get networkCheckMicrosoftAccountSign => 'Microsoft account sign-in';

  @override
  String get networkCheckModsModpacksResourcePacks => 'Mods, modpacks and resource packs';

  @override
  String get networkCheckPixelWorldUpdates => 'Pixel World updates';

  @override
  String get networkCheckUpdateChecksAnnouncementsDocs => 'Update checks, announcements and docs';

  @override
  String get networkCheckTimedOut => 'Timed out';

  @override
  String get networkCheckSecureConnectionFailed => 'Secure connection failed';

  @override
  String networkCheckConnectionFailed(Object error) {
    return 'Connection failed ($error)';
  }

  @override
  String get microsoftMicrosoftAccountDoesntHave => 'This Microsoft account doesn\'t have an Xbox profile yet';

  @override
  String get microsoftUnderageAccountsNeedJoin => 'Underage accounts need to join a family group before signing in';

  @override
  String microsoftMinecraftRejectedAzureApp(Object status) {
    return 'Minecraft rejected this Azure app ($status Invalid app registration). New apps must first pass Mojang\'s review (https://aka.ms/mce-reviewappid); after approval, sign in again with the same client ID. It may take a while to take effect right after approval';
  }

  @override
  String microsoftRequestFailed(Object status, Object url, Object reason) {
    return 'Request failed ($status): $url$reason';
  }

  @override
  String get microsoftAccountDoesntOwnMinecraft => 'This account doesn\'t own Minecraft: Java Edition';

  @override
  String microsoftCouldntGetProfile(Object status, Object reason) {
    return 'Couldn\'t get the profile ($status)$reason';
  }

  @override
  String get microsoftSetAzureAppClient => 'Set an Azure app client ID in Settings → Other first';

  @override
  String microsoftSignAccountHasExpired(Object name) {
    return 'The sign-in for account $name has expired (imported from PCL-CE and can\'t be renewed); add it again with Microsoft sign-in';
  }

  @override
  String get microsoftMicrosoftAccountHasExpired => 'The Microsoft account has expired; please sign in again';

  @override
  String get docsOverview => 'Overview';

  @override
  String get docsDownloadInstall => 'Download and install';

  @override
  String get docsFirstLaunch => 'First launch';

  @override
  String get docsVersionsLoaders => 'Versions and loaders';

  @override
  String get docsAndroid => 'Android';

  @override
  String get docsFAQTroubleshooting => 'FAQ and troubleshooting';

  @override
  String get docsLauncherAPI => 'Launcher API';

  @override
  String get docsDocumentEmpty => 'The document is empty';

  @override
  String docsCouldntLoadDocsCheck(Object error) {
    return 'Couldn\'t load the docs ($error); check your network and try again';
  }

  @override
  String get docsNoCache => 'no cache';

  @override
  String get instanceFilesFoldersCantOpenedPhones => 'Folders can\'t be opened on phones yet';

  @override
  String instanceFilesCouldntMoveRecycleBin(Object stderr) {
    return 'Couldn\'t move to the recycle bin: $stderr';
  }

  @override
  String get instanceFilesCouldntMoveTrash => 'Couldn\'t move to the Trash';

  @override
  String get instanceFilesCouldntMoveRecycleBin2 => 'Couldn\'t move to the recycle bin';

  @override
  String instanceFilesUnknownNBTType(Object typeValue) {
    return 'Unknown NBT type $typeValue';
  }

  @override
  String safePathOnlyFilesVersionsWorking(Object rel) {
    return 'Only files in the version\'s working directory can be accessed: $rel';
  }

  @override
  String safePathInvalidPath(Object rel) {
    return 'Invalid path: $rel';
  }

  @override
  String get safePathOnlyFilesVersionsWorking2 => 'Only files in the version\'s working directory can be accessed';

  @override
  String safePathPathContainsSymbolicLink(Object root) {
    return 'The path contains a symbolic link and can\'t be used for safety reasons: $root';
  }

  @override
  String safePathCantDetermineRealLocation(Object root) {
    return 'Can\'t determine the real location of the path: $root';
  }

  @override
  String safePathPathActuallyPointsOutside(Object root) {
    return 'The path actually points outside the version\'s working directory: $root';
  }

  @override
  String get updaterGitHubRateLimitExceeded => 'GitHub rate limit exceeded; please try again later';

  @override
  String updaterCouldntGetUpdateInfo(Object statusCode) {
    return 'Couldn\'t get update info (HTTP $statusCode)';
  }

  @override
  String get updaterInstallingUnknownAppsNeeds => 'Installing unknown apps needs to be allowed';

  @override
  String updaterIncompleteDownloadBytes(Object received, Object size) {
    return 'Incomplete download ($received / $size bytes)';
  }

  @override
  String get updaterFileVerificationFailedSHA => 'File verification failed (SHA-256 mismatch)';

  @override
  String get updaterAutomaticUpdatesArentSupported => 'Automatic updates aren\'t supported on this platform yet';

  @override
  String updaterUpdatePackageDoesntContain(Object appExeNames) {
    return 'The update package doesn\'t contain the main program ($appExeNames)';
  }

  @override
  String get updaterText => ' or ';

  @override
  String get hudBridgeConversationNoLongerExists => 'This conversation no longer exists.';

  @override
  String get hudBridgeQuestionCantEmpty => 'The question can\'t be empty.';

  @override
  String get hudBridgeAIIsntSetUp =>
      'AI isn\'t set up yet. Go back to the launcher and fill in the API, model and API key in Settings → AI.';

  @override
  String get hudBridgeConversationStillBeingAnswered => 'This conversation is still being answered; please wait.';

  @override
  String hudBridgeWaitingConfirmation(Object label) {
    return 'Waiting for confirmation: $label';
  }

  @override
  String hudBridgeRunning(Object label) {
    return 'Running: $label';
  }

  @override
  String yggdrasilConnectDoesntSupportYggdrasilConnect(Object name) {
    return '$name doesn\'t support Yggdrasil Connect';
  }

  @override
  String yggdrasilConnectHasInvalidYggdrasilConnect(Object name) {
    return '$name has an invalid Yggdrasil Connect configuration';
  }

  @override
  String yggdrasilConnectLauncherHasntRegisteredApp(Object name) {
    return 'The launcher hasn\'t registered an app with $name yet, so OAuth sign-in isn\'t available';
  }

  @override
  String get yggdrasilConnectMalformedIDToken => 'Malformed ID token';

  @override
  String get yggdrasilConnectInvalidIDTokenIssuer => 'Invalid ID token (issuer, audience or validity doesn\'t match)';

  @override
  String yggdrasilConnectDoesntSupportDeviceCode(Object name) {
    return '$name doesn\'t support device code sign-in';
  }

  @override
  String get yggdrasilConnectNoProfileWasChosen => 'No profile was chosen during authorization';

  @override
  String yggdrasilConnectAuthorizationAccountHasExpired(Object typeLabel, Object name) {
    return 'The authorization for $typeLabel account $name has expired; sign in again under Accounts';
  }

  @override
  String oauthCantStartSign(Object status) {
    return 'Can\'t start sign-in: $status';
  }

  @override
  String get oauthAuthorizationDenied => 'Authorization denied';

  @override
  String get oauthSignTimedOutPlease => 'Sign-in timed out; please try again';

  @override
  String oauthSignFailed(Object status) {
    return 'Sign-in failed: $status';
  }

  @override
  String oauthAuthenticationServerTemporarilyUnavailable(Object status) {
    return 'The authentication server is temporarily unavailable ($status); please try again later';
  }

  @override
  String accountsExternal(Object host) {
    return 'External · $host';
  }

  @override
  String get accountsUsernamesMust316 => 'Usernames must be 3–16 letters, digits or underscores';

  @override
  String get yggdrasilAccountHasNoProfile => 'This account has no profile yet; create one on the skin site first';

  @override
  String get yggdrasilAuthenticationServerDidntReturn => 'The authentication server didn\'t return the chosen profile';

  @override
  String yggdrasilProfileNoLongerBelongs(Object name) {
    return 'Profile $name no longer belongs to this account; please add the account again';
  }

  @override
  String get yggdrasilApiEnterAuthenticationServerAddress => 'Enter the authentication server address';

  @override
  String yggdrasilApiIsntValidAuthenticationServer(Object url) {
    return '$url isn\'t a valid authentication server';
  }

  @override
  String yggdrasilApiAuthenticationServerReturnedHTTP(Object status) {
    return 'The authentication server returned HTTP $status';
  }

  @override
  String newsMinecraftWikiRequestFailed(Object statusCode) {
    return 'Minecraft Wiki request failed ($statusCode)';
  }

  @override
  String get secureEncryptionFailed => 'Encryption failed';

  @override
  String get secureDecryptionFailed => 'Decryption failed';

  @override
  String get authlibInjectorVerificationFailedSHA256 => 'Verification failed (SHA-256 mismatch)';

  @override
  String authlibInjectorCouldntDownloadAuthlibInjector(Object e) {
    return 'Couldn\'t download authlib-injector: $e';
  }

  @override
  String get authSignCanceled => 'Sign-in canceled';

  @override
  String get aiToolsViewInstanceList => 'View instance list';

  @override
  String get aiToolsViewInstanceInfo => 'View instance info';

  @override
  String aiToolsViewInfo(Object id) {
    return 'View info for $id';
  }

  @override
  String get aiToolsViewModList => 'View mod list';

  @override
  String aiToolsViewMods(Object id) {
    return 'View mods of $id';
  }

  @override
  String get aiToolsViewFiles => 'View files';

  @override
  String aiToolsView(Object id, Object rel) {
    return 'View $id/$rel';
  }

  @override
  String get aiToolsReadLog => 'Read log';

  @override
  String aiToolsRead(Object id, Object kind) {
    return 'Read the $kind of $id';
  }

  @override
  String get aiToolsCrashReport => 'crash report';

  @override
  String get aiToolsDebugLog => 'debug log';

  @override
  String get aiToolsSearchMods => 'Search mods';

  @override
  String aiToolsSearchModrinth(Object q) {
    return 'Search Modrinth for “$q”';
  }

  @override
  String get aiToolsViewInstallableVersions => 'View installable versions';

  @override
  String get aiToolsViewInstallableMinecraftVersions => 'View installable Minecraft versions';

  @override
  String get aiToolsViewLoaderVersions => 'View loader versions';

  @override
  String aiToolsViewVersions(Object game, Object label) {
    return 'View $label versions for $game';
  }

  @override
  String get aiToolsInstallNewInstance => 'Install new instance';

  @override
  String aiToolsSwitchCurrentInstance(Object id) {
    return 'Switch the current instance to $id';
  }

  @override
  String get aiToolsSearchResources => 'Search resources';

  @override
  String aiToolsSearchModrinth2(Object f, Object label, Object q) {
    return 'Search Modrinth for $f$label$q';
  }

  @override
  String aiToolsText(Object label) {
    return '$label ';
  }

  @override
  String get aiToolsViewProjectDetails => 'View project details';

  @override
  String aiToolsViewModrinthProject(Object ids) {
    return 'View Modrinth project $ids';
  }

  @override
  String aiToolsCompareModrinthProjects(Object count) {
    return 'Compare $count Modrinth projects';
  }

  @override
  String get aiToolsInstallResource => 'Install resource';

  @override
  String aiToolsInstall(Object label, Object name) {
    return 'Install $label $name';
  }

  @override
  String aiToolsInstance(Object id) {
    return 'Instance: $id';
  }

  @override
  String aiToolsFileInto(Object fileName, Object fileSize, Object folder) {
    return 'File: $fileName ($fileSize), into $folder';
  }

  @override
  String get aiToolsSourceModrinth => 'Source: Modrinth';

  @override
  String get aiToolsViewJava => 'View Java';

  @override
  String get aiToolsViewInstalledJava => 'View installed Java';

  @override
  String get aiToolsViewSystemInfo => 'View system info';

  @override
  String get aiToolsSetInstanceJava => 'Set instance Java';

  @override
  String aiToolsChangeJava(Object id, Object label) {
    return 'Change the Java of $id to $label';
  }

  @override
  String aiToolsBefore(Object old) {
    return 'Before: $old';
  }

  @override
  String aiToolsAfter(Object label) {
    return 'After: $label';
  }

  @override
  String get aiToolsSetInstanceMemory => 'Set instance memory';

  @override
  String aiToolsChangeMemory(Object id, Object label) {
    return 'Change the memory of $id to $label';
  }

  @override
  String aiToolsBefore2(Object s) {
    return 'Before: $s';
  }

  @override
  String aiToolsSystemMemoryGBTotal(Object total, Object free) {
    return 'System memory: $total GB total, $free GB free';
  }

  @override
  String get aiToolsReadConfigFile => 'Read config file';

  @override
  String commonRead(Object rel) {
    return 'Read $rel';
  }

  @override
  String get aiToolsEditConfigFile => 'Edit config file';

  @override
  String aiToolsEditChanges(Object rel, Object count) {
    return 'Edit $rel ($count changes)';
  }

  @override
  String get aiToolsOriginalFileBackedUp => 'The original file is backed up before editing';

  @override
  String get aiToolsInstallMod => 'Install mod';

  @override
  String aiToolsInstallMod2(Object name) {
    return 'Install mod $name';
  }

  @override
  String aiToolsFile(Object fileName, Object fileSize) {
    return 'File: $fileName ($fileSize)';
  }

  @override
  String get aiToolsRequiredDependenciesInstalledToo => 'Required dependencies are installed too';

  @override
  String get aiToolsEnableDisableMods => 'Enable or disable mods';

  @override
  String aiToolsMods(Object enabled, Object count) {
    return '$enabled $count mods';
  }

  @override
  String get aiToolsEnable => 'Enable';

  @override
  String get aiToolsDisable => 'Disable';

  @override
  String get aiToolsBackUp => 'Back up';

  @override
  String aiToolsBackUpItems(Object count) {
    return 'Back up $count items';
  }

  @override
  String aiToolsAboutSavedBackupsGame(Object size) {
    return 'About $size, saved to backups in the game folder';
  }

  @override
  String get aiToolsViewBackups => 'View backups';

  @override
  String aiToolsViewBackups2(Object id) {
    return 'View backups of $id';
  }

  @override
  String get commonDeleteFiles => 'Delete files';

  @override
  String aiToolsDeleteItemsMoveRecycle(Object count) {
    return 'Delete $count items (move to recycle bin)';
  }

  @override
  String get aiToolsReplaceMod => 'Replace mod';

  @override
  String aiToolsReplaceMod2(Object name) {
    return 'Replace mod $name';
  }

  @override
  String aiToolsOldFile(Object name) {
    return 'Old file: $name';
  }

  @override
  String aiToolsNewFileFromModrinth(Object fileName, Object name) {
    return 'New file: $fileName ($name, from Modrinth)';
  }

  @override
  String get aiToolsOldFileBackedUp => 'The old file is backed up first, then moved to the recycle bin';

  @override
  String get aiToolsRestoreFromBackup => 'Restore from backup';

  @override
  String aiToolsRestoreFromBackup2(Object name) {
    return 'Restore from backup $name';
  }

  @override
  String aiToolsWillRestoreFiles(Object paths, Object files, Object bytes) {
    return 'Will restore: $paths ($files files, $bytes)';
  }

  @override
  String get aiToolsNoteBackupWasCreated =>
      'Note: this backup was created by an older Pixel World and isn\'t signed, so its contents can\'t be verified as unmodified';

  @override
  String get aiToolsItsExtractedTemporaryFolder =>
      'It\'s extracted to a temporary folder and verified first; only then is the current content backed up and moved to the recycle bin';

  @override
  String aiToolsInstall2(Object shown) {
    return 'Install $shown';
  }

  @override
  String aiToolsInstanceName(Object shown) {
    return 'Instance name: $shown';
  }

  @override
  String aiToolsDownloadsFromMayTake(Object useMirror) {
    return 'Downloads from $useMirror; this may take a few minutes. Progress is shown on the Tasks page';
  }

  @override
  String aiToolsNoteHasNoIris(Object id) {
    return 'Note: $id has no Iris or OptiFine, which shader packs need';
  }

  @override
  String get workspaceToolsViewAccessibleFolders => 'View accessible folders';

  @override
  String get workspaceToolsViewFolder => 'View folder';

  @override
  String workspaceToolsView(Object rel) {
    return 'View $rel';
  }

  @override
  String get workspaceToolsFindFiles => 'Find files';

  @override
  String workspaceToolsFind(Object rel, Object pattern) {
    return 'Find $pattern in $rel';
  }

  @override
  String get workspaceToolsSearchFileContents => 'Search file contents';

  @override
  String workspaceToolsSearch(Object rel, Object pattern) {
    return 'Search for “$pattern” in $rel';
  }

  @override
  String get workspaceToolsReadFile => 'Read file';

  @override
  String get workspaceToolsWriteFile => 'Write file';

  @override
  String workspaceToolsLines(Object length, Object count) {
    return '$length, $count lines';
  }

  @override
  String get workspaceToolsOriginalFileWillReplaced => 'The original file will be replaced';

  @override
  String get workspaceToolsEditFile => 'Edit file';

  @override
  String workspaceToolsEdit(Object rel, Object count) {
    return 'Edit $rel$count';
  }

  @override
  String workspaceToolsOriginal(Object oldText) {
    return 'Original:\n$oldText';
  }

  @override
  String workspaceToolsChange(Object newText) {
    return 'Change to:\n$newText';
  }

  @override
  String get workspaceToolsMoveFile => 'Move file';

  @override
  String workspaceToolsMove(Object rel, Object rel2) {
    return 'Move $rel to $rel2';
  }

  @override
  String workspaceToolsDelete(Object rel) {
    return 'Delete $rel';
  }

  @override
  String get workspaceToolsWholeFolderItsContents => 'The whole folder and its contents';

  @override
  String workspaceToolsFile(Object lengthSync) {
    return 'File, $lengthSync';
  }

  @override
  String get workspaceToolsMovedRecycleBin => 'Moved to the recycle bin';

  @override
  String webToolsSearch(Object q) {
    return 'Search for “$q”';
  }

  @override
  String get webToolsOpenWebPage => 'Open web page';

  @override
  String webToolsOpen(Object host, Object path) {
    return 'Open $host$path';
  }

  @override
  String get webToolsSearchMinecraftWiki => 'Search the Minecraft Wiki';

  @override
  String webToolsSearchMinecraftWiki2(Object q) {
    return 'Search the Minecraft Wiki for “$q”';
  }

  @override
  String get aiClientQwen => 'Qwen';

  @override
  String get aiClientOllamaLocal => 'Ollama (local)';

  @override
  String get aiClientEnterAPIAddressFirst => 'Enter the API address first';

  @override
  String aiClientCouldntGetModelList(Object s) {
    return 'Couldn\'t get the model list: $s';
  }

  @override
  String aiClientCantConnect(Object host, Object message) {
    return 'Can\'t connect to $host: $message';
  }

  @override
  String aiClientSecureConnectionFailed(Object host) {
    return 'Secure connection to $host failed';
  }

  @override
  String get aiClientAPIDidntReturnModel => 'The API didn\'t return a model list; check the API address';

  @override
  String aiClientConnectionTimedOut(Object host) {
    return 'Connection to $host timed out';
  }

  @override
  String get aiClientModelRefusedAnswerRequest => 'The model refused to answer this request';

  @override
  String get aiClientModelReturnedNothingCheck => 'The model returned nothing; check the API address and model name';

  @override
  String get aiClientAnswerHitLengthLimit => '\n\n(The answer hit the length limit and was cut off)';

  @override
  String aiClientConnectionWasInterrupted(Object host, Object message) {
    return 'Connection to $host was interrupted: $message';
  }

  @override
  String aiClientSecureConnectionFailedCheck(Object host) {
    return 'Secure connection to $host failed; check the API address or network proxy';
  }

  @override
  String aiClientHasntRespondedLongTime(Object host) {
    return '$host hasn\'t responded for a long time; please try again later';
  }

  @override
  String get aiClientConversationLongerThanModel =>
      'The conversation is longer than the model can handle; click “Compact context” above the conversation or start a new one';

  @override
  String aiClientModelDoesntExistIsnt(Object model) {
    return 'Model “$model” doesn\'t exist or isn\'t available; check the model name, or use the button next to it to fetch available models';
  }

  @override
  String get aiClientInsufficientBalanceQuotaTop =>
      'Insufficient balance or quota; top up or check your quota in the provider\'s console';

  @override
  String get aiClientAIServiceOverloadedPlease => 'The AI service is overloaded; please try again later';

  @override
  String get aiClientRequestRejectedModelProvider =>
      'Request rejected; this model or provider may not support this kind of request';

  @override
  String get aiClientAPIKeyInvalidExpired => 'The API key is invalid or expired; check it in settings';

  @override
  String get aiClientNoPermissionUseModel =>
      'No permission to use this model or API; check your account permissions or region restrictions';

  @override
  String get aiClientAPIAddressModelDoesnt =>
      'The API address or model doesn\'t exist; check the API address (OpenAI-compatible APIs usually end in /v1)';

  @override
  String get aiClientAIServiceTimedOut => 'The AI service timed out; please try again later';

  @override
  String get aiClientContentSentTooLong => 'The content sent is too long; please start a new conversation';

  @override
  String get aiClientTooManyRequestsPlease => 'Too many requests; please try again later';

  @override
  String get aiClientAIServiceTemporarilyUnavailable =>
      'The AI service is temporarily unavailable; please try again later';

  @override
  String aiClientRequestFailed(Object code, Object raw) {
    return 'Request failed ($code): $raw';
  }

  @override
  String get aiClientNoDetailsReturned => 'No details returned';

  @override
  String get mcpClientExaSearch => 'Exa search';

  @override
  String get mcpClientInvalidURL => 'Invalid URL';

  @override
  String get mcpClientOnlyHttpHttpsSupported => 'Only http / https are supported';

  @override
  String get mcpClientRemoteServicesMustUse =>
      'Remote services must use https; http can only connect to this machine (127.0.0.1 / localhost)';

  @override
  String mcpClientServiceReturnedError(Object err) {
    return 'The service returned an error: $err';
  }

  @override
  String get mcpClientAccessDeniedCheckAccess => 'Access denied; check the access token';

  @override
  String get mcpClientWrongAddressServiceClosed => 'Wrong address, or the service closed this session';

  @override
  String get mcpClientResponseTooLarge => 'Response too large';

  @override
  String get mcpClientMalformedResponse => 'Malformed response';

  @override
  String get mcpClientTimedOutWaitingService => 'Timed out waiting for the service';

  @override
  String get mcpClientServicesResponseIsntValid => 'The service\'s response isn\'t valid JSON';

  @override
  String mcpClientCantReachService(Object message) {
    return 'Can\'t reach the service: $message';
  }

  @override
  String mcpClientConnectionError(Object message) {
    return 'Connection error: $message';
  }

  @override
  String get mcpClientServiceDisconnectedWithoutResponding => 'The service disconnected without responding';

  @override
  String get mcpClientServiceProcessHasExited => 'The service process has exited';

  @override
  String mcpClientServiceProcessHasExited2(Object code) {
    return 'The service process has exited (exit code $code)';
  }

  @override
  String get mcpClientPixelWorldDoesntSupport => 'Pixel World doesn\'t support this request';

  @override
  String get mcpClientServiceProvidesNoTools => 'This service provides no tools';

  @override
  String get mcpHubAskEveryTime => 'Ask every time';

  @override
  String get mcpHubReadOnlyRejectChanges => 'Read-only (reject changes)';

  @override
  String mcpHubCall(Object name, Object name2) {
    return 'Call $name2 of “$name”';
  }

  @override
  String get mcpHubServiceDeclaresToolRead => 'The service declares this tool read-only';

  @override
  String mcpHubArguments(Object shown) {
    return 'Arguments: $shown';
  }

  @override
  String get mcpHubExited => 'Exited';

  @override
  String get mcpHubUnreachable => 'Unreachable';

  @override
  String get mcpHubLocalJarServicesCant =>
      'Local jar services can\'t run on Android yet; use a remote (HTTP) service instead';

  @override
  String mcpHubJarFileNotFound(Object jar) {
    return 'Jar file not found: $jar';
  }

  @override
  String get mcpHubPrepareJavaMCPService => 'Prepare Java for the MCP service';

  @override
  String get aiChatModelReturnedNoSummary => 'The model returned no summary';

  @override
  String aiChatCouldntCompactContext(Object e) {
    return 'Couldn\'t compact the context: $e';
  }

  @override
  String get aiChatTooManyActionsRound =>
      'Too many actions this round, so it paused. Send a message to let the AI continue';

  @override
  String aiChatAnswerInterrupted(Object partial) {
    return '$partial\n\n(Answer interrupted)';
  }

  @override
  String get aiChatNoToolsAvailable => 'No tools available';

  @override
  String aiChatStopped(Object partial) {
    return '$partial\n\n(Stopped)';
  }

  @override
  String agentRootCurrentInstance(Object id) {
    return 'Current instance ($id)';
  }

  @override
  String get agentRootDownloads => 'Downloads';

  @override
  String get aiPromptMyGameCrashedBelow =>
      'My game crashed. Below is the crash information the launcher collected; please help me find the cause and tell me how to fix it.';

  @override
  String get aiReplyLanguage => 'English (US spelling)';

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonClauseSeparator => '; ';

  @override
  String get commonComma => ', ';

  @override
  String get commonColon => ': ';

  @override
  String commonParenthesized(Object text) {
    return ' ($text)';
  }

  @override
  String get aiSearchEngineAuto => 'Built-in (Exa, falling back to DuckDuckGo and Bing)';

  @override
  String get aiSearchEngineExa => 'Exa (key optional)';

  @override
  String get aiSearchEngineBing => 'Bing (more reliable for English results)';

  @override
  String get aiSearchEngineSearxng => 'SearXNG (self-hosted or public instance)';

  @override
  String get aiSearchEngineTavily => 'Tavily (key required)';

  @override
  String get aiSearchEngineBrave => 'Brave Search (key required)';

  @override
  String get aiSearchEngineSerper => 'Serper / Google (key required)';

  @override
  String get downloadLoadFailedRetry => 'Failed · Retry';

  @override
  String get precheckOwnershipRequired =>
      'To verify game ownership, sign in once with a Microsoft account that owns Minecraft before using offline and external accounts.';

  @override
  String get launchDialogsVerifyOwnershipFirst => 'Verify game ownership first';

  @override
  String get launchDialogsOwnershipRequiredBody =>
      'Minecraft is a paid game. Mojang requires you to sign in once with a Microsoft account that owns Minecraft before playing with offline or external accounts.\n\nAfter verifying once, offline and external accounts stay available.';

  @override
  String get launchDialogsBuyGame => 'Buy the game';

  @override
  String get launchDialogsSignInMicrosoft => 'Sign in with Microsoft';

  @override
  String get oobeAccountHintVerified =>
      'Use a Microsoft account to play the full game, or an offline or external account.';

  @override
  String get oobeAccountHintUnverified =>
      'To verify game ownership, sign in first with a Microsoft account that owns Minecraft; after that, offline and external accounts work too.';

  @override
  String get oobeAvailableAfterVerification => 'Available after verifying ownership';

  @override
  String get accountsOwnershipNotice =>
      'Note: to verify game ownership, offline and external accounts can only be added and used after you sign in once with a Microsoft account that owns Minecraft.';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get windowMinimize => 'Minimise';

  @override
  String get windowMaximize => 'Maximise';

  @override
  String get settingsAppearance => 'Personalisation';

  @override
  String get colorMode => 'Colour mode';

  @override
  String get themeColor => 'Theme colour';

  @override
  String get themeColorAuto =>
      'Follow background: colours are picked from the background image with Material Design 3 and update when the image changes';

  @override
  String get themeColorManual =>
      'A full light and dark palette is generated from the theme colour with Material Design 3';

  @override
  String get bgFitCenter => 'Centre';

  @override
  String get bgFitFitHint => 'Fit: shows the whole image and fills the gaps with its colours';

  @override
  String get bgFitCenterHint => 'Centre: places the image at its original size in the middle of the window';

  @override
  String get bgGlowHint => 'How far the colours taken from cover art spread out on recently played cards';

  @override
  String get aboutSourceHint => 'Pixel World is open source under the Apache-2.0 licence';

  @override
  String get aboutMaterialHint => 'Design language and colour algorithm';

  @override
  String get gameWindowMaximized => 'Maximised';

  @override
  String get afterLaunchMinimize => 'Minimise, restore when the game exits';

  @override
  String get oobeSelectedPanelsBecomeFrosted =>
      'Selected · panels become frosted glass and the theme colour follows the image';

  @override
  String get tourThemeBackgroundImageHome =>
      'Theme, background image and home layout are under “Personalisation”; Java, memory and game folders are adjusted here too.';

  @override
  String get yggdrasilLoginDialogOAuthAuthorization => 'OAuth authorisation';

  @override
  String yggdrasilLoginDialogClickingStartOpensAuthorization(Object site) {
    return 'Clicking Start opens the $site authorisation page in your browser; approve it and choose a profile. The launcher never sees your password.';
  }

  @override
  String get deviceLoginDialogAuthorizationPageHasOpened =>
      'The authorisation page has opened in your browser. Check that the code on the page matches the one below, then approve:';

  @override
  String get themeColorDialogCustomThemeColor => 'Custom theme colour';

  @override
  String homeMonthDay(Object month, Object day) {
    return '$day/$month';
  }

  @override
  String get tasksCanceled => 'Cancelled';

  @override
  String get diagnoseNoKnownProblemMatched => 'No known problem matched; you can check the log or analyse it with AI.';

  @override
  String get diagnoseNothingAnalyze => 'Nothing to analyse';

  @override
  String get diagnoseAnalyzeAI => 'Analyse with AI';

  @override
  String get diagnoseAnalyzeLogYourOwn =>
      'Analyse the log with your own AI service; set the API address, model and API key first';

  @override
  String get commonFavorites => 'Favourites';

  @override
  String get downloadModernized1122 => 'A modernised 1.12.2 branch based on Forge; requires Java 21';

  @override
  String get commonTaskCanceled => 'Task cancelled';

  @override
  String get resourcesRemoveFromFavorites => 'Remove from favourites';

  @override
  String get resourcesFavorites => 'Favourites';

  @override
  String get resourcesNoFavoritesYetClick => 'No favourites yet; click the heart icon next to a resource to add it';

  @override
  String get toolsAnalyze => 'Analyse';

  @override
  String get toolsAnalyzeMostRecentGame => 'Analyse the most recent game run since the launcher was opened';

  @override
  String get toolsLauncherFirstMatchesCommon =>
      'The launcher first matches common problems with local rules; after setting up your own AI service in Settings → AI, you can also have AI analyse logs. A prompt appears automatically when the game crashes.';

  @override
  String aiMonthDay(Object month, Object day) {
    return '$day/$month';
  }

  @override
  String get aiCompactContextSummarizeEarlier => 'Compact context: summarise earlier messages';

  @override
  String get aiCanceled => 'Cancelled';

  @override
  String get aiEarlierPartsWereSummarized => ' (earlier parts were summarised)';

  @override
  String get aiConversationAboveWasSummarized => 'The conversation above was summarised';

  @override
  String get aiSettingsSummarizeEarlierMessagesOnce =>
      'Summarise earlier messages once the limit is exceeded, to save cost';

  @override
  String get appStateAnalyzeInstance => 'Analyse instance';

  @override
  String get javaJava8ArchiveHas => 'The Java 8 archive has an unrecognised layout';

  @override
  String get installOrganizeLegacyAssets => 'Organise legacy assets';

  @override
  String get importUnrecognizedCNGProtectedData => 'Unrecognised CNG protected data';

  @override
  String get importUnrecognizedUserKeyBinFormat => 'Unrecognised UserKey.bin format';

  @override
  String get importLauncherBehaviorAfterLaunch => 'Launcher behaviour after launch';

  @override
  String get yggdrasilConnectNoProfileWasChosen => 'No profile was chosen during authorisation';

  @override
  String yggdrasilConnectAuthorizationAccountHasExpired(Object typeLabel, Object name) {
    return 'The authorisation for $typeLabel account $name has expired; sign in again under Accounts';
  }

  @override
  String get oauthAuthorizationDenied => 'Authorisation denied';

  @override
  String get authSignCanceled => 'Sign-in cancelled';

  @override
  String get aiReplyLanguage => 'English (UK spelling)';

  @override
  String get accountsOwnershipNotice =>
      'Note: to verify game ownership, offline and external accounts can only be added and used after you sign in once with a Microsoft account that owns Minecraft.';
}
