import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/android_runtime.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tc');
    await Directory(p.join(dir.path, 'mods')).create();
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> put(String name) => File(p.join(dir.path, 'mods', name)).writeAsString('');

  test('没有 mods 或没装时都算没装', () async {
    expect(hasTouchController(p.join(dir.path, 'nope')), isFalse);
    await put('sodium-fabric-0.6.jar');
    expect(hasTouchController(dir.path, includeDisabled: true), isFalse);
  });

  test('启用的算装了', () async {
    await put('TouchController-0.3.0+1.21.4-fabric.jar');
    expect(hasTouchController(dir.path), isTrue);
  });

  test('禁用的只在判断推荐时算装了', () async {
    await put('touchcontroller-0.3.0.jar.disabled');
    expect(hasTouchController(dir.path), isFalse);
    expect(hasTouchController(dir.path, includeDisabled: true), isTrue);
  });
}
