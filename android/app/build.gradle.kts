plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.zhuzhi09.pcl_pw"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.github.zhuzhi09.pcl_pw"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // 游戏运行时需要 Android 8.0 及以上
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 发布签名：CI 通过环境变量提供密钥库；本地没有设置时用调试签名
    val releaseKeystore = System.getenv("PCLPW_KEYSTORE")?.takeIf { file(it).exists() }
    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = file(releaseKeystore)
                storePassword = System.getenv("PCLPW_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("PCLPW_KEY_ALIAS")
                keyPassword = System.getenv("PCLPW_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (releaseKeystore != null) "release" else "debug")
        }
    }
}

android {
    packaging {
        jniLibs {
            // 游戏运行时会 dlopen 这些库，需要解压到 nativeLibraryDir
            useLegacyPackaging = true
            excludes += listOf("**/libawt_headless.so")
            // xdl 的 prefab 包与 ndk-build 输出各带一份
            pickFirsts += listOf("**/libxdl.so", "**/libc++_shared.so")
        }
    }
    // 资源中的 LWJGL jar 不要压缩
    androidResources {
        noCompress += listOf("jar")
    }
}

dependencies {
    implementation(project(":runtime"))
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
