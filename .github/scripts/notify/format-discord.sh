#!/bin/bash
MESSAGE="$1"

SUMMARY=""
if ls deploy-results/*.json 1> /dev/null 2>&1; then
  SUMMARY+="\`\`\`\n"
  SUMMARY+="Target       Status   Details\n"
  SUMMARY+="-----------  -------  ----------------------\n"
  for file in deploy-results/*.json; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    SUMMARY+=$(printf "%-12s %-8s %s\n" "$TARGET" "$STATUS" "$NOTE")
  done
  SUMMARY+="\n\`\`\`"
fi

echo -e "$MESSAGE\n\n$SUMMARY"
