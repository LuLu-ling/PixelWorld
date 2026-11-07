import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

enum _Glyph { minimize, maximize, restore, close }

/// Windows 风格的窗口按钮。三个图标画在同样大小的 10×10 格子里，视觉大小一致。
class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key, this.height = 40, this.showMaximize = true});

  final double height;
  final bool showMaximize;

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  final Window _window = WindowManager.instance.getCurrent()!;
  late bool _maximized = _window.isMaximized;
  late final ListenerId _listener;

  @override
  void initState() {
    super.initState();
    _listener = _window.addListener((event) {
      if (event is WindowMaximizedEvent || event is WindowRestoredEvent || event is WindowResizedEvent) {
        final m = _window.isMaximized;
        if (mounted && m != _maximized) setState(() => _maximized = m);
      }
    });
  }

  @override
  void dispose() {
    _window.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Button(height: widget.height, glyph: _Glyph.minimize, tooltip: '最小化', onTap: _window.minimize),
        if (widget.showMaximize)
          // 悬停时弹出 Windows 11 的贴靠布局
          MaximizeButtonArea(
            child: _Button(
              height: widget.height,
              glyph: _maximized ? _Glyph.restore : _Glyph.maximize,
              tooltip: _maximized ? '还原' : '最大化',
              onTap: () => _maximized ? _window.unmaximize() : _window.maximize(),
            ),
          ),
        _Button(height: widget.height, glyph: _Glyph.close, tooltip: '关闭', onTap: () => _window.close(), danger: true),
      ],
    );
  }
}

class _Button extends StatefulWidget {
  const _Button({
    required this.height,
    required this.glyph,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  final double height;
  final _Glyph glyph;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool _hover = false;
  Offset? _pressedAt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 关闭按钮悬停时用 Windows 的危险红，与系统标题栏一致
    final bg = !_hover
        ? Colors.transparent
        : widget.danger
        ? const Color(0xFFC42B1C)
        : scheme.onSurface.withValues(alpha: 0.08);
    final fg = _hover && widget.danger ? Colors.white : scheme.onSurfaceVariant;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        // 用 Listener 而不是 GestureDetector：顶栏同时有拖动窗口的手势，
        // 按钮放在拖动层外面也能保证点击一定到达这里
        child: Listener(
          onPointerDown: (e) => _pressedAt = e.position,
          onPointerUp: (e) {
            final start = _pressedAt;
            _pressedAt = null;
            if (start != null && (e.position - start).distance <= 6) widget.onTap();
          },
          onPointerCancel: (_) => _pressedAt = null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: widget.height,
            color: bg,
            alignment: Alignment.center,
            child: CustomPaint(size: const Size(10, 10), painter: _GlyphPainter(widget.glyph, fg)),
          ),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color);

  final _Glyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    switch (glyph) {
      case _Glyph.minimize:
        canvas.drawLine(const Offset(0, 5.5), const Offset(10, 5.5), p);
      case _Glyph.maximize:
        canvas.drawRRect(RRect.fromLTRBR(0.5, 0.5, 9.5, 9.5, const Radius.circular(1.5)), p);
      case _Glyph.restore:
        canvas.drawRRect(RRect.fromLTRBR(0.5, 2.5, 7.5, 9.5, const Radius.circular(1)), p);
        canvas.drawPath(
          Path()
            ..moveTo(2.5, 0.5)
            ..lineTo(7.5, 0.5)
            ..arcToPoint(const Offset(9.5, 2.5), radius: const Radius.circular(2))
            ..lineTo(9.5, 7.5),
          p,
        );
      case _Glyph.close:
        canvas.drawLine(const Offset(0.5, 0.5), const Offset(9.5, 9.5), p);
        canvas.drawLine(const Offset(9.5, 0.5), const Offset(0.5, 9.5), p);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.glyph != glyph || old.color != color;
}
