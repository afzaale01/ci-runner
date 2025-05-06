#!/bin/bash
set -euo pipefail

RAW_NAME="${1:?Missing project name input}"

# Trim spaces
RAW_NAME="$(echo "$RAW_NAME" | xargs)"

# Replace anything not a-zA-Z0-9._- with _
SANITIZED_NAME="$(echo "$RAW_NAME" | sed 's/[^a-zA-Z0-9._-]/_/g')"

echo "🔹 Raw Name       : $RAW_NAME"
echo "🔹 Sanitized Name : $SANITIZED_NAME"

# Export as GitHub Actions output
echo "sanitized_name=$SANITIZED_NAME" >> "$GITHUB_OUTPUT"