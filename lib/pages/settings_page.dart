import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../app_scope.dart';
import '../widgets/settings_group.dart';
import '../widgets/side_nav.dart';
import '../widgets/ai_settings.dart';
import 'settings_sections.dart';

enum _Section { launch, java, manage, appearance, ai, misc, about }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _Section _section = _Section.launch;

  static const _groups = [
    SideNavGroup('游戏', [
      SideNavItem(_Section.launch, '启动', Icons.rocket_launch_outlined),
      SideNavItem(_Section.java, 'Java', Icons.coffee_outlined),
      SideNavItem(_Section.manage, '游戏管理', Icons.folder_outlined),
    ]),
    SideNavGroup('启动器', [
      SideNavItem(_Section.appearance, '个性化', Icons.palette_outlined),
      SideNavItem(_Section.ai, 'AI 排障', Icons.auto_awesome_outlined),
      SideNavItem(_Section.misc, '其他', Icons.tune),
    ]),
    SideNavGroup('关于', [SideNavItem(_Section.about, '关于与致谢', Icons.info_outline)]),
  ];

  @override
  Widget build(BuildContext context) {
    final label = _groups.expand((g) => g.items).firstWhere((i) => i.value == _section).label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav(groups: _groups, value: _section, onChanged: (s) => setState(() => _section = s)),
        Expanded(
          child: ContentPanel(
            child: switch (_section) {
              _Section.launch => const LaunchSection(),
              _Section.java => const JavaSection(),
              _Section.misc => const MiscSection(),
              _Section.appearance => const _AppearanceSection(),
              _Section.ai => ListView(
                padding: const EdgeInsets.all(28),
                children: const [
                  SettingsGroup(
                    title: 'AI 排障',
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          '游戏崩溃后，可以把截取的日志发送给你自己的 AI 服务分析原因。'
                          '支持 OpenAI 兼容接口（DeepSeek、通义千问、Kimi、OpenRouter、本机 Ollama 等）和 Anthropic 接口；'
                          '费用由你的 AI 服务商收取。',
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 20), child: AiSettingsForm()),
                    ],
                  ),
                ],
              ),
              _Section.about => const _AboutSection(),
              _ => MigratingPlaceholder(title: label),
            },
          ),
        ),
      ],
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: '个性化',
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('颜色模式'),
              subtitle: const Text('主题色固定为 PCL 主题蓝'),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('跟随系统'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 'light', label: Text('浅色'), icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: 'dark', label: Text('深色'), icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {AppScope.of(context).config.themeMode},
                onSelectionChanged: (s) => AppScope.read(context).config.update({'themeMode': s.first}),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: '首页',
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              secondary: const Icon(Icons.info_outline),
              title: const Text('显示使用提示'),
              subtitle: const Text('正在使用的版本与免费声明'),
              value: AppScope.of(context).config.homeHints,
              onChanged: (v) => AppScope.read(context).config.update({'homeHints': v}),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              secondary: const Icon(Icons.newspaper_outlined),
              title: const Text('显示 Minecraft 版本动态'),
              subtitle: const Text('最新的正式版与快照，简介来自中文 Minecraft Wiki'),
              value: AppScope.of(context).config.homeNews,
              onChanged: (v) => AppScope.read(context).config.update({'homeNews': v}),
            ),
          ],
        ),
      ],
    );
  }
}

/// 关于页。按《PCL 存储库合理使用指南》第 3 条，首位为龙腾猫跃的署名及赞助链接。
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  static void _open(String url) => launchUrl(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ListTile link(IconData icon, String title, String subtitle, String url, {String action = '查看'}) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () => _open(url), child: Text(action)),
    );
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SettingsGroup(
          title: '关于',
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.favorite),
              ),
              title: const Text(AppInfo.pclAuthor),
              subtitle: const Text('Plain Craft Launcher（PCL）的作者。PCL.PW 基于 PCL 二次创作'),
              trailing: FilledButton.icon(
                onPressed: () => _open(AppInfo.pclSponsorUrl),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('赞助作者'),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: const Icon(Icons.info_outline),
              title: Text('${AppInfo.fullName} ${AppInfo.version}'),
              subtitle: const Text(
                '本软件是第三方基于 PCL 独立进行二次创作的产物，'
                '由第三方开发和维护，与 PCL 及其作者无关，也不代表 PCL 官方。'
                '请勿就本软件的问题打扰 PCL 作者。',
              ),
            ),
            link(Icons.code, '源代码', 'PCL.PW 以 Apache-2.0 协议开源', AppInfo.repoUrl, action: '打开'),
            link(
              Icons.gavel_outlined,
              'PCL 存储库合理使用指南',
              '本项目遵循的命名、署名与使用规则，随源代码一同发布',
              '${AppInfo.repoUrl}/blob/main/PCL-GUIDE.md',
            ),
          ],
        ),
        SettingsGroup(
          title: '致谢',
          children: [
            link(
              Icons.groups_outlined,
              'PCL Community',
              'PCL 社区版（PCL-CE）的开发者们，本软件与 PCL-CE 的数据兼容',
              AppInfo.pclCeRepoUrl,
            ),
            link(Icons.flutter_dash, 'Flutter', '跨平台界面框架', 'https://flutter.dev'),
            link(Icons.palette_outlined, 'Material Design 3', '界面设计语言与配色算法', 'https://m3.material.io'),
          ],
        ),
        Text(
          'Minecraft 是 Mojang Studios 的商标。本软件不是官方 Minecraft 产品，未经 Mojang 或 Microsoft 批准，也与其无关。',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
