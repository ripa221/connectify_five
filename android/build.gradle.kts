// Top-level build.gradle.kts for Connectify project

// Step 1: Configure Gradle plugins used in this project (Android, Kotlin, Firebase)
buildscript {
    dependencies {
        // Android Gradle Plugin (compatible with Kotlin and Firebase)
        classpath("com.android.tools.build:gradle:7.4.2")

        // Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")

        // Google Services plugin for Firebase (required for google-services.json)
        classpath("com.google.gms:google-services:4.4.0")
    }

    // Step 2: Define repositories for resolving plugin dependencies
    repositories {
        google()       // Google's Maven repository (Firebase, AndroidX, etc.)
        mavenCentral() // Kotlin, third-party, and open-source libraries
    }
}

// Step 3: Configure repositories for all modules in the project
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Step 4: Define a shared root-level build directory to separate output from source
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Step 5: Apply the shared build directory to all subprojects
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Step 6: Ensure app module is evaluated first to prevent resolution issues
subprojects {
    project.evaluationDependsOn(":app")
}

// Step 7: Register a global clean task to delete all build outputs
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Step 8: Compatibility patch for flutter_local_notifications if included locally
// Only required if using local plugin override with old-style namespace
subprojects {
    if (name.contains("flutter_local_notifications")) {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "com.etutemp.fix.localnotifications" // Example namespace override
            }
        }
    }
}
