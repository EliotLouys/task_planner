plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.zbeub_task_plan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.zbeub_task_plan"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // FIX: Block to rename the APK file to include version number
    applicationVariants.configureEach {
        // Only target the release build variant
        if (name == "release") {
            // Retrieve version details from defaultConfig
            val versionName = defaultConfig.versionName
            val versionCode = defaultConfig.versionCode

            // Configure the output file name for the release variant
            outputs.configureEach { output ->
                // Use 'output.outputFileName' to correctly resolve the property
                output.outputFileName.set("app-release-$versionName-$versionCode.apk")
            }
        }
    }
    // END FIX

}

flutter {
    source = "../.."
}


