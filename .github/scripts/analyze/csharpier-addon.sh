#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: one-line fields, except Header stays above..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 0;
  }

  function trim(s) {
    sub(/^[ \t\r\n]+/, "", s);
    sub(/[ \t\r\n]+$/, "", s);
    return s;
  }

  /^[[:space:]]*\[/ {
    attr = trim($0);
    if (attr ~ /^\[Header\(/) {
      header_attr = attr;
    } else {
      in_attr = 1;
      attr_block = attr_block attr;
    }
    next;
  }

  in_attr && /^[[:space:]]*\[/ {
    attr = trim($0);
    if (attr ~ /^\[Header\(/) {
      header_attr = attr;
    } else {
      attr_block = attr_block attr;
    }
    next;
  }

  # Field follows attributes
  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    if (header_attr != "") {
      print header_attr;
    }
    print attr_block trim($0);
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 1;
    next;
  }

  # Field without any attributes
  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    print trim($0);
    skip_next_blank = 1;
    next;
  }

  # Skip blank lines after a field
  /^[[:space:]]*$/ {
    if (skip_next_blank) {
      skip_next_blank = 0;
      next;
    }
    print "";
    next;
  }

  {
    # Catch orphaned attribute blocks
    if (attr_block != "" || header_attr != "") {
      if (header_attr != "") print header_attr;
      if (attr_block != "") print attr_block;
      header_attr = "";
      attr_block = "";
      in_attr = 0;
    }
    print $0;
    skip_next_blank = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Fields flattened, Header preserved above fields, and blank lines removed."
