#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: single-line fields, no trailing blank lines..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    in_attr = 0;
    skip_next_blank = 0;
  }

  function trim(s) {
    sub(/^[ \t\r\n]+/, "", s);
    sub(/[ \t\r\n]+$/, "", s);
    return s;
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

  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    print attr_block trim($0);
    attr_block = "";
    in_attr = 0;
    skip_next_blank = 1;
    next;
  }

  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    print trim($0);
    skip_next_blank = 1;
    next;
  }

  /^[[:space:]]*$/ {
    if (skip_next_blank) {
      skip_next_blank = 0;
      next; # actually skip the blank line
    }
    print "";
    next;
  }

  {
    if (attr_block != "") {
      print attr_block;
      attr_block = "";
      in_attr = 0;
    }
    print $0;
    skip_next_blank = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Fields flattened and newlines removed."
