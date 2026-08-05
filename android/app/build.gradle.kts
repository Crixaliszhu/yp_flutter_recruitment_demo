plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle 插件必须放在 Android 和 Kotlin Gradle 插件之后应用。
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yupao.demo.yp_flutter_recruitment_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO：上线前替换为正式唯一的 Application ID。
        applicationId = "com.yupao.demo.yp_flutter_recruitment_demo"
        // MMKV Android 插件要求 minSdk >= 23，因此这里显式覆盖 Flutter 默认 minSdk。
        // 配置说明：https://flutter.dev/to/review-gradle-config
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO：正式发布前替换为 release 签名配置。
            // 当前暂用 debug 签名，便于 `flutter run --release` 在 demo 阶段直接运行。
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
