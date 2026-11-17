import 'dart:io';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/ai/agent_root.dart';
import '../core/ai/web_tools.dart';
import '../core/instance_files.dart';
import '../pages/file_manager_page.dart';
import '../l10n/l10n.dart';

/// AI 设置里的「工作区」和「联网」部分（在「允许 AI 操作游戏文件」打开时显示）
class AiWorkspaceSettings extends StatefulWidget {
  const AiWorkspaceSettings({super.key});

  @override
  State<AiWorkspaceSettings> createState() => _AiWorkspaceSettingsState();
}

class _AiWorkspaceSettingsState extends State<AiWorkspaceSettings> {
  final _searchUrl = TextEditingController();
  final _searchKey = TextEditingController();
  bool _loaded = false;
  bool _showKey = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _searchUrl.text = AppScope.read(context).config.aiSearchUrl;
    _searchKey.text = SearchKey.load(AppScope.read(context).config.aiSearchEngine);
  }

  @override
  void dispose() {
    _searchUrl.dispose();
    _searchKey.dispose();
    super.dispose();
  }

  Future<void> _addRoot() async {
    final cfg = AppScope.read(context).config;
    final path = await pickFolder(context, confirm: context.l10n.aiWorkspaceSettingsLetAIAccessFolder);
    if (path == null || !mounted) return;
    final dir = Directory(path);
    if (!dir.existsSync()) return;
    final real = dir.resolveSymbolicLinksSync();
    final roots = cfg.aiUserRoots;
    if (roots.any((r) => r['path'] == real)) {
      toast(context, context.l10n.aiWorkspaceSettingsFolderHasAlreadyBeen);
      return;
    }
    // 磁盘根目录等于整个盘都交给 AI，单独确认
    final whole = Directory(real).parent.path == real;
    if (whole) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.aiWorkspaceSettingsAllowAccessWholeDrive),
          content: Text(context.l10n.aiWorkspaceSettingsRootDriveSoAI(real)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.commonCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.aiWorkspaceSettingsAddAnyway),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    final id = newRootId(real, roots.map((r) => '${r['id']}'));
    final label = real.split(RegExp(r'[\\/]')).lastWhere((s) => s.isNotEmpty, orElse: () => real);
    // 默认只读，需要时再在列表里打开「允许修改」
    await cfg.update({
      'aiUserRoots': [
        ...roots,
        {'id': id, 'label': label, 'path': real, 'writable': false},
      ],
    });
  }

  Future<void> _updateRoot(String id, Map<String, dynamic>? change) async {
    final cfg = AppScope.read(context).config;
    await cfg.update({
      'aiUserRoots': [
        for (final r in cfg.aiUserRoots)
          if (r['id'] != id) r else if (change != null) {...r, ...change},
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cfg = AppScope.of(context).config;
    final engine = searchEngines.containsKey(cfg.aiSearchEngine) ? cfg.aiSearchEngine : 'auto';
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.commonAIWorkspace),
          subtitle: Text(context.l10n.aiWorkspaceSettingsAIHasItsOwn),
          value: cfg.aiWorkspace,
          onChanged: (v) => cfg.update({'aiWorkspace': v}),
        ),
        if (cfg.aiWorkspace) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              Platform.isAndroid
                  ? context.l10n.aiWorkspaceSettingsAfterGrantingAllFiles
                  : context.l10n.aiWorkspaceSettingsYouCanAddOther,
              style: muted,
            ),
          ),
          for (final r in cfg.aiUserRoots)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.folder_outlined, color: scheme.primary),
              title: Text('${r['label']}'),
              subtitle: Text('${r['path']}', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.aiWorkspaceSettingsAllowChanges, style: muted),
                  Switch(value: r['writable'] == true, onChanged: (v) => _updateRoot('${r['id']}', {'writable': v})),
                  IconButton(
                    tooltip: context.l10n.aiWorkspaceSettingsRemoveFolderIsntDeleted,
                    onPressed: () => _updateRoot('${r['id']}', null),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _addRoot,
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: Text(context.l10n.versionsAddFolder),
              ),
              TextButton.icon(
                onPressed: () => openInFileManager(aiWorkspaceDir),
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: Text(context.l10n.aiWorkspaceSettingsOpenWorkspace),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.commonWebSearch),
          subtitle: Text(context.l10n.aiWorkspaceSettingsAICanSearchWeb),
          value: cfg.aiWeb,
          onChanged: (v) => cfg.update({'aiWeb': v}),
        ),
        if (cfg.aiWeb) ...[
          DropdownButtonFormField<String>(
            initialValue: engine,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.aiWorkspaceSettingsSearchEngine,
              border: const OutlineInputBorder(),
            ),
            items: [for (final e in searchEngines.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) {
              cfg.update({'aiSearchEngine': v ?? 'auto'});
              // 每个服务的 Key 分开保存，切换后显示对应服务的 Key
              setState(() => _searchKey.text = SearchKey.load(v ?? 'auto'));
            },
          ),
          if (engine == 'searxng') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchUrl,
              decoration: InputDecoration(
                labelText: context.l10n.aiWorkspaceSettingsSearXNGURL,
                hintText: 'https://searx.example.com',
                helperText: context.l10n.aiWorkspaceSettingsInstanceNeedsJSONOutput,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => cfg.update({'aiSearchUrl': v.trim()}),
            ),
          ],
          if (searchEngineTakesKey(engine)) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchKey,
              obscureText: !_showKey,
              decoration: InputDecoration(
                labelText: engine == 'exa'
                    ? context.l10n.aiWorkspaceSettingsExaAPIKeyOptional
                    : context.l10n.aiWorkspaceSettingsSearchServiceAPIKey,
                helperText: engine == 'exa'
                    ? context.l10n.aiWorkspaceSettingsWorksWithoutOneRate
                    : context.l10n.aiWorkspaceSettingsStoredSeparatelyFromModels,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showKey = !_showKey),
                  icon: Icon(_showKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
              onChanged: (v) => SearchKey.save(engine, v),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
