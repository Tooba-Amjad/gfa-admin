allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    project.extra["compileSdk"] = 34
    project.extra["minSdk"] = 21
    project.extra["targetSdk"] = 34
    project.extra["javaVersion"] = JavaVersion.VERSION_11

    // Force JVM 17 for all Android projects
    plugins.withType<com.android.build.gradle.BasePlugin>().configureEach {
        val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension
        android.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

    // Force JVM 17 for all Kotlin tasks
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}
