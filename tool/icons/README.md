# 应用图标

源图在 `assets/icon/source/`：

- `cube_blue.jpg`：蓝底版，用于 Windows、macOS、安卓旧版图标和"关于"页（立方体是白色的，浅色背景上需要蓝底）。
- `cube_transparent.png`：透明版，用于安卓自适应图标前景，背景色是 `#1471FD`；单色主题图标由它的透明通道生成。

重新生成（Windows PowerShell 5.1）：

```powershell
# 1. 在两个侧面印上 "P C / L ." 和 "PW"
.\tool\icons\icon_text.ps1 -Src assets\icon\source\cube_blue.jpg -Out $env:TEMP\blue.png
.\tool\icons\icon_text.ps1 -Src assets\icon\source\cube_transparent.png -Out $env:TEMP\fg.png -Scale 1.05 -TopY 270
# 2. 生成各平台尺寸
.\tool\icons\make_icons.ps1 -Blue $env:TEMP\blue.png -Fg $env:TEMP\fg.png -Repo .
```