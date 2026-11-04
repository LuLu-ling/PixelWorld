import 'instance.dart';

// 加载器的显示名称与版本的简短描述（界面与 AI 工具共用）

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
