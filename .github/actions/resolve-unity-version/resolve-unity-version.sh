#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────
# Load defaults.json (override or bundled)
# ─────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────
# Validate Unity version format with regex
# ─────────────────────────────────────────────────────────────
if [[ ! "$UNITY_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(f[0-9]+|p[0-9]+|b[0-9]+|a[0-9]+)?$ ]]; then
  echo "❌ Invalid Unity version format: $UNITY_VERSION"
  echo "Expected formats: e.g., 5.6.7f1, 2019.4.39f1, 6000.1.1f1, 6000.2.0a10, 6000.1.0b8"
  exit 1
fi

# ─────────────────────────────────────────────────────────────
# Output resolved version to GitHub
# ─────────────────────────────────────────────────────────────
echo "unityVersion=$UNITY_VERSION" >> "$GITHUB_OUTPUT"

# Optional: Print summary
echo "✅ Resolved unity version: $UNITY_VERSION"
