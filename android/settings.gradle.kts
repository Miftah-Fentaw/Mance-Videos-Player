pluginManagement {
    val flutterSdkPath = File(
        System.getenv("FLUTTER_ROOT")
            ?: throw GradleException("FLUTTER_ROOT environment variable not found.")
    )

    includeBuild("${flutterSdkPath.absolutePath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}



plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
