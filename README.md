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

项目仍在开发中，已经可以日常使用：版本下载与安装、模组加载器、正版与离线账户、启动游戏、崩溃分析等功能可用。

| 平台 | 状态 |
|---|---|
| Windows | 可用 |
| Android | 可用（需要 Android 8.0 及以上、64 位 ARM），游戏运行时见 [android/runtime](android/runtime/NOTICE.md) |
| macOS | 正在测试，暂不提供下载 |
| Linux | 尚未适配 |

## 下载

在 [Releases](https://github.com/zhuzhi-09/PCL.PW/releases) 页面下载：

- **正式版**：推送 `v*` 标签时自动构建发布。
- **Nightly**：`main` 分支每次更新后自动构建，发布为名为 `nightly` 的预发布版本，包含最新改动，可能不稳定。

## 构建

需要 Flutter 3.47 或更高版本。Windows 构建另需 Visual Studio 2022 的“使用 C++ 的桌面开发”工作负载（含 C++ CMake 工具）。

```bash
flutter pub get
flutter run -d windows
flutter build windows --release --no-tree-shake-icons
```

发布构建需要加 `--no-tree-shake-icons`：当前 Flutter 版本裁剪图标字体时会漏掉部分图标。

打包 Windows 安装程序与便携版（输出到 `dist/`）：

```bash
dart run tool/build_installer.dart
```

安装程序只为当前用户安装，不需要管理员权限；外壳用系统自带的 .NET Framework 编译器编译。

安卓版（arm64）：

```bash
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons
```

自动发布由 [.github/workflows/release.yml](.github/workflows/release.yml) 完成。安卓的发布签名来自仓库 Secrets：`ANDROID_KEYSTORE_BASE64`（密钥库的 base64）、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`；没有配置时使用调试签名。

## 许可证

PCL.PW 自身的代码以 [Apache-2.0](LICENSE) 协议开源。PCL 的相关规则见 [PCL-GUIDE.md](PCL-GUIDE.md)。

Minecraft 是 Mojang Studios 的商标。本软件不是官方 Minecraft 产品，未经 Mojang 或 Microsoft 批准，也与其无关。
