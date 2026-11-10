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

/// 版本的标题：自动生成的文件夹名（如 fabric-loader-0.20.1-1.21.4）显示成「1.21.4 Fabric」，
/// 自己起过名字的版本保留原名
String versionTitle(InstanceInfo v) => isGeneratedVersionName(v.id) ? friendlyVersionName(v) : v.id;

/// 「1.21.4 Fabric」「1.12.2 Forge + OptiFine」「26.3 原版」
String friendlyVersionName(InstanceInfo v) {
  final parts = <String>[
    if (v.loader == Loader.vanilla) (v.nonRelease ? '快照' : '原版') else loaderNames[v.loader]!,
    for (final a in v.addons)
      if (a != v.loader) loaderNames[a]!,
  ];
  return '${v.gameVersion} ${parts.join(' + ')}';
}

final _generatedName = RegExp(
  r'^(\d[\w.\-]*|(fabric|quilt|legacyfabric)-loader-[\w.\-]+|neoforge-[\w.\-]+|\d[\w.\-]*-(forge|neoforge|optifine|liteloader|cleanroom)[\w.\-]*|[\w.\-]*-OptiFine_[\w.\-]+)$',
  caseSensitive: false,
);

/// 文件夹名是不是安装时自动生成的（没有自己起名字）
bool isGeneratedVersionName(String id) => _generatedName.hasMatch(id);

/// 版本的简短描述，例如「Fabric · 1.20.1」「Forge + OptiFine · 1.12.2」
String describeVersion(InstanceInfo v) {
  final parts = <String>[
    if (v.loader == Loader.vanilla) (v.nonRelease ? '快照' : '原版') else loaderNames[v.loader]!,
    for (final a in v.addons)
      if (a != v.loader) loaderNames[a]!,
  ];
  return '${parts.join(' + ')} · ${v.gameVersion}';
}
