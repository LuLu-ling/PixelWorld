import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'android_storage.dart';

/// 启动器自身的目录。游戏目录相关的路径见 [GamePaths]。
abstract final class Paths {
  static late final String appData;

  static Future<void> init() async {
    appData = (await getApplicationSupportDirectory()).path;
    await Directory(appData).create(recursive: true);
    await AndroidStorage.init();
  }

  /// 启动器所在目录
  static String get launcherDir => p.dirname(Platform.resolvedExecutable);

  /// 官方启动器的 .minecraft 位置
  static String get officialMinecraftDir {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    if (Platform.isWindows) return p.join(Platform.environment['APPDATA'] ?? home, '.minecraft');
    if (Platform.isMacOS) return p.join(home, 'Library', 'Application Support', 'minecraft');
    return p.join(home, '.minecraft');
  }

  static String get runtimeDir => p.join(appData, 'runtime');
}

/// 某个 .minecraft 目录下的各类路径
class GamePaths {
  const GamePaths(this.root);

  final String root;

  String get versions => p.join(root, 'versions');
  String versionDir(String id) => p.join(root, 'versions', id);
  String versionJson(String id) => p.join(root, 'versions', id, '$id.json');
  String versionJar(String id) => p.join(root, 'versions', id, '$id.jar');
  String get libraries => p.join(root, 'libraries');
  String get assets => p.join(root, 'assets');
}
