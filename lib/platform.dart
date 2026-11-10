import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

/// 桌面端：有窗口管理、文件管理器，可以启动游戏
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// 使用系统原生窗口按钮：macOS 的红绿灯，Linux 使用桌面标题栏
bool get nativeWindowButtons => Platform.isMacOS || Platform.isLinux;

/// macOS 红绿灯按钮占用的标题栏左侧宽度
const macTrafficLightsWidth = 72.0;

/// 手机：界面按实际尺寸（dp）布局，不再整体缩小——缩小会让按钮和列表小到不好点。
/// 只有屏幕比 [_minWidth] × [_minHeight] 还小时才按比例缩小。
///
/// 左侧安全区（横屏时的挖孔）不在这里留白，而是保留在 MediaQuery.padding.left 里，
/// 由侧栏把背景铺过去、内容从挖孔右边开始，避免左边出现一条黑边。
class MobileScale extends StatelessWidget {
  const MobileScale({super.key, required this.child});

  final Widget child;

  static const _minWidth = 760.0;
  static const _minHeight = 360.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      child: LayoutBuilder(
        builder: (context, c) {
          final scale = min(1.0, min(c.maxWidth / _minWidth, c.maxHeight / _minHeight));
          if (scale >= 1) return child;
          final mq = MediaQuery.of(context);
          final size = Size(c.maxWidth / scale, c.maxHeight / scale);
          return FittedBox(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(
              size: size,
              child: MediaQuery(
                data: mq.copyWith(
                  size: size,
                  padding: EdgeInsets.only(left: mq.padding.left / scale),
                  viewPadding: EdgeInsets.only(left: mq.viewPadding.left / scale),
                  viewInsets: mq.viewInsets / scale,
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
