import 'package:flutter/material.dart';

import '../core/task.dart';

/// 任务步骤：完成为绿色对勾，失败为红色叉，进行中为进度圈，未开始为灰色圆圈横线
class TaskSteps extends StatelessWidget {
  const TaskSteps({super.key, required this.task, this.dense = false});

  final TaskProgress task;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (task.steps.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    // 状态色只用于小图标，不影响界面主色相
    final green = dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final size = dense ? 14.0 : 18.0;
    final style = (dense ? theme.textTheme.labelSmall : theme.textTheme.labelMedium);

    Widget icon(TaskStepState s) => switch (s) {
      TaskStepState.done => Icon(Icons.check_circle, size: size, color: green),
      TaskStepState.failed => Icon(Icons.cancel, size: size, color: scheme.error),
      TaskStepState.cancelled => Icon(Icons.stop_circle_outlined, size: size, color: scheme.tertiary),
      TaskStepState.pending => Icon(Icons.remove_circle_outline, size: size, color: scheme.outline),
      TaskStepState.running => SizedBox.square(
        dimension: size,
        child: Padding(padding: EdgeInsets.all(size * 0.1), child: const CircularProgressIndicator(strokeWidth: 2)),
      ),
    };

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < task.steps.length; i++) ...[
          if (i > 0) Icon(Icons.chevron_right, size: size, color: scheme.outline),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon(task.steps[i].state),
              SizedBox(width: dense ? 3 : 5),
              Text(
                task.steps[i].label,
                style: style?.copyWith(
                  color: switch (task.steps[i].state) {
                    TaskStepState.pending => scheme.outline,
                    TaskStepState.failed => scheme.error,
                    TaskStepState.cancelled => scheme.tertiary,
                    _ => scheme.onSurface,
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
