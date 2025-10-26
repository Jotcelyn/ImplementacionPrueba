# ==========================================================
# ETAPA 1: BUILDER (Compilar la aplicación con Maven)
# Usamos una imagen de Maven completa para construir el proyecto.
# ==========================================================
FROM maven:3.9-openjdk-17 AS builder

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos del proyecto (pom.xml y código fuente)
# Copiar primero el pom.xml permite a Docker usar el caché 
# si solo cambian las dependencias.
COPY pom.xml .
COPY src ./src

# Construye el proyecto y genera el JAR/WAR ejecutable
# El flag -DskipTests es opcional, pero se recomienda ejecutar pruebas
# en una etapa separada del Jenkinsfile para mejor reporte.
RUN mvn clean package -DskipTests

# ==========================================================
# ETAPA 2: PRODUCTION (Imagen Final de Ejecución)
# Usamos una imagen mínima de JRE (Java Runtime Environment)
# para que el contenedor sea lo más pequeño y seguro posible.
# ==========================================================
# Cambia '17' a la versión de Java que uses
FROM openjdk:17-jre-slim

# Define el puerto que usa tu aplicación (ej. Spring Boot usa 8080 por defecto)
EXPOSE 8080

# Establece el directorio de trabajo
WORKDIR /opt/app

# Copia el archivo JAR/WAR ejecutable desde la etapa 'builder'
# Asume que tu artefacto final se llama 'app.jar' (ajusta si es necesario)
COPY --from=builder /app/target/*.jar app.jar

# Comando para iniciar la aplicación web (CRUCIAL para el requisito 5)
# Esto asegura que la aplicación web funcione inmediatamente al iniciar el contenedor.
CMD ["java", "-jar", "app.jar"]