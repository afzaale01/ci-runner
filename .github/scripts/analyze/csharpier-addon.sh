#!/bin/bash
set -e

echo "🔧 Reformatting fields: one-liner fields with no extra newlines..."

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

  /^[[:space:]]*\[/ {
    # Start or continue collecting attribute block
    in_attr = 1;
    attr_block = attr_block trim($0);
    next;
  }

  in_attr && /^[[:space:]]*\[/ {
    # Continue collecting multi-line attributes
    attr_block = attr_block trim($0);
    next;
  }

  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    # Field declaration follows attribute block
    print attr_block trim($0);
    attr_block = "";
    in_attr = 0;
    next;
  }

  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    # Standalone field (no attribute)
    print trim($0);
    next;
  }

  /^[[:space:]]*$/ {
    # Skip empty lines following a field or attribute
    if (attr_block != "") {
      next;
    }
    if (prev_line_was_field) {
      next;
    }
    print "";
    next;
  }

  {
    # Flush any collected attributes if we didn’t hit a field
    if (attr_block != "") {
      print attr_block;
      attr_block = "";
      in_attr = 0;
    }
    print $0;
    prev_line_was_field = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Fields collapsed and blank lines removed."
