#!/bin/bash
set -e
VERSION="$1"
API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/$VERSION"

RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" "$API_URL")

if [ "$RESPONSE" -eq 200 ]; then
  echo "exists=true"
  echo "release_id=$(jq -r '.id' response.json)"
else
  echo "exists=false"
fi
