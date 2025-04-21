#!/bin/bash
set -e

echo "🔧 Running CSharpier post-fix: Flattening Unity field attributes..."

# This script rewrites C# files to move all attributes for each field onto the same line.

# Find all C# files in Assets/
find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    in_attr_block = 0;
    attr_line = "";
  }

  function flush_attr_and_line(line) {
    if (attr_line != "") {
      print attr_line line;
      attr_line = "";
    } else {
      print line;
    }
  }

  /^\s*\[/ {
    # Start collecting attributes
    in_attr_block = 1;
    attr_line = attr_line $0;
    next;
  }

  in_attr_block && /^\s*\[/ {
    # Continued attribute block
    attr_line = attr_line $0;
    next;
  }

  in_attr_block && /^\s*(public|private|protected|internal)/ {
    # Attribute block ends and field declaration starts
    flush_attr_and_line($0);
    in_attr_block = 0;
    next;
  }

  {
    if (in_attr_block) {
      # Unexpected line in attribute block (likely malformed), just flush and reset
      print attr_line;
      attr_line = "";
      in_attr_block = 0;
    }
    print $0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Attribute flattening complete."
