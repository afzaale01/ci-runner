#!/bin/bash
set -e

DEFAULTS_FILE=".github/config/defaults.json"

if [[ ! -f "$DEFAULTS_FILE" ]]; then
  echo "❌ Defaults file not found at $DEFAULTS_FILE"
  exit 1
fi

DEFAULTS=$(cat "$DEFAULTS_FILE")

# Load defaults from config file
DEFAULT_UNITY_VERSION=$(echo "$DEFAULTS" | jq -r '.unity.version')
DEFAULT_USE_GIT_LFS=$(echo "$DEFAULTS" | jq -r '.unity.useGitLfs')
DEFAULT_EDIT_MODE_PATH=$(echo "$DEFAULTS" | jq -r '.unity.editModePath')
DEFAULT_PLAY_MODE_PATH=$(echo "$DEFAULTS" | jq -r '.unity.playModePath')
DEFAULT_QUIET_MODE=$(echo "$DEFAULTS" | jq -r '.unity.quietMode')

# Apply fallback: prefer environment-provided overrides if present
UNITY_VERSION="${UNITY_VERSION_OVERRIDE:-$DEFAULT_UNITY_VERSION}"
USE_GIT_LFS="${USE_GIT_LFS_OVERRIDE:-$DEFAULT_USE_GIT_LFS}"
EDIT_MODE_PATH="${EDIT_MODE_PATH_OVERRIDE:-$DEFAULT_EDIT_MODE_PATH}"
PLAY_MODE_PATH="${PLAY_MODE_PATH_OVERRIDE:-$DEFAULT_PLAY_MODE_PATH}"
QUIET_MODE="${QUIET_MODE_OVERRIDE:-$DEFAULT_QUIET_MODE}"

# Output to GitHub
echo "unityVersion=$UNITY_VERSION" >> "$GITHUB_OUTPUT"
echo "useGitLfs=$USE_GIT_LFS" >> "$GITHUB_OUTPUT"
echo "editModePath=$EDIT_MODE_PATH" >> "$GITHUB_OUTPUT"
echo "playModePath=$PLAY_MODE_PATH" >> "$GITHUB_OUTPUT"
echo "quietMode=$QUIET_MODE" >> "$GITHUB_OUTPUT"

# Print summary
echo "## 📋 Test Data Summary" >> "$GITHUB_STEP_SUMMARY"
echo "| Key             | Value |" >> "$GITHUB_STEP_SUMMARY"
echo "|-----------------|-------|" >> "$GITHUB_STEP_SUMMARY"
echo "| Unity Version   | $UNITY_VERSION |" >> "$GITHUB_STEP_SUMMARY"
echo "| Use Git LFS     | $USE_GIT_LFS |" >> "$GITHUB_STEP_SUMMARY"
echo "| EditMode Path   | $EDIT_MODE_PATH |" >> "$GITHUB_STEP_SUMMARY"
echo "| PlayMode Path   | $PLAY_MODE_PATH |" >> "$GITHUB_STEP_SUMMARY"
echo "| Quiet Mode      | $QUIET_MODE |" >> "$GITHUB_STEP_SUMMARY"