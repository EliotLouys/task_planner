plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.zbeub_task_plan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
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

    signingConfigs {
        // KEEP the debug config for local debug builds
        getByName("debug")

        // ADD a RELEASE config to be populated by environment variables/secrets in CI
        create("release") {
             // FIX: Change all instances of .set(...) to the direct assignment operator (=)
             keyAlias = System.getenv("RELEASE_KEY_ALIAS") ?: "release_key"
             keyPassword = System.getenv("RELEASE_KEY_PASSWORD") ?: "password"
             storeFile = file(System.getenv("RELEASE_STORE_FILE") ?: "app_release.jks")
             storePassword = System.getenv("RELEASE_STORE_PASSWORD") ?: "password"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")      

            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }


}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}