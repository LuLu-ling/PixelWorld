import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'android_storage.dart';
import 'download.dart' show VerifiedFiles;

/// 启动器自身的目录。游戏目录相关的路径见 [GamePaths]。
///
/// Windows 上分成两处：
///  - [configDir]（`%APPDATA%\Pixel World`）：配置、账户、AI 的 Key 等小文件；
///  - [appData]（`%LOCALAPPDATA%\Pixel World`）：Java 运行时、AI 工作区、对话记录、缓存等可以重新生成的数据。
/// 配置和账户每次保存后还会在启动器旁边的 `backup` 文件夹留一份，AppData 被清掉时自动恢复。
/// 其他平台两者相同，都是系统给应用的数据目录。
abstract final class Paths {
  static late final String appData;
  static late final String configDir;
  static bool _ready = false;

  static Future<void> init() async {
    final support = (await getApplicationSupportDirectory()).path;
    final roaming = Platform.environment['APPDATA'] ?? '';
    final local = Platform.environment['LOCALAPPDATA'] ?? '';
    if (Platform.isWindows && roaming.isNotEmpty && local.isNotEmpty) {
      configDir = p.join(roaming, 'Pixel World');
      appData = await migrateWindowsLayout(
        legacy: [support, p.join(roaming, 'PCL.PW', 'PCL.PW')],
        configDir: configDir,
        dataDir: p.join(local, 'Pixel World'),
      );
      await restoreConfigBackup(configDir, configBackupDir);
    } else {
      configDir = support;
      appData = support;
    }
    await Directory(appData).create(recursive: true);
    await Directory(configDir).create(recursive: true);
    _ready = true;
    // 启动时就备份一次，不用等到第一次保存
    for (final name in backedUpFileNames) {
      final f = File(p.join(configDir, name));
      if (f.existsSync()) await backupConfigFile(f);
    }
    await AndroidStorage.init();
    VerifiedFiles.storePath = p.join(appData, 'verified-files.json');
  }

  /// 启动器所在目录
  static String get launcherDir => p.dirname(Platform.resolvedExecutable);

  /// 配置与账户的备份（启动器旁边）
  static String get configBackupDir => p.join(launcherDir, 'backup');

  /// 配置或账户保存后，在启动器旁边留一份备份（只在 Windows 上）。
  /// 启动器装在没有写权限的位置时静默跳过。
  static Future<void> backupConfigFile(File file) async {
    if (!_ready || !Platform.isWindows) return;
    try {
      await Directory(configBackupDir).create(recursive: true);
      await file.copy(p.join(configBackupDir, p.basename(file.path)));
    } catch (_) {}
  }

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

/// 放在配置目录的文件（小、不能重新生成）
const configFileNames = ['config.json', 'accounts.dat', 'accounts.json', 'ai.dat', 'ai-search.dat'];

/// 启动器旁边备份的文件
const backedUpFileNames = ['config.json', 'accounts.dat'];

bool _hasContent(String dir) {
  try {
    final d = Directory(dir);
    return d.existsSync() && d.listSync().isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// 把旧的 Windows 数据目录（`%APPDATA%\Pixel World\Pixel World`，更早是 `%APPDATA%\PCL.PW\PCL.PW`）
/// 拆到新位置：配置与账户复制到 [configDir]，其余数据整体移到 [dataDir]（同一个盘时只是改名，
/// 已下载的 Java 不用重新下载），再把配置里指向旧目录的路径改到新位置。
///
/// 整体改名失败（某个文件或文件夹被占用）时逐项移动：移不动的留在原处，下次启动再试。
/// 配置里的路径只改已经移走的那几项，任何时候都指向文件实际所在的位置。
///
/// 返回这次启动应该使用的数据目录：一项都移不动（例如不在同一个盘）时继续用旧目录。
Future<String> migrateWindowsLayout({required List<String> legacy, required String configDir, required String dataDir}) async {
  final old = legacy.where((d) => !p.equals(d, dataDir) && !p.equals(d, configDir) && _hasContent(d)).firstOrNull;
  if (old == null) return dataDir;
  final config = File(p.join(configDir, 'config.json'));
  try {
    await Directory(configDir).create(recursive: true);
    // 1. 配置与账户：新位置还没有时才复制，不覆盖已经在用的新文件
    for (final name in configFileNames) {
      final from = File(p.join(old, name));
      final to = File(p.join(configDir, name));
      if (from.existsSync() && !to.existsSync()) await from.copy(to.path);
    }
    // 2. 其余数据移到 Local：先试整体改名（同一个盘时瞬间完成）
    final target = Directory(dataDir);
    if (!_hasContent(dataDir)) {
      try {
        if (target.existsSync()) await target.delete();
        await target.parent.create(recursive: true);
        await Directory(old).rename(dataDir);
        rewriteConfigPaths(config, old, dataDir);
      } on FileSystemException {
        // 下面逐项移动
      }
    }
    if (Directory(old).existsSync()) {
      await target.create(recursive: true);
      var moved = 0;
      final stuck = <String>{};
      for (final e in Directory(old).listSync()) {
        final name = p.basename(e.path);
        if (configFileNames.contains(name)) continue;
        final dest = p.join(dataDir, name);
        // 同名的保留新目录里的
        if (FileSystemEntity.typeSync(dest, followLinks: false) != FileSystemEntityType.notFound) continue;
        try {
          await e.rename(dest);
          moved++;
        } on FileSystemException {
          stuck.add(name);
        }
      }
      // 一项都移不动：继续用旧目录，配置里的路径也没改，保持一致
      if (moved == 0 && stuck.isNotEmpty) return old;
      // 指向旧目录的路径都改到新位置（包括还没创建的，例如默认游戏目录），只有还留在原处的不改
      rewriteConfigPaths(config, old, dataDir, keep: stuck);
    }
    // 配置文件已经在配置目录里，数据目录与旧目录里的副本删掉，避免以后弄混
    for (final name in configFileNames) {
      for (final dir in [dataDir, if (Directory(old).existsSync()) old]) {
        final f = File(p.join(dir, name));
        if (f.existsSync() && File(p.join(configDir, name)).existsSync()) await f.delete();
      }
    }
    if (Directory(old).existsSync() && !_hasContent(old)) await Directory(old).delete();
    // 旧品牌留下的空父目录（例如 Roaming\PCL.PW）
    final parent = Directory(old).parent;
    if (!p.equals(parent.path, configDir) && parent.existsSync() && !_hasContent(parent.path)) await parent.delete();
    return dataDir;
  } catch (_) {
    return _hasContent(dataDir) ? dataDir : old;
  }
}

/// 把配置文件里以 [from] 开头的路径改成以 [to] 开头（不区分大小写，只替换完整的路径段）。
/// [keep] 里的项（[from] 下第一级的名字）保持原样：它们还留在旧位置。
void rewriteConfigPaths(File config, String from, String to, {Set<String> keep = const {}}) {
  if (!config.existsSync()) return;
  final prefix = p.normalize(from);
  final kept = {for (final k in keep) k.toLowerCase()};
  Object? walk(Object? v) {
    if (v is String) {
      final n = p.normalize(v);
      if (p.equals(n, prefix)) return kept.isEmpty ? to : v;
      if (p.isWithin(prefix, n)) {
        final rel = p.relative(n, from: prefix);
        if (kept.contains(p.split(rel).first.toLowerCase())) return v;
        return p.join(to, rel);
      }
      return v;
    }
    if (v is List) return [for (final x in v) walk(x)];
    if (v is Map) return {for (final e in v.entries) e.key: walk(e.value)};
    return v;
  }

  try {
    final data = walk(jsonDecode(config.readAsStringSync()));
    config.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  } catch (_) {}
}

/// AppData 被清掉时，从启动器旁边的备份恢复配置与账户（只补缺失的文件）
Future<void> restoreConfigBackup(String configDir, String backupDir) async {
  for (final name in backedUpFileNames) {
    try {
      final to = File(p.join(configDir, name));
      final from = File(p.join(backupDir, name));
      if (!to.existsSync() && from.existsSync()) {
        await Directory(configDir).create(recursive: true);
        await from.copy(to.path);
      }
    } catch (_) {}
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
