import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/download.dart' show Downloader;
import '../core/install.dart';
import '../core/instance.dart';
import '../core/loaders.dart';
import '../core/modrinth.dart';
import '../core/task.dart';
import '../widgets/loader_icon.dart';
import '../widgets/app_background.dart';
import '../core/optifine_compat.dart';
import '../widgets/shell_layout.dart';
import '../widgets/side_nav.dart';
import 'resources.dart';
import '../l10n/l10n.dart';
import '../core/i18n/strings.dart';

enum _Tab { versions, mods, modpacks, resourcePacks, shaders, datapacks, favorites }

const _resources = {
  _Tab.mods: ResourceType.mod,
  _Tab.modpacks: ResourceType.modpack,
  _Tab.resourcePacks: ResourceType.resourcepack,
  _Tab.shaders: ResourceType.shader,
  _Tab.datapacks: ResourceType.datapack,
};

/// 其他页面要求下载页切到某个分类（例如首页「装模组」）：'mods'、'versions' 等
final downloadTabRequest = ValueNotifier<String?>(null);

enum _Filter { release, snapshot, old, fool }

/// 下载：顶部分类标签；「游戏版本」左边是版本列表，右边是选中版本的安装面板。
/// 加载器不再单独成页，在安装面板里选择。
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  _Tab _tab = _Tab.versions;
  _Filter _filter = _Filter.release;

  @override
  void initState() {
    super.initState();
    downloadTabRequest.addListener(_onRequest);
    _onRequest();
  }

  @override
  void dispose() {
    downloadTabRequest.removeListener(_onRequest);
    super.dispose();
  }

  void _onRequest() {
    final name = downloadTabRequest.value;
    if (name == null) return;
    final tab = _Tab.values.where((t) => t.name == name).firstOrNull;
    downloadTabRequest.value = null;
    if (tab != null && mounted) setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final resource = _resources[_tab];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageTabs<_Tab>(
            tabs: [
              (_Tab.versions, context.l10n.commonGameVersion),
              (_Tab.mods, context.l10n.homeMods),
              (_Tab.modpacks, context.l10n.downloadModpacks),
              (_Tab.resourcePacks, context.l10n.commonResourcePacks),
              (_Tab.shaders, context.l10n.commonShaders),
              (_Tab.datapacks, context.l10n.downloadDataPacks),
              (_Tab.favorites, context.l10n.commonFavorites),
            ],
            value: _tab,
            onChanged: (t) => setState(() => _tab = t),
            trailing: _tab != _Tab.versions
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SegmentPicker<_Filter>(
                      options: [
                        (_Filter.release, context.l10n.updateChannelStable),
                        (_Filter.snapshot, context.l10n.homeFeedSnapshot),
                        (_Filter.old, context.l10n.downloadOldVersions),
                        (_Filter.fool, context.l10n.downloadAprilFools),
                      ],
                      value: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_tab) {
              _Tab.versions => _VersionsView(filter: _filter),
              _Tab.favorites => const FavoritesList(),
              _ => ResourceBrowser(key: ValueKey(_tab), type: resource!),
            },
          ),
        ],
      ),
    );
  }
}

/// 游戏版本：左边紧凑列表（每行 48 高），右边安装面板
class _VersionsView extends StatefulWidget {
  const _VersionsView({required this.filter});

  final _Filter filter;

  @override
  State<_VersionsView> createState() => _VersionsViewState();
}

class _VersionsViewState extends State<_VersionsView> {
  late Future<({List<RemoteVersion> list, String latestRelease, String latestSnapshot})> _future;
  String _query = '';
  RemoteVersion? _selected;

  @override
  void initState() {
    super.initState();
    _future = remoteVersions(AppScope.read(context).downloader);
  }

  bool _match(RemoteVersion v) => switch (widget.filter) {
    _Filter.release => v.type == 'release',
    _Filter.snapshot => v.type == 'snapshot' && !v.fool,
    _Filter.old => v.type.startsWith('old_'),
    _Filter.fool => v.fool,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final installed = {for (final v in AppScope.of(context).versions) v.gameVersion};
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.downloadCouldntGetVersionList(errorText(snap.error!))),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => setState(() => _future = remoteVersions(AppScope.read(context).downloader)),
                  child: Text(context.l10n.deviceLoginDialogRetry),
                ),
              ],
            ),
          );
        }
        if (!snap.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                Text(context.l10n.downloadLoadingVersionList, style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          );
        }
        final data = snap.data!;
        final q = _query.trim().toLowerCase();
        final list = data.list.where(_match).where((v) => q.isEmpty || v.id.toLowerCase().contains(q)).toList();
        final selected = list.contains(_selected) ? _selected : list.firstOrNull;
        return AlignedSplit(
          left: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchField(hint: context.l10n.downloadSearchVersions, onChanged: (v) => setState(() => _query = v)),
              const SizedBox(height: 6),
              Expanded(
                child: GlassPanel(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            context.l10n.downloadNoMatchingVersions,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: .3)),
                          itemBuilder: (context, i) {
                            final v = list[i];
                            final on = v == selected;
                            final latest = v.id == data.latestRelease || v.id == data.latestSnapshot;
                            return Material(
                              color: on ? glassCardColor(context, scheme.surfaceContainerHigh) : Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _selected = v),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: on ? scheme.primary : Colors.transparent, width: 3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        v.id,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 8),
                                      if (latest) _Tag(context.l10n.downloadLatest, filled: true),
                                      if (installed.contains(v.id)) ...[
                                        const SizedBox(width: 6),
                                        _Tag(context.l10n.downloadInstalled),
                                      ],
                                      const Spacer(),
                                      Text(
                                        v.releaseTime.split('T').first,
                                        style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          right: GlassPanel(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            child: selected == null
                ? Center(
                    child: Text(
                      context.l10n.downloadChooseVersionLeft,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : InstallPanel(key: ValueKey(selected.id), version: selected),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.filled = false});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: filled ? scheme.primaryContainer : Colors.transparent,
        border: filled ? null : Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: filled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// 安装 Minecraft 为一个新实例：选择加载器（不兼容的灰掉并写明原因）、加载器版本、OptiFine 和实例名称
class InstallPanel extends StatefulWidget {
  const InstallPanel({super.key, required this.version, this.preset});

  final RemoteVersion version;
  final LoaderKind? preset;

  @override
  State<InstallPanel> createState() => _InstallPanelState();
}

class _InstallPanelState extends State<InstallPanel> {
  static Map<LoaderKind?, String> _descriptions(AppLocalizations l) => {
    null: l.downloadPlainMinecraft,
    LoaderKind.forge: l.downloadOldestLoaderMostMods,
    LoaderKind.neoforge: l.downloadCommunityForkForgeAvailable,
    LoaderKind.cleanroom: l.downloadModernized1122,
    LoaderKind.labymod: l.downloadAllOneClientLots,
    LoaderKind.fabric: l.downloadLightweightFastUpdatingMod,
    LoaderKind.quilt: l.downloadCompatibleMostFabricMods,
    LoaderKind.legacyfabric: l.downloadFabricPorted113,
    LoaderKind.liteloader: l.downloadLightweightLoader112,
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

  /// 各加载器分别加载，先返回的先显示（LiteLoader 的官方服务器较慢）。
  /// 获取到的列表在这次运行中记住，再次选中同一个游戏版本时直接显示
  void _load() {
    final dl = AppScope.read(context).downloader;
    for (final k in LoaderKind.values) {
      final key = '${k.name}/${widget.version.id}';
      final cached = _loaderCache[key];
      if (cached != null) {
        _lists[k] = cached;
        if (_choice == k) {
          if (cached.isEmpty) _choice = null;
          _pickDefault();
        }
        if (k == LoaderKind.optifine) _pickOptiFine();
        continue;
      }
      _fetch(dl, k, key);
    }
  }

  /// 获取一个加载器的版本列表；连不上时记为「获取失败」，点一下可以重试
  void _fetch(Downloader dl, LoaderKind k, String key) {
    fetchLoaderVersions(
      dl,
      k,
      widget.version.id,
    ).then((list) => (list, false)).catchError((_) => (const <LoaderVersion>[], true)).then((r) {
      final (list, failed) = r;
      if (!failed) _loaderCache[key] = list;
      if (!mounted) return;
      setState(() {
        if (failed) {
          _failed.add(k);
        } else {
          _failed.remove(k);
        }
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

  /// 重新获取「获取失败」的加载器
  void _retry(LoaderKind k) {
    setState(() {
      _lists.remove(k);
      _failed.remove(k);
    });
    _fetch(AppScope.read(context).downloader, k, '${k.name}/${widget.version.id}');
  }

  /// 获取失败（连不上服务器）的加载器
  final _failed = <LoaderKind>{};

  static final _loaderCache = <String, List<LoaderVersion>>{};

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
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.downloadInstallationStartedSeeBackground),
        behavior: SnackBarBehavior.floating,
        width: 420,
      ),
    );
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
            SnackBar(content: Text(tr.downloadInstalled2(id)), behavior: SnackBarBehavior.floating, width: 420),
          ),
        )
        .catchError((Object e) {
          final cancelled = e is TaskCancelled;
          return messenger.showSnackBar(
            SnackBar(
              content: Text(cancelled ? tr.commonTaskCanceled : tr.commonInstallationFailed(errorText(e))),
              behavior: SnackBarBehavior.floating,
              width: 420,
            ),
          );
        });
  }

  String get _defaultName => _choice == null && _optifine && _canOptiFine
      ? defaultVersionName(LoaderKind.optifine, widget.version.id, _optifineVersion)
      : defaultVersionName(_choice, widget.version.id, _loaderVersion);

  /// 加载器选项格子下面的一行小字：加载中 / 不支持 / 默认版本或说明
  String _hint(LoaderKind? k) {
    if (_loading(k)) return context.l10n.homeLoading;
    if (_failed.contains(k)) return context.l10n.downloadLoadFailedRetry;
    if (!_available(k)) return context.l10n.downloadIsntSupported(widget.version.id);
    if (k == null) return context.l10n.downloadNone;
    final list = _lists[k] ?? const <LoaderVersion>[];
    final def = (list.where((l) => l.stable).firstOrNull ?? list.firstOrNull)?.label;
    return def ?? _descriptions(context.l10n)[k]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = _choice == null ? const <LoaderVersion>[] : (_lists[_choice] ?? const <LoaderVersion>[]);
    final ofList = _optifineList;
    final ofSelected = ofList.where((v) => v.version == _optifineVersion).firstOrNull;
    final ofLoading = _loading(LoaderKind.optifine);
    final canInstall = !(_loading(_choice) || (_choice != null && _loaderVersion.isEmpty));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    context.l10n.downloadInstall(widget.version.id),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.version.releaseTime.split('T').first,
                    style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (_lists.length < LoaderKind.values.length)
                    Text(
                      context.l10n.downloadLoadingLoaders(_lists.length, LoaderKind.values.length),
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
              // 网络慢时各加载器的版本号要一会才出来：顶部一条进度，全部获取完就收起
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _lists.length < LoaderKind.values.length
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(
                          value: _lists.isEmpty ? null : _lists.length / LoaderKind.values.length,
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: context.l10n.downloadInstanceName,
                    hintText: _defaultName,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              // 同一个游戏版本可以装多个实例：已经装过时说明这次是再装一个独立的
              Builder(
                builder: (context) {
                  final same = AppScope.of(context).versions.where((v) => v.gameVersion == widget.version.id).length;
                  if (same == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      context.l10n.downloadInstancesAlreadyInstalledInstalls(same, widget.version.id),
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 420 ? 3 : 2;
                  final w = (c.maxWidth - 6 * (cols - 1)) / cols;
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final k in _mainOptions)
                        SizedBox(
                          width: w,
                          child: _LoaderTile(
                            loader: loaderOfKind(k),
                            label: k?.label ?? context.l10n.downloadVanilla,
                            hint: _hint(k),
                            selected: _choice == k,
                            loading: _loading(k),
                            enabled: !_loading(k) && (_available(k) || _failed.contains(k)),
                            onTap: () {
                              if (k != null && _failed.contains(k)) return _retry(k);
                              setState(() {
                                _choice = k;
                                _pickDefault();
                              });
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_choice != null && current.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownMenu<String>(
                  // 选择 OptiFine 后 Forge 版本可能被自动切换，需要重建下拉框
                  key: ValueKey('$_choice-$_loaderVersion'),
                  expandedInsets: EdgeInsets.zero,
                  label: Text(context.l10n.downloadVersion(_choice!.label)),
                  initialSelection: _loaderVersion,
                  menuHeight: 300,
                  dropdownMenuEntries: [
                    for (final l in current.take(40))
                      DropdownMenuEntry(
                        value: l.version,
                        label: l.stable ? l.label : context.l10n.downloadBeta(l.label),
                      ),
                  ],
                  onSelected: (v) => setState(() => _loaderVersion = v ?? _loaderVersion),
                ),
              ],
              const SizedBox(height: 8),
              // OptiFine 附加项：整行可点
              Material(
                color: _optifine && _canOptiFine
                    ? scheme.secondaryContainer
                    : glassCardColor(context, scheme.surfaceContainer),
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  dense: true,
                  secondary: const LoaderIcon(Loader.optifine),
                  title: Text(context.l10n.downloadInstallOptiFineToo),
                  subtitle: Text(
                    ofLoading
                        ? context.l10n.downloadLoadingOptiFineVersions
                        : !canAddOptiFine(loaderOfKind(_choice))
                        ? context.l10n.downloadCantInstalledTogetherOptiFine(_choice?.label ?? '')
                        : ofList.isEmpty
                        ? (_choice == LoaderKind.forge
                              ? context.l10n.downloadNoOptiFineCompatibleForge
                              : context.l10n.downloadNoOptiFineVersion)
                        : [
                            optiFineNote(loaderOfKind(_choice), ofSelected),
                            if (_forgeMismatch(ofSelected)) context.l10n.downloadSelectedForgeDiffersFrom,
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
                  label: Text(context.l10n.commonOptiFineVersion),
                  initialSelection: _optifineVersion,
                  menuHeight: 300,
                  dropdownMenuEntries: [
                    for (final l in ofList.take(40))
                      DropdownMenuEntry(
                        value: l.version,
                        label:
                            '${l.label}${l.stable ? '' : context.l10n.commonPreview}'
                            '${_choice == LoaderKind.forge && (l.requiredForge?.isNotEmpty ?? false) ? context.l10n.commonRequiresForge(l.requiredForge ?? '') : ''}',
                      ),
                  ],
                  onSelected: (v) => setState(() {
                    _optifineVersion = v ?? _optifineVersion;
                    _matchForge();
                  }),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.downloadInstallAs(_name.text.trim().isEmpty ? _defaultName : _name.text.trim()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: canInstall ? _install : null,
                style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
                child: Text(context.l10n.commonInstall),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 加载器选项：至少 52 高，整格可点；不可用的灰掉并写明原因
class _LoaderTile extends StatelessWidget {
  const _LoaderTile({
    required this.loader,
    required this.label,
    required this.hint,
    required this.selected,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final Loader loader;
  final String label;
  final String hint;
  final bool selected;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Opacity(
      opacity: enabled || loading ? 1 : .45,
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: .35)
            : glassCardColor(context, scheme.surfaceContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  LoaderIcon(loader, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (loading) const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
