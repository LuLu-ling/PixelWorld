import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'app_info.dart';
import 'app_scope.dart';
import 'app_state.dart';
import 'core/hud_bridge.dart';
import 'core/instance_files.dart';
import 'pages/file_manager_page.dart';
import 'installer/installer_app.dart';
import 'installer/installer_core.dart';
import 'platform.dart';
import 'shell.dart';
import 'theme.dart';

Future<void> main(List<String> args) async {
  // 安装包外壳与系统「应用」列表会以安装 / 卸载模式启动；这时不读写启动器的用户数据
  final installer = installerModeFromArgs(args);
  if (installer != null) return runInstaller(installer, args);

  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    stderr.writeln('PCLPW FLUTTER ERROR: ${details.exceptionAsString()}\n${details.stack}');
    FlutterError.presentError(details);
  };
  final state = await AppState.create();
  // 安卓：游戏进程通过本机回环端口向启动器里的 AI 提问
  if (Platform.isAndroid) unawaited(HudBridge.start(state.config));
  if (isDesktop) {
    final window = WindowManager.instance.getCurrent()!;
    window.title = AppInfo.name;
    window.titleBarStyle = TitleBarStyle.hidden;
    window.isWindowControlButtonsVisible = nativeWindowButtons;
    window.setSize(const Size(1100, 700).toNative(), false);
    window.minimumSize = const Size(900, 560).toNative();
    window.center();
    window.show();
    window.focus();
  } else {
    // 手机上使用横屏，布局与桌面端相同；隐藏系统状态栏与导航栏，电量和网络显示在标题栏
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  // 手机上「打开文件夹」使用内置的文件管理器
  mobileFileManager = (path) async {
    await appNavigator.currentState?.push(FileManagerPage.route(path));
  };
  runApp(AppScope(state: state, child: const PclPwApp()));
}

final appNavigator = GlobalKey<NavigatorState>();

/// 浅色 / 深色 / 跟随系统。主题色固定，只能切换明暗。
ThemeMode themeModeOf(String v) => switch (v) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

const _windowChannel = MethodChannel('pclpw/window');
bool? _lastLinuxDark;

void _syncLinuxWindowTheme(bool dark) {
  if (!Platform.isLinux || _lastLinuxDark == dark) return;
  _lastLinuxDark = dark;
  _windowChannel.invokeMethod<void>('setDarkMode', dark).catchError((_) {});
}

class PclPwApp extends StatelessWidget {
  const PclPwApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return MaterialApp(
      title: AppInfo.name,
      navigatorKey: appNavigator,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, seed: Color(state.config.themeColor)),
      darkTheme: buildTheme(Brightness.dark, seed: Color(state.config.themeColor)),
      themeMode: themeModeOf(state.config.themeMode),
      home: const Shell(),
      builder: (context, child) {
        if (Platform.isLinux) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncLinuxWindowTheme(dark));
        }
        return isDesktop ? child! : MobileScale(child: child!);
      },
    );
  }
}
