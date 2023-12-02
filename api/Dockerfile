FROM amazoncorretto:21
WORKDIR /app
COPY target/words.jar .
COPY target/dependency/ ./dependency/
EXPOSE 8080
CMD ["java", "-jar", "/app/words.jar"]
