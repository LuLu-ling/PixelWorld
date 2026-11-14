import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/widgets/app_background.dart';

void main() {
  test('背景图片按铺满（cover）放进窗口：短边贴满、居中裁掉多出来的部分', () async {
    final rec = ui.PictureRecorder();
    Canvas(rec).drawRect(const Rect.fromLTWH(0, 0, 200, 100), Paint());
    final image = await rec.endRecording().toImage(200, 100);
    // 窗口比图片「高」：按高度铺满，左右裁掉
    final tall = BackgroundController.coverRect(image, const Size(100, 100));
    expect(tall.height, 100);
    expect(tall.width, 200);
    expect(tall.left, -50);
    // 窗口比图片「宽」：按宽度铺满，上下裁掉
    final wide = BackgroundController.coverRect(image, const Size(400, 100));
    expect(wide.width, 400);
    expect(wide.top, -50);
  });

  test('默认参数与效果图一致', () {
    final d = BackgroundPrefs.defaults;
    expect(d[BackgroundPrefs.blurKey], 8.0);
    expect(d[BackgroundPrefs.panelBlurKey], 20.0);
    expect(d[BackgroundPrefs.opacityKey], .62);
    expect(d[BackgroundPrefs.glowKey], .55);
    expect(d[BackgroundPrefs.solidKey], false);
    expect(d[BackgroundPrefs.themeFromImageKey], true);
  });
}
