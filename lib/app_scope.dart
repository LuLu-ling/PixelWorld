import 'package:flutter/material.dart';

import 'app_state.dart';

/// 向界面提供 [AppState]，状态变化时重建依赖它的组件
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// 只取状态、不订阅变化（用于事件回调里）
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// 底部提示条
void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, width: 420));
}

String errorText(Object e) => '$e'.replaceFirst(RegExp(r'^(Exception|HttpException|FileSystemException): ?'), '');
