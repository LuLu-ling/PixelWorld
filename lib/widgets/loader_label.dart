import 'package:flutter/material.dart';

import '../core/instance.dart';

const loaderNames = {
  Loader.vanilla: '原版',
  Loader.fabric: 'Fabric',
  Loader.legacyfabric: 'Legacy Fabric',
  Loader.quilt: 'Quilt',
  Loader.forge: 'Forge',
  Loader.neoforge: 'NeoForge',
  Loader.cleanroom: 'Cleanroom',
  Loader.liteloader: 'LiteLoader',
  Loader.optifine: 'OptiFine',
  Loader.labymod: 'LabyMod',
  Loader.unknown: '未知',
};

/// 版本的简短描述，例如「Fabric · 1.20.1」「Forge + OptiFine · 1.12.2」
String describeVersion(InstanceInfo v) {
  final parts = <String>[
    if (v.loader == Loader.vanilla) (v.nonRelease ? '快照' : '原版') else loaderNames[v.loader]!,
    for (final a in v.addons)
      if (a != v.loader) loaderNames[a]!,
  ];
  return '${parts.join(' + ')} · ${v.gameVersion}';
}

/// 版本图标：原版用方块，加载器用拼图，快照用实验瓶
IconData versionIcon(InstanceInfo v) {
  if (v.modable) return Icons.extension_outlined;
  if (v.optifine) return Icons.auto_awesome_outlined;
  if (v.nonRelease) return Icons.science_outlined;
  return Icons.view_in_ar_outlined;
}
