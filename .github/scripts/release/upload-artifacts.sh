#!/bin/bash
set -e

FILE="$1"
RELEASE_ID="$2"
NAME=$(basename "$FILE")

echo "📦 Uploading: $FILE as $NAME"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

curl -s -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @"$FILE" \
  "https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/$RELEASE_ID/assets?name=$NAME"
