import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/install.dart';
import '../core/instance.dart';
import '../core/loaders.dart';
import '../core/modrinth.dart';
import '../widgets/loader_icon.dart';
import '../core/optifine_compat.dart';
import '../widgets/side_nav.dart';
import 'resources.dart';

enum _Section {
  minecraft,
  forge,
  neoforge,
  cleanroom,
  optifine,
  labymod,
  fabric,
  quilt,
  legacyfabric,
  liteloader,
  mods,
  modpacks,
  resourcePacks,
  shaders,
  datapacks,
  favorites,
}

const _resources = {
  _Section.mods: ResourceType.mod,
  _Section.modpacks: ResourceType.modpack,
  _Section.resourcePacks: ResourceType.resourcepack,
  _Section.shaders: ResourceType.shader,
  _Section.datapacks: ResourceType.datapack,
};

const _presets = {
  _Section.forge: LoaderKind.forge,
  _Section.neoforge: LoaderKind.neoforge,
  _Section.cleanroom: LoaderKind.cleanroom,
  _Section.optifine: LoaderKind.optifine,
  _Section.labymod: LoaderKind.labymod,
  _Section.fabric: LoaderKind.fabric,
  _Section.quilt: LoaderKind.quilt,
  _Section.legacyfabric: LoaderKind.legacyfabric,
  _Section.liteloader: LoaderKind.liteloader,
};

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  _Section _section = _Section.minecraft;

  static const _groups = [
    SideNavGroup(null, [
      SideNavItem(_Section.minecraft, 'Minecraft', Icons.view_in_ar_outlined, loader: Loader.vanilla),
    ]),
    SideNavGroup('加载器', [
      SideNavItem(_Section.forge, 'Forge', Icons.extension_outlined, loader: Loader.forge),
      SideNavItem(_Section.neoforge, 'NeoForge', Icons.extension_outlined, loader: Loader.neoforge),
      SideNavItem(_Section.cleanroom, 'Cleanroom', Icons.extension_outlined, loader: Loader.cleanroom),
      SideNavItem(_Section.optifine, 'OptiFine', Icons.extension_outlined, loader: Loader.optifine),
      SideNavItem(_Section.labymod, 'LabyMod', Icons.extension_outlined, loader: Loader.labymod),
      SideNavItem(_Section.fabric, 'Fabric', Icons.extension_outlined, loader: Loader.fabric),
      SideNavItem(_Section.quilt, 'Quilt', Icons.grid_view_outlined, loader: Loader.quilt),
      SideNavItem(_Section.legacyfabric, 'Legacy Fabric', Icons.history_outlined, loader: Loader.legacyfabric),
      SideNavItem(_Section.liteloader, 'LiteLoader', Icons.light_mode_outlined, loader: Loader.liteloader),
    ]),
    SideNavGroup('社区资源', [
      SideNavItem(_Section.mods, '模组', Icons.extension_outlined),
      SideNavItem(_Section.modpacks, '整合包', Icons.inventory_2_outlined),
      SideNavItem(_Section.resourcePacks, '资源包', Icons.layers_outlined),
      SideNavItem(_Section.shaders, '光影包', Icons.wb_sunny_outlined),
      SideNavItem(_Section.datapacks, '数据包', Icons.data_object),
    ]),
    SideNavGroup(null, [SideNavItem(_Section.favorites, '收藏夹', Icons.favorite_border)]),
  ];

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_section];
    final resource = _resources[_section];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav(groups: _groups, value: _section, onChanged: (s) => setState(() => _section = s)),
        Expanded(
          child: ContentPanel(
            child: switch (_section) {
              _Section.favorites => const FavoritesList(),
              _ when resource != null => ResourceBrowser(key: ValueKey(_section), type: resource),
              _ => _MinecraftList(key: ValueKey(_section), preset: preset),
            },
          ),
        ),
      ],
    );
  }
}

enum _Filter { release, snapshot, old, fool }

/// Minecraft 版本列表。从加载器入口进入时只显示正式版，点击后预选该加载器
class _MinecraftList extends StatefulWidget {
  const _MinecraftList({super.key, this.preset});

  final LoaderKind? preset;

  @override
  State<_MinecraftList> createState() => _MinecraftListState();
}

class _MinecraftListState extends State<_MinecraftList> {
  late Future<({List<RemoteVersion> list, String latestRelease, String latestSnapshot})> _future;
  _Filter _filter = _Filter.release;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = remoteVersions(AppScope.read(context).downloader);
  }

  bool _match(RemoteVersion v) => switch (_filter) {
    _Filter.release => v.type == 'release',
    _Filter.snapshot => v.type == 'snapshot' && !v.fool,
    _Filter.old => v.type.startsWith('old_'),
    _Filter.fool => v.fool,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('获取版本列表失败：${errorText(snap.error!)}'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => setState(() => _future = remoteVersions(AppScope.read(context).downloader)),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final data = snap.data!;
        final q = _query.trim().toLowerCase();
        final list = data.list
            .where((v) => widget.preset != null ? v.type == 'release' : _match(v))
            .where((v) => q.isEmpty || v.id.toLowerCase().contains(q))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.preset == null ? 'Minecraft' : '安装 ${widget.preset!.label}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: '搜索版本',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.preset == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final (f, label) in const [
                      (_Filter.release, '正式版'),
                      (_Filter.snapshot, '快照'),
                      (_Filter.old, '远古版'),
                      (_Filter.fool, '愚人节'),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  '选择要安装 ${widget.preset!.label} 的 Minecraft 版本',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final v = list[i];
                  final latest = v.id == data.latestRelease || v.id == data.latestSnapshot;
                  return Card.filled(
                    color: scheme.surfaceContainerLow,
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: Icon(
                        v.type == 'release' ? Icons.view_in_ar_outlined : Icons.science_outlined,
                        color: scheme.primary,
                      ),
                      title: Row(
                        children: [
                          Text(v.id),
                          if (latest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '最新',
                                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text('发布于 ${v.releaseTime.split('T').first}'),
                      trailing: const Icon(Icons.download_outlined),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => InstallDialog(version: v, preset: widget.preset),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 安装 Minecraft：可选择加载器和版本名称
class InstallDialog extends StatefulWidget {
  const InstallDialog({super.key, required this.version, this.preset});

  final RemoteVersion version;
  final LoaderKind? preset;

  @override
  State<InstallDialog> createState() => _InstallDialogState();
}

class _InstallDialogState extends State<InstallDialog> {
  static const _descriptions = {
    null: '纯净的 Minecraft',
    LoaderKind.forge: '历史最久、模组最多的加载器',
    LoaderKind.neoforge: '从 Forge 分出的社区版，1.20.1 起可用',
    LoaderKind.cleanroom: '基于 Forge 的 1.12.2 现代化分支，需要 Java 21',
    LoaderKind.labymod: '自带大量功能的整合客户端（LabyMod 4）',
    LoaderKind.fabric: '轻量、更新快的模组加载器',
    LoaderKind.quilt: '兼容大部分 Fabric 模组',
    LoaderKind.legacyfabric: '为 1.13.2 及更早版本移植的 Fabric',
    LoaderKind.liteloader: '1.12.2 及更早版本的轻量加载器',
  };

  /// 主加载器；null 为原版。OptiFine 不在其中，作为附加项单独勾选
  LoaderKind? _choice;

  /// 各加载器的可用版本；还在加载的加载器不在其中
  final _lists = <LoaderKind, List<LoaderVersion>>{};
  String _loaderVersion = '';
  bool _optifine = false;
  String _optifineVersion = '';
  final _name = TextEditingController();

  static final _mainOptions = <LoaderKind?>[null, ...LoaderKind.values.where((k) => k != LoaderKind.optifine)];

  @override
  void initState() {
    super.initState();
    // 从 OptiFine 入口进入时：原版 + OptiFine
    if (widget.preset == LoaderKind.optifine) {
      _optifine = true;
    } else {
      _choice = widget.preset;
    }
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 各加载器分别加载，先返回的先显示（LiteLoader 的官方服务器较慢）
  void _load() {
    final dl = AppScope.read(context).downloader;
    for (final k in LoaderKind.values) {
      loaderVersions(dl, k, widget.version.id).then((list) {
        if (!mounted) return;
        setState(() {
          _lists[k] = list;
          if (_choice == k) {
            // 预选的加载器不支持这个版本时，回到原版
            if (list.isEmpty) _choice = null;
            _pickDefault();
          }
          if (k == LoaderKind.optifine) _pickOptiFine();
        });
      });
    }
  }

  bool _loading(LoaderKind? k) => k != null && !_lists.containsKey(k);

  bool _available(LoaderKind? k) => k == null || (_lists[k]?.isNotEmpty ?? false);

  void _pickDefault() {
    final list = _choice == null ? const <LoaderVersion>[] : (_lists[_choice] ?? const <LoaderVersion>[]);
    _loaderVersion = (list.where((l) => l.stable).firstOrNull ?? list.firstOrNull)?.version ?? '';
    _pickOptiFine();
  }

  /// 可与当前主加载器搭配的 OptiFine 版本
  List<LoaderVersion> get _optifineList =>
      optiFineFor(loaderOfKind(_choice), _lists[LoaderKind.optifine] ?? const <LoaderVersion>[]);

  bool get _canOptiFine => canAddOptiFine(loaderOfKind(_choice)) && _optifineList.isNotEmpty;

  void _pickOptiFine() {
    final list = _optifineList;
    if (list.any((v) => v.version == _optifineVersion)) return;
    _optifineVersion = (list.where((l) => l.stable).firstOrNull ?? list.firstOrNull)?.version ?? '';
  }

  /// 选择 OptiFine 时，把 Forge 切换到 OptiFine 要求的版本（较新的 Forge 可能与 OptiFine 不兼容）
  void _matchForge() {
    if (_choice != LoaderKind.forge || !_optifine) return;
    final req = _optifineList.where((v) => v.version == _optifineVersion).firstOrNull?.requiredForge;
    if (req == null || req.isEmpty) return;
    final wanted = '${widget.version.id}-$req';
    if ((_lists[LoaderKind.forge] ?? const <LoaderVersion>[]).any((v) => v.version == wanted)) {
      _loaderVersion = wanted;
    }
  }

  bool _forgeMismatch(LoaderVersion? of) {
    final req = of?.requiredForge;
    if (_choice != LoaderKind.forge || !_optifine || req == null || req.isEmpty) return false;
    return _loaderVersion != '${widget.version.id}-$req';
  }

  void _install() {
    final state = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    final withOptiFine = _optifine && _canOptiFine && _optifineVersion.isNotEmpty;
    Navigator.pop(context);
    // 只选 OptiFine 时安装为独立版本；有主加载器时 OptiFine 作为模组
    final future = _choice == null && withOptiFine
        ? state.installVersion(
            widget.version.id,
            loader: LoaderKind.optifine,
            loaderVersion: _optifineVersion,
            name: name.isEmpty ? null : name,
          )
        : state.installVersion(
            widget.version.id,
            loader: _choice,
            loaderVersion: _loaderVersion,
            name: name.isEmpty ? null : name,
            optifine: withOptiFine ? _optifineVersion : null,
          );
    future
        .then(
          (id) => messenger.showSnackBar(
            SnackBar(content: Text('$id 安装完成'), behavior: SnackBarBehavior.floating, width: 420),
          ),
        )
        .catchError(
          (Object e) => messenger.showSnackBar(
            SnackBar(content: Text('安装失败：${errorText(e)}'), behavior: SnackBarBehavior.floating, width: 420),
          ),
        );
  }

  String get _defaultName => _choice == null && _optifine && _canOptiFine
      ? defaultVersionName(LoaderKind.optifine, widget.version.id, _optifineVersion)
      : defaultVersionName(_choice, widget.version.id, _loaderVersion);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = _choice == null ? const <LoaderVersion>[] : (_lists[_choice] ?? const <LoaderVersion>[]);
    final ofList = _optifineList;
    final ofSelected = ofList.where((v) => v.version == _optifineVersion).firstOrNull;
    final ofLoading = _loading(LoaderKind.optifine);
    return AlertDialog(
      title: Text('安装 Minecraft ${widget.version.id}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final k in _mainOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: _choice == k ? scheme.secondaryContainer : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      dense: true,
                      enabled: _loading(k) || _available(k),
                      leading: LoaderIcon(loaderOfKind(k)),
                      title: Text(k?.label ?? '原版'),
                      subtitle: Text(!_loading(k) && !_available(k) ? '该版本不可用' : _descriptions[k]!),
                      trailing: _loading(k)
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : (_choice == k ? Icon(Icons.check_circle, color: scheme.primary) : null),
                      onTap: !_loading(k) && _available(k)
                          ? () => setState(() {
                              _choice = k;
                              _pickDefault();
                            })
                          : null,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (_choice != null && current.isNotEmpty) ...[
                DropdownMenu<String>(
                  // 选择 OptiFine 后 Forge 版本可能被自动切换，需要重建下拉框
                  key: ValueKey('$_choice-$_loaderVersion'),
                  expandedInsets: EdgeInsets.zero,
                  label: Text('${_choice!.label} 版本'),
                  initialSelection: _loaderVersion,
                  menuHeight: 300,
                  dropdownMenuEntries: [
                    for (final l in current.take(40))
                      DropdownMenuEntry(value: l.version, label: l.stable ? l.label : '${l.label}（测试版）'),
                  ],
                  onSelected: (v) => setState(() => _loaderVersion = v ?? _loaderVersion),
                ),
                const SizedBox(height: 10),
              ],
              // OptiFine 附加项
              Material(
                color: _optifine && _canOptiFine ? scheme.secondaryContainer : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  dense: true,
                  secondary: const LoaderIcon(Loader.optifine),
                  title: const Text('同时安装 OptiFine'),
                  subtitle: Text(
                    ofLoading
                        ? '正在获取 OptiFine 版本…'
                        : !canAddOptiFine(loaderOfKind(_choice))
                        ? '${_choice?.label} 不支持与 OptiFine 一起安装'
                        : ofList.isEmpty
                        ? (_choice == LoaderKind.forge ? '没有与 Forge 兼容的 OptiFine' : '该版本没有 OptiFine')
                        : [
                            optiFineNote(loaderOfKind(_choice), ofSelected),
                            if (_forgeMismatch(ofSelected)) '当前选择的 Forge 与 OptiFine 要求的版本不同，较新的 Forge 可能与它不兼容',
                          ].join('\n'),
                  ),
                  value: _optifine && _canOptiFine,
                  onChanged: _canOptiFine
                      ? (v) => setState(() {
                          _optifine = v ?? false;
                          _matchForge();
                        })
                      : null,
                ),
              ),
              if (_optifine && _canOptiFine) ...[
                const SizedBox(height: 10),
                DropdownMenu<String>(
                  key: ValueKey('optifine-$_choice'),
                  expandedInsets: EdgeInsets.zero,
                  label: const Text('OptiFine 版本'),
                  initialSelection: _optifineVersion,
                  menuHeight: 300,
                  dropdownMenuEntries: [
                    for (final l in ofList.take(40))
                      DropdownMenuEntry(
                        value: l.version,
                        label:
                            '${l.label}${l.stable ? '' : '（预览版）'}'
                            '${_choice == LoaderKind.forge && (l.requiredForge?.isNotEmpty ?? false) ? ' · 需要 Forge ${l.requiredForge}' : ''}',
                      ),
                  ],
                  onSelected: (v) => setState(() {
                    _optifineVersion = v ?? _optifineVersion;
                    _matchForge();
                  }),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: '版本名称（可选）',
                  hintText: _defaultName,
                  helperText: '留空则使用默认名称',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: _loading(_choice) || (_choice != null && _loaderVersion.isEmpty) ? null : _install,
          child: const Text('开始安装'),
        ),
      ],
    );
  }
}
