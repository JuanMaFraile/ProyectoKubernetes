pipeline {
    agent any

    tools {
        gradle 'Gradle_8' // Define el nombre como esté en Jenkins (Manage Jenkins → Global Tool Configuration)
        jdk 'JDK_17'      // Define también el nombre que diste a JDK
    }

    environment {
        // Variables opcionales
        JAVA_HOME = "${tool 'JDK_17'}"
    }

    stages {
        stage('Clonar repositorio') {
            steps {
                git url: 'https://github.com/JuanMaFraile/ProyectoKubernetes.git', branch: 'main'
            }
        }

        stage('Compilar') {
            steps {
                sh './gradlew clean build' // O 'gradle build' si usas Gradle del sistema
            }
        }

        stage('Pruebas') {
            steps {
                sh './gradlew test'
            }
        }

        stage('Empaquetar') {
            steps {
                sh './gradlew jar'
            }
        }

        stage('Publicar artefacto') {
            steps {
                echo 'Aquí puedes subir el .jar a Nexus, Artifactory o copiarlo a otro servidor.'
            }
        }
    }

    post {
        success {
            echo 'Build completado correctamente.'
        }
        failure {
            echo 'La compilación falló.'
        }
    }
}
