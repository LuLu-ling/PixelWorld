import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../app_state.dart';
import '../core/instance.dart';
import '../core/lan_transfer.dart';
import '../core/loader_names.dart';
import '../widgets/format.dart';
import '../widgets/settings_group.dart';

/// 收到但还没导入的传输包；离开页面后仍保留，直到导入、删除或关闭启动器
final _received = <ReceivedTransfer>[];

/// 局域网互传：接收方显示 IP、随机端口和配对码；发送方选择版本和内容后发送
class LanTransferPage extends StatefulWidget {
  const LanTransferPage({super.key});

  @override
  State<LanTransferPage> createState() => _LanTransferPageState();
}

class _LanTransferPageState extends State<LanTransferPage> {
  // ---------- 接收 ----------
  TransferServer? _server;
  List<String> _addresses = [];
  String? _stopReason;
  (int, int)? _recvProgress;
  StreamSubscription<(int, int)>? _progressSub;

  // ---------- 发送 ----------
  InstanceInfo? _version;
  var _whole = false;
  final _items = <String>{'mods', 'config', 'saves'};
  final _address = TextEditingController();
  final _code = TextEditingController();
  var _sending = false;
  String? _sendStatus;
  double? _sendProgress;

  @override
  void dispose() {
    // 离开页面就停止接收：只在需要时监听端口
    _progressSub?.cancel();
    _server?.close();
    _address.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _startReceive() async {
    try {
      final s = await TransferServer.start(
        onReceived: (t) {
          if (!mounted) return;
          setState(() {
            _received.add(t);
            _recvProgress = null;
          });
          toast(context, '收到来自 ${t.manifest.from} 的「${t.manifest.version}」');
        },
        onStopped: (reason) {
          if (!mounted) return;
          setState(() {
            _server = null;
            _stopReason = reason;
          });
        },
      );
      final addrs = await localAddresses();
      _progressSub = s.progress.stream.listen((v) {
        if (mounted) setState(() => _recvProgress = v);
      });
      setState(() {
        _server = s;
        _addresses = addrs;
        _stopReason = null;
      });
    } catch (e) {
      if (mounted) toast(context, '无法开始接收：$e');
    }
  }

  Future<void> _stopReceive() async {
    await _progressSub?.cancel();
    _progressSub = null;
    await _server?.close();
    setState(() {
      _server = null;
      _recvProgress = null;
    });
  }

  Future<void> _import(AppState state, ReceivedTransfer t) async {
    final m = t.manifest;
    try {
      if (m.wholeVersion) {
        final ok = await _confirm(
          '导入为新版本',
          '将「${m.version}」导入为新版本，并开启版本隔离。\n'
              '共 ${m.files.length} 个文件，${formatSize(m.bytes)}。\n\n'
              '${m.parents.isEmpty ? '' : '依赖的原版 ${m.parents.join('、')} 也会一起导入（本机已有时保留本机的）。\n'}'
              '游戏本体依赖的库文件和资源文件没有一起传输，第一次启动时会自动补全。',
        );
        if (ok != true) return;
        final id = await _withProgress(
          '正在导入「${m.version}」',
          (onProgress) => importTransferVersion(t.file.path, m, state.paths.root, onProgress: onProgress),
        );
        await state.refreshVersions();
        _drop(t);
        if (mounted) toast(context, '已导入版本「$id」');
      } else {
        final target = await _pickTarget(state, m);
        if (target == null) return;
        final dir = await state.gameDirOf(target);
        final backup = await _withProgress(
          '正在导入到「${target.id}」',
          (onProgress) => importTransferFiles(
            t.file.path,
            m,
            dir,
            targetVersion: target.id,
            backupDir: p.join(state.paths.root, 'backups', target.id),
            onProgress: onProgress,
          ),
        );
        await state.refreshVersions();
        _drop(t);
        if (mounted) {
          toast(context, backup == null ? '已导入到「${target.id}」' : '已导入到「${target.id}」，原来的内容已备份到 ${p.basename(backup)}');
        }
      }
    } catch (e) {
      if (mounted) toast(context, '导入失败：$e');
    }
  }

  /// 导入时显示不可关闭的进度对话框
  Future<T> _withProgress<T>(String title, Future<T> Function(void Function(int total, int done)) run) async {
    final progress = ValueNotifier<(int, int)?>(null);
    final nav = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: ValueListenableBuilder(
            valueListenable: progress,
            builder: (ctx, v, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v == null ? '正在准备…' : '${formatSize(v.$2)} / ${formatSize(v.$1)}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: v == null || v.$1 == 0 ? null : v.$2 / v.$1),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      return await run((total, done) => progress.value = (total, done));
    } finally {
      nav.pop();
      progress.dispose();
    }
  }

  void _drop(ReceivedTransfer t) {
    if (t.file.existsSync()) t.file.deleteSync();
    if (mounted) setState(() => _received.remove(t));
  }

  Future<bool?> _confirm(String title, String body) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('导入')),
      ],
    ),
  );

  Future<InstanceInfo?> _pickTarget(AppState state, TransferManifest m) {
    final versions = state.versions;
    if (versions.isEmpty) {
      toast(context, '还没有版本，请先安装一个版本再导入');
      return Future.value();
    }
    bool loaderOk(InstanceInfo v) => m.loader == null || v.loader.name == m.loader;
    bool gameOk(InstanceInfo v) => m.gameVersion == null || v.gameVersion == m.gameVersion;
    var chosen =
        versions.where((v) => v.id == m.version && loaderOk(v) && gameOk(v)).firstOrNull ??
        versions.where((v) => loaderOk(v) && gameOk(v)).firstOrNull ??
        versions.where((v) => v.id == m.version).firstOrNull ??
        versions.first;
    String? warning(InstanceInfo v) {
      final from = m.describe ?? '发送方的版本';
      if (!loaderOk(v) && m.items.contains('mods')) {
        return '这些模组来自 $from，但「${v.id}」是 ${describeVersion(v)}，导入后模组不会被加载。'
            '建议先在这台设备上安装相同的加载器，或者让对方改用「整个版本」发送。';
      }
      if (!loaderOk(v)) return '发送方的版本是 $from，「${v.id}」是 ${describeVersion(v)}，加载器不同。';
      if (!gameOk(v)) return '发送方的版本是 $from，「${v.id}」是 ${describeVersion(v)}，游戏版本不同，模组和存档可能不兼容。';
      return null;
    }

    final what = m.items.map((i) => transferItems[i] ?? i).join('、');
    return showDialog<InstanceInfo>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('导入到哪个版本'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<InstanceInfo>(
                isExpanded: true,
                value: chosen,
                items: [for (final v in versions) DropdownMenuItem(value: v, child: Text(v.id))],
                onChanged: (v) => set(() => chosen = v!),
              ),
              const SizedBox(height: 12),
              Text('将替换这个版本的：$what\n原来的内容会先备份到游戏文件夹的 backups 中。'),
              if (warning(chosen) case final w?) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Theme.of(ctx).colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(w, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, chosen), child: const Text('导入')),
          ],
        ),
      ),
    );
  }

  Future<void> _send(AppState state) async {
    final v = _version;
    if (v == null) return toast(context, '请选择要发送的版本');
    final Uri base;
    try {
      base = parseTransferAddress(_address.text);
    } on TransferException catch (e) {
      return toast(context, e.message);
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) return toast(context, '配对码是 6 位数字');
    setState(() {
      _sending = true;
      _sendProgress = null;
      _sendStatus = '正在连接…';
    });
    File? zip;
    try {
      final name = await transferHello(base, _code.text);
      if (!mounted) return;
      setState(() => _sendStatus = '已连接到 $name，正在打包…');
      final gameDir = await state.gameDirOf(v);
      zip = await packTransfer(
        version: v.id,
        versionDir: state.paths.versionDir(v.id),
        gameDir: gameDir,
        wholeVersion: _whole,
        items: _items.toList(),
        loader: v.loader.name,
        gameVersion: v.gameVersion,
        describe: describeVersion(v),
        onFile: (n) {
          if (mounted && n % 50 == 0) setState(() => _sendStatus = '正在打包…已加入 $n 个文件');
        },
      );
      final size = formatSize(zip.lengthSync());
      if (!mounted) return;
      setState(() => _sendStatus = '正在发送 $size…');
      final reply = await transferSend(
        base,
        _code.text,
        zip,
        onProgress: (total, sent) {
          if (mounted) setState(() => _sendProgress = sent / total);
        },
      );
      if (mounted) setState(() => _sendStatus = '发送完成（$size）：$reply');
    } catch (e) {
      if (mounted) setState(() => _sendStatus = '发送失败：$e');
    } finally {
      if (zip != null && zip.existsSync()) zip.deleteSync();
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    _version ??= state.versions.firstOrNull;
    if (_version != null && !state.versions.contains(_version)) _version = state.versions.firstOrNull;
    final server = _server;

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Text('在同一个局域网（同一个 Wi-Fi）中的两台设备之间传输版本、模组、配置和存档。', style: muted),
        const SizedBox(height: 16),
        SettingsGroup(
          title: '接收',
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: server == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_stopReason != null) ...[
                          Text(_stopReason!, style: TextStyle(color: theme.colorScheme.error)),
                          const SizedBox(height: 12),
                        ],
                        Text('开始接收后，在另一台设备上输入下面显示的地址和配对码。离开这个页面会停止接收。', style: muted),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _startReceive,
                          icon: const Icon(Icons.download),
                          label: const Text('开始接收'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('配对码', style: muted),
                        SelectableText(
                          server.code,
                          style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 6, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text('地址（IP:端口）', style: muted),
                        if (_addresses.isEmpty) const Text('没有找到局域网地址，请确认已连接 Wi-Fi 或网线'),
                        for (final a in _addresses)
                          Row(
                            children: [
                              SelectableText('$a:${server.port}', style: theme.textTheme.titleMedium),
                              IconButton(
                                tooltip: '复制',
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: '$a:${server.port}'));
                                  toast(context, '已复制');
                                },
                              ),
                            ],
                          ),
                        if (_addresses.length > 1) Text('有多个地址时，通常用 192.168 开头的那个', style: muted),
                        if (Platform.isWindows) Text('如果 Windows 防火墙弹出提示，请允许 PCL.PW 访问专用网络', style: muted),
                        if (_recvProgress case (final total, final got)) ...[
                          const SizedBox(height: 12),
                          Text('正在接收 ${formatSize(got)} / ${formatSize(total)}'),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: total == 0 ? null : got / total),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _stopReceive,
                          icon: const Icon(Icons.stop),
                          label: const Text('停止接收'),
                        ),
                      ],
                    ),
            ),
            for (final t in _received)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Icon(t.manifest.wholeVersion ? Icons.inventory_2_outlined : Icons.folder_zip_outlined),
                title: Text(
                  t.manifest.wholeVersion
                      ? '整个版本「${t.manifest.version}」'
                      : '「${t.manifest.version}」的${t.manifest.items.map((i) => transferItems[i] ?? i).join('、')}',
                ),
                subtitle: Text(
                  '来自 ${t.manifest.from}（${t.address}）${t.manifest.describe == null ? '' : '，${t.manifest.describe}'}，'
                  '${formatSize(t.manifest.bytes)}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () => _drop(t), child: const Text('删除')),
                    FilledButton.tonal(onPressed: () => _import(state, t), child: const Text('导入')),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: '发送',
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.versions.isEmpty)
                    const Text('还没有可以发送的版本')
                  else
                    DropdownButton<InstanceInfo>(
                      isExpanded: true,
                      value: _version,
                      items: [for (final v in state.versions) DropdownMenuItem(value: v, child: Text(v.id))],
                      onChanged: _sending ? null : (v) => setState(() => _version = v),
                    ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('选择内容'), icon: Icon(Icons.checklist)),
                      ButtonSegment(value: true, label: Text('整个版本'), icon: Icon(Icons.inventory_2_outlined)),
                    ],
                    selected: {_whole},
                    onSelectionChanged: _sending ? null : (s) => setState(() => _whole = s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _whole
                        ? '打包版本文件夹（不含日志和崩溃报告）。对方会导入为新版本并开启版本隔离。'
                              '\n如果这个版本没有开启版本隔离，还会附带下面选中的内容。'
                        : '对方导入时会替换选中的内容，替换前自动备份。',
                    style: muted,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in transferItems.entries)
                        FilterChip(
                          label: Text(e.value),
                          selected: _items.contains(e.key),
                          onSelected: _sending
                              ? null
                              : (on) => setState(() => on ? _items.add(e.key) : _items.remove(e.key)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _address,
                          enabled: !_sending,
                          decoration: const InputDecoration(labelText: '对方地址', hintText: '192.168.1.5:43567'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _code,
                          enabled: !_sending,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(labelText: '配对码', counterText: ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _sending || state.versions.isEmpty ? null : () => _send(state),
                    icon: const Icon(Icons.send),
                    label: const Text('发送'),
                  ),
                  if (_sendStatus != null) ...[const SizedBox(height: 12), Text(_sendStatus!)],
                  if (_sending) ...[const SizedBox(height: 4), LinearProgressIndicator(value: _sendProgress)],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
