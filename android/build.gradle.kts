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
    if (project.name == "app") {
        return@subprojects
    }

    // Correct way to enforce Java 17 using the Toolchain service
    val toolchainService = project.extensions.findByType(JavaToolchainService::class.java)
    if (toolchainService != null) {
        tasks.withType<JavaCompile>().configureEach {
            javaCompiler.set(toolchainService.compilerFor {
                languageVersion.set(JavaLanguageVersion.of(17))
            })
            // Explicitly force compatibility properties to satisfy Kotlin validation
            sourceCompatibility = "17"
            targetCompatibility = "17"
            // Must clear this as it conflicts with Android builds
            options.release.set(null as Int?)
        }
    } else {
        // Fallback for projects without the service
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
            options.release.set(null as Int?)
        }
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}
