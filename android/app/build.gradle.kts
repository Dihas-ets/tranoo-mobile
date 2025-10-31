//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "tech.dihas.tranoo"
//    compileSdk = 33
//    ndkVersion = "25.2.9519653"
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//        applicationId = "tech.dihas.tranoo"
//        minSdk = 21
//        targetSdk = 33
//        versionCode = 2
//        versionName = "1.0.1"
//    }
//
//    buildTypes {
//        release {
//            isMinifyEnabled = false
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}


plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "tech.dihas.tranoo" // ton identifiant unique
    compileSdk = 34

    defaultConfig {
        applicationId = "tech.dihas.tranoo"
        minSdk = 21
        targetSdk = 34
        versionCode = 2 // incrémente si c’est une mise à jour
        versionName = "1.1.0" // incrémente si c’est une mise à jour
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // ⚠️ Met ici ton keystore pour Google Play
            signingConfig = signingConfigs.getByName("debug") // temporaire, mais pour Play Store il faut release
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
