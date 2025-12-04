pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            if (file("local.properties").exists()) {
                file("local.properties").inputStream().use { properties.load(it) }
            }
            var flutterSdkPath = properties.getProperty("flutter.sdk")
            
            // Try environment variable as fallback
            if (flutterSdkPath == null || !file(flutterSdkPath).exists()) {
                flutterSdkPath = System.getenv("FLUTTER_ROOT")
            }
            
            // Try FLUTTER_SDK as another fallback
            if (flutterSdkPath == null || !file(flutterSdkPath).exists()) {
                flutterSdkPath = System.getenv("FLUTTER_SDK")
            }
            
            require(flutterSdkPath != null && file(flutterSdkPath).exists()) { 
                "flutter.sdk not set in local.properties and FLUTTER_ROOT/FLUTTER_SDK environment variables are not set or invalid. " +
                "Please set flutter.sdk in android/local.properties to your Flutter SDK path (e.g., flutter.sdk=C:\\flutter or flutter.sdk=D:\\flutter)"
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
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
