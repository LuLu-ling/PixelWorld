import 'package:flutter/foundation.dart';

/// 一个后台任务的进度，界面监听它显示阶段与进度条
class TaskProgress extends ChangeNotifier {
  TaskProgress(this.title);

  final String title;
  String stage = '';
  int done = 0;
  int total = 0;

  double? get fraction => total > 0 ? done / total : null;

  void setStage(String s) {
    stage = s;
    done = 0;
    total = 0;
    notifyListeners();
  }

  void progress(int d, int t) {
    done = d;
    total = t;
    notifyListeners();
  }
}
