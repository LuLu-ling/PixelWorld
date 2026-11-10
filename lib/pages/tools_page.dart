import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../core/crash.dart';
import '../core/task.dart';
import '../core/toolbox.dart';
import '../widgets/format.dart';
import '../widgets/settings_group.dart';
import '../shell.dart';
import '../platform.dart';
import '../widgets/side_nav.dart';
import 'diagnose_page.dart';
import 'docs_page.dart';
import 'file_manager_page.dart';
import 'lan_transfer_page.dart';
import 'versions_page.dart';

enum _Section { lobby, transfer, diagnose, toolbox, download, skin, server, achievement, docs }

/// 工具。桌面：左侧二级菜单 + 右侧内容（鼠标操作，列表比卡片合适）；
/// 手机：大块按钮（每块带一句说明），点开进入对应工具，左上角返回
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _Tool {
  const _Tool(this.section, this.title, this.hint, this.icon, {this.sub});

  final _Section? section;
  final String title;
  final String hint;
  final IconData icon;

  /// 进入外壳的子页面（任务历史）而不是工具页内的分类
  final SubPage? sub;
}

class _ToolsPageState extends State<ToolsPage> {
  _Section? _section;

  static const _groups = [
    (
      '游戏',
      [
        _Tool(_Section.transfer, '局域网互传', '在两台设备之间传模组、存档、整个版本', Icons.swap_horiz),
        _Tool(_Section.diagnose, '错误分析', '查看日志，自动找出崩溃原因', Icons.troubleshoot),
        _Tool(_Section.download, '自定义下载', '按链接下载文件到指定位置', Icons.download_for_offline_outlined),
        _Tool(_Section.skin, '皮肤与头像', '查看和下载正版玩家的皮肤', Icons.face_outlined),
        _Tool(_Section.server, '服务器查询', '查询服务器在线人数和延迟', Icons.dns_outlined),
        _Tool(_Section.achievement, '成就图片', '生成自定义的成就弹窗图片', Icons.emoji_events_outlined),
      ],
    ),
    (
      '其他',
      [
        _Tool(null, '任务历史', '下载与安装记录', Icons.history, sub: SubPage.tasks),
        _Tool(_Section.toolbox, '百宝箱', '今日人品、随机种子等小工具', Icons.handyman_outlined),
        _Tool(_Section.docs, '使用文档', '在启动器里阅读官网文档', Icons.menu_book_outlined),
        _Tool(_Section.lobby, '联机大厅', '规划中', Icons.lan_outlined),
      ],
    ),
  ];

  static Widget _content(_Section section) => switch (section) {
    _Section.lobby => const _Lobby(),
    _Section.transfer => const LanTransferPage(),
    _Section.diagnose => const _Diagnose(),
    _Section.toolbox => const _Toolbox(),
    _Section.download => const _CustomDownload(),
    _Section.skin => const _SkinTools(),
    _Section.server => const _ServerQuery(),
    _Section.achievement => const _Achievement(),
    _Section.docs => const DocsPage(),
  };

  /// 桌面：和设置页一样的左侧分组菜单；「任务历史」打开外壳的子页面，不改变当前选中项
  Widget _desktop(BuildContext context) {
    final section = _section ?? _Section.transfer;
    final current = _groups.expand((g) => g.$2).firstWhere((t) => t.section == section);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav<_Tool>(
          groups: [
            for (final (title, tools) in _groups)
              SideNavGroup(title, [for (final t in tools) SideNavItem(t, t.title, t.icon)]),
          ],
          value: current,
          onChanged: (t) => t.sub != null ? ShellNav.of(context).open(t.sub!) : setState(() => _section = t.section),
        ),
        Expanded(child: ContentPanel(child: _content(section))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) return _desktop(context);
    final theme = Theme.of(context);
    final section = _section;
    if (section != null) {
      final tool = _groups.expand((g) => g.$2).firstWhere((t) => t.section == section);
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(tooltip: '返回工具', onPressed: () => setState(() => _section = null), icon: const Icon(Icons.arrow_back)),
                Text(tool.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            Expanded(
              child: ContentPanel(child: _content(section)),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 16, 16),
      children: [
        for (final (title, tools) in _groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
            child: Text(title, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 560 ? 3 : 2);
              final w = (c.maxWidth - 10 * (cols - 1)) / cols;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in tools)
                    SizedBox(
                      width: w,
                      child: _ToolTile(
                        tool: t,
                        onTap: () => t.sub != null ? ShellNav.of(context).open(t.sub!) : setState(() => _section = t.section),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.onTap});

  final _Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(11)),
                  child: Icon(tool.icon, color: scheme.onPrimaryContainer, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tool.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        tool.hint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _page(List<Widget> children) => ListView(padding: const EdgeInsets.fromLTRB(6, 2, 16, 16), children: children);

/// 选择保存位置：桌面端系统对话框，手机上内置文件管理器
Future<String?> _saveAs(BuildContext context, String name, {String label = 'PNG 图片', List<String> ext = const ['png']}) =>
    pickSavePath(context, name, extensions: ext, label: label);

// ---------- 联机大厅（规划中） ----------

class _Lobby extends StatelessWidget {
  const _Lobby();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lan_outlined, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('联机大厅', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '让几位玩家组成虚拟局域网一起游戏，正在规划中',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------- 错误分析 ----------

class _Diagnose extends StatelessWidget {
  const _Diagnose();

  Future<void> _lastRun(BuildContext context) async {
    final report = await AppScope.read(context).analyzeLastRun();
    if (!context.mounted) return;
    if (report == null) return toast(context, '本次打开启动器后还没有启动过游戏');
    openDiagnosis(context, report);
  }

  Future<void> _file(BuildContext context) async {
    final path = await pickFile(
      context,
      label: '日志',
      extensions: const ['log', 'txt'],
      start: Platform.isAndroid ? AppScope.read(context).config.gameDir : null,
    );
    if (path == null || !context.mounted) return;
    final text = utf8.decode(await File(path).readAsBytes(), allowMalformed: true);
    if (!context.mounted) return;
    _open(context, p.basename(path), text);
  }

  void _open(BuildContext context, String name, String text) {
    if (text.trim().isEmpty) return toast(context, '内容为空');
    openDiagnosis(context, reportFromText(name, text, AppScope.read(context).redactor()));
  }

  Future<void> _paste(BuildContext context) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('粘贴日志'),
        content: SizedBox(
          width: 640,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 12,
            maxLines: 20,
            decoration: const InputDecoration(hintText: '粘贴崩溃报告或日志内容', border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('分析')),
        ],
      ),
    );
    ctrl.dispose();
    if (text != null && context.mounted) _open(context, '粘贴的日志', text);
  }

  @override
  Widget build(BuildContext context) {
    Widget tool(IconData icon, String title, String subtitle, String action, VoidCallback onTap) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: FilledButton.tonal(onPressed: onTap, child: Text(action)),
    );
    return _page([
      SettingsGroup(
        title: '错误分析',
        children: [
          tool(Icons.history, '最近一次游戏', '分析本次打开启动器后最近一次运行的游戏', '分析', () => _lastRun(context)),
          tool(Icons.description_outlined, '日志文件', '选择崩溃报告（crash-reports）或日志文件（logs）', '选择', () => _file(context)),
          tool(Icons.content_paste, '粘贴日志', '粘贴别人发给你的崩溃报告或日志', '粘贴', () => _paste(context)),
        ],
      ),
      Text(
        '启动器先用本地规则匹配常见问题；在「设置 → AI 排障」填写自己的 AI 服务后，还可以让 AI 分析日志。'
        '游戏崩溃时会自动弹出提示。',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ]);
  }
}

// ---------- 百宝箱 ----------

class _Toolbox extends StatelessWidget {
  const _Toolbox();

  Future<void> _clean(BuildContext context) async {
    final state = AppScope.read(context);
    final folders = VersionsPage.folders(state.config).map((f) => f.path).toList();
    final junk = findGameJunk(folders);
    final size = junk.fold<int>(0, (s, e) => s + sizeOf(e));
    if (junk.isEmpty) return toast(context, '没有需要清理的文件');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cleaning_services_outlined),
        title: const Text('清理游戏垃圾'),
        content: Text(
          '将删除 ${junk.length} 项，共 ${formatSize(size)}：\n'
          '游戏文件夹与各版本文件夹中的日志（logs、*.log）、崩溃报告（crash-reports、hs_err_pid*）'
          '与解压出的本地库（natives，启动时会重新生成）。\n\n存档、模组与设置不会被删除。',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('清理')),
        ],
      ),
    );
    if (ok != true) return;
    final failed = await deleteAll(junk);
    if (context.mounted) {
      toast(context, failed == 0 ? '已清理 ${formatSize(size)}' : '已清理，$failed 项正在被使用，没有删除');
    }
  }

  Future<void> _luck(BuildContext context) async {
    final state = AppScope.read(context);
    final name = state.selectedAccount?.name ?? '玩家';
    final v = luckToday(name);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome_outlined),
        title: Text('$name 的今日人品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$v', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(luckComment(v)),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('好'))],
      ),
    );
  }

  Future<void> _shortcut(BuildContext context) async {
    try {
      final path = await createDesktopShortcut();
      if (context.mounted) toast(context, '已创建 $path');
    } catch (e) {
      if (context.mounted) toast(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = AppScope.of(context).config.launchCount;
    Widget tool(IconData icon, String title, String subtitle, String action, VoidCallback? onTap) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : FilledButton.tonal(onPressed: onTap, child: Text(action)),
    );
    return _page([
      SettingsGroup(
        title: '百宝箱',
        children: [
          tool(Icons.cleaning_services_outlined, '清理游戏垃圾', '删除日志、崩溃报告与解压出的本地库，不影响存档和模组', '清理', () => _clean(context)),
          tool(Icons.auto_awesome_outlined, '今日人品', '看看今天的运气，每人每天固定', '查看', () => _luck(context)),
          if (Platform.isWindows) tool(Icons.shortcut, '创建桌面快捷方式', '在桌面创建启动器的快捷方式', '创建', () => _shortcut(context)),
          tool(Icons.rocket_launch_outlined, '启动次数', '已经通过启动器启动了 $count 次游戏', '', null),
        ],
      ),
    ]);
  }
}

// ---------- 自定义下载 ----------

class _CustomDownload extends StatefulWidget {
  const _CustomDownload();

  @override
  State<_CustomDownload> createState() => _CustomDownloadState();
}

class _CustomDownloadState extends State<_CustomDownload> {
  final _url = TextEditingController();
  final _name = TextEditingController();
  String? _dir;
  String? _saved;

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final url = _url.text.trim();
    var dir = _dir;
    dir ??= await pickFolder(context, confirm: '保存到');
    if (dir == null || !mounted) return;
    setState(() => _dir = dir);
    final name = _name.text.trim().isEmpty ? fileNameFromUrl(url) : _name.text.trim();
    final path = p.join(dir, name);
    final state = AppScope.read(context);
    final existed = File(path).existsSync();
    final t = TaskProgress('下载 $name', steps: const ['下载'], canCancel: true);
    if (!existed) t.registerCleanupPath(path);
    try {
      await state.track(t, () => downloadToFile(url, path, t));
      if (mounted) setState(() => _saved = path);
    } catch (e) {
      if (mounted) toast(context, '下载失败：${errorText(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _page([
      Text('自定义下载', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text('下载任意文件，进度显示在任务页', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 20),
      TextField(
        controller: _url,
        decoration: const InputDecoration(labelText: '下载地址', hintText: 'https://', border: OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _name,
        decoration: InputDecoration(
          labelText: '文件名（可选）',
          hintText: _url.text.trim().isEmpty ? null : fileNameFromUrl(_url.text),
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: Text(_dir == null ? '保存位置：开始下载时选择' : '保存位置：$_dir', overflow: TextOverflow.ellipsis)),
          TextButton(
            onPressed: () async {
              final d = await pickFolder(context);
              if (d != null) setState(() => _dir = d);
            },
            child: const Text('选择'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          FilledButton.icon(
            onPressed: _url.text.trim().isEmpty ? null : _start,
            icon: const Icon(Icons.download),
            label: const Text('开始下载'),
          ),
          if (_saved != null) ...[
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => Process.start(Platform.isWindows ? 'explorer.exe' : 'open', [p.dirname(_saved!)]),
              icon: const Icon(Icons.folder_open),
              label: const Text('打开文件夹'),
            ),
          ],
        ],
      ),
    ]);
  }
}

// ---------- 皮肤与头像 ----------

/// 从皮肤截取头部（脸 + 帽子层），按像素放大，返回 PNG
Future<Uint8List> renderHead(Uint8List skinPng, int size) async {
  final codec = await ui.instantiateImageCodec(skinPng);
  final skin = (await codec.getNextFrame()).image;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..filterQuality = FilterQuality.none;
  final dst = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
  canvas.drawImageRect(skin, const Rect.fromLTWH(8, 8, 8, 8), dst, paint);
  canvas.drawImageRect(skin, const Rect.fromLTWH(40, 8, 8, 8), dst, paint);
  final img = await recorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

class _SkinTools extends StatefulWidget {
  const _SkinTools();

  @override
  State<_SkinTools> createState() => _SkinToolsState();
}

class _SkinToolsState extends State<_SkinTools> {
  final _player = TextEditingController();
  PlayerSkin? _skin;
  Uint8List? _localSkin;
  String? _localName;
  int _size = 128;
  bool _busy = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Uint8List? get _source => _localSkin ?? _skin?.png;

  Future<void> _fetch() async {
    setState(() => _busy = true);
    try {
      final s = await fetchSkin(_player.text);
      setState(() {
        _skin = s;
        _localSkin = null;
      });
    } catch (e) {
      if (mounted) toast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickLocal() async {
    final f = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: '皮肤图片', extensions: ['png']),
      ],
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    setState(() {
      _localSkin = bytes;
      _localName = f.name;
    });
  }

  Future<void> _saveSkin() async {
    final s = _skin!;
    final path = await _saveAs(context, '${s.name}.png');
    if (path == null) return;
    await File(path).writeAsBytes(s.png);
    if (mounted) toast(context, '已保存 $path');
  }

  Future<void> _saveHead() async {
    final png = await renderHead(_source!, _size);
    if (!mounted) return;
    final path = await _saveAs(context, '${_skin?.name ?? 'Head'}-$_size.png');
    if (path == null) return;
    await File(path).writeAsBytes(png);
    if (mounted) toast(context, '已保存 $path');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _page([
      Text('正版皮肤', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _player,
              decoration: const InputDecoration(labelText: '正版玩家名', border: OutlineInputBorder()),
              onSubmitted: (_) => _fetch(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: _busy ? null : _fetch, child: const Text('获取')),
        ],
      ),
      if (_skin != null) ...[
        const SizedBox(height: 16),
        Card.filled(
          color: scheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Image.memory(_skin!.png, width: 64, height: 64, filterQuality: FilterQuality.none),
            title: Text(_skin!.name),
            subtitle: Text('${_skin!.slim ? 'Alex 模型（细手臂）' : 'Steve 模型'} · ${_skin!.uuid}'),
            trailing: FilledButton.tonal(onPressed: _saveSkin, child: const Text('保存皮肤')),
          ),
        ),
      ],
      const SizedBox(height: 32),
      Text('头像生成', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        '从皮肤截取头部（含帽子层）并放大，可用上面获取的正版皮肤或本地皮肤文件',
        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _pickLocal,
            icon: const Icon(Icons.image_outlined),
            label: Text(_localName == null ? '选择本地皮肤' : '本地：$_localName'),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 64, label: Text('64')),
              ButtonSegment(value: 128, label: Text('128')),
              ButtonSegment(value: 256, label: Text('256')),
              ButtonSegment(value: 512, label: Text('512')),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (_source != null)
        Row(
          children: [
            FutureBuilder(
              future: renderHead(_source!, 128),
              builder: (context, snap) => Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: snap.hasData ? Image.memory(snap.data!, filterQuality: FilterQuality.none) : null,
              ),
            ),
            const SizedBox(width: 20),
            FilledButton.icon(
              onPressed: _saveHead,
              icon: const Icon(Icons.save_alt),
              label: Text('保存 $_size×$_size 头像'),
            ),
          ],
        )
      else
        Text('先获取正版皮肤或选择本地皮肤', style: TextStyle(color: scheme.onSurfaceVariant)),
    ]);
  }
}

// ---------- 服务器查询 ----------

class _ServerQuery extends StatefulWidget {
  const _ServerQuery();

  @override
  State<_ServerQuery> createState() => _ServerQueryState();
}

class _ServerQueryState extends State<_ServerQuery> {
  final _address = TextEditingController();
  Future<ServerStatus>? _future;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _query() {
    if (_address.text.trim().isEmpty) return;
    setState(() => _future = queryServer(_address.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _page([
      Text('服务器查询', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'mc.example.com 或 1.2.3.4:25565',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _query(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: _query, child: const Text('查询')),
        ],
      ),
      const SizedBox(height: 16),
      if (_future != null)
        FutureBuilder(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const LinearProgressIndicator();
            if (snap.hasError) return Text(errorText(snap.error!), style: TextStyle(color: scheme.error));
            final s = snap.data!;
            return Card.filled(
              color: scheme.surfaceContainerLow,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: s.favicon != null
                          ? Image.memory(s.favicon!, width: 64, height: 64, filterQuality: FilterQuality.none)
                          : Container(
                              width: 64,
                              height: 64,
                              color: scheme.surfaceContainerHighest,
                              child: const Icon(Icons.dns_outlined),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.motd.isEmpty ? _address.text.trim() : s.motd, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text('在线 ${s.online} / ${s.max} · ${s.version} · 延迟 ${s.latency} ms'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    ]);
  }
}

// ---------- 成就图片 ----------

class _Achievement extends StatefulWidget {
  const _Achievement();

  @override
  State<_Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<_Achievement> {
  final _block = TextEditingController(text: 'diamond');
  final _title = TextEditingController(text: '获得成就！');
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  Uint8List? _png;
  bool _busy = false;

  /// 本地绘制时使用的图标（可选）
  Uint8List? _icon;
  String? _iconName;
  bool _local = false;

  @override
  void dispose() {
    for (final c in [_block, _title, _line1, _line2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      if (_title.text.trim().isEmpty || _line1.text.trim().isEmpty) throw Exception('请填写标题和第一行文字');
      Uint8List png;
      var local = false;
      try {
        png = await fetchAchievement(block: _block.text, title: _title.text, line1: _line1.text, line2: _line2.text);
      } catch (_) {
        // 在线服务会拦截桌面程序的请求，失败时在本地绘制
        png = await renderAchievement(title: _title.text, line1: _line1.text, line2: _line2.text, icon: _icon);
        local = true;
      }
      setState(() {
        _png = png;
        _local = local;
      });
    } catch (e) {
      if (mounted) toast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final path = await _saveAs(context, '${_title.text.trim().isEmpty ? 'achievement' : _title.text.trim()}.png');
    if (path == null) return;
    await File(path).writeAsBytes(_png!);
    if (mounted) toast(context, '已保存 $path');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InputDecoration deco(String label, [String? hint]) =>
        InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());
    return _page([
      Text('成就图片', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        '生成 Minecraft 风格的成就提示图片。优先由第三方服务 minecraft-api.com 生成（填写的文字会发送给它）；'
        '该服务拒绝请求时在本地绘制，本地绘制使用系统字体和你选择的图标',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: TextField(controller: _block, decoration: deco('物品 ID（在线生成）', '例如 diamond、grass、golden_apple')),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final f = await openFile(
                acceptedTypeGroups: const [
                  XTypeGroup(label: '图标', extensions: ['png']),
                ],
              );
              if (f == null) return;
              final bytes = await f.readAsBytes();
              setState(() {
                _icon = bytes;
                _iconName = f.name;
              });
            },
            icon: const Icon(Icons.image_outlined),
            label: Text(_iconName == null ? '图标（本地绘制）' : _iconName!),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(controller: _title, decoration: deco('标题')),
      const SizedBox(height: 12),
      TextField(controller: _line1, decoration: deco('第一行')),
      const SizedBox(height: 12),
      TextField(controller: _line2, decoration: deco('第二行（可选）')),
      const SizedBox(height: 16),
      Row(
        children: [
          FilledButton(onPressed: _busy ? null : _generate, child: const Text('生成')),
          if (_png != null) ...[
            const SizedBox(width: 12),
            FilledButton.tonal(onPressed: _save, child: const Text('保存图片')),
          ],
        ],
      ),
      if (_png != null) ...[
        const SizedBox(height: 16),
        if (_local)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('在线服务不可用，以下为本地绘制', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Image.memory(_png!, width: 640, filterQuality: FilterQuality.none),
        ),
      ],
    ]);
  }
}

/// 本地绘制成就提示图片：深色面板、黄色标题、白色文字（尺寸与在线生成的一致：320×64）
Future<Uint8List> renderAchievement({
  required String title,
  required String line1,
  String line2 = '',
  Uint8List? icon,
}) async {
  const w = 320.0, h = 64.0, scale = 2.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(1, 1, w - 2, h - 2), const Radius.circular(3));
  canvas.drawRRect(rect, Paint()..color = const Color(0xFF212121));
  canvas.drawRRect(
    rect,
    Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  var textLeft = 14.0;
  if (icon != null) {
    final img = (await (await ui.instantiateImageCodec(icon)).getNextFrame()).image;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      const Rect.fromLTWH(14, 16, 32, 32),
      Paint()..filterQuality = FilterQuality.none,
    );
    textLeft = 56;
  }
  void text(String t, Color color, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontFamily: 'Microsoft YaHei UI',
          fontFamilyFallback: const ['PingFang SC', 'Noto Sans CJK SC', 'sans-serif'],
          shadows: const [Shadow(color: Color(0xFF3F3F3F), offset: Offset(1.5, 1.5))],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: w - textLeft - 10);
    tp.paint(canvas, Offset(textLeft, y));
  }

  final lines = [line1.trim(), if (line2.trim().isNotEmpty) line2.trim()];
  final top = lines.length == 1 ? 12.0 : 4.0;
  text(title.trim(), const Color(0xFFFFFF00), top);
  for (var i = 0; i < lines.length; i++) {
    text(lines[i], Colors.white, top + 20 * (i + 1));
  }
  final img = await recorder.endRecording().toImage((w * scale).round(), (h * scale).round());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
