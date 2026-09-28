allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ============================================================
// BUILD DIRECTORY
// ============================================================

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// ============================================================
// SUBPROJECT BUILD DIRECTORY
// ============================================================

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ============================================================
// APP DEPENDENCY
// ============================================================

subprojects {
    project.evaluationDependsOn(":app")
}

// ============================================================
// CLEAN
// ============================================================

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}