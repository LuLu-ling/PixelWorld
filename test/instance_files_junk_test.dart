import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/instance_files.dart';

void main() {
  test('不列出系统自动生成的文件，禁用后的也不列', () async {
    final dir = await Directory.systemTemp.createTemp('junk');
    addTearDown(() => dir.delete(recursive: true));
    final mods = await Directory(p.join(dir.path, 'mods')).create();
    for (final n in ['.DS_Store', 'Thumbs.db', 'desktop.ini', 'Thumbs.db.disabled', 'sodium.jar', 'old.jar.disabled']) {
      await File(p.join(mods.path, n)).writeAsString('');
    }
    final names = listInstanceFiles(dir.path, InstanceFolder.mods).map((f) => p.basename(f.path)).toSet();
    expect(names, {'sodium.jar', 'old.jar.disabled'});
  });
}
