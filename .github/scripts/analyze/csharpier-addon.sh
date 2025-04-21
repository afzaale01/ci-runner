#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier fixer..."

find Assets -type f -name "*.cs" -print0 | while IFS= read -r -d '' file; do
  echo "📄 Fixing $file..."

  awk '
    function trim(str) {
      sub(/^[ \t\r\n]+/, "", str);
      sub(/[ \t\r\n]+$/, "", str);
      return str;
    }

    BEGIN {
      attributeLine = "";
      inAttributeBlock = 0;
    }

    # Header stands alone
    /^\[Header\(/ {
      if (inAttributeBlock) {
        print attributeLine " " currentDeclaration;
        attributeLine = "";
        currentDeclaration = "";
        inAttributeBlock = 0;
      }
      print $0;
      next;
    }

    # Match other attributes
    /^\[[^H][^ ]*\]/ {
      attributeLine = (attributeLine == "") ? $0 : attributeLine " " $0;
      inAttributeBlock = 1;
      next;
    }

    # Field declaration after attribute(s)
    /^[[:space:]]*(public|private|protected)/ {
      if (inAttributeBlock) {
        currentDeclaration = $0;
        print trim(attributeLine) " " trim(currentDeclaration);
        attributeLine = "";
        currentDeclaration = "";
        inAttributeBlock = 0;
      } else {
        print $0;
      }
      next;
    }

    # Any other line
    {
      if (inAttributeBlock) {
        print attributeLine " " currentDeclaration;
        attributeLine = "";
        currentDeclaration = "";
        inAttributeBlock = 0;
      }
      print $0;
    }
  ' "$file" > "$file.fixed" && mv "$file.fixed" "$file"

done

echo "✅ Unity-style formatting complete."