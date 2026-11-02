import '../core/instance.dart';
import '../core/loaders.dart';

/// OptiFine 与加载器的搭配（参照 PCL：有加载器时 OptiFine 作为模组放进 mods）

/// 能与 OptiFine 一起安装的主加载器；null 表示原版（OptiFine 独立安装）
bool canAddOptiFine(Loader loader) => const {
  Loader.vanilla,
  Loader.forge,
  Loader.neoforge,
  Loader.fabric,
  Loader.quilt,
  Loader.legacyfabric,
  Loader.liteloader,
}.contains(loader);

/// 与 Forge 搭配时只列出兼容的 OptiFine（BMCLAPI 的 forge 字段为 N/A 的不兼容）
List<LoaderVersion> optiFineFor(Loader loader, List<LoaderVersion> all) =>
    loader == Loader.forge ? all.where((v) => v.requiredForge != null).toList() : all;

/// 选择 OptiFine 时的说明
String optiFineNote(Loader loader, LoaderVersion? v) => switch (loader) {
  Loader.vanilla => '将安装为独立的 OptiFine 版本',
  Loader.forge when v?.requiredForge?.isNotEmpty ?? false => '作为模组放进 mods；适配 Forge ${v!.requiredForge}，较新的 Forge 可能不兼容',
  Loader.forge => '作为模组放进 mods',
  Loader.neoforge => '作为模组放进 mods；OptiFine 官方不支持 NeoForge，可能无法加载',
  Loader.fabric || Loader.quilt || Loader.legacyfabric => '作为模组放进 mods；还需要另外安装 OptiFabric 模组才能加载',
  _ => '作为模组放进 mods',
};

Loader loaderOfKind(LoaderKind? k) => k == null ? Loader.vanilla : Loader.values.byName(k.name);
