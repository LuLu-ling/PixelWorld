// PCL.PW game runtime. LGPL-3.0, kept apart from the launcher (Apache-2.0) so it can be replaced. See NOTICE.md
plugins {
    id("com.android.library")
}

android {
    namespace = "io.github.zhuzhi09.pclpw.runtime"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("consumer-rules.pro")
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
        externalNativeBuild {
            ndkBuild {
                arguments += listOf("APP_SHORT_COMMANDS=true")
            }
        }
    }

    externalNativeBuild {
        ndkBuild {
            path = file("src/main/jni/Android.mk")
        }
    }

    buildFeatures {
        prefab = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        abortOnError = false
    }
}

dependencies {
    implementation("androidx.annotation:annotation:1.9.1")
    implementation("io.github.hexhacking:xdl:2.4.0")
    implementation("org.apache.commons:commons-compress:1.27.1")
    implementation("org.tukaani:xz:1.10")
    // libjnidispatch.so for Android; the game loads it through -Djna.boot.library.path
    implementation("net.java.dev.jna:jna:5.14.0@aar")
}
