import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../app_state.dart';
import '../core/instance.dart';
import '../core/loader_names.dart';
import '../core/recent_worlds.dart';
import '../platform.dart';
import '../shell.dart';
import '../widgets/launch_dialogs.dart';
import 'home_feed.dart';

/// 启动页：绿色主视觉、当前实例和最近游玩。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _launch(BuildContext context) async {
    final state = AppScope.read(context);
    final view = View.of(context);
    final display = PlatformDispatcher.instance.displays.firstOrNull;
    final launcher = view.physicalSize / view.devicePixelRatio;
    final screen = display == null ? launcher : display.size / display.devicePixelRatio;
    try {
      await state.launch(
        DialogLaunchPrompts(context),
        launcherSize: (width: launcher.width.round(), height: launcher.height.round()),
        screenSize: (width: screen.width.round(), height: screen.height.round()),
      );
    } catch (e) {
      if (context.mounted) toast(context, '启动失败：${errorText(e)}');
    }
  }

  Future<void> _playWorld(BuildContext context, RecentWorld world) async {
    final state = AppScope.read(context);
    final versionId = world.versionId;
    if (versionId != null && versionId.isNotEmpty && state.selectedVersion?.id != versionId) {
      await state.selectVersion(versionId);
    }
    if (context.mounted) await _launch(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final acc = state.selectedAccount;
    final version = state.selectedVersion;

    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 6, 30, 30),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(acc?.name),
                    style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '准备好冒险了吗？',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.4),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '版本选择',
              onPressed: () => ShellNav.of(context).open(SubPage.versions),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: '任务历史',
              onPressed: () => ShellNav.of(context).open(SubPage.tasks),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _HeroCard(
          state: state,
          version: version,
          onLaunch: () => _launch(context),
          onVersions: () => ShellNav.of(context).open(SubPage.versions),
          onSettings: version == null
              ? null
              : () {
                  AppScope.read(context).instanceId = version.id;
                  ShellNav.of(context).open(SubPage.instance);
                },
          onLog: () => ShellNav.of(context).open(SubPage.log),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Text('最近游玩', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text('快速回到你的世界', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            const Spacer(),
            TextButton(
              onPressed: () => ShellNav.of(context).open(SubPage.versions),
              child: const Text('获取更多'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _RecentWorldsSection(
          onSelectVersion: (id) => state.selectVersion(id),
          onPlay: (world) => _playWorld(context, world),
        ),
        if (state.config.homeHints) ...[const SizedBox(height: 20), const HomeHints()],
        const ChangelogHint(),
        const HomeNotices(),
        if (state.config.homeNews) ...[const SizedBox(height: 18), const VersionNewsFeed()],
      ],
    );
  }

  static String _greeting(String? name) {
    final h = DateTime.now().hour;
    final when = h < 5
        ? '夜深了'
        : h < 11
        ? '早上好'
        : h < 13
        ? '中午好'
        : h < 18
        ? '下午好'
        : '晚上好';
    return name == null ? when : '$when，$name';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.state,
    required this.version,
    required this.onLaunch,
    required this.onVersions,
    required this.onSettings,
    required this.onLog,
  });

  final AppState state;
  final InstanceInfo? version;
  final VoidCallback onLaunch;
  final VoidCallback onVersions;
  final VoidCallback? onSettings;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const forest = Color(0xFF2F6B4F);
    const forestDeep = Color(0xFF1D4A35);
    return Container(
      height: 238,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [forest, forestDeep],
        ),
        boxShadow: [BoxShadow(color: forest.withValues(alpha: .22), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _VoxelLandscapePainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _Pill(label: '当前实例', light: true),
                    if (version != null) ...[
                      const SizedBox(width: 7),
                      _Pill(label: '已同步', light: false, icon: Icons.check),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  version?.id ?? '还没有选择版本',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  version == null ? '先下载或选择一个版本，准备好就开始' : describeVersion(version!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .76)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _HeroLaunchButton(state: state, version: version, onLaunch: onLaunch),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      tooltip: '更多',
                      color: const Color(0xFF244C39),
                      iconColor: Colors.white,
                      onSelected: (value) {
                        if (value == 'versions') onVersions();
                        if (value == 'settings') onSettings?.call();
                        if (value == 'log') onLog();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'versions', child: Text('版本选择')),
                        PopupMenuItem(value: 'settings', enabled: onSettings != null, child: const Text('版本设置')),
                        const PopupMenuItem(value: 'log', child: Text('游戏日志')),
                      ],
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: .18)),
                        ),
                        child: const Icon(Icons.more_horiz, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLaunchButton extends StatelessWidget {
  const _HeroLaunchButton({required this.state, required this.version, required this.onLaunch});

  final AppState state;
  final InstanceInfo? version;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)));
    if (state.gameState == GameState.preparing && state.task != null) {
      return ListenableBuilder(
        listenable: state.task!,
        builder: (context, _) {
          final t = state.task!;
          return Container(
            width: 210,
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.stage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                    if (t.total > 0)
                      Text(t.countText, style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: t.fraction,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFD9F2D4),
                  backgroundColor: Colors.white.withValues(alpha: .18),
                ),
              ],
            ),
          );
        },
      );
    }

    final running = state.gameState == GameState.running;
    if (running && !isDesktop) {
      return Row(
        children: [
          FilledButton.icon(
            onPressed: state.resumeGame,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE4F4DF),
              foregroundColor: const Color(0xFF1D3D2B),
              shape: shape,
              minimumSize: const Size(150, 46),
            ),
            icon: const Icon(Icons.sports_esports, size: 19),
            label: const Text('返回游戏'),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: state.killGame,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.stop, size: 19),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: running ? state.killGame : (version == null ? null : onLaunch),
      style: FilledButton.styleFrom(
        backgroundColor: running ? theme.colorScheme.error : const Color(0xFFE4F4DF),
        foregroundColor: running ? theme.colorScheme.onError : const Color(0xFF1D3D2B),
        disabledBackgroundColor: Colors.white.withValues(alpha: .2),
        disabledForegroundColor: Colors.white.withValues(alpha: .6),
        shape: shape,
        minimumSize: const Size(170, 46),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      icon: Icon(running ? Icons.stop : Icons.play_arrow, size: 19),
      label: Text(running ? '结束游戏' : '开始游戏'),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.light, this.icon});

  final String label;
  final bool light;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: .2) : const Color(0xFFBFE3B4).withValues(alpha: .95),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: const Color(0xFF234A33)),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: light ? Colors.white : const Color(0xFF234A33),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentWorldsSection extends StatefulWidget {
  const _RecentWorldsSection({required this.onSelectVersion, required this.onPlay});

  final ValueChanged<String> onSelectVersion;
  final ValueChanged<RecentWorld> onPlay;

  @override
  State<_RecentWorldsSection> createState() => _RecentWorldsSectionState();
}

class _RecentWorldsSectionState extends State<_RecentWorldsSection> {
  Future<List<RecentWorld>>? _future;
  String? _key;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final config = state.config;
    final key = [
      config.gameDir,
      for (final folder in config.gameFolders) folder.path,
      state.gameState.index,
    ].join('\u0000');
    if (_key == key) return;
    final first = _future == null;
    _key = key;
    _future = recentWorlds(config, force: !first);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentWorld>>(
      future: _future,
      builder: (context, snapshot) {
        final worlds = snapshot.data ?? const <RecentWorld>[];
        if (snapshot.connectionState == ConnectionState.waiting && worlds.isEmpty) {
          return const SizedBox(height: 92);
        }
        if (worlds.isEmpty) return const _EmptyWorlds();
        return _WorldGrid(
          worlds: worlds,
          onSelect: widget.onSelectVersion,
          onPlay: widget.onPlay,
        );
      },
    );
  }
}

class _WorldGrid extends StatelessWidget {
  const _WorldGrid({required this.worlds, required this.onSelect, required this.onPlay});

  final List<RecentWorld> worlds;
  final ValueChanged<String> onSelect;
  final ValueChanged<RecentWorld> onPlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 840 ? 3 : (constraints.maxWidth >= 540 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: worlds.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.0,
          ),
          itemBuilder: (context, index) {
            final world = worlds[index];
            return _WorldCard(
              world: world,
              onTap: world.versionId == null ? null : () => onSelect(world.versionId!),
              onPlay: () => onPlay(world),
            );
          },
        );
      },
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({required this.world, required this.onTap, required this.onPlay});

  final RecentWorld world;
  final VoidCallback? onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(Icons.landscape_outlined, size: 25, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      world.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${world.versionId ?? world.folderName} · ${_timeAgo(world.modified)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '启动这个版本',
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primaryContainer.withValues(alpha: .65),
                  foregroundColor: scheme.onPrimaryContainer,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime time) {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return '刚刚';
    if (d.inHours < 1) return '${d.inMinutes} 分钟前';
    if (d.inDays < 1) return '${d.inHours} 小时前';
    if (d.inDays < 7) return '${d.inDays} 天前';
    return '${time.month}/${time.day}';
  }
}

class _EmptyWorlds extends StatelessWidget {
  const _EmptyWorlds();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(Icons.landscape_outlined, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('似乎还没有玩过哦', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '开始一次游戏后，最近的存档会出现在这里。',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页主视觉的方块风景，不依赖 Minecraft 官方素材。
class _VoxelLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final right = w * .58;
    final bottom = h;

    final sun = Paint()..color = const Color(0xFFFFE59A).withValues(alpha: .9);
    canvas.drawCircle(Offset(w * .82, h * .24), h * .09, sun);

    final cloud = Paint()..color = Colors.white.withValues(alpha: .2);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .67, h * .16, w * .1, h * .045), const Radius.circular(8)), cloud);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .72, h * .27, w * .07, h * .035), const Radius.circular(8)), cloud);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .9, h * .14, w * .06, h * .03), const Radius.circular(8)), cloud);

    final backHill = Paint()..color = const Color(0xFF4F8266).withValues(alpha: .55);
    final hill = Paint()..color = const Color(0xFF3E7258).withValues(alpha: .7);
    final front = Paint()..color = const Color(0xFF2B5B45);
    final path = Path()
      ..moveTo(right, bottom)
      ..lineTo(right, h * .56)
      ..lineTo(w * .7, h * .28)
      ..lineTo(w * .79, h * .56)
      ..lineTo(w * .86, h * .4)
      ..lineTo(w, h * .6)
      ..lineTo(w, bottom)
      ..close();
    canvas.drawPath(path, backHill);

    final path2 = Path()
      ..moveTo(w * .54, bottom)
      ..lineTo(w * .54, h * .7)
      ..lineTo(w * .66, h * .47)
      ..lineTo(w * .75, h * .7)
      ..lineTo(w * .81, h * .62)
      ..lineTo(w, h * .82)
      ..lineTo(w, bottom)
      ..close();
    canvas.drawPath(path2, hill);

    final ground = Path()
      ..moveTo(w * .55, bottom)
      ..lineTo(w * .55, h * .84)
      ..lineTo(w * .72, h * .76)
      ..lineTo(w * .86, h * .84)
      ..lineTo(w, h * .78)
      ..lineTo(w, bottom)
      ..close();
    canvas.drawPath(ground, front);

    // 前景的方块树和草方块
    final trunk = Paint()..color = const Color(0xFF6C4B2F);
    final leaves = Paint()..color = const Color(0xFF4B8A5A);
    final grass = Paint()..color = const Color(0xFF5D9B63);
    final soil = Paint()..color = const Color(0xFF795A3C);

    canvas.drawRect(Rect.fromLTWH(w * .77, h * .72, w * .018, h * .14), trunk);
    canvas.drawRect(Rect.fromLTWH(w * .742, h * .62, w * .074, h * .11), leaves);
    canvas.drawRect(Rect.fromLTWH(w * .752, h * .57, w * .054, h * .06), leaves);

    canvas.drawRect(Rect.fromLTWH(w * .63, h * .82, w * .055, h * .045), grass);
    canvas.drawRect(Rect.fromLTWH(w * .63, h * .865, w * .055, h * .035), soil);
    canvas.drawRect(Rect.fromLTWH(w * .89, h * .8, w * .05, h * .04), grass);
    canvas.drawRect(Rect.fromLTWH(w * .89, h * .84, w * .05, h * .035), soil);

    final haze = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: .07), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), haze);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
