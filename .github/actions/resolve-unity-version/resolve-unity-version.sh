#!/bin/bash
set -e

# Pick override or bundled defaults.json
DEFAULTS_FILE="${DEFAULTS_FILE_OVERRIDE:-$GITHUB_ACTION_PATH/defaults.json}"

if [[ ! -f "$DEFAULTS_FILE" ]]; then
  echo "❌ Defaults file not found at $DEFAULTS_FILE. Falling back to action-specific defaults."
  DEFAULTS_FILE="$GITHUB_ACTION_PATH/defaults.json"
  if [[ ! -f "$DEFAULTS_FILE" ]]; then
    echo "❌ Defaults file not found in the action folder. Exiting."
    exit 1
  fi
fi

DEFAULTS=$(cat "$DEFAULTS_FILE")

# Load default unity version from config
DEFAULT_UNITY_VERSION=$(echo "$DEFAULTS" | jq -r '.unity.version')

# Apply overrides if provided via env vars
UNITY_VERSION="${UNITY_VERSION_OVERRIDE:-$DEFAULT_UNITY_VERSION}"

# Output to GitHub
echo "unityVersion=$UNITY_VERSION" >> "$GITHUB_OUTPUT"

# Optional: Print summary
echo "✅ Resolved unity version: $UNITY_VERSION"