import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import 'file_manager_page.dart' show pickFile;
import '../widgets/app_background.dart';
import '../app_scope.dart';
import '../core/config.dart' show homeLayouts;
import '../platform.dart';
import '../widgets/theme_color_dialog.dart';
import '../widgets/settings_group.dart';
import '../widgets/side_nav.dart';
import '../widgets/ai_settings.dart';
import '../widgets/ai_workspace_settings.dart';
import '../widgets/storage_location.dart';
import 'docs_page.dart';
import 'settings_sections.dart';

enum _Section { launch, java, manage, appearance, misc, ai, aiTools, aiWorkspace, about, docs }

/// 从别的页面跳到设置的某个小节（值为小节名，例如 ai、aiTools、aiWorkspace），见 ShellNav.openSettings
final settingsSectionRequest = ValueNotifier<String?>(null);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _Section _section = _Section.launch;

  @override
  void initState() {
    super.initState();
    settingsSectionRequest.addListener(_onRequest);
    _onRequest();
  }

  @override
  void dispose() {
    settingsSectionRequest.removeListener(_onRequest);
    super.dispose();
  }

  void _onRequest() {
    final s = _Section.values.asNameMap()[settingsSectionRequest.value];
    if (s == null) return;
    settingsSectionRequest.value = null;
    if (mounted) setState(() => _section = s);
  }

  /// AI 的几个小节共用的外框
  static Widget _aiPage(String title, String? intro, Widget child) => ListView(
    padding: const EdgeInsets.fromLTRB(6, 2, 16, 16),
    children: [
      SettingsGroup(
        title: title,
        children: [
          if (intro != null) Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Text(intro)),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), child: child),
        ],
      ),
    ],
  );

  static const _groups = [
    SideNavGroup('游戏', [
      SideNavItem(_Section.launch, '启动', Icons.rocket_launch_outlined),
      SideNavItem(_Section.java, 'Java', Icons.coffee_outlined),
      SideNavItem(_Section.manage, '游戏管理', Icons.folder_outlined),
    ]),
    SideNavGroup('启动器', [
      SideNavItem(_Section.appearance, '个性化', Icons.palette_outlined),
      SideNavItem(_Section.misc, '其他', Icons.tune),
    ]),
    SideNavGroup('AI', [
      SideNavItem(_Section.ai, '模型与接口', Icons.auto_awesome_outlined),
      SideNavItem(_Section.aiTools, '工具与服务', Icons.extension_outlined),
      SideNavItem(_Section.aiWorkspace, '工作区与联网', Icons.travel_explore),
    ]),
    SideNavGroup('关于', [
      SideNavItem(_Section.about, '关于与致谢', Icons.info_outline),
      SideNavItem(_Section.docs, '使用文档', Icons.menu_book_outlined),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
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
              _Section.manage => const GameStorageSection(),
              _Section.appearance => const _AppearanceSection(),
              _Section.ai => _aiPage(
                '模型与接口',
                'AI 助手使用你自己的 AI 服务。支持 OpenAI 兼容接口（DeepSeek、通义千问、Kimi、OpenRouter、本机 Ollama 等）'
                    '和 Anthropic 接口；费用由你的 AI 服务商收取。',
                const AiSettingsForm(),
              ),
              _Section.aiTools => _aiPage('工具与服务', null, const AiToolsSettings()),
              _Section.aiWorkspace => _aiPage('工作区与联网', null, const AiWorkspaceSettings()),
              _Section.about => const _AboutSection(),
              _Section.docs => const DocsPage(),
            },
          ),
        ),
      ],
    );
  }
}

/// 没有缩放时的屏幕尺寸（去掉系统栏），用来显示「自动」算出的比例
Size _unscaledSize(BuildContext context) {
  final view = View.of(context);
  final padding = view.padding;
  // 左右的挖孔都扣掉，和 AppScale 的算法一致
  final w = view.physicalSize.width - padding.left - padding.right;
  final h = view.physicalSize.height - padding.top - padding.bottom;
  return Size(w, h) / view.devicePixelRatio;
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 2, 16, 16),
      children: [
        SettingsGroup(
          title: '个性化',
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('颜色模式'),
              subtitle: const Text('启动器界面的明暗模式'),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('跟随系统'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 'light', label: Text('浅色'), icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: 'dark', label: Text('深色'), icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {cfg.themeMode},
                onSelectionChanged: (s) => cfg.update({'themeMode': s.first}),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.zoom_out_map),
              title: const Text('界面缩放'),
              subtitle: Text(
                cfg.uiScale > 0
                    ? '整个启动器按这个比例显示'
                    : '自动：按屏幕尺寸计算，当前为 ${(autoUiScale(_unscaledSize(context)) * 100).round()}%',
              ),
              trailing: DropdownButton<double>(
                // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
                focusColor: Colors.transparent,
                value: uiScaleOptions.contains(cfg.uiScale) ? cfg.uiScale : 0.0,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                items: [
                  for (final v in uiScaleOptions)
                    DropdownMenuItem(value: v, child: Text(v == 0 ? '自动' : '${(v * 100).round()}%')),
                ],
                onChanged: (v) => cfg.update({'uiScale': v ?? 0.0}),
              ),
            ),
            const _ThemeColorSetting(),
          ],
        ),
        // 背景图片只在电脑上生效
        if (isDesktop) const _BackgroundSettings(),
        SettingsGroup(
          title: '首页',
          children: [
            if (isDesktop)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('首页布局'),
                subtitle: Text(switch (cfg.homeLayout) {
                  'split' => '上下：当前实例在顶部，开始游戏和存档在底部，中间留给背景；选背景图片时自动切到这个布局',
                  'minimal' => '极简：只在底部留一条，放当前实例和开始游戏',
                  _ => '标准：大卡片、公告与快捷按钮、最近游玩',
                }),
                trailing: DropdownButton<String>(
                  focusColor: Colors.transparent,
                  value: cfg.homeLayout,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: [for (final e in homeLayouts.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                  onChanged: (v) => v == null ? null : cfg.update({'homeLayout': v}),
                ),
              ),
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

/// 主题色：设了背景图片时可以跟随背景（MD3 从图片取色），否则手动选择
class _ThemeColorSetting extends StatelessWidget {
  const _ThemeColorSetting();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cfg = state.config;
    final bg = state.background;
    final hasImage = isDesktop && bg.imagePath.isNotEmpty;
    final auto = hasImage && bg.themeFromImage;
    final seed = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(radius: 13, backgroundColor: auto ? seed : Color(cfg.themeColor)),
          title: const Text('主题色'),
          subtitle: Text(auto ? '跟随背景：按 Material Design 3 从背景图片取色，换图片后自动更新' : '按 Material Design 3 从主题色生成整套浅色与深色配色'),
          trailing: hasImage
              ? SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('跟随背景')),
                    ButtonSegment(value: false, label: Text('手动选择')),
                  ],
                  selected: {auto},
                  onSelectionChanged: (v) => cfg.update({BackgroundPrefs.themeFromImageKey: v.first}),
                )
              : const Icon(Icons.palette_outlined),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: auto
              ? Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final (i, c) in bg.candidates.indexed)
                      Tooltip(
                        message: i == 0 ? '推荐' : '候选 ${i + 1}',
                        child: InkResponse(
                          onTap: () => cfg.update({BackgroundPrefs.seedIndexKey: i}),
                          radius: 22,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: c,
                            child: i == bg.seedIndex.clamp(0, bg.candidates.length - 1)
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: ThemeData.estimateBrightnessForColor(c) == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                )
              : ThemeColorPicker(current: cfg.themeColor, onChanged: (color) => cfg.update({'themeColor': color})),
        ),
      ],
    );
  }
}

/// 背景图片（电脑端）：选择图片、两种模糊、封面色散、面板不透明度与降低透明度
class _BackgroundSettings extends StatelessWidget {
  const _BackgroundSettings();

  Future<void> _pick(BuildContext context) async {
    final bg = AppScope.read(context).background;
    final path = await pickFile(context, extensions: const ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif'], label: '图片');
    if (path == null) return;
    try {
      await bg.setImage(path);
    } catch (e) {
      if (context.mounted) toast(context, '无法使用这张图片：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final bg = state.background;
    final cfg = state.config;
    final path = bg.imagePath;
    final has = path.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    return SettingsGroup(
      title: '背景图片',
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: const Icon(Icons.wallpaper_outlined),
          title: const Text('背景图片'),
          subtitle: Text(has ? '显示在整个窗口后面，界面面板会变成毛玻璃' : '选择一张图片作为启动器的背景（只在电脑上生效）'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (has)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(path),
                    width: 96,
                    height: 54,
                    fit: BoxFit.cover,
                    cacheWidth: 240,
                    errorBuilder: (_, _, _) => Container(width: 96, height: 54, color: scheme.surfaceContainerHighest),
                  ),
                ),
              const SizedBox(width: 12),
              // 按钮横着排，不超出这一行的高度
              FilledButton.tonal(onPressed: () => _pick(context), child: Text(has ? '换一张…' : '选择图片…')),
              if (has) ...[const SizedBox(width: 8), OutlinedButton(onPressed: bg.clearImage, child: const Text('移除'))],
            ],
          ),
        ),
        if (has) ...[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: const Icon(Icons.fit_screen_outlined),
            title: const Text('契合度'),
            subtitle: Text(switch (bg.fit) {
              'fit' => '适应：完整显示整张图片，空出来的地方用图片的颜色填上',
              'stretch' => '拉伸：拉伸到窗口大小，图片可能变形',
              'tile' => '平铺：按图片原来的大小重复铺满窗口',
              'center' => '居中：按图片原来的大小放在窗口中间',
              'span' => '跨区：图片铺满整个桌面（所有屏幕），窗口只显示自己所在位置的那一块，移动窗口时背景不动',
              _ => '填充：铺满整个窗口，多出来的部分裁掉',
            }),
            trailing: DropdownButton<String>(
              // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
              focusColor: Colors.transparent,
              value: bg.fit,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              items: [
                for (final e in BackgroundPrefs.fits.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => v == null ? null : cfg.update({BackgroundPrefs.fitKey: v}),
            ),
          ),
          _PrefSlider(
            icon: Icons.blur_on,
            title: '背景模糊',
            subtitle: '整张背景图片的模糊程度；为 0 时背景保持清晰',
            value: bg.blur,
            min: 0,
            max: 48,
            label: (v) => v.round().toString(),
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.blurKey: v.roundToDouble()}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.brightness_6_outlined,
            title: '背景暗化',
            subtitle: Theme.of(context).brightness == Brightness.dark
                ? '在背景图片上压一层黑色，图片很亮或很花时调高，界面和文字更清楚'
                : '在背景图片上压一层白色，图片很暗或很花时调高，界面和文字更清楚',
            value: bg.dimFor(Theme.of(context).brightness),
            min: 0,
            max: .7,
            label: (v) => '${(v * 100).round()}%',
            live: true,
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.dimKey: (v * 100).roundToDouble() / 100}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.blur_linear,
            title: '面板模糊',
            subtitle: '只模糊面板后面的部分（毛玻璃），与背景模糊互不影响；为 0 时面板后面也是清晰的',
            value: bg.panelBlur,
            min: 0,
            max: 40,
            label: (v) => v.round().toString(),
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.panelBlurKey: v.roundToDouble()}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.opacity,
            title: '面板不透明度',
            subtitle: '面板越透明，背景图片越明显',
            value: bg.opacity,
            min: .35,
            max: .95,
            label: (v) => '${(v * 100).round()}%',
            live: true,
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.opacityKey: (v * 100).roundToDouble() / 100}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.gradient,
            title: '封面色散',
            subtitle: '最近游玩的卡片上，从封面取出的颜色向外扩散的强弱',
            value: bg.coverGlow,
            min: 0,
            max: 1,
            label: (v) => '${(v * 100).round()}%',
            live: true,
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.glowKey: (v * 100).roundToDouble() / 100}, persist: persist),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            secondary: const Icon(Icons.layers_outlined),
            title: const Text('降低透明度'),
            subtitle: const Text('保留背景图片，但面板几乎不透明，适合图片很花或者想要更清楚的文字'),
            value: bg.solid,
            onChanged: (v) => cfg.update({BackgroundPrefs.solidKey: v}),
          ),
        ],
      ],
    );
  }
}

/// 设置里的滑块：拖动时只更新显示，松手才保存（模糊要重新计算图片，不能每一帧都算）。
/// [live] 为 true 时拖动中也保存（不透明度、色散只是重画，开销很小）
class _PrefSlider extends StatefulWidget {
  const _PrefSlider({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onCommit,
    this.live = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final String Function(double) label;
  final void Function(double value, {required bool persist}) onCommit;
  final bool live;

  @override
  State<_PrefSlider> createState() => _PrefSliderState();
}

class _PrefSliderState extends State<_PrefSlider> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final v = (_dragging ?? widget.value).clamp(widget.min, widget.max);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(widget.icon),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      trailing: SizedBox(
        width: 260,
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: v,
                min: widget.min,
                max: widget.max,
                onChanged: (x) {
                  setState(() => _dragging = x);
                  // 拖动中只更新界面，不写配置文件；松手时 onChangeEnd 再保存
                  if (widget.live) widget.onCommit(x, persist: false);
                },
                onChangeEnd: (x) {
                  widget.onCommit(x, persist: true);
                  setState(() => _dragging = null);
                },
              ),
            ),
            SizedBox(width: 44, child: Text(widget.label(v), textAlign: TextAlign.end)),
          ],
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(6, 2, 16, 16),
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
              title: const Text(AppInfo.authorName),
              subtitle: const Text('Pixel World 的开发者'),
              trailing: FilledButton.icon(
                onPressed: () => _open(AppInfo.sponsorUrl),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('赞助作者'),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Image.asset('assets/icon/icon.png', width: 40, height: 40),
              title: Text('${AppInfo.fullName} ${AppInfo.version}'),
              subtitle: const Text(
                'Pixel World 是第三方 Minecraft 启动器，本项目为轻度使用 PCL 仓储库，界面布局参考 PCL 社区版（PCL-CE）。'
                'PCL 由龙腾猫跃开发，本软件与 PCL 及其作者无关，也不代表 PCL 官方。'
                '请勿就本软件的问题打扰 PCL 作者。',
              ),
            ),
            link(Icons.code, '源代码', 'Pixel World 以 Apache-2.0 协议开源', AppInfo.repoUrl, action: '打开'),
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
            link(
              Icons.android,
              '安卓版游戏运行时',
              '基于 Amethyst-Android（LGPL-3.0）、MobileGlues、Krypton Wrapper、LWJGL 与 OpenJDK，单独以 LGPL-3.0 开源',
              '${AppInfo.repoUrl}/blob/main/android/runtime/NOTICE.md',
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
