import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../core/config.dart';
import '../core/paths.dart';
import '../shell.dart';
import '../widgets/loader_label.dart';
import '../widgets/side_nav.dart';

/// 版本选择：左侧游戏文件夹，右侧该文件夹中的版本（PCL 的布局）
class VersionsPage extends StatelessWidget {
  const VersionsPage({super.key});

  /// 与 PCL-CE 的 McFolderListLoadSub 一致的自动发现规则，加上用户添加的文件夹
  static List<GameFolder> folders(LauncherConfig cfg) {
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
    if (hasVersions(exeDir)) push(GameFolder(name: '当前文件夹', path: exeDir, custom: false));
    try {
      for (final d in Directory(exeDir).listSync().whereType<Directory>()) {
        final name = p.basename(d.path);
        if (name == '.minecraft' || hasVersions(d.path)) push(GameFolder(name: name, path: d.path, custom: false));
      }
    } catch (_) {
      // 没有权限扫描启动器目录
    }
    if (hasVersions(Paths.officialMinecraftDir)) {
      push(GameFolder(name: '官方启动器文件夹', path: Paths.officialMinecraftDir, custom: false));
    }
    push(GameFolder(name: '启动器默认文件夹', path: p.join(Paths.appData, '.minecraft'), custom: false));
    // 当前目录即使不在列表中也要显示
    push(GameFolder(name: p.basename(cfg.gameDir), path: cfg.gameDir, custom: true));
    return out;
  }

  Future<void> _addFolder(BuildContext context) async {
    final state = AppScope.read(context);
    final dir = await getDirectoryPath(confirmButtonText: '添加');
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
    final list = folders(state.config);
    final current = p.normalize(state.config.gameDir);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 260,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('游戏文件夹', style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
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
                              tooltip: '从列表移除（不会删除文件）',
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
                label: const Text('添加文件夹'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ContentPanel(
            child: state.loadingVersions
                ? const Center(child: CircularProgressIndicator())
                : state.versions.isEmpty
                ? Center(
                    child: Text(
                      '这个文件夹中还没有版本',
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('${state.versions.length} 个版本', style: theme.textTheme.titleSmall)),
                          IconButton(tooltip: '刷新', onPressed: state.refreshVersions, icon: const Icon(Icons.refresh)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final v in state.versions)
                        Card.filled(
                          color: v.id == state.config.selectedVersion
                              ? scheme.secondaryContainer
                              : scheme.surfaceContainerLow,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Icon(versionIcon(v), color: scheme.primary),
                            title: Text(v.id),
                            subtitle: Text(describeVersion(v)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (v.id == state.config.selectedVersion) const Icon(Icons.check),
                                IconButton(
                                  tooltip: '版本设置',
                                  icon: const Icon(Icons.settings_outlined),
                                  onPressed: () {
                                    state.instanceId = v.id;
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
        ),
      ],
    );
  }
}
