# PCL.PW（PixelsWorld 修改版）

PCL.PW 是一个跨平台的 Minecraft 启动器，页面布局参考 PCL，视觉上遵循 Google 的 Material Design 3 设计语言，使用 Flutter 开发，目标平台为 Windows、macOS、Linux 与 Android。

> [!IMPORTANT]
> **PCL.PW 是第三方基于 [Plain Craft Launcher（PCL）](https://github.com/Meloong-Git/PCL) 独立进行二次创作的产物**，由第三方开发和维护，与 PCL 及其作者龙腾猫跃无关，也不代表 PCL 官方。请勿就本软件的问题打扰 PCL 作者。
>
> 如果 PCL 对你有帮助，欢迎[赞助 PCL 的作者龙腾猫跃](https://afdian.com/a/LTCat)。

本项目遵循 PCL 的[《PCL 存储库合理使用指南》](PCL-GUIDE.md)，包括：

- 名称以 PCL 开头，并带有表明第三方修改的后缀；
- 关于页的首位为龙腾猫跃的署名及赞助链接；
- 源代码公开，并随项目继续使用该指南；
- 启动游戏前提供正版购买劝导与赞助劝导；
- 界面主色固定为 PCL 主题蓝，不提供更换主题色的功能。

## 状态

项目正在从 Electron 版重写为 Flutter 版，目前完成了界面框架（PCL 布局、MD3 配色、浅色 / 深色模式、关于页），游戏启动、下载、账户等功能正在迁移。

## 构建

需要 Flutter 3.47 或更高版本。Windows 构建另需 Visual Studio 2022 的“使用 C++ 的桌面开发”工作负载（含 C++ CMake 工具）。

```bash
flutter pub get
flutter run -d windows
flutter build windows --release --no-tree-shake-icons
```

发布构建需要加 `--no-tree-shake-icons`：当前 Flutter 版本裁剪图标字体时会漏掉部分图标。

## 许可证

PCL.PW 自身的代码以 [Apache-2.0](LICENSE) 协议开源。PCL 的相关规则见 [PCL-GUIDE.md](PCL-GUIDE.md)。

Minecraft 是 Mojang Studios 的商标。本软件不是官方 Minecraft 产品，未经 Mojang 或 Microsoft 批准，也与其无关。
