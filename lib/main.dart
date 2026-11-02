import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'app_scope.dart';
import 'app_state.dart';
import 'shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.create();
  final window = WindowManager.instance.getCurrent()!;
  window.title = AppInfo.name;
  window.titleBarStyle = TitleBarStyle.hidden;
  window.isWindowControlButtonsVisible = false;
  window.setSize(const Size(1100, 700).toNative(), false);
  window.minimumSize = const Size(900, 560).toNative();
  window.center();
  window.show();
  window.focus();
  runApp(AppScope(state: state, child: const PclPwApp()));
}

/// 浅色 / 深色 / 跟随系统。主题色固定，只能切换明暗。
ThemeMode themeModeOf(String v) => switch (v) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

class PclPwApp extends StatelessWidget {
  const PclPwApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeModeOf(state.config.themeMode),
      home: const Shell(),
    );
  }
}
