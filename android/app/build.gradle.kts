plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // ID unik aplikasi kamu
        applicationId = "com.example.flutter_application_1"
        
        // TFLite dan Firebase memerlukan minimal SDK 21 agar stabil
        // Jika flutter.minSdkVersion masih 16 atau 19, ganti manual ke 21
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- BAGIAN ANTI-CRASH TFLITE ---
    // Mencegah sistem Android mengompres file model agar bisa dibaca oleh Interpreter
    androidResources {
        noCompress("tflite", "lite")
    }

    buildTypes {
        release {
            // Menggunakan debug signing untuk keperluan testing development
            signingConfig = signingConfigs.getByName("debug")
            
            // Biarkan false agar tidak terjadi obfuscation pada nama class TFLite
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase Bill of Materials (BoM)
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
}
