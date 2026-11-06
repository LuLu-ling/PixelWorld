import 'package:flutter/material.dart';

const _presetColors = <int>[
  0xFF2F6B4F,
  0xFF1370F3,
  0xFF6B4FBB,
  0xFFB35C1E,
  0xFFC42B2B,
  0xFF0F7C7C,
  0xFFB02E77,
  0xFF6B5B3E,
];

/// 个性化页里直接显示的主题色选择器：预设 + 自定义。
class ThemeColorPicker extends StatelessWidget {
  const ThemeColorPicker({super.key, required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  Future<void> _openCustom(BuildContext context) async {
    final color = await showDialog<int>(
      context: context,
      builder: (context) => _CustomColorDialog(initial: current),
    );
    if (color != null) onChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final argb in _presetColors)
          _ColorDot(
            selected: current == argb,
            onTap: () => onChanged(argb),
            child: Container(color: Color(argb)),
          ),
        _ColorDot(
          selected: !_presetColors.contains(current),
          onTap: () => _openCustom(context),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFFFF4D4D),
                  Color(0xFFFFD24D),
                  Color(0xFF4DFF88),
                  Color(0xFF4DD2FF),
                  Color(0xFF6B4DFF),
                  Color(0xFFFF4DC4),
                  Color(0xFFFF4D4D),
                ],
              ),
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.selected, required this.onTap, required this.child});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(child: child),
      ),
    );
  }
}

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog({required this.initial});

  final int initial;

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late int _red;
  late int _green;
  late int _blue;

  @override
  void initState() {
    super.initState();
    final c = Color(widget.initial);
    _red = (c.r * 255).round();
    _green = (c.g * 255).round();
    _blue = (c.b * 255).round();
  }

  Color get _color => Color.fromARGB(255, _red, _green, _blue);

  String get _hex => '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: const Text('自定义主题色'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 14),
                Text(_hex, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace')),
              ],
            ),
            const SizedBox(height: 16),
            _channel('红', _red, (v) => setState(() => _red = v)),
            _channel('绿', _green, (v) => setState(() => _green = v)),
            _channel('蓝', _blue, (v) => setState(() => _blue = v)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.pop(context, _color.toARGB32()), child: const Text('使用')),
      ],
    );
  }

  Widget _channel(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 38, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}
