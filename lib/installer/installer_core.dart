import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../app_info.dart';

/// Windows 安装与卸载。安装包外壳（installer/Shell.cs）解压出程序后，
/// 以 --pw-install 启动本程序显示安装界面；已安装的程序以 --pw-uninstall 启动显示卸载界面。

/// 安装和打包用的主程序文件名。
/// v0.3.3 及以前的便携版更新只认 PCL.PW.exe，所以要等认得两个名字的版本作为正式版发布之后，
/// 再改成 Pixel World.exe（同时改 installer/Shell.cs 的 AppExe 和 tool/build_installer.dart）。
const exeName = 'PCL.PW.exe';

/// 认得的所有主程序文件名，新名字在前
const appExeNames = ['Pixel World.exe', 'PCL.PW.exe'];
const _regKey = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PCL.PW';
const _manifestName = '.pw-install.json';

enum InstallerMode { install, uninstall }

InstallerMode? installerModeFromArgs(List<String> args) {
  if (!Platform.isWindows) return null;
  if (args.contains('--pw-install')) return InstallerMode.install;
  if (args.contains('--pw-uninstall')) return InstallerMode.uninstall;
  return null;
}

String? argValue(List<String> args, String name) =>
    args.where((a) => a.startsWith('--$name=')).map((a) => a.substring(name.length + 3)).firstOrNull;

String get _env => Platform.environment['LOCALAPPDATA'] ?? '';

String get defaultInstallDir => p.join(_env, 'Programs', AppInfo.name);

/// 程序当前所在目录（安装时为外壳解压出的临时目录）
String get sourceDir => p.dirname(Platform.resolvedExecutable);

/// 目录里是否已经有本启动器的安装（有安装清单或主程序）
bool isInstallDir(String dir) {
  if (dir.isEmpty) return false;
  final d = p.normalize(p.absolute(dir));
  return File(p.join(d, _manifestName)).existsSync() || appExeNames.any((n) => File(p.join(d, n)).existsSync());
}

/// 旧版本使用过的程序目录名
const _legacyInstallNames = ['Pixel World', 'PCL.PW', 'PixelsWorld Launcher'];

String? _registryInstallDir() {
  try {
    final r = Process.runSync('reg.exe', ['query', _regKey, '/v', 'InstallLocation']);
    if (r.exitCode != 0) return null;
    final m = RegExp(r'InstallLocation\s+REG_SZ\s+(.+)').firstMatch('${r.stdout}');
    return m?.group(1)?.trim();
  } catch (_) {
    return null;
  }
}

/// 查找已经安装的位置：安装程序默认升级原目录，而不是在别处再装一份。
/// 依次检查卸载信息里的 InstallLocation、旧品牌的默认目录和 Programs 下的其他子目录。
String? findInstalledDir() {
  final reg = _registryInstallDir();
  if (reg != null && isInstallDir(reg)) return p.normalize(p.absolute(reg));

  final programs = p.join(_env, 'Programs');
  for (final name in _legacyInstallNames) {
    final dir = p.join(programs, name);
    if (isInstallDir(dir)) return p.normalize(dir);
  }

  try {
    final dir = Directory(programs);
    if (dir.existsSync()) {
      for (final e in dir.listSync()) {
        if (e is Directory && isInstallDir(e.path)) return p.normalize(e.path);
      }
    }
  } catch (_) {
    // 没有权限时忽略，继续使用默认目录
  }
  return null;
}

/// 启动器的用户数据目录：配置与账户在 Roaming，游戏文件夹、Java 等数据在 Local（见 lib/core/paths.dart）
List<String> get userDataDirs => [
  for (final env in ['APPDATA', 'LOCALAPPDATA'])
    if ((Platform.environment[env] ?? '').isNotEmpty) p.join(Platform.environment[env]!, AppInfo.name),
];

class Manifest {
  Manifest(this.files, this.shortcuts);

  /// 相对安装目录的路径，卸载时只删除这些文件
  final List<String> files;
  final List<String> shortcuts;

  Map<String, dynamic> toJson() => {'files': files, 'shortcuts': shortcuts};
}

Manifest? readManifest(String dir) {
  try {
    final j = jsonDecode(File(p.join(dir, _manifestName)).readAsStringSync()) as Map<String, dynamic>;
    return Manifest((j['files'] as List).cast<String>(), (j['shortcuts'] as List).cast<String>());
  } catch (_) {
    return null;
  }
}

bool sameDir(String a, String b) =>
    p.normalize(p.absolute(a)).toLowerCase() == p.normalize(p.absolute(b)).toLowerCase();

String get _desktop => p.join(Platform.environment['USERPROFILE'] ?? '', 'Desktop', '${AppInfo.name}.lnk');
String get _startMenu => p.join(
  Platform.environment['APPDATA'] ?? '',
  'Microsoft',
  'Windows',
  'Start Menu',
  'Programs',
  '${AppInfo.name}.lnk',
);

/// 删除清单里的文件和变空的文件夹，其他文件不动
Future<void> _removeFiles(String dir, List<String> files) async {
  final parents = <String>{};
  for (final f in files) {
    final file = File(p.join(dir, f));
    if (file.existsSync()) await file.delete();
    for (var d = p.dirname(f); d != '.'; d = p.dirname(d)) {
      parents.add(d);
    }
  }
  for (final d in parents.toList()..sort((a, b) => b.length.compareTo(a.length))) {
    try {
      await Directory(p.join(dir, d)).delete();
    } catch (_) {
      // 文件夹里还有用户自己的文件
    }
  }
}

/// 运行中的 exe 无法以写方式打开
Future<void> _ensureNotRunning(String dir) async {
  for (final name in appExeNames) {
    final exe = File(p.join(dir, name));
    if (!exe.existsSync()) continue;
    try {
      final raf = await exe.open(mode: FileMode.append);
      await raf.close();
    } catch (_) {
      throw Exception('${AppInfo.name} 正在运行，请先关闭它再安装');
    }
  }
}

Future<void> _createShortcut(String path, String target, String cwd) async {
  String q(String s) => s.replaceAll("'", "''");
  final r = await Process.run('powershell.exe', [
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    "\$s = (New-Object -ComObject WScript.Shell).CreateShortcut('${q(path)}'); "
        "\$s.TargetPath = '${q(target)}'; \$s.WorkingDirectory = '${q(cwd)}'; "
        "\$s.Description = '${AppInfo.fullName}'; \$s.Save()",
  ]);
  if (r.exitCode != 0) throw Exception('无法创建快捷方式：$path');
}

Future<void> _writeRegistry(String dir, int size) async {
  final exe = p.join(dir, exeName);
  final values = [
    ('DisplayName', 'REG_SZ', AppInfo.fullName),
    ('DisplayVersion', 'REG_SZ', AppInfo.version),
    ('Publisher', 'REG_SZ', 'Pixel World'),
    ('DisplayIcon', 'REG_SZ', '$exe,0'),
    ('InstallLocation', 'REG_SZ', dir),
    ('UninstallString', 'REG_SZ', '"$exe" --pw-uninstall'),
    ('EstimatedSize', 'REG_DWORD', '${(size / 1024).round()}'),
    ('NoModify', 'REG_DWORD', '1'),
    ('NoRepair', 'REG_DWORD', '1'),
  ];
  for (final (name, type, data) in values) {
    final r = await Process.run('reg.exe', ['add', _regKey, '/v', name, '/t', type, '/d', data, '/f']);
    if (r.exitCode != 0) throw Exception('写入卸载信息失败');
  }
}

Future<void> install(
  String dir, {
  required bool desktopShortcut,
  required bool startMenuShortcut,
  required void Function(String stage, double? value) report,
}) async {
  if (sameDir(dir, sourceDir)) throw Exception('不能安装到安装程序所在的文件夹');
  await _ensureNotRunning(dir);

  final previous = readManifest(dir);
  final files = Directory(sourceDir).listSync(recursive: true).whereType<File>().toList();
  final total = files.fold<int>(0, (s, f) => s + f.lengthSync());
  final copied = <String>[];
  try {
    var done = 0;
    for (final f in files) {
      final rel = p.relative(f.path, from: sourceDir);
      report('正在复制 ${p.basename(rel)}', total == 0 ? 0 : done / total);
      final target = File(p.join(dir, rel));
      await target.parent.create(recursive: true);
      await f.copy(target.path);
      copied.add(rel);
      done += f.lengthSync();
    }
  } catch (_) {
    // 全新安装失败时不留下半套文件；覆盖安装则保留，重试即可
    if (previous == null) await _removeFiles(dir, copied).catchError((_) {});
    rethrow;
  }

  report('正在完成安装…', null);
  if (previous != null) {
    final keep = copied.map((f) => f.toLowerCase()).toSet();
    await _removeFiles(dir, previous.files.where((f) => !keep.contains(f.toLowerCase())).toList());
  }

  final exe = p.join(dir, exeName);
  final shortcuts = <String>[];
  for (final (wanted, path) in [(desktopShortcut, _desktop), (startMenuShortcut, _startMenu)]) {
    if (wanted) {
      await _createShortcut(path, exe, dir);
      shortcuts.add(path);
    } else if (previous?.shortcuts.contains(path) ?? false) {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    }
  }

  await File(p.join(dir, _manifestName)).writeAsString(jsonEncode(Manifest(copied, shortcuts).toJson()));
  await _writeRegistry(dir, total);
}

/// 运行中的程序删不掉自己，把清单交给临时目录里的清理程序，等本程序退出后删除
Future<void> startCleanup(String dir, {required bool removeData}) async {
  final manifest = readManifest(dir);
  if (manifest == null) throw Exception('找不到安装清单，无法确定要删除哪些文件');

  final parents = <String>{dir};
  for (final f in manifest.files) {
    for (var d = p.dirname(f); d != '.'; d = p.dirname(d)) {
      parents.add(p.join(dir, d));
    }
  }
  final lines = [
    'pid\t$pid',
    for (final f in manifest.files) 'file\t${p.join(dir, f)}',
    'file\t${p.join(dir, _manifestName)}',
    for (final s in manifest.shortcuts) 'file\t$s',
    for (final d in parents) 'dir\t$d',
    if (removeData)
      for (final d in userDataDirs) 'tree\t$d',
    'key\t$_regKey',
  ];
  final id = 'pw-cleanup-$pid';
  final tmp = Directory.systemTemp.path;
  final helper = p.join(tmp, '$id.exe');
  final plan = p.join(tmp, '$id.txt');
  await File(p.join(dir, 'pw-cleanup.exe')).copy(helper);
  await File(plan).writeAsString(lines.join('\n'));
  await Process.start(helper, ['--cleanup', plan], mode: ProcessStartMode.detached);
}
