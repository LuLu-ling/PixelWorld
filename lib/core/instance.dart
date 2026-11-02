import 'dart:io';

import 'package:path/path.dart' as p;

import 'instance_config.dart';
import 'paths.dart';
import 'version.dart';

/// 加载器与附加组件
enum Loader { vanilla, fabric, legacyfabric, quilt, forge, neoforge, cleanroom, liteloader, optifine, labymod, unknown }

const _modable = {
  Loader.fabric,
  Loader.legacyfabric,
  Loader.quilt,
  Loader.forge,
  Loader.liteloader,
  Loader.neoforge,
  Loader.cleanroom,
};

/// 对应 PCL-CE 的 McInstance 中与分类相关的信息
class InstanceInfo {
  InstanceInfo({
    required this.id,
    required this.type,
    required this.releaseTime,
    required this.loader,
    required this.addons,
    required this.gameVersion,
    required this.nonRelease,
    required this.isolation,
  });

  final String id;
  final String type;
  final String? releaseTime;
  final Loader loader;

  /// 同时安装的附加组件，例如 Forge + OptiFine
  final List<Loader> addons;

  /// 对应的原版版本号
  final String gameVersion;

  /// 是否为非正式版（快照、远古版、愚人节版本）
  final bool nonRelease;

  /// 版本隔离：已决定的结果；null 表示首次启动时按全局策略决定
  final bool? isolation;

  /// 可安装 Mod（PCL 的 Modable）
  bool get modable => addons.any(_modable.contains);
  bool get optifine => addons.contains(Loader.optifine);
}

List<Loader> _detectAddons(VersionJson v) {
  final main = v.mainClass;
  final libs = v.libraries.map((l) => '${l['name']}'.toLowerCase()).toList();
  bool has(String prefix) => libs.any((n) => n.startsWith(prefix));
  final out = <Loader>[];
  // LabyMod 的依赖库里也有 net.neoforged 等，先判断它，避免被识别成 NeoForge
  if (has('net.labymod:labymod') || main.toLowerCase().contains('labymod')) {
    return [Loader.labymod, if (has('optifine:optifine')) Loader.optifine];
  }
  if (has('com.cleanroommc:cleanroom')) {
    out.add(Loader.cleanroom);
  } else if (has('net.neoforged')) {
    out.add(Loader.neoforge);
  } else if (has('net.minecraftforge:forge') || has('net.minecraftforge:fmlloader') || main.contains('cpw.mods')) {
    out.add(Loader.forge);
  }
  if (has('org.quiltmc:quilt-loader')) {
    out.add(Loader.quilt);
  } else if (has('net.legacyfabric')) {
    out.add(Loader.legacyfabric);
  } else if (has('net.fabricmc:fabric-loader')) {
    out.add(Loader.fabric);
  }
  if (has('com.mumfrey:liteloader')) out.add(Loader.liteloader);
  if (has('optifine:optifine')) out.add(Loader.optifine);
  return out;
}

/// 沿 inheritsFrom 找到原版版本号
Future<String> _rootVersionId(GamePaths g, String id, [int depth = 0]) async {
  final v = await readVersionJson(g, id);
  if (v.inheritsFrom == null || depth > 8) return v.clientVersion ?? v.id;
  return _rootVersionId(g, v.inheritsFrom!, depth + 1);
}

/// 已知的愚人节版本（不区分大小写的前缀）
const _knownFools = [
  '2.0',
  '15w14a',
  '1.rv-pre1',
  '3d shareware',
  '20w14infinite',
  '20w14∞',
  '22w13oneblockatatime',
  '23w13a_or_b',
  '24w14potato',
  '25w14craftmine',
];

/// 愚人节版本：已知名单，或在 4 月 1 日前后发布、且版本号不符合常规快照格式的快照
bool isAprilFools(String id, String? releaseTime) {
  final lower = id.toLowerCase();
  if (_knownFools.any(lower.startsWith)) return true;
  final t = releaseTime == null ? null : DateTime.tryParse(releaseTime)?.toUtc();
  if (t == null) return false;
  final near = (t.month == 3 && t.day == 31) || (t.month == 4 && t.day <= 2);
  final regular =
      RegExp(r'^\d{2}w\d{2}[a-z]$').hasMatch(lower) ||
      RegExp(r'-(pre|rc|snapshot)').hasMatch(lower) ||
      RegExp(r'^[\d.]+$').hasMatch(lower);
  return near && !regular;
}

/// 愚人节 / 远古 / 快照均视为非正式版
bool _isNonRelease(VersionJson v, String vanilla, String name) {
  final type = v.type ?? '';
  if (type == 'fool' || isAprilFools(vanilla, v.releaseTime)) return true;
  if (type.startsWith('old_')) return true;
  if (type == 'snapshot' || type == 'pending') return true;
  if (RegExp('combat', caseSensitive: false).hasMatch(name)) return true;
  final lower = vanilla.toLowerCase();
  return ['w', 'snapshot', 'rc', 'pre', 'experimental', '-'].any(lower.contains);
}

Future<InstanceInfo> analyzeInstance(GamePaths g, String id) async {
  final self = await readVersionJson(g, id);
  final v = await resolveVersion(g, id);
  final addons = _detectAddons(v);
  final gameVersion = await _rootVersionId(g, id).catchError((_) => id);
  final loader = addons.firstWhere(
    (a) => _modable.contains(a) || a == Loader.labymod,
    orElse: () => addons.isNotEmpty ? addons.first : (self.inheritsFrom != null ? Loader.unknown : Loader.vanilla),
  );
  return InstanceInfo(
    id: id,
    type: self.type ?? 'release',
    releaseTime: self.releaseTime ?? v.releaseTime,
    loader: loader,
    addons: addons,
    gameVersion: gameVersion,
    nonRelease: _isNonRelease(v, gameVersion, id),
    isolation: readInstanceSettings(g.versionDir(id)).isolation,
  );
}

bool _hasContent(String dir, {required bool files}) {
  try {
    return Directory(dir).listSync().any((e) => files ? e is File : e is Directory);
  } catch (_) {
    return false;
  }
}

/// 按 PCL-CE 的规则决定版本隔离（McInstance.PathIndie）
bool shouldIsolate(GamePaths g, InstanceInfo info, int isolationMode) {
  final dir = g.versionDir(info.id);
  // 版本文件夹里已有 mods 或存档，说明之前就是隔离使用的
  if (_hasContent(p.join(dir, 'mods'), files: true) || _hasContent(p.join(dir, 'saves'), files: false)) return true;
  final labyOrModable = info.addons.contains(Loader.labymod) || info.modable;
  return switch (isolationMode) {
    0 => false,
    1 => labyOrModable,
    2 => info.nonRelease,
    3 => labyOrModable || info.nonRelease,
    _ => true,
  };
}

/// 实际运行目录；首次使用时把隔离结果写入实例配置，之后不再随全局设置变化（与 PCL-CE 一致）
Future<String> gameDirFor(GamePaths g, InstanceInfo info, int isolationMode, {bool persist = false}) async {
  var isolate = info.isolation;
  if (isolate == null) {
    isolate = shouldIsolate(g, info, isolationMode);
    if (persist) await writeInstanceRaw(g.versionDir(info.id), {'VersionArgumentIndieV2': isolate});
  }
  return isolate ? g.versionDir(info.id) : g.root;
}

/// 列出当前文件夹中已安装的版本，按发布时间从新到旧排序
Future<List<InstanceInfo>> installedVersions(GamePaths g) async {
  final dir = Directory(g.versions);
  if (!dir.existsSync()) return [];
  final out = <InstanceInfo>[];
  for (final e in dir.listSync().whereType<Directory>()) {
    final id = p.basename(e.path);
    if (!File(g.versionJson(id)).existsSync()) continue;
    try {
      out.add(await analyzeInstance(g, id));
    } catch (_) {
      // 不是有效的版本目录
    }
  }
  out.sort((a, b) => (b.releaseTime ?? '').compareTo(a.releaseTime ?? ''));
  return out;
}
