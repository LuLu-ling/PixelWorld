import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../app_state.dart';
import '../core/accounts.dart';
import '../shell.dart';
import '../widgets/accounts_dialog.dart';
import '../widgets/launch_dialogs.dart';
import '../widgets/loader_label.dart';
import '../widgets/side_nav.dart';
import 'home_feed.dart';

/// 启动页：左侧账户与启动按钮，右侧欢迎卡片和当前版本（PCL 的布局）
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _launch(BuildContext context) async {
    final state = AppScope.read(context);
    final view = View.of(context);
    final display = PlatformDispatcher.instance.displays.firstOrNull;
    final launcher = view.physicalSize / view.devicePixelRatio;
    final screen = display == null ? launcher : display.size / display.devicePixelRatio;
    try {
      await state.launch(
        DialogLaunchPrompts(context),
        launcherSize: (width: launcher.width.round(), height: launcher.height.round()),
        screenSize: (width: screen.width.round(), height: screen.height.round()),
      );
    } catch (e) {
      if (context.mounted) toast(context, '启动失败：${errorText(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final acc = state.selectedAccount;
    final version = state.selectedVersion;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => showAccountsDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: acc == null
                              ? Icon(Icons.person_add_alt, size: 36, color: scheme.onPrimaryContainer)
                              : Text(
                                  acc.name.characters.first.toUpperCase(),
                                  style: theme.textTheme.headlineLarge?.copyWith(color: scheme.onPrimaryContainer),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(acc?.name ?? '添加账户', style: theme.textTheme.titleLarge),
                        Text(
                          acc == null ? '点击添加' : (acc.type == AccountType.microsoft ? '微软账户' : '离线账户'),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _LaunchButton(state: state, onLaunch: () => _launch(context)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ShellNav.of(context).open(SubPage.versions),
                        child: const Text('版本选择'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: version == null
                            ? null
                            : () {
                                AppScope.read(context).instanceId = version.id;
                                ShellNav.of(context).open(SubPage.instance);
                              },
                        child: const Text('版本设置'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ContentPanel(
            child: ListView(
              padding: const EdgeInsets.all(28),
              children: [
                Container(
                  height: 158,
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [scheme.primaryContainer, Color.lerp(scheme.primaryContainer, Colors.black, 0.28)!],
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(acc?.name),
                        style: theme.textTheme.titleSmall?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                      Text(
                        'PCL.PW',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '第三方基于 PCL 二次创作的跨平台 Minecraft 启动器',
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card.filled(
                  color: scheme.surfaceContainerLow,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: version == null
                            ? Icon(Icons.add, color: scheme.onPrimaryContainer)
                            : versionIcon(version, color: scheme.onPrimaryContainer),
                      ),
                    ),
                    title: Text(version == null ? '当前版本' : version.id),
                    subtitle: Text(
                      version == null
                          ? (state.versions.isEmpty ? '当前文件夹中还没有版本，可以到「下载」页安装' : '请选择一个版本')
                          : describeVersion(version),
                    ),
                    onTap: () => ShellNav.of(context).open(SubPage.versions),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => ShellNav.of(context).open(SubPage.log),
                    icon: const Icon(Icons.article_outlined),
                    label: Text(state.gameState == GameState.running ? '游戏运行中 · 查看日志' : '游戏日志'),
                  ),
                ),
                if (state.config.homeHints) ...[const SizedBox(height: 8), const HomeHints()],
                if (state.config.homeNews) ...[const SizedBox(height: 16), const VersionNewsFeed()],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _greeting(String? name) {
    final h = DateTime.now().hour;
    final when = h < 5
        ? '夜深了'
        : h < 11
        ? '早上好'
        : h < 13
        ? '中午好'
        : h < 18
        ? '下午好'
        : '晚上好';
    return name == null ? '$when！' : '$when，$name';
  }
}

class _LaunchButton extends StatelessWidget {
  const _LaunchButton({required this.state, required this.onLaunch});

  final AppState state;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final version = state.selectedVersion;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    if (state.gameState == GameState.preparing && state.task != null) {
      return ListenableBuilder(
        listenable: state.task!,
        builder: (context, _) {
          final t = state.task!;
          return Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(shape: shape, color: theme.colorScheme.secondaryContainer),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.stage, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                    ),
                    if (t.total > 0) Text('${t.done} / ${t.total}', style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: t.fraction, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          );
        },
      );
    }

    final running = state.gameState == GameState.running;
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: FilledButton(
        onPressed: running ? state.killGame : (version == null ? null : onLaunch),
        style: FilledButton.styleFrom(
          shape: shape,
          backgroundColor: running ? theme.colorScheme.error : null,
          foregroundColor: running ? theme.colorScheme.onError : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(running ? Icons.stop : Icons.play_arrow),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 不用 textTheme，文字颜色跟随按钮前景色
                  Text(running ? '结束游戏' : '开始游戏', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  if (version != null)
                    Text(version.id, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
