#!/usr/bin/env sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OFFLINE_REPOSITORY="$PROJECT_DIR/.mvn/offline-repository"

if [ ! -d "$OFFLINE_REPOSITORY" ]; then
    echo "Missing offline Maven repository: $OFFLINE_REPOSITORY" >&2
    echo "Use the complete Escrow offline package; the source-only checkout cannot build offline." >&2
    exit 1
fi

if ! command -v java >/dev/null 2>&1; then
    echo "Java is required (JDK 17)." >&2
    exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
    echo "Maven is required (3.9.x)." >&2
    exit 1
fi

JAVA_MAJOR=$(java -version 2>&1 | sed -n '1s/.*version "\([0-9][0-9]*\).*/\1/p')
if [ "$JAVA_MAJOR" != "17" ]; then
    echo "JDK 17 is required; detected Java ${JAVA_MAJOR:-unknown}." >&2
    exit 1
fi

cd "$PROJECT_DIR"
mvn -o -ntp -Dmaven.repo.local="$OFFLINE_REPOSITORY" clean package

JAR_FILE="$PROJECT_DIR/target/escrow-demo-1.0.0-SNAPSHOT.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "Build completed but the expected JAR was not created: $JAR_FILE" >&2
    exit 1
fi

echo "Created $JAR_FILE"
