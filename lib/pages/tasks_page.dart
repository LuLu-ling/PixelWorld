import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../core/task.dart';
import '../widgets/side_nav.dart';
import '../widgets/task_steps.dart';
import '../l10n/l10n.dart';

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
      padding: const EdgeInsets.only(left: 8),
      child: ContentPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                children: [
                  Text(context.l10n.subTasks, style: theme.textTheme.headlineSmall),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.tasksProgress(state.runningTasks.length),
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (finished > 0)
                    TextButton.icon(
                      onPressed: state.clearFinishedTasks,
                      icon: const Icon(Icons.clear_all),
                      label: Text(context.l10n.tasksClearFinishedTasks),
                    ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.tasksNoTasksYetInstalling,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
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

  /// 运行中的任务每秒刷新一次耗时（任务本身只在有新进度时通知）
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || widget.task.state != TaskState.running) {
        timer.cancel();
        if (mounted) setState(() {});
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  static String _duration(AppLocalizations l, Duration d) =>
      d.inMinutes > 0 ? l.tasksMinS(d.inMinutes, d.inSeconds % 60) : l.tasksS(d.inSeconds);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListenableBuilder(
      listenable: widget.task,
      builder: (context, _) {
        final t = widget.task;
        final (icon, color, label) = switch (t.state) {
          TaskState.running => (
            Icons.downloading,
            scheme.primary,
            t.cancelled ? context.l10n.tasksCanceling : context.l10n.tasksProgress2,
          ),
          TaskState.success => (Icons.check_circle, scheme.primary, context.l10n.tasksCompleted),
          TaskState.failed => (Icons.error, scheme.error, context.l10n.tasksFailed),
          TaskState.cancelled => (Icons.stop_circle_outlined, scheme.tertiary, context.l10n.tasksCanceled),
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
                            '$label · ${_duration(context.l10n, t.elapsed)}',
                            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (t.state == TaskState.running && t.canCancel)
                            TextButton.icon(
                              onPressed: t.cancelled ? null : () => AppScope.read(context).cancelTask(t),
                              icon: const Icon(Icons.stop_circle_outlined, size: 18),
                              label: Text(t.cancelled ? context.l10n.tasksCanceling2 : context.l10n.tasksCancel),
                            ),
                          if (t.state == TaskState.failed && t.retry != null)
                            TextButton(onPressed: t.retry, child: Text(context.l10n.deviceLoginDialogRetry)),
                          if (t.state != TaskState.running)
                            IconButton(
                              tooltip: context.l10n.bgImageRemove,
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
                                '${t.countText}${context.l10n.commonParenthesized('${((t.fraction ?? 0) * 100).toStringAsFixed(0)}%')}',
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
              tooltip: context.l10n.tasksCopyLog,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: lines.join('\n')));
                toast(context, context.l10n.commonLogCopied);
              },
            ),
          ),
        ],
      ),
    );
  }
}
