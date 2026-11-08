import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'android_storage.dart';
import 'download.dart' show VerifiedFiles;

/// 启动器自身的目录。游戏目录相关的路径见 [GamePaths]。
abstract final class Paths {
  static late final String appData;

  static Future<void> init() async {
    appData = (await getApplicationSupportDirectory()).path;
    if (Platform.isWindows) {
      final roaming = Platform.environment['APPDATA'];
      if (roaming != null && roaming.isNotEmpty) await migrateAppData(roaming, appData);
    }
    await Directory(appData).create(recursive: true);
    await AndroidStorage.init();
    VerifiedFiles.storePath = p.join(appData, 'verified-files.json');
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

  static var _tempSeq = 0;

  /// 临时文件路径，每次调用都不同：同时进行的任务（例如连点两次重试）不会互相覆盖或删掉对方的文件
  static File tempFile(String name) => File(
    p.join(Directory.systemTemp.path, 'pclpw-$pid-${DateTime.now().microsecondsSinceEpoch}-${_tempSeq++}-$name'),
  );
}

/// Windows 上 path_provider 用 exe 的公司/产品名拼数据目录。品牌从 PCL.PW 改成
/// Pixel World 后目录会变，首次启动时把旧目录整体迁移过来，避免设置、账号和
/// 已下载的 Java 运行时丢失。
Future<void> migrateAppData(String roaming, String target) async {
  final old = p.join(roaming, 'PCL.PW', 'PCL.PW');
  if (p.equals(old, target)) return;
  final oldDir = Directory(old);
  if (!await oldDir.exists()) return;
  final newDir = Directory(target);
  try {
    if (!await newDir.exists() || await newDir.list().isEmpty) {
      // 新目录还没用过：直接改名，已下载的运行时不用重新下载
      if (await newDir.exists()) await newDir.delete();
      await newDir.parent.create(recursive: true);
      await oldDir.rename(target);
    } else if (!await File(p.join(target, 'config.json')).exists()) {
      // 新目录已有其他内容时只复制关键文件
      for (final name in ['config.json', 'accounts.dat', 'verified-files.json']) {
        final f = File(p.join(old, name));
        if (await f.exists()) await f.copy(p.join(target, name));
      }
    }
  } catch (_) {
    // 迁移失败不阻止启动，继续使用新目录
  }
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
