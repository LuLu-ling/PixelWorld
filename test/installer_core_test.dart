import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/installer/installer_core.dart';

void main() {
  test('通过主程序或安装清单识别安装目录', () async {
    final dir = await Directory.systemTemp.createTemp('pw_install_dir');
    expect(isInstallDir(dir.path), isFalse);

    await File(p.join(dir.path, exeName)).writeAsString('');
    expect(isInstallDir(dir.path), isTrue);

    await File(p.join(dir.path, exeName)).delete();
    expect(isInstallDir(dir.path), isFalse);

    // 改名后的主程序也能识别
    await File(p.join(dir.path, 'Pixel World.exe')).writeAsString('');
    expect(isInstallDir(dir.path), isTrue);
    await File(p.join(dir.path, 'Pixel World.exe')).delete();

    await File(p.join(dir.path, '.pw-install.json')).writeAsString('{"files":[],"shortcuts":[]}');
    expect(isInstallDir(dir.path), isTrue);

    await dir.delete(recursive: true);
  });
}
