#!/bin/bash
set -e

BUILD_TYPE="$1"

DEFAULTS_FILE=".github/config/defaults.json"

if [[ ! -f "$DEFAULTS_FILE" ]]; then
  echo "❌ Defaults file not found at $DEFAULTS_FILE"
  exit 1
fi

DEFAULTS=$(cat "$DEFAULTS_FILE")

# Load default days from config file
DEFAULT_RELEASE_DAYS=$(echo "$DEFAULTS" | jq -r '.retentionDays.release')
DEFAULT_RC_DAYS=$(echo "$DEFAULTS" | jq -r '.retentionDays.release_candidate')
DEFAULT_PREVIEW_DAYS=$(echo "$DEFAULTS" | jq -r '.retentionDays.preview')

# Select the right override env var
if [[ "$BUILD_TYPE" == "release" ]]; then
  RETENTION_DAYS="${RETENTION_DAYS_RELEASE_OVERRIDE:-$DEFAULT_RELEASE_DAYS}"
elif [[ "$BUILD_TYPE" == "release_candidate" ]]; then
  RETENTION_DAYS="${RETENTION_DAYS_RC_OVERRIDE:-$DEFAULT_RC_DAYS}"
else
  RETENTION_DAYS="${RETENTION_DAYS_PREVIEW_OVERRIDE:-$DEFAULT_PREVIEW_DAYS}"
fi

# Output to GitHub
echo "retentionDays=$RETENTION_DAYS" >> "$GITHUB_OUTPUT"
echo "✅ Resolved retention days: $RETENTION_DAYS"