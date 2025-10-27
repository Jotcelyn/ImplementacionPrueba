pipeline {
    // Agente global: Usamos el contenedor de Jenkins (o 'any') para las operaciones por defecto.
    agent any 

    environment {
        // ... (Variables de entorno iguales)
        DOCKER_IMAGE = "tuusuario/implementacionprueba" 
        DOCKER_CRED_ID = 'docker-hub-creds'
        APP_CONTAINER_NAME = 'mi-app-web-contenedor'
    }

    stages {
        // ==========================================================
        // STAGE 1: CI - Construcción del código con Maven
        // Requiere el contenedor Maven para que el comando 'mvn' funcione.
        // ==========================================================
        stage('Maven Build') {
            // *** SOLUCIÓN: Usar un agente Docker con Maven ***
            agent {
                docker {
                    image 'maven:3.9-openjdk-17' // La imagen que contiene el comando 'mvn'
                    args '-v /var/run/docker.sock:/var/run/docker.sock' // Pasar el socket si es necesario
                }
            }
            steps {
                // El comando 'mvn' ahora funcionará dentro de este contenedor Maven
                sh 'mvn clean package -DskipTests' 
            }
        }
        
        // ==========================================================
        // STAGE 2: CI - Pruebas Unitarias
        // ==========================================================
        stage('Test') {
            agent {
                docker {
                    image 'maven:3.9-openjdk-17' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo 'Skipping unit tests for quick demonstration.'
            }
        }
        
        // ==========================================================
        // STAGE 3: CD - Construcción de la Imagen Docker
        // Usamos el agente por defecto (any) que debe tener acceso al docker.sock
        // ==========================================================
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_ID} ."
            }
        }

        // ... (Stages 4 y 5 iguales, ya que 'docker' y 'sh' funcionan en el agente por defecto) ...
        
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