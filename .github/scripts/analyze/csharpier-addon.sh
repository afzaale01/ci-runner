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
      header_line = ""
      attrs = ""
    }

    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      next
    }

    /^\s*\[[^]]+\]/ {
      # Strip [] and keep attribute name
      attr = $0
      gsub(/\[|\]/, "", attr)
      attr = trim(attr)
      attrs = attrs == "" ? attr : attrs ", " attr
      next
    }

    /^\s*(public|private|protected|internal)[^;]+;/ {
      line = $0

      split(attrs, all_attrs, ",")
      serialize_first = ""
      others = ""
      for (i in all_attrs) {
        a = trim(all_attrs[i])
        if (a == "SerializeField") {
          serialize_first = a
        } else if (a != "") {
          others = others == "" ? a : others ", " a
        }
      }

      if (header_line != "") {
        print header_line
        print ""
        header_line = ""
      }

      if (serialize_first != "") {
        if (others != "") {
          print "    [" serialize_first ", " sort_attrs(others) "] " trim(line)
        } else {
          print "    [" serialize_first "] " trim(line)
        }
      } else if (others != "") {
        print "    [" sort_attrs(others) "] " trim(line)
      } else {
        print "    " trim(line)
      }

      attrs = ""
      next
    }

    {
      if (header_line != "") {
        print header_line
        print ""
        header_line = ""
      }

      if (attrs != "") {
        # orphaned attributes, print them raw
        print "    [" attrs "]"
        attrs = ""
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

echo "✅ Unity-style attribute cleanup complete. Safe for CSharpier."
