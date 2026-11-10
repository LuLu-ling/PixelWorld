import 'package:flutter/material.dart';

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
          child: Text(title, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Card.filled(
          color: theme.colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
