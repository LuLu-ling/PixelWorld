import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../core/android_storage.dart';
import '../core/config.dart';
import '../core/instance.dart';
import '../core/loader_names.dart';
import '../core/paths.dart';
import '../shell.dart';
import '../widgets/loader_label.dart';
import 'file_manager_page.dart';
import '../widgets/side_nav.dart';
import '../widgets/app_background.dart';
import 'download_page.dart' show downloadTabRequest;
import 'home_page.dart' show instanceModCount;
import 'instance_page.dart' show instanceSectionRequest;
import '../l10n/l10n.dart';

/// 打开实例列表时聚焦搜索框（顶栏的搜索按钮）；已在实例列表时也会重新聚焦
final versionsSearchRequest = ValueNotifier<bool>(false);

/// 版本选择：左侧游戏文件夹，右侧该文件夹中的版本（PCL 的布局）
class VersionsPage extends StatefulWidget {
  const VersionsPage({super.key});

  /// 与 PCL-CE 的 McFolderListLoadSub 一致的自动发现规则，加上用户添加的文件夹
  static List<GameFolder> folders(LauncherConfig cfg, AppLocalizations l) {
    String norm(String x) => Platform.isWindows ? p.normalize(x).toLowerCase() : p.normalize(x);
    final out = <GameFolder>[];
    void push(GameFolder f) {
      if (!out.any((x) => norm(x.path) == norm(f.path))) out.add(f);
    }

    bool hasVersions(String dir) => Directory(p.join(dir, 'versions')).existsSync();
    for (final f in cfg.gameFolders) {
      if (Directory(f.path).existsSync()) push(f);
    }
    final exeDir = Paths.launcherDir;
    if (hasVersions(exeDir)) push(GameFolder(name: l.versionsCurrentFolder, path: exeDir, custom: false));
    try {
      for (final d in Directory(exeDir).listSync().whereType<Directory>()) {
        final name = p.basename(d.path);
        if (name == '.minecraft' || hasVersions(d.path)) push(GameFolder(name: name, path: d.path, custom: false));
      }
    } catch (_) {
      // 没有权限扫描启动器目录
    }
    if (hasVersions(Paths.officialMinecraftDir)) {
      push(GameFolder(name: l.versionsOfficialLauncherFolder, path: Paths.officialMinecraftDir, custom: false));
    }
    // 手机存储中的文件夹在重装应用后仍然存在
    if (Platform.isAndroid && hasVersions(AndroidStorage.gameDir)) {
      push(GameFolder(name: l.oobePhoneStorage, path: AndroidStorage.gameDir, custom: false));
    }
    push(GameFolder(name: l.versionsLauncherDefaultFolder, path: p.join(Paths.appData, '.minecraft'), custom: false));
    // 当前目录即使不在列表中也要显示
    push(GameFolder(name: p.basename(cfg.gameDir), path: cfg.gameDir, custom: true));
    return out;
  }

  @override
  State<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends State<VersionsPage> {
  final _search = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    versionsSearchRequest.addListener(_onSearchRequest);
    _onSearchRequest();
  }

  @override
  void dispose() {
    versionsSearchRequest.removeListener(_onSearchRequest);
    _search.dispose();
    super.dispose();
  }

  void _onSearchRequest() {
    if (!versionsSearchRequest.value) return;
    versionsSearchRequest.value = false;
    _search.requestFocus();
  }

  /// 按名称、加载器和游戏版本搜索，空格分隔的每个词都要匹配
  bool _matches(InstanceInfo v) {
    final text = '${v.id} ${describeVersion(v)}'.toLowerCase();
    return _query.toLowerCase().split(' ').every(text.contains);
  }

  Future<void> _addFolder(BuildContext context) async {
    final state = AppScope.read(context);
    final dir = await pickFolder(context, confirm: context.l10n.oobeAdd);
    if (dir == null) return;
    final list = state.config.gameFolders.where((f) => p.normalize(f.path) != p.normalize(dir)).toList()
      ..add(GameFolder(name: p.basename(dir), path: dir, custom: true));
    await state.config.update({
      'gameFolders': [for (final f in list) f.toJson()],
    });
    await state.selectFolder(dir);
  }

  Future<void> _removeFolder(BuildContext context, GameFolder f) async {
    final state = AppScope.read(context);
    final list = state.config.gameFolders.where((x) => p.normalize(x.path) != p.normalize(f.path));
    await state.config.update({
      'gameFolders': [for (final x in list) x.toJson()],
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final list = VersionsPage.folders(state.config, context.l10n);
    final shown = state.versions.where(_matches).toList();
    final current = p.normalize(state.config.gameDir);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 260,
          child: _FolderColumn(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    context.l10n.oobeGameFolder,
                    style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                for (final f in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: p.normalize(f.path) == current ? scheme.secondaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(f.name, overflow: TextOverflow.ellipsis),
                        subtitle: Text(f.path, overflow: TextOverflow.ellipsis, maxLines: 1),
                        onTap: () => state.selectFolder(f.path),
                        trailing: f.custom && state.config.gameFolders.any((x) => x.path == f.path)
                            ? IconButton(
                                tooltip: context.l10n.versionsRemoveFromListFiles,
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _removeFolder(context, f),
                              )
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addFolder(context),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(context.l10n.versionsAddFolder),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ContentPanel(
            child: state.loadingVersions
                ? const Center(child: CircularProgressIndicator())
                : state.versions.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.versionsNoInstancesFolderYet,
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 标题和搜索框固定在上面，只滚动下面的实例
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.versionsOtherInstances(state.versions.length),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    downloadTabRequest.value = 'versions';
                                    ShellNav.of(context).goMain(MainPage.download);
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(context.l10n.versionsNewInstance),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: context.l10n.fileViewerRefresh,
                                  onPressed: state.refreshVersions,
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SearchField(
                              hint: context.l10n.versionsSearchInstances,
                              focusNode: _search,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: shown.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.versionsNoMatchingInstances,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                children: [
                                  for (final v in shown)
                                    Card.filled(
                                      color: v.id == state.config.selectedVersion
                                          ? scheme.secondaryContainer
                                          : scheme.surfaceContainerLow,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: versionIcon(v, color: scheme.primary),
                                        title: Text(v.id),
                                        // 同一个游戏版本可以装多个实例，带上模组数方便区分
                                        subtitle: FutureBuilder<int?>(
                                          future: v.loader == Loader.vanilla
                                              ? Future.value(null)
                                              : instanceModCount(state, v),
                                          builder: (context, snap) => Text(
                                            [
                                              describeVersion(v),
                                              if (snap.data != null) context.l10n.commonModCount(snap.data ?? 0),
                                            ].join(' · '),
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (v.id == state.config.selectedVersion) const Icon(Icons.check),
                                            IconButton(
                                              tooltip: context.l10n.tourInstanceSettings,
                                              icon: const Icon(Icons.settings_outlined),
                                              onPressed: () {
                                                state.instanceId = v.id;
                                                instanceSectionRequest.value = 'setup';
                                                ShellNav.of(context).open(SubPage.instance);
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          await state.selectVersion(v.id);
                                          if (context.mounted) ShellNav.of(context).back();
                                        },
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// 左边的游戏文件夹列表：启用背景图片时放在一块毛玻璃上（和设置页的二级菜单一样）
class _FolderColumn extends StatelessWidget {
  const _FolderColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (BackgroundScope.activeOf(context) == null) return child;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 16),
      child: GlassPanel(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }
}
