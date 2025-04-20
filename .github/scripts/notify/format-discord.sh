#!/bin/bash
MESSAGE="$1"

# Safely add trace if BRANCH/COMMIT are set
TRACE=""
[ -n "$BRANCH" ] && TRACE+="Branch: \`$BRANCH\`"
[ -n "$COMMIT" ] && TRACE+="${TRACE:+ | }Commit: \`$(echo "$COMMIT" | cut -c1-7)\`"
[ -n "$TRACE" ] && MESSAGE="$MESSAGE\n$TRACE"

# Add per-target deploy summary as a Discord-friendly code block
SUMMARY=""
if ls deploy-results/*.json 1> /dev/null 2>&1; then
  SUMMARY+="\n\`\`\`\n"
  SUMMARY+="Target       Status   Details\n"
  SUMMARY+="-----------  -------  ----------------------\n"
  for file in deploy-results/*.json; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    SUMMARY+=$(printf "%-12s %-8s %s\n" "$TARGET" "$STATUS" "$NOTE")
  done
  SUMMARY+="\`\`\`"
fi

echo -e "$MESSAGE$SUMMARY"
