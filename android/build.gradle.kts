// ⚠️ Do NOT declare repositories here
// ⚠️ Do NOT use buildscript {} block (handled in settings.gradle.kts)

// Ensures :app is evaluated first
subprojects {
    evaluationDependsOn(":app")
}

// Standard clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
