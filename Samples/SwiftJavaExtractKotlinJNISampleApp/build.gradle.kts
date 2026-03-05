import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import utilities.javaLibraryPaths
import utilities.registerJextractTask

plugins {
    id("build-logic.java-application-conventions")
    id("org.jetbrains.kotlin.jvm") version "2.1.10"
}

group = "org.swift.swiftkit"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

val jextract = registerJextractTask {
    val cmdArgs = mutableListOf("build", "--disable-experimental-prebuilts", "--disable-sandbox")
    if (project.hasProperty("swiftSdk")) {
        cmdArgs.add("--swift-sdk")
        cmdArgs.add(project.property("swiftSdk").toString())
    }
    cmdArgs
}

sourceSets {
    main {
        kotlin {
            srcDir(jextract)
        }
    }
}

tasks.withType<KotlinCompile>().configureEach {
    dependsOn(jextract)
}

tasks.build {
    dependsOn(jextract)
}

registerCleanSwift()

dependencies {
}

application {
    mainClass = "com.example.swift.HelloKotlin2SwiftJNIKt"

    applicationDefaultJvmArgs = listOf(
        "-Djava.library.path=" + (javaLibraryPaths(rootDir) + javaLibraryPaths(project.projectDir)).joinToString(":"),
        "-Djextract.trace.downcalls=true"
    )
}
