import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

/// 桌面端：有窗口管理、文件管理器，可以启动游戏
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// 使用系统原生窗口按钮：macOS 的红绿灯，Linux 使用桌面标题栏
bool get nativeWindowButtons => Platform.isMacOS || Platform.isLinux;

/// macOS 红绿灯按钮占用的标题栏左侧宽度
const macTrafficLightsWidth = 72.0;

/// 「自动」界面缩放：手机按大约 1000 × 440 的尺寸排版（大屏不放大），电脑上为 100%。
/// [size] 为没有缩放时的可用尺寸（逻辑像素）
double autoUiScale(Size size) {
  if (isDesktop) return 1;
  final s = min(size.width / 1000, size.height / 440);
  return s.clamp(.75, 1.0);
}

/// 界面缩放档位（设置里的选项）；0 表示自动
const uiScaleOptions = [0.0, .75, .8, .85, .9, .95, 1.0, 1.1, 1.25];

/// 整体缩放界面：[scale] 为 0 时按 [autoUiScale]。
///
/// 手机上左侧安全区（横屏时的挖孔）不在这里留白，而是保留在 MediaQuery.padding.left 里，
/// 由侧栏把背景铺过去、内容从挖孔右边开始，避免左边出现一条黑边。
class AppScale extends StatelessWidget {
  const AppScale({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, c) {
        final s = scale > 0 ? scale : autoUiScale(c.biggest);
        if ((s - 1).abs() < .001) return child;
        final mq = MediaQuery.of(context);
        final size = Size(c.maxWidth / s, c.maxHeight / s);
        return FittedBox(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: mq.copyWith(
                size: size,
                padding: mq.padding / s,
                viewPadding: mq.viewPadding / s,
                viewInsets: mq.viewInsets / s,
              ),
              child: child,
            ),
          ),
        );
      },
    );
    return isDesktop ? content : SafeArea(left: false, child: content);
  }
}

