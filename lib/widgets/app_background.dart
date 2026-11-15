import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:path/path.dart' as p;

import '../core/config.dart';
import '../core/paths.dart';
import '../platform.dart';

// 电脑端的个性化背景：整个窗口后面一张背景图片，界面面板变成毛玻璃。
// - 背景图片按「背景模糊」整体模糊一次；
// - 每个面板自己画一份与窗口对齐的背景，用「面板模糊」单独模糊（与背景模糊互不影响），再叠一层主题色；
// - 两种模糊都在换图或改参数时预先算好，绘制时只是贴图，开销很小；
// - 直接放在背景上的文字按整张背景图片的亮度统一用黑字或白字（同一屏颜色一致）。
// 手机上不启用，保持实色界面。

/// 背景相关的设置（保存在 config 里）
abstract final class BackgroundPrefs {
  static const imageKey = 'bgImage';
  static const blurKey = 'bgBlur';
  static const panelBlurKey = 'bgPanelBlur';
  static const opacityKey = 'bgPanelOpacity';
  static const glowKey = 'bgCoverGlow';
  static const solidKey = 'bgSolid';
  static const themeFromImageKey = 'bgThemeFromImage';
  static const seedIndexKey = 'bgSeedIndex';

  /// 设了背景图片时首页用「壁纸」排版：内容放在顶部和底部，中间留给图片
  static const homeLayoutKey = 'bgHomeWallpaper';

  /// 背景暗化：背景图片上压一层颜色的浓度（深色压黑、浅色压白），0～0.7；小于 0 表示用默认值
  static const dimKey = 'bgDim';

  static const defaults = <String, dynamic>{
    imageKey: '',
    blurKey: 8.0,
    panelBlurKey: 20.0,
    opacityKey: 0.62,
    glowKey: 0.55,
    solidKey: false,
    themeFromImageKey: true,
    seedIndexKey: 0,
    homeLayoutKey: true,
    dimKey: -1.0,
  };

  /// 背景图片复制到启动器自己的数据目录，原图移动或删除后仍然可用
  static String get dir => p.join(Paths.appData, 'background');
}

/// 绘制时的参考窗口宽度：模糊半径按这个宽度换算到图片像素
const _referenceWidth = 1100.0;

/// 预处理时图片的最长边（够铺满大多数窗口，模糊后看不出差别）
const _workingSize = 1600;

class BackgroundController extends ChangeNotifier {
  BackgroundController(this.config) {
    config.addListener(_sync);
    _sync();
  }

  final LauncherConfig config;

  ui.Image? _image;
  ui.Image? _bgImage;
  ui.Image? _panelImage;
  ByteData? _luma;
  static const _lumaW = 64, _lumaH = 40;
  List<Color> _candidates = const [];

  String _loadedPath = '';
  double _loadedBlur = -1, _loadedPanelBlur = -1;
  int _generation = 0;

  T _get<T>(String key) => (config.raw[key] ?? BackgroundPrefs.defaults[key]) as T;

  String get imagePath => _get<String>(BackgroundPrefs.imageKey);
  double get blur => (_get<num>(BackgroundPrefs.blurKey)).toDouble();
  double get panelBlur => (_get<num>(BackgroundPrefs.panelBlurKey)).toDouble();
  double get opacity => (_get<num>(BackgroundPrefs.opacityKey)).toDouble();

  /// 背景暗化的浓度；没有调过时用默认值（深色 35%、浅色 10%，和以前一样）
  double dimFor(Brightness b) {
    final v = (_get<num>(BackgroundPrefs.dimKey)).toDouble();
    return v < 0 ? (b == Brightness.dark ? .35 : .10) : v.clamp(0.0, .7);
  }
  double get coverGlow => (_get<num>(BackgroundPrefs.glowKey)).toDouble();
  bool get solid => _get<bool>(BackgroundPrefs.solidKey);
  bool get themeFromImage => _get<bool>(BackgroundPrefs.themeFromImageKey);
  int get seedIndex => (_get<num>(BackgroundPrefs.seedIndexKey)).toInt();
  bool get wallpaperHome => _get<bool>(BackgroundPrefs.homeLayoutKey);

  /// 只在电脑上、并且已经设置并加载好背景图片时启用
  bool get active => isDesktop && _bgImage != null && _panelImage != null;

  ui.Image? get backgroundImage => _bgImage;
  ui.Image? get panelImage => _panelImage;

  /// 从背景图片取出的主题色候选（MD3 的 Score，最多 4 个）
  List<Color> get candidates => _candidates;

  /// 主题色种子：设了背景、选择跟随背景时用候选色，否则为 null（用手动选的主题色）
  Color? get themeSeed {
    if (!isDesktop || imagePath.isEmpty || !themeFromImage || _candidates.isEmpty) return null;
    return _candidates[seedIndex.clamp(0, _candidates.length - 1)];
  }

  /// 面板底色的不透明度（降低透明度时接近实色）
  double panelAlpha({double extra = 0}) => solid ? .94 : (opacity + extra).clamp(0.0, 1.0);

  void _sync() {
    final path = isDesktop ? imagePath : '';
    if (path != _loadedPath || blur != _loadedBlur || panelBlur != _loadedPanelBlur) {
      unawaited(_load(path));
    } else {
      // 只改了不透明度、色散等：直接重画
      notifyListeners();
    }
  }

  Future<void> _load(String path) async {
    final gen = ++_generation;
    final blurNow = blur, panelBlurNow = panelBlur;
    if (path.isEmpty || !File(path).existsSync()) {
      _image = _bgImage = _panelImage = null;
      _luma = null;
      _candidates = const [];
      _loadedPath = path;
      _loadedBlur = blurNow;
      _loadedPanelBlur = panelBlurNow;
      notifyListeners();
      return;
    }
    try {
      if (path != _loadedPath || _image == null) {
        final bytes = await File(path).readAsBytes();
        final image = await _decode(bytes);
        if (gen != _generation) return;
        _image = image;
        _candidates = await _extractCandidates(image);
      }
      final image = _image!;
      final scale = image.width / _referenceWidth;
      final bg = await _blurred(image, blurNow * scale);
      final panel = await _blurred(image, panelBlurNow * scale);
      final luma = await _lumaOf(bg);
      if (gen != _generation) return;
      _bgImage = bg;
      _panelImage = panel;
      _luma = luma;
      _avgLuma = null;
      _loadedPath = path;
      _loadedBlur = blurNow;
      _loadedPanelBlur = panelBlurNow;
    } catch (_) {
      // 图片损坏或格式不支持：当作没有背景
      _image = _bgImage = _panelImage = null;
      _luma = null;
      _candidates = const [];
      _loadedPath = path;
    }
    notifyListeners();
  }

  /// 解码并缩小到最长边 [_workingSize]
  static Future<ui.Image> _decode(Uint8List bytes) async {
    final probe = await ui.instantiateImageCodec(bytes);
    final frame = await probe.getNextFrame();
    final w = frame.image.width, h = frame.image.height;
    final k = math.min(1.0, _workingSize / math.max(w, h));
    if (k >= 1) return frame.image;
    frame.image.dispose();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: (w * k).round(), targetHeight: (h * k).round());
    return (await codec.getNextFrame()).image;
  }

  static Future<ui.Image> _blurred(ui.Image src, double sigma) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (sigma > 0.3) paint.imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.clamp);
    canvas.drawImage(src, Offset.zero, paint);
    return rec.endRecording().toImage(src.width, src.height);
  }

  /// 缩小成很小的图，用来估算某块区域的亮度
  static Future<ByteData?> _lumaOf(ui.Image src) async {
    final rec = ui.PictureRecorder();
    Canvas(rec).drawImageRect(
      src,
      Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
      const Rect.fromLTWH(0, 0, _lumaW * 1.0, _lumaH * 1.0),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final small = await rec.endRecording().toImage(_lumaW, _lumaH);
    final data = await small.toByteData(format: ui.ImageByteFormat.rawRgba);
    small.dispose();
    return data;
  }

  /// MD3 取色：量化后按 Score 打分（与 Android 壁纸取色相同的做法）
  static Future<List<Color>> _extractCandidates(ui.Image src) async {
    const side = 112;
    final rec = ui.PictureRecorder();
    Canvas(rec).drawImageRect(
      src,
      Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
      const Rect.fromLTWH(0, 0, side * 1.0, side * 1.0),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final small = await rec.endRecording().toImage(side, side);
    final data = await small.toByteData(format: ui.ImageByteFormat.rawRgba);
    small.dispose();
    if (data == null) return const [];
    final pixels = <int>[];
    for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
      final a = data.getUint8(i + 3);
      if (a < 255) continue;
      pixels.add(0xFF000000 | data.getUint8(i) << 16 | data.getUint8(i + 1) << 8 | data.getUint8(i + 2));
    }
    final result = await QuantizerCelebi().quantize(pixels, 128);
    return [for (final c in Score.score(result.colorToCount, desired: 4)) Color(c)];
  }

  /// 图片按「铺满（cover）」放进 [size] 时占的矩形
  static Rect coverRect(ui.Image image, Size size) {
    final k = math.max(size.width / image.width, size.height / image.height);
    final w = image.width * k, h = image.height * k;
    return Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h);
  }

  /// [rect]（窗口坐标）后面背景的平均亮度，0～1；没有背景时为 null
  /// 整张背景图片的平均亮度（0～1）。直接显示在背景上的文字统一按它选黑字或白字，
  /// 不再每处单独取样，避免同一屏上有的黑有的白
  double? get averageLuminance {
    final luma = _luma;
    if (luma == null) return null;
    if (_avgLuma != null) return _avgLuma;
    var sum = 0.0;
    final n = _lumaW * _lumaH;
    for (var i = 0; i < n; i++) {
      final o = i * 4;
      sum += (0.2126 * luma.getUint8(o) + 0.7152 * luma.getUint8(o + 1) + 0.0722 * luma.getUint8(o + 2)) / 255;
    }
    return _avgLuma = sum / n;
  }

  double? _avgLuma;

  double? luminanceAt(Rect rect, Size window) {
    final luma = _luma, bg = _bgImage;
    if (luma == null || bg == null || window.isEmpty) return null;
    final cover = coverRect(bg, window);
    final x0 = ((rect.left - cover.left) / cover.width * _lumaW).floor().clamp(0, _lumaW - 1);
    final x1 = ((rect.right - cover.left) / cover.width * _lumaW).ceil().clamp(x0 + 1, _lumaW);
    final y0 = ((rect.top - cover.top) / cover.height * _lumaH).floor().clamp(0, _lumaH - 1);
    final y1 = ((rect.bottom - cover.top) / cover.height * _lumaH).ceil().clamp(y0 + 1, _lumaH);
    var sum = 0.0;
    var n = 0;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        final i = (y * _lumaW + x) * 4;
        sum += (0.2126 * luma.getUint8(i) + 0.7152 * luma.getUint8(i + 1) + 0.0722 * luma.getUint8(i + 2)) / 255;
        n++;
      }
    }
    return n == 0 ? null : sum / n;
  }

  /// 选择一张新的背景图片：复制到启动器的数据目录，删掉旧的副本
  Future<void> setImage(String source) async {
    final dir = Directory(BackgroundPrefs.dir);
    await dir.create(recursive: true);
    final ext = p.extension(source).toLowerCase();
    final target = p.join(dir.path, 'background-${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(source).copy(target);
    final old = imagePath;
    await config.update({BackgroundPrefs.imageKey: target, BackgroundPrefs.seedIndexKey: 0});
    if (old.isNotEmpty && p.isWithin(dir.path, old)) await File(old).delete().catchError((_) => File(old));
  }

  Future<void> clearImage() async {
    final old = imagePath;
    await config.update({BackgroundPrefs.imageKey: ''});
    if (old.isNotEmpty && p.isWithin(BackgroundPrefs.dir, old)) await File(old).delete().catchError((_) => File(old));
  }

  @override
  void dispose() {
    config.removeListener(_sync);
    super.dispose();
  }
}

/// 背景相关的上下文：控制器与窗口根节点（面板据此把背景对齐到窗口）
class BackgroundScope extends InheritedNotifier<BackgroundController> {
  const BackgroundScope({
    super.key,
    required BackgroundController controller,
    required this.rootKey,
    required super.child,
  }) : super(notifier: controller);

  final GlobalKey rootKey;

  /// 启用背景时返回 scope，否则为 null
  static BackgroundScope? activeOf(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<BackgroundScope>();
    return s != null && s.notifier!.active ? s : null;
  }

  BackgroundController get controller => notifier!;

  RenderBox? get root => rootKey.currentContext?.findRenderObject() as RenderBox?;
}

/// 整个窗口后面的背景层：按背景模糊处理过的图片，再压一层颜色（深色压暗、浅色提亮）保证文字清楚
class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = BackgroundScope.activeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CoverPainter(scope.controller.backgroundImage!),
        foregroundPainter: _DimPainter(
          (dark ? Colors.black : Colors.white).withValues(
            alpha: scope.controller.dimFor(dark ? Brightness.dark : Brightness.light),
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(
      image,
      src,
      BackgroundController.coverRect(image, size),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_CoverPainter old) => old.image != image;
}

class _DimPainter extends CustomPainter {
  _DimPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(Offset.zero & size, Paint()..color = color);

  @override
  bool shouldRepaint(_DimPainter old) => old.color != color;
}

/// 面板：启用背景时是毛玻璃（对齐窗口的背景副本 + 面板模糊 + 主题色），否则是普通的实色面板。
/// [extraOpacity] 让重要的面板（例如主卡片、侧栏）稍微不透明一点；[overlay] 画在玻璃之上、内容之下（例如封面色散）
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.color,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.extraOpacity = 0,
    this.overlay,
    this.clip = true,
    required this.child,
  });

  /// 不启用背景时的底色，也是启用时主题色层的颜色（会改成半透明）
  final Color color;
  final BorderRadius borderRadius;
  final BorderSide? border;
  final double extraOpacity;
  final Widget? overlay;
  final bool clip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = BackgroundScope.activeOf(context);
    final shape = RoundedRectangleBorder(borderRadius: borderRadius, side: border ?? BorderSide.none);
    if (scope == null) {
      return Material(color: color, shape: shape, clipBehavior: clip ? Clip.antiAlias : Clip.none, child: child);
    }
    final c = scope.controller;
    final scheme = Theme.of(context).colorScheme;
    // 已经在一块毛玻璃里面：再画一次背景会和外层一模一样，看不出卡片，改成叠一层半透明的面板颜色
    if (context.dependOnInheritedWidgetOfExactType<_InGlass>() != null) {
      return Material(
        color: color.withValues(alpha: c.solid ? .9 : .55),
        shape: shape,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: child,
      );
    }
    final tint = scheme.surface.withValues(alpha: c.panelAlpha(extra: extraOpacity));
    return Material(
      type: MaterialType.transparency,
      shape: shape.copyWith(side: border ?? BorderSide(color: scheme.onSurface.withValues(alpha: .07))),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: _GlassBackdrop(scope: scope)),
          Positioned.fill(child: ColoredBox(color: tint)),
          if (overlay != null) Positioned.fill(child: overlay!),
          _InGlass(child: child),
        ],
      ),
    );
  }
}

/// 页面顶部的搜索框：启用背景时是一条毛玻璃，否则是普通的填充输入框
class GlassField extends StatelessWidget {
  const GlassField({super.key, required this.decoration, required this.child});

  /// 输入框原本的装饰；启用背景时去掉填充色
  final InputDecoration decoration;
  final Widget Function(InputDecoration decoration) child;

  @override
  Widget build(BuildContext context) {
    if (BackgroundScope.activeOf(context) == null) return child(decoration);
    return GlassPanel(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: child(decoration.copyWith(filled: false)),
    );
  }
}

/// 标记「在毛玻璃面板里面」，里面的 [GlassPanel] 不再重复画背景
class _InGlass extends InheritedWidget {
  const _InGlass({required super.child});

  @override
  bool updateShouldNotify(_InGlass old) => false;
}

/// 在毛玻璃面板里面的实色卡片：启用背景时改成半透明，透出面板；否则就是 [color]
Color glassCardColor(BuildContext context, Color color) {
  final scope = BackgroundScope.activeOf(context);
  if (scope == null) return color;
  return color.withValues(alpha: scope.controller.solid ? .9 : .55);
}

/// 画出面板所在位置那一块（按面板模糊处理过的）背景
class _GlassBackdrop extends LeafRenderObjectWidget {
  const _GlassBackdrop({required this.scope});

  final BackgroundScope scope;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlassBackdrop(scope.controller.panelImage!, scope.rootKey, Scrollable.maybeOf(context)?.position);

  @override
  void updateRenderObject(BuildContext context, _RenderGlassBackdrop render) => render
    ..image = scope.controller.panelImage!
    ..rootKey = scope.rootKey
    ..scroll = Scrollable.maybeOf(context)?.position;
}

class _RenderGlassBackdrop extends RenderBox {
  _RenderGlassBackdrop(this._image, this.rootKey, ScrollPosition? scroll) {
    this.scroll = scroll;
  }

  ui.Image _image;
  GlobalKey rootKey;
  ScrollPosition? _scroll;

  set image(ui.Image v) {
    if (v == _image) return;
    _image = v;
    markNeedsPaint();
  }

  /// 面板在滚动列表里时，滚动不会让它重画，要自己跟着重画，背景才对得上
  set scroll(ScrollPosition? v) {
    if (v == _scroll) return;
    _scroll?.removeListener(markNeedsPaint);
    _scroll = v;
    if (attached) _scroll?.addListener(markNeedsPaint);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scroll?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scroll?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final root = rootKey.currentContext?.findRenderObject() as RenderBox?;
    if (root == null || !root.attached) return;
    final origin = localToGlobal(Offset.zero, ancestor: root);
    final cover = BackgroundController.coverRect(_image, root.size);
    final canvas = context.canvas;
    canvas.save();
    canvas.clipRect(offset & size);
    canvas.drawImageRect(
      _image,
      Rect.fromLTWH(0, 0, _image.width.toDouble(), _image.height.toDouble()),
      cover.shift(offset - origin),
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }
}

/// 直接放在背景上的内容（问候、小标题）：按整张背景图片的亮度统一给出黑字或白字；
/// 没有启用背景时 [builder] 收到 null，用原来的颜色
class OnBackground extends StatelessWidget {
  const OnBackground({super.key, required this.builder});

  /// [foreground] 主要文字颜色，[muted] 次要文字颜色
  final Widget Function(BuildContext context, Color? foreground, Color? muted) builder;

  @override
  Widget build(BuildContext context) {
    final scope = BackgroundScope.activeOf(context);
    final l0 = scope?.controller.averageLuminance;
    // 已经在毛玻璃面板里面（例如版本详情里的设置分组标题）：不是直接压在背景上，用面板上的正常颜色
    final inGlass = context.dependOnInheritedWidgetOfExactType<_InGlass>() != null;
    if (scope == null || l0 == null || inGlass) return builder(context, null, null);
    // 算上背景层上压的那层颜色
    final b = Theme.of(context).brightness;
    final dim = scope.controller.dimFor(b);
    final l = b == Brightness.dark ? l0 * (1 - dim) : l0 * (1 - dim) + dim;
    final darkText = l > .55;
    final fg = darkText ? const Color(0xFF111512) : const Color(0xFFF5F7F5);
    final muted = fg.withValues(alpha: darkText ? .72 : .78);
    final shadow = Shadow(
      color: darkText ? Colors.white.withValues(alpha: .3) : Colors.black.withValues(alpha: .35),
      offset: const Offset(0, 1),
      blurRadius: 1,
    );
    return DefaultTextStyle.merge(
      style: TextStyle(color: fg, shadows: [shadow]),
      child: IconTheme.merge(
        data: IconThemeData(color: fg),
        child: builder(context, fg, muted),
      ),
    );
  }
}

/// 存档卡片上的封面色散：从封面位置（左侧）向外扩散的微弱主色。
/// 深色时提亮（screen）、浅色时压暗（multiply），叠在毛玻璃上
class CoverGlow extends StatelessWidget {
  const CoverGlow({super.key, required this.colors, required this.strength});

  final List<Color> colors;

  /// 0～1，设置里的「封面色散」
  final double strength;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CoverGlowPainter(colors, strength.clamp(0.0, 1.0), Theme.of(context).brightness == Brightness.dark),
  );
}

class _CoverGlowPainter extends CustomPainter {
  _CoverGlowPainter(this.colors, this.strength, this.dark);

  final List<Color> colors;
  final double strength;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty || strength <= 0) return;
    final k = dark ? strength : strength * .6;
    final rect = Offset.zero & size;
    void glow(Color c, Alignment center, double rx, double ry, double alpha) {
      final shader =
          RadialGradient(
            center: center,
            radius: .5,
            colors: [
              c.withValues(alpha: alpha * k),
              c.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCenter(center: center.withinRect(rect), width: size.width * rx * 2, height: size.height * ry * 2),
          );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = shader
          ..blendMode = dark ? BlendMode.screen : BlendMode.multiply,
      );
    }

    glow(colors.first, const Alignment(-.84, 0), .7, 1.4, .55);
    glow(colors.length > 1 ? colors[1] : colors.first, const Alignment(-.4, 1), .6, 1.2, .3);
  }

  @override
  bool shouldRepaint(_CoverGlowPainter old) => old.colors != colors || old.strength != strength || old.dark != dark;
}
