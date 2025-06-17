FROM openjdk:17-jdk-slim

COPY /build/libs/ProyectoKubernetes-0.0.1-SNAPSHOT.jar ./app.jar

CMD ["java","-jar","./app.jar"]