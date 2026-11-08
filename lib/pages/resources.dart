import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../core/instance.dart';
import '../core/instance_files.dart';
import '../core/modrinth.dart';
import '../core/task.dart';
import '../widgets/format.dart';

/// 社区资源（Modrinth）：搜索列表，点击进入详情
class ResourceBrowser extends StatefulWidget {
  const ResourceBrowser({super.key, required this.type});

  final ResourceType type;

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

  Future<void> _search({bool more = false}) async {
    final state = AppScope.read(context);
    final current = state.selectedVersion;
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) _hits.clear();
    });
    try {
      final loaders = current == null ? const <String>[] : modrinthLoaders(current.loader);
      final fit = _fitCurrent && current != null && widget.type != ResourceType.modpack;
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
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Modrinth 整合包', extensions: ['mrpack']),
      ],
      confirmButtonText: '选择',
    );
    if (file == null || !mounted) return;
    setState(() => _installingPack = true);
    try {
      final id = await AppScope.read(context).installModpackFile(file.path);
      if (mounted) toast(context, '已安装整合包为 $id');
    } catch (e) {
      if (mounted) toast(context, e is TaskCancelled ? '任务已中断' : '安装失败：${errorText(e)}');
    } finally {
      if (mounted) setState(() => _installingPack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_open != null) {
      return ResourceDetail(hit: _open!, onBack: () => setState(() => _open = null));
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = AppScope.of(context).selectedVersion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            children: [
              Text(widget.type.label, style: theme.textTheme.headlineSmall),
              if (widget.type == ResourceType.modpack) ...[
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _installingPack ? null : _installFromFile,
                  icon: _installingPack
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add, size: 18),
                  label: const Text('从文件安装'),
                ),
              ],
              const Spacer(),
              Text('数据来自 Modrinth', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _query,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: '搜索${widget.type.label}',
                    isDense: true,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 12),
              DropdownMenu<String>(
                width: 150,
                initialSelection: _sort,
                label: const Text('排序'),
                inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'relevance', label: '相关性'),
                  DropdownMenuEntry(value: 'downloads', label: '下载量'),
                  DropdownMenuEntry(value: 'follows', label: '关注数'),
                  DropdownMenuEntry(value: 'newest', label: '最新发布'),
                  DropdownMenuEntry(value: 'updated', label: '最近更新'),
                ],
                onSelected: (v) {
                  _sort = v ?? _sort;
                  _search();
                },
              ),
            ],
          ),
        ),
        if (current != null && widget.type != ResourceType.modpack)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text('适配当前版本：${current.id}'),
                selected: _fitCurrent,
                onSelected: (v) {
                  _fitCurrent = v;
                  _search();
                },
              ),
            ),
          ),
        Expanded(
          child: _error != null && _hits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton.tonal(onPressed: _search, child: const Text('重试')),
                    ],
                  ),
                )
              : _hits.isEmpty && _loading
              ? const Center(child: CircularProgressIndicator())
              : _hits.isEmpty
              ? Center(
                  child: Text('没有找到结果', style: TextStyle(color: scheme.onSurfaceVariant)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: _hits.length + (_hits.length < _total ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _hits.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator()
                              : OutlinedButton(onPressed: () => _search(more: true), child: const Text('加载更多')),
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
    return Card.filled(
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
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
                        _Stat(Icons.download_outlined, formatCount(hit.downloads)),
                        if (hit.updated.isNotEmpty) _Stat(Icons.update, timeAgo(hit.updated)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: fav ? '取消收藏' : '收藏',
                onPressed: () => state.toggleFavorite(hit),
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? scheme.error : null),
              ),
            ],
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
  const ResourceDetail({super.key, required this.hit, required this.onBack});

  final ResourceHit hit;
  final VoidCallback onBack;

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
    if (inst == null) return '还没有安装任何游戏版本';
    if (_type == ResourceType.mod && modrinthLoaders(inst.loader).isEmpty) return '${inst.id} 没有安装模组加载器，模组不会生效';
    if (_type == ResourceType.datapack && _worlds.isEmpty) return '${inst.id} 还没有存档，请先进入游戏创建一个世界';
    return null;
  }

  Future<void> _install(ResourceVersion v, InstanceInfo inst) async {
    setState(() => _installing = v.id);
    try {
      final r = await AppScope.read(context).installResource(v, _type, inst, world: _world);
      if (!mounted) return;
      final parts = ['已安装 ${r.installed.length} 个文件'];
      if (r.skipped.isNotEmpty) parts.add('${r.skipped.length} 个已存在');
      if (r.missing.isNotEmpty) parts.add('找不到兼容的前置：${r.missing.join('、')}');
      toast(context, parts.join('，'));
    } catch (e) {
      if (mounted) toast(context, e is TaskCancelled ? '任务已中断' : '安装失败：${errorText(e)}');
    } finally {
      if (mounted) setState(() => _installing = '');
    }
  }

  Future<void> _installPack(ResourceVersion v) async {
    setState(() => _installing = v.id);
    try {
      final id = await AppScope.read(context).installModpack(v, name: widget.hit.title);
      if (mounted) toast(context, '已安装整合包为 $id');
    } catch (e) {
      if (mounted) toast(context, e is TaskCancelled ? '任务已中断' : '安装失败：${errorText(e)}');
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 24, 24),
          children: [
            Row(
              children: [
                IconButton(tooltip: '返回', onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                ResourceIcon(url: hit.icon, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hit.title, style: theme.textTheme.titleLarge),
                      Text(
                        '${project?.hit.author ?? hit.author} · ${_type.label} · ${formatCount(hit.downloads)} 次下载'
                        '${hit.updated.isNotEmpty ? ' · 更新于 ${timeAgo(hit.updated)}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: fav ? '取消收藏' : '收藏',
                  onPressed: () => state.toggleFavorite(hit),
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? scheme.error : null),
                ),
                TextButton.icon(
                  onPressed: () =>
                      launchUrl(Uri.parse(project?.page ?? 'https://modrinth.com/${_type.tag}/${hit.slug}')),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('在 Modrinth 查看'),
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
                child: Text('加载失败：${errorText(snap.error!)}', style: TextStyle(color: scheme.error)),
              )
            else if (!snap.hasData)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Card.filled(
                color: scheme.surfaceContainerLow,
                margin: const EdgeInsets.only(left: 56),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (_type != ResourceType.modpack)
                        DropdownMenu<String>(
                          width: 320,
                          label: const Text('安装到'),
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
                        Chip(avatar: const Icon(Icons.inventory_2_outlined, size: 18), label: const Text('将安装为新的独立版本')),
                      if (_type == ResourceType.datapack && _worlds.isNotEmpty)
                        DropdownMenu<String>(
                          key: ValueKey(_instanceId),
                          width: 220,
                          label: const Text('世界'),
                          initialSelection: _world,
                          inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
                          dropdownMenuEntries: [for (final w in _worlds) DropdownMenuEntry(value: w, label: w)],
                          onSelected: (w) => setState(() => _world = w),
                        ),
                      FilterChip(
                        label: const Text('显示全部文件'),
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
                    inst == null ? '没有可用的文件' : '没有适配 ${inst.gameVersion} 的文件，可以打开「显示全部文件」',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              for (final v in shown.take(60))
                Padding(
                  padding: const EdgeInsets.only(left: 56, bottom: 6),
                  child: Card.filled(
                    color: scheme.surfaceContainerLow,
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(v.name, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${const {'release': '正式', 'beta': 'Beta', 'alpha': 'Alpha'}[v.type] ?? v.type}'
                        ' · ${v.loaders.join(' / ')} · ${_compactVersions(v.gameVersions)}'
                        ' · ${formatSize(v.fileSize)} · ${timeAgo(v.published)}',
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
                              child: const Text('安装'),
                            ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  /// 版本列表太长时只显示首尾
  static String _compactVersions(List<String> list) {
    if (list.length <= 3) return list.join('、');
    return '${list.first} ~ ${list.last}（${list.length} 个版本）';
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text('收藏夹', style: theme.textTheme.headlineSmall),
        ),
        if (favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('还没有收藏，点击资源右侧的心形图标即可收藏', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ),
        for (final h in favorites) ResourceCard(hit: h, onTap: () => setState(() => _open = h)),
      ],
    );
  }
}
