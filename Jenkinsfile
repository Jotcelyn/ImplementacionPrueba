pipeline {
    agent any
    stages {
        // 1. Integración Continua (CI)
        stage('Build') {
            steps { /* Compilación y/o instalación de dependencias */ }
        }
        stage('Test') {
            steps { /* Ejecución de pruebas unitarias */ }
        }
        
        // 2. Entrega Continua (CD)
        stage('Build Docker Image') {
            steps {
                // Comando: docker build -t tuusuario/mi-app:latest .
            }
        }
        stage('Push to Docker Hub') {
            steps {
                // Comando: docker push tuusuario/mi-app:latest
            }
        }
        stage('Deploy') {
            steps {
                // Comando: docker run ... tuusuario/mi-app:latest
                // ¡Esto garantiza que la app funcione al iniciar el contenedor!
            }
        }
        // ... dentro del 'pipeline' y 'stages'
stage('Build & Push Docker Image') {
    steps {
        // 1. Construir la imagen con el Dockerfile que acabas de crear
        // Usa el BUILD_ID o BUILD_NUMBER de Jenkins como etiqueta de versión
        sh "docker build -t mi-app-web:${env.BUILD_ID} ."

        // 2. Etiquetar para Docker Hub (asume que ya tienes credenciales configuradas en Jenkins)
        sh "docker tag mi-app-web:${env.BUILD_ID} tuusuario/mi-app-web:${env.BUILD_ID}"
        
        // 3. Subir a Docker Hub (Cumple el requisito de compartir el enlace del contenedor)
        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
            sh "docker push tuusuario/mi-app-web:${env.BUILD_ID}"
        }
    }
}

stage('Deploy Application') {
    agent {
        // Usa un agente o SSH para ejecutar comandos en el servidor de destino
        label 'remote-server' 
    }
    steps {
        sh "docker stop mi-app-contenedor || true" // Detiene el contenedor anterior
        sh "docker rm mi-app-contenedor || true"   // Elimina el contenedor anterior
        
        // Ejecuta la nueva versión.
        // Esto cumple el requisito: La aplicación web debe funcionar al iniciar el contenedor Docker.
        sh "docker run -d --name mi-app-contenedor -p 8080:8080 tuusuario/mi-app-web:${env.BUILD_ID}"
    }
}