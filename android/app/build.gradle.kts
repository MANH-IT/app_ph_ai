plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.apps_health_ai"
    compileSdk = 36 // ← tăng lên 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.apps_health_ai"
        minSdk = 24
        targetSdk = 36 // ← tăng lên 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
