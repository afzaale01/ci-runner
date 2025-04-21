#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: one-line fields, Header above, 4-space indent enforced..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 0;
    standard_indent = "    "; # 4 spaces
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

  # Field after attributes
  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    if (header_attr != "") {
      print standard_indent header_attr;
    }
    print standard_indent attr_block trim($0);
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 1;
    next;
  }

  # Field without attributes
  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    print standard_indent trim($0);
    skip_next_blank = 1;
    next;
  }

  # Skip blank lines after fields
  /^[[:space:]]*$/ {
    if (skip_next_blank) {
      skip_next_blank = 0;
      next;
    }
    print "";
    next;
  }

  {
    # Orphaned attribute blocks (shouldn’t happen, but just in case)
    if (attr_block != "" || header_attr != "") {
      if (header_attr != "") print standard_indent header_attr;
      if (attr_block != "") print standard_indent attr_block;
      attr_block = "";
      header_attr = "";
      in_attr = 0;
    }
    print $0;
    skip_next_blank = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ All fields now start with 4-space indent, Header above fields, no blank lines remain."
