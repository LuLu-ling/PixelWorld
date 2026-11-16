import 'file_manager_page.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../app_state.dart' show AppState;
import '../core/instance.dart';
import '../core/instance_files.dart';
import '../core/modrinth.dart';
import '../core/task.dart';
import '../widgets/format.dart';
import '../widgets/app_background.dart';
import '../l10n/l10n.dart';

/// 社区资源（Modrinth）：搜索列表，点击进入详情
class ResourceBrowser extends StatefulWidget {
  const ResourceBrowser({super.key, required this.type, this.target, this.onUnlock});

  final ResourceType type;

  /// 从实例详情「添加」进来时锁定的实例：只显示适配它的资源，安装时直接装进它
  final String? target;

  /// 锁定时「改为普通浏览」
  final VoidCallback? onUnlock;

  @override
  State<ResourceBrowser> createState() => _ResourceBrowserState();
}

class _ResourceBrowserState extends State<ResourceBrowser> {
  final _query = TextEditingController();
  String _sort = 'relevance';

  /// 只显示适配当前版本的资源
  bool _fitCurrent = true;
  final _hits = <ResourceHit>[];
  int _total = 0;
  bool _loading = false;
  String? _error;
  ResourceHit? _open;
  int _generation = 0;
  bool _installingPack = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// 适配哪个实例：锁定的实例，否则是当前实例
  InstanceInfo? _fitTarget(AppState state) =>
      widget.target != null ? state.instance(widget.target!) : state.selectedVersion;

  Future<void> _search({bool more = false}) async {
    final state = AppScope.read(context);
    final current = _fitTarget(state);
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) _hits.clear();
    });
    try {
      final loaders = current == null ? const <String>[] : modrinthLoaders(current.loader);
      final fit = (_fitCurrent || widget.target != null) && current != null && widget.type != ResourceType.modpack;
      final r = await Modrinth.search(
        type: widget.type,
        query: _query.text.trim(),
        sort: _sort,
        offset: more ? _hits.length : 0,
        gameVersion: fit ? current.gameVersion : null,
        loader: fit && widget.type == ResourceType.mod ? loaders.firstOrNull : null,
      );
      if (gen != _generation || !mounted) return;
      setState(() {
        _hits.addAll(r.hits);
        _total = r.total;
      });
    } catch (e) {
      if (gen == _generation && mounted) setState(() => _error = errorText(e));
    } finally {
      if (gen == _generation && mounted) setState(() => _loading = false);
    }
  }

  Future<void> _installFromFile() async {
    final path = await pickFile(context, extensions: const ['mrpack'], label: context.l10n.resourcesModrinthModpacks);
    if (path == null || !mounted) return;
    setState(() => _installingPack = true);
    try {
      final id = await AppScope.read(context).installModpackFile(path);
      if (mounted) toast(context, context.l10n.resourcesInstalledModpackAs(id));
    } catch (e) {
      if (mounted) {
        toast(
          context,
          e is TaskCancelled ? context.l10n.commonTaskCanceled : context.l10n.commonInstallationFailed(errorText(e)),
        );
      }
    } finally {
      if (mounted) setState(() => _installingPack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_open != null) {
      return ResourceDetail(hit: _open!, target: widget.target, onBack: () => setState(() => _open = null));
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = _fitTarget(AppScope.of(context));
    final locked = widget.target != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (locked && current != null) ...[
          tintedPanel(
            context,
            scheme.primaryContainer,
            BorderRadius.circular(12),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              child: Row(
                children: [
                  Icon(Icons.link, size: 18, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l10n.resourcesAddingOnlyCompatibleShown(
                        current.id,
                        widget.type.label,
                        current.gameVersion,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                  if (widget.onUnlock != null)
                    TextButton(onPressed: widget.onUnlock, child: Text(context.l10n.resourcesBrowseNormally)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        // 一行：搜索、适配当前版本、排序、（整合包）从文件安装。分类名已经在顶部标签里
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: GlassField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintText: context.l10n.resourcesSearchModrinth(widget.type.label),
                    isDense: true,
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  child: (decoration) =>
                      TextField(controller: _query, decoration: decoration, onSubmitted: (_) => _search()),
                ),
              ),
              if (!locked && current != null && widget.type != ResourceType.modpack) ...[
                const SizedBox(width: 8),
                GlassPanel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: FilterChip(
                    label: Text(context.l10n.resourcesText(current.id), overflow: TextOverflow.ellipsis),
                    selected: _fitCurrent,
                    onSelected: (v) {
                      _fitCurrent = v;
                      _search();
                    },
                  ),
                ),
              ],
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: context.l10n.resourcesSort,
                initialValue: _sort,
                onSelected: (v) {
                  _sort = v;
                  _search();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'relevance', child: Text(context.l10n.resourcesRelevance)),
                  PopupMenuItem(value: 'downloads', child: Text(context.l10n.resourcesDownloads)),
                  PopupMenuItem(value: 'follows', child: Text(context.l10n.resourcesFollows)),
                  PopupMenuItem(value: 'newest', child: Text(context.l10n.resourcesNewest)),
                  PopupMenuItem(value: 'updated', child: Text(context.l10n.resourcesRecentlyUpdated)),
                ],
                child: GlassPanel(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.resourcesSort2(
                            {
                                  'relevance': context.l10n.resourcesRelevance,
                                  'downloads': context.l10n.resourcesDownloads,
                                  'follows': context.l10n.resourcesFollows,
                                  'newest': context.l10n.resourcesNewest,
                                  'updated': context.l10n.resourcesRecentlyUpdated,
                                }[_sort] ??
                                '',
                          ),
                          style: theme.textTheme.labelLarge,
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.type == ResourceType.modpack) ...[
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: _installingPack ? null : _installFromFile,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  icon: _installingPack
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.resourcesInstallFromFile),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _error != null && _hits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnBackground(
                        builder: (context, fg, _) => Text(_error!, style: TextStyle(color: fg)),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(onPressed: _search, child: Text(context.l10n.deviceLoginDialogRetry)),
                    ],
                  ),
                )
              : _hits.isEmpty && _loading
              ? const Center(child: CircularProgressIndicator())
              : _hits.isEmpty
              ? Center(
                  child: OnBackground(
                    builder: (context, _, muted) => Text(
                      context.l10n.resourcesNoResults,
                      style: TextStyle(color: muted ?? scheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _hits.length + (_hits.length < _total ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _hits.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator()
                              : OutlinedButton(
                                  onPressed: () => _search(more: true),
                                  child: Text(context.l10n.resourcesLoadMore),
                                ),
                        ),
                      );
                    }
                    return ResourceCard(hit: _hits[i], onTap: () => setState(() => _open = _hits[i]));
                  },
                ),
        ),
      ],
    );
  }
}

class ResourceIcon extends StatelessWidget {
  const ResourceIcon({super.key, required this.url, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.extension_outlined, color: scheme.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).round(),
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.hit, required this.onTap});

  final ResourceHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final fav = state.isFavorite(hit.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResourceIcon(url: hit.icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: hit.title, style: theme.textTheme.titleMedium),
                            if (hit.author.isNotEmpty)
                              TextSpan(
                                text: '  by ${hit.author}',
                                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hit.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final c in hit.categories.take(4)) _Tag(c),
                          _Stat(Icons.download_outlined, formatCount(context.l10n, hit.downloads)),
                          if (hit.updated.isNotEmpty) _Stat(Icons.update, timeAgo(context.l10n, hit.updated)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: fav ? context.l10n.resourcesRemoveFromFavorites : context.l10n.commonFavorites,
                  onPressed: () => state.toggleFavorite(hit),
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? scheme.error : null),
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
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style?.color),
        const SizedBox(width: 3),
        Text(text, style: style),
      ],
    );
  }
}

/// 资源详情：选择要安装到的游戏版本，列出兼容的文件
class ResourceDetail extends StatefulWidget {
  const ResourceDetail({super.key, required this.hit, required this.onBack, this.target});

  final ResourceHit hit;
  final VoidCallback onBack;

  /// 锁定的安装目标（从实例详情添加时），不再让用户选
  final String? target;

  @override
  State<ResourceDetail> createState() => _ResourceDetailState();
}

class _ResourceDetailState extends State<ResourceDetail> {
  late Future<(ResourceProject, List<ResourceVersion>)> _future;
  String _instanceId = '';
  List<String> _worlds = [];
  String? _world;
  bool _showAll = false;
  String _installing = '';

  ResourceType get _type => widget.hit.type;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _instanceId = _defaultInstance();
    _loadWorlds();
  }

  Future<(ResourceProject, List<ResourceVersion>)> _load() async {
    final r = await Future.wait([Modrinth.project(widget.hit.id, _type), Modrinth.versions(widget.hit.id)]);
    return (r[0] as ResourceProject, r[1] as List<ResourceVersion>);
  }

  /// 默认安装目标：当前版本；模组则优先选择装了加载器的版本；整合包不需要目标版本
  String _defaultInstance() {
    if (_type == ResourceType.modpack) return '';
    if (widget.target != null) return widget.target!;
    final state = AppScope.read(context);
    final selected = state.selectedVersion;
    if (_type != ResourceType.mod || (selected != null && modrinthLoaders(selected.loader).isNotEmpty)) {
      return selected?.id ?? state.versions.firstOrNull?.id ?? '';
    }
    return (state.versions.where((v) => modrinthLoaders(v.loader).isNotEmpty).firstOrNull ??
                selected ??
                state.versions.firstOrNull)
            ?.id ??
        '';
  }

  Future<void> _loadWorlds() async {
    _worlds = [];
    _world = null;
    final inst = AppScope.read(context).instance(_instanceId);
    if (_type != ResourceType.datapack || inst == null) return;
    final dir = await AppScope.read(context).gameDirOf(inst);
    if (!mounted) return;
    setState(() {
      _worlds = worldsOf(dir);
      _world = _worlds.firstOrNull;
    });
  }

  bool _compatible(ResourceVersion v, InstanceInfo inst) {
    if (_type == ResourceType.modpack) return true;
    if (!v.gameVersions.contains(inst.gameVersion)) return false;
    if (_type != ResourceType.mod) return true;
    final tags = modrinthLoaders(inst.loader);
    return v.loaders.any(tags.contains);
  }

  String? _warning(InstanceInfo? inst) {
    if (_type == ResourceType.modpack) return null;
    if (inst == null) return context.l10n.resourcesNoInstancesInstalledYet;
    if (_type == ResourceType.mod && modrinthLoaders(inst.loader).isEmpty) {
      return context.l10n.resourcesHasNoModLoader(inst.id);
    }
    if (_type == ResourceType.datapack && _worlds.isEmpty) return context.l10n.resourcesHasNoWorldsYet(inst.id);
    return null;
  }

  Future<void> _install(ResourceVersion v, InstanceInfo inst) async {
    setState(() => _installing = v.id);
    try {
      final r = await AppScope.read(context).installResource(v, _type, inst, world: _world);
      if (!mounted) return;
      final parts = [context.l10n.resourcesInstalledFiles(r.installed.length)];
      if (r.skipped.isNotEmpty) parts.add(context.l10n.resourcesAlreadyPresent(r.skipped.length));
      if (r.missing.isNotEmpty) {
        parts.add(context.l10n.resourcesNoCompatibleDependencyFound(r.missing.join(context.l10n.commonListSeparator)));
      }
      toast(context, parts.join(context.l10n.commonClauseSeparator));
    } catch (e) {
      if (mounted) {
        toast(
          context,
          e is TaskCancelled ? context.l10n.commonTaskCanceled : context.l10n.commonInstallationFailed(errorText(e)),
        );
      }
    } finally {
      if (mounted) setState(() => _installing = '');
    }
  }

  Future<void> _installPack(ResourceVersion v) async {
    setState(() => _installing = v.id);
    try {
      final id = await AppScope.read(context).installModpack(v, name: widget.hit.title);
      if (mounted) toast(context, context.l10n.resourcesInstalledModpackAs(id));
    } catch (e) {
      if (mounted) {
        toast(
          context,
          e is TaskCancelled ? context.l10n.commonTaskCanceled : context.l10n.commonInstallationFailed(errorText(e)),
        );
      }
    } finally {
      if (mounted) setState(() => _installing = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final hit = widget.hit;
    final fav = state.isFavorite(hit.id);
    final inst = state.instance(_instanceId);
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        final project = snap.data?.$1;
        final all = snap.data?.$2 ?? const <ResourceVersion>[];
        final shown = _type == ResourceType.modpack || _showAll || inst == null
            ? all
            : all.where((v) => _compatible(v, inst)).toList();
        final warning = _warning(inst);
        final glass = BackgroundScope.activeOf(context) != null;
        final page = ListView(
          padding: glass ? const EdgeInsets.fromLTRB(8, 12, 20, 20) : const EdgeInsets.fromLTRB(16, 12, 24, 24),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: context.l10n.tooltipBack,
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                ResourceIcon(url: hit.icon, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hit.title, style: theme.textTheme.titleLarge),
                      Text(
                        context.l10n.resourcesDownloads2(
                          project?.hit.author ?? hit.author,
                          _type.label,
                          formatCount(context.l10n, hit.downloads),
                          hit.updated.isNotEmpty
                              ? context.l10n.resourcesUpdated(timeAgo(context.l10n, hit.updated))
                              : '',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: fav ? context.l10n.resourcesRemoveFromFavorites : context.l10n.commonFavorites,
                  onPressed: () => state.toggleFavorite(hit),
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? scheme.error : null),
                ),
                TextButton.icon(
                  onPressed: () =>
                      launchUrl(Uri.parse(project?.page ?? 'https://modrinth.com/${_type.tag}/${hit.slug}')),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(context.l10n.resourcesViewModrinth),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 0, 16),
              child: Text(hit.description, style: theme.textTheme.bodyLarge),
            ),
            if (snap.hasError)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.homeFeedCouldntLoad(errorText(snap.error!)),
                  style: TextStyle(color: scheme.error),
                ),
              )
            else if (!snap.hasData)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Card.filled(
                color: glassCardColor(context, scheme.surfaceContainerLow),
                margin: const EdgeInsets.only(left: 56),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (_type != ResourceType.modpack && widget.target != null)
                        Chip(
                          avatar: const Icon(Icons.link, size: 18),
                          label: Text(context.l10n.resourcesInstall(widget.target ?? '')),
                        )
                      else if (_type != ResourceType.modpack)
                        DropdownMenu<String>(
                          width: 320,
                          label: Text(context.l10n.resourcesInstall2),
                          initialSelection: _instanceId.isEmpty ? null : _instanceId,
                          inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
                          dropdownMenuEntries: [
                            for (final v in state.versions) DropdownMenuEntry(value: v.id, label: v.id),
                          ],
                          onSelected: (v) {
                            setState(() => _instanceId = v ?? _instanceId);
                            _loadWorlds();
                          },
                        )
                      else
                        Chip(
                          avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                          label: Text(context.l10n.resourcesWillInstalledAsNew),
                        ),
                      if (_type == ResourceType.datapack && _worlds.isNotEmpty)
                        DropdownMenu<String>(
                          key: ValueKey(_instanceId),
                          width: 220,
                          label: Text(context.l10n.resourcesWorld),
                          initialSelection: _world,
                          inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
                          dropdownMenuEntries: [for (final w in _worlds) DropdownMenuEntry(value: w, label: w)],
                          onSelected: (w) => setState(() => _world = w),
                        ),
                      FilterChip(
                        label: Text(context.l10n.resourcesShowAllFiles),
                        selected: _showAll,
                        onSelected: (v) => setState(() => _showAll = v),
                      ),
                      if (warning != null)
                        Text(warning, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 16, 0, 0),
                  child: Text(
                    inst == null
                        ? context.l10n.resourcesNoFilesAvailable
                        : context.l10n.resourcesNoFilesYouCan(inst.gameVersion),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              for (final v in shown.take(60))
                Padding(
                  padding: const EdgeInsets.only(left: 56, bottom: 6),
                  child: Card.filled(
                    color: glassCardColor(context, scheme.surfaceContainerLow),
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(v.name, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${{'release': context.l10n.resourcesRelease, 'beta': 'Beta', 'alpha': 'Alpha'}[v.type] ?? v.type}'
                        ' · ${v.loaders.join(' / ')} · ${_compactVersions(context.l10n, v.gameVersions)}'
                        ' · ${formatSize(v.fileSize)} · ${timeAgo(context.l10n, v.published)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _installing == v.id
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : FilledButton.tonal(
                              onPressed: _installing.isNotEmpty
                                  ? null
                                  : _type == ResourceType.modpack
                                  ? () => _installPack(v)
                                  : inst == null || (_type == ResourceType.datapack && _world == null)
                                  ? null
                                  : () => _install(v, inst),
                              child: Text(context.l10n.commonInstall),
                            ),
                    ),
                  ),
                ),
            ],
          ],
        );
        if (!glass) return page;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GlassPanel(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16), child: page),
        );
      },
    );
  }

  /// 版本列表太长时只显示首尾
  static String _compactVersions(AppLocalizations l, List<String> list) {
    if (list.length <= 3) return list.join(l.commonListSeparator);
    return l.resourcesVersions(list.first, list.last, list.length);
  }
}

/// 收藏夹
class FavoritesList extends StatefulWidget {
  const FavoritesList({super.key});

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  ResourceHit? _open;

  @override
  Widget build(BuildContext context) {
    if (_open != null) return ResourceDetail(hit: _open!, onBack: () => setState(() => _open = null));
    final theme = Theme.of(context);
    final favorites = AppScope.of(context).favorites;
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(context.l10n.resourcesFavorites, style: theme.textTheme.headlineSmall),
        ),
        if (favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                context.l10n.resourcesNoFavoritesYetClick,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        for (final h in favorites) ResourceCard(hit: h, onTap: () => setState(() => _open = h)),
      ],
    );
    if (BackgroundScope.activeOf(context) == null) return list;
    return GlassPanel(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: list,
    );
  }
}
