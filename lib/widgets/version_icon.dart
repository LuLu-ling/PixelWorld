import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/instance.dart';
import 'loader_icon.dart';

/// 版本的自定义图标：`versions/<id>/PCL/Logo.png`（与 PCL-CE 的自定义图标位置相同）
String versionLogoPath(String versionDir) => p.join(versionDir, 'PCL', 'Logo.png');

/// 有自定义图标时返回它的路径
String? customVersionLogo(String versionDir) {
  final f = File(versionLogoPath(versionDir));
  return f.existsSync() ? f.path : null;
}

/// 版本图标：自定义图标优先，否则是主题色方块里的加载器图标
class VersionIcon extends StatelessWidget {
  const VersionIcon({super.key, required this.info, required this.versionDir, this.size = 48, this.radius = 12});

  final InstanceInfo info;
  final String versionDir;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final custom = customVersionLogo(versionDir);
    final fallback = Container(
      width: size,
      height: size,
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: LoaderIcon(info.loader, size: size * .52, color: scheme.onPrimaryContainer),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      clipBehavior: Clip.antiAlias,
      child: custom == null
          ? fallback
          : Image.file(
              File(custom),
              // 换图后让旧的缓存失效
              key: ValueKey('$custom\u0000${File(custom).lastModifiedSync().millisecondsSinceEpoch}'),
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// 让用户选一张图片作为版本图标；返回是否已更换
Future<bool> pickVersionLogo(String versionDir) async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: '图片', extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif']),
    ],
    confirmButtonText: '选择',
  );
  if (file == null) return false;
  final target = File(versionLogoPath(versionDir));
  await target.parent.create(recursive: true);
  await target.writeAsBytes(await file.readAsBytes());
  imageCache.clear();
  return true;
}

/// 恢复默认图标
Future<void> resetVersionLogo(String versionDir) async {
  final f = File(versionLogoPath(versionDir));
  if (f.existsSync()) await f.delete();
  imageCache.clear();
}
