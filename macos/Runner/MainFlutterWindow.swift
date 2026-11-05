import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // 启动器自己绘制 56 像素高的标题栏，使用系统原生的红绿灯按钮。
    // 加一个空的统一样式工具栏，让标题栏变高，红绿灯在启动器标题栏中垂直居中。
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    let toolbar = NSToolbar(identifier: "PCLPWTitleBar")
    toolbar.showsBaselineSeparator = false
    self.toolbar = toolbar
    self.toolbarStyle = .unified

    super.awakeFromNib()
  }
}
