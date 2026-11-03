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

Java runtimes are not bundled. The launcher downloads Android builds of OpenJDK
(GPLv2 with Classpath Exception) from
[angelauramc-openjdk-build](https://github.com/AngelAuraMC/angelauramc-openjdk-build/releases),
where their source is published.
