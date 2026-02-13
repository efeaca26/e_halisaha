plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.e_halisaha"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // --- İMZA AYARLARI BURADA BAŞLIYOR ---
    signingConfigs {
        create("release") {
            // upload-keystore.jks dosyasını android/app klasörüne koyduğunu varsayıyoruz
            storeFile = file("upload-keystore.jks")
            storePassword = "acf!112621"
            keyAlias = "upload"
            keyPassword = "acf!112621"
        }
    }

    defaultConfig {
        applicationId = "com.example.e_halisaha"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Debug anahtarını senin gerçek anahtarınla değiştirdik
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}