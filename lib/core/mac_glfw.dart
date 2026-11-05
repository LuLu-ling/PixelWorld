import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'paths.dart';

// Apple 芯片的 Mac 上运行 1.13～1.18：LWJGL 换成 3.3.1 后（见 version.dart 的 appleSiliconLibraries），
// 其中的 GLFW 在设置窗口图标时会报错 65548，而这些版本把所有 GLFW 错误都当作致命错误。
// 启动器内置一份去掉了这条报错的 GLFW 3.4（arm64，构建方法见 tool/glfw/README.md），
// 启动时用 -Dorg.lwjgl.glfw.libname 让 LWJGL 使用它。

const _asset = 'assets/macos/libglfw.3.dylib';

/// 解压后的位置
String get appleSiliconGlfwPath => p.join(Paths.runtimeDir, 'glfw-3.4-pclpw', 'libglfw.3.dylib');

/// 把内置的 GLFW 写到 [appleSiliconGlfwPath]；已存在且大小相同时不重复写入
Future<void> ensureAppleSiliconGlfw() async {
  final data = await rootBundle.load(_asset);
  final f = File(appleSiliconGlfwPath);
  if (f.existsSync() && f.lengthSync() == data.lengthInBytes) return;
  await f.parent.create(recursive: true);
  await f.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
}
