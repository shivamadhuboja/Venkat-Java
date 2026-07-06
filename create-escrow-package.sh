#!/usr/bin/env sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OFFLINE_REPOSITORY="$PROJECT_DIR/.mvn/offline-repository"
MANIFEST_DIR="$PROJECT_DIR/escrow-manifest"
DIST_DIR="$PROJECT_DIR/dist"
PACKAGE_NAME="escrow-demo-1.0.0-SNAPSHOT-offline.zip"

if [ ! -d "$OFFLINE_REPOSITORY" ]; then
    echo "Missing $OFFLINE_REPOSITORY" >&2
    echo "Populate it with Maven before creating the Escrow package; see README.md." >&2
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "The zip command is required to create the delivery package." >&2
    exit 1
fi

"$PROJECT_DIR/build-offline.sh"

mkdir -p "$MANIFEST_DIR" "$DIST_DIR"

{
    echo "Project: cn.sunline.ltts.busi:escrow-demo:1.0.0-SNAPSHOT"
    echo "Required Java: 17"
    echo "Required Maven: 3.9.x"
    java -version 2>&1 | sed 's/^/Build /'
    mvn -version | sed 's/^/Build /'
} > "$MANIFEST_DIR/VERSIONS.txt"

find "$OFFLINE_REPOSITORY" -type f \( -name '*.jar' -o -name '*.pom' \) \
    | sed "s|$PROJECT_DIR/||" \
    | LC_ALL=C sort > "$MANIFEST_DIR/DEPENDENCIES.txt"

cd "$PROJECT_DIR"
rm -f "$DIST_DIR/$PACKAGE_NAME"
zip -q -r "$DIST_DIR/$PACKAGE_NAME" . \
    -x 'target/*' 'dist/*' 'logs/*' '.git/*' '*.DS_Store'

echo "Created $DIST_DIR/$PACKAGE_NAME"
