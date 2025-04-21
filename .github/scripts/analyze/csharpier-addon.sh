#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier fixer (Header + SerializeField)..."

find Assets -type f -name "*.cs" -print0 | while IFS= read -r -d '' file; do
  echo "📄 Fixing $file..."

  awk '
    BEGIN {
      inSerializeBlock = 0;
    }

    # Match [Header("...")] — should always be on its own line
    /^\[Header\(/ {
      if (inSerializeBlock) {
        print "";
        inSerializeBlock = 0;
      }
      print $0;
      next;
    }

    # Match [SerializeField] on its own line
    /^\[SerializeField\]$/ {
      getline nextLine;
      if (nextLine ~ /^[[:space:]]*(public|private|protected)/) {
        print "[SerializeField] " nextLine;
        inSerializeBlock = 1;
        next;
      } else {
        print $0;
        print nextLine;
        next;
      }
    }

    # Match one-liner [SerializeField] field
    /^\[SerializeField\][[:space:]]+(public|private|protected)/ {
      print $0;
      inSerializeBlock = 1;
      next;
    }

    # Match any other line
    {
      if (inSerializeBlock) {
        print "";
        inSerializeBlock = 0;
      }
      print $0;
    }

  ' "$file" > "$file.fixed" && mv "$file.fixed" "$file"

done

echo "✅ Unity-style formatting complete."
