#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier Addon Fixer..."

# Find all .cs files under Assets
find Assets -name '*.cs' | while read -r file; do
  tmp_file="${file}.tmp"
  in_header_block=false

  awk '
    BEGIN { OFS = ""; in_header = 0 }
    # Detect [Header(...)]
    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      in_header = 1
      next
    }
    # Detect [SerializeField] and possibly other attributes
    /^\s*(\[.*\])*\s*\[SerializeField\](.*)$/ {
      line = $0
      # If a header was previously found, insert it on a separate line above SerializeField
      if (in_header) {
        print header_line
        in_header = 0
      }
      # Reorder so SerializeField is always first, and collapse other attributes to same line
      gsub(/\[SerializeField\]/, "", line)
      gsub(/\s+/, " ", line) # normalize spacing
      sub(/^\s*/, "")        # remove leading space
      print "    [SerializeField]" line
      next
    }
    # Any other line — flush header if we didn’t find SerializeField
    {
      if (in_header) {
        print header_line
        in_header = 0
      }
      print $0
    }
  ' "$file" > "$tmp_file"

  # Replace original file if changes were made
  if ! cmp -s "$file" "$tmp_file"; then
    echo "📝 Fixed: $file"
    mv "$tmp_file" "$file"
  else
    rm "$tmp_file"
  fi
done

echo "✅ Unity-style attribute layout enforced."