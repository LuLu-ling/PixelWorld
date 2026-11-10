import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 外壳的布局信息：顶栏「后台任务」右边缘的位置（相对外壳根部），
/// 页面里左右两栏的分界线对齐到这里，视觉上与顶栏连成一条线。
class ShellLayout extends InheritedWidget {
  const ShellLayout({super.key, required this.rootKey, required this.splitX, required super.child});

  /// 外壳根部，用来换算坐标（手机上整体缩放时也成立）
  final GlobalKey rootKey;

  /// 「后台任务」右边缘的 x，相对 [rootKey]；还没量到时为 null
  final ValueNotifier<double?> splitX;

  static ShellLayout? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<ShellLayout>();

  @override
  bool updateShouldNotify(ShellLayout old) => old.splitX != splitX || old.rootKey != rootKey;
}

/// 左右两栏，分界线对齐顶栏「后台任务」的右边缘；两栏之间留 [gap]。
/// 宽度不够时按比例分（左边至少 [minLeft]，右边至少 [minRight]）。
class AlignedSplit extends StatefulWidget {
  const AlignedSplit({
    super.key,
    required this.left,
    required this.right,
    this.gap = 10,
    this.minLeft = 260,
    this.minRight = 240,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final Widget left;
  final Widget right;
  final double gap;
  final double minLeft;
  final double minRight;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<AlignedSplit> createState() => _AlignedSplitState();
}

class _AlignedSplitState extends State<AlignedSplit> {
  final _key = GlobalKey();
  double? _leftWidth;
  ValueNotifier<double?>? _listening;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = ShellLayout.maybeOf(context)?.splitX;
    if (notifier != _listening) {
      _listening?.removeListener(_measure);
      _listening = notifier?..addListener(_measure);
    }
  }

  @override
  void dispose() {
    _listening?.removeListener(_measure);
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final layout = ShellLayout.maybeOf(context);
    final x = layout?.splitX.value;
    final root = layout?.rootKey.currentContext?.findRenderObject();
    final box = _key.currentContext?.findRenderObject();
    if (x == null || root is! RenderBox || box is! RenderBox || !box.attached || !root.attached) return;
    final left = box.localToGlobal(Offset.zero, ancestor: root).dx;
    final width = x - left;
    if (_leftWidth == null || (width - _leftWidth!).abs() > .5) setState(() => _leftWidth = width);
  }

  @override
  Widget build(BuildContext context) {
    // 每次布局后都核对一次：窗口大小、侧栏宽度变化时自动跟上
    SchedulerBinding.instance.addPostFrameCallback((_) => _measure());
    return LayoutBuilder(
      key: _key,
      builder: (context, c) {
        final total = c.maxWidth;
        final max = total - widget.gap - widget.minRight;
        var left = _leftWidth ?? total * .55;
        if (max < widget.minLeft) {
          left = (total - widget.gap) * .55;
        } else {
          left = left.clamp(widget.minLeft, max);
        }
        return Row(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            SizedBox(width: left, child: widget.left),
            SizedBox(width: widget.gap),
            Expanded(child: widget.right),
          ],
        );
      },
    );
  }
}
