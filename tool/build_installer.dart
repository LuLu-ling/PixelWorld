// 打包 Windows 版：先编译 Flutter，再生成便携版 zip 与带加载动画的安装程序。
// 安装程序外壳用系统自带的 .NET Framework 编译器 csc 编译，Windows 10 及以上与 GitHub Actions 都自带。
//
//   dart run tool/build_installer.dart
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> run(String exe, List<String> args, {String? cwd}) async {
  final proc = await Process.start(
    exe,
    args,
    workingDirectory: cwd,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  final code = await proc.exitCode;
  if (code != 0) throw Exception('$exe 退出代码 $code');
}

Future<void> copyTree(Directory from, Directory to) async {
  await to.create(recursive: true);
  for (final e in from.listSync(recursive: true)) {
    final target = p.join(to.path, p.relative(e.path, from: from.path));
    if (e is Directory) {
      await Directory(target).create(recursive: true);
    } else if (e is File) {
      await File(target).parent.create(recursive: true);
      await e.copy(target);
    }
  }
}

Future<void> main() async {
  if (!Platform.isWindows) {
    stderr.writeln('只能在 Windows 上打包');
    exit(1);
  }
  final root = p.normalize(p.join(p.dirname(Platform.script.toFilePath()), '..'));
  final version = RegExp(
    r'^version:\s*([\d.]+)',
    multiLine: true,
  ).firstMatch(File(p.join(root, 'pubspec.yaml')).readAsStringSync())!.group(1)!;
  final windir = Platform.environment['WINDIR'] ?? r'C:\Windows';
  final csc = p.join(windir, 'Microsoft.NET', 'Framework64', 'v4.0.30319', 'csc.exe');
  // 用系统自带的 bsdtar 压缩；Git Bash 里的 tar 不支持 zip
  final tar = p.join(windir, 'System32', 'tar.exe');

  // 当前 Flutter 版本裁剪图标字体时会漏掉部分图标
  // 更新功能用到的构建信息（CI 中设置，见 .github/workflows/release.yml）
  final defines = [
    for (final k in ['PCLPW_COMMIT', 'PCLPW_CHANNEL'])
      if ((Platform.environment[k] ?? '').isNotEmpty) '--dart-define=$k=${Platform.environment[k]}',
  ];
  await run('flutter', ['build', 'windows', '--release', '--no-tree-shake-icons', ...defines], cwd: root);

  final dist = Directory(p.join(root, 'dist'));
  final name = 'PCL.PW-$version-windows-x64';
  final stage = Directory(p.join(dist.path, name));
  if (stage.existsSync()) await stage.delete(recursive: true);
  await copyTree(Directory(p.join(root, 'build', 'windows', 'x64', 'runner', 'Release')), stage);
  // Flutter 的可执行文件名不能带点，发布时改名
  await File(p.join(stage.path, 'pcl_pw.exe')).rename(p.join(stage.path, 'PCL.PW.exe'));

  Future<void> compile(String output, [List<String> extra = const []]) => run(csc, [
    '/nologo',
    '/optimize+',
    '/target:winexe',
    '/codepage:65001',
    '/win32manifest:${p.join(root, 'installer', 'shell.manifest')}',
    '/r:System.IO.Compression.dll',
    '/r:System.Windows.Forms.dll',
    '/r:System.Drawing.dll',
    '/r:System.Core.dll',
    '/out:$output',
    ...extra,
    p.join(root, 'installer', 'Shell.cs'),
    p.join(root, 'installer', 'Theme.cs'),
  ]);

  // 卸载时用的清理程序随程序一起安装
  await compile(p.join(stage.path, 'pw-cleanup.exe'));

  final portable = p.join(dist.path, '$name-portable.zip');
  final payload = p.join(dist.path, 'payload.zip');
  for (final f in [portable, payload]) {
    if (File(f).existsSync()) File(f).deleteSync();
  }
  await run(tar, ['-a', '-c', '-f', portable, '-C', dist.path, name]);
  await run(tar, ['-a', '-c', '-f', payload, '-C', stage.path, '.']);

  final setup = p.join(dist.path, '$name-setup.exe');
  await compile(setup, ['/resource:$payload,payload.zip']);
  File(payload).deleteSync();

  for (final f in [portable, setup]) {
    stdout.writeln('  • ${p.basename(f)}  ${(File(f).lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB');
  }
}
