import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'shell.dart';
import 'theme.dart';

/// 浅色 / 深色 / 跟随系统。主题色固定，只能切换明暗。
final themeMode = ValueNotifier(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final window = WindowManager.instance.getCurrent()!;
  window.title = AppInfo.name;
  window.titleBarStyle = TitleBarStyle.hidden;
  window.isWindowControlButtonsVisible = false;
  window.setSize(const Size(1100, 700).toNative(), false);
  window.minimumSize = const Size(900, 560).toNative();
  window.center();
  window.show();
  window.focus();
  runApp(const PclPwApp());
}

class PclPwApp extends StatelessWidget {
  const PclPwApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: AppInfo.name,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const Shell(),
      ),
    );
  }
}
