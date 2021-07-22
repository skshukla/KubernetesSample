FROM openjdk:11.0.11-jre-slim-buster
ADD ServiceB*.jar app.jar
RUN sh -c 'touch /app.jar'
EXPOSE 8080 7000
ENTRYPOINT ["java","-jar","/app.jar"]