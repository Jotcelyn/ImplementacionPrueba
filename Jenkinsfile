pipeline {
    // Agente: Ejecuta el pipeline en cualquier agente disponible (usualmente el servidor Jenkins).
    agent any

    // Variables de entorno globales para reutilización.
    environment {
        // Asegúrate de cambiar esto a tu usuario de Docker Hub
        DOCKER_IMAGE = "tuusuario/implementacionprueba" 
        // Nombre de la credencial de Jenkins para Docker Hub
        DOCKER_CRED_ID = 'docker-hub-creds'
        APP_CONTAINER_NAME = 'mi-app-web-contenedor'
    }

    stages {
        // ==========================================================
        // STAGE 1: CI - Construcción del código con Maven
        // ==========================================================
        stage('Maven Build') {
            steps {
                // Ejecuta la compilación de Maven. Asume que pom.xml está en la raíz.
                // Usamos 'sh' para ejecutar comandos de shell.
                sh 'mvn clean package -DskipTests' 
            }
        }
        
        // ==========================================================
        // STAGE 2: CI - Pruebas Unitarias (Opcional, pero recomendado)
        // ==========================================================
        stage('Test') {
            steps {
                // Aquí irían los pasos para ejecutar pruebas (si no se ejecutaron arriba)
                // sh 'mvn test' 
                echo 'Skipping unit tests for quick demonstration.'
            }
        }
        
        // ==========================================================
        // STAGE 3: CD - Construcción de la Imagen Docker
        // ==========================================================
        stage('Build Docker Image') {
            steps {
                // Construye la imagen usando el Dockerfile en la raíz.
                // Etiqueta la imagen con el número de construcción de Jenkins.
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_ID} ."
            }
        }

        // ==========================================================
        // STAGE 4: CD - Subida a Docker Hub
        // ==========================================================
        stage('Push to Docker Hub') {
            // AÑADIR EL BLOQUE 'steps' AQUI
            steps { 
                // Usa las credenciales de Docker Hub almacenadas en Jenkins
                withCredentials([usernamePassword(credentialsId: DOCKER_CRED_ID, 
                                                 passwordVariable: 'DOCKER_PASSWORD', 
                                                 usernameVariable: 'DOCKER_USERNAME')]) {
                    // Aquí van los comandos sh
                    sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_ID} ${DOCKER_IMAGE}:latest"
                    
                    // 2. Login en Docker Hub (usa las variables de credenciales)
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    
                    // 3. Subir las dos etiquetas (BUILD_ID y latest)
                    sh "docker push ${DOCKER_IMAGE}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        // ==========================================================
        // STAGE 5: CD - Despliegue de la Aplicación
        // ==========================================================
        stage('Deploy Application') {
            steps {
                echo "Deploying container ${APP_CONTAINER_NAME}..."
                
                // Detener y eliminar el contenedor antiguo (si existe)
                // '|| true' evita que el pipeline falle si el contenedor no existe
                sh "docker stop ${APP_CONTAINER_NAME} || true" 
                sh "docker rm ${APP_CONTAINER_NAME} || true"
                
                // Iniciar la nueva versión de la aplicación
                // Requisito: La aplicación web debe funcionar al iniciar el contenedor.
                sh "docker run -d --name ${APP_CONTAINER_NAME} -p 8080:8080 ${DOCKER_IMAGE}:latest"
                
                echo "Application deployed. Check http://localhost:8080"
            }
        }
    } 
} 
