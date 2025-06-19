pipeline {
    agent any

    tools {
        gradle 'Gradle_8' // Asegúrate de que el nombre coincida con tu configuración global de Jenkins
        jdk 'JDK_17'      // Asegúrate de que el nombre coincida con tu configuración global de Jenkins
    }

    environment {
        // Variables de entorno para tu pipeline
        DOCKER_REGISTRY = 'docker.io' // O 'ghcr.io' para GitHub Container Registry, o tu registro privado
        DOCKER_USERNAME = 'tu_usuario_docker' // Tu usuario de Docker Hub o GHCR
        IMAGE_NAME = 'juanmafraile/proyectokubernetes' // Reemplaza con el nombre de tu imagen en el registro
        
        // Utiliza el SHA del commit para el tag de la imagen, o si prefieres, env.BUILD_NUMBER
        IMAGE_TAG = "${env.GIT_COMMIT ? env.GIT_COMMIT[0..7] : 'latest'}" 
        
        K8S_NAMESPACE = 'default' // O el namespace de Kubernetes donde desplegarás tu aplicación
        // Reemplaza 'kubernetes-credentials' con el ID de tu credencial de Kubernetes en Jenkins
        KUBERNETES_CREDENTIAL_ID = 'kubernetes-kubeconfig-id' // ID de tu credencial Kubeconfig (tipo Secret File)
        // O si usas un ServiceAccount Token: 'kubernetes-serviceaccount-token-id' (tipo Secret Text)
    }

    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/JuanMaFraile/ProyectoKubernetes.git', branch: 'main'
            }
        }

        stage('Build with Gradle') {
            steps {
                sh 'chmod +x gradlew' // Asegúrate de que el script Gradle Wrapper sea ejecutable
                sh './gradlew clean build'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'chmod +x gradlew'
                sh './gradlew test'
            }
            post {
                always {
                    // Publica los resultados de los tests
                    junit '**/build/test-results/**/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Asegúrate de que el Dockerfile esté en la raíz de tu proyecto
                    // Y que el JAR generado por Gradle (ej. build/libs/your-app.jar) sea copiado correctamente en el Dockerfile
                    docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}", "-f Dockerfile .")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // 'docker-registry-credentials' es el ID de la credencial de tipo 'Username with password'
                    // que configuraste en Jenkins para tu registro Docker (ej. Docker Hub)
                    withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_USERNAME) {
                            docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Esta etapa requiere que 'kubectl' esté disponible en el agente de Jenkins
                    // y que tenga acceso a tu clúster de Kubernetes.

                    // Opción 1: Usando un Kubeconfig (recomendado para agentes que no son pods en K8s)
                    // La credencial 'kubernetes-kubeconfig-id' debe ser de tipo 'Secret file' en Jenkins
                    withCredentials([file(credentialsId: KUBERNETES_CREDENTIAL_ID, variable: 'KUBECONFIG_FILE')]) {
                        // Exporta KUBECONFIG para que kubectl use el archivo de credenciales
                        sh "export KUBECONFIG=${KUBECONFIG_FILE}"
                        sh "kubectl config use-context $(kubectl config current-context)" // Asegura el contexto correcto
                        
                        // Aplica los manifiestos de Kubernetes (asegúrate de que estén en la ruta correcta, ej. kubernetes/)
                        sh "kubectl apply -f kubernetes/deployment.yaml -n ${K8S_NAMESPACE}"
                        sh "kubectl apply -f kubernetes/service.yaml -n ${K8S_NAMESPACE}"
                        // Si tienes otros manifiestos (Ingress, ConfigMaps, etc.), agrégalos aquí.

                        // ¡MUY IMPORTANTE! Actualiza la imagen del Deployment para que Kubernetes tire de la nueva imagen
                        // Asegúrate de que el nombre del deployment en deployment.yaml sea '${IMAGE_NAME}'
                        // y que el nombre del contenedor dentro de ese deployment también sea '${IMAGE_NAME}'
                        sh "kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n ${K8S_NAMESPACE}"
                        
                        // Si usas Helm:
                        // sh "helm upgrade --install ${IMAGE_NAME} ./helm_chart_path --set image.repository=${DOCKER_REGISTRY}/${IMAGE_NAME},image.tag=${IMAGE_TAG} -n ${K8S_NAMESPACE}"
                    }

                    // Opción 2: Usando un token de ServiceAccount (si el agente es un pod de K8s o tienes acceso directo al token)
                    // La credencial 'kubernetes-serviceaccount-token-id' debe ser de tipo 'Secret text' en Jenkins
                    // withCredentials([string(credentialsId: KUBERNETES_CREDENTIAL_ID, variable: 'K8S_TOKEN')]) {
                    //     sh "kubectl config set-cluster my-cluster --server='https://YOUR_KUBERNETES_API_SERVER'"
                    //     sh "kubectl config set-context my-context --cluster=my-cluster --user='my-user'"
                    //     sh "kubectl config set-credentials my-user --token=${K8S_TOKEN}"
                    //     sh "kubectl config use-context my-context"
                    //     sh "kubectl apply -f kubernetes/deployment.yaml -n ${K8S_NAMESPACE}"
                    //     sh "kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n ${K8S_NAMESPACE}"
                    // }
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Limpia el espacio de trabajo del agente después de cada build
            echo 'Pipeline finalizado.'
        }
        success {
            echo '¡Despliegue completado correctamente!'
        }
        failure {
            echo '¡El pipeline falló! Revisa los logs.'
        }
    }
}