import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:path/path.dart' as p;

import 'download.dart';
import 'instance_config.dart';
import 'paths.dart';
import 'task.dart';
import 'version.dart';

final _javaExe = Platform.isWindows ? 'java.exe' : 'java';

class JavaInfo {
  JavaInfo({required this.path, required this.version, required this.major, required this.is64, required this.managed});

  final String path;
  final String version;
  final int major;
  final bool is64;

  /// 启动器下载的 Mojang 运行时
  final bool managed;
}

String _managedJavaPath(String component) {
  final base = p.join(Paths.runtimeDir, component);
  return Platform.isMacOS
      ? p.join(base, 'jre.bundle', 'Contents', 'Home', 'bin', 'java')
      : p.join(base, 'bin', _javaExe);
}

/// 解析 `java -version` 输出
Future<JavaInfo?> probeJava(String path, {bool managed = false}) async {
  try {
    final r = await Process.run(path, ['-version']).timeout(const Duration(seconds: 8));
    final err = '${r.stderr}';
    final m = RegExp(r'version "([^"]+)"').firstMatch(err);
    if (m == null) return null;
    final version = m.group(1)!;
    final parts = version.split(RegExp(r'[._-]')).map((s) => int.tryParse(s) ?? 0).toList();
    final major = parts[0] == 1 && parts.length > 1 ? parts[1] : parts[0];
    // 64 位 JVM 会输出 "64-Bit Server VM"
    return JavaInfo(
      path: path,
      version: version,
      major: major,
      is64: RegExp('64-Bit', caseSensitive: false).hasMatch(err),
      managed: managed,
    );
  } catch (_) {
    return null;
  }
}

List<String> _listDirs(String dir) {
  try {
    return Directory(dir).listSync().whereType<Directory>().map((d) => d.path).toList();
  } catch (_) {
    return [];
  }
}

List<String> _candidates() {
  final set = <String>{};
  void addHome(String home) => set.add(p.join(home, 'bin', _javaExe));
  final env = Platform.environment;

  final javaHome = env['JAVA_HOME'];
  if (javaHome != null && javaHome.isNotEmpty) addHome(javaHome);
  final pathVar = env.entries
      .firstWhere((e) => e.key.toUpperCase() == 'PATH', orElse: () => const MapEntry('', ''))
      .value;
  for (final dir in pathVar.split(Platform.isWindows ? ';' : ':')) {
    if (dir.isNotEmpty && File(p.join(dir, _javaExe)).existsSync()) set.add(p.join(dir, _javaExe));
  }

  final home = env['USERPROFILE'] ?? env['HOME'] ?? '';
  final roots = <String>[p.join(home, '.jdks')];
  if (Platform.isWindows) {
    for (final pf in [env['ProgramFiles'], env['ProgramFiles(x86)']]) {
      if (pf == null) continue;
      for (final vendor in ['Java', 'Eclipse Adoptium', 'Zulu', 'Microsoft', 'BellSoft', 'Amazon Corretto', 'Semeru']) {
        roots.add(p.join(pf, vendor));
      }
    }
  } else if (Platform.isMacOS) {
    // 系统级与用户级的 JDK（IntelliJ、Zulu 等安装到 ~/Library/Java）
    for (final root in ['/Library/Java/JavaVirtualMachines', p.join(home, 'Library', 'Java', 'JavaVirtualMachines')]) {
      for (final d in _listDirs(root)) {
        addHome(p.join(d, 'Contents', 'Home'));
      }
    }
    // Homebrew（Apple 芯片在 /opt/homebrew，Intel 在 /usr/local）的 openjdk 与 openjdk@N
    for (final prefix in ['/opt/homebrew/opt', '/usr/local/opt']) {
      for (final d in _listDirs(prefix).where((d) => p.basename(d).startsWith('openjdk'))) {
        addHome(p.join(d, 'libexec', 'openjdk.jdk', 'Contents', 'Home'));
      }
    }
    // SDKMAN
    roots.add(p.join(home, '.sdkman', 'candidates', 'java'));
  } else {
    roots.addAll(['/usr/lib/jvm', '/usr/java', '/opt/java']);
  }
  for (final root in roots) {
    for (final d in _listDirs(root)) {
      addHome(d);
    }
  }
  return set.where((x) => File(x).existsSync()).toList();
}

Future<List<JavaInfo>> listJavas() async {
  final out = <JavaInfo>[];
  for (final comp in _listDirs(Paths.runtimeDir)) {
    final exe = _managedJavaPath(p.basename(comp));
    final info = File(exe).existsSync() ? await probeJava(exe, managed: true) : null;
    if (info != null) out.add(info);
  }
  final probed = await Future.wait(_candidates().map(probeJava));
  out.addAll(probed.whereType<JavaInfo>());
  return out..sort((a, b) => b.major.compareTo(a.major));
}

// ---------- Mojang 官方 Java 运行时 ----------

const _runtimeIndex =
    'https://launchermeta.mojang.com/v1/products/java-runtime/2ec0cc96c44e5a76b9c8b7c39df7210883d12871/all.json';

String? _runtimePlatform() {
  final abi = Abi.current();
  if (Platform.isWindows) {
    return abi == Abi.windowsArm64 ? 'windows-arm64' : (abi == Abi.windowsIA32 ? 'windows-x86' : 'windows-x64');
  }
  if (Platform.isMacOS) return abi == Abi.macosArm64 ? 'mac-os-arm64' : 'mac-os';
  if (Platform.isLinux) return abi == Abi.linuxIA32 ? 'linux-i386' : (abi == Abi.linuxX64 ? 'linux' : null);
  return null;
}

Future<String?> _installRuntime(String component, Downloader dl, TaskProgress task) async {
  final platform = _runtimePlatform();
  if (platform == null) return null;
  task.setStage('获取 Java 运行时 ($component)');
  final index = await dl.fetchJson(_runtimeIndex) as Map<String, dynamic>;
  final entries = (index[platform] as Map<String, dynamic>?)?[component] as List?;
  if (entries == null || entries.isEmpty) return null;
  final manifestUrl = '${(entries.first as Map)['manifest']['url']}';

  final manifest = await dl.fetchJson(manifestUrl) as Map<String, dynamic>;
  final base = p.join(Paths.runtimeDir, component);
  final files = <DownloadItem>[];
  final executables = <String>[];
  final links = <(String, String)>[];
  for (final e in (manifest['files'] as Map<String, dynamic>).entries) {
    final f = e.value as Map<String, dynamic>;
    final path = p.join(base, e.key);
    switch (f['type']) {
      case 'directory':
        await Directory(path).create(recursive: true);
      case 'file':
        final raw = (f['downloads'] as Map)['raw'] as Map;
        files.add(
          DownloadItem(
            url: '${raw['url']}',
            path: path,
            sha1: raw['sha1'] as String?,
            size: (raw['size'] as num?)?.toInt(),
          ),
        );
        if (f['executable'] == true) executables.add(path);
      case 'link':
        links.add((path, '${f['target']}'));
    }
  }

  task.setStage('下载 Java 运行时 ($component)');
  await dl.downloadAll(files, task.progress);

  if (!Platform.isWindows) {
    if (executables.isNotEmpty) await Process.run('chmod', ['755', ...executables]);
    for (final (path, target) in links) {
      if (FileSystemEntity.typeSync(path, followLinks: false) != FileSystemEntityType.notFound) continue;
      await Directory(p.dirname(path)).create(recursive: true);
      await Link(path).create(target).catchError((_) => Link(path));
    }
  }
  await File(p.join(base, '.installed')).writeAsString(manifestUrl);
  final java = _managedJavaPath(component);
  return File(java).existsSync() ? java : null;
}

Future<JavaInfo> _describe(String path) async {
  if (!File(path).existsSync()) throw Exception('Java 路径不存在：$path');
  final info = await probeJava(path);
  if (info == null) throw Exception('无法运行 Java：$path');
  return info;
}

/// 已知会因为 Java 版本过高而无法运行的版本，返回提示文字；没有已知问题时返回 null。
/// LaunchWrapper（Forge 1.12.2 及更早、OptiFine 独立版、LiteLoader 等）把系统类加载器当作 URLClassLoader 使用，
/// Java 9 起不再是，游戏会在加载时崩溃
String? javaTooNewWarning(VersionJson v, int javaMajor) {
  if (v.mainClass == 'net.minecraft.launchwrapper.Launch' && javaMajor > 8) {
    return '这个版本通过 LaunchWrapper 启动（Forge 1.12.2 及更早、OptiFine、LiteLoader 等），'
        '只能在 Java 8 上运行，使用 Java $javaMajor 很可能在加载时崩溃。';
  }
  return null;
}

/// 为指定版本选择合适的 Java，必要时自动下载。
/// 优先级与 PCL-CE 一致：实例指定 > 全局指定 > 自动选择。
Future<JavaInfo> ensureJava(VersionJson v, JavaPref pref, String globalJava, Downloader dl, TaskProgress task) async {
  // 安卓上的 Java 不能作为独立进程运行，要经游戏运行时（见 java_run.dart 的 runJava）
  if (Platform.isAndroid) throw UnsupportedError('安卓上请使用 ensureAndroidJava');
  final major = v.javaMajor ?? 8;
  // 用户指定的 Java 不自动替换；路径失效或版本过低时给出明确提示
  Future<JavaInfo> chosen(String path, String where) async {
    if (!File(path).existsSync()) {
      throw Exception('$where指定的 Java 不存在：$path。请重新选择 Java，或改为自动选择');
    }
    final info = await _describe(path);
    if (info.major < major) {
      throw Exception('$where指定的是 Java ${info.major}，这个版本至少需要 Java $major。请重新选择 Java，或改为自动选择');
    }
    return info;
  }

  switch (pref) {
    case JavaExist(:final path) when path.isNotEmpty:
      return chosen(path, '版本设置中');
    case JavaRelative(:final path) when path.isNotEmpty:
      return chosen(p.normalize(p.join(Paths.launcherDir, path)), '版本设置中');
    case JavaGlobal() when globalJava.isNotEmpty:
      return chosen(globalJava, '全局设置中');
    default:
  }

  final component = v.javaComponent ?? 'jre-legacy';

  final managed = _managedJavaPath(component);
  if (File(p.join(Paths.runtimeDir, component, '.installed')).existsSync() && File(managed).existsSync()) {
    return _describe(managed);
  }

  task.setStage('检测 Java');
  final javas = await listJavas();
  final exact = javas.where((j) => j.major == major).firstOrNull;
  if (exact != null) return exact;

  var downloadError = '';
  final downloaded = await _installRuntime(component, dl, task).catchError((Object e) {
    downloadError = '$e';
    return null;
  });
  if (downloaded != null) return _describe(downloaded);

  // 无法下载时，退而求其次使用更新的 Java
  final newer = javas.where((j) => j.major > major).toList()..sort((a, b) => a.major.compareTo(b.major));
  if (newer.isNotEmpty) return newer.first;
  throw Exception('找不到 Java $major，请在设置中手动指定 Java 路径${downloadError.isNotEmpty ? '（自动下载失败：$downloadError）' : ''}');
}
