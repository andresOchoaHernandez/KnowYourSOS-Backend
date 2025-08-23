# Build the application using Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Declare the build time argument
ARG SERVICE_NAME

# Install netcat, needed by the "wait-for-it" script
# RUN apt-get update && apt-get install -y netcat

# Set working directory
WORKDIR /KnowYourSOS-${SERVICE_NAME}

# Copy pom.xml
COPY pom.xml .

# Download the dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Clean the old build and package the application
RUN mvn clean package -DskipTests

# Copy the script to wait for the service specified as
# an environment variable in the doker-compose file.
# The wildcard is used to prevent an error while building
# the image of the configuration server. It doesn't need it. 
COPY  waitForService.sh* .

# Render the file executable only if it's not the configuration server 
RUN if [ ${SERVICE_NAME} != "ConfigurationServer" ]; then \
      chmod +x waitForService.sh; \
    fi

# Run the application
CMD [ "sh", "-c", "if [ \"${SERVICE_TO_WAIT_FOR}\" != \"None\" ]; then ./waitForService.sh ${SERVICE_TO_WAIT_FOR}; fi && mvn spring-boot:run" ]
