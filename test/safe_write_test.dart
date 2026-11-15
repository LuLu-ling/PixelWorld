import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/safe_write.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('pw-safe-write-'));
  tearDown(() => dir.delete(recursive: true));

  test('同一个文件同时写很多次：不报错，最后是最新的内容，不留临时文件', () async {
    final f = File(p.join(dir.path, 'sub', 'a.json'));
    await Future.wait([for (var i = 0; i < 200; i++) writeFileSafely(f, utf8.encode('{"v":$i}'))]);
    expect(jsonDecode(await f.readAsString()), {'v': 199});
    expect(File('${f.path}.tmp').existsSync(), isFalse);
  });

  test('写完一轮后再写，新内容也会写进去', () async {
    final f = File(p.join(dir.path, 'b.txt'));
    await writeFileSafely(f, utf8.encode('1'));
    await writeFileSafely(f, utf8.encode('2'));
    expect(await f.readAsString(), '2');
  });

  test('删除时取消还没写进去的内容', () async {
    final f = File(p.join(dir.path, 'c.txt'));
    final w = writeFileSafely(f, utf8.encode('x'));
    await deleteFileSafely(f);
    await w;
    expect(f.existsSync(), isFalse);
  });
}
