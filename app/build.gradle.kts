plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    namespace = "com.example.versionscriptproject"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.versionscriptproject"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0.0"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
