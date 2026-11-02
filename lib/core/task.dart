import 'package:flutter/foundation.dart';

enum TaskState { running, success, failed }

enum TaskStepState { pending, running, done, failed }

class TaskStep {
  TaskStep(this.label);

  final String label;
  TaskStepState state = TaskStepState.pending;
}

/// 一个后台任务（安装、下载、启动）的进度与日志，界面监听它显示阶段与进度条
class TaskProgress extends ChangeNotifier {
  TaskProgress(this.title, {this.retry, List<String> steps = const []}) : steps = [for (final s in steps) TaskStep(s)];

  final String title;

  /// 任务的步骤，例如「下载」「安装」；按顺序进行
  final List<TaskStep> steps;

  /// 进入名为 [label] 的步骤；计划中没有这一步时追加到末尾
  void beginStep(String label) {
    var i = steps.indexWhere((s) => s.label == label);
    if (i < 0) {
      steps.add(TaskStep(label));
      i = steps.length - 1;
    }
    startStep(i);
  }

  /// 进入第 [index] 步：之前的步骤都算完成
  void startStep(int index) {
    if (index >= steps.length) return;
    for (var i = 0; i < index; i++) {
      if (steps[i].state != TaskStepState.failed) steps[i].state = TaskStepState.done;
    }
    steps[index].state = TaskStepState.running;
    _append('—— ${steps[index].label} ——');
    notifyListeners();
  }

  /// 失败后重试（重新执行同一个任务）
  final VoidCallback? retry;

  final startedAt = DateTime.now();
  DateTime? endedAt;
  TaskState state = TaskState.running;
  String? error;

  /// 当前阶段
  String stage = '';

  /// 阶段内的最新消息，例如安装器输出的最后一行
  String detail = '';
  int done = 0;
  int total = 0;

  /// 详细日志（最多保留 2000 行）
  final log = <String>[];

  double? get fraction => total > 0 ? done / total : null;

  Duration get elapsed => (endedAt ?? DateTime.now()).difference(startedAt);

  void _append(String line) {
    final t = DateTime.now();
    log.add(
      '[${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}] $line',
    );
    if (log.length > 2000) log.removeRange(0, log.length - 2000);
  }

  void setStage(String s) {
    stage = s;
    detail = '';
    done = 0;
    total = 0;
    _append(s);
    notifyListeners();
  }

  void progress(int d, int t) {
    final first = total == 0 && t > 0;
    done = d;
    total = t;
    if (first) _append('共 $t 个文件需要下载');
    notifyListeners();
  }

  /// 记录一行详细输出，同时作为阶段内的最新消息显示
  void output(String line) {
    final l = line.trim();
    if (l.isEmpty) return;
    detail = l;
    _append(l);
    notifyListeners();
  }

  void complete() {
    for (final s in steps) {
      s.state = TaskStepState.done;
    }
    state = TaskState.success;
    endedAt = DateTime.now();
    _append('完成');
    notifyListeners();
  }

  void fail(Object e) {
    // 出错的是正在进行的那一步；还没开始任何一步时算第一步失败
    final running =
        steps.where((s) => s.state == TaskStepState.running).firstOrNull ??
        steps.where((s) => s.state == TaskStepState.pending).firstOrNull;
    running?.state = TaskStepState.failed;
    state = TaskState.failed;
    endedAt = DateTime.now();
    error = '$e'.replaceFirst(RegExp(r'^Exception: ?'), '');
    _append('失败：$error');
    notifyListeners();
  }
}
