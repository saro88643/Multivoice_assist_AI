pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()

            file("local.properties").inputStream().use {
                properties.load(it)
            }

            val flutterSdkPath = properties.getProperty("flutter.sdk")

            require(flutterSdkPath != null) {
                "flutter.sdk not set in local.properties"
            }

            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    id("com.android.application") version "9.0.1" apply false

    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)

    val storageUrl =
        System.getenv("FLUTTER_STORAGE_BASE_URL")
            ?: "https://storage.googleapis.com"

    repositories {
        google()
        mavenCentral()

        // Flutter engine/plugin artifacts
        maven("$storageUrl/download.flutter.io")

        // uCrop used by image_cropper
        maven("https://jitpack.io")
    }
}

rootProject.name = "multivoice_assist"

include(":app")