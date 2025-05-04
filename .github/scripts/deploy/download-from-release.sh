#!/bin/bash
set -euo pipefail

# ────────────────────────────
# Inputs
# ────────────────────────────
PROJECT_NAME="${1:?Missing project name}"
VERSION="${2:?Missing version}"
GITHUB_REPOSITORY="${3:?Missing repository}"
GITHUB_TOKEN="${4:?Missing GitHub token}"
HAS_COMBINED_ARTIFACTS="${5:?Missing hasCombinedArtifacts flag (true/false)}"
REQUIRED_PLATFORMS_JSON="${6:?Missing required platforms JSON}"

PROJECT_NAME="$(echo "$PROJECT_NAME" | xargs)"
VERSION="$(echo "$VERSION" | xargs)"
GITHUB_REPOSITORY="$(echo "$GITHUB_REPOSITORY" | xargs)"
GITHUB_TOKEN="$(echo "$GITHUB_TOKEN" | xargs)"
HAS_COMBINED_ARTIFACTS="$(echo "$HAS_COMBINED_ARTIFACTS" | xargs)"

DEST_DIR="deployment-artifacts/${PROJECT_NAME}-${VERSION}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Starting Release Asset Download"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Project                   : ${PROJECT_NAME}"
echo "🔹 Version                   : ${VERSION}"
echo "🔹 Repository                : ${GITHUB_REPOSITORY}"
echo "🔹 Has Combined              : ${HAS_COMBINED_ARTIFACTS}"
echo "🔹 Target Download Directory : ${DEST_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEST_DIR}"

# ────────────────────────────
# Fetch Release Metadata
# ────────────────────────────
ASSETS_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${VERSION}"
echo "📡 Fetching release assets from: ${ASSETS_URL}"

RELEASE_DATA=$(curl -sSL -H "Authorization: token ${GITHUB_TOKEN}" "${ASSETS_URL}")

# ────────────────────────────
# Extract URLs
# ────────────────────────────
echo "🔍 Extracting asset download URLs..."
ASSETS=$(echo "${RELEASE_DATA}" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"')

if [[ -z "${ASSETS}" ]]; then
  echo "❌ No assets found for tag ${VERSION}"
  exit 1
fi

# ────────────────────────────
# Download & Extract
# ────────────────────────────
found_combined_artifact=false

if [[ "${HAS_COMBINED_ARTIFACTS}" == "true" ]]; then
  echo "🛠️ Only downloading combined artifact..."

  while read -r NAME URL; do
    if [[ "${NAME}" == *-all-platforms.zip ]]; then
      echo "⬇️ Downloading combined artifact: ${NAME}"
      curl -sSL -H "Authorization: token ${GITHUB_TOKEN}" "${URL}" -o "${DEST_DIR}/${NAME}"
      echo "📂 Extracting ${NAME} into ${DEST_DIR}"
      unzip -q "${DEST_DIR}/${NAME}" -d "${DEST_DIR}"
      rm "${DEST_DIR}/${NAME}"
      found_combined_artifact=true
      break
    fi
  done <<< "${ASSETS}"

  if [[ "${found_combined_artifact}" == "false" ]]; then
    echo "❌ Expected combined artifact (-all-platforms.zip) but none was found!"
    exit 1
  fi

else
  echo "📦 Downloading and extracting per-platform artifacts..."

  # Convert REQUIRED_PLATFORMS_JSON into a bash array
  REQUIRED_PLATFORMS=($(echo "${REQUIRED_PLATFORMS_JSON}" | jq -r '.[]'))

  for PLATFORM in "${REQUIRED_PLATFORMS[@]}"; do
    ARTIFACT_NAME="${PROJECT_NAME}-${VERSION}-${PLATFORM}.zip"
    ARTIFACT_URL=$(echo "${ASSETS}" | awk -v name="${ARTIFACT_NAME}" '$1 == name {print $2}')

    if [[ -z "${ARTIFACT_URL}" ]]; then
      echo "⚠️ Warning: Artifact ${ARTIFACT_NAME} not found in release assets."
      continue
    fi

    echo "⬇️ Downloading: ${ARTIFACT_NAME}"
    curl -sSL -H "Authorization: token ${GITHUB_TOKEN}" "${ARTIFACT_URL}" -o "${DEST_DIR}/${ARTIFACT_NAME}"

    echo "📂 Extracting ${ARTIFACT_NAME} to ${DEST_DIR}/${PROJECT_NAME}-${VERSION}-${PLATFORM}"
    mkdir -p "${DEST_DIR}/${PROJECT_NAME}-${VERSION}-${PLATFORM}"
    unzip -q "${DEST_DIR}/${ARTIFACT_NAME}" -d "${DEST_DIR}/${PROJECT_NAME}-${VERSION}-${PLATFORM}"
    rm "${DEST_DIR}/${ARTIFACT_NAME}"
  done
fi

echo "✅ Finished downloading release assets to: ${DEST_DIR}"
