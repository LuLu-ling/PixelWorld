# Windows 安装器外壳

这里是 Windows 安装程序的原生外壳（C#），与 `lib/installer/` 中的 Flutter 安装界面配合使用：

- `Shell.cs`：带 payload.zip 资源时显示加载动画并解压，再启动 PCL.PW 的安装界面；带 `--cleanup` 参数时在卸载后删除剩余文件。
- `Theme.cs`：外壳使用的颜色。
- `shell.manifest`：应用清单。

不需要手动编译。`dart run tool/build_installer.dart` 会用 Windows 自带的 .NET Framework 编译器 `csc` 编译它，并把程序打包进去。
