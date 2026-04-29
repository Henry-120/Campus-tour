allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory.get())
}

// 💡 修正 arcore_flutter_plugin 的 namespace 問題
subprojects {
    // 遍歷所有子項目，如果還沒 evaluate 就掛載 hook，如果已經 evaluate 了就直接執行
    val patchAction = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                // 透過動態調用避開編譯期檢查
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                
                if (getNamespace.invoke(android) == null) {
                    setNamespace.invoke(android, "com.example.campus_tour.patch.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) {
                // 忽略錯誤
            }
        }
    }

    if (project.state.executed) {
        patchAction()
    } else {
        project.afterEvaluate { patchAction() }
    }
}
