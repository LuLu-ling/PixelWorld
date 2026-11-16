import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../platform.dart';
import '../shell.dart';

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

const _steps = [
  _Step('欢迎使用 Pixel World', '花一分钟认识一下启动器的几个主要地方。随时可以点「跳过」，之后在「设置 → 关于与致谢」里能再看一遍。', page: MainPage.home),
  _Step('先添加账户', '点这里添加微软正版账户、外置登录（例如 LittleSkin），或者先用离线账户玩。', target: 'top.account'),
  _Step(
    '安装游戏',
    '在「下载」里选游戏版本和加载器（Forge、Fabric 等）来安装。装好的一份叫「实例」，同一个版本可以装好几个，存档和模组互不影响。'
        '模组、整合包、资源包和光影也在这里找。',
    target: 'rail.download',
  ),
  _Step('切换实例', '首页显示当前实例。点「切换实例」可以在装好的实例之间切换，或者管理全部实例。', target: 'home.switch', page: MainPage.home),
  _Step('开始游戏', '选好实例后点这里启动。第一次启动会自动准备好需要的 Java。', target: 'home.launch', page: MainPage.home),
  _Step('实例设置', '每个实例的模组、存档、资源包、光影、内存和 Java 都在这里单独管理，也可以直接给这个实例添加模组。', target: 'home.settings', page: MainPage.home),
  _Step('后台任务', '下载和安装都在后台进行，进度显示在这里，点开可以查看详情或者取消。', target: 'top.tasks'),
  _Step('工具', '联机大厅、局域网互传、服务器查询、错误分析，还有皮肤、成就图片这些小工具。', target: 'rail.tools'),
  _Step('文件', '手机上的文件管理器：直接管理游戏文件夹里的存档、模组和截图。', target: 'rail.files', mobileOnly: true),
  _Step('AI 助手', '有问题可以问 AI，例如游戏为什么崩溃、该装哪个模组。先在设置里配置好模型就能用。', target: 'rail.ai'),
  _Step('设置', '主题、背景图片和首页布局在「个性化」里；Java、内存和游戏文件夹也在这里调整。', target: 'rail.settings'),
  _Step('准备好了', '先去「下载」装一个实例吧！这个教程可以在「设置 → 关于与致谢」里再次打开。'),
];

OverlayEntry? _entry;

/// 教程正在进行（自动检查更新等弹窗等它结束再出来）
final tourRunning = ValueNotifier<bool>(false);

/// 开始新手教程（[context] 要在主窗口里面，用来切换页面）
void startTour(BuildContext context) {
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
                  if (!last) TextButton(onPressed: onSkip, child: const Text('跳过')),
                  const Spacer(),
                  if (onPrev != null) TextButton(onPressed: onPrev, child: const Text('上一步')),
                  const SizedBox(width: 4),
                  FilledButton(onPressed: onNext, child: Text(last ? '开始使用' : '下一步')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
