import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import 'file_manager_page.dart' show pickFile;
import '../widgets/app_background.dart';
import '../app_scope.dart';
import '../core/config.dart' show homeLayouts;
import '../l10n/l10n.dart';
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

  static List<SideNavGroup<_Section>> _groups(AppLocalizations l) => [
    SideNavGroup(l.settingsGroupGame, [
      SideNavItem(_Section.launch, l.settingsLaunch, Icons.rocket_launch_outlined),
      const SideNavItem(_Section.java, 'Java', Icons.coffee_outlined),
      SideNavItem(_Section.manage, l.settingsManage, Icons.folder_outlined),
    ]),
    SideNavGroup(l.settingsGroupLauncher, [
      SideNavItem(_Section.appearance, l.settingsAppearance, Icons.palette_outlined),
      SideNavItem(_Section.misc, l.settingsMisc, Icons.tune),
    ]),
    SideNavGroup('AI', [
      SideNavItem(_Section.ai, l.settingsAiModel, Icons.auto_awesome_outlined),
      SideNavItem(_Section.aiTools, l.settingsAiTools, Icons.extension_outlined),
      SideNavItem(_Section.aiWorkspace, l.settingsAiWorkspace, Icons.travel_explore),
    ]),
    SideNavGroup(l.settingsGroupAbout, [
      SideNavItem(_Section.about, l.settingsAbout, Icons.info_outline),
      SideNavItem(_Section.docs, l.settingsDocs, Icons.menu_book_outlined),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav(groups: _groups(l), value: _section, onChanged: (s) => setState(() => _section = s)),
        Expanded(
          child: ContentPanel(
            child: switch (_section) {
              _Section.launch => const LaunchSection(),
              _Section.java => const JavaSection(),
              _Section.misc => const MiscSection(),
              _Section.manage => const GameStorageSection(),
              _Section.appearance => const _AppearanceSection(),
              _Section.ai => _aiPage(l.settingsAiModel, l.settingsAiIntro, const AiSettingsForm()),
              _Section.aiTools => _aiPage(l.settingsAiTools, null, const AiToolsSettings()),
              _Section.aiWorkspace => _aiPage(l.settingsAiWorkspace, null, const AiWorkspaceSettings()),
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
  final w = view.physicalSize.width - padding.right;
  final h = view.physicalSize.height - padding.top - padding.bottom;
  return Size(w, h) / view.devicePixelRatio;
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final cfg = AppScope.of(context).config;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 2, 16, 16),
      children: [
        SettingsGroup(
          title: l.settingsAppearance,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(l.colorMode),
              subtitle: Text(l.colorModeHint),
              trailing: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(l.themeSystem), icon: const Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 'light', label: Text(l.themeLight), icon: const Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: 'dark', label: Text(l.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
                ],
                selected: {cfg.themeMode},
                onSelectionChanged: (s) => cfg.update({'themeMode': s.first}),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.zoom_out_map),
              title: Text(l.uiScale),
              subtitle: Text(
                cfg.uiScale > 0 ? l.uiScaleFixed : l.uiScaleAuto((autoUiScale(_unscaledSize(context)) * 100).round()),
              ),
              trailing: DropdownButton<double>(
                // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
                focusColor: Colors.transparent,
                value: uiScaleOptions.contains(cfg.uiScale) ? cfg.uiScale : 0.0,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                items: [
                  for (final v in uiScaleOptions)
                    DropdownMenuItem(value: v, child: Text(v == 0 ? l.commonAuto : '${(v * 100).round()}%')),
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
          title: l.homeGroup,
          children: [
            if (isDesktop)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.dashboard_outlined),
                title: Text(l.homeLayout),
                subtitle: Text(switch (cfg.homeLayout) {
                  'split' => l.homeLayoutSplitHint,
                  'minimal' => l.homeLayoutMinimalHint,
                  _ => l.homeLayoutStandardHint,
                }),
                trailing: DropdownButton<String>(
                  focusColor: Colors.transparent,
                  value: cfg.homeLayout,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    for (final v in homeLayouts)
                      DropdownMenuItem(
                        value: v,
                        child: Text(switch (v) {
                          'split' => l.homeLayoutSplit,
                          'minimal' => l.homeLayoutMinimal,
                          _ => l.homeLayoutStandard,
                        }),
                      ),
                  ],
                  onChanged: (v) => v == null ? null : cfg.update({'homeLayout': v}),
                ),
              ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              secondary: const Icon(Icons.info_outline),
              title: Text(l.homeHints),
              subtitle: Text(l.homeHintsHint),
              value: AppScope.of(context).config.homeHints,
              onChanged: (v) => AppScope.read(context).config.update({'homeHints': v}),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              secondary: const Icon(Icons.newspaper_outlined),
              title: Text(l.homeNews),
              subtitle: Text(l.homeNewsHint),
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
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(radius: 13, backgroundColor: auto ? seed : Color(cfg.themeColor)),
          title: Text(l.themeColor),
          subtitle: Text(auto ? l.themeColorAuto : l.themeColorManual),
          trailing: hasImage
              ? SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(l.themeFollowBackground)),
                    ButtonSegment(value: false, label: Text(l.themeManual)),
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
                        message: i == 0 ? l.themeRecommended : l.themeCandidate(i + 1),
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
    final l = context.l10n;
    final path = await pickFile(
      context,
      extensions: const ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif'],
      label: l.bgImageFiles,
    );
    if (path == null) return;
    try {
      await bg.setImage(path);
    } catch (e) {
      if (context.mounted) toast(context, l.bgImageInvalid('$e'));
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
    final l = context.l10n;
    return SettingsGroup(
      title: l.bgImage,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: const Icon(Icons.wallpaper_outlined),
          title: Text(l.bgImage),
          subtitle: Text(has ? l.bgImageSet : l.bgImageUnset),
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
              FilledButton.tonal(onPressed: () => _pick(context), child: Text(has ? l.bgImageChange : l.bgImageChoose)),
              if (has) ...[
                const SizedBox(width: 8),
                OutlinedButton(onPressed: bg.clearImage, child: Text(l.bgImageRemove)),
              ],
            ],
          ),
        ),
        if (has) ...[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: const Icon(Icons.fit_screen_outlined),
            title: Text(l.bgFit),
            subtitle: Text(switch (bg.fit) {
              'fit' => l.bgFitFitHint,
              'stretch' => l.bgFitStretchHint,
              'tile' => l.bgFitTileHint,
              'center' => l.bgFitCenterHint,
              'span' => l.bgFitSpanHint,
              _ => l.bgFitFillHint,
            }),
            trailing: DropdownButton<String>(
              // 鼠标选完后不保留焦点高亮（否则会留一块灰底）
              focusColor: Colors.transparent,
              value: bg.fit,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              items: [
                for (final v in BackgroundPrefs.fits)
                  DropdownMenuItem(
                    value: v,
                    child: Text(switch (v) {
                      'fit' => l.bgFitFit,
                      'stretch' => l.bgFitStretch,
                      'tile' => l.bgFitTile,
                      'center' => l.bgFitCenter,
                      'span' => l.bgFitSpan,
                      _ => l.bgFitFill,
                    }),
                  ),
              ],
              onChanged: (v) => v == null ? null : cfg.update({BackgroundPrefs.fitKey: v}),
            ),
          ),
          _PrefSlider(
            icon: Icons.blur_on,
            title: l.bgBlur,
            subtitle: l.bgBlurHint,
            value: bg.blur,
            min: 0,
            max: 48,
            label: (v) => v.round().toString(),
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.blurKey: v.roundToDouble()}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.brightness_6_outlined,
            title: l.bgDim,
            subtitle: Theme.of(context).brightness == Brightness.dark ? l.bgDimDarkHint : l.bgDimLightHint,
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
            title: l.bgPanelBlur,
            subtitle: l.bgPanelBlurHint,
            value: bg.panelBlur,
            min: 0,
            max: 40,
            label: (v) => v.round().toString(),
            onCommit: (v, {required persist}) =>
                cfg.update({BackgroundPrefs.panelBlurKey: v.roundToDouble()}, persist: persist),
          ),
          _PrefSlider(
            icon: Icons.opacity,
            title: l.bgOpacity,
            subtitle: l.bgOpacityHint,
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
            title: l.bgGlow,
            subtitle: l.bgGlowHint,
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
            title: Text(l.bgSolid),
            subtitle: Text(l.bgSolidHint),
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
    final l = context.l10n;
    ListTile link(IconData icon, String title, String subtitle, String url, {String? action}) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () => _open(url), child: Text(action ?? l.commonView)),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 2, 16, 16),
      children: [
        SettingsGroup(
          title: l.settingsGroupAbout,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.favorite),
              ),
              title: const Text(AppInfo.authorName),
              subtitle: Text(l.aboutDeveloper),
              trailing: FilledButton.icon(
                onPressed: () => _open(AppInfo.sponsorUrl),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: Text(l.aboutSponsor),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Image.asset('assets/icon/icon.png', width: 40, height: 40),
              title: Text(l.aboutAppVersion(AppInfo.version)),
              subtitle: Text(l.aboutDisclaimer),
            ),
            link(Icons.code, l.aboutSource, l.aboutSourceHint, AppInfo.repoUrl, action: l.commonOpen),
            link(Icons.gavel_outlined, l.aboutGuide, l.aboutGuideHint, '${AppInfo.repoUrl}/blob/main/PCL-GUIDE.md'),
          ],
        ),
        SettingsGroup(
          title: l.aboutCredits,
          children: [
            link(Icons.groups_outlined, 'PCL Community', l.aboutPclCeHint, AppInfo.pclCeRepoUrl),
            link(
              Icons.android,
              l.aboutAndroidRuntime,
              l.aboutAndroidRuntimeHint,
              '${AppInfo.repoUrl}/blob/main/android/runtime/NOTICE.md',
            ),
            link(Icons.flutter_dash, 'Flutter', l.aboutFlutterHint, 'https://flutter.dev'),
            link(Icons.palette_outlined, 'Material Design 3', l.aboutMaterialHint, 'https://m3.material.io'),
          ],
        ),
        Text(l.aboutTrademark, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
