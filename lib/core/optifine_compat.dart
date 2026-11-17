import 'instance.dart';
import 'loaders.dart';
import 'i18n/strings.dart';

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
  Loader.vanilla => tr.optifineCompatWillInstalledAsSeparate,
  Loader.forge when v?.requiredForge?.isNotEmpty ?? false => tr.optifineCompatGoesIntoModsAs(v!.requiredForge ?? ''),
  Loader.forge => tr.optifineCompatGoesIntoModsAs2,
  Loader.neoforge => tr.optifineCompatGoesIntoModsAs3,
  Loader.fabric || Loader.quilt || Loader.legacyfabric => tr.optifineCompatGoesIntoModsAs4,
  _ => tr.optifineCompatGoesIntoModsAs2,
};

Loader loaderOfKind(LoaderKind? k) => k == null ? Loader.vanilla : Loader.values.byName(k.name);
