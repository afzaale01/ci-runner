#!/bin/bash
MESSAGE="$1"
SUMMARY=$(bash .github/scripts/generate-summary-table.sh)

if [ -n "$SUMMARY" ]; then
  echo -e "$MESSAGE\n\n**Deploy Targets:**\n$SUMMARY"
else
  echo -e "$MESSAGE"
fi
