FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/ci-cd-app-1.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/ci-cd-app-1.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
