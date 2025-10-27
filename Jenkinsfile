// Definición del Pipeline Declarativo
pipeline {
    // Agente global: Usamos el agente principal de Jenkins (debe tener Docker instalado).
    agent any 

    environment {
        // Asegúrate de cambiar esto a tu usuario de Docker Hub
        DOCKER_IMAGE = "tuusuario/implementacionprueba" 
        DOCKER_CRED_ID = 'docker-hub-creds'
        APP_CONTAINER_NAME = 'mi-app-web-contenedor'
    }

    // Directiva tools: Asegura que Maven esté en el PATH para cualquier etapa que lo necesite.
    // El nombre 'M3_HOME' DEBE coincidir con el nombre que configuraste en Global Tool Configuration.
    tools {
        maven 'M3_HOME'
    }

    stages {
        // ==========================================================
        // STAGE 1: CI - Construcción del código con Maven
        // ==========================================================
        stage('Maven Build') {
            steps {
                // El comando 'mvn' ahora funcionará porque está en la directiva 'tools'
                sh 'mvn clean package -DskipTests' 
            }
        }
        
        // ==========================================================
        // STAGE 2: CI - Pruebas Unitarias
        // ==========================================================
        stage('Test') {
            steps {
                // Aquí podrías ejecutar pruebas unitarias si las tuvieras: sh 'mvn test'
                echo 'Skipping unit tests for quick demonstration.'
            }
        }
        
        // ==========================================================
        // STAGE 3: CD - Construcción de la Imagen Docker
        // ==========================================================
        stage('Build Docker Image') {
            steps {
                // Construye la imagen usando el Dockerfile en la raíz.
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_ID} ."
            }
        }

        // ==========================================================
        // STAGE 4: CD - Subida a Docker Hub
        // ==========================================================
        stage('Push to Docker Hub') {
            steps { 
                withCredentials([usernamePassword(credentialsId: DOCKER_CRED_ID, 
                                                 passwordVariable: 'DOCKER_PASSWORD', 
                                                 usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_ID} ${DOCKER_IMAGE}:latest"
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
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
                sh "docker stop ${APP_CONTAINER_NAME} || true" 
                sh "docker rm ${APP_CONTAINER_NAME} || true"
                sh "docker run -d --name ${APP_CONTAINER_NAME} -p 8080:8080 ${DOCKER_IMAGE}:latest"
                echo "Application deployed. Check http://localhost:8080"
            }
        }
    } 
}
