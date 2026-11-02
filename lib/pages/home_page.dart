import 'package:flutter/material.dart';

import '../widgets/side_nav.dart';

/// 启动页：左侧账户与启动按钮，右侧欢迎卡片和当前版本（PCL 的布局）。
/// 账户、版本和启动还在迁移，这里先放布局。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Icon(Icons.person, size: 40, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: 16),
                Text('未登录', style: theme.textTheme.titleLarge),
                Text('账户功能迁移中', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始游戏'),
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: null, child: const Text('版本选择'))),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton(onPressed: null, child: const Text('版本设置'))),
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
                    gradient: LinearGradient(colors: [scheme.primaryContainer, scheme.tertiary]),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('欢迎使用', style: theme.textTheme.titleSmall?.copyWith(color: scheme.onPrimaryContainer)),
                      Text('PCL.PW',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                      Text('第三方基于 PCL 二次创作的跨平台 Minecraft 启动器',
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card.filled(
                  color: scheme.surfaceContainerLow,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.inventory_2_outlined, color: scheme.primary),
                    title: const Text('当前版本'),
                    subtitle: const Text('版本管理迁移中'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
