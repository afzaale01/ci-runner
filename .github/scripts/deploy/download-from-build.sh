#!/bin/bash
set -euo pipefail

# ────────────────────────────
# Inputs
# ────────────────────────────
PROJECT_NAME="${1:?Missing project name}"
VERSION="${2:?Missing version}"
HAS_COMBINED_ARTIFACTS="${3:?Missing hasCombinedArtifacts flag (true/false)}"

PROJECT_NAME="$(echo "$PROJECT_NAME" | xargs)"
VERSION="$(echo "$VERSION" | xargs)"
HAS_COMBINED_ARTIFACTS="$(echo "$HAS_COMBINED_ARTIFACTS" | xargs)"

DEST_DIR="${4:-deployment-artifacts}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Starting Build Artifact Download"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Project                   : ${PROJECT_NAME}"
echo "🔹 Version                   : ${VERSION}"
echo "🔹 Has Combined Artifacts    : ${HAS_COMBINED_ARTIFACTS}"
echo "🔹 Target Download Directory : ${DEST_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEST_DIR}"

# ────────────────────────────
# Download & Extract
# ────────────────────────────
if [[ "${HAS_COMBINED_ARTIFACTS}" == "true" ]]; then
  echo "🛠️ Only downloading combined artifact..."

  ARTIFACT_NAME="${PROJECT_NAME}-${VERSION}"

  echo "⬇️ Downloading artifact: ${ARTIFACT_NAME}"
  gh run download --name "${ARTIFACT_NAME}" --dir "${DEST_DIR}"

  # If a zip exists, extract and clean up
  if ls "${DEST_DIR}"/*.zip &>/dev/null; then
    echo "📂 Extracting combined artifact..."
    unzip -q "${DEST_DIR}"/*.zip -d "${DEST_DIR}"
    rm "${DEST_DIR}"/*.zip
  fi

else
  echo "📦 Downloading per-platform artifacts..."

  gh run download --dir "${DEST_DIR}"

  # Extract each platform artifact into its own folder
  if ls "${DEST_DIR}"/*.zip &>/dev/null; then
    echo "📂 Extracting platform-specific artifacts..."

    for zipfile in "${DEST_DIR}"/*.zip; do
      base_name="$(basename "${zipfile}" .zip)"  # Remove .zip
      platform_dir="${DEST_DIR}-${base_name##*-}"  # Use suffix after last hyphen
      echo "📂 Extracting ${zipfile} to ${platform_dir}"
      mkdir -p "${platform_dir}"
      unzip -q "${zipfile}" -d "${platform_dir}"
      rm "${zipfile}"
    done
  fi
fi

echo "✅ Finished downloading and extracting build artifacts to: ${DEST_DIR}"