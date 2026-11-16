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
}
