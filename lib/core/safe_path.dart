import 'dart:io';

import 'package:path/path.dart' as p;

import 'i18n/strings.dart';

/// 路径不在允许的目录内，或无法确认是否安全
class UnsafePathException implements Exception {
  UnsafePathException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 把相对路径限制在 [root] 中，供 AI 工具和备份恢复统一使用。
///
/// 规则：
///  - 只接受相对路径；拒绝绝对路径、盘符、`..`、`.`、冒号（Windows 的备用数据流）和控制字符；
///  - [root] 之下的每一级已存在的路径都不能是符号链接或目录联接（junction）；
///  - 已存在的最深一级路径解析真实路径后，仍要位于 [root] 的真实路径中。
///
/// 只要有一项无法确认就拒绝。返回规范化的绝对路径。
/// 检查和实际操作之间仍有很短的时间窗口，所以执行操作前应再调用一次 [recheckInside]。
String resolveInside(String root, String rel) {
  final parts = splitRelative(rel);
  final abs = p.normalize(p.joinAll([root, ...parts]));
  if (!p.isWithin(root, abs)) throw UnsafePathException(tr.safePathOnlyFilesVersionsWorking(rel));
  recheckInside(root, abs);
  return abs;
}

/// 校验并拆分相对路径（不访问文件系统）
List<String> splitRelative(String rel) {
  final s = rel.replaceAll('\\', '/').trim();
  if (s.isEmpty) throw UnsafePathException(tr.safePathInvalidPath(rel));
  if (s.startsWith('/') || p.posix.isAbsolute(s) || p.windows.isAbsolute(s)) {
    throw UnsafePathException(tr.safePathInvalidPath(rel));
  }
  final parts = s.split('/').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) throw UnsafePathException(tr.safePathInvalidPath(rel));
  for (final part in parts) {
    if (part == '..' || part == '.' || part.contains(':') || part.codeUnits.any((c) => c < 0x20)) {
      throw UnsafePathException(tr.safePathInvalidPath(rel));
    }
    // Windows 会忽略结尾的点和空格，"mods." 实际指向 "mods"
    if (Platform.isWindows && (part.endsWith('.') || part.endsWith(' '))) {
      throw UnsafePathException(tr.safePathInvalidPath(rel));
    }
  }
  return parts;
}

/// 确认 [abs]（必须已在 [root] 之下）沿途没有符号链接，且真实路径仍在 [root] 中
void recheckInside(String root, String abs) {
  if (!p.isWithin(root, abs)) throw UnsafePathException(tr.safePathOnlyFilesVersionsWorking2);
  final rel = p.relative(abs, from: root);
  var cur = root;
  var deepest = root;
  for (final part in p.split(rel)) {
    cur = p.join(cur, part);
    final type = FileSystemEntity.typeSync(cur, followLinks: false);
    if (type == FileSystemEntityType.notFound) break;
    if (type == FileSystemEntityType.link) {
      throw UnsafePathException(tr.safePathPathContainsSymbolicLink(p.relative(cur, from: root)));
    }
    deepest = cur;
  }
  // 兜底：Windows 的目录联接等不一定被识别为链接，按真实路径再比较一次
  final String realRoot, realDeepest;
  try {
    realRoot = Directory(root).resolveSymbolicLinksSync();
    realDeepest = FileSystemEntity.isDirectorySync(deepest)
        ? Directory(deepest).resolveSymbolicLinksSync()
        : File(deepest).resolveSymbolicLinksSync();
  } on FileSystemException {
    throw UnsafePathException(tr.safePathCantDetermineRealLocation(p.relative(abs, from: root)));
  }
  if (!p.equals(realRoot, realDeepest) && !p.isWithin(realRoot, realDeepest)) {
    throw UnsafePathException(tr.safePathPathActuallyPointsOutside(p.relative(abs, from: root)));
  }
}

/// [path] 本身是否为符号链接（不跟随）
bool isLink(String path) => FileSystemEntity.typeSync(path, followLinks: false) == FileSystemEntityType.link;
