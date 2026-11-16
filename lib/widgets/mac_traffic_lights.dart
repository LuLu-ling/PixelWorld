import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('pclpw/window');

/// macOS：把侧栏在窗口里的实际位置和宽度、顶栏的中线（窗口坐标，已经算上界面缩放）告诉原生代码，
/// 让红绿灯在侧栏里水平居中、和顶栏中线对齐（见 macos/Runner/MainFlutterWindow.swift）。
/// 界面缩放（设置里的「界面缩放」或窗口较小时的自动缩放）会改变侧栏宽度，按钮本身大小不变，所以要按实际宽度摆。
class MacTrafficLightsAnchor extends StatefulWidget {
  const MacTrafficLightsAnchor({super.key, required this.topBarHeight, required this.child});

  /// 顶栏高度（缩放前的逻辑像素）
  final double topBarHeight;

  /// 侧栏
  final Widget child;

  @override
  State<MacTrafficLightsAnchor> createState() => _MacTrafficLightsAnchorState();
}

class _MacTrafficLightsAnchorState extends State<MacTrafficLightsAnchor> {
  Map<String, double>? _sent;

  void _sync() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize || box.size.width == 0) return;
    final rect = MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
    final scale = rect.width / box.size.width;
    final args = {
      'railLeft': rect.left,
      'railWidth': rect.width,
      'centerY': rect.top + widget.topBarHeight / 2 * scale,
    };
    final last = _sent;
    if (last != null && args.keys.every((k) => (last[k]! - args[k]!).abs() < .5)) return;
    _sent = args;
    _channel.invokeMethod<void>('setTrafficLights', args).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    return widget.child;
  }
}
