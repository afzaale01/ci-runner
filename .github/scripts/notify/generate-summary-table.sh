#!/bin/bash
SUMMARY=""
if ls deploy-results/*.json 1> /dev/null 2>&1; then
  SUMMARY+="| Target | Status | Details |\n"
  SUMMARY+="|--------|--------|---------|\n"
  for file in deploy-results/*.json; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    SUMMARY+="| $TARGET | $STATUS | $NOTE |\n"
  done
fi
echo -e "$SUMMARY"
