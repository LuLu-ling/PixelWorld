import 'dart:io';

import '../core/android_storage.dart';
import 'file_manager_page.dart';

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../app_state.dart' show GameState;
import '../core/android_runtime.dart';
import '../core/config.dart';
import '../core/i18n/change_language_command.dart';
import '../core/java.dart';
import '../core/memory.dart';
import '../core/task.dart';
import '../core/updater.dart';
import '../l10n/l10n.dart';
import '../platform.dart';
import '../widgets/format.dart';
import '../widgets/maintenance_actions.dart';
import '../widgets/pcl_import_dialog.dart';
import '../widgets/settings_group.dart';
import '../widgets/update_dialog.dart';

// ---------- 通用设置行 ----------

const _rowPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 8);

class _SelectRow<T> extends StatelessWidget {
  const _SelectRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: _rowPadding,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: DropdownMenu<T>(
        // 只在创建时读取 initialSelection；所选项的文字变了（例如切换语言）时重新创建
        key: ValueKey(options[value]),
        width: 240,
        initialSelection: value,
        requestFocusOnTap: false,
        inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
        dropdownMenuEntries: [for (final e in options.entries) DropdownMenuEntry(value: e.key, label: e.value)],
        onSelected: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: _rowPadding,
    secondary: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
  );
}

/// 文本设置：失去焦点或按回车时保存
class _TextRow extends StatefulWidget {
  const _TextRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onSaved,
    this.hint,
    this.wide = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String value;
  final String? hint;
  final bool wide;
  final ValueChanged<String> onSaved;

  @override
  State<_TextRow> createState() => _TextRowState();
}

class _TextRowState extends State<_TextRow> {
  late final _c = TextEditingController(text: widget.value);
  late final FocusNode _focus = FocusNode()..addListener(() => _focus.hasFocus ? null : _save());

  void _save() {
    if (_c.text != widget.value) widget.onSaved(_c.text);
  }

  @override
  void didUpdateWidget(_TextRow old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: _c,
      focusNode: _focus,
      onSubmitted: (_) => _save(),
      decoration: InputDecoration(hintText: widget.hint, isDense: true, border: const OutlineInputBorder()),
    );
    if (!widget.wide) {
      return ListTile(
        contentPadding: _rowPadding,
        leading: Icon(widget.icon),
        title: Text(widget.title),
        subtitle: widget.subtitle == null ? null : Text(widget.subtitle!),
        trailing: SizedBox(width: 240, child: field),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(widget.icon)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.bodyLarge),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 8),
                field,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- 启动 ----------

/// 安卓：渲染比例。降低后画面更模糊，但帧率更高、发热更少
class _RenderScaleRow extends StatefulWidget {
  const _RenderScaleRow();

  @override
  State<_RenderScaleRow> createState() => _RenderScaleRowState();
}

class _RenderScaleRowState extends State<_RenderScaleRow> {
  double? _value;

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    final value = _value ?? cfg.renderScale;
    // 屏幕的实际像素（横屏），与界面缩放无关
    final screen = View.of(context).physicalSize;
    final w = (screen.longestSide * value).round(), h = (screen.shortestSide * value).round();
    final l = context.l10n;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: const Icon(Icons.aspect_ratio),
      title: Text(l.renderScale((value * 100).round())),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.renderScaleHint(w, h)),
          Slider(
            value: value,
            min: 0.25,
            max: 1,
            divisions: 15,
            label: '${(value * 100).round()}%',
            onChanged: (v) => setState(() => _value = v),
            onChangeEnd: (v) async {
              await cfg.update({'renderScale': v});
              if (mounted) setState(() => _value = null);
            },
          ),
        ],
      ),
    );
  }
}

/// 安卓：渲染器，并显示识别到的显卡与「自动」实际会选的渲染器
class _RendererRow extends StatefulWidget {
  const _RendererRow();

  @override
  State<_RendererRow> createState() => _RendererRowState();
}

class _RendererRowState extends State<_RendererRow> {
  AndroidGpu? _gpu;

  @override
  void initState() {
    super.initState();
    androidGpu().then((g) => mounted ? setState(() => _gpu = g) : null).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    final pref = cfg.androidRenderer;
    final gpu = _gpu;
    final auto = gpu == null ? null : resolveAndroidRenderer('auto', gpu);
    final l = context.l10n;
    return ListTile(
      contentPadding: _rowPadding,
      leading: const Icon(Icons.memory),
      title: Text(l.renderer),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(androidRendererHints[pref] ?? ''),
          if (gpu != null) Text(l.rendererGpu('$gpu')),
          if (pref == 'auto' && auto != null) Text(l.rendererAuto('${androidRenderers[auto.renderer]}', auto.reason)),
          Text(l.rendererPerInstance),
        ],
      ),
      trailing: DropdownMenu<String>(
        width: 240,
        initialSelection: pref,
        requestFocusOnTap: false,
        inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
        dropdownMenuEntries: [
          for (final e in androidRenderers.entries) DropdownMenuEntry(value: e.key, label: e.value),
        ],
        onSelected: (v) => v == null ? null : cfg.update({'androidRenderer': v}),
      ),
    );
  }
}

class LaunchSection extends StatelessWidget {
  const LaunchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final set = cfg.update;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: l.settingsLaunch,
          children: [
            _SelectRow<int>(
              icon: Icons.call_split,
              title: l.isolation,
              subtitle: l.isolationHint,
              value: cfg.isolationMode,
              options: {for (final m in isolationModes) m: l.isolationMode(m)},
              onChanged: (v) => set({'isolationMode': v}),
            ),
            // 手机上游戏总是全屏，调的是渲染分辨率
            if (!isDesktop) const _RenderScaleRow(),
            if (Platform.isAndroid) const _RendererRow(),
            if (Platform.isAndroid)
              _SwitchRow(
                icon: Icons.dashboard_outlined,
                title: l.gameHud,
                subtitle: l.gameHudHint,
                value: cfg.gameHud,
                onChanged: (v) => set({'gameHud': v}),
              ),
            if (Platform.isAndroid && cfg.gameHud)
              _SwitchRow(
                icon: Icons.auto_awesome_outlined,
                title: l.gameHudAi,
                subtitle: l.gameHudAiHint,
                value: cfg.gameHudAi,
                onChanged: (v) => set({'gameHudAi': v}),
              ),
            if (Platform.isAndroid && cfg.gameHud && cfg.gameHudAi)
              _SwitchRow(
                icon: Icons.article_outlined,
                title: l.gameHudAiLog,
                subtitle: l.gameHudAiLogHint,
                value: cfg.gameHudAiLog,
                onChanged: (v) => set({'gameHudAiLog': v}),
              ),
            if (isDesktop)
              _SelectRow<String>(
                icon: Icons.crop_landscape,
                title: l.gameWindow,
                value: cfg.windowMode,
                options: {
                  'default': l.gameWindowDefault,
                  'launcher': l.gameWindowLauncher,
                  'maximized': l.gameWindowMaximized,
                  'fullscreen': l.gameWindowFullscreen,
                  'custom': l.gameWindowCustom,
                },
                onChanged: (v) => set({'windowMode': v}),
              ),
            if (isDesktop && cfg.windowMode == 'custom') ...[
              _TextRow(
                icon: Icons.width_normal_outlined,
                title: l.gameWindowWidth,
                value: '${cfg.windowWidth}',
                onSaved: (v) => set({'windowWidth': int.tryParse(v) ?? cfg.windowWidth}),
              ),
              _TextRow(
                icon: Icons.height,
                title: l.gameWindowHeight,
                value: '${cfg.windowHeight}',
                onSaved: (v) => set({'windowHeight': int.tryParse(v) ?? cfg.windowHeight}),
              ),
            ],
            // 以下两项只对桌面端的游戏进程有效
            if (isDesktop)
              _SelectRow<String>(
                icon: Icons.rocket_launch_outlined,
                title: l.afterLaunch,
                value: cfg.afterLaunch,
                options: {
                  'keep': l.afterLaunchKeep,
                  'minimizeAndReopen': l.afterLaunchMinimize,
                  'hideAndReopen': l.afterLaunchHide,
                  'hideAndExit': l.afterLaunchHideExit,
                  'exit': l.afterLaunchExit,
                },
                onChanged: (v) => set({'afterLaunch': v}),
              ),
            if (isDesktop)
              _SelectRow<String>(
                icon: Icons.speed,
                title: l.priority,
                value: cfg.processPriority,
                options: {
                  'high': l.priorityHigh,
                  'aboveNormal': l.priorityAboveNormal,
                  'normal': l.priorityNormal,
                  'belowNormal': l.priorityBelowNormal,
                },
                onChanged: (v) => set({'processPriority': v}),
              ),
            _TextRow(
              icon: Icons.label_outline,
              title: l.versionType,
              subtitle: l.versionTypeHint,
              value: cfg.versionType,
              onSaved: (v) => set({'versionType': v}),
            ),
            _SwitchRow(
              icon: Icons.translate,
              title: l.autoGameLanguage,
              subtitle: l.autoGameLanguageHint,
              value: cfg.autoGameLanguage,
              onChanged: (v) => set({'autoGameLanguage': v}),
            ),
          ],
        ),
        const _MemoryGroup(),
        SettingsGroup(
          title: l.advanced,
          children: [
            _TextRow(
              icon: Icons.code,
              title: l.jvmArgs,
              value: cfg.jvmArgs,
              wide: true,
              onSaved: (v) => set({'jvmArgs': v.trim().isEmpty ? defaultJvmArgs : v}),
            ),
            _TextRow(
              icon: Icons.terminal,
              title: l.gameArgs,
              value: cfg.gameArgs,
              hint: '--demo',
              wide: true,
              onSaved: (v) => set({'gameArgs': v}),
            ),
            _TextRow(
              icon: Icons.play_circle_outline,
              title: l.preLaunchCommand,
              subtitle: l.preLaunchCommandHint,
              value: cfg.preLaunchCommand,
              wide: true,
              onSaved: (v) => set({'preLaunchCommand': v}),
            ),
            _SwitchRow(
              icon: Icons.hourglass_bottom,
              title: l.preLaunchWait,
              value: cfg.preLaunchWait,
              onChanged: (v) => set({'preLaunchWait': v}),
            ),
            _SelectRow<String>(
              icon: Icons.lan_outlined,
              title: l.ipStack,
              value: cfg.preferredIpStack,
              options: {'default': l.commonDefault, 'v4': l.ipStackV4, 'v6': l.ipStackV6},
              onChanged: (v) => set({'preferredIpStack': v}),
            ),
            _SwitchRow(
              icon: Icons.memory,
              title: l.gpuPreference,
              subtitle: l.gpuPreferenceHint,
              value: cfg.gpuPreference,
              onChanged: (v) => set({'gpuPreference': v}),
            ),
          ],
        ),
      ],
    );
  }
}

/// 游戏内存：自动分配或按 PCL 的刻度自定义
class _MemoryGroup extends StatelessWidget {
  const _MemoryGroup();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final theme = Theme.of(context);
    final mem = state.memoryPreview();
    final maxTick = maxTickFor(mem.total);
    final tick = cfg.memoryTick.clamp(1, maxTick);
    final l = context.l10n;
    return SettingsGroup(
      title: l.memory,
      children: [
        ListTile(
          contentPadding: _rowPadding,
          leading: const Icon(Icons.memory_outlined),
          title: Text(l.memoryMode),
          subtitle: Text(
            l.memorySummary(
              mem.allocated.toStringAsFixed(1),
              mem.free.toStringAsFixed(1),
              mem.total.toStringAsFixed(1),
            ),
          ),
          trailing: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'auto', label: Text(l.commonAuto)),
              ButtonSegment(value: 'custom', label: Text(l.commonCustom)),
            ],
            selected: {cfg.memoryMode},
            onSelectionChanged: (s) => cfg.update({'memoryMode': s.first}),
          ),
        ),
        if (cfg.memoryMode == 'custom')
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Slider(
                    value: tick.toDouble(),
                    min: 1,
                    max: maxTick.toDouble(),
                    divisions: maxTick > 1 ? maxTick - 1 : null,
                    label: '${ramFromTick(tick).toStringAsFixed(1)} GB',
                    onChanged: (v) => cfg.update({'memoryTick': v.round()}),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    '${ramFromTick(tick).toStringAsFixed(1)} GB',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        SwitchListTile(
          contentPadding: _rowPadding,
          secondary: const Icon(Icons.lock_outline),
          title: Text(l.memoryLock),
          subtitle: Text(l.memoryLockHint),
          value: cfg.lockMemory,
          onChanged: (v) => cfg.update({'lockMemory': v}),
        ),
      ],
    );
  }
}

// ---------- Java ----------

class JavaSection extends StatefulWidget {
  const JavaSection({super.key});

  @override
  State<JavaSection> createState() => _JavaSectionState();
}

class _JavaSectionState extends State<JavaSection> {
  late Future<List<JavaInfo>> _javas = listJavas();

  Future<void> _pick() async {
    final path = await pickFile(
      context,
      label: 'Java',
      extensions: Platform.isWindows ? const ['exe'] : null,
      start: Platform.isAndroid ? AndroidStorage.root : null,
    );
    if (path == null || !mounted) return;
    final info = await probeJava(path);
    if (!mounted) return;
    if (info == null) return toast(context, context.l10n.javaUnusable);
    await AppScope.read(context).config.update({'javaPath': path});
    setState(() => _javas = listJavas());
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) return const _AndroidJavaSection();
    final cfg = AppScope.of(context).config;
    final scheme = Theme.of(context).colorScheme;
    final l = context.l10n;
    return RadioGroup<String>(
      groupValue: cfg.javaPath,
      onChanged: (v) => cfg.update({'javaPath': v ?? ''}),
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          SettingsGroup(
            title: 'Java',
            children: [
              RadioListTile<String>(
                contentPadding: _rowPadding,
                value: '',
                title: Text(l.javaAuto),
                subtitle: Text(l.javaAutoHint),
              ),
              FutureBuilder(
                future: _javas,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator());
                  }
                  final list = snap.data!;
                  final paths = {for (final j in list) j.path};
                  return Column(
                    children: [
                      for (final j in list)
                        RadioListTile<String>(
                          contentPadding: _rowPadding,
                          value: j.path,
                          title: Text([l.javaEntry(j.major, j.version), if (j.managed) l.javaManaged].join(' · ')),
                          subtitle: Text(j.path, overflow: TextOverflow.ellipsis),
                        ),
                      if (cfg.javaPath.isNotEmpty && !paths.contains(cfg.javaPath))
                        RadioListTile<String>(
                          contentPadding: _rowPadding,
                          value: cfg.javaPath,
                          title: Text(l.javaManual),
                          subtitle: Text(cfg.javaPath, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.folder_open), label: Text(l.javaPick)),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => setState(() => _javas = listJavas()),
                      icon: const Icon(Icons.refresh),
                      label: Text(l.javaRescan),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            l.javaPerInstance,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------- 其他 ----------

class MiscSection extends StatelessWidget {
  const MiscSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final l = context.l10n;
    final commit = AppInfo.commit.substring(0, AppInfo.commit.length.clamp(0, 7));
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: l.languageGroup,
          children: [
            _SelectRow<AppLanguage>(
              icon: Icons.translate,
              title: l.language,
              subtitle: l.languageHint,
              value: state.language.current,
              options: {for (final lang in AppLanguage.values) lang: lang.label(l)},
              onChanged: (v) => ChangeLanguageCommand(state.language, v).execute(),
            ),
          ],
        ),
        SettingsGroup(
          title: l.updates,
          children: [
            _SelectRow<UpdateChannel>(
              icon: Icons.alt_route,
              title: l.updateChannel,
              subtitle: l.updateChannelHint,
              value: UpdateChannel.parse(cfg.updateChannel),
              options: {
                for (final c in UpdateChannel.values)
                  c: switch (c) {
                    UpdateChannel.stable => l.updateChannelStable,
                    UpdateChannel.preview => l.updateChannelPreview,
                    UpdateChannel.nightly => c.label,
                  },
              },
              onChanged: (v) => cfg.update({'updateChannel': v.name, 'updateSkipped': ''}),
            ),
            _SwitchRow(
              icon: Icons.update,
              title: l.updateAutoCheck,
              value: cfg.updateAutoCheck,
              onChanged: (v) => cfg.update({'updateAutoCheck': v}),
            ),
            ListTile(
              contentPadding: _rowPadding,
              leading: const Icon(Icons.system_update_alt),
              title: Text(l.updateCheck),
              subtitle: Text(
                AppInfo.commit.isEmpty
                    ? l.updateCurrentLocal(AppInfo.version)
                    : l.updateCurrentBuild(AppInfo.version, AppInfo.channel, commit),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => checkUpdates(context, manual: true),
                child: Text(l.updateCheckButton),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'PCL-CE',
          children: [
            ListTile(
              contentPadding: _rowPadding,
              leading: const Icon(Icons.move_down),
              title: Text(l.pclImport),
              subtitle: Text(l.pclImportHint),
              trailing: FilledButton.tonal(onPressed: () => showPclImport(context), child: Text(l.pclImportButton)),
            ),
          ],
        ),
        if (Platform.isWindows)
          SettingsGroup(
            title: l.system,
            children: [
              ListTile(
                contentPadding: _rowPadding,
                leading: const Icon(Icons.shortcut),
                title: Text(l.shortcut),
                subtitle: Text(l.shortcutHint),
                trailing: FilledButton.tonal(
                  onPressed: () => createShortcutWithToast(context),
                  child: Text(l.shortcutButton),
                ),
              ),
            ],
          ),
        SettingsGroup(
          title: l.commonDownload,
          children: [
            _SelectRow<String>(
              icon: Icons.cloud_download_outlined,
              title: l.downloadSource,
              value: cfg.downloadSource,
              options: {'official': l.downloadSourceOfficial, 'bmclapi': l.downloadSourceMirror},
              onChanged: (v) => cfg.update({'downloadSource': v}),
            ),
            ListTile(
              contentPadding: _rowPadding,
              leading: const Icon(Icons.stacked_line_chart),
              title: Text(l.downloadConcurrency),
              trailing: SizedBox(
                width: 240,
                child: Slider(
                  value: cfg.concurrency.clamp(1, 64).toDouble(),
                  min: 1,
                  max: 64,
                  divisions: 63,
                  label: '${cfg.concurrency}',
                  onChanged: (v) => cfg.update({'concurrency': v.round()}),
                ),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: l.msLogin,
          children: [
            _TextRow(
              icon: Icons.key_outlined,
              title: l.msClientId,
              subtitle: l.msClientIdHint,
              // 只显示用户自己填的 ID；内置 ID 不回显到输入框
              value: cfg.msClientId,
              hint: AppInfo.msClientId.isEmpty ? l.msClientIdEmpty : l.msClientIdBuiltIn,
              wide: true,
              onSaved: (v) => cfg.update({'msClientId': v.trim()}),
            ),
          ],
        ),
      ],
    );
  }
}

/// 安卓上的 Java：启动器提供的安卓版 Java 8 / 17 / 21 / 25，可以下载、删除和固定使用其中一个
class _AndroidJavaSection extends StatefulWidget {
  const _AndroidJavaSection();

  @override
  State<_AndroidJavaSection> createState() => _AndroidJavaSectionState();
}

class _AndroidJavaSectionState extends State<_AndroidJavaSection> {
  final _sizes = <int, int>{};
  final _busy = <int>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    for (final m in androidJavaMajors) {
      final installed = androidJavaAt(androidJavaHome(m)) != null;
      final size = installed ? await folderSize(androidJavaHome(m)) : null;
      if (!mounted) return;
      setState(() => size == null ? _sizes.remove(m) : _sizes[m] = size);
    }
  }

  Future<void> _download(int major) async {
    final state = AppScope.read(context);
    final existed = androidJavaAt(androidJavaHome(major)) != null;
    final l = context.l10n;
    final step = l.commonDownload;
    final t = TaskProgress(l.javaAndroidTask(major), steps: [step], canCancel: true);
    if (!existed) t.registerCleanupPath(androidJavaHome(major));
    setState(() => _busy.add(major));
    try {
      await state.track(t, () async {
        t.beginStep(step);
        await installAndroidJava(major, state.downloader, t);
      });
    } catch (e) {
      if (mounted) toast(context, l.javaDownloadFailed(major, errorText(e)));
    } finally {
      if (mounted) setState(() => _busy.remove(major));
      await _refresh();
    }
  }

  Future<void> _delete(int major) async {
    final state = AppScope.read(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.javaDeleteTitle(major)),
        content: Text(context.l10n.javaDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy.add(major));
    try {
      await deleteAndroidJava(major);
      if (state.config.javaPath == androidJavaHome(major)) await state.config.update({'javaPath': ''});
    } catch (e) {
      if (mounted) toast(context, context.l10n.commonDeleteFailed(errorText(e)));
    } finally {
      if (mounted) setState(() => _busy.remove(major));
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final scheme = Theme.of(context).colorScheme;
    // 游戏或安装器运行时不能删除 Java
    final inUse = state.gameState != GameState.idle || state.runningTasks.isNotEmpty;
    final l = context.l10n;
    return RadioGroup<String>(
      groupValue: cfg.javaPath,
      onChanged: (v) => cfg.update({'javaPath': v ?? ''}),
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          SettingsGroup(
            title: 'Java',
            children: [
              RadioListTile<String>(
                contentPadding: _rowPadding,
                value: '',
                title: Text(l.javaAuto),
                subtitle: Text(l.javaAndroidAutoHint),
              ),
              for (final m in androidJavaMajors)
                if (_sizes.containsKey(m))
                  RadioListTile<String>(
                    contentPadding: _rowPadding,
                    value: androidJavaHome(m),
                    title: Text('Java $m'),
                    subtitle: Text(l.javaInstalled(formatSize(_sizes[m]!))),
                    secondary: _busy.contains(m)
                        ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            tooltip: inUse ? l.javaInUse : l.commonDelete,
                            onPressed: inUse ? null : () => _delete(m),
                            icon: const Icon(Icons.delete_outline),
                          ),
                  )
                else
                  ListTile(
                    contentPadding: _rowPadding,
                    leading: const SizedBox(width: 24),
                    title: Text('Java $m'),
                    subtitle: Text(l.javaNotInstalled),
                    trailing: _busy.contains(m)
                        ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : FilledButton.tonal(onPressed: () => _download(m), child: Text(l.commonDownload)),
                  ),
              if (cfg.javaPath.isNotEmpty && !androidJavaMajors.any((m) => androidJavaHome(m) == cfg.javaPath))
                RadioListTile<String>(
                  contentPadding: _rowPadding,
                  value: cfg.javaPath,
                  title: Text(l.javaManualAndroid),
                  subtitle: Text(cfg.javaPath, overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
          Text(
            l.javaAndroidNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
