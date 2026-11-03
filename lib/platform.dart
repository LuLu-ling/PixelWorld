import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

/// 桌面端：有窗口管理、文件管理器，可以启动游戏
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;


/// 手机屏幕较小：把界面按比例缩小，按至少 960 × 520 的尺寸布局，保持与桌面端相同的布局
class MobileScale extends StatelessWidget {
  const MobileScale({super.key, required this.child});

  final Widget child;

  static const _minWidth = 960.0;
  static const _minHeight = 520.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
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
