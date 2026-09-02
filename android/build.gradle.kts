buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Classpath untuk Firebase Google Services
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Pengaturan lokasi Build Directory (Default Flutter)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// PENTING: Pindahkan script bypass ke atas sebelum evaluationDependsOn
subprojects {
    // bypass namespace untuk library lama (seperti flutter_tflite)
    // Kita gunakan plugins.withType agar tidak tabrakan dengan siklus evaluasi
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        extensions.configure<com.android.build.gradle.BaseExtension> {
            if (namespace == null) {
                namespace = project.group.toString()
            }
        }
    }
}

subprojects {
    // Pastikan ini hanya berjalan jika project bukan root
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}