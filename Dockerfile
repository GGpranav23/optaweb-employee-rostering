# ---------- Build Stage ----------
FROM maven:3.9.6-eclipse-temurin-11 AS builder

WORKDIR /usr/src/optaweb

# Copy Maven wrapper files and project
COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY optaweb-employee-rostering-frontend optaweb-employee-rostering-frontend
COPY optaweb-employee-rostering-backend optaweb-employee-rostering-backend
COPY optaweb-employee-rostering-benchmark optaweb-employee-rostering-benchmark
COPY optaweb-employee-rostering-docs optaweb-employee-rostering-docs
COPY optaweb-employee-rostering-distribution optaweb-employee-rostering-distribution
COPY optaweb-employee-rostering-standalone optaweb-employee-rostering-standalone

# Make Maven wrapper executable and build
RUN chmod +x mvnw && ./mvnw clean install -DskipTests -Dimpsort.skip=true -Dassembly.skipAssembly=true -Dmaven.source.skip=true

# ---------- Runtime Stage ----------
FROM eclipse-temurin:11-jre

RUN mkdir /opt/app
COPY --from=builder /usr/src/optaweb/optaweb-employee-rostering-standalone/target/quarkus-app /opt/app/optaweb-employee-rostering

CMD ["java", "-jar", "/opt/app/optaweb-employee-rostering/quarkus-run.jar"]
EXPOSE 8080
