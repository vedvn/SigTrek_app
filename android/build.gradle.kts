allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ❌ Do NOT override build directories (Flutter requires defaults)
// ❌ Do NOT relocate build outputs

subprojects {
    // Ensures :app is evaluated first (safe & minimal)
    evaluationDependsOn(":app")
}

// Standard clean task (Flutter-compatible)
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
