FROM openjdk:8-jre-slim

WORKDIR /app

COPY pom.xml  .

COPY src ./app

RUN mvn clean install

EXPOSE 8080

CMD ["java", "-jar", "build/libs/your-app-name.jar"]
