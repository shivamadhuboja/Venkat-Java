# Escrow Demo Offline JAR Build Guide

## 1. Purpose

Escrow Demo is a minimal APS source-code escrow project containing one `flowtran`
transaction (`es0001`). The delivery package is intended for verification on a clean
Linux machine without access to the Sunline Maven repository or Maven Central.

The supplied offline Maven repository contains all dependencies and plugins needed to
build the project JAR. The expected result is:

```text
[INFO] BUILD SUCCESS
Created .../target/escrow-demo-1.0.0-SNAPSHOT.jar
```

This is a build-only POC. It does not start an application and does not require a
database, message queue, application server, or other middleware.

## 2. Required Software

The verification machine must be a 64-bit Linux system with the following software:

| Software | Required version | Purpose |
| --- | --- | --- |
| JDK | 17 | Java compiler and runtime |
| Apache Maven | 3.9.x | Offline project build |
| `unzip` | Any current version | Extract the delivery ZIP |
| POSIX shell | `sh`, `bash`, or compatible | Run the build script |

Git, Docker, network access, and access to a private Maven repository are not required.

## 3. Install the Required Software

### 3.1 Ubuntu or Debian

Install JDK 17 and the archive tools:

```bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk unzip curl tar
```

Install Maven 3.9.9:

```bash
curl -fLO https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9/bin/mvn /usr/local/bin/mvn
```

### 3.2 RHEL, Rocky Linux, AlmaLinux, or Fedora

```bash
sudo dnf install -y java-17-openjdk-devel unzip curl tar gzip
curl -fLO https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9/bin/mvn /usr/local/bin/mvn
```

### 3.3 Linux Machine Without Internet Access

The project build itself is fully offline. If the new machine is air-gapped, transfer
and install these prerequisites before transferring the Escrow package:

- a JDK 17 distribution for the target Linux CPU architecture;
- the Apache Maven 3.9.x binary archive;
- an `unzip` package if the operating system does not already provide it.

No Maven artifacts need to be downloaded separately.

## 4. Verify the Installed Tools

Run:

```bash
java -version
javac -version
mvn -version
unzip -v
```

Both `java` and `javac` must report version 17. Maven must report version 3.9.x and
must show that it is running with Java 17.

## 5. Delivery Package Structure

After extracting `escrow-demo-1.0.0-SNAPSHOT-offline.zip`, the important files are:

```text
.
|-- .mvn/
|   `-- offline-repository/       Maven dependencies and build plugins
|-- escrow-manifest/
|   |-- DEPENDENCIES.txt          Delivered JAR and POM inventory
|   `-- VERSIONS.txt              Project and build-environment versions
|-- src/
|   `-- main/
|       |-- java/
|       |   `-- cn/sunline/ltts/busi/escrowdemo/trans/es0001.java
|       `-- resources/
|           |-- datatype/EscrowType.u_schema.xml
|           |-- dict/EscrowDict.d_schema.xml
|           `-- trans/es0001.flowtrans.xml
|-- build-offline.sh              Third-party offline JAR build command
|-- create-escrow-package.sh      Internal packaging utility; not used for verification
|-- pom.xml                       Maven project definition
`-- README.md                     This guide
```

Do not delete or rename `.mvn/offline-repository`. Hidden directories must be retained
when the extracted project is copied to another location.

## 6. Third-Party Build Procedure

### Step 1: Extract the delivery package

```bash
mkdir escrow-verification
cd escrow-verification
unzip /path/to/escrow-demo-1.0.0-SNAPSHOT-offline.zip
```

The ZIP extracts the project files directly into the current directory.

### Step 2: Enable the build script

ZIP extraction normally preserves the executable permission. If necessary, run:

```bash
chmod +x build-offline.sh
```

### Step 3: Build the JAR

```bash
./build-offline.sh
```

The script runs:

```bash
mvn -o -ntp -Dmaven.repo.local=.mvn/offline-repository clean package
```

The `-o` option forces Maven offline mode. The build will fail rather than contact a
remote repository if an artifact is absent from the delivered repository.

### Step 4: Confirm the result

The build log must show that APS validates the following three project model files:

- `EscrowType.u_schema.xml`;
- `EscrowDict.d_schema.xml`;
- `es0001.flowtrans.xml`.

The log must also show five Java source files compiled and finish with:

```text
[INFO] BUILD SUCCESS
Created .../target/escrow-demo-1.0.0-SNAPSHOT.jar
```

Confirm that the JAR exists:

```bash
ls -lh target/escrow-demo-1.0.0-SNAPSHOT.jar
```

Optionally inspect its contents:

```bash
jar tf target/escrow-demo-1.0.0-SNAPSHOT.jar
```

The JAR contains compiled transaction classes, APS-generated classes, model resources,
and `META-INF/MANIFEST.MF`.

## 7. Generated Build Output

The build creates:

```text
target/
|-- classes/                              Compiled classes and resources
|-- gen/                                  APS-generated Java sources
`-- escrow-demo-1.0.0-SNAPSHOT.jar        Final JAR artifact
```

The output is recreated from scratch each time because the script runs `clean package`.

## 8. Transaction Overview

The single `es0001` transaction simulates registering a software artifact with an
escrow service.

Inputs:

- escrow ID;
- depositor;
- artifact name;
- artifact version.

Outputs:

- receipt number;
- `ACCEPTED` status;
- acceptance timestamp;
- result message.

During the build, `aps-maven-plugin` validates the APS models and generates the
`Es0001` input/output interface, REST controller, data type, and dictionary classes.

## 9. Troubleshooting

### `Missing offline Maven repository`

The complete delivery ZIP was not extracted, or the hidden `.mvn` directory was lost
during transfer. A source-only Git checkout cannot perform the offline build.

### `JDK 17 is required`

Set `JAVA_HOME` to JDK 17, place `$JAVA_HOME/bin` at the front of `PATH`, and verify the
result with `java -version` and `javac -version`.

### `Maven is required (3.9.x)`

Install Apache Maven 3.9.x and ensure `mvn` is available on `PATH`.

### `Permission denied: ./build-offline.sh`

Run:

```bash
chmod +x build-offline.sh
```

### Maven reports an artifact is unavailable in offline mode

The offline repository is incomplete. Re-extract the original Escrow ZIP. Do not
remove the `-o` option or configure another Maven repository.

### Expected JAR was not created

Review the Maven errors earlier in the log. A successful build must create exactly:

```text
target/escrow-demo-1.0.0-SNAPSHOT.jar
```

## 10. Scope and Limitations

Successful packaging proves that the delivered source code, APS models, build plugins,
and dependencies are sufficient to produce the JAR. Application startup, integration
testing, external services, deployment, and JAR reproducibility comparison are outside
the scope of this POC.
