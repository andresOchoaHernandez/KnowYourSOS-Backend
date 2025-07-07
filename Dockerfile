# Step 1: Build the application using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder

ARG SERVICE_NAME

# Install netcat, needed by the "wait-for-it" script
RUN apt-get update && apt-get install -y netcat

# Set working directory
WORKDIR /KnowYourSOS-${SERVICE_NAME}

# Copy pom.xml
COPY pom.xml .

# Download the dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Clean the old build and package the application
RUN mvn clean package

# Run the application
ENTRYPOINT [ "mvn","spring-boot:run" ]