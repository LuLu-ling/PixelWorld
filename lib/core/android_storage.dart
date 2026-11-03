import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// 安卓的共享存储（/storage/emulated/0）。应用数据目录在卸载时会被清空，
/// 游戏文件夹放在共享存储才能保留。
abstract final class AndroidStorage {
  static const _channel = MethodChannel('pclpw/storage');

  /// 共享存储根目录，启动时读取
  static String root = '/storage/emulated/0';

  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    try {
      root = await _channel.invokeMethod<String>('externalRoot') ?? root;
    } catch (_) {
      // 读取失败时用常见的默认位置
    }
  }

  /// 共享存储中的启动器文件夹
  static String get launcherDir => p.join(root, 'PCL.PW');

  /// 放在共享存储时的默认游戏文件夹
  static String get gameDir => p.join(launcherDir, '.minecraft');

  static bool isShared(String path) => Platform.isAndroid && (p.isWithin(root, path) || p.equals(root, path));

  static Future<bool> hasAccess() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('hasAccess') ?? false;
  }

  /// Android 11 起会跳到系统设置，用户返回应用后得到结果
  static Future<bool> requestAccess() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('requestAccess') ?? false;
  }
}

/// 复制文件或文件夹；[onFile] 每复制完一个文件调用一次
Future<void> copyEntity(String from, String to, {void Function(String file)? onFile}) async {
  if (FileSystemEntity.isDirectorySync(from)) {
    await Directory(to).create(recursive: true);
    await for (final e in Directory(from).list(followLinks: false)) {
      await copyEntity(e.path, p.join(to, p.basename(e.path)), onFile: onFile);
    }
  } else {
    await Directory(p.dirname(to)).create(recursive: true);
    await File(from).copy(to);
    onFile?.call(from);
  }
}

/// 移动文件或文件夹。应用数据目录与共享存储不在同一个分区，不能直接重命名时先复制再删除
Future<void> moveEntity(String from, String to, {void Function(String file)? onFile}) async {
  final isDir = FileSystemEntity.isDirectorySync(from);
  try {
    await Directory(p.dirname(to)).create(recursive: true);
    await (isDir ? Directory(from).rename(to) : File(from).rename(to));
    return;
  } on FileSystemException {
    // 跨分区移动
  }
  await copyEntity(from, to, onFile: onFile);
  await (isDir ? Directory(from).delete(recursive: true) : File(from).delete());
}

/// 把文件夹合并移动到 [to]：目标里没有的直接移过去，同名文件保留目标里的，同名文件夹继续合并
Future<void> mergeMove(String from, String to, {void Function(String file)? onFile}) async {
  final type = FileSystemEntity.typeSync(to);
  if (type == FileSystemEntityType.notFound) return moveEntity(from, to, onFile: onFile);
  if (type != FileSystemEntityType.directory || !FileSystemEntity.isDirectorySync(from)) return;
  for (final e in Directory(from).listSync(followLinks: false)) {
    await mergeMove(e.path, p.join(to, p.basename(e.path)), onFile: onFile);
  }
  try {
    if (Directory(from).listSync().isEmpty) await Directory(from).delete();
  } catch (_) {
    // 留下没有移动的同名文件
  }
}

/// 统计文件数量，用于显示移动进度
int countFiles(String path) {
  if (!FileSystemEntity.isDirectorySync(path)) return FileSystemEntity.isFileSync(path) ? 1 : 0;
  try {
    return Directory(path).listSync(recursive: true, followLinks: false).whereType<File>().length;
  } catch (_) {
    return 0;
  }
}

/// 同名文件已存在时换一个名字：a.txt → a (2).txt
String uniquePath(String path) {
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) return path;
  final dir = p.dirname(path);
  final ext = FileSystemEntity.isDirectorySync(path) ? '' : p.extension(path);
  final base = p.basename(path).substring(0, p.basename(path).length - ext.length);
  for (var i = 2; ; i++) {
    final next = p.join(dir, '$base ($i)$ext');
    if (FileSystemEntity.typeSync(next) == FileSystemEntityType.notFound) return next;
  }
}
