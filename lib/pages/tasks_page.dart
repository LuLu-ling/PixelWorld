import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../core/task.dart';
import '../widgets/side_nav.dart';
import '../widgets/task_steps.dart';

/// 任务管理：安装、下载与启动的进度、详细日志和错误
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tasks = state.tasks;
    final finished = tasks.where((t) => t.state != TaskState.running).length;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ContentPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                children: [
                  Text('任务', style: theme.textTheme.headlineSmall),
                  const SizedBox(width: 12),
                  Text(
                    '${state.runningTasks.length} 个进行中',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (finished > 0)
                    TextButton.icon(
                      onPressed: state.clearFinishedTasks,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('清除已结束的任务'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text('还没有任务。安装版本、下载资源或启动游戏时会显示在这里', style: TextStyle(color: scheme.onSurfaceVariant)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      children: [for (final t in tasks) _TaskCard(key: ObjectKey(t), task: t)],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  const _TaskCard({super.key, required this.task});

  final TaskProgress task;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  late bool _expanded = widget.task.state == TaskState.failed;

  static String _duration(Duration d) =>
      d.inMinutes > 0 ? '${d.inMinutes} 分 ${d.inSeconds % 60} 秒' : '${d.inSeconds} 秒';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListenableBuilder(
      listenable: widget.task,
      builder: (context, _) {
        final t = widget.task;
        final (icon, color, label) = switch (t.state) {
          TaskState.running => (Icons.downloading, scheme.primary, '进行中'),
          TaskState.success => (Icons.check_circle, scheme.primary, '已完成'),
          TaskState.failed => (Icons.error, scheme.error, '失败'),
        };
        return Card.filled(
          color: scheme.surfaceContainerLow,
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(t.title, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '$label · ${_duration(t.elapsed)}',
                            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (t.state == TaskState.failed && t.retry != null)
                            TextButton(onPressed: t.retry, child: const Text('重试')),
                          if (t.state != TaskState.running)
                            IconButton(
                              tooltip: '移除',
                              onPressed: () => AppScope.read(context).removeTask(t),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: scheme.onSurfaceVariant),
                        ],
                      ),
                      if (t.steps.isNotEmpty) ...[const SizedBox(height: 10), TaskSteps(task: t)],
                      if (t.state == TaskState.running) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(t.stage, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                            ),
                            if (t.total > 0)
                              Text(
                                '${t.countText}（${((t.fraction ?? 0) * 100).toStringAsFixed(0)}%）',
                                style: theme.textTheme.labelMedium,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: t.fraction, borderRadius: BorderRadius.circular(4)),
                        if (t.detail.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            t.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                      if (t.error != null) ...[
                        const SizedBox(height: 8),
                        Text(t.error!, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error)),
                      ],
                    ],
                  ),
                ),
              ),
              if (_expanded) _Log(task: t),
            ],
          ),
        );
      },
    );
  }
}

class _Log extends StatelessWidget {
  const _Log({required this.task});

  final TaskProgress task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = task.log;
    return Container(
      color: scheme.surfaceContainerHighest,
      height: 220,
      child: Stack(
        children: [
          SelectionArea(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 48, 8),
              itemCount: lines.length,
              itemBuilder: (context, i) => Text(
                lines[lines.length - 1 - i],
                style: TextStyle(
                  fontFamily: 'Consolas',
                  fontFamilyFallback: const ['Cascadia Mono', 'Menlo', 'monospace', 'Microsoft YaHei UI'],
                  fontSize: 12,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              tooltip: '复制日志',
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: lines.join('\n')));
                toast(context, '已复制日志');
              },
            ),
          ),
        ],
      ),
    );
  }
}
