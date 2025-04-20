#!/bin/bash
set -e

# ───── Arguments ─────
FILE="$1"
RELEASE_ID="$2"
REPO="$3"
TOKEN="$4"

NAME=$(basename "$FILE")

echo "📦 Uploading: $FILE as $NAME → Release ID: $RELEASE_ID"

# ───── Safety Check ─────
if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

# ───── Upload ─────
RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/upload_response.json -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @"$FILE" \
  "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$NAME")

if [ "$RESPONSE" -ne 201 ]; then
  echo "❌ Upload failed! HTTP $RESPONSE"
  cat /tmp/upload_response.json
  exit 1
else
  echo "✅ Successfully uploaded $NAME"
fi
