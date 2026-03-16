plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}

// buildscript block removed as per user requested format if it was intended to be replaced, 
// but usually older projects have it. The user specifically asked for this plugins block.
// I'll keep the buildscript if it has other things, but here it only had the classpath.

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
