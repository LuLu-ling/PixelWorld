import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pcl_pw/core/safe_path.dart';

void main() {
  late Directory tmp;
  late String root;
  late String outside;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pclpw-safe');
    root = p.join(tmp.path, 'game');
    outside = p.join(tmp.path, 'outside');
    Directory(p.join(root, 'config')).createSync(recursive: true);
    Directory(outside).createSync();
    File(p.join(root, 'config', 'a.txt')).writeAsStringSync('a');
    File(p.join(outside, 'secret.txt')).writeAsStringSync('secret');
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('普通相对路径可以访问', () {
    expect(resolveInside(root, 'config/a.txt'), p.join(root, 'config', 'a.txt'));
    expect(resolveInside(root, r'config\a.txt'), p.join(root, 'config', 'a.txt'));
    // 不存在的文件也可以（用于新建）
    expect(resolveInside(root, 'config/new/b.txt'), p.join(root, 'config', 'new', 'b.txt'));
  });

  test('拒绝绝对路径、上级目录与特殊名称', () {
    for (final bad in [
      '',
      '   ',
      '../outside/secret.txt',
      'config/../../outside/secret.txt',
      '/etc/passwd',
      r'C:\Windows\win.ini',
      'C:foo',
      r'\\server\share\x',
      './config/a.txt',
      'config/a.txt:stream',
      'config/a\u0000.txt',
    ]) {
      expect(() => resolveInside(root, bad), throwsA(isA<UnsafePathException>()), reason: bad);
    }
  });

  test('拒绝经过目录链接（Windows 上为目录联接）', () {
    final link = Link(p.join(root, 'linked'));
    link.createSync(outside);
    expect(() => resolveInside(root, 'linked/secret.txt'), throwsA(isA<UnsafePathException>()));
    expect(() => resolveInside(root, 'linked'), throwsA(isA<UnsafePathException>()));
    expect(() => resolveInside(root, 'linked/new.txt'), throwsA(isA<UnsafePathException>()));
  });

  test('拒绝指向外部的文件链接', () {
    final link = Link(p.join(root, 'config', 'evil.txt'));
    try {
      link.createSync(p.join(outside, 'secret.txt'));
    } on FileSystemException {
      markTestSkipped('当前系统不允许创建文件符号链接');
      return;
    }
    expect(() => resolveInside(root, 'config/evil.txt'), throwsA(isA<UnsafePathException>()));
  });

  test('检查之后被替换成链接时，复查会拒绝', () {
    final abs = resolveInside(root, 'config');
    Directory(abs).deleteSync(recursive: true);
    Link(abs).createSync(outside);
    expect(() => recheckInside(root, abs), throwsA(isA<UnsafePathException>()));
  });

  test('游戏文件夹本身位于链接之后时仍可使用', () {
    final alias = p.join(tmp.path, 'alias');
    Link(alias).createSync(root);
    expect(resolveInside(alias, 'config/a.txt'), p.join(alias, 'config', 'a.txt'));
  });
}
