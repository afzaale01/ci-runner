#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier fixer (Header floats, others inline)..."

find Assets -type f -name "*.cs" -print0 | while IFS= read -r -d '' file; do
  echo "📄 Fixing $file..."

  awk '
    function trim(str) {
      sub(/^[ \t\r\n]+/, "", str);
      sub(/[ \t\r\n]+$/, "", str);
      return str;
    }

    BEGIN {
      headerMode = 0;
      attrBlock = "";
    }

    # Handle headers
    /^\[Header\(/ {
      if (attrBlock != "") {
        print trim(attrBlock) " " trim($0);
        attrBlock = "";
      } else {
        print $0;
      }
      headerMode = 1;
      next;
    }

    # Handle other attributes
    /^\[[^H][^ ]*\]/ {
      attrBlock = (attrBlock == "") ? $0 : attrBlock " " $0;
      next;
    }

    # Handle field declaration
    /^[ \t]*(public|private|protected)/ {
      if (headerMode) {
        if (attrBlock != "") {
          print trim(attrBlock) " " trim($0);
          attrBlock = "";
        } else {
          print $0;
        }
        headerMode = 0;
      } else if (attrBlock != "") {
        print trim(attrBlock) " " trim($0);
        attrBlock = "";
      } else {
        print $0;
      }
      next;
    }

    # Print any other lines
    {
      if (attrBlock != "") {
        print trim(attrBlock);
        attrBlock = "";
      }
      print $0;
    }
  ' "$file" > "$file.fixed" && mv "$file.fixed" "$file"

done

echo "✅ Unity-style formatting complete."
