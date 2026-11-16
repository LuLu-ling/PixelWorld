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
import '../widgets/settings_group.dart';
import '../platform.dart';
import '../widgets/side_nav.dart';
import '../widgets/app_background.dart';
import 'diagnose_page.dart';
import 'file_manager_page.dart';
import 'lan_transfer_page.dart';
import '../l10n/l10n.dart';
import '../core/i18n/strings.dart';

enum _Section { lobby, transfer, diagnose, luck, download, skin, server, achievement }

/// 工具。桌面：左侧二级菜单 + 右侧内容（鼠标操作，列表比卡片合适）；
/// 手机：大块按钮（每块带一句说明），点开进入对应工具，左上角返回
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _Tool {
  const _Tool(this.section, this.title, this.hint, this.icon);

  final _Section section;
  final String title;
  final String hint;
  final IconData icon;
}

/// 从别的页面跳到工具的某一项（值为 _Section 的名字，例如 transfer），打开后清空
final toolsSectionRequest = ValueNotifier<String?>(null);

class _ToolsPageState extends State<ToolsPage> {
  _Section? _section;

  @override
  void initState() {
    super.initState();
    toolsSectionRequest.addListener(_onRequest);
    _onRequest();
  }

  @override
  void dispose() {
    toolsSectionRequest.removeListener(_onRequest);
    super.dispose();
  }

  void _onRequest() {
    final s = _Section.values.asNameMap()[toolsSectionRequest.value];
    if (s == null) return;
    toolsSectionRequest.value = null;
    if (mounted) setState(() => _section = s);
  }

  // 任务历史在顶栏的任务面板里；清理游戏垃圾、桌面快捷方式、使用文档在设置里
  static List<(String, List<_Tool>)> _groups(AppLocalizations l) => [
    (
      l.toolsMultiplayer,
      [
        _Tool(_Section.transfer, l.toolsLANTransfer, l.toolsSendModsWorldsWhole, Icons.swap_horiz),
        _Tool(_Section.server, l.toolsServerLookup, l.toolsCheckServersPlayerCount, Icons.dns_outlined),
        _Tool(_Section.lobby, l.toolsMultiplayerLobby, l.toolsPlanned, Icons.lan_outlined),
      ],
    ),
    (l.toolsTroubleshooting, [_Tool(_Section.diagnose, l.subDiagnose, l.toolsReadLogsFindCause, Icons.troubleshoot)]),
    (
      l.toolsUtilities,
      [
        _Tool(
          _Section.download,
          l.toolsCustomDownload,
          l.toolsDownloadFileFromLink,
          Icons.download_for_offline_outlined,
        ),
      ],
    ),
    (
      l.toolsFun,
      [
        _Tool(_Section.skin, l.toolsSkinsAvatars, l.toolsViewDownloadMinecraftPlayers, Icons.face_outlined),
        _Tool(
          _Section.achievement,
          l.toolsAchievementImage,
          l.toolsMakeCustomAchievementToast,
          Icons.emoji_events_outlined,
        ),
        _Tool(_Section.luck, l.toolsTodaysLuck, l.toolsSeeHowLuckyYou, Icons.auto_awesome_outlined),
      ],
    ),
  ];

  static Widget _content(_Section section) => switch (section) {
    _Section.lobby => const _Lobby(),
    _Section.transfer => const LanTransferPage(),
    _Section.diagnose => const _Diagnose(),
    _Section.luck => const _Luck(),
    _Section.download => const _CustomDownload(),
    _Section.skin => const _SkinTools(),
    _Section.server => const _ServerQuery(),
    _Section.achievement => const _Achievement(),
  };

  /// 桌面：和设置页一样的左侧分组菜单
  Widget _desktop(BuildContext context) {
    final section = _section ?? _Section.transfer;
    final current = _groups(context.l10n).expand((g) => g.$2).firstWhere((t) => t.section == section);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav<_Tool>(
          groups: [
            for (final (title, tools) in _groups(context.l10n))
              SideNavGroup(title, [for (final t in tools) SideNavItem(t, t.title, t.icon)]),
          ],
          value: current,
          onChanged: (t) => setState(() => _section = t.section),
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
      final tool = _groups(context.l10n).expand((g) => g.$2).firstWhere((t) => t.section == section);
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: context.l10n.toolsBackTools,
                  onPressed: () => setState(() => _section = null),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(tool.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            Expanded(child: ContentPanel(child: _content(section))),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 16, 16),
      children: [
        for (final (title, tools) in _groups(context.l10n)) ...[
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
                      child: _ToolTile(tool: t, onTap: () => setState(() => _section = t.section)),
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
    return GlassPanel(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
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
Future<String?> _saveAs(BuildContext context, String name, {String? label, List<String> ext = const ['png']}) =>
    pickSavePath(context, name, extensions: ext, label: label ?? context.l10n.toolsPNGImage);

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
          Text(context.l10n.toolsMultiplayerLobby, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            context.l10n.toolsLetsFewPlayersForm,
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
    if (report == null) return toast(context, context.l10n.toolsNoGameHasBeen);
    openDiagnosis(context, report);
  }

  Future<void> _file(BuildContext context) async {
    final path = await pickFile(
      context,
      label: context.l10n.toolsLog,
      extensions: const ['log', 'txt'],
      start: Platform.isAndroid ? AppScope.read(context).config.gameDir : null,
    );
    if (path == null || !context.mounted) return;
    final text = utf8.decode(await File(path).readAsBytes(), allowMalformed: true);
    if (!context.mounted) return;
    _open(context, p.basename(path), text);
  }

  void _open(BuildContext context, String name, String text) {
    if (text.trim().isEmpty) return toast(context, context.l10n.toolsEmpty);
    openDiagnosis(context, reportFromText(name, text, AppScope.read(context).redactor()));
  }

  Future<void> _paste(BuildContext context) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.toolsPasteLog),
        content: SizedBox(
          width: 640,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 12,
            maxLines: 20,
            decoration: InputDecoration(
              hintText: context.l10n.toolsPasteCrashReportLog,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text(context.l10n.toolsAnalyze)),
        ],
      ),
    );
    ctrl.dispose();
    if (text != null && context.mounted) _open(context, context.l10n.toolsPastedLog, text);
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
        title: context.l10n.subDiagnose,
        children: [
          tool(
            Icons.history,
            context.l10n.toolsLastGame,
            context.l10n.toolsAnalyzeMostRecentGame,
            context.l10n.toolsAnalyze,
            () => _lastRun(context),
          ),
          tool(
            Icons.description_outlined,
            context.l10n.toolsLogFile,
            context.l10n.toolsChooseCrashReportCrash,
            context.l10n.commonChoose,
            () => _file(context),
          ),
          tool(
            Icons.content_paste,
            context.l10n.toolsPasteLog,
            context.l10n.toolsPasteCrashReportLog2,
            context.l10n.toolsPaste,
            () => _paste(context),
          ),
        ],
      ),
      Text(
        context.l10n.toolsLauncherFirstMatchesCommon,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ]);
  }
}

// ---------- 今日人品 ----------

class _Luck extends StatelessWidget {
  const _Luck();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final name = state.selectedAccount?.name ?? context.l10n.toolsPlayer;
    final v = luckToday(name);
    return _page([
      SettingsGroup(
        title: context.l10n.toolsTodaysLuck,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(context.l10n.toolsSLuckToday(name), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  '$v',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(luckComment(v)),
                const SizedBox(height: 2),
                Text(
                  context.l10n.toolsFixedEachPlayerEach,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.rocket_launch_outlined),
            title: Text(context.l10n.toolsLaunchCount),
            subtitle: Text(context.l10n.toolsYouveLaunchedGameTimes(state.config.launchCount)),
          ),
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
    dir ??= await pickFolder(context, confirm: context.l10n.toolsSave);
    if (dir == null || !mounted) return;
    setState(() => _dir = dir);
    final name = _name.text.trim().isEmpty ? fileNameFromUrl(url) : _name.text.trim();
    final path = p.join(dir, name);
    final state = AppScope.read(context);
    final existed = File(path).existsSync();
    final t = TaskProgress(context.l10n.toolsDownload(name), steps: [context.l10n.commonDownload], canCancel: true);
    if (!existed) t.registerCleanupPath(path);
    try {
      await state.track(t, () => downloadToFile(url, path, t));
      if (mounted) setState(() => _saved = path);
    } catch (e) {
      if (mounted) toast(context, context.l10n.toolsDownloadFailed(errorText(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _page([
      Text(context.l10n.toolsCustomDownload, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        context.l10n.toolsDownloadAnyFileProgress,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _url,
        decoration: InputDecoration(
          labelText: context.l10n.toolsDownloadURL,
          hintText: 'https://',
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _name,
        decoration: InputDecoration(
          labelText: context.l10n.toolsFileNameOptional,
          hintText: _url.text.trim().isEmpty ? null : fileNameFromUrl(_url.text),
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Text(
              _dir == null ? context.l10n.toolsSaveLocationChosenWhen : context.l10n.toolsSaveLocation(_dir ?? ''),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () async {
              final d = await pickFolder(context);
              if (d != null) setState(() => _dir = d);
            },
            child: Text(context.l10n.commonChoose),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          FilledButton.icon(
            onPressed: _url.text.trim().isEmpty ? null : _start,
            icon: const Icon(Icons.download),
            label: Text(context.l10n.toolsStartDownload),
          ),
          if (_saved != null) ...[
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => Process.start(Platform.isWindows ? 'explorer.exe' : 'open', [p.dirname(_saved!)]),
              icon: const Icon(Icons.folder_open),
              label: Text(context.l10n.homeOpenFolder),
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
      acceptedTypeGroups: [
        XTypeGroup(label: context.l10n.toolsSkinImage, extensions: const ['png']),
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
    if (mounted) toast(context, context.l10n.toolsSaved(path));
  }

  Future<void> _saveHead() async {
    final png = await renderHead(_source!, _size);
    if (!mounted) return;
    final path = await _saveAs(context, '${_skin?.name ?? 'Head'}-$_size.png');
    if (path == null) return;
    await File(path).writeAsBytes(png);
    if (mounted) toast(context, context.l10n.toolsSaved(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _page([
      Text(context.l10n.toolsPlayerSkins, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _player,
              decoration: InputDecoration(
                labelText: context.l10n.toolsMinecraftPlayerName,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _fetch(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: _busy ? null : _fetch, child: Text(context.l10n.toolsGet)),
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
            subtitle: Text(
              '${_skin!.slim ? context.l10n.toolsAlexModelSlimArms : context.l10n.toolsSteveModel} · ${_skin!.uuid}',
            ),
            trailing: FilledButton.tonal(onPressed: _saveSkin, child: Text(context.l10n.toolsSaveSkin)),
          ),
        ),
      ],
      const SizedBox(height: 32),
      Text(context.l10n.toolsAvatarMaker, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        context.l10n.toolsCropsHeadHatLayer,
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
            label: Text(
              _localName == null ? context.l10n.toolsChooseLocalSkin : context.l10n.toolsLocal(_localName ?? ''),
            ),
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
              label: Text(context.l10n.toolsSaveAvatar(_size)),
            ),
          ],
        )
      else
        Text(context.l10n.toolsFetchPlayersSkinChoose, style: TextStyle(color: scheme.onSurfaceVariant)),
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
      Text(context.l10n.toolsServerLookup, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _address,
              decoration: InputDecoration(
                labelText: context.l10n.toolsServerAddress,
                hintText: context.l10n.toolsMcExampleCom1,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _query(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: _query, child: Text(context.l10n.toolsLookUp)),
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
                          Text(context.l10n.toolsOnlineMsLatency(s.online, s.max, s.version, s.latency)),
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
  final _title = TextEditingController(text: tr.toolsAchievementGet);
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
      if (_title.text.trim().isEmpty || _line1.text.trim().isEmpty) {
        throw Exception(context.l10n.toolsFillTitleFirstLine);
      }
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
    if (mounted) toast(context, context.l10n.toolsSaved(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InputDecoration deco(String label, [String? hint]) =>
        InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());
    return _page([
      Text(context.l10n.toolsAchievementImage, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        context.l10n.toolsMakesMinecraftStyleAchievement,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _block,
              decoration: deco(context.l10n.toolsItemIDOnline, context.l10n.toolsEGDiamondGrass),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final f = await openFile(
                acceptedTypeGroups: [
                  XTypeGroup(label: context.l10n.toolsIcon, extensions: const ['png']),
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
            label: Text(_iconName == null ? context.l10n.toolsIconLocalDrawing : _iconName!),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(controller: _title, decoration: deco(context.l10n.toolsTitle)),
      const SizedBox(height: 12),
      TextField(controller: _line1, decoration: deco(context.l10n.toolsFirstLine)),
      const SizedBox(height: 12),
      TextField(controller: _line2, decoration: deco(context.l10n.toolsSecondLineOptional)),
      const SizedBox(height: 16),
      Row(
        children: [
          FilledButton(onPressed: _busy ? null : _generate, child: Text(context.l10n.toolsGenerate)),
          if (_png != null) ...[
            const SizedBox(width: 12),
            FilledButton.tonal(onPressed: _save, child: Text(context.l10n.toolsSaveImage)),
          ],
        ],
      ),
      if (_png != null) ...[
        const SizedBox(height: 16),
        if (_local)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              context.l10n.toolsOnlineServiceIsntAvailable,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
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
