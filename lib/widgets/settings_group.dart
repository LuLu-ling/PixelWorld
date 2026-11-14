import 'package:flutter/material.dart';

import 'app_background.dart';

/// 设置项分组：标题 + 圆角卡片
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          // 启用背景图片时标题直接放在背景上，按背景亮度自动黑字或白字
          child: OnBackground(
            builder: (context, fg, muted) => Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(color: muted ?? theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        GlassPanel(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(height: 1), children[i]],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
