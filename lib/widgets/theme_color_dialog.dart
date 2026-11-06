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

/// 选择主题色种子。返回 ARGB int；取消返回 null。
Future<int?> showThemeColorDialog(BuildContext context, int current) {
  return showDialog<int>(
    context: context,
    builder: (context) => _ThemeColorDialog(current: current),
  );
}

class _ThemeColorDialog extends StatefulWidget {
  const _ThemeColorDialog({required this.current});

  final int current;

  @override
  State<_ThemeColorDialog> createState() => _ThemeColorDialogState();
}

class _ThemeColorDialogState extends State<_ThemeColorDialog> {
  late int _red;
  late int _green;
  late int _blue;

  @override
  void initState() {
    super.initState();
    final c = Color(widget.current);
    _red = (c.r * 255).round();
    _green = (c.g * 255).round();
    _blue = (c.b * 255).round();
  }

  Color get _color => Color.fromARGB(255, _red, _green, _blue);

  void _setColor(int argb) {
    final c = Color(argb);
    setState(() {
      _red = (c.r * 255).round();
      _green = (c.g * 255).round();
      _blue = (c.b * 255).round();
    });
  }

  String get _hex => '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: const Text('主题色'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_hex, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace')),
                        Text(
                          '按 Material Design 3 生成整套配色',
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('预设', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  for (final argb in _presetColors)
                    InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: () => _setColor(argb),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(argb),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color.toARGB32() == argb ? scheme.onSurface : scheme.outlineVariant,
                            width: _color.toARGB32() == argb ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text('自定义', style: theme.textTheme.labelLarge),
              _channel('红', _red, (v) => setState(() => _red = v)),
              _channel('绿', _green, (v) => setState(() => _green = v)),
              _channel('蓝', _blue, (v) => setState(() => _blue = v)),
            ],
          ),
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
        SizedBox(
          width: 38,
          child: Text('$value', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
