#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier fixer (Header + SerializeField + other attributes)..."

find Assets -type f -name "*.cs" -print0 | while IFS= read -r -d '' file; do
  echo "📄 Fixing $file..."

  awk '
    function flushAttributes() {
      if (attrCount > 0 && fieldLine != "") {
        line = "";
        for (i = 1; i <= attrCount; i++) {
          line = line (i == 1 ? "" : " ") attributes[i];
        }
        print line " " fieldLine;
        attrCount = 0;
        fieldLine = "";
      }
    }

    BEGIN {
      attrCount = 0;
      fieldLine = "";
    }

    /^\[Header\(/ {
      flushAttributes();
      print "";  # Add spacing before headers
      print $0;
      next;
    }

    /^\[[^]]+\]$/ {
      attributes[++attrCount] = $0;
      next;
    }

    /^[[:space:]]*(public|private|protected)/ {
      fieldLine = $0;
      flushAttributes();
      next;
    }

    {
      flushAttributes();
      print $0;
    }

    END {
      flushAttributes();
    }
  ' "$file" > "$file.fixed" && mv "$file.fixed" "$file"

done

echo "✅ Unity-style formatting complete."
