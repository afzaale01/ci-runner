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

# Load default timeouts from config
DEFAULT_TESTS_TIMEOUT=$(echo "$DEFAULTS" | jq -r '.timeouts.testsInMinutes')
DEFAULT_BUILD_TIMEOUT=$(echo "$DEFAULTS" | jq -r '.timeouts.buildInMinutes')

# Apply overrides if provided via env vars
TIMEOUT_TESTS="${TIMEOUT_TESTS_OVERRIDE:-$DEFAULT_TESTS_TIMEOUT}"
TIMEOUT_BUILD="${TIMEOUT_BUILD_OVERRIDE:-$DEFAULT_BUILD_TIMEOUT}"

# Output to GitHub
echo "timeoutMinutesTests=$TIMEOUT_TESTS" >> "$GITHUB_OUTPUT"
echo "timeoutMinutesBuild=$TIMEOUT_BUILD" >> "$GITHUB_OUTPUT"

# Optional: Print summary
echo "✅ Resolved test timeout: $TIMEOUT_TESTS minutes"
echo "✅ Resolved build timeout: $TIMEOUT_BUILD minutes"