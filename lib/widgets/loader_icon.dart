import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/instance.dart';

/// 加载器图标。本项目自绘的线条图标，取各项目标志的意象（Forge 铁砧、NeoForge 狐狸、Fabric 布料、
/// Quilt 拼布、LiteLoader 羽毛、OptiFine 的 OF 字样），用来区分各加载器，不是各项目的官方标志。
const _cloth =
    '<path d="M4.5 10.5 12 4a2 2 0 0 1 2.8.2l5 5.6a2 2 0 0 1-.2 2.9L12 19.5a2 2 0 0 1-2.8-.2l-4.9-5.8a2 2 0 0 1 .2-3Z"/>';

const loaderSvg = {
  // 草方块：立方体，侧面上沿是草的轮廓
  Loader.vanilla:
      '<path d="M12 2.8 20.5 7.5v9L12 21.2l-8.5-4.7v-9L12 2.8Z"/><path d="M3.5 7.5 12 12.2l8.5-4.7M12 12.2v9"/>'
      '<path d="m3.5 10.6 2.8 1.5 2.4-.4 3.3 1.9 3.3-1.9 2.4.4 2.8-1.5"/>',
  // 铁砧
  Loader.forge: '<path d="M2.5 8H9V6h12.5v3c-3.2.7-5.5 2.2-5.5 4.6 0 1.2.8 2 2 2.4v3H6v-3c1.8-.4 3.2-1.6 3.2-3.4 0-1.9-4.5-1.2-6.7-4.6Z"/>',
  // 狐狸头
  Loader.neoforge: '<path d="m4 3 1.4 7.6L3 13l9 8 9-8-2.4-2.4L20 3l-5 4.2H9L4 3Z"/><path d="M8.8 12.2v1.3M15.2 12.2v1.3M12 17v.01"/>',
  // 六边形里的 C
  Loader.cleanroom: '<path d="M12 2.8 20 7.4v9.2l-8 4.6-8-4.6V7.4l8-4.6Z"/><path d="M15 9.6a4 4 0 1 0 0 4.8"/>',
  // 布料与缝线
  Loader.fabric: '$_cloth<path d="m9 10 5.5 6M12.5 7l5.5 6"/>',
  // 布料与时钟指针
  Loader.legacyfabric: '$_cloth<path d="M10 9v5.5h4.5"/>',
  // 拼布
  Loader.quilt:
      '<rect x="3" y="3" width="8" height="8" rx="2"/><rect x="13" y="3" width="8" height="8" rx="2"/>'
      '<rect x="3" y="13" width="8" height="8" rx="2"/><path d="m17 12.6 4.4 4.4-4.4 4.4-4.4-4.4 4.4-4.4Z"/>',
  // OF 字样
  Loader.optifine: '<rect x="3" y="6" width="7.5" height="12" rx="3"/><path d="M14.5 18V6H21M14.5 12H19"/>',
  Loader.labymod: '<rect x="4" y="4" width="16" height="16" rx="4"/><path d="M10 8.5V15.5H15"/>',
  // 羽毛
  Loader.liteloader: '<path d="M20 4c-6.5 0-11.5 3-13 8.5L6.5 17l4.5-.5C17 15 20 10.5 20 4Z"/><path d="m4 20 10-10"/>',
};

class LoaderIcon extends StatelessWidget {
  const LoaderIcon(this.loader, {super.key, this.size = 24, this.color});

  final Loader loader;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final paths = loaderSvg[loader];
    if (paths == null) return Icon(Icons.help_outline, size: size, color: c);
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" '
      'stroke-linecap="round" stroke-linejoin="round">$paths</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
