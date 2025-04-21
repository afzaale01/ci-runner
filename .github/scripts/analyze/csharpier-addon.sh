#!/bin/bash
set -e

echo "🔧 Running CSharpier post-fix: Flattening Unity field attributes..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    in_attr = 0;
  }

  function trim(s) {
    sub(/^[ \t\r\n]+/, "", s);
    sub(/[ \t\r\n]+$/, "", s);
    return s;
  }

  function flush_attr() {
    if (attr_block != "") {
      print attr_block;
      attr_block = "";
    }
  }

  /^[[:space:]]*\[/ {
    in_attr = 1;
    attr_block = attr_block trim($0);
    next;
  }

  in_attr && /^[[:space:]]*\[/ {
    attr_block = attr_block trim($0);
    next;
  }

  in_attr && /^[[:space:]]*(public|private|protected|internal)[^=]*;[[:space:]]*$/ {
    # Field detected after attributes
    print attr_block trim($0);
    attr_block = "";
    in_attr = 0;
    next;
  }

  {
    if (in_attr) {
      # If the line isn't a field, flush and reset
      print attr_block;
      attr_block = "";
      in_attr = 0;
    }
    print $0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Fields flattened to single lines."
