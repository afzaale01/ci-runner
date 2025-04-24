#!/bin/bash
set -e

# ───── Arguments ─────
PROJECT="$1"
VERSION="$2"
RELEASE_ID="$3"
REPO="$4"
TOKEN="$5"
PLATFORMS_JSON="$6"

# ───── Parse Platforms ─────
PLATFORMS=$(echo "$PLATFORMS_JSON" | jq -r '.[]')

for PLATFORM in $PLATFORMS; do
  ARTIFACT_PATH="${PROJECT}-${VERSION}-${PLATFORM}"
  ZIP_NAME="${ARTIFACT_PATH}.zip"

  if [ -d "$ARTIFACT_PATH" ]; then
    echo "📦 Zipping: $ARTIFACT_PATH → $ZIP_NAME"
    zip -r "$ZIP_NAME" "$ARTIFACT_PATH"

    echo "📤 Uploading $ZIP_NAME to Release ID: $RELEASE_ID"
    HTTP_CODE=$(curl -s -w "%{http_code}" -o /tmp/upload_response.json -X POST \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/zip" \
      --data-binary @"$ZIP_NAME" \
      "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$ZIP_NAME")

    if [ "$HTTP_CODE" -ne 201 ]; then
      echo "❌ Upload failed for $ZIP_NAME (HTTP $HTTP_CODE)"
      echo "🔍 GitHub API response:"

      jq . /tmp/upload_response.json || cat /tmp/upload_response.json

      # Extract and print validation error(s) if available
      ERRORS=$(jq -r '.errors[]?.message // .errors[]? // empty' /tmp/upload_response.json)
      if [[ -n "$ERRORS" ]]; then
        echo ""
        echo "🚫 Validation Errors:"
        echo "$ERRORS"
      fi

      exit 1
    else
      echo "✅ Uploaded $ZIP_NAME"
    fi
  else
    echo "⚠️ Skipping: $ARTIFACT_PATH not found"
  fi
done
