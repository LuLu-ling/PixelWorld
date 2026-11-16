import 'package:flutter/material.dart';

/// 应用图标（透明底的立方体）
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/icon.png', width: size, height: size, filterQuality: FilterQuality.medium);
  }
}
