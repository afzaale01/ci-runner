#!/bin/bash
set -euo pipefail

BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}
TIMESTAMP=$(date +'%Y%m%dT%H%M')
VERSION="manual-${BRANCH}-${TIMESTAMP}"
SHA=$(git rev-parse HEAD)
REPO="$GITHUB_REPOSITORY"

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
echo "version=$VERSION" >> "$GITHUB_OUTPUT"