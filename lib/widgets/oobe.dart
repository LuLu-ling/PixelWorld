import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../app_scope.dart';
import '../core/accounts.dart';
import '../core/android_storage.dart';
import '../core/config.dart' show homeLayouts;
import '../core/microsoft.dart';
import '../core/network_check.dart';
import '../core/pcl_import.dart';
import '../l10n/l10n.dart';
import '../pages/file_manager_page.dart';
import '../platform.dart';
import 'agreement_dialog.dart';
import 'app_logo.dart';
import 'device_login_dialog.dart';
import 'network_check_panel.dart';
import 'storage_location.dart';
import 'theme_color_dialog.dart';
import 'window_buttons.dart';
import '../core/i18n/strings.dart';

/// 首次设置走完后要做的事
class OobeResult {
  const OobeResult({required this.tour, required this.download});

  /// 接着看新手教程
  final bool tour;

  /// 打开「下载」页安装第一个实例
  final bool download;
}

/// 全新安装第一次打开时全屏显示首次设置；已经走过（或老用户）返回 null
Future<OobeResult?> showOobeIfNeeded(BuildContext context) async {
  if (AppScope.read(context).config.oobeDone) return null;
  return Navigator.of(context, rootNavigator: true).push<OobeResult>(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const OobePage(),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

/// 首次设置的步数（[_steps] 是各步的标题）
const _stepCount = 7;

List<String> _steps(AppLocalizations l) => [
  l.oobeWelcome,
  l.helpTerms,
  l.oobeAppearance,
  l.oobeGameFolder,
  l.oobeNetwork,
  l.oobeAccount,
  l.oobeDone,
];

class OobePage extends StatefulWidget {
  const OobePage({super.key});

  @override
  State<OobePage> createState() => _OobePageState();
}

class _OobePageState extends State<OobePage> {
  int _step = 0;
  bool _agreed = false;
  bool _busy = false;
  bool _tour = true;

  // 游戏文件夹（电脑）：default / existing / pcl
  String _folder = 'default';
  String? _existingDir;
  late final PclDetection _pcl = isDesktop ? detectPcl() : PclDetection(found: false, folders: 0, hasAccounts: false);
  String? _folderNote;

  // 游戏文件夹（安卓）：放在手机存储
  bool _shared = true;

  bool? _preferMirror;
  final _offlineName = TextEditingController();
  bool _offlineOpen = false;
  String? _offlineError;

  final _scroll = ScrollController();

  @override
  void dispose() {
    _offlineName.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _phone => !isDesktop;

  void _go(int i) {
    if (i > 1 && !_agreed) return;
    setState(() => _step = i);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _next() async {
    final state = AppScope.read(context);
    switch (_step) {
      case 1:
        await state.config.update({'agreementVersion': agreementVersion});
      case 3:
        setState(() => _busy = true);
        try {
          await _applyFolder();
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        if (!mounted) return;
    }
    if (_step < _stepCount - 1) _go(_step + 1);
  }

  /// 「游戏文件夹」这一步点下一步时才真正生效（要申请权限、导入）
  Future<void> _applyFolder() async {
    final state = AppScope.read(context);
    if (Platform.isAndroid) {
      await state.config.update({'storageAsked': true});
      if (_shared && !AndroidStorage.isShared(state.config.gameDir) && mounted) {
        await changeStorage(context, toShared: true);
      }
      return;
    }
    switch (_folder) {
      case 'existing':
        if (_existingDir != null) await state.selectFolder(_existingDir!);
      case 'pcl':
        try {
          final r = await importFromPcl(state.config, state.accounts, settings: true, folders: true, accounts: true);
          await state.refreshVersions();
          _folderNote = tr.oobeImportedFromPCLCE(r.folders, r.accounts);
        } catch (e) {
          _folderNote = tr.oobeCouldntImportFromPCL(e);
        }
    }
  }

  Future<void> _finish({required bool download}) async {
    final cfg = AppScope.read(context).config;
    await cfg.update({
      'oobeDone': true,
      'agreementVersion': agreementVersion,
      if (Platform.isAndroid) 'storageAsked': true,
      // 不看教程就当作看过了，之后可以在「设置 → 关于与致谢 → 帮助」里再看
      if (!_tour) 'tourSeen': true,
    });
    if (mounted) Navigator.of(context).pop(OobeResult(tour: _tour, download: download));
  }

  /// 「全部用默认」：协议还是要同意
  void _skipAll() {
    if (!_agreed) {
      _go(1);
      return;
    }
    _finish(download: false);
  }

  Future<void> _decline() async {
    if (Platform.isAndroid) await SystemNavigator.pop();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final side = _Side(
      step: _step,
      agreed: _agreed,
      compact: _phone,
      onGo: _go,
      onSkip: _step == _stepCount - 1 ? null : _skipAll,
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktop) _TitleBar(),
        Expanded(
          child: Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: _phone ? const EdgeInsets.fromLTRB(26, 18, 28, 12) : const EdgeInsets.fromLTRB(44, 12, 44, 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(key: ValueKey(_step), child: _body(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: .4)),
        Padding(
          padding: _phone ? const EdgeInsets.fromLTRB(26, 8, 28, 10) : const EdgeInsets.fromLTRB(44, 14, 44, 18),
          child: _foot(context),
        ),
      ],
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        // 挖孔在左边时侧栏底色铺到挖孔那一侧（侧栏自己留出位置），在右边时内容让开
        body: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              side,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.paddingOf(context).right),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 底栏 ─────────────────────────

  Widget _foot(BuildContext context) {
    final theme = Theme.of(context);
    final last = _step == _stepCount - 1;
    final hint = switch (_step) {
      0 => _phone ? context.l10n.oobeAbout1Minute : context.l10n.oobe6StepsAbout1,
      1 => _agreed ? '' : context.l10n.oobeAcceptAgreementContinue,
      2 || 3 || 4 || 5 => context.l10n.oobeYouCanChangeAll,
      _ => '',
    };
    return Row(
      children: [
        if (_step > 0) ...[
          OutlinedButton(onPressed: _busy ? null : () => _go(_step - 1), child: Text(context.l10n.commonBack)),
          const SizedBox(width: 12),
        ],
        if (_step == 1) ...[
          TextButton(onPressed: _decline, child: Text(context.l10n.commonDeclineQuit)),
          const Spacer(),
        ] else
          Expanded(
            child: Text(
              hint,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        if (last) ...[
          OutlinedButton(
            onPressed: () => _finish(download: true),
            child: Text(context.l10n.oobeInstallYourFirstInstance),
          ),
          const SizedBox(width: 10),
          FilledButton(onPressed: () => _finish(download: false), child: Text(context.l10n.oobeOpenLauncher)),
        ] else
          FilledButton(
            onPressed: _busy || (_step == 1 && !_agreed) ? null : _next,
            child: _busy
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(switch (_step) {
                    0 => context.l10n.oobeStartSetup,
                    5 =>
                      AppScope.of(context).accounts.accounts.isEmpty
                          ? context.l10n.commonSkip
                          : context.l10n.commonNext,
                    _ => context.l10n.commonNext,
                  }),
          ),
      ],
    );
  }

  // ───────────────────────── 各步内容 ─────────────────────────

  Widget _body(BuildContext context) => switch (_step) {
    0 => _welcome(context),
    1 => _agreement(context),
    2 => _appearance(context),
    3 => _phone ? _storage(context) : _folders(context),
    4 => _network(context),
    5 => _account(context),
    _ => _done(context),
  };

  Widget _title(BuildContext context, String title, String lead) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: _phone ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (_phone ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall)?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(lead, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _welcome(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget feat(IconData icon, String t, String s) => Expanded(
      child: Container(
        padding: EdgeInsets.all(_phone ? 10 : 14),
        decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 6),
            Text(t, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(s, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: _phone ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLogo(size: _phone ? 56 : 80),
          SizedBox(height: _phone ? 8 : 16),
          _title(context, context.l10n.commonWelcomePixelWorld, context.l10n.oobeFreeOpenSourceMinecraft),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                feat(Icons.layers_outlined, context.l10n.oobeInstallManage, context.l10n.oobeVanillaEveryModLoader),
                const SizedBox(width: 10),
                feat(Icons.travel_explore, context.l10n.oobeModsResources, context.l10n.oobeFindModsModpacksResource),
                const SizedBox(width: 10),
                feat(Icons.forum_outlined, context.l10n.oobeAITroubleshooting, context.l10n.oobeGameCrashedLetAI),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreement(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(context, context.l10n.commonTermsUsePrivacyNotice, context.l10n.oobeBeforeYouContinuePlease),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: _phone ? 8 : 12),
          decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: Text(context.l10n.oobeSoftwareFreeOpenSource, style: theme.textTheme.bodySmall?.copyWith(height: 1.6)),
        ),
        const SizedBox(height: 8),
        DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                tabs: [
                  Tab(text: context.l10n.helpTerms),
                  Tab(text: context.l10n.helpPrivacy),
                ],
              ),
              Container(
                height: _phone ? 150 : 300,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: const TabBarView(children: [LegalText('terms'), LegalText('privacy')]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        CheckboxListTile(
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: _phone,
          title: Text(context.l10n.oobeIHaveReadAccept),
        ),
      ],
    );
  }

  Widget _appearance(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final bg = state.background;
    final hasImage = bg.imagePath.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(
          context,
          context.l10n.oobeAppearance,
          _phone ? context.l10n.oobePickLookYouLike : context.l10n.oobePickLookYouLike2,
        ),
        _Group(
          children: [
            _Row(
              title: context.l10n.colorMode,
              subtitle: context.l10n.oobeLightDarkLauncherAppearance,
              trailing: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 'system', label: Text(context.l10n.themeSystem)),
                  ButtonSegment(value: 'light', label: Text(context.l10n.themeLight)),
                  ButtonSegment(value: 'dark', label: Text(context.l10n.themeDark)),
                ],
                selected: {cfg.themeMode},
                onSelectionChanged: (s) => cfg.update({'themeMode': s.first}),
              ),
            ),
            _Row(
              title: context.l10n.bgImage,
              subtitle: hasImage
                  ? context.l10n.oobeSelectedPanelsBecomeFrosted
                  : context.l10n.oobeOptionalChooseImageShow,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(bg.imagePath), width: 64, height: 36, fit: BoxFit.cover, cacheWidth: 160),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: bg.clearImage, child: Text(context.l10n.bgImageRemove)),
                  ] else
                    FilledButton.tonal(
                      onPressed: () => _pickBackground(context),
                      child: Text(context.l10n.bgImageChoose),
                    ),
                ],
              ),
            ),
            if (!(hasImage && bg.enabled && bg.themeFromImage))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.themeColor, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    ThemeColorPicker(current: cfg.themeColor, onChanged: (c) => cfg.update({'themeColor': c})),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _GroupTitle(context.l10n.homeLayout),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, kind) in homeLayouts.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _LayoutCard(
                    kind: kind,
                    name: context.l10n.homeLayoutName(kind),
                    selected: cfg.homeLayout == kind,
                    wallpaper: hasImage && !(_phone && kind == 'standard'),
                    compact: _phone,
                    recommended: kind == 'split' && hasImage,
                    onTap: () => cfg.update({'homeLayout': kind}),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickBackground(BuildContext context) async {
    final bg = AppScope.read(context).background;
    final path = await pickFile(
      context,
      extensions: const ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif'],
      label: context.l10n.bgImageFiles,
    );
    if (path == null) return;
    try {
      await bg.setImage(path);
    } catch (e) {
      if (context.mounted) toast(context, context.l10n.oobeCantUseImage(e));
    }
  }

  Widget _folders(BuildContext context) {
    final cfg = AppScope.of(context).config;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(context, context.l10n.oobeGameFolder, context.l10n.oobeGamesInstancesModsWorlds),
        _Option(
          selected: _folder == 'default',
          title: context.l10n.oobeUseDefaultFolder,
          tag: context.l10n.themeRecommended,
          subtitle: cfg.gameDir,
          onTap: () => setState(() => _folder = 'default'),
        ),
        _Option(
          selected: _folder == 'existing',
          title: context.l10n.oobeUseExistingMinecraftFolder,
          subtitle: context.l10n.oobeInstalledGameAnotherLauncher,
          onTap: () async {
            setState(() => _folder = 'existing');
            if (_existingDir == null) await _pickExisting();
          },
          extra: _folder == 'existing'
              ? _PathRow(path: _existingDir ?? context.l10n.oobeNotChosenYet, onPick: _pickExisting)
              : null,
        ),
        if (_pcl.found)
          _Option(
            selected: _folder == 'pcl',
            title: context.l10n.pclImport,
            tag: context.l10n.oobePCLCEDetected,
            grayTag: true,
            subtitle: context.l10n.oobeImportsPCLCEGame(
              _pcl.folders,
              _pcl.hasAccounts ? context.l10n.oobeAccounts : '',
            ),
            onTap: () => setState(() => _folder = 'pcl'),
          ),
        if (_folderNote != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_folderNote!, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }

  Future<void> _pickExisting() async {
    final dir = await pickFolder(context, start: _existingDir);
    if (dir != null && mounted) setState(() => _existingDir = dir);
    if (dir == null && _existingDir == null && mounted) setState(() => _folder = 'default');
  }

  Widget _storage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(context, context.l10n.oobeWhereShouldGameFiles, context.l10n.oobeYouCanChangeLater),
        _Option(
          selected: _shared,
          title: context.l10n.oobePhoneStorage,
          tag: context.l10n.themeRecommended,
          subtitle: context.l10n.oobeStoredPixelWorldMinecraft,
          onTap: () => setState(() => _shared = true),
        ),
        _Option(
          selected: !_shared,
          title: context.l10n.oobeAppStorage,
          subtitle: context.l10n.oobeNoPermissionNeededBut,
          onTap: () => setState(() => _shared = false),
        ),
      ],
    );
  }

  Widget _network(BuildContext context) {
    final cfg = AppScope.of(context).config;
    final auto = switch (_preferMirror) {
      null => context.l10n.oobeDecidedAfterSpeedTest,
      true => context.l10n.oobeSpeedTestBMCLAPIMirror,
      false => context.l10n.oobeSpeedTestOfficialSource,
    };
    final options = [
      ('auto', context.l10n.downloadSourceAuto, auto, context.l10n.themeRecommended),
      ('bmclapi', context.l10n.downloadSourceMirror, context.l10n.oobeUsuallyFasterMainlandChina, null),
      ('official', context.l10n.downloadSourceOfficial, context.l10n.oobeOfficialServersOnly, null),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(context, context.l10n.oobeNetwork, context.l10n.oobeChooseWhereDownloadGame),
        _GroupTitle(context.l10n.downloadSource),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, o) in options.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _Option(
                    selected: cfg.downloadSource == o.$1,
                    title: o.$2,
                    tag: o.$4,
                    subtitle: o.$3,
                    margin: EdgeInsets.zero,
                    onTap: () => cfg.update({'downloadSource': o.$1}),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        NetworkCheckPanel(compact: true, onDone: (m) => setState(() => _preferMirror = m)),
        if (!_phone && _preferMirror != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              context.l10n.oobeAutomaticUsesFasterOne,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _account(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final clientId = state.config.effectiveMsClientId.trim();
    final list = state.accounts.accounts;
    // 验证过正版后才能添加离线账户（见 precheck.dart）
    final verified = state.config.hintBuy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(
          context,
          context.l10n.accountAdd,
          verified ? context.l10n.oobeAccountHintVerified : context.l10n.oobeAccountHintUnverified,
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _AccountCard(
                  icon: Icons.window,
                  title: context.l10n.oobeMicrosoftAccount,
                  subtitle: clientId.isEmpty
                      ? context.l10n.oobeSetClientIDSettings
                      : context.l10n.oobeOfficialSignLetsYou,
                  onTap: clientId.isEmpty
                      ? null
                      : () => showDeviceLogin(
                          context,
                          title: context.l10n.commonSignMicrosoft,
                          create: (onCode) => MicrosoftLogin(clientId, onCode),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AccountCard(
                  icon: Icons.person_outline,
                  title: context.l10n.oobeOfflineAccount,
                  subtitle: verified ? context.l10n.oobeJustPickNamePlay : context.l10n.oobeAvailableAfterVerification,
                  selected: _offlineOpen,
                  onTap: verified ? () => setState(() => _offlineOpen = true) : null,
                ),
              ),
            ],
          ),
        ),
        if (_offlineOpen && verified) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _offlineName,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.oobeOfflineUsername,
                    hintText: context.l10n.oobe316LettersDigits,
                    errorText: _offlineError,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addOffline(),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: FilledButton.tonal(onPressed: _addOffline, child: Text(context.l10n.oobeAdd)),
              ),
            ],
          ),
        ],
        if (list.isNotEmpty) ...[
          const SizedBox(height: 14),
          _GroupTitle(context.l10n.oobeAdded),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in list)
                InputChip(
                  avatar: CircleAvatar(child: Text(a.name.characters.first.toUpperCase())),
                  label: Text('${a.name} · ${a.typeLabel}'),
                  selected: a.id == state.selectedAccount?.id,
                  onPressed: () => state.selectAccount(a.id),
                  onDeleted: () => state.removeAccount(a.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Text(context.l10n.oobeYouCanAlsoSkip, style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
      ],
    );
  }

  Future<void> _addOffline() async {
    final name = _offlineName.text.trim();
    final error = AccountStore.validateOfflineName(name);
    if (error != null) return setState(() => _offlineError = error);
    await AppScope.read(context).addOfflineAccount(name);
    _offlineName.clear();
    if (mounted) {
      setState(() {
        _offlineError = null;
        _offlineOpen = false;
      });
    }
  }

  Widget _done(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final account = state.selectedAccount;
    String mode() => switch (cfg.themeMode) {
      'light' => context.l10n.themeLight,
      'dark' => context.l10n.themeDark,
      _ => context.l10n.themeSystem,
    };
    final source = switch (cfg.downloadSource) {
      'bmclapi' => context.l10n.downloadSourceMirror,
      'official' => context.l10n.downloadSourceOfficial,
      _ =>
        DownloadSourcePicker.last == null
            ? context.l10n.downloadSourceAuto
            : context.l10n.oobeAutomaticCurrently(
                DownloadSourcePicker.preferMirror
                    ? context.l10n.downloadSourceMirror
                    : context.l10n.downloadSourceOfficial,
              ),
    };
    final folder = Platform.isAndroid
        ? (AndroidStorage.isShared(cfg.gameDir) ? context.l10n.oobePhoneStorage : context.l10n.oobeAppStorage)
        : cfg.gameDir;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: _phone ? 44 : 56,
            height: _phone ? 44 : 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.check, color: scheme.onPrimaryContainer, size: _phone ? 24 : 30),
          ),
        ),
        SizedBox(height: _phone ? 8 : 14),
        _title(context, context.l10n.commonAllSet, context.l10n.oobeHereYourChoicesClick),
        _Group(
          children: [
            _Summary(
              context.l10n.oobeAppearance,
              context.l10n.oobeLayout(mode(), context.l10n.homeLayoutName(cfg.homeLayout)),
              () => _go(2),
            ),
            _Summary(context.l10n.oobeGameFolder, folder, () => _go(3)),
            _Summary(context.l10n.downloadSource, source, () => _go(4)),
            _Summary(
              context.l10n.oobeAccount,
              account == null
                  ? context.l10n.oobeNoneYet
                  : '${account.name}${context.l10n.commonParenthesized(account.typeLabel)}',
              () => _go(5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        CheckboxListTile(
          value: _tour,
          onChanged: (v) => setState(() => _tour = v ?? true),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: _phone,
          title: Text(context.l10n.oobeTakeGuidedTourAfter),
          subtitle: Text(context.l10n.oobeAbout30SecondsYou),
        ),
      ],
    );
  }
}

// ───────────────────────── 小部件 ─────────────────────────

class _TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(child: Platform.isLinux ? const SizedBox.expand() : DragToMoveArea(child: const SizedBox.expand())),
          if (!nativeWindowButtons) const WindowButtons(),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.step, required this.agreed, required this.compact, required this.onGo, this.onSkip});

  final int step;
  final bool agreed;
  final bool compact;
  final ValueChanged<int> onGo;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppLogo(size: compact ? 30 : 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pixel World', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  context.l10n.oobeFirstTimeSetup,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 12 : 24),
        for (final (i, t) in _steps(context.l10n).indexed)
          _StepItem(
            index: i,
            label: t,
            current: i == step,
            done: i < step,
            locked: i > 1 && !agreed,
            compact: compact,
            onTap: () => onGo(i),
          ),
        const Spacer(),
        if (onSkip != null && !compact)
          Text.rich(
            TextSpan(
              text: context.l10n.oobeDontWantSetThings,
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: onSkip,
                    child: Text(
                      context.l10n.oobeUseAllDefaults,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                TextSpan(text: agreed ? '' : context.l10n.oobeYouStillNeedAccept),
              ],
            ),
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
      ],
    );
    final cutout = MediaQuery.paddingOf(context).left;
    return Container(
      width: (compact ? 190 : 240) + cutout,
      color: scheme.surfaceContainerLow,
      padding: compact
          ? EdgeInsets.fromLTRB(14 + cutout, 14, 10, 10)
          : EdgeInsets.fromLTRB(20 + cutout, Platform.isMacOS ? 44 : 24, 16, 18),
      child: body,
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.label,
    required this.current,
    required this.done,
    required this.locked,
    required this.compact,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool current;
  final bool done;
  final bool locked;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dot = compact ? 20.0 : 24.0;
    return Opacity(
      opacity: locked ? .45 : 1,
      child: Material(
        color: current ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: locked ? null : onTap,
          child: SizedBox(
            height: compact ? 32 : 40,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Container(
                  width: dot,
                  height: dot,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current || done ? scheme.primary : scheme.surfaceContainerHighest,
                  ),
                  child: done
                      ? Icon(Icons.check, size: dot * .62, color: scheme.onPrimary)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: compact ? 10.5 : 12,
                            fontWeight: FontWeight.w700,
                            color: current ? scheme.onPrimary : scheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: current ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: .35)),
            c,
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.subtitle, required this.trailing});

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(this.label, this.value, this.onEdit);

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 6, 2),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
          ),
          TextButton(onPressed: onEdit, child: Text(context.l10n.oobeChange)),
        ],
      ),
    );
  }
}

/// 单选卡片
class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tag,
    this.grayTag = false,
    this.extra,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String? tag;
  final bool grayTag;
  final Widget? extra;
  final VoidCallback onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final compact = !isDesktop;
    return Padding(
      padding: margin,
      child: Material(
        color: selected
            ? Color.alphaBlend(scheme.primaryContainer.withValues(alpha: .4), scheme.surfaceContainer)
            : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: compact ? const EdgeInsets.fromLTRB(10, 8, 12, 9) : const EdgeInsets.fromLTRB(12, 12, 16, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: compact ? 18 : 20,
                  color: selected ? scheme.primary : scheme.outline,
                ),
                SizedBox(width: compact ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          if (tag != null) _Tag(tag!, gray: grayTag),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      if (extra != null) ...[const SizedBox(height: 10), extra!],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.gray = false});

  final String text;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: gray ? scheme.surfaceContainerHighest : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: gray ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.path, required this.onPick});

  final String path;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(10)),
            child: Text(
              path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: onPick, child: Text(context.l10n.oobeChoose)),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final compact = !isDesktop;
    return Opacity(
      opacity: onTap == null ? .5 : 1,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 28 : 36,
                  height: compact ? 28 : 36,
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: compact ? 16 : 20, color: scheme.onPrimaryContainer),
                ),
                SizedBox(height: compact ? 6 : 10),
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 首页布局选择：画一个简单的示意图
class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.kind,
    required this.name,
    required this.selected,
    required this.wallpaper,
    required this.compact,
    required this.recommended,
    required this.onTap,
  });

  final String kind;
  final String name;
  final bool selected;
  final bool wallpaper;
  final bool compact;
  final bool recommended;
  final VoidCallback onTap;

  static Map<String, String> _desc(AppLocalizations l) => {
    'standard': l.oobeLargeCardAnnouncementsShortcuts,
    'split': l.oobeInstanceAtTopPlay,
    'minimal': l.oobeSingleBarAtBottom,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final block = scheme.onSurface.withValues(alpha: wallpaper ? .28 : .14);
    final accent = scheme.primary;
    Widget box({double? w, double? h, Color? c, double r = 3}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: c ?? block, borderRadius: BorderRadius.circular(r)),
    );
    final preview = Container(
      height: compact ? 58 : 84,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // 有背景图片时用主题色块表示图片
        color: wallpaper ? scheme.primaryContainer : scheme.surface,
      ),
      child: switch (kind) {
        'split' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            box(h: 12),
            const Spacer(),
            Row(
              children: [
                Expanded(child: box(h: 12)),
                const SizedBox(width: 4),
                box(w: 26, h: 12, c: accent),
              ],
            ),
          ],
        ),
        'minimal' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Row(
              children: [
                Expanded(child: box(h: 10)),
                const SizedBox(width: 4),
                box(w: 22, h: 10, c: accent),
              ],
            ),
          ],
        ),
        _ => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: box()),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: box(w: 26, h: 9, c: accent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: box()),
                  const SizedBox(height: 4),
                  Expanded(child: box()),
                ],
              ),
            ),
          ],
        ),
      },
    );
    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 8 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (recommended) _Tag(context.l10n.themeRecommended),
                ],
              ),
              if (!compact)
                Text(
                  _desc(context.l10n)[kind]!,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
