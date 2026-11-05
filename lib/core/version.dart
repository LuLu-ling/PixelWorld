import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:path/path.dart' as p;

import 'paths.dart';

/// Mojang 版本 JSON。字段较多且各加载器写法不一，直接包装 Map 读取。
class VersionJson {
  VersionJson(this.raw);

  final Map<String, dynamic> raw;

  String get id => raw['id'] as String;
  set id(String v) => raw['id'] = v;
  String? get type => raw['type'] as String?;
  String? get releaseTime => raw['releaseTime'] as String?;
  String? get inheritsFrom => raw['inheritsFrom'] as String?;

  /// 显式指定的游戏 jar（LiteLoader 等直接使用原版的 jar）
  String? get jar => raw['jar'] as String?;

  /// 版本文件夹名。PCL 与官方启动器都以文件夹名为准：改过名的版本，JSON 中的 id 可能还是旧名称，
  /// 游戏 jar 却已经跟着文件夹改名了
  String get folder => (raw['_folder'] as String?) ?? id;

  /// 继承链最底层（原版）的版本文件夹，客户端 jar 从这里下载
  String get rootJar => (raw['_rootJar'] as String?) ?? jar ?? folder;

  /// 启动时使用的游戏 jar。继承的版本没有指定 jar 时用自己文件夹里的副本（与官方启动器一致）：
  /// Forge 1.17+ 按版本名在模块系统中排除游戏 jar，直接用原版的 jar 会导致包冲突
  String get launchJar => jar ?? folder;
  String get mainClass => (raw['mainClass'] as String?) ?? '';
  String? get minecraftArguments => raw['minecraftArguments'] as String?;
  Map<String, dynamic>? get arguments => raw['arguments'] as Map<String, dynamic>?;
  List<dynamic>? get gameArguments => arguments?['game'] as List<dynamic>?;
  List<dynamic>? get jvmArguments => arguments?['jvm'] as List<dynamic>?;
  Map<String, dynamic>? get assetIndex => raw['assetIndex'] as Map<String, dynamic>?;
  String? get assets => raw['assets'] as String?;
  Map<String, dynamic>? get clientDownload => (raw['downloads'] as Map?)?['client'] as Map<String, dynamic>?;
  List<Map<String, dynamic>> get libraries =>
      ((raw['libraries'] as List?) ?? const []).whereType<Map<String, dynamic>>().toList();
  int? get javaMajor => ((raw['javaVersion'] as Map?)?['majorVersion'] as num?)?.toInt();
  String? get javaComponent => (raw['javaVersion'] as Map?)?['component'] as String?;
  Map<String, dynamic>? get loggingClient => (raw['logging'] as Map?)?['client'] as Map<String, dynamic>?;

  /// 原版版本号（部分加载器写在 clientVersion）
  /// LabyMod 的版本 JSON 是完整的独立版本，原版版本号写在 _minecraftVersion
  String? get clientVersion => (raw['clientVersion'] ?? raw['_minecraftVersion']) as String?;
}

// ---------- 规则判断 ----------

String get osName => Platform.isWindows ? 'windows' : (Platform.isMacOS ? 'osx' : 'linux');

bool get _isArm64 =>
    Abi.current() == Abi.windowsArm64 || Abi.current() == Abi.macosArm64 || Abi.current() == Abi.linuxArm64;
bool get _isX86 => Abi.current() == Abi.windowsIA32 || Abi.current() == Abi.linuxIA32;

bool rulesAllow(List<dynamic>? rules, [Map<String, bool> features = const {}]) {
  if (rules == null || rules.isEmpty) return true;
  var result = false;
  for (final rule in rules.whereType<Map<String, dynamic>>()) {
    var match = true;
    final os = rule['os'] as Map<String, dynamic>?;
    if (os != null) {
      if (os['name'] != null && os['name'] != osName) match = false;
      if (os['arch'] == 'x86' && !_isX86) match = false;
      if (os['arch'] == 'arm64' && !_isArm64) match = false;
    }
    final f = rule['features'] as Map<String, dynamic>?;
    if (f != null) {
      for (final e in f.entries) {
        if ((features[e.key] ?? false) != e.value) match = false;
      }
    }
    if (match) result = rule['action'] == 'allow';
  }
  return result;
}

// ---------- Maven 坐标 ----------

/// group:artifact:version[:classifier][@ext] -> 相对路径
String mavenPath(String name) {
  var ext = 'jar';
  var coord = name;
  final at = coord.indexOf('@');
  if (at >= 0) {
    ext = coord.substring(at + 1);
    coord = coord.substring(0, at);
  }
  final parts = coord.split(':');
  final group = parts[0], artifact = parts[1], version = parts[2];
  final classifier = parts.length > 3 ? parts[3] : null;
  final file = '$artifact-$version${classifier != null ? '-$classifier' : ''}.$ext';
  return [...group.split('.'), artifact, version, file].join('/');
}

/// 用于去重的键：group:artifact[:classifier]，忽略版本
String _libKey(String name) {
  final parts = name.split('@').first.split(':');
  return [parts[0], if (parts.length > 1) parts[1], if (parts.length > 3) parts[3]].join(':');
}

// ---------- 读取 & 合并继承 ----------

Future<VersionJson> readVersionJson(GamePaths g, String id) async {
  final f = File(g.versionJson(id));
  if (!f.existsSync()) throw Exception('版本 $id 未安装');
  final raw = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
  return VersionJson(raw..['_folder'] = id);
}

/// 解析 inheritsFrom（Fabric 等加载器），返回完整版本 JSON
Future<VersionJson> resolveVersion(GamePaths g, String id, [int depth = 0]) async {
  final self = await readVersionJson(g, id);
  final parentId = self.inheritsFrom;
  if (parentId == null || depth > 8) return self;
  final parent = await resolveVersion(g, parentId, depth + 1);

  // 子版本库优先，同一构件只保留一份
  final seen = <String>{};
  final libraries = <Map<String, dynamic>>[];
  for (final lib in [...self.libraries, ...parent.libraries]) {
    if (seen.add(_libKey('${lib['name']}'))) libraries.add(lib);
  }

  final merged = <String, dynamic>{...parent.raw, ...self.raw};
  merged['jar'] = self.jar ?? parent.jar;
  merged['_rootJar'] = parent.rootJar;
  merged['mainClass'] = self.raw['mainClass'] ?? parent.raw['mainClass'];
  merged['libraries'] = libraries;
  if (self.arguments != null || parent.arguments != null) {
    merged['arguments'] = {
      'game': [...?parent.gameArguments, ...?self.gameArguments],
      'jvm': [...?parent.jvmArguments, ...?self.jvmArguments],
    };
  }
  for (final k in ['minecraftArguments', 'assetIndex', 'assets', 'downloads', 'javaVersion', 'logging']) {
    merged[k] = self.raw[k] ?? parent.raw[k];
  }
  return VersionJson(merged);
}

// ---------- 库文件解析 ----------

class ResolvedLibrary {
  ResolvedLibrary({
    required this.name,
    required this.path,
    required this.url,
    this.sha1,
    this.size,
    required this.native,
    required this.classpath,
    required this.exclude,
  });

  final String name;
  final String path;
  final String url;
  final String? sha1;
  final int? size;

  /// 需要解压到 natives 目录
  final bool native;

  /// 是否加入 classpath
  final bool classpath;
  final List<String> exclude;
}

const _defaultLibBase = 'https://libraries.minecraft.net/';

/// Apple 芯片的 Mac：1.13～1.18 自带的 LWJGL 3.1/3.2 没有 arm64 本地库，换成 3.3.1
/// （Mojang 的库服务器上有 natives-macos-arm64），java-objc-bridge 1.0.0 换成同时支持 arm64 的 1.1。
/// 先按规则筛选，替换后的库不再带规则。LWJGL 2（1.12.2 及更早）不在这里处理。
/// Apple 芯片的 Mac 上，这个版本是否使用了替换后的 LWJGL 3.3.1（需要配套的 GLFW，见 mac_glfw.dart）
bool needsAppleSiliconGlfw(List<Map<String, dynamic>> libraries) =>
    Platform.isMacOS &&
    _isArm64 &&
    libraries.any((l) => RegExp(r'^org\.lwjgl:lwjgl:3\.[12]\.').hasMatch('${l['name']}'));

const _lwjgl2 = '2.9.4-nightly-20150209';
const _lwjgl2Arm64 = {
  'url': 'https://github.com/MinecraftMachina/lwjgl/releases/download/2.9.4-20150209-mmachina.2/lwjgl-platform-2.9.4-nightly-20150209-natives-osx.jar',
  'sha1': 'eff546c0b319d6ffc7a835652124c18089c67f36',
  'size': 488316,
};
const _jinputArm64 = {
  'url': 'https://github.com/r58Playz/jinput-m1/raw/main/plugins/OSX/bin/jinput-platform-2.0.5.jar',
  'sha1': '5189eb40db3087fb11ca063b68fa4f4c20b199dd',
  'size': 10031,
};

/// 只有 arm64 本地库的旧格式 natives 库
Map<String, dynamic> _arm64Natives(String name, Map<String, Object> download) => {
  'name': name,
  'natives': {'osx': 'natives-osx-arm64'},
  'downloads': {
    'classifiers': {
      'natives-osx-arm64': {...download, 'path': mavenPath('$name:natives-osx-arm64')},
    },
  },
};

List<Map<String, dynamic>> appleSiliconLibraries(List<Map<String, dynamic>> libraries) {
  final out = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final lib in libraries) {
    if (!rulesAllow(lib['rules'] as List?)) continue;
    final parts = '${lib['name']}'.split(':');
    if (parts.length >= 3 && parts[0] == 'org.lwjgl' && RegExp(r'^3\.[12]\.').hasMatch(parts[2])) {
      final artifact = parts[1];
      if (!seen.add(artifact)) continue;
      out.add({'name': 'org.lwjgl:$artifact:3.3.1'});
      out.add({'name': 'org.lwjgl:$artifact:3.3.1:natives-macos-arm64'});
      continue;
    }
    // LWJGL 2（1.12.2 及更早）：Java 部分统一用 2.9.4，本地库用社区编译的 arm64 版本（与 Prism Launcher 相同）
    if (parts.length >= 3 && parts[0] == 'org.lwjgl.lwjgl' && parts[2].startsWith('2.9.')) {
      final artifact = parts[1];
      if (!seen.add(artifact)) continue;
      if (artifact == 'lwjgl-platform') {
        out.add(_arm64Natives('org.lwjgl.lwjgl:lwjgl-platform:$_lwjgl2', _lwjgl2Arm64));
      } else {
        out.add({'name': 'org.lwjgl.lwjgl:$artifact:$_lwjgl2'});
      }
      continue;
    }
    if (parts.length >= 3 && parts[0] == 'net.java.jinput' && parts[1] == 'jinput-platform') {
      if (seen.add('jinput-platform')) out.add(_arm64Natives('${lib['name']}', _jinputArm64));
      continue;
    }
    if (parts.length >= 3 && parts[0] == 'ca.weblite' && parts[1] == 'java-objc-bridge' && parts[2] == '1.0.0') {
      if (seen.add('java-objc-bridge')) out.add({'name': 'ca.weblite:java-objc-bridge:1.1'});
      continue;
    }
    out.add(lib);
  }
  return out;
}

List<ResolvedLibrary> resolveLibraries(GamePaths g, VersionJson v) {
  final out = <ResolvedLibrary>[];
  final archBits = _isX86 ? '32' : '64';
  final libs = Platform.isMacOS && _isArm64 ? appleSiliconLibraries(v.libraries) : v.libraries;
  for (final lib in libs) {
    if (!rulesAllow(lib['rules'] as List?)) continue;
    final name = '${lib['name']}';
    final exclude = (((lib['extract'] as Map?)?['exclude'] as List?) ?? const []).map((e) => '$e').toList();
    final downloads = lib['downloads'] as Map<String, dynamic>?;
    final natives = lib['natives'] as Map<String, dynamic>?;
    final libUrl = lib['url'] as String?;

    // 旧格式 natives：通过 classifier 下载
    final classifier = (natives?[osName] as String?)?.replaceAll(r'${arch}', archBits);
    if (classifier != null) {
      final a = (downloads?['classifiers'] as Map?)?[classifier] as Map<String, dynamic>?;
      final rel = (a?['path'] as String?) ?? mavenPath('$name:$classifier');
      out.add(
        ResolvedLibrary(
          name: name,
          path: p.join(g.libraries, rel),
          url: (a?['url'] as String?) ?? '${libUrl ?? _defaultLibBase}$rel',
          sha1: a?['sha1'] as String?,
          size: (a?['size'] as num?)?.toInt(),
          native: true,
          classpath: false,
          exclude: exclude,
        ),
      );
    }

    final a = downloads?['artifact'] as Map<String, dynamic>?;
    // 只有 natives、没有 downloads 信息的旧格式库（如 lwjgl-platform）不存在主 jar
    final nativesOnly = natives != null && downloads == null;
    if (a != null || (downloads == null && !nativesOnly)) {
      final rel = (a?['path'] as String?) ?? mavenPath(name);
      var base = libUrl ?? _defaultLibBase;
      if (!base.endsWith('/')) base = '$base/';
      out.add(
        ResolvedLibrary(
          name: name,
          path: p.join(g.libraries, rel),
          // 下载地址为空的库由安装器在本地生成，只加入 classpath、不下载（与官方启动器一致）
          url: (a?['url'] as String?) ?? base + rel,
          sha1: (a?['sha1'] ?? lib['sha1']) as String?,
          size: ((a?['size'] ?? lib['size']) as num?)?.toInt(),
          // 新格式（1.19+）natives 直接放在 classpath 中，同时也解压一份
          native: RegExp(r':natives-').hasMatch(name),
          classpath: true,
          exclude: exclude,
        ),
      );
    }
  }
  return out;
}
