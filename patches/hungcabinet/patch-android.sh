#!/usr/bin/env bash
set -euo pipefail

echo "== Android Kotlin DSL patch =="

APP_ID="${APP_ID:-com.example.myfork}"
APP_NAME="${APP_NAME:-My App}"

ANDROID_DIR="clients/android"
APP_DIR="$ANDROID_DIR/app"

echo "APP_ID=$APP_ID"
echo "APP_NAME=$APP_NAME"

# =========================
# 1. applicationId (KTS)
# =========================

BUILD_KTS="$APP_DIR/build.gradle.kts"

if [ -f "$BUILD_KTS" ]; then
  echo "Patching build.gradle.kts applicationId"

  sed -i -E \
    "s/applicationId[[:space:]]*=[[:space:]]*\"[^\"]+\"/applicationId = \"$APP_ID\"/g" \
    "$BUILD_KTS"
fi

# =========================
# 2. app_name
# =========================

echo "Patching app_name in all locales"

find "$APP_DIR/src" \
  -type f \
  -path "*/res/values*/strings.xml" \
  | while read -r file; do

    if grep -q 'name="app_name"' "$file"; then
      echo "  -> $file"

      sed -i -E \
        "s|<string name=\"app_name\">.*</string>|<string name=\"app_name\">$APP_NAME</string>|g" \
        "$file"
    fi

done

echo "== Done =="