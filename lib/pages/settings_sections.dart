import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/config.dart';
import '../core/java.dart';
import '../core/memory.dart';
import '../widgets/pcl_import_dialog.dart';
import '../widgets/settings_group.dart';

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

class LaunchSection extends StatelessWidget {
  const LaunchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final set = cfg.update;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: '启动',
          children: [
            _SelectRow<int>(
              icon: Icons.call_split,
              title: '版本隔离',
              subtitle: '新版本首次启动时按此规则决定，之后在版本设置中单独修改',
              value: cfg.isolationMode,
              options: isolationModes,
              onChanged: (v) => set({'isolationMode': v}),
            ),
            _SelectRow<String>(
              icon: Icons.crop_landscape,
              title: '游戏窗口',
              value: cfg.windowMode,
              options: const {
                'default': '默认（854 × 480）',
                'launcher': '与启动器一致',
                'maximized': '最大化',
                'fullscreen': '全屏',
                'custom': '自定义大小',
              },
              onChanged: (v) => set({'windowMode': v}),
            ),
            if (cfg.windowMode == 'custom') ...[
              _TextRow(
                icon: Icons.width_normal_outlined,
                title: '窗口宽度',
                value: '${cfg.windowWidth}',
                onSaved: (v) => set({'windowWidth': int.tryParse(v) ?? cfg.windowWidth}),
              ),
              _TextRow(
                icon: Icons.height,
                title: '窗口高度',
                value: '${cfg.windowHeight}',
                onSaved: (v) => set({'windowHeight': int.tryParse(v) ?? cfg.windowHeight}),
              ),
            ],
            _SelectRow<String>(
              icon: Icons.rocket_launch_outlined,
              title: '游戏启动后',
              value: cfg.afterLaunch,
              options: const {
                'keep': '保持不变',
                'minimizeAndReopen': '最小化，游戏退出后恢复',
                'hideAndReopen': '隐藏，游戏退出后恢复',
                'hideAndExit': '隐藏，游戏退出后关闭',
                'exit': '直接关闭启动器',
              },
              onChanged: (v) => set({'afterLaunch': v}),
            ),
            _SelectRow<String>(
              icon: Icons.speed,
              title: '进程优先级',
              value: cfg.processPriority,
              options: const {'high': '高', 'aboveNormal': '较高', 'normal': '中', 'belowNormal': '较低'},
              onChanged: (v) => set({'processPriority': v}),
            ),
            _TextRow(
              icon: Icons.label_outline,
              title: '版本类型显示',
              subtitle: '显示在游戏主界面左下角，留空则不显示',
              value: cfg.versionType,
              onSaved: (v) => set({'versionType': v}),
            ),
            _SwitchRow(
              icon: Icons.translate,
              title: '自动设置游戏语言',
              subtitle: '新版本或没有存档时，把游戏语言设为与启动器一致',
              value: cfg.autoGameLanguage,
              onChanged: (v) => set({'autoGameLanguage': v}),
            ),
          ],
        ),
        const _MemoryGroup(),
        SettingsGroup(
          title: '高级',
          children: [
            _TextRow(
              icon: Icons.code,
              title: 'JVM 参数',
              value: cfg.jvmArgs,
              wide: true,
              onSaved: (v) => set({'jvmArgs': v.trim().isEmpty ? pclDefaultJvmArgs : v}),
            ),
            _TextRow(
              icon: Icons.terminal,
              title: '游戏参数',
              value: cfg.gameArgs,
              hint: '--demo',
              wide: true,
              onSaved: (v) => set({'gameArgs': v}),
            ),
            _TextRow(
              icon: Icons.play_circle_outline,
              title: '启动前执行命令',
              subtitle: '在游戏文件夹中执行',
              value: cfg.preLaunchCommand,
              wide: true,
              onSaved: (v) => set({'preLaunchCommand': v}),
            ),
            _SwitchRow(
              icon: Icons.hourglass_bottom,
              title: '等待命令执行完毕再启动游戏',
              value: cfg.preLaunchWait,
              onChanged: (v) => set({'preLaunchWait': v}),
            ),
            _SelectRow<String>(
              icon: Icons.lan_outlined,
              title: '网络协议偏好',
              value: cfg.preferredIpStack,
              options: const {'default': '默认', 'v4': '优先 IPv4', 'v6': '优先 IPv6'},
              onChanged: (v) => set({'preferredIpStack': v}),
            ),
            _SwitchRow(
              icon: Icons.memory,
              title: '使用高性能显卡',
              subtitle: '仅 Windows：让 Java 使用独立显卡',
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
    return SettingsGroup(
      title: '游戏内存',
      children: [
        ListTile(
          contentPadding: _rowPadding,
          leading: const Icon(Icons.memory_outlined),
          title: const Text('分配方式'),
          subtitle: Text(
            '将分配 ${mem.allocated.toStringAsFixed(1)} GB · '
            '系统空闲 ${mem.free.toStringAsFixed(1)} / ${mem.total.toStringAsFixed(1)} GB',
          ),
          trailing: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'auto', label: Text('自动')),
              ButtonSegment(value: 'custom', label: Text('自定义')),
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
          title: const Text('锁定内存'),
          subtitle: const Text('初始内存与最大内存相同（-Xms 等于 -Xmx）'),
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
    final file = await openFile(
      confirmButtonText: '选择',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Java', extensions: ['exe']),
      ],
    );
    if (file == null || !mounted) return;
    final info = await probeJava(file.path);
    if (!mounted) return;
    if (info == null) return toast(context, '无法运行这个 Java');
    await AppScope.read(context).config.update({'javaPath': file.path});
    setState(() => _javas = listJavas());
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    final scheme = Theme.of(context).colorScheme;
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
                title: const Text('自动选择'),
                subtitle: const Text('按版本要求选择，找不到时自动下载 Mojang 提供的 Java'),
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
                          title: Text('Java ${j.major}（${j.version}）${j.managed ? ' · 启动器下载' : ''}'),
                          subtitle: Text(j.path, overflow: TextOverflow.ellipsis),
                        ),
                      if (cfg.javaPath.isNotEmpty && !paths.contains(cfg.javaPath))
                        RadioListTile<String>(
                          contentPadding: _rowPadding,
                          value: cfg.javaPath,
                          title: const Text('手动指定'),
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
                    OutlinedButton.icon(
                      onPressed: _pick,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('手动选择'),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => setState(() => _javas = listJavas()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新检测'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            '版本设置里可以为单个版本指定 Java，优先于这里的设置。',
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
    final cfg = AppScope.of(context).config;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: 'PCL-CE',
          children: [
            ListTile(
              contentPadding: _rowPadding,
              leading: const Icon(Icons.move_down),
              title: const Text('从 PCL-CE 导入'),
              subtitle: const Text('导入启动设置、游戏文件夹与账户；版本独立设置两者直接共用'),
              trailing: FilledButton.tonal(onPressed: () => showPclImport(context), child: const Text('导入')),
            ),
          ],
        ),
        SettingsGroup(
          title: '下载',
          children: [
            _SelectRow<String>(
              icon: Icons.cloud_download_outlined,
              title: '下载源',
              value: cfg.downloadSource,
              options: const {'official': '官方源', 'bmclapi': 'BMCLAPI 镜像（官方源失败时自动回退）'},
              onChanged: (v) => cfg.update({'downloadSource': v}),
            ),
            ListTile(
              contentPadding: _rowPadding,
              leading: const Icon(Icons.stacked_line_chart),
              title: const Text('同时下载的文件数'),
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
          title: '正版登录',
          children: [
            _TextRow(
              icon: Icons.key_outlined,
              title: 'Azure 应用 Client ID',
              subtitle: '微软登录需要在 Azure 注册一个「个人 Microsoft 账户」类型的公共客户端应用，并开启“允许公共客户端流”',
              value: cfg.msClientId,
              wide: true,
              onSaved: (v) => cfg.update({'msClientId': v.trim()}),
            ),
          ],
        ),
      ],
    );
  }
}
