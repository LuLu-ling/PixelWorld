// 手动运行：把本地绘制的成就图片与头像输出到 PW_TEST_OUT，用来目测效果。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/pages/tools_page.dart';

void main() {
  final out = Platform.environment['PW_TEST_OUT'];
  testWidgets('本地绘制', (tester) async {
    await tester.runAsync(() async {
      final ach = await renderAchievement(title: '获得成就！', line1: '用 PCL.PW 启动了游戏', line2: 'Hello World');
      await File('$out/ach-local.png').writeAsBytes(ach);
      // 测试环境中 HTTP 被替换，皮肤从文件读取
      final skin = await File(Platform.environment['PW_TEST_SKIN']!).readAsBytes();
      await File('$out/head.png').writeAsBytes(await renderHead(skin, 128));
    });
  }, skip: out == null);
}
