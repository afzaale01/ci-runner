#!/bin/bash
MESSAGE="$1"
RUN_URL="$2"
RELEASE_URL="$3"
DEPLOY_RESULTS_PATH="$4"

SUMMARY=""
if ls "${DEPLOY_RESULTS_PATH}"/*.json 1> /dev/null 2>&1; then
  SUMMARY+="\n\`\`\`\n"
  SUMMARY+="Target      | Status | Details\n"
  SUMMARY+="------------|--------|----------------------\n"
  while IFS= read -r file; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    printf -v ROW "%-11s | %-6s | %s\n" "$TARGET" "$STATUS" "$NOTE"
    SUMMARY+="$ROW"
  done < <(find "${DEPLOY_RESULTS_PATH}" -type f -name "*.json" | sort)
  SUMMARY+="\n\`\`\`"
fi

FINAL="$MESSAGE$SUMMARY"
FINAL=$(echo "$FINAL" | sed "s#\\[View Pipeline\\]($RUN_URL)#<${RUN_URL}|View Pipeline>#g")
FINAL=$(echo "$FINAL" | sed "s#\\[View Release\\]($RELEASE_URL)#<${RELEASE_URL}|View Release>#g")
echo "$FINAL"
