#!/bin/bash
set -e

DEFAULTS_FILE=".github/config/defaults.json"

if [[ ! -f "$DEFAULTS_FILE" ]]; then
  echo "❌ Defaults file not found at $DEFAULTS_FILE"
  exit 1
fi

DEFAULTS=$(cat "$DEFAULTS_FILE")

# Load default timeouts from config
DEFAULT_TESTS_TIMEOUT=$(echo "$DEFAULTS" | jq -r '.timeouts.tests')
DEFAULT_BUILD_TIMEOUT=$(echo "$DEFAULTS" | jq -r '.timeouts.build')

# Apply overrides if provided via env vars
TIMEOUT_TESTS="${TIMEOUT_TESTS_OVERRIDE:-$DEFAULT_TESTS_TIMEOUT}"
TIMEOUT_BUILD="${TIMEOUT_BUILD_OVERRIDE:-$DEFAULT_BUILD_TIMEOUT}"

# Output to GitHub
echo "timeoutMinutesTests=$TIMEOUT_TESTS" >> "$GITHUB_OUTPUT"
echo "timeoutMinutesBuild=$TIMEOUT_BUILD" >> "$GITHUB_OUTPUT"