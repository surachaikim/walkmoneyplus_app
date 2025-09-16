import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mixproad.walkmoney"
    compileSdk = 35

        // โหลดค่า keystore
    val keystoreProperties = Properties().apply {
        val f = rootProject.file("key.properties")
        if (f.exists()) {
            load(FileInputStream(f))
        } else {
            println("WARNING: key.properties not found. Using debug signing for release.")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.mixproad.walkmoney"
        minSdk = 21
        targetSdk = 35
    // version bump for release 2.1.1 (build 2)
    versionCode = 2
    versionName = "2.1.1"
    }


        signingConfigs {
        // สร้าง release config (ถ้าไม่มี key.properties จะไม่เซ็ตค่า และใช้ debug แทน)
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                val storeFilePath = keystoreProperties["storeFile"] as String?
                if (!storeFilePath.isNullOrBlank()) {
                    storeFile = file(storeFilePath)
                    storePassword = keystoreProperties["storePassword"] as String?
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                }
            }
        }
    }

   buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )
            // ใช้ release signing ถ้ามีค่าครบ มิฉะนั้น fallback เป็น debug
            signingConfig = if (signingConfigs.findByName("release")?.storeFile != null)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
        debug {
            // debug เหมือนเดิม
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ไม่ต้องแก้ไขส่วนนี้
}