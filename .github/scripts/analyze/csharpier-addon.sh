#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier addon..."

# Merge [SerializeField] attributes into one-liners
find Assets -type f -name "*.cs" -print0 | while IFS= read -r -d '' file; do
  sed -i.bak -E ':a;N;$!ba;s/\[SerializeField\]\n[[:space:]]*/[SerializeField] /g' "$file"
  rm "$file.bak"
done

echo "✅ Done fixing common Unity style issues."
