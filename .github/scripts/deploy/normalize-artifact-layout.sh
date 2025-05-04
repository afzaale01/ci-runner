#!/bin/bash
set -euo pipefail

DEPLOY_DIR="${1:?Missing deployment directory}"
PROJECT_DIR="${2:?Missing project directory}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️ Starting Artifact Layout Normalization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Source Directory: ${DEPLOY_DIR}"
echo "🔹 Project Directory: ${PROJECT_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEPLOY_DIR}/${PROJECT_DIR}"

for platform_dir in "${DEPLOY_DIR}"/*/; do
  [[ -d "$platform_dir" ]] || continue
  platform_name="$(basename "$platform_dir")"
  target_dir="${DEPLOY_DIR}/${PROJECT_DIR}/${platform_name}"

  echo "➡️ Moving platform '${platform_name}' into '${target_dir}'"

  mv "$platform_dir" "$target_dir"
done

echo "✅ Artifact layout normalized into: ${DEPLOY_DIR}/${PROJECT_DIR}"