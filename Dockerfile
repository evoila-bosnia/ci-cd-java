# Step 1: Build the application using Maven
FROM maven:3.8.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy the pom.xml files from parent and child modules
COPY pom.xml .

# Download dependencies separately to leverage Docker's build caching
RUN mvn -B dependency:go-offline

# Copy the rest of the source code
COPY src src

# add OTel agent
RUN curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
# Build the application
RUN mvn -B clean package -DskipTests


#
# Package stage
#
# Step 2: Create the final Docker image with the built application
FROM openjdk:17-jdk-slim-buster AS runtime

WORKDIR /app

# Copy the built application (jar file) from the build stage
COPY --from=build /app/target/*.jar app.jar
# Copy the built newrelic agent
COPY --from=build /app/opentelemetry-javaagent.jar opentelemetry-javaagent.jar

# Expose the application's port
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "app.jar"]