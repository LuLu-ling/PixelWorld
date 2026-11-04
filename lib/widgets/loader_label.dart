import 'package:flutter/material.dart';

import '../core/instance.dart';
import 'loader_icon.dart';

/// 版本图标：加载器的图标；原版只装了 OptiFine 时用 OptiFine 的图标
Widget versionIcon(InstanceInfo v, {double size = 24, Color? color}) {
  final loader = switch (v.loader) {
    Loader.vanilla when v.optifine => Loader.optifine,
    Loader.unknown => Loader.vanilla,
    final l => l,
  };
  return LoaderIcon(loader, size: size, color: color);
}
