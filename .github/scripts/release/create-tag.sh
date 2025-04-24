#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"
SHA="${2:-$(git rev-parse HEAD)}"
REPO="${GITHUB_REPOSITORY:-your-org/your-repo}"

# Determine fallback version if input is empty, null, or just whitespace
if [[ -z "${INPUT_VERSION// }" ]]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  TIMESTAMP=$(date +'%Y%m%dT%H%M')
  VERSION="manual-${BRANCH}-${TIMESTAMP}"
  echo "⚠️ No valid version provided — falling back to '$VERSION'"
else
  VERSION="$INPUT_VERSION"
  echo "ℹ️ Using provided version: '$VERSION'"
fi

echo "🧪 Creating tag '$VERSION' at commit $SHA in $REPO"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d @- "https://api.github.com/repos/${REPO}/git/refs" <<EOF
{
  "ref": "refs/tags/$VERSION",
  "sha": "$SHA"
}
EOF
)

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n1)

if [[ "$STATUS" -ne 201 ]]; then
  echo "❌ Failed to create tag: $BODY"
  exit 1
fi

echo "✅ Created tag: $VERSION"
echo "version=\"$VERSION\"" >> "$GITHUB_OUTPUT"
