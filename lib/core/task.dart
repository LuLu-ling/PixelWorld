import 'dart:io';

import 'package:flutter/foundation.dart';

enum TaskState { running, success, failed, cancelled }

enum TaskStepState { pending, running, done, failed, cancelled }

/// 任务被用户中断
class TaskCancelled implements Exception {
  const TaskCancelled();

  @override
  String toString() => '任务已中断';
}

class TaskStep {
  TaskStep(this.label);

  final String label;
  TaskStepState state = TaskStepState.pending;
}

/// 一个后台任务（安装、下载、启动）的进度与日志，界面监听它显示阶段与进度条
class TaskProgress extends ChangeNotifier {
  TaskProgress(this.title, {this.retry, this.canCancel = false, List<String> steps = const []})
    : steps = [for (final s in steps) TaskStep(s)];

  final String title;

  /// 任务的步骤，例如「下载」「安装」；按顺序进行
  final List<TaskStep> steps;

  /// 是否允许用户中断。启动游戏这类任务应该用结束游戏，而不是中断任务
  final bool canCancel;

  bool _cancelled = false;

  /// 用户是否已请求中断
  bool get cancelled => _cancelled;

  /// 中断后需要删除的文件或目录（只登记本次任务新建的内容）
  final Set<String> cleanupPaths = {};

  /// 清理回调是否已经执行，避免重复删除
  bool cleanupDone = false;

  /// 登记一个本次任务创建的文件或目录，中断时统一删除
  void registerCleanupPath(String path) => cleanupPaths.add(path);

  /// 请求中断；实际停止由任务主体在检查点发现
  void cancel() {
    if (!canCancel || state != TaskState.running || _cancelled) return;
    _cancelled = true;
    _append('正在中断任务…');
    notifyListeners();
  }

  /// 进入名为 [label] 的步骤；计划中没有这一步时追加到末尾
  void beginStep(String label) {
    if (_cancelled) throw const TaskCancelled();
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

  /// [done]、[total] 是字节数而不是文件数
  bool bytes = false;

  double? get fraction => total > 0 ? done / total : null;

  /// 进度数字：文件数，或按字节计时的 MB
  String get countText {
    if (!bytes) return '$done / $total';
    String mb(int b) => (b / 1024 / 1024).toStringAsFixed(1);
    return '${mb(done)} / ${mb(total)} MB';
  }

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
    if (_cancelled) throw const TaskCancelled();
    stage = s;
    detail = '';
    done = 0;
    total = 0;
    bytes = false;
    _append(s);
    notifyListeners();
  }

  /// 切换阶段但保留当前进度（例如下载完成后进入解压）
  void setStageKeepProgress(String s) {
    if (_cancelled) throw const TaskCancelled();
    stage = s;
    _append(s);
    notifyListeners();
  }

  /// 只更新阶段内的最新消息，不写入日志；适合下载速度这类频繁变化的内容
  void setDetail(String s) {
    detail = s;
    notifyListeners();
  }

  void progress(int d, int t) {
    final first = total == 0 && t > 0;
    done = d;
    total = t;
    if (first) _append('共 $t 个文件需要下载');
    notifyListeners();
  }

  /// 单个文件的下载进度（字节）
  void progressBytes(int d, int t) {
    bytes = true;
    done = d;
    total = t;
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

  /// 删除任务新建的文件和目录，返回删除的数量
  Future<int> cleanupFiles() async {
    if (cleanupDone) return 0;
    cleanupDone = true;
    var removed = 0;
    for (final path in cleanupPaths) {
      try {
        final type = await FileSystemEntity.type(path);
        if (type == FileSystemEntityType.notFound) continue;
        if (type == FileSystemEntityType.directory) {
          await Directory(path).delete(recursive: true);
        } else {
          await File(path).delete();
        }
        removed++;
      } catch (_) {
        // 清理失败不影响中断本身
      }
    }
    return removed;
  }

  /// 中断完成：未完成的步骤标记为已中断
  void markCancelled() {
    for (final s in steps) {
      if (s.state == TaskStepState.running || s.state == TaskStepState.pending) {
        s.state = TaskStepState.cancelled;
      }
    }
    state = TaskState.cancelled;
    endedAt = DateTime.now();
    error = null;
    _append('已中断');
    notifyListeners();
  }
}
