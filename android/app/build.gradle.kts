plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release keystore credentials from android/key.properties (gitignored).
// Debug builds remain independent of this file. Release builds must have it.
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.honestfern.currency_converter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.honestfern.currency_converter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobApplicationId"] =
            System.getenv("ADMOB_ANDROID_APP_ID")
                ?: "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        if (keystoreProperties.isNotEmpty()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            if (keystoreProperties.isNotEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

val verifyReleaseSigning = tasks.register("verifyReleaseSigning") {
    doLast {
        val requiredKeys = listOf(
            "storeFile",
            "storePassword",
            "keyAlias",
            "keyPassword",
        )
        val missingKeys = requiredKeys.filter { keystoreProperties[it].toString().isBlank() }
        if (missingKeys.isNotEmpty()) {
            throw GradleException(
                "Release signing is not configured. Missing android/key.properties values: " +
                    missingKeys.joinToString(", "),
            )
        }
        val storeFilePath = keystoreProperties.getProperty("storeFile")
        if (!project.file(storeFilePath).isFile) {
            throw GradleException(
                "Release signing keystore not found: ${project.file(storeFilePath).path}",
            )
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(verifyReleaseSigning)
}

flutter {
    source = "../.."
}

// No Glance / Compose-runtime dep is needed for the home-screen widget.
// We use the legacy AppWidgetProvider + RemoteViews pattern (see
// HonestFernAppWidgetProvider.kt) because the Glance-based path trips a
// Kotlin 2.2.20 inliner bug on `currentState<T>()` / `LocalState.current`.
// If we ever move back to Glance, add:
//     implementation("androidx.glance:glance-appwidget:1.1.1")
