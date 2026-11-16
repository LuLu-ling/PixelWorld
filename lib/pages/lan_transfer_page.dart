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
import '../shell.dart';
import '../widgets/settings_group.dart';
import 'tools_page.dart' show toolsSectionRequest;
import '../l10n/l10n.dart';
import '../core/i18n/strings.dart';

/// 收到但还没导入的传输包；离开页面后仍保留，直到导入、删除或关闭启动器
final _received = <ReceivedTransfer>[];

/// 从实例详情「发送」进来时预先选好的内容（实例、整个实例或哪些内容），打开页面后清空
final lanTransferRequest = ValueNotifier<({String instance, bool whole, Set<String>? items})?>(null);

/// 打开「工具 → 局域网互传」，并选好要发送的实例和内容
void openLanTransfer(BuildContext context, {required String instance, bool whole = false, Set<String>? items}) {
  lanTransferRequest.value = (instance: instance, whole: whole, items: items);
  toolsSectionRequest.value = 'transfer';
  ShellNav.of(context).goMain(MainPage.tools);
}

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
  ({String instance, bool whole, Set<String>? items})? _preset;

  @override
  void initState() {
    super.initState();
    _preset = lanTransferRequest.value;
    lanTransferRequest.value = null;
    if (_preset != null) {
      _whole = _preset!.whole;
      if (_preset!.items != null) {
        _items
          ..clear()
          ..addAll(_preset!.items!);
      }
    }
  }

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
          toast(context, context.l10n.lanTransferReceivedFrom(t.manifest.from, t.manifest.version));
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
      if (mounted) toast(context, context.l10n.lanTransferCouldntStartReceiving(e));
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
          context.l10n.lanTransferImportAsNewInstance,
          context.l10n.lanTransferImportAsNewInstance2(
            m.version,
            m.files.length,
            formatSize(m.bytes),
            m.parents.isEmpty
                ? ''
                : context.l10n.lanTransferVanillaVersionDependsImported(
                    m.parents.join(context.l10n.commonListSeparator),
                  ),
          ),
        );
        if (ok != true) return;
        final id = await _withProgress(
          tr.lanTransferImporting(m.version),
          (onProgress) => importTransferVersion(t.file.path, m, state.paths.root, onProgress: onProgress),
        );
        await state.refreshVersions();
        _drop(t);
        if (mounted) toast(context, context.l10n.lanTransferImportedInstance(id));
      } else {
        final target = await _pickTarget(state, m);
        if (target == null) return;
        final dir = await state.gameDirOf(target);
        final backup = await _withProgress(
          tr.lanTransferImportingInto(target.id),
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
          toast(
            context,
            backup == null
                ? context.l10n.lanTransferImportedInto(target.id)
                : context.l10n.lanTransferImportedIntoPreviousContents(target.id, p.basename(backup)),
          );
        }
      }
    } catch (e) {
      if (mounted) toast(context, context.l10n.lanTransferImportFailed(e));
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
                Text(v == null ? context.l10n.lanTransferPreparing : '${formatSize(v.$2)} / ${formatSize(v.$1)}'),
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
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.pclImportButton)),
      ],
    ),
  );

  Future<InstanceInfo?> _pickTarget(AppState state, TransferManifest m) {
    final versions = state.versions;
    if (versions.isEmpty) {
      toast(context, context.l10n.lanTransferNoInstancesYetInstall);
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
      final from = m.describe ?? context.l10n.lanTransferSendersInstance;
      if (!loaderOk(v) && m.items.contains('mods')) {
        return context.l10n.lanTransferTheseModsComeFrom(from, v.id, describeVersion(v));
      }
      if (!loaderOk(v)) return context.l10n.lanTransferSendersInstanceLoadersDiffer(from, v.id, describeVersion(v));
      if (!gameOk(v)) return context.l10n.lanTransferSendersInstanceGameVersions(from, v.id, describeVersion(v));
      return null;
    }

    final what = m.items.map((i) => transferItems[i] ?? i).join(context.l10n.commonListSeparator);
    return showDialog<InstanceInfo>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(context.l10n.lanTransferImportIntoWhichInstance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<InstanceInfo>(
                // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
                focusColor: Colors.transparent,
                isExpanded: true,
                value: chosen,
                items: [for (final v in versions) DropdownMenuItem(value: v, child: Text(v.id))],
                onChanged: (v) => set(() => chosen = v!),
              ),
              const SizedBox(height: 12),
              Text(context.l10n.lanTransferReplacesInstancesPreviousContents(what)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, chosen), child: Text(context.l10n.pclImportButton)),
          ],
        ),
      ),
    );
  }

  Future<void> _send(AppState state) async {
    final v = _version;
    if (v == null) return toast(context, context.l10n.lanTransferChooseInstanceSend);
    final Uri base;
    try {
      base = parseTransferAddress(_address.text);
    } on TransferException catch (e) {
      return toast(context, e.message);
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      return toast(context, context.l10n.lanTransferPairingCode6Digits);
    }
    setState(() {
      _sending = true;
      _sendProgress = null;
      _sendStatus = context.l10n.lanTransferConnecting;
    });
    File? zip;
    try {
      final name = await transferHello(base, _code.text);
      if (!mounted) return;
      setState(() => _sendStatus = context.l10n.lanTransferConnectedPacking(name));
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
          if (mounted && n % 50 == 0) setState(() => _sendStatus = context.l10n.lanTransferPackingFilesAdded(n));
        },
      );
      final size = formatSize(zip.lengthSync());
      if (!mounted) return;
      setState(() => _sendStatus = context.l10n.lanTransferSending(size));
      final reply = await transferSend(
        base,
        _code.text,
        zip,
        onProgress: (total, sent) {
          if (mounted) setState(() => _sendProgress = sent / total);
        },
      );
      if (mounted) setState(() => _sendStatus = context.l10n.lanTransferSent(size, reply));
    } catch (e) {
      if (mounted) setState(() => _sendStatus = context.l10n.lanTransferSendingFailed(e));
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
    if (_preset != null) {
      _version = state.instance(_preset!.instance) ?? _version;
      _preset = null;
    }
    _version ??= state.versions.firstOrNull;
    if (_version != null && !state.versions.contains(_version)) _version = state.versions.firstOrNull;
    final server = _server;

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Text(context.l10n.lanTransferTransferInstancesModsConfigs, style: muted),
        const SizedBox(height: 16),
        SettingsGroup(
          title: context.l10n.lanTransferReceive,
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
                        Text(context.l10n.lanTransferAfterYouStartReceiving, style: muted),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _startReceive,
                          icon: const Icon(Icons.download),
                          label: Text(context.l10n.lanTransferStartReceiving),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.lanTransferPairingCode, style: muted),
                        SelectableText(
                          server.code,
                          style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 6, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(context.l10n.lanTransferAddressIPPort, style: muted),
                        if (_addresses.isEmpty) Text(context.l10n.lanTransferNoLocalNetworkAddress),
                        for (final a in _addresses)
                          Row(
                            children: [
                              SelectableText('$a:${server.port}', style: theme.textTheme.titleMedium),
                              IconButton(
                                tooltip: context.l10n.commonCopy,
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: '$a:${server.port}'));
                                  toast(context, context.l10n.fileViewerCopied);
                                },
                              ),
                            ],
                          ),
                        if (_addresses.length > 1) Text(context.l10n.lanTransferIfThereSeveralAddresses, style: muted),
                        if (Platform.isWindows) Text(context.l10n.lanTransferIfWindowsFirewallAsks, style: muted),
                        if (_recvProgress case (final total, final got)) ...[
                          const SizedBox(height: 12),
                          Text(context.l10n.lanTransferReceiving(formatSize(got), formatSize(total))),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: total == 0 ? null : got / total),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _stopReceive,
                          icon: const Icon(Icons.stop),
                          label: Text(context.l10n.lanTransferStopReceiving),
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
                      ? context.l10n.lanTransferWholeInstance(t.manifest.version)
                      : context.l10n.lanTransferText(
                          t.manifest.version,
                          t.manifest.items.map((i) => transferItems[i] ?? i).join(context.l10n.commonListSeparator),
                        ),
                ),
                subtitle: Text(
                  context.l10n.lanTransferFrom(
                    t.manifest.from,
                    t.address,
                    t.manifest.describe == null ? '' : '${context.l10n.commonComma}${t.manifest.describe}',
                    formatSize(t.manifest.bytes),
                  ),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(onPressed: () => _drop(t), child: Text(context.l10n.commonDelete)),
                    FilledButton.tonal(onPressed: () => _import(state, t), child: Text(context.l10n.pclImportButton)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: context.l10n.instanceSend,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.versions.isEmpty)
                    Text(context.l10n.lanTransferNoInstancesSendYet)
                  else
                    DropdownButton<InstanceInfo>(
                      // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
                      focusColor: Colors.transparent,
                      isExpanded: true,
                      value: _version,
                      items: [for (final v in state.versions) DropdownMenuItem(value: v, child: Text(v.id))],
                      onChanged: _sending ? null : (v) => setState(() => _version = v),
                    ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(context.l10n.lanTransferChooseContent),
                        icon: const Icon(Icons.checklist),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(context.l10n.lanTransferWholeInstance2),
                        icon: const Icon(Icons.inventory_2_outlined),
                      ),
                    ],
                    selected: {_whole},
                    onSelectionChanged: _sending ? null : (s) => setState(() => _whole = s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _whole
                        ? context.l10n.lanTransferPacksInstanceFolderWithout
                        : context.l10n.lanTransferReceiverReplacesSelectedContent,
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
                          decoration: InputDecoration(
                            labelText: context.l10n.lanTransferReceiversAddress,
                            hintText: '192.168.1.5:43567',
                          ),
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
                          decoration: InputDecoration(labelText: context.l10n.lanTransferPairingCode, counterText: ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _sending || state.versions.isEmpty ? null : () => _send(state),
                    icon: const Icon(Icons.send),
                    label: Text(context.l10n.instanceSend),
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
