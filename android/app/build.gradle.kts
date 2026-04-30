import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Load release signing config from android/key.properties ─────────
//
// File NOT committed to git. Generate the keystore once with:
//   keytool -genkeypair -v -keystore android/keys/release.jks ...
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.newhorizon.hr_portal_admin"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.newhorizon.hr_portal_admin"
        // Min Android 7.0 (API 24) — covers ~99% of devices and required by
        // several plugins (firebase, awesome_notifications).
        minSdk = 24
        // Required by Google Play in 2024+: target API 34 (Android 14).
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Locale used by the launcher icon's app_name (string resource).
        resourceConfigurations.addAll(listOf("ar", "en"))
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release keystore when key.properties is present, otherwise
            // fall back to debug keys so `flutter run --release` keeps working.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Shrinking + obfuscation. Reduces APK size & makes reverse
            // engineering harder. Tweak proguard-rules.pro if a plugin breaks.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            // Keep debug builds easy to attach to.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
