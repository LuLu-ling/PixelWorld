import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_scope.dart';
import '../app_state.dart';
import '../core/ai/mcp_client.dart';
import '../core/ai/mcp_hub.dart';
import '../pages/file_manager_page.dart' show pickFile;
import '../l10n/l10n.dart';
import '../core/i18n/strings.dart';

/// AI 设置里的「工具服务（MCP）」：内置服务的权限，以及用户添加的外部 MCP 服务
class AiMcpSettings extends StatefulWidget {
  const AiMcpSettings({super.key});

  @override
  State<AiMcpSettings> createState() => _AiMcpSettingsState();
}

class _AiMcpSettingsState extends State<AiMcpSettings> {
  McpHub? _hub;
  bool _probing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final hub = AppScope.read(context).chats.hub;
    if (hub == _hub) return;
    _hub?.statusVersion.removeListener(_changed);
    _hub = hub?..statusVersion.addListener(_changed);
    // 打开这一页时连接一次外部服务，显示工具数或失败原因
    _probe();
  }

  @override
  void dispose() {
    _hub?.statusVersion.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _probe() async {
    final hub = _hub;
    if (hub == null || _probing) return;
    setState(() => _probing = true);
    try {
      await hub.probe();
    } finally {
      if (mounted) setState(() => _probing = false);
    }
  }

  Future<void> _setPolicy(AppState state, String id, McpPolicy policy) => state.config.update({
    'aiMcpPolicy': {...state.config.aiMcpPolicy, id: policy.name},
  });

  Future<void> _saveServers(AppState state, List<McpServerConfig> list) => state.config.update({
    'aiMcpServers': [for (final s in list) s.toJson()],
  });

  Future<void> _edit(AppState state, [McpServerConfig? old]) async {
    final saved = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _McpServerDialog(
        state: state,
        old: old,
        policy: old == null ? McpPolicy.ask : McpPolicy.parse(state.config.aiMcpPolicy[old.id]),
      ),
    );
    if (saved == null) return;
    final list = state.config.aiMcpServers;
    final i = list.indexWhere((s) => s.id == saved.config.id);
    if (i < 0) {
      list.add(saved.config);
    } else {
      list[i] = saved.config;
    }
    await McpSecret.save(saved.config.id, saved.token);
    await _saveServers(state, list);
    await _setPolicy(state, saved.config.id, saved.policy);
    // 新的配置马上连接一次，显示状态
    unawaited(_probe());
  }

  Future<void> _remove(AppState state, McpServerConfig s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiMcpSettingsRemoveMCPService),
        content: Text(context.l10n.aiMcpSettingsRemoveItsSavedAccess(s.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.bgImageRemove)),
        ],
      ),
    );
    if (ok != true) return;
    await McpSecret.save(s.id, '');
    await _saveServers(state, state.config.aiMcpServers.where((x) => x.id != s.id).toList());
    await state.config.update({
      'aiMcpPolicy': {...state.config.aiMcpPolicy}..remove(s.id),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final cfg = state.config;
    final hub = state.chats.hub;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    Widget policyMenu(String id, {bool readOnlyTools = false}) {
      if (readOnlyTools) return Text(context.l10n.aiMcpSettingsReadOnlyActionsOnly, style: muted);
      // 弹出菜单会自动避开屏幕边缘（下拉框贴着右边时菜单会被截掉）
      final current = McpPolicy.parse(cfg.aiMcpPolicy[id]);
      return PopupMenuButton<McpPolicy>(
        initialValue: current,
        tooltip: context.l10n.aiMcpSettingsPermissions,
        onSelected: (v) => _setPolicy(state, id, v),
        itemBuilder: (_) => [for (final p in McpPolicy.values) PopupMenuItem(value: p, child: Text(p.label))],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                current.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: current == McpPolicy.readOnly ? scheme.primary : scheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      );
    }

    final builtins = [
      (id: 'game', icon: Icons.sports_esports_outlined, on: true, readOnly: false),
      (id: 'workspace', icon: Icons.folder_special_outlined, on: cfg.aiWorkspace, readOnly: false),
      (id: 'web', icon: Icons.travel_explore, on: cfg.aiWeb, readOnly: true),
    ];
    final externals = hub?.externals ?? const <ExternalMcpServer>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          context.l10n.aiMcpSettingsToolServicesMCP,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(context.l10n.aiMcpSettingsEverythingAIDoesGoes, style: muted),
        for (final b in builtins)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(b.icon, color: b.on ? scheme.primary : scheme.outline),
            title: Text(hub?.builtins.firstWhere((s) => s.id == b.id).name ?? b.id),
            subtitle: Text(b.on ? context.l10n.commonBuilt : context.l10n.aiMcpSettingsBuiltTurnedOffAbove),
            trailing: policyMenu(b.id, readOnlyTools: b.readOnly),
          ),
        for (final s in externals)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              s.config.isJar ? Icons.coffee_outlined : Icons.cloud_outlined,
              color: s.config.enabled ? scheme.primary : scheme.outline,
            ),
            title: Text(s.name),
            subtitle: Text(
              [
                s.config.isJar ? p.basename(s.config.jar) : s.config.url,
                McpPolicy.parse(cfg.aiMcpPolicy[s.id]).label,
                if (s.config.trusted) context.l10n.aiMcpSettingsTrustReadOnlyClaims,
                if (s.error != null)
                  context.l10n.aiMcpSettingsConnectionFailed(s.error!.split('\n').first)
                else if (s.toolCount != null)
                  context.l10n.commonTools(s.toolCount ?? 0),
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: s.error != null ? TextStyle(color: scheme.error) : null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: s.config.enabled,
                  onChanged: (v) => _saveServers(state, [
                    for (final x in cfg.aiMcpServers) x.id == s.id ? x.copyWith(enabled: v) : x,
                  ]),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? _edit(state, s.config) : _remove(state, s.config),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(context.l10n.aiMcpSettingsEdit)),
                    PopupMenuItem(value: 'remove', child: Text(context.l10n.bgImageRemove)),
                  ],
                ),
              ],
            ),
          ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _edit(state),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.aiMcpSettingsAddMCPService),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _probing ? null : _probe,
              icon: const Icon(Icons.refresh),
              label: Text(_probing ? context.l10n.lanTransferConnecting : context.l10n.aiMcpSettingsRefreshStatus),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditResult {
  const _EditResult(this.config, this.token, this.policy);

  final McpServerConfig config;
  final String token;
  final McpPolicy policy;
}

class _McpServerDialog extends StatefulWidget {
  const _McpServerDialog({required this.state, required this.old, required this.policy});

  final AppState state;
  final McpServerConfig? old;
  final McpPolicy policy;

  @override
  State<_McpServerDialog> createState() => _McpServerDialogState();
}

class _McpServerDialogState extends State<_McpServerDialog> {
  late final _name = TextEditingController(text: widget.old?.displayName ?? '');
  late final _url = TextEditingController(text: widget.old?.url ?? '');
  late final _token = TextEditingController(text: widget.old == null ? '' : McpSecret.load(widget.old!.id));
  late final _jar = TextEditingController(text: widget.old?.jar ?? '');
  late final _args = TextEditingController(text: widget.old?.args.join(' ') ?? '');
  late String _type = widget.old?.type ?? 'http';
  late McpPolicy _policy = widget.policy;
  late bool _trusted = widget.old?.trusted ?? false;
  bool _showToken = false;
  bool _testing = false;
  String? _result;
  bool _ok = false;

  @override
  void dispose() {
    for (final c in [_name, _url, _token, _jar, _args]) {
      c.dispose();
    }
    super.dispose();
  }

  /// 当前填写的配置；有问题时返回说明
  (McpServerConfig?, String?) _build() {
    final name = _name.text.trim();
    if (name.isEmpty) return (null, context.l10n.aiMcpSettingsEnterName);
    if (_type == 'http') {
      final bad = checkMcpUrl(_url.text);
      if (bad != null) return (null, bad);
    } else {
      if (Platform.isAndroid) return (null, context.l10n.aiMcpSettingsLocalJarServicesCant);
      if (!File(_jar.text.trim()).existsSync()) return (null, context.l10n.aiMcpSettingsChooseJarFile);
    }
    final id = widget.old?.id ?? newMcpId(name, widget.state.config.aiMcpServers.map((s) => s.id));
    return (
      McpServerConfig(
        id: id,
        name: name,
        type: _type,
        url: _url.text.trim(),
        jar: _jar.text.trim(),
        args: _args.text.trim().isEmpty ? const [] : _args.text.trim().split(RegExp(r'\s+')),
        enabled: widget.old?.enabled ?? true,
        trusted: _trusted,
      ),
      null,
    );
  }

  Future<void> _test() async {
    final (c, bad) = _build();
    if (c == null) {
      setState(() {
        _result = bad;
        _ok = false;
      });
      return;
    }
    setState(() {
      _testing = true;
      _result = null;
    });
    // 测试用临时 id，令牌只在这次连接中使用
    final probe = McpServerConfig(id: '${c.id}test', name: c.name, type: c.type, url: c.url, jar: c.jar, args: c.args);
    try {
      await McpSecret.save(probe.id, _token.text);
      final r = await testMcpServer(probe, widget.state);
      final names = r.tools.map((t) => t.name).take(8).join(tr.commonListSeparator);
      _ok = true;
      _result = tr.aiMcpSettingsConnectedToolsAvailable(
        r.server.isEmpty ? '' : tr.commonParenthesized(r.server),
        r.tools.length,
        names.isEmpty ? '' : '${tr.commonColon}$names${r.tools.length > 8 ? '…' : ''}',
      );
    } catch (e) {
      _ok = false;
      _result = '$e';
    } finally {
      await McpSecret.save(probe.id, '');
    }
    if (mounted) setState(() => _testing = false);
  }

  Future<void> _pickJar() async {
    final path = await pickFile(context, extensions: const ['jar'], label: context.l10n.aiMcpSettingsJarFile);
    if (path != null) setState(() => _jar.text = path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Text(
        widget.old == null ? context.l10n.aiMcpSettingsAddMCPService : context.l10n.aiMcpSettingsEditMCPService,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: context.l10n.fileManagerName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'http',
                    label: Text(context.l10n.aiMcpSettingsRemoteHTTP),
                    icon: const Icon(Icons.cloud_outlined),
                  ),
                  ButtonSegment(
                    value: 'jar',
                    label: Text(context.l10n.aiMcpSettingsLocalJar),
                    icon: const Icon(Icons.coffee_outlined),
                    enabled: !Platform.isAndroid,
                  ),
                ],
                selected: {_type},
                onSelectionChanged: widget.old == null ? (v) => setState(() => _type = v.first) : null,
              ),
              const SizedBox(height: 12),
              if (_type == 'http') ...[
                TextField(
                  controller: _url,
                  decoration: InputDecoration(
                    labelText: context.l10n.aiMcpSettingsServiceURL,
                    hintText: 'https://example.com/mcp',
                    helperText: context.l10n.aiMcpSettingsRemoteServicesNeedHttps,
                    helperMaxLines: 3,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _token,
                  obscureText: !_showToken,
                  decoration: InputDecoration(
                    labelText: context.l10n.aiMcpSettingsAccessTokenOptional,
                    helperText: context.l10n.aiMcpSettingsStoredEncryptedDeviceOnly,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showToken = !_showToken),
                      icon: Icon(_showToken ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jar,
                        decoration: InputDecoration(
                          labelText: context.l10n.aiMcpSettingsJarFile,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(onPressed: _pickJar, icon: const Icon(Icons.folder_open_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _args,
                  decoration: InputDecoration(
                    labelText: context.l10n.aiMcpSettingsLaunchArgumentsOptional,
                    helperText: context.l10n.aiMcpSettingsSeparatedSpacesAppendedAfter,
                    helperMaxLines: 2,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<McpPolicy>(
                initialValue: _policy,
                decoration: InputDecoration(
                  labelText: context.l10n.aiMcpSettingsPermissions,
                  border: const OutlineInputBorder(),
                ),
                items: [for (final p in McpPolicy.values) DropdownMenuItem(value: p, child: Text(p.label))],
                onChanged: (v) => setState(() => _policy = v ?? McpPolicy.ask),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.aiMcpSettingsTrustServicesReadOnly),
                subtitle: Text(context.l10n.aiMcpSettingsWhenToolsServiceDeclares),
                value: _trusted,
                onChanged: (v) => setState(() => _trusted = v),
              ),
              if (_result != null) ...[
                const SizedBox(height: 12),
                Text(_result!, style: TextStyle(color: _ok ? scheme.primary : scheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _testing ? null : _test,
          child: Text(_testing ? context.l10n.lanTransferConnecting : context.l10n.commonTestConnection),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            final (c, bad) = _build();
            if (c == null) {
              setState(() {
                _result = bad;
                _ok = false;
              });
              return;
            }
            Navigator.pop(context, _EditResult(c, _token.text, _policy));
          },
          child: Text(context.l10n.fileManagerSave),
        ),
      ],
    );
  }
}
