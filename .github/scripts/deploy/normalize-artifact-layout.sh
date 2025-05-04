#!/bin/bash
set -euo pipefail

DEPLOY_DIR="${1:?Missing deployment directory}"
PROJECT_DIR="${2:?Missing project directory}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️ Starting Artifact Folder Renaming"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Deploy Directory: ${DEPLOY_DIR}"
echo "🔹 Project Directory: ${PROJECT_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for platform_dir in "${DEPLOY_DIR}"/*/; do
  [[ -d "$platform_dir" ]] || continue
  platform_name="$(basename "$platform_dir")"
  new_dir="${DEPLOY_DIR}/${PROJECT_DIR}-${platform_name}"

  echo "➡️ Renaming '${platform_dir}' → '${new_dir}'"
  mv "$platform_dir" "$new_dir"
done

echo "✅ Artifact folders renamed."