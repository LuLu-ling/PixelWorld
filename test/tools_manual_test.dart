// 手动运行的联网测试：工具页的服务器查询、皮肤、成就图片与清理范围。
//   PW_TEST_TOOLS=1 PW_TEST_GAME_DIR=... flutter test test/tools_manual_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/toolbox.dart';

void main() {
  final on = Platform.environment['PW_TEST_TOOLS'] == '1';
  test('服务器查询', () async {
    final s = await queryServer('mc.hypixel.net');
    // ignore: avoid_print
    print(
      'Hypixel：${s.online}/${s.max} ${s.version} ${s.latency}ms 图标 ${s.favicon?.length} 字节\n  ${s.motd.split('\n').first}',
    );
  }, skip: !on);
  test('正版皮肤', () async {
    final s = await fetchSkin('jeb_');
    // ignore: avoid_print
    print('皮肤：${s.name} ${s.uuid} ${s.slim ? 'slim' : 'classic'} ${s.png.length} 字节');
  }, skip: !on);
  test('成就图片', () async {
    final png = await fetchAchievement(block: 'diamond', title: '获得成就！', line1: 'PCL.PW 测试');
    // ignore: avoid_print
    print('成就图片 ${png.length} 字节');
  }, skip: !on);
  test('今日人品与清理范围', () {
    // ignore: avoid_print
    print('今日人品 Steve：${luckToday('Steve')}，同一天再算一次：${luckToday('Steve')}');
    final dir = Platform.environment['PW_TEST_GAME_DIR'];
    if (dir != null) {
      final junk = findGameJunk([dir]);
      final size = junk.fold<int>(0, (s, e) => s + sizeOf(e));
      // ignore: avoid_print
      print(
        '可清理 ${junk.length} 项，${(size / 1024 / 1024).toStringAsFixed(1)} MB，例如 ${junk.take(3).map((e) => e.path.split(Platform.pathSeparator).skip(e.path.split(Platform.pathSeparator).length - 2).join('/')).join('、')}',
      );
    }
  }, skip: !on);
}
