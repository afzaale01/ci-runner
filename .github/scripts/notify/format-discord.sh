#!/bin/bash
MESSAGE="$1"
RUN_URL="$2"
RELEASE_URL="$3"

SUMMARY=""
if ls deploy-results/*.json 1> /dev/null 2>&1; then
  SUMMARY+="\n\`\`\`\n"
  SUMMARY+="Target      | Status | Details\n"
  SUMMARY+="------------|--------|----------------------\n"
  while IFS= read -r file; do
    TARGET=$(basename "$file" .json)
    STATUS=$(jq -r '.status' "$file")
    NOTE=$(jq -r '.note' "$file")
    printf -v ROW "%-11s | %-6s | %s\n" "$TARGET" "$STATUS" "$NOTE"
    SUMMARY+="$ROW"
  done < <(find deploy-results -type f -name "*.json" | sort)
  SUMMARY+="\n\`\`\`"
fi

# --- 🔗 Shorten URLs to suppress Discord embeds ---
shorten_url() {
  curl -s "https://tinyurl.com/api-create.php?url=$1"
}

RELEASE_SHORT=$(shorten_url "$RELEASE_URL")
RUN_SHORT=$(shorten_url "$RUN_URL")

# --- 🔔 Append formatted link line to the message ---
MESSAGE="$MESSAGE\n📦 [View Release](<$RELEASE_SHORT>)   ·   🔗 [View Pipeline](<$RUN_SHORT>)"

# --- 🧾 Combine everything ---
FINAL="$MESSAGE$SUMMARY"

# You can keep this sed just in case any leftover [text](url) exists, though it may be redundant now
FINAL=$(echo "$FINAL" | sed -E 's/\[([^\]]+)\]\(([^)]+)\)/[\1](<\2>)/g')

echo "$FINAL"
