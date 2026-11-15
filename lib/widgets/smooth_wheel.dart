import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// 电脑上鼠标滚轮的平滑滚动（全局）。
///
/// Flutter 在桌面上把滚轮的每一格直接跳过去，看起来一顿一顿的。这里在指针事件进入框架之前，
/// 把一格滚轮拆成一串越来越小的滚动事件，大约 0.2 秒滑完（先快后慢，指数衰减）；
/// 连续滚动时，没滑完的部分和新的一格叠加，滚得越快走得越远。
/// 拆出来的事件和原来的一样走正常的命中测试，嵌套的列表、横向列表都照常处理。
/// 触控板的滚动本来就是连续的小步，不处理（只拆单次很大的滚动量）。
class SmoothWheel {
  SmoothWheel._();

  /// 单个事件的滚动量至少这么大（物理像素）才认为是滚轮的一格
  static const _wheelThreshold = 40.0;

  /// 衰减时间常数：越小越快滑完
  static const _tau = 70.0;

  /// 每一步的间隔
  static const _step = Duration(milliseconds: 8);

  static ui.PointerDataPacketCallback? _forward;
  static Timer? _timer;
  static final _clock = Stopwatch();
  static ui.PointerData? _template;
  static double _remainX = 0, _remainY = 0;

  /// 在 WidgetsFlutterBinding.ensureInitialized() 之后调用
  static void install() {
    final dispatcher = ui.PlatformDispatcher.instance;
    final original = dispatcher.onPointerDataPacket;
    if (original == null || _forward != null) return;
    _forward = original;
    dispatcher.onPointerDataPacket = _handle;
  }

  static void _handle(ui.PointerDataPacket packet) {
    final pass = <ui.PointerData>[];
    for (final d in packet.data) {
      final wheel =
          d.signalKind == ui.PointerSignalKind.scroll &&
          d.kind == ui.PointerDeviceKind.mouse &&
          math.max(d.scrollDeltaX.abs(), d.scrollDeltaY.abs()) >= _wheelThreshold;
      if (!wheel) {
        pass.add(d);
        continue;
      }
      // 换了位置滚（比如移到另一个列表上）就把之前没滑完的丢掉，从新位置开始
      final t = _template;
      if (t != null && ((t.physicalX - d.physicalX).abs() > 2 || (t.physicalY - d.physicalY).abs() > 2)) {
        _remainX = _remainY = 0;
      }
      // 方向反了也丢掉之前的
      if (_remainY * d.scrollDeltaY < 0) _remainY = 0;
      if (_remainX * d.scrollDeltaX < 0) _remainX = 0;
      _template = d;
      _remainX += d.scrollDeltaX;
      _remainY += d.scrollDeltaY;
      _start();
    }
    if (pass.isNotEmpty) _forward!(ui.PointerDataPacket(data: pass));
  }

  static void _start() {
    if (_timer != null) return;
    _clock
      ..reset()
      ..start();
    _timer = Timer.periodic(_step, (_) => _tick());
  }

  static void _tick() {
    final t = _template;
    final dt = _clock.elapsedMicroseconds / 1000.0;
    _clock
      ..reset()
      ..start();
    if (t == null) return _stop();
    final k = 1 - math.exp(-dt / _tau);
    var dx = _remainX * k, dy = _remainY * k;
    // 剩下很少时一次走完
    if (_remainX.abs() < 1) dx = _remainX;
    if (_remainY.abs() < 1) dy = _remainY;
    _remainX -= dx;
    _remainY -= dy;
    if (dx != 0 || dy != 0) {
      _forward!(ui.PointerDataPacket(data: [_copy(t, dx, dy)]));
    }
    if (_remainX == 0 && _remainY == 0) _stop();
  }

  static void _stop() {
    _timer?.cancel();
    _timer = null;
    _clock.stop();
  }

  static ui.PointerData _copy(ui.PointerData d, double dx, double dy) => ui.PointerData(
    viewId: d.viewId,
    embedderId: d.embedderId,
    timeStamp: d.timeStamp + _clock.elapsed,
    change: d.change,
    kind: d.kind,
    signalKind: d.signalKind,
    device: d.device,
    pointerIdentifier: d.pointerIdentifier,
    physicalX: d.physicalX,
    physicalY: d.physicalY,
    buttons: d.buttons,
    synthesized: true,
    scrollDeltaX: dx,
    scrollDeltaY: dy,
  );
}
