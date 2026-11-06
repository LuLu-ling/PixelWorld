import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/cat_ini.dart';

/// PCL/PCL-CE 使用的路径。只有需要读写旧版启动器格式时才应该引用这里。

String get pclCompatAppData => Platform.environment['APPDATA'] ?? '';

/// PW_PCL_SHARED_DIR 仅用于测试，避免读写真实的 PCL-CE 数据
String get pclCompatSharedDir =>
    Platform.environment['PW_PCL_SHARED_DIR'] ?? p.join(pclCompatAppData, 'PCLCE');

/// PCL-CE 的实例配置：`versions/<id>/PCL/config.v1.yml`
String pclInstanceConfig(String versionDir) => p.join(versionDir, 'PCL', 'config.v1.yml');

/// 旧版 PCL 的实例配置：`versions/<id>/PCL/setup.ini`
String pclInstanceLegacyConfig(String versionDir) => p.join(versionDir, 'PCL', 'setup.ini');

/// 游戏文件夹根目录的 PCL.ini
String pclLauncherIni(String gameRoot) => p.join(gameRoot, 'PCL.ini');

String? readPclSelectedVersion(String gameRoot) => readCatIni(pclLauncherIni(gameRoot))['Version'];

Future<void> writePclSelectedVersion(String gameRoot, String id) =>
    writeCatIni(pclLauncherIni(gameRoot), 'Version', id);
