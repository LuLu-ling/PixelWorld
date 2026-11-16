# 应用图标

源图在 `assets/icon/source/`：

- `cube_transparent.png`：透明底的白色立方体，所有平台的图标都从它生成。
- `cube_blue.jpg`：最早的蓝底版，现在不再使用，留作参考。

`make_icons.py` 在立方体左侧面印 P、右侧面印 W（按等轴测投影贴到面上，并沿面的法线方向凸起一点，和顶面中间的小方块一致；W 比 P 宽，收窄一些让两边平衡），然后生成：

- 启动器内与 Linux：`assets/icon/icon.png`（透明底）
- 安卓：自适应图标前景、单色主题图标（字母镂空）、旧版图标（白色圆角底）；自适应图标的背景色在 `android/app/src/main/res/values/colors.xml`（白色）
- Windows：`windows/runner/resources/app_icon.ico`
- macOS：`macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- 网站：`docs/icon.png`、`docs/favicon.png`

重新生成（需要 Pillow 和 numpy，字体用 Windows 自带的 Bahnschrift）：

```bash
python tool/icons/make_icons.py
```
