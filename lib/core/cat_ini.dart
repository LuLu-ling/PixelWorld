import 'dart:convert';
import 'dart:io';

import 'safe_write.dart';

/// PCL 的 "cat ini" 格式：每行 `键:值`，没有分节。
/// 用于 `.minecraft/PCL.ini`、旧版 `PCL/setup.ini` 与 `options.txt`。
Map<String, String> readCatIni(String file) {
  final map = <String, String>{};
  final f = File(file);
  if (!f.existsSync()) return map;
  for (final line in f.readAsLinesSync()) {
    final i = line.indexOf(':');
    if (i <= 0) continue;
    map[line.substring(0, i)] = line.substring(i + 1);
  }
  return map;
}

/// 修改单个键并保留其余内容与顺序
Future<void> writeCatIni(String file, String key, String value) async {
  final map = readCatIni(file)..[key] = value;
  await writeFileSafely(File(file), utf8.encode(map.entries.map((e) => '${e.key}:${e.value}').join('\n')));
}
