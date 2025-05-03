#!/bin/bash
set -euo pipefail

DEPLOY_DIR="${1:?Missing deployment directory}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️ Starting Artifact Layout Normalization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 Source Directory: ${DEPLOY_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for platform_dir in "${DEPLOY_DIR}"/*/; do
  [[ -d "$platform_dir" ]] || continue
  platform_name="$(basename "$platform_dir")"
  target_dir="${DEPLOY_DIR}-${platform_name}"

  echo "➡️ Moving platform '${platform_name}' to '${target_dir}'"

  mkdir -p "$target_dir"
  mv "${platform_dir}"* "$target_dir"
  rmdir "$platform_dir" || true
done

echo "✅ Artifact layout normalized."