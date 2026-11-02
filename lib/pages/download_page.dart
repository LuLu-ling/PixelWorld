import 'package:flutter/material.dart';

import '../widgets/side_nav.dart';

enum _Section { minecraft, mods, modpacks, resourcePacks, shaders }

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  _Section _section = _Section.minecraft;

  static const _groups = [
    SideNavGroup(null, [SideNavItem(_Section.minecraft, 'Minecraft', Icons.view_in_ar_outlined)]),
    SideNavGroup('社区资源', [
      SideNavItem(_Section.mods, '模组', Icons.extension_outlined),
      SideNavItem(_Section.modpacks, '整合包', Icons.inventory_2_outlined),
      SideNavItem(_Section.resourcePacks, '资源包', Icons.layers_outlined),
      SideNavItem(_Section.shaders, '光影包', Icons.wb_sunny_outlined),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final label = _groups.expand((g) => g.items).firstWhere((i) => i.value == _section).label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SideNav(groups: _groups, value: _section, onChanged: (s) => setState(() => _section = s)),
        Expanded(child: ContentPanel(child: MigratingPlaceholder(title: label))),
      ],
    );
  }
}
