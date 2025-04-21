#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier Addon Fixer..."

find Assets -name '*.cs' | while read -r file; do
  tmp_file="${file}.tmp"

  awk '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function sort_attrs(attrs,   n, a, i, j, tmp) {
      n = split(attrs, a, ",")
      for (i = 1; i <= n; i++) a[i] = trim(a[i])
      for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
          if (a[i] > a[j]) { tmp = a[i]; a[i] = a[j]; a[j] = tmp }
        }
      }
      out = a[1]
      for (i = 2; i <= n; i++) out = out ", " a[i]
      return out
    }

    BEGIN {
      in_header = 0
      header_line = ""
      attribute_block = ""
    }

    # Capture Header and hold it
    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      in_header = 1
      next
    }

    # Capture lines with attributes
    /^\s*\[[^]]+\]/ {
      if (attribute_block != "") {
        attribute_block = attribute_block " " trim($0)
      } else {
        attribute_block = trim($0)
      }
      next
    }

    # When we hit the field
    /^\s*(public|private|protected|internal)[^;]+;/ {
      access_line = $0

      # Separate attributes into individual parts
      split(attribute_block, raw_attrs, /\]\s*\[/)
      attr_clean = ""
      serialize_present = 0
      attr_list = ""

      for (i in raw_attrs) {
        attr = raw_attrs[i]
        gsub(/\[|\]/, "", attr)
        attr = trim(attr)
        if (attr == "SerializeField") {
          serialize_present = 1
        } else if (attr != "") {
          attr_list = attr_list == "" ? attr : attr_list ", " attr
        }
      }

      sorted_attrs = sort_attrs(attr_list)

      if (in_header) {
        print header_line
        print ""
        in_header = 0
      }

      if (serialize_present) {
        if (sorted_attrs != "") {
          print "    [SerializeField, " sorted_attrs "] " trim(access_line)
        } else {
          print "    [SerializeField] " trim(access_line)
        }
      } else {
        if (sorted_attrs != "") {
          print "    [" sorted_attrs "] " trim(access_line)
        } else {
          print "    " trim(access_line)
        }
      }

      attribute_block = ""
      next
    }

    {
      if (in_header) {
        print header_line
        print ""
        in_header = 0
      }

      if (attribute_block != "") {
        print attribute_block
        attribute_block = ""
      }

      print $0
    }
  ' "$file" > "$tmp_file"

  if ! cmp -s "$file" "$tmp_file"; then
    echo "📝 Fixed: $file"
    mv "$tmp_file" "$file"
  else
    rm "$tmp_file"
  fi
done

echo "✅ Unity attribute style applied: headers spaced, serialize first, others sorted inline."
