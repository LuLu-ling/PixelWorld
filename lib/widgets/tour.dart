import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../platform.dart';
import '../shell.dart';
import '../l10n/l10n.dart';
import '../core/i18n/strings.dart';

/// 新手教程：在真实界面上一步步高亮各个地方（周围压暗），旁边的卡片说明它是做什么的。
/// 第一次打开启动器时自动出现一次；之后可以在「设置 → 关于与致谢」里再看一遍。
///
/// 要高亮的地方用 [TourTarget] 包起来，按 id 对应到 [_steps] 里的某一步。

/// 标记教程里要高亮的地方。
/// [inkWell] 为 true 时高亮包住它的那个按钮（最近的 InkWell），用于只能包住按钮文字的地方
class TourTarget extends StatefulWidget {
  const TourTarget({super.key, required this.id, this.inkWell = false, required this.child});

  final String id;
  final bool inkWell;
  final Widget child;

  @override
  State<TourTarget> createState() => _TourTargetState();
}

class _TourTargetState extends State<TourTarget> {
  static final _all = <_TourTargetState>[];

  @override
  void initState() {
    super.initState();
    _all.add(this);
  }

  @override
  void dispose() {
    _all.remove(this);
    super.dispose();
  }

  /// 在 [ancestor] 坐标系里的位置；没有显示出来（不在当前页、尺寸为 0）时为 null
  Rect? rectIn(RenderBox ancestor) {
    Element? target = context as Element;
    if (widget.inkWell) {
      Element? found;
      target.visitAncestorElements((e) {
        if (e.widget is InkWell) {
          found = e;
          return false;
        }
        return true;
      });
      target = found ?? target;
    }
    final box = target.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize || box.size.isEmpty) return null;
    // 被 IndexedStack 等藏起来的页面不算
    if (!_visible(box)) return null;
    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    return rect.isFinite ? rect : null;
  }

  static bool _visible(RenderObject box) {
    RenderObject? child = box;
    var parent = box.parent;
    while (parent != null) {
      if (parent is RenderIndexedStack && child is RenderBox) {
        final i = parent.index;
        var c = parent.firstChild;
        var n = 0;
        while (c != null && c != child) {
          c = (c.parentData! as StackParentData).nextSibling;
          n++;
        }
        if (n != i) return false;
      }
      if (parent is RenderOffstage && parent.offstage) return false;
      child = parent;
      parent = parent.parent;
    }
    return true;
  }

  static Rect? find(String id, RenderBox ancestor) {
    for (final t in _all.reversed) {
      if (t.widget.id != id || !t.mounted) continue;
      final r = t.rectIn(ancestor);
      if (r != null) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Step {
  const _Step(this.title, this.body, {this.target, this.page, this.mobileOnly = false});

  final String title;
  final String body;

  /// 要高亮的 [TourTarget.id]；为 null 时卡片放在屏幕中间
  final String? target;

  /// 显示这一步前先切到哪个主页面
  final MainPage? page;
  final bool mobileOnly;
}

List<_Step> get _steps => [
  _Step(tr.commonWelcomePixelWorld, tr.tourTakeMinuteGetKnow, page: MainPage.home),
  _Step(tr.tourAddAccountFirst, tr.tourClickHereAddMicrosoft, target: 'top.account'),
  _Step(tr.tourInstallGame, tr.tourUnderDownloadChooseGame, target: 'rail.download'),
  _Step(tr.tourSwitchInstance, tr.tourHomePageShowsCurrent, target: 'home.switch', page: MainPage.home),
  _Step(tr.tourPlay, tr.tourPickInstanceClickHere, target: 'home.launch', page: MainPage.home),
  _Step(tr.tourInstanceSettings, tr.tourEachInstancesModsWorlds, target: 'home.settings', page: MainPage.home),
  _Step(tr.tourBackgroundTasks, tr.tourDownloadsInstallsRunBackground, target: 'top.tasks'),
  _Step(tr.navTools, tr.tourMultiplayerLobbyLANTransfer, target: 'rail.tools'),
  _Step(tr.navFiles, tr.tourFileManagerYourPhone, target: 'rail.files', mobileOnly: true),
  _Step(tr.navAiAssistant, tr.tourAskAIWhenSomething, target: 'rail.ai'),
  _Step(tr.navSettings, tr.tourThemeBackgroundImageHome, target: 'rail.settings'),
  _Step(tr.commonAllSet, tr.tourHeadDownloadInstallInstance),
];

OverlayEntry? _entry;

/// 教程正在进行（自动检查更新等弹窗等它结束再出来）
final tourRunning = ValueNotifier<bool>(false);

/// 开始新手教程（[context] 要在主窗口里面，用来切换页面）；[onClose] 在教程结束或跳过后调用
void startTour(BuildContext context, {VoidCallback? onClose}) {
  if (_entry != null) return;
  final nav = ShellNav.maybeOf(context);
  final overlay = Overlay.of(context, rootOverlay: true);
  final config = AppScope.read(context).config;
  final steps = [
    for (final s in _steps)
      if (!s.mobileOnly || !isDesktop) s,
  ];
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Tour(
      steps: steps,
      onPage: (p) => nav?.goMain(p),
      onClose: () {
        entry.remove();
        _entry = null;
        tourRunning.value = false;
        config.update({'tourSeen': true});
        onClose?.call();
      },
    ),
  );
  _entry = entry;
  tourRunning.value = true;
  overlay.insert(entry);
}

/// 第一次打开启动器时自动开始一次
void startTourOnFirstRun(BuildContext context) {
  if (AppScope.read(context).config.tourSeen) return;
  startTour(context);
}

class _Tour extends StatefulWidget {
  const _Tour({required this.steps, required this.onPage, required this.onClose});

  final List<_Step> steps;
  final ValueChanged<MainPage> onPage;
  final VoidCallback onClose;

  @override
  State<_Tour> createState() => _TourState();
}

class _TourState extends State<_Tour> {
  final _box = GlobalKey();
  final _focus = FocusNode(debugLabel: 'tour');
  int _i = 0;
  Rect? _rect;
  bool _measuring = false;
  Size? _size;

  /// 换步骤或窗口大小变化后，接下来这段时间每一帧都量一次（等切页、动画走完）
  DateTime _until = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 切页面会让外面的界面重建，不能在这一帧的构建过程中做
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 抢到键盘焦点：方向键、回车翻页，Esc 跳过
      _focus.requestFocus();
      _go(0);
    });
  }

  void _go(int i) {
    final step = widget.steps[i];
    if (step.page != null) widget.onPage(step.page!);
    setState(() => _i = i);
    _kick();
  }

  void _kick() {
    _until = DateTime.now().add(const Duration(milliseconds: 900));
    if (_measuring) return;
    _measuring = true;
    _measure();
  }

  /// 量目标的位置（切换页面、窗口缩放时跟着走），变了才重画
  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _box.currentContext?.findRenderObject() as RenderBox?;
      final id = widget.steps[_i].target;
      final r = box == null || id == null ? null : _TourTargetState.find(id, box)?.inflate(6);
      if (r != _rect) setState(() => _rect = r);
      if (DateTime.now().isBefore(_until)) {
        _measure();
        WidgetsBinding.instance.scheduleFrame();
      } else {
        _measuring = false;
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _next() => _i == widget.steps.length - 1 ? widget.onClose() : _go(_i + 1);
  void _prev() => _i > 0 ? _go(_i - 1) : null;

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.escape) {
      widget.onClose();
    } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
      _next();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _prev();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_i];
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    if (size != _size) {
      _size = size;
      _kick();
    }
    Widget layer(Rect? r) => CustomPaint(
      painter: _Spotlight(r, scheme.primary),
      child: CustomSingleChildLayout(
        delegate: _CardPlacement(r),
        child: _Card(
          step: step,
          index: _i,
          count: widget.steps.length,
          onNext: _next,
          onPrev: _i > 0 ? _prev : null,
          onSkip: widget.onClose,
        ),
      ),
    );
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _key,
      child: Stack(
        key: _box,
        fit: StackFit.expand,
        children: [
          // 挡住下面的界面，教程进行中不能点
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: _rect == null
                ? layer(null)
                // 从上一个目标滑到下一个
                : TweenAnimationBuilder<Rect?>(
                    tween: RectTween(end: _rect),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    builder: (context, r, _) => layer(r),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 压暗整个屏幕，目标的位置挖一个圆角的洞，洞的边上画一圈主题色
class _Spotlight extends CustomPainter {
  _Spotlight(this.hole, this.ring);

  final Rect? hole;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = Colors.black.withValues(alpha: .58);
    final h = hole;
    if (h == null) {
      canvas.drawRect(Offset.zero & size, dim);
      return;
    }
    final rr = RRect.fromRectAndRadius(h, const Radius.circular(14));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rr)),
      dim,
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_Spotlight old) => old.hole != hole || old.ring != ring;
}

/// 卡片放在目标旁边空间最大的一侧：侧栏的目标放右边，其他的放下面或上面；没有目标时居中
class _CardPlacement extends SingleChildLayoutDelegate {
  _CardPlacement(this.target);

  final Rect? target;
  static const _gap = 14.0, _margin = 12.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints c) =>
      BoxConstraints(maxWidth: (c.maxWidth - _margin * 2).clamp(0, 380), maxHeight: c.maxHeight - _margin * 2);

  @override
  Offset getPositionForChild(Size size, Size child) {
    final t = target;
    double clampX(double x) => x.clamp(_margin, size.width - child.width - _margin);
    double clampY(double y) => y.clamp(_margin, size.height - child.height - _margin);
    if (t == null) return Offset((size.width - child.width) / 2, (size.height - child.height) / 2);
    final right = size.width - t.right - _gap - _margin;
    final below = size.height - t.bottom - _gap - _margin;
    final above = t.top - _gap - _margin;
    final left = t.left - _gap - _margin;
    // 窄而靠左（侧栏）：放右边，和目标垂直居中
    if (t.width < 120 && t.left < size.width * .2 && right >= child.width) {
      return Offset(t.right + _gap, clampY(t.center.dy - child.height / 2));
    }
    if (below >= child.height) return Offset(clampX(t.center.dx - child.width / 2), t.bottom + _gap);
    if (above >= child.height) return Offset(clampX(t.center.dx - child.width / 2), t.top - _gap - child.height);
    if (right >= child.width) return Offset(t.right + _gap, clampY(t.center.dy - child.height / 2));
    if (left >= child.width) return Offset(t.left - _gap - child.width, clampY(t.center.dy - child.height / 2));
    return Offset((size.width - child.width) / 2, clampY(size.height - child.height - _margin));
  }

  @override
  bool shouldRelayout(_CardPlacement old) => old.target != target;
}

class _Card extends StatelessWidget {
  const _Card({
    required this.step,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  final _Step step;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback? onPrev;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final last = index == count - 1;
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 8,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(step.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Text(
                    '${index + 1} / $count',
                    style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(step.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              ),
              const SizedBox(height: 12),
              // 进度点
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 4),
                      width: i == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= index ? scheme.primary : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!last) TextButton(onPressed: onSkip, child: Text(context.l10n.commonSkip)),
                  const Spacer(),
                  if (onPrev != null) TextButton(onPressed: onPrev, child: Text(context.l10n.commonBack)),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: onNext,
                    child: Text(last ? context.l10n.tourGetStarted : context.l10n.commonNext),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
