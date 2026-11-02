import 'package:flutter/material.dart';

import '../core/instance.dart';
import 'loader_icon.dart';

class SideNavItem<T> {
  const SideNavItem(this.value, this.label, this.icon, {this.trailing, this.loader});

  final T value;
  final String label;
  final IconData icon;
  final String? trailing;

  /// 设置时显示加载器图标，代替 [icon]
  final Loader? loader;
}

class SideNavGroup<T> {
  const SideNavGroup(this.title, this.items);

  final String? title;
  final List<SideNavItem<T>> items;
}

/// 二级页面左侧的分组导航（PCL 的布局），选中项为 MD3 药丸形指示器
class SideNav<T> extends StatelessWidget {
  const SideNav({super.key, required this.groups, required this.value, required this.onChanged});

  final List<SideNavGroup<T>> groups;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 232,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          for (final g in groups) ...[
            if (g.title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(g.title!, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            for (final item in g.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: item.value == value ? scheme.secondaryContainer : Colors.transparent,
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onChanged(item.value),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          if (item.loader != null)
                            LoaderIcon(
                              item.loader!,
                              size: 22,
                              color: item.value == value ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                            )
                          else
                            Icon(
                              item.icon,
                              size: 22,
                              color: item.value == value ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: item.value == value ? scheme.onSecondaryContainer : scheme.onSurface,
                              ),
                            ),
                          ),
                          if (item.trailing != null)
                            Text(
                              item.trailing!,
                              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 右侧内容区：左上圆角的面板
class ContentPanel extends StatelessWidget {
  const ContentPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// 尚未从 Electron 版迁移过来的功能
class MigratingPlaceholder extends StatelessWidget {
  const MigratingPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('这部分功能正在迁移中', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
