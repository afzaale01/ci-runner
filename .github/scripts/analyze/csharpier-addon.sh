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

    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      in_header = 1
      next
    }

    /^\s*\[[^]]+\]/ {
      attribute_block = attribute_block == "" ? trim($0) : attribute_block " " trim($0)
      next
    }

    /^\s*(public|private|protected|internal)[^;]+;/ {
      access_line = trim($0)
      serialize_present = 0
      attr_list = ""

      n = split(attribute_block, raw_attrs, /\]\s*\[/)
      for (i = 1; i <= n; i++) {
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
        print ""   # exactly one blank line after header
        in_header = 0
      }

      if (serialize_present) {
        if (sorted_attrs != "") {
          print "    [SerializeField, " sorted_attrs "] " access_line
        } else {
          print "    [SerializeField] " access_line
        }
      } else if (sorted_attrs != "") {
        print "    [" sorted_attrs "] " access_line
      } else {
        print "    " access_line
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

echo "✅ Unity-style format applied: headers spaced, no extra blank lines."
