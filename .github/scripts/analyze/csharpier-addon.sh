#!/bin/bash
set -e

echo "🔧 Running Unity-style CSharpier Addon Fixer..."

find Assets -name '*.cs' | while read -r file; do
  tmp_file="${file}.tmp"
  in_header=0
  header_line=""

  awk '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function sort_attrs(attrs,   n, a, i, j, tmp) {
      n = split(attrs, a, ",")
      # Simple bubble sort since n is usually 1-3
      for (i = 1; i <= n; i++) a[i] = trim(a[i])
      for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
          if (a[i] > a[j]) {
            tmp = a[i]; a[i] = a[j]; a[j] = tmp
          }
        }
      }
      return a[1] (n > 1 ? ", " a[2] : "") (n > 2 ? ", " a[3] : "")
    }

    BEGIN { in_header = 0 }

    # Match: [Header("Some Text")]
    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      in_header = 1
      next
    }

    # Match: lines with SerializeField and possibly others
    /^\s*(\[.*\])+\s*private/ {
      orig = $0
      matches = ""
      field = orig

      # Extract all [] attributes
      while (match(field, /\[[^]]*\]/)) {
        attr = substr(field, RSTART + 1, RLENGTH - 2)
        if (attr ~ /^SerializeField$/) {
          has_serialize = 1
        } else {
          matches = matches == "" ? attr : matches ", " attr
        }
        field = substr(field, RSTART + RLENGTH)
      }

      # Sort non-SerializeField attributes
      sorted = matches == "" ? "" : sort_attrs(matches)

      if (in_header) {
        print header_line
        print ""
        in_header = 0
      }

      print "    [SerializeField" (sorted != "" ? ", " sorted : "") "] " substr(orig, match(orig, /private/))
      next
    }

    {
      if (in_header) {
        print header_line
        print ""
        in_header = 0
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

echo "✅ Unity-style attribute layout enforced with header spacing and sorted attributes."
