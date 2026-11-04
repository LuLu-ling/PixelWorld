import 'package:flutter/material.dart';

/// 应用图标（蓝底版：立方体是白色的，浅色标题栏上需要蓝底）
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset('assets/icon/icon.png', width: size, height: size, filterQuality: FilterQuality.medium),
    );
  }
}
