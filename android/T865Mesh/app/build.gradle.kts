plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "dev.t865.mesh"
    compileSdk = 36
    ndkVersion = "27.2.12479018"
    defaultConfig {
        applicationId = "dev.t865.mesh"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "0.1"
        ndk { abiFilters += "arm64-v8a" }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
kotlin { compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) } }

// Normal Android Studio/Gradle builds compile the Rust library too.
val compileRust by tasks.registering(Exec::class) {
    val root = rootProject.projectDir.resolve("../../rust")
    inputs.files(fileTree(root.resolve("src")), fileTree(root.resolve("proto")))
    inputs.files(root.resolve("Cargo.toml"), root.resolve("Cargo.lock"), root.resolve("build.rs"), rootProject.file("build-native.sh"))
    outputs.file(layout.projectDirectory.file("src/main/jniLibs/arm64-v8a/libt865_mesh.so"))
    workingDir(rootProject.projectDir)
    commandLine("bash", "build-native.sh")
}
tasks.named("preBuild") { dependsOn(compileRust) }
