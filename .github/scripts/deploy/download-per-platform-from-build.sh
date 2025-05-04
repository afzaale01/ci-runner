#!/bin/bash
set -euo pipefail

DEST_DIR="${1:?Missing artifact destination directory}"
PROJECT_NAME="${2:?Missing project name}"
VERSION="${3:?Missing version}"
TARGET_PLATFORMS_JSON="${4:?Missing target platforms JSON}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Starting Build Artifact Download"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Project Name              : ${PROJECT_NAME}"
echo "🔹 Version                  : ${VERSION}"
echo "🔹 Destination Directory    : ${DEST_DIR}"
echo "🔹 Target Platforms (JSON)  : ${TARGET_PLATFORMS_JSON}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEST_DIR}"

# ────────────────────────────
# Download Per Platform
# ────────────────────────────
for platform in $(echo "${TARGET_PLATFORMS_JSON}" | jq -r '.[]'); do
  ARTIFACT_NAME="${PROJECT_NAME}-${VERSION}-${platform}"
  PLATFORM_DIR="${DEST_DIR}/${platform}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⬇️  Downloading Artifact"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔸 Platform        : ${platform}"
  echo "🔸 Artifact Name   : ${ARTIFACT_NAME}"
  echo "🔸 Target Folder   : ${PLATFORM_DIR}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  mkdir -p "${PLATFORM_DIR}"

  if gh run download --name "${ARTIFACT_NAME}" --dir "${PLATFORM_DIR}"; then
    echo "✅ Successfully downloaded: ${ARTIFACT_NAME}"
  else
    echo "⚠️ Warning: Artifact ${ARTIFACT_NAME} not found or failed to download."
  fi
done

echo ""
echo "✅ All required platform artifacts downloaded into: ${DEST_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"