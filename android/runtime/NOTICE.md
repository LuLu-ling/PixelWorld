# PCL.PW game runtime

This Android library runs Minecraft: Java Edition inside the PCL.PW launcher. It is licensed
under the **GNU Lesser General Public License v3.0** (see `LICENSE`), separately from the rest of
PCL.PW (Apache-2.0). The launcher only talks to it through
`io.github.zhuzhi09.pclpw.runtime.GameRuntime` and `GameActivity`, so this module can be rebuilt,
modified or replaced on its own, as the LGPL requires.

## Origins

| Part | From | License |
|---|---|---|
| `src/main/jni` (except `nsbypass/`) | [Amethyst-Android](https://github.com/AngelAuraMC/Amethyst-Android) `app_pojavlauncher/src/main/jni`, commit `28d6e12`; SDL3 include replaced with three constants | LGPL-3.0 |
| `src/main/jni/jre_launcher.c` | Boardwalk / OpenJDK launcher code via Amethyst | GPLv2 with Classpath Exception |
| `src/main/jni/nsbypass/` | [androidnsbypass](https://github.com/alexytomi/androidnsbypass) | MIT / BSD-2-Clause |
| `src/main/java/org/lwjgl/glfw/CallbackBridge.java`, `net/kdt/pojavlaunch/*` | Amethyst-Android, trimmed (no SDL, no gamepad remapper) | LGPL-3.0 |
| `src/main/java/io/github/zhuzhi09/pclpw/runtime/*` | written for PCL.PW; environment and JVM arguments follow Amethyst's `JREUtils` | LGPL-3.0 |
| `src/main/jniLibs/arm64-v8a/libmobileglues.so` | [MobileGlues](https://github.com/MobileGL-Dev/MobileGlues), prebuilt from Amethyst `libs/MobileGlues-release.aar` | LGPL-2.1 |
| `src/main/jniLibs/arm64-v8a/libopenal.so` | [OpenAL Soft](https://github.com/kcat/openal-soft), prebuilt from Amethyst | LGPL-2.0 |
| `src/main/jniLibs/arm64-v8a/liblwjgl*.so`, `libfreetype.so` | [LWJGL 3.3.3 for Android](https://github.com/AngelAuraMC/lwjgl3), prebuilt from Amethyst | BSD-3-Clause (FreeType: FTL) |
| `src/main/assets/lwjgl3/3.3.3/*.jar` | Amethyst's LWJGL 3.3.3 build, including the GLFW stub (`jre_lwjgl3glfw`) | BSD-3-Clause / LGPL-3.0 (GLFW stub) |
| `src/main/assets/lwjgl3/3.4.1/*.jar`, `src/main/assets/lwjgl3/3.4.1/natives/*.so` | Amethyst's LWJGL 3.4.1 build (from `components/lwjgl3/3.4.1` and `libs/lwjgl-3.4.1-natives-release.aar`), with the GLFW stub and SDL overrides; used by versions that run on SDL3 (26.x). `org/lwjgl/sdl/SDLMouse*.class` in the merged-modules jar is compiled from Amethyst's `jre_lwjgl3glfw/lwjgl-3.4.1/src/main/java/org/lwjgl/sdl/SDLMouse.java`, which the prebuilt jar lacked | BSD-3-Clause / LGPL-3.0 (stub and overrides; FreeType: FTL) |
| `src/main/assets/lwjgl3/3.4.1/natives/libspirv-cross-c-shared.so` | [SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross), prebuilt from Amethyst `libs/spirv-cross-natives.aar`, debug symbols stripped | Apache-2.0 |
| `src/main/assets/lwjgl3/3.4.1/natives/libshaderc.so` | [shaderc](https://github.com/google/shaderc), from Amethyst's LWJGL 3.4.1 natives | Apache-2.0 |
| `agent/src`, `src/main/assets/lwjgl3/3.4.1/agent/pclpw-agent.jar` | written for PCL.PW: renames 26.x's generated uniform block names that MobileGlues mis-parses. Rebuild the jar with `javac --release 8` and `jar cfm pclpw-agent.jar agent/MANIFEST.MF` | LGPL-3.0 |
| `src/main/jni/sdlshim` | written for PCL.PW: lets 26.x's several SDL windows share Android's single window | LGPL-3.0 |
| `src/main/jniLibs/arm64-v8a/libEGL_mesa.so`, `libglapi.so`, `libzink_dri.so` | [Mesa](https://mesa3d.org) Zink (kopper), prebuilt from Amethyst `libs/kopper-zink-release.aar`; Amethyst's `libglxshim.so` is not used (no license), libpojavexec provides `glXGetProcAddress` instead | MIT and others, see `licenses/mesa-licenses.rst` |
| `src/main/jniLibs/arm64-v8a/libvulkan_freedreno.so` | Mesa Turnip (open-source Vulkan driver for Adreno), prebuilt from Amethyst `jniLibs`; used with Zink on Adreno | MIT, see `licenses/mesa-licenses.rst` |
| `src/main/jni/driver_helper/turnip/hook.c` | Amethyst-Android `jni/driver_helper/internal_android_dlopen_hook/turnip/hook.c` (`liblinkerhook.so`) | LGPL-3.0 |
| `src/main/jniLibs/arm64-v8a/libSDL3.so` | [SDL 3](https://github.com/libsdl-org/SDL), prebuilt from Amethyst `libs/SDL-release.aar` | zlib |
| `src/main/java/org/libsdl/app/*` | SDL3's Android Java glue as modified by Amethyst-Android (runs without an SDLActivity); Amethyst launcher references replaced | zlib (SDL) / LGPL-3.0 (Amethyst changes) |
| `src/main/java/net/kdt/pojavlaunch/EfficientAndroidLWJGLKeycode.java` | Amethyst-Android, GLFW to Android key code table | LGPL-3.0 |
| `src/main/assets/lwjgl3/3.3.3/lwjgl-lwjglx.jar` | LWJGL 2 compatibility layer from [AngelAuraMC/lwjgl3](https://github.com/AngelAuraMC/lwjgl3), via Amethyst | BSD-3-Clause |
| `src/main/jniLibs/arm64-v8a/libSimpleFPEWrapper.so` | [SimpleFPEWrapper](https://github.com/MobileGL-Dev/SimpleFPEWrapper), fixed-function pipeline emulation; prebuilt from Amethyst `libs/SimpleFPEWrapper-release.aar` | LGPL-3.0 |

Java runtimes are not bundled. The launcher downloads Android builds of OpenJDK
(GPLv2 with Classpath Exception) from
[angelauramc-openjdk-build](https://github.com/AngelAuraMC/angelauramc-openjdk-build/releases),
where their source is published.
