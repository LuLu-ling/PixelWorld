import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:window_manager/window_manager.dart';

import 'app_scope.dart';
import 'core/accounts.dart';
import 'app_state.dart';
import 'core/crash.dart';
import 'l10n/l10n.dart';
import 'platform.dart';
import 'widgets/accounts_dialog.dart';
import 'widgets/agreement_dialog.dart';
import 'widgets/app_background.dart';
import 'widgets/app_logo.dart';
import 'widgets/device_login_dialog.dart' show resumePendingMicrosoftLogin;
import 'widgets/device_status.dart';
import 'widgets/oobe.dart';
import 'widgets/shell_layout.dart';
import 'widgets/storage_location.dart';
import 'widgets/tour.dart';
import 'widgets/update_dialog.dart';
import 'widgets/window_buttons.dart';
import 'pages/ai_page.dart';
import 'pages/diagnose_page.dart';
import 'pages/download_page.dart';
import 'pages/file_manager_page.dart';
import 'pages/home_feed.dart';
import 'pages/home_page.dart';
import 'pages/instance_page.dart';
import 'pages/log_page.dart';
import 'pages/settings_page.dart';
import 'pages/tasks_page.dart';
import 'pages/tools_page.dart';
import 'pages/versions_page.dart';
import 'widgets/mac_traffic_lights.dart';

export 'widgets/shell_layout.dart' show AlignedSplit;

/// files 只在手机上出现（内置文件管理器）；电脑上打开文件夹用系统的资源管理器
enum MainPage { home, download, settings, tools, ai, files }

/// 从主页面进入的子页面：顶栏显示返回按钮和标题
enum SubPage { versions, log, instance, tasks, diagnose }

String _subTitle(AppLocalizations l, SubPage p) => switch (p) {
  SubPage.versions => l.subVersions,
  SubPage.log => l.subLog,
  SubPage.instance => l.subInstance,
  SubPage.tasks => l.subTasks,
  SubPage.diagnose => l.subDiagnose,
};

String _mainTitle(AppLocalizations l, MainPage p) => switch (p) {
  MainPage.home => l.navHome,
  MainPage.download => l.navDownload,
  MainPage.settings => l.navSettings,
  MainPage.tools => l.navTools,
  MainPage.ai => l.navAiAssistant,
  MainPage.files => l.navFiles,
};

/// 页面切换，供各页面打开子页面或返回
class ShellNav extends InheritedWidget {
  const ShellNav({super.key, required this.open, required this.back, required this.goMain, required super.child});

  final void Function(SubPage) open;
  final VoidCallback back;

  /// 关闭子页面并切换到某个主页面
  final void Function(MainPage) goMain;

  /// 切到「设置」页的某个小节（见 SettingsPage 的小节名，例如 ai、aiTools）
  void openSettings(String section) {
    settingsSectionRequest.value = section;
    goMain(MainPage.settings);
  }

  static ShellNav of(BuildContext context) => context.getInheritedWidgetOfExactType<ShellNav>()!;

  static ShellNav? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<ShellNav>();

  @override
  bool updateShouldNotify(ShellNav old) => false;
}

/// 主窗口：左边是窄侧栏，右边是顶栏和页面内容。
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  MainPage _page = MainPage.home;
  SubPage? _sub;
  StreamSubscription<CrashReport>? _crashes;
  final _navKey = GlobalKey();
  final _rootKey = GlobalKey();
  final _splitX = ValueNotifier<double?>(null);
  bool _askedStorage = false;

  @override
  void initState() {
    super.initState();
    // 手机上「打开文件夹」切到「文件」页，而不是盖住整个界面
    fileManagerRequest.addListener(_onFileRequest);
  }

  void _onFileRequest() {
    if (fileManagerRequest.value != null && mounted) _goMain(MainPage.files);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 游戏崩溃时弹出提示
    _crashes ??= AppScope.read(context).crashes.listen((report) {
      final ctx = _navKey.currentContext;
      if (ctx != null && ctx.mounted) showCrashDialog(ctx, report);
    });
    if (!_askedStorage) {
      _askedStorage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ctx = _navKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        // 上次去浏览器登录微软账户时启动器被系统杀掉了：接着完成那次登录
        await resumePendingMicrosoftLogin(ctx);
        if (!ctx.mounted) return;
        // 全新安装：全屏的首次设置（协议、外观、游戏文件夹、网络、账户）
        final oobe = await showOobeIfNeeded(ctx);
        if (!ctx.mounted) return;
        if (oobe == null) {
          // 老用户：协议更新时请用户重新确认（不同意会退出），安卓上没问过存储位置的再问一次
          await ensureAgreement(ctx);
          if (!ctx.mounted) return;
          await askStorageOnFirstRun(ctx);
        }
        // 等启动画面（或首次设置）淡出后开始新手教程
        await Future<void>.delayed(Duration(milliseconds: oobe == null ? 1200 : 400));
        final again = _navKey.currentContext;
        if (again == null || !again.mounted) return;
        if (oobe?.download == true) {
          // 「去安装第一个实例」：看完教程（如果要看）再打开下载页
          if (oobe!.tour) {
            startTour(again, onClose: () => _goMain(MainPage.download));
          } else {
            _goMain(MainPage.download);
          }
        } else {
          startTourOnFirstRun(again);
        }
      });
      // 启动后稍等一会再检查更新，不和首次运行的提示抢
      Future<void>.delayed(const Duration(seconds: 5), () async {
        // 还在首次设置、还没同意用户协议、第一次打开还没看完新手教程、或者教程正在进行：等它们结束再弹更新提示
        while (tourRunning.value ||
            mounted &&
                (!AppScope.read(context).config.oobeDone ||
                    AppScope.read(context).config.agreementVersion < agreementVersion ||
                    !AppScope.read(context).config.tourSeen)) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        final ctx = _navKey.currentContext;
        if (ctx != null && ctx.mounted && AppScope.read(ctx).config.updateAutoCheck) checkUpdates(ctx, manual: false);
      });
    }
  }

  @override
  void dispose() {
    fileManagerRequest.removeListener(_onFileRequest);
    _crashes?.cancel();
    _splitX.dispose();
    super.dispose();
  }

  void _goMain(MainPage page) => setState(() {
    _sub = null;
    _page = page;
  });

  void _openSub(SubPage page) => setState(() => _sub = page);

  @override
  Widget build(BuildContext context) {
    final pageView = switch (_sub) {
      SubPage.versions => const VersionsPage(),
      SubPage.log => const LogPage(),
      SubPage.instance => const InstancePage(),
      SubPage.tasks => const TasksPage(),
      SubPage.diagnose => const DiagnosePage(),
      null => IndexedStack(
        index: _page.index,
        children: [
          const HomePage(),
          const DownloadPage(),
          const SettingsPage(),
          const ToolsPage(),
          const AiPage(),
          if (isDesktop) const SizedBox.shrink() else const EmbeddedFileManager(),
        ],
      ),
    };
    final scheme = Theme.of(context).colorScheme;

    final shell = Scaffold(
      key: _navKey,
      backgroundColor: scheme.surface,
      body: BackgroundScope(
        controller: AppScope.of(context).background,
        rootKey: _rootKey,
        child: KeyedSubtree(
          key: _rootKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 电脑端设了背景图片时铺满整个窗口；没有时什么都不画
              const BackgroundLayer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Rail(page: _page, sub: _sub, onMain: _goMain),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeLeft: true,
                      removeTop: true,
                      removeRight: true,
                      removeBottom: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopBar(
                            page: _page,
                            sub: _sub,
                            onBack: () => setState(() => _sub = null),
                            rootKey: _rootKey,
                            splitX: _splitX,
                          ),
                          Expanded(child: pageView),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ShellLayout(
      rootKey: _rootKey,
      splitX: _splitX,
      child: ShellNav(open: _openSub, back: () => setState(() => _sub = null), goMain: _goMain, child: shell),
    );
  }
}

/// 窄侧栏：图标 + 短文字。手机横屏时背景一直铺到挖孔那一侧，内容从挖孔右边开始。
class _Rail extends StatelessWidget {
  const _Rail({required this.page, required this.sub, required this.onMain});

  final MainPage page;
  final SubPage? sub;
  final ValueChanged<MainPage> onMain;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inset = MediaQuery.paddingOf(context).left;
    // macOS 的红绿灯由原生代码挪到侧栏里水平居中、与顶栏中线对齐（MacTrafficLightsAnchor 告诉原生代码侧栏的实际宽度）：
    // 侧栏加宽到能完整容纳它们，图标从它们下面留出空隙再开始
    final top = Platform.isMacOS ? 64.0 : 10.0;
    final width = Platform.isMacOS ? 84.0 : 76.0;
    final l = context.l10n;
    Widget item(MainPage p, IconData icon, IconData active, [String? label]) => TourTarget(
      id: 'rail.${p.name}',
      child: _RailItem(
        icon: icon,
        activeIcon: active,
        label: label ?? _mainTitle(l, p),
        selected: page == p && (sub == null || p == MainPage.home && sub == SubPage.instance),
        onTap: () => onMain(p),
      ),
    );
    return MacTrafficLightsAnchor(
      topBarHeight: 56,
      child: GlassPanel(
        color: scheme.surfaceContainerLow,
        extraOpacity: .08,
        child: Container(
          width: width + inset,
          padding: EdgeInsets.fromLTRB(inset, top, 0, 10),
          child: Column(
            children: [
              const AppLogo(size: 36),
              const SizedBox(height: 10),
              item(MainPage.home, Icons.rocket_launch_outlined, Icons.rocket_launch),
              item(MainPage.download, Icons.download_outlined, Icons.download),
              item(MainPage.tools, Icons.construction_outlined, Icons.construction),
              // 手机上的内置文件管理器（电脑上打开文件夹用系统的资源管理器）
              if (!isDesktop) item(MainPage.files, Icons.folder_outlined, Icons.folder),
              item(MainPage.settings, Icons.settings_outlined, Icons.settings),
              item(MainPage.ai, Icons.chat_bubble_outline, Icons.chat_bubble, 'AI'),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? scheme.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 21,
                  color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 内容区顶栏：标题（首页是问候语）、后台任务、搜索与通知、设备状态、账户、窗口按钮。
class _TopBar extends StatefulWidget {
  const _TopBar({
    required this.page,
    required this.sub,
    required this.onBack,
    required this.rootKey,
    required this.splitX,
  });

  final MainPage page;
  final SubPage? sub;
  final VoidCallback onBack;
  final GlobalKey rootKey;
  final ValueNotifier<double?> splitX;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final _tasksKey = GlobalKey();

  /// 量出「后台任务」右边缘，供页面对齐左右两栏
  void _measure() {
    final root = widget.rootKey.currentContext?.findRenderObject();
    final box = _tasksKey.currentContext?.findRenderObject();
    if (root is! RenderBox || box is! RenderBox || !box.attached || !root.attached) return;
    final x = box.localToGlobal(Offset(box.size.width, 0), ancestor: root).dx;
    if (widget.splitX.value == null || (widget.splitX.value! - x).abs() > .5) widget.splitX.value = x;
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
    return LayoutBuilder(
      builder: (context, c) {
        // 按可用宽度分三档：宽 ≥ 900 全部显示；中等去掉问候语后的小字、账户只显示头像；窄再收起「公告」
        final compact = c.maxWidth < 900;
        final tight = c.maxWidth < 760;
        return _bar(context, compact: compact, tight: tight);
      },
    );
  }

  Widget _bar(BuildContext context, {required bool compact, required bool tight}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final sub = widget.sub;
    final l = context.l10n;
    // 启用背景图片时 fg、muted 是统一的黑字或白字，要显式写进字体样式（主题字体自带颜色会盖掉外层的默认颜色）
    Widget title(Color? fg, Color? muted) {
      if (sub != null) {
        final text = _subTitle(l, sub);
        return Row(
          children: [
            IconButton(
              tooltip: l.tooltipBack,
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back, size: 20, color: fg),
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: fg),
              ),
            ),
          ],
        );
      } else if (widget.page == MainPage.home) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: greeting(l, state.selectedAccount?.name),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (!compact)
                TextSpan(
                  text: '  ${l.greetingAdventure}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted ?? scheme.onSurfaceVariant),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(color: fg),
        );
      } else {
        return Text(
          _mainTitle(l, widget.page),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: fg),
        );
      }
    }

    // 桌面端：标题区域拖动窗口
    Widget titleArea = Align(
      alignment: Alignment.centerLeft,
      child: OnBackground(builder: (context, fg, muted) => title(fg, muted)),
    );
    if (isDesktop && !Platform.isLinux) titleArea = DragToMoveArea(child: SizedBox.expand(child: titleArea));

    return SizedBox(
      height: 56,
      child: Padding(
        padding: EdgeInsets.only(
          left: (sub != null ? 6 : 14) + (Platform.isMacOS ? 8 : 0),
          right: isDesktop && !nativeWindowButtons ? 0 : 14,
        ),
        child: Row(
          children: [
            Expanded(child: titleArea),
            const SizedBox(width: 8),
            TourTarget(
              id: 'top.tasks',
              child: _TasksPill(key: _tasksKey, width: tight ? 168 : (compact ? 200 : 236)),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: l.versionsSearchInstances,
              onPressed: () {
                versionsSearchRequest.value = true;
                ShellNav.of(context).open(SubPage.versions);
              },
              icon: const Icon(Icons.search, size: 21),
            ),
            if (!tight)
              IconButton(
                tooltip: l.tooltipNotices,
                onPressed: () => showNoticesDialog(context),
                icon: const Icon(Icons.notifications_none_outlined, size: 21),
              ),
            if (!isDesktop) ...[const SizedBox(width: 4), const _BarChip(child: DeviceStatus())],
            const SizedBox(width: 6),
            TourTarget(
              id: 'top.account',
              child: _AccountChip(avatarOnly: compact),
            ),
            if (isDesktop && !nativeWindowButtons) ...[const SizedBox(width: 8), const WindowButtons()],
          ],
        ),
      ),
    );
  }
}

/// 首页问候语
String greeting(AppLocalizations l, String? name) {
  final h = DateTime.now().hour;
  final when = h < 5
      ? l.greetingLateNight
      : h < 11
      ? l.greetingMorning
      : h < 13
      ? l.greetingNoon
      : h < 18
      ? l.greetingAfternoon
      : l.greetingEvening;
  return name == null ? when : l.greetingWithName(when, name);
}

/// 顶栏里统一样式的小块按钮
class _BarChip extends StatelessWidget {
  const _BarChip({required this.child, this.onTap, this.color, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = InkWell(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: child,
      ),
    );
    // 指定了颜色（例如任务出错时）保持实色，其余在启用背景时是毛玻璃
    if (color != null) {
      return Material(
        color: color,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }
    return GlassPanel(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(9), child: content);
  }
}

/// 后台任务：没有任务时显示「当前无后台任务」；有任务时显示第一个任务和进度。点击进入任务页。
class _TasksPill extends StatelessWidget {
  const _TasksPill({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final running = state.runningTasks;
    final task = running.firstOrNull;
    final l = context.l10n;
    // 没有后台任务但游戏在运行时显示运行中的实例数（点击仍进入任务页）
    final games = state.gameState == GameState.running ? 1 : 0;
    return SizedBox(
      width: width,
      child: _BarChip(
        onTap: () => ShellNav.of(context).open(SubPage.tasks),
        color: task == null ? null : scheme.primaryContainer,
        child: task == null
            ? Row(
                children: [
                  Icon(
                    games > 0 ? Icons.sports_esports_outlined : Icons.check,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      games > 0 ? l.tasksGamesRunning(games) : l.tasksIdle,
                      style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: scheme.onSurfaceVariant),
                ],
              )
            : ListenableBuilder(
                listenable: task,
                builder: (context, _) => Row(
                  children: [
                    Icon(Icons.downloading, size: 16, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            running.length > 1 ? l.tasksMore(task.title, running.length) : task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
                          ),
                          const SizedBox(height: 3),
                          LinearProgressIndicator(
                            value: task.fraction,
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(2),
                            color: scheme.primary,
                            backgroundColor: scheme.onPrimaryContainer.withValues(alpha: .15),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: scheme.onPrimaryContainer),
                  ],
                ),
              ),
      ),
    );
  }
}

/// 账户：头像首字母 + 名称 · 类型，点击切换账户
class _AccountChip extends StatelessWidget {
  const _AccountChip({this.avatarOnly = false});

  /// 窄屏只显示头像，名称放在提示里
  final bool avatarOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final account = AppScope.of(context).selectedAccount;
    final l = context.l10n;
    final kind = switch (account?.type) {
      null => '',
      AccountType.microsoft => ' · ${l.accountMicrosoft}',
      AccountType.offline => ' · ${l.accountOffline}',
      _ => ' · ${account!.serverName ?? l.accountExternal}',
    };
    final chip = _BarChip(
      onTap: () => showAccountsDialog(context),
      padding: EdgeInsets.only(left: 7, right: avatarOnly ? 7 : 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
            child: Text(
              account == null ? '+' : account.name.characters.first.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!avatarOnly) const SizedBox(width: 7),
          if (!avatarOnly)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                account == null ? l.accountAdd : '${account.name}$kind',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
    return Tooltip(message: account == null ? l.accountAdd : '${account.name}$kind', child: chip);
  }
}
