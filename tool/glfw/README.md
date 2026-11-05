# 修改版 GLFW（macOS，Apple 芯片）

`assets/macos/libglfw.3.dylib` 是修改过的 [GLFW](https://www.glfw.org/) 3.4，许可证见同目录的 `LICENSE.md`（zlib 许可证）。

## 用途

Apple 芯片的 Mac 上运行 Minecraft 1.13～1.18 时，启动器把游戏自带的 LWJGL 3.1/3.2 换成有 arm64 本地库的 3.3.1（`lib/core/version.dart`）。
LWJGL 3.3.1 自带的 GLFW 在 macOS 上设置窗口图标时会报错 65548（`Cocoa: Regular windows do not have icons on macOS`），
而这些版本的游戏把所有 GLFW 错误都当作致命错误。启动时用 `-Dorg.lwjgl.glfw.libname` 改用这份 GLFW（`lib/core/mac_glfw.dart`）。

## 修改内容

只删除了 `src/cocoa_window.m` 中 `_glfwSetWindowIconCocoa` 里报告错误的一行，函数变为空函数（与 GLFW 3.3 在 macOS 上的行为相同）：

```diff
 void _glfwSetWindowIconCocoa(_GLFWwindow* window,
                              int count, const GLFWimage* images)
 {
-    _glfwInputError(GLFW_FEATURE_UNAVAILABLE,
-                    "Cocoa: Regular windows do not have icons on macOS");
 }
```

## 构建方法（在 Mac 上）

```bash
curl -LO https://github.com/glfw/glfw/releases/download/3.4/glfw-3.4.zip
# SHA-256: b5ec004b2712fd08e8861dc271428f048775200a2df719ccf575143ba749a3e9
unzip glfw-3.4.zip && cd glfw-3.4
# 按上面的修改删除 src/cocoa_window.m 中的两行
cmake -S . -B build -DBUILD_SHARED_LIBS=ON -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_BUILD_TYPE=Release -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF
cmake --build build
cp build/src/libglfw.3.4.dylib ../assets/macos/libglfw.3.dylib
```
