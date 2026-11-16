import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// 侧栏在窗口里的左边位置和宽度、顶栏中线的 y（窗口坐标，单位 pt，从上往下算）。
  /// 由 Flutter 按实际界面缩放发过来（lib/widgets/mac_traffic_lights.dart），收到之前用默认值：
  /// 侧栏宽 84、顶栏高 56（见 lib/shell.dart 的 _Rail 与 _TopBar）
  private var railLeft: CGFloat = 0
  private var railWidth: CGFloat = 84
  private var trafficLightsCenterY: CGFloat = 28

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // 启动器自己绘制标题栏，使用系统原生的红绿灯按钮（保留悬停菜单、全屏、分屏等系统功能），
    // 只是把它们挪到侧栏里，和微信等应用一样
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)

    let channel = FlutterMethodChannel(
      name: "pclpw/window", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setTrafficLights", let self = self,
        let args = call.arguments as? [String: Any]
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      func value(_ key: String) -> CGFloat? { (args[key] as? NSNumber).map { CGFloat($0.doubleValue) } }
      if let v = value("railLeft") { self.railLeft = v }
      if let v = value("railWidth"), v > 0 { self.railWidth = v }
      if let v = value("centerY"), v > 0 { self.trafficLightsCenterY = v }
      self.layoutTrafficLights()
      result(nil)
    }

    // 系统在窗口缩放、进出全屏、切换焦点时会把按钮放回默认位置，每次都重新摆一次
    let center = NotificationCenter.default
    for name in [
      NSWindow.didResizeNotification,
      NSWindow.didEndLiveResizeNotification,
      NSWindow.didExitFullScreenNotification,
      NSWindow.didBecomeKeyNotification,
      NSWindow.didResignKeyNotification,
      NSWindow.didChangeBackingPropertiesNotification,
    ] {
      center.addObserver(self, selector: #selector(trafficLightsNeedLayout), name: name, object: self)
    }

    super.awakeFromNib()
    layoutTrafficLights()
  }

  @objc private func trafficLightsNeedLayout() {
    layoutTrafficLights()
    // 系统可能在通知之后才完成自己的布局，下一轮再摆一次
    DispatchQueue.main.async { [weak self] in self?.layoutTrafficLights() }
  }

  /// 做法同 Electron 的 trafficLightPosition：加高按钮所在的标题栏容器，再逐个设置按钮位置
  private func layoutTrafficLights() {
    // 全屏时标题栏由系统管理
    if styleMask.contains(.fullScreen) { return }
    guard
      let close = standardWindowButton(.closeButton),
      let miniaturize = standardWindowButton(.miniaturizeButton),
      let zoom = standardWindowButton(.zoomButton),
      let container = close.superview?.superview
    else { return }

    let buttonHeight = close.frame.height
    let containerHeight = trafficLightsCenterY * 2
    var rect = container.frame
    rect.size.height = containerHeight
    rect.origin.y = frame.height - containerHeight
    container.frame = rect

    // 三个按钮连同间距的总宽度（不同系统版本按钮大小不同，按实际大小算），在侧栏里水平居中
    let spacing = miniaturize.frame.origin.x - close.frame.origin.x
    let span = spacing * 2 + zoom.frame.width
    let left = railLeft + max(6, (railWidth - span) / 2)
    for (i, button) in [close, miniaturize, zoom].enumerated() {
      button.setFrameOrigin(
        NSPoint(x: left + CGFloat(i) * spacing, y: (containerHeight - buttonHeight) / 2))
    }
  }
}
