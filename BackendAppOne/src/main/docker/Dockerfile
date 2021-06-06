FROM openjdk:8u222-jre-slim-buster
ADD BackendAppOne*.jar app.jar
ENV env_val kubernetes
RUN sh -c 'touch /app.jar'
EXPOSE 8080
ENTRYPOINT ["java","-jar","-Dspring.profiles.active=${env_val}","/app.jar"]