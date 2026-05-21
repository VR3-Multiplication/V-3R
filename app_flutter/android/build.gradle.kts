allprojects {
    repositories {
        flatDir {
            dirs(file("${rootDir}/unityLibrary/libs"))
        }
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
