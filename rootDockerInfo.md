Important

# 🐳 Dockerfile Overview

This Dockerfile (located in the project root) defines a **multi-stage Docker build** for a **Quarkus Java application** that uses **Maven** to build and **OpenJDK** to run.

---

## 🏗️ Stage 1: Builder

```dockerfile
FROM adoptopenjdk/maven-openjdk11:latest as builder
```

**Explanation:**
- The base image includes both **Maven** and **OpenJDK 11**.
- The tag `latest` means it pulls the newest version available from the AdoptOpenJDK registry.

---

```dockerfile
WORKDIR /usr/src/optaweb
```

**Explanation:**
- Sets the **working directory** inside the container.
- All subsequent commands (`COPY`, `RUN`, etc.) execute relative to this path.
- If `/usr/src/optaweb` doesn’t exist, it will be created automatically.

---

```dockerfile
COPY . .
```

**Explanation:**
- Copies the **entire project source code** from your host machine into the container’s working directory (`/usr/src/optaweb`).
- `.` (first) → current directory on host  
- `.` (second) → working directory inside the container  

After this step, the container contains:
- `pom.xml`
- `src/`
- other project files

---

```dockerfile
RUN mvn clean install -DskipTests
```

**Explanation:**
- Executes Maven commands to:
  - Clean old build artifacts.
  - Compile and package the Quarkus application.
  - Skip tests (`-DskipTests`) to make the build faster inside Docker.

After this step, the final runnable package (a JAR or Quarkus build folder) will be located in:

```
/usr/src/optaweb/optaweb-employee-rostering-standalone/target/
```

---

## 🚀 Stage 2: Runtime

```dockerfile
FROM adoptopenjdk/openjdk11:ubi-minimal
```

**Explanation:**
- This is the **runtime stage** — a smaller, cleaner image.
- Uses `adoptopenjdk/openjdk11:ubi-minimal`, which includes:
  - Only the **JRE (Java Runtime Environment)** — no Maven, no compiler.
  - UBI = “Universal Base Image”, Red Hat’s minimal Linux base (secure and lightweight).

This makes the final image **smaller**, **safer**, and **more efficient**.

---

```dockerfile
RUN mkdir /opt/app
```

**Explanation:**
- Creates a directory `/opt/app` inside the container to store the final application files.

---

```dockerfile
COPY --from=builder /usr/src/optaweb/optaweb-employee-rostering-standalone/target/quarkus-app /opt/app/optaweb-employee-rostering
```

**Explanation:**
- This is the key multi-stage step:
  - `--from=builder` copies files from the **builder stage**.
  - Copies the compiled Quarkus app folder (`quarkus-app`) into `/opt/app/optaweb-employee-rostering` in the runtime image.
- After this, the runtime image contains everything needed to **run** the app — and nothing unnecessary.

---

```dockerfile
CMD ["java", "-jar", "/opt/app/optaweb-employee-rostering/quarkus-run.jar"]
```

**Explanation:**
- Defines the default command Docker runs when the container starts.
- Executes:

```bash
java -jar /opt/app/optaweb-employee-rostering/quarkus-run.jar
```

This launches the Quarkus application.

---

```dockerfile
EXPOSE 8080
```

**Explanation:**
- Informs Docker that the container listens on **port 8080**.
- This doesn’t actually publish the port — it’s just metadata.
- You map ports manually when running the container (e.g. `-p 8080:8080`).

---

## ⚙️ Running the Container

### 🧱 Build the Image

```bash
docker build -t optaweb/employee-rostering --ulimit nofile=98304:98304 .
```

**Explanation:**
- `-t optaweb/employee-rostering` → tags the image with a name.  
- `--ulimit nofile=98304:98304` → increases file descriptor limit (useful for large Java apps).  
- `.` → sets the current directory as the build context.

---

### 🏃 Run (Default: In-memory H2 Database)

```bash
docker run -p 8080:8080 --rm -it optaweb/employee-rostering
```

**Explanation:**
- Maps container port 8080 → host port 8080.
- `--rm` → removes the container automatically after it stops.
- `-it` → runs the container in interactive mode.

---

### 🏭 Run (Production: PostgreSQL Database)

```bash
docker run -p 8080:8080 --rm -it -e QUARKUS_PROFILE=production optaweb/employee-rostering
```

**Explanation:**
- Adds an environment variable `QUARKUS_PROFILE=production`.
- Quarkus automatically loads the **production profile**, connecting to a PostgreSQL database instead of H2.

---


