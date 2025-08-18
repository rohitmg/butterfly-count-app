// android/settings.gradle.kts
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id("com.android.application") version "8.1.0" apply false // Or your current AGP version
        id("org.jetbrains.kotlin.android") version "2.1.0" apply false // <--- UPDATE THIS LINE
        id("com.android.library") version "8.1.0" apply false // Or your current AGP version
        id("io.flutter.plugin") version "0.0.0-dev" apply false
    }
}

// The include statement is correct.
include(":app")
