import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

/// 每个文件还没写进去的最新内容，以及正在进行的写入
final _latest = <String, List<int>>{};
final _running = <String, Future<void>>{};

/// 安全地写入一个小文件（配置、账户、对话等）：
/// - 同一个文件排队写：正在写时又来了新内容，写完后只再写最新的一份（中间的直接跳过）。
///   以前连续修改（拖动滑块、输入框每输一个字）会同时打开同一个文件写入，
///   Windows 上报「文件正被另一个进程使用」，还可能把文件写坏；
/// - 先写到同目录的临时文件再替换，写到一半出错（断电、磁盘满）也不会留下半个文件；
/// - 替换时文件刚好被占用（备份、杀毒软件）就稍等重试几次。
/// 返回的 Future 在这次内容（或更新的内容）写入后完成；写入失败时抛出异常。
Future<void> writeFileSafely(File file, List<int> bytes) {
  final key = p.normalize(file.absolute.path);
  _latest[key] = bytes;
  return _running[key] ??= _drain(key, file);
}

Future<void> _drain(String key, File file) async {
  try {
    while (_latest.containsKey(key)) {
      final data = _latest.remove(key)!;
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsBytes(data, flush: true);
      for (var attempt = 0; ; attempt++) {
        try {
          await tmp.rename(file.path);
          break;
        } on FileSystemException {
          if (attempt >= 4) rethrow;
          await Future<void>.delayed(Duration(milliseconds: 50 * (attempt + 1)));
        }
      }
    }
  } finally {
    // 在同一个微任务里移除：之后再来的写入会开始新的一轮，不会丢
    _running.remove(key);
  }
}

/// 删除文件，并取消它还没写进去的内容（例如清空 Key 时）
Future<void> deleteFileSafely(File file) async {
  final key = p.normalize(file.absolute.path);
  _latest.remove(key);
  try {
    await _running[key];
  } catch (_) {}
  if (file.existsSync()) await file.delete();
}
