import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_info.dart';
import '../app_scope.dart';
import '../app_state.dart';
import '../core/android_runtime.dart';
import '../core/instance.dart';
import '../core/instance_config.dart';
import '../core/instance_files.dart';
import '../core/loader_names.dart';
import '../core/recent_worlds.dart';
import '../core/site_api.dart';
import '../core/updater.dart';
import '../platform.dart';
import '../shell.dart';
import '../widgets/cover_palette.dart';
import '../widgets/launch_dialogs.dart';
import 'download_page.dart';
import 'home_feed.dart';

/// 启动页：左边是当前版本（背景取自存档封面的颜色），右边是公告和常用操作，下面是最近游玩。
/// 左右分界线对齐顶栏「后台任务」的右边缘。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<RecentWorld>>? _worlds;
  String? _worldsKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    final config = state.config;
    final key = [config.gameDir, for (final folder in config.gameFolders) folder.path, state.gameState.index].join('\u0000');
    if (_worldsKey == key) return;
    final first = _worlds == null;
    _worldsKey = key;
    _worlds = recentWorlds(config, force: !first);
  }

  Future<void> _launch() async {
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
      if (mounted) toast(context, '启动失败：${errorText(e)}');
    }
  }

  Future<void> _playWorld(RecentWorld world) async {
    final state = AppScope.read(context);
    final versionId = world.versionId;
    if (versionId != null && versionId.isNotEmpty && state.selectedVersion?.id != versionId) {
      await state.selectVersion(versionId);
    }
    if (mounted) await _launch();
  }

  void _openInstance() {
    final version = AppScope.read(context).selectedVersion;
    if (version == null) return;
    AppScope.read(context).instanceId = version.id;
    ShellNav.of(context).open(SubPage.instance);
  }

  Future<void> _openFolder() async {
    final state = AppScope.read(context);
    final version = state.selectedVersion;
    if (version == null) return;
    try {
      await openInFileManager(await state.gameDirOf(version));
    } catch (e) {
      if (mounted) toast(context, '打不开文件夹：${errorText(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppScope.of(context);
    final version = state.selectedVersion;

    return FutureBuilder<List<RecentWorld>>(
      future: _worlds,
      builder: (context, snap) {
        final worlds = snap.data ?? const <RecentWorld>[];
        final latest = version == null ? null : worlds.where((w) => w.versionId == version.id).firstOrNull;
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 0, 16, 16),
          children: [
            SizedBox(
              height: 176,
              child: AlignedSplit(
                left: _HeroCard(
                  state: state,
                  version: version,
                  latest: latest,
                  onLaunch: _launch,
                  onVersions: () => ShellNav.of(context).open(SubPage.versions),
                  onSettings: version == null ? null : _openInstance,
                  onLog: () => ShellNav.of(context).open(SubPage.log),
                  onFolder: version == null ? null : _openFolder,
                ),
                right: _SidePanel(
                  onInstallMods: () {
                    downloadTabRequest.value = 'mods';
                    ShellNav.of(context).goMain(MainPage.download);
                  },
                  onManageMods: version == null ? null : _openInstance,
                  onFolder: version == null ? null : _openFolder,
                  onLog: () => ShellNav.of(context).open(SubPage.log),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Text('最近游玩', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: version == null ? null : _openInstance, child: const Text('全部存档 ›')),
                ],
              ),
            ),
            if (snap.connectionState == ConnectionState.waiting && worlds.isEmpty)
              const SizedBox(height: _WorldCard.height)
            else if (worlds.isEmpty)
              const _EmptyWorlds()
            else
              SizedBox(
                height: _WorldCard.height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: worlds.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _WorldCard(
                    world: worlds[i],
                    versionName: _versionName(state, worlds[i].versionId),
                    onTap: worlds[i].versionId == null ? null : () => state.selectVersion(worlds[i].versionId!),
                    onPlay: () => _playWorld(worlds[i]),
                  ),
                ),
              ),
            if (state.config.homeHints) ...[const SizedBox(height: 20), const HomeHints()],
            const ChangelogHint(),
            if (state.config.homeNews) ...[const SizedBox(height: 18), const VersionNewsFeed()],
          ],
        );
      },
    );
  }

  static String _versionName(AppState state, String? id) {
    if (id == null) return '';
    final v = state.versions.where((v) => v.id == id).firstOrNull;
    return v == null ? id : versionTitle(v);
  }
}

String _timeAgo(DateTime time) {
  final d = DateTime.now().difference(time);
  if (d.inMinutes < 1) return '刚刚';
  if (d.inHours < 1) return '${d.inMinutes} 分钟前';
  if (d.inDays < 1) return '${d.inHours} 小时前';
  if (d.inDays < 30) return '${d.inDays} 天前';
  return '${time.month}月${time.day}日';
}

/// 当前版本：背景是这个版本最近存档封面的主色，右上角是封面小图
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.state,
    required this.version,
    required this.latest,
    required this.onLaunch,
    required this.onVersions,
    required this.onSettings,
    required this.onLog,
    required this.onFolder,
  });

  final AppState state;
  final InstanceInfo? version;
  final RecentWorld? latest;
  final VoidCallback onLaunch;
  final VoidCallback onVersions;
  final VoidCallback? onSettings;
  final VoidCallback onLog;
  final VoidCallback? onFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = latest == null ? null : p.join(latest!.path, 'icon.png');
    final v = version;
    const white = Colors.white;
    return CoverBackground(
      iconPath: icon,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // 左侧压暗，保证文字清楚
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: .55), Colors.black.withValues(alpha: .25), Colors.black.withValues(alpha: .02)],
                  stops: const [0, .5, 1],
                ),
              ),
            ),
          ),
          if (latest != null)
            Positioned(right: 16, top: 16, child: CoverThumb(iconPath: icon, size: 72, modified: latest!.modified)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onVersions,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('切换版本', style: theme.textTheme.labelMedium?.copyWith(color: white.withValues(alpha: .8))),
                          Icon(Icons.expand_more, size: 16, color: white.withValues(alpha: .8)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.only(right: latest == null ? 0 : 84),
                  child: Text(
                    v == null ? '还没有选择版本' : versionTitle(v),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(color: white, fontWeight: FontWeight.w800),
                  ),
                ),
                if (v != null && versionTitle(v) != v.id)
                  Padding(
                    padding: EdgeInsets.only(right: latest == null ? 0 : 84),
                    child: Text(
                      v.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: white.withValues(alpha: .5), fontFamily: 'monospace'),
                    ),
                  ),
                const SizedBox(height: 4),
                if (v == null)
                  Text('先下载或选择一个版本，准备好就开始', style: theme.textTheme.bodySmall?.copyWith(color: white.withValues(alpha: .75)))
                else
                  _VersionFacts(state: state, version: v, latest: latest),
                const Spacer(),
                Row(
                  children: [
                    _LaunchButton(state: state, version: v, onLaunch: onLaunch),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onSettings,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: white,
                        side: BorderSide(color: white.withValues(alpha: .25)),
                        backgroundColor: Colors.black.withValues(alpha: .18),
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('版本设置'),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: '更多',
                      onSelected: (value) {
                        if (value == 'versions') onVersions();
                        if (value == 'log') onLog();
                        if (value == 'folder') onFolder?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'versions', child: Text('版本选择')),
                        PopupMenuItem(value: 'folder', enabled: onFolder != null, child: const Text('打开版本文件夹')),
                        const PopupMenuItem(value: 'log', child: Text('游戏日志')),
                      ],
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: white.withValues(alpha: .25)),
                        ),
                        child: const Icon(Icons.more_horiz, color: white),
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

/// 「12 个模组 · Zink 渲染 · 14 小时前玩过」
class _VersionFacts extends StatelessWidget {
  const _VersionFacts({required this.state, required this.version, required this.latest});

  final AppState state;
  final InstanceInfo version;
  final RecentWorld? latest;

  Future<int?> _modCount() async {
    try {
      final dir = Directory(p.join(await state.gameDirOf(version), 'mods'));
      if (!dir.existsSync()) return 0;
      return dir.listSync().where((e) => e is File && e.path.toLowerCase().endsWith('.jar')).length;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? renderer;
    if (Platform.isAndroid) {
      final inst = readInstanceSettings(state.paths.versionDir(version.id)).renderer;
      final pref = inst.isNotEmpty ? inst : state.config.androidRenderer;
      if (pref != 'auto') renderer = androidRenderers[pref]?.split('（').first;
    }
    return FutureBuilder<int?>(
      future: version.loader == Loader.vanilla ? Future.value(null) : _modCount(),
      builder: (context, snap) {
        final parts = [
          if (snap.data != null) '${snap.data} 个模组',
          ?renderer == null ? null : '$renderer 渲染',
          if (latest != null) '${_timeAgo(latest!.modified)}玩过',
          if (snap.data == null && renderer == null && latest == null) describeVersion(version),
        ];
        return Text(
          parts.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: .78)),
        );
      },
    );
  }
}

class _LaunchButton extends StatelessWidget {
  const _LaunchButton({required this.state, required this.version, required this.onLaunch});

  final AppState state;
  final InstanceInfo? version;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)));
    if (state.gameState == GameState.preparing && state.task != null) {
      return ListenableBuilder(
        listenable: state.task!,
        builder: (context, _) {
          final t = state.task!;
          return Container(
            width: 190,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.total > 0 ? '${t.stage} · ${t.countText}' : t.stage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: t.fraction,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(4),
                  color: scheme.primaryFixed,
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
            style: FilledButton.styleFrom(shape: shape, minimumSize: const Size(130, 44)),
            icon: const Icon(Icons.sports_esports, size: 19),
            label: const Text('返回游戏'),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: '结束游戏',
            onPressed: state.killGame,
            style: IconButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size(44, 44),
              shape: shape,
            ),
            icon: const Icon(Icons.stop, size: 19),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: running ? state.killGame : (version == null ? null : onLaunch),
      style: FilledButton.styleFrom(
        backgroundColor: running ? scheme.error : scheme.primaryFixed,
        foregroundColor: running ? scheme.onError : scheme.onPrimaryFixed,
        disabledBackgroundColor: Colors.white.withValues(alpha: .2),
        disabledForegroundColor: Colors.white.withValues(alpha: .6),
        shape: shape,
        minimumSize: const Size(132, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      icon: Icon(running ? Icons.stop : Icons.play_arrow, size: 20),
      label: Text(running ? '结束游戏' : '开始游戏'),
    );
  }
}

/// 右半边：启动器公告 + 2×2 常用操作（跟当前版本相关）
class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.onInstallMods, required this.onManageMods, required this.onFolder, required this.onLog});

  final VoidCallback onInstallMods;
  final VoidCallback? onManageMods;
  final VoidCallback? onFolder;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _NoticeStrip(),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _QuickButton(icon: Icons.download_outlined, label: '装模组', onTap: onInstallMods)),
                      const SizedBox(width: 6),
                      Expanded(child: _QuickButton(icon: Icons.view_list_outlined, label: '管理模组', onTap: onManageMods)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _QuickButton(icon: Icons.folder_outlined, label: '文件夹', onTap: onFolder)),
                      const SizedBox(width: 6),
                      Expanded(child: _QuickButton(icon: Icons.article_outlined, label: '查看日志', onTap: onLog)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 19, color: enabled ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: .5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: enabled ? null : scheme.onSurfaceVariant.withValues(alpha: .5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 启动器公告（notices.json）里当前可见的第一条，标题和「查看」同一行，内容最多两行
class _NoticeStrip extends StatefulWidget {
  const _NoticeStrip();

  @override
  State<_NoticeStrip> createState() => _NoticeStripState();
}

class _NoticeStripState extends State<_NoticeStrip> {
  final _future = loadNotices();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cfg = AppScope.of(context).config;
    return FutureBuilder<List<Notice>>(
      future: _future,
      builder: (context, snap) {
        final notice = (snap.data ?? const <Notice>[])
            .where(
              (n) => n.visibleFor(
                platform: noticePlatform,
                channel: UpdateChannel.parse(cfg.updateChannel).name,
                version: AppInfo.version,
                now: DateTime.now(),
                dismissed: const {},
              ),
            )
            .firstOrNull;
        final title = notice?.title ?? '启动器公告';
        final body = notice == null
            ? (snap.connectionState == ConnectionState.waiting ? '正在获取…' : '暂无公告')
            : notice.body.replaceAll(RegExp(r'[#*_`>\[\]]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        return Material(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showNoticesDialog(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('查看 ›', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: .8))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body.isEmpty ? title : body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 最近游玩：上半部分是封面主色 + 居中的清晰小封面，下半部分是名称和版本
class _WorldCard extends StatelessWidget {
  const _WorldCard({required this.world, required this.versionName, required this.onTap, required this.onPlay});

  final RecentWorld world;
  final String versionName;
  final VoidCallback? onTap;
  final VoidCallback onPlay;

  static const height = 124.0;
  static const width = 196.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = p.join(world.path, 'icon.png');
    return SizedBox(
      width: width,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 68,
                    child: CoverBackground(
                      iconPath: icon,
                      child: Center(child: CoverThumb(iconPath: icon, size: 54, radius: 9, modified: world.modified)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          world.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          [if (versionName.isNotEmpty) versionName, _timeAgo(world.modified)].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 8,
                top: 46,
                child: IconButton.filled(
                  tooltip: '进入这个存档的版本',
                  onPressed: onPlay,
                  style: IconButton.styleFrom(minimumSize: const Size(40, 40), fixedSize: const Size(40, 40)),
                  icon: const Icon(Icons.play_arrow, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorlds extends StatelessWidget {
  const _EmptyWorlds();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.landscape_outlined, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '开始一次游戏后，最近的存档会出现在这里。',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
