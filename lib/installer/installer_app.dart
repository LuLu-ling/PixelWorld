import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import '../app_info.dart';
import '../shell.dart' show AppLogo;
import '../theme.dart';
import '../widgets/window_buttons.dart';
import 'installer_core.dart';

/// 安装 / 卸载界面
Future<void> runInstaller(InstallerMode mode, List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final window = WindowManager.instance.getCurrent()!;
  window.title = mode == InstallerMode.install ? '安装 ${AppInfo.name}' : '卸载 ${AppInfo.name}';
  window.titleBarStyle = TitleBarStyle.hidden;
  window.isWindowControlButtonsVisible = false;
  window.isResizable = false;
  window.isMaximizable = false;
  window.setSize(const Size(640, 470).toNative(), false);
  window.center();
  runApp(InstallerApp(mode: mode, args: args));
  // 首帧画完再显示窗口，并告诉外壳可以收起加载动画了
  WidgetsBinding.instance.addPostFrameCallback((_) {
    window.show();
    window.focus();
    final ready = argValue(args, 'pw-ready');
    if (ready != null) File(ready).writeAsStringSync('');
  });
}

class InstallerApp extends StatelessWidget {
  const InstallerApp({super.key, required this.mode, required this.args});

  final InstallerMode mode;
  final List<String> args;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: _InstallerPage(mode: mode, args: args),
    );
  }
}

enum _Step { form, working, done, failed }

class _InstallerPage extends StatefulWidget {
  const _InstallerPage({required this.mode, required this.args});

  final InstallerMode mode;
  final List<String> args;

  @override
  State<_InstallerPage> createState() => _InstallerPageState();
}

class _InstallerPageState extends State<_InstallerPage> {
  late String _dir = widget.mode == InstallerMode.uninstall
      ? sourceDir
      : p.normalize(p.absolute(argValue(widget.args, 'pw-dir') ?? defaultInstallDir));
  bool _desktop = true;
  bool _startMenu = true;
  bool _removeData = false;
  _Step _step = _Step.form;
  String _stage = '';
  double? _value;
  String _error = '';

  bool get _isInstall => widget.mode == InstallerMode.install;
  bool get _upgrade => _isInstall && readManifest(_dir) != null;

  Future<void> _pickDir() async {
    final picked = await getDirectoryPath(initialDirectory: p.dirname(_dir), confirmButtonText: '选择');
    if (picked == null) return;
    // 选了普通文件夹时放进同名子文件夹，文件不会散落在里面
    setState(
      () =>
          _dir = p.basename(picked).toLowerCase() == AppInfo.name.toLowerCase() ? picked : p.join(picked, AppInfo.name),
    );
  }

  Future<void> _install() async {
    setState(() {
      _step = _Step.working;
      _stage = '正在准备…';
      _value = null;
    });
    try {
      await install(
        _dir,
        desktopShortcut: _desktop,
        startMenuShortcut: _startMenu,
        report: (stage, value) {
          if (mounted) {
            setState(() {
              _stage = stage;
              _value = value;
            });
          }
        },
      );
      setState(() => _step = _Step.done);
    } catch (e) {
      setState(() {
        _step = _Step.failed;
        _error = '$e'.replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _uninstall() async {
    setState(() {
      _step = _Step.working;
      _stage = '正在卸载…';
    });
    try {
      await startCleanup(_dir, removeData: _removeData);
      exit(0);
    } catch (e) {
      setState(() {
        _step = _Step.failed;
        _error = '$e'.replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _launch() async {
    await Process.start(p.join(_dir, exeName), [], workingDirectory: _dir, mode: ProcessStartMode.detached);
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                const Positioned.fill(child: DragToMoveArea(child: SizedBox.expand())),
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Row(
                      children: [
                        const AppLogo(size: 16),
                        const SizedBox(width: 10),
                        Text(AppInfo.fullName, style: theme.textTheme.titleSmall),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    ignoring: _step == _Step.working,
                    child: const WindowButtons(height: 36, showMaximize: false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
              child: _isInstall ? _installBody(theme) : _uninstallBody(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _installBody(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (_step) {
      _Step.form => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${_upgrade ? '更新' : '安装'} ${AppInfo.name}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '版本 ${AppInfo.version} · 只为当前用户安装，不需要管理员权限',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Card.filled(
            color: scheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('安装位置'),
              subtitle: Text(_dir, overflow: TextOverflow.ellipsis),
              trailing: TextButton(onPressed: _pickDir, child: const Text('更改')),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _desktop,
            onChanged: (v) => setState(() => _desktop = v!),
            title: const Text('创建桌面快捷方式'),
          ),
          CheckboxListTile(
            value: _startMenu,
            onChanged: (v) => setState(() => _startMenu = v!),
            title: const Text('添加到开始菜单'),
          ),
          const Spacer(),
          Text(
            '${AppInfo.name} 是第三方基于 PCL 独立进行二次创作的产物，不代表 PCL 官方。',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => exit(1), child: const Text('取消')),
              const SizedBox(width: 8),
              FilledButton(onPressed: _install, child: Text(_upgrade ? '更新' : '安装')),
            ],
          ),
        ],
      ),
      _Step.working => _progress(theme, _upgrade ? '正在更新' : '正在安装'),
      _Step.done => _result(
        theme,
        icon: Icons.check_circle,
        color: scheme.primary,
        title: '安装完成',
        body: '已安装到 $_dir',
        actions: [
          TextButton(onPressed: () => exit(0), child: const Text('完成')),
          const SizedBox(width: 8),
          FilledButton(onPressed: _launch, child: Text('启动 ${AppInfo.name}')),
        ],
      ),
      _Step.failed => _result(
        theme,
        icon: Icons.error,
        color: scheme.error,
        title: '安装失败',
        body: _error,
        actions: [
          TextButton(onPressed: () => exit(1), child: const Text('关闭')),
          const SizedBox(width: 8),
          FilledButton(onPressed: () => setState(() => _step = _Step.form), child: const Text('重试')),
        ],
      ),
    };
  }

  Widget _uninstallBody(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (_step) {
      _Step.form || _Step.done => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('卸载 ${AppInfo.name}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '只删除安装时写入的文件，放在程序文件夹里的其他文件不会动',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Card.filled(
            color: scheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('安装位置'),
              subtitle: Text(_dir, overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _removeData,
            onChanged: (v) => setState(() => _removeData = v!),
            title: Text('同时删除启动器数据', style: TextStyle(color: _removeData ? scheme.error : null)),
            subtitle: Text(
              '设置、账户与默认游戏文件夹（$userDataDir）。默认游戏文件夹中的存档也会被删除',
              style: TextStyle(color: _removeData ? scheme.error : null),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => exit(1), child: const Text('取消')),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
                onPressed: _uninstall,
                child: const Text('卸载'),
              ),
            ],
          ),
        ],
      ),
      _Step.working => _progress(theme, '正在卸载'),
      _Step.failed => _result(
        theme,
        icon: Icons.error,
        color: scheme.error,
        title: '卸载失败',
        body: _error,
        actions: [TextButton(onPressed: () => exit(1), child: const Text('关闭'))],
      ),
    };
  }

  Widget _progress(ThemeData theme, String title) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      LinearProgressIndicator(value: _value, borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 10),
      Text(_stage, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
    ],
  );

  Widget _result(
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required List<Widget> actions,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Spacer(),
      Icon(icon, size: 56, color: color),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(body, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
      const Spacer(),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
    ],
  );
}
