import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'app_scope.dart';
import 'core/crash.dart';
import 'core/task.dart';
import 'widgets/task_steps.dart';
import 'pages/ai_page.dart';
import 'pages/diagnose_page.dart';
import 'pages/download_page.dart';
import 'pages/home_page.dart';
import 'pages/instance_page.dart';
import 'pages/log_page.dart';
import 'pages/settings_page.dart';
import 'pages/tasks_page.dart';
import 'pages/tools_page.dart';
import 'pages/versions_page.dart';
import 'widgets/window_buttons.dart';

enum MainPage { home, download, settings, tools, ai }

/// 从主页面进入的子页面：标题栏显示返回按钮和标题，代替主导航
enum SubPage { versions, log, instance, tasks, diagnose }

const _subTitles = {
  SubPage.versions: '版本选择',
  SubPage.log: '游戏日志',
  SubPage.instance: '版本设置',
  SubPage.tasks: '任务',
  SubPage.diagnose: '错误分析',
};

const _nav = [
  (page: MainPage.home, icon: Icons.rocket_launch_outlined, active: Icons.rocket_launch, label: '启动'),
  (page: MainPage.download, icon: Icons.download_outlined, active: Icons.download, label: '下载'),
  (page: MainPage.settings, icon: Icons.settings_outlined, active: Icons.settings, label: '设置'),
  (page: MainPage.tools, icon: Icons.construction_outlined, active: Icons.construction, label: '工具'),
  (page: MainPage.ai, icon: Icons.auto_awesome_outlined, active: Icons.auto_awesome, label: 'AI'),
];

/// 页面切换，供各页面打开子页面或返回
class ShellNav extends InheritedWidget {
  const ShellNav({super.key, required this.open, required this.back, required this.goMain, required super.child});

  final void Function(SubPage) open;
  final VoidCallback back;

  /// 关闭子页面并切换到某个主页面
  final void Function(MainPage) goMain;

  static ShellNav of(BuildContext context) => context.getInheritedWidgetOfExactType<ShellNav>()!;

  @override
  bool updateShouldNotify(ShellNav old) => false;
}

/// 主窗口：标题栏里放主导航（与 PCL 相同的布局），下面是当前页面。
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 游戏崩溃时弹出提示
    _crashes ??= AppScope.read(context).crashes.listen((report) {
      final ctx = _navKey.currentContext;
      if (ctx != null && ctx.mounted) showCrashDialog(ctx, report);
    });
  }

  @override
  void dispose() {
    _crashes?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShellNav(
      open: (s) => setState(() => _sub = s),
      back: () => setState(() => _sub = null),
      goMain: (p) => setState(() {
        _sub = null;
        _page = p;
      }),
      child: Scaffold(
        body: Stack(
          key: _navKey,
          children: [
            Column(
              children: [
                _TitleBar(
                  page: _page,
                  subTitle: _sub == SubPage.instance ? '版本设置 - ${AppScope.of(context).instanceId}' : _subTitles[_sub],
                  onSelect: (p) => setState(() => _page = p),
                  onBack: () => setState(() => _sub = null),
                ),
                Expanded(
                  child: switch (_sub) {
                    SubPage.versions => const VersionsPage(),
                    SubPage.log => const LogPage(),
                    SubPage.instance => const InstancePage(),
                    SubPage.tasks => const TasksPage(),
                    SubPage.diagnose => const DiagnosePage(),
                    null => IndexedStack(
                      index: _page.index,
                      children: const [HomePage(), DownloadPage(), SettingsPage(), ToolsPage(), AiPage()],
                    ),
                  },
                ),
              ],
            ),
            const Positioned(right: 20, bottom: 20, child: _InstallProgress()),
          ],
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.page, required this.subTitle, required this.onSelect, required this.onBack});

  final MainPage page;
  final String? subTitle;
  final ValueChanged<MainPage> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          // 空白处可拖动窗口，双击最大化
          const Positioned.fill(child: DragToMoveArea(child: SizedBox.expand())),
          Positioned(
            left: subTitle == null ? 20 : 8,
            top: 0,
            bottom: 0,
            child: subTitle == null
                ? IgnorePointer(
                    child: Row(
                      children: [
                        const PixelLogo(size: 18),
                        const SizedBox(width: 10),
                        Text(AppInfo.name, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      IconButton(tooltip: '返回', onPressed: onBack, icon: const Icon(Icons.arrow_back)),
                      const SizedBox(width: 4),
                      Text(subTitle!, style: theme.textTheme.titleMedium),
                    ],
                  ),
          ),
          if (subTitle == null)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in _nav)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _NavPill(
                        icon: page == item.page ? item.active : item.icon,
                        label: item.label,
                        selected: page == item.page,
                        onTap: () => onSelect(item.page),
                      ),
                    ),
                ],
              ),
            ),
          // 窗口按钮左侧：任务入口
          const Positioned(right: 46 * 3 + 4, top: 4, child: _TasksButton()),
          const Positioned(right: 0, top: 0, child: WindowButtons()),
        ],
      ),
    );
  }
}

/// 与 MD3 导航项相同的药丸形指示器
class _NavPill extends StatelessWidget {
  const _NavPill({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    return Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 像素风格的四格小方块 logo，颜色全部取自主题蓝
class PixelLogo extends StatelessWidget {
  const PixelLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final half = size / 2;
    Widget cell(Color c) => SizedBox(
      width: half,
      height: half,
      child: ColoredBox(color: c),
    );
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Column(
          children: [
            Row(children: [cell(s.primary), cell(s.tertiary)]),
            Row(children: [cell(s.secondary), cell(s.primaryContainer)]),
          ],
        ),
      ),
    );
  }
}

/// 标题栏的任务入口；有任务进行时显示进度环
class _TasksButton extends StatelessWidget {
  const _TasksButton();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final running = state.runningTasks;
    final failed = state.tasks.any((t) => t.state == TaskState.failed);
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: running.isEmpty ? '任务' : '${running.length} 个任务进行中',
      onPressed: () => ShellNav.of(context).open(SubPage.tasks),
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (running.isNotEmpty)
            const SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2)),
          Icon(Icons.download_outlined, size: 20, color: failed ? scheme.error : null),
        ],
      ),
    );
  }
}

/// 右下角的任务进度，点击进入任务页查看详情
class _InstallProgress extends StatelessWidget {
  const _InstallProgress();

  @override
  Widget build(BuildContext context) {
    final running = AppScope.of(context).runningTasks;
    if (running.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ShellNav.of(context).open(SubPage.tasks),
        child: Container(
          width: 340,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in running.take(3))
                ListenableBuilder(
                  listenable: t,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(t.title, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                        if (t.steps.isNotEmpty) ...[const SizedBox(height: 4), TaskSteps(task: t, dense: true)],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(t.stage, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                            ),
                            if (t.total > 0) Text('${t.done} / ${t.total}', style: theme.textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: t.fraction, borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                running.length > 3 ? '还有 ${running.length - 3} 个任务 · 点击查看详情' : '点击查看详情',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
