#!/bin/bash
MESSAGE="$1"

SUMMARY=""
if ls deploy-results/*.json 1> /dev/null 2>&1; then
  for file in deploy-results/*.json; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    SUMMARY+="- **$TARGET**: $STATUS – $NOTE\n"
  done
fi

echo -e "$MESSAGE\n\n**Deploy Targets:**\n$SUMMARY"
