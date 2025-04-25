#!/bin/bash
set -euo pipefail

# ────────────────────────────
# Inputs
# ────────────────────────────
PROJECT_NAME="${1:?Missing project name}"
VERSION="${2:?Missing version}"
HAS_COMBINED_ARTIFACTS="${3:?Missing hasCombinedArtifacts flag (true/false)}"
DEST_DIR="${4:-deployment-artifacts/${PROJECT_NAME}-${VERSION}}"

mkdir -p "$DEST_DIR"

echo "🧹 Preparing to download build artifacts..."
echo "🎯 Project      : $PROJECT_NAME"
echo "🎯 Version      : $VERSION"
echo "🎯 Combined     : $HAS_COMBINED_ARTIFACTS"
echo "🎯 Target Folder: $DEST_DIR"
echo ""

# ────────────────────────────
# Combined Artifact Download
# ────────────────────────────
if [[ "$HAS_COMBINED_ARTIFACTS" == "true" ]]; then
  echo "📦 Downloading combined artifact..."
  ARTIFACT_NAME="${PROJECT_NAME}-${VERSION}"

  gh run download --name "$ARTIFACT_NAME" --dir "$DEST_DIR"

  # Unzip if it's an archive (optional safety check)
  if ls "$DEST_DIR"/*.zip &>/dev/null; then
    echo "📂 Extracting combined zip..."
    unzip -q "$DEST_DIR"/*.zip -d "$DEST_DIR"
    rm "$DEST_DIR"/*.zip
  fi

# ────────────────────────────
# Per-Platform Artifacts Download
# ────────────────────────────
else
  echo "📦 Downloading all per-platform artifacts..."
  
  gh run download --dir "$DEST_DIR"

  # (Optional) Unzip all artifacts individually
  if ls "$DEST_DIR"/*.zip &>/dev/null; then
    echo "📂 Extracting all platform zips..."
    for zipfile in "$DEST_DIR"/*.zip; do
      platform_dir="${zipfile%.zip}"
      mkdir -p "$platform_dir"
      unzip -q "$zipfile" -d "$platform_dir"
      rm "$zipfile"
    done
  fi
fi

echo ""
echo "✅ Artifact download and extraction complete."