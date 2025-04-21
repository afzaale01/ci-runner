#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: one-line fields, Header above, 4-space indent, sorted attributes, spacing before Header..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 0;
    standard_indent = "    ";
    last_was_open_brace = 0;
  }

  function trim(s) {
    sub(/^[ \t\r\n]+/, "", s);
    sub(/[ \t\r\n]+$/, "", s);
    return s;
  }

  function sort_attrs(attrs_raw) {
    n = split(attrs_raw, parts, /\]\[/)
    delete attrs
    hasSerializeField = 0
    for (i = 1; i <= n; i++) {
      a = parts[i]
      gsub(/^\[|\]$/, "", a)
      if (a == "SerializeField") {
        hasSerializeField = 1
      } else {
        attrs[a] = a
      }
    }
    asorti(attrs, sorted)
    line = ""
    if (hasSerializeField) {
      line = "[SerializeField]"
    }
    for (i = 1; i <= length(sorted); i++) {
      line = line "[" attrs[sorted[i]] "]"
    }
    return line
  }

  /^[[:space:]]*\[/ {
    attr = trim($0);
    if (attr ~ /^\[Header\(/) {
      header_attr = attr;
    } else {
      in_attr = 1;
      gsub(/^[ \t]+/, "", attr)
      attr = gensub(/\][ \t]*\[/, "][", "g", attr)
      attr_block = attr_block attr;
    }
    next;
  }

  in_attr && /^[[:space:]]*\[/ {
    attr = trim($0);
    if (attr ~ /^\[Header\(/) {
      header_attr = attr;
    } else {
      gsub(/^[ \t]+/, "", attr)
      attr = gensub(/\][ \t]*\[/, "][", "g", attr)
      attr_block = attr_block attr;
    }
    next;
  }

  # Field after attributes
  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    if (header_attr != "") {
      if (!last_was_open_brace) print "";  # Add newline before Header unless it's directly after {
      print standard_indent header_attr;
    }
    sorted_attrs = sort_attrs(attr_block);
    print standard_indent sorted_attrs trim($0);
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 1;
    last_was_open_brace = 0;
    next;
  }

  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    print standard_indent trim($0);
    skip_next_blank = 1;
    last_was_open_brace = 0;
    next;
  }

  /^[[:space:]]*$/ {
    if (skip_next_blank) {
      skip_next_blank = 0;
      next;
    }
    print "";
    next;
  }

  /^[[:space:]]*{[[:space:]]*$/ {
    print $0;
    last_was_open_brace = 1;
    next;
  }

  {
    if (attr_block != "" || header_attr != "") {
      if (header_attr != "") {
        if (!last_was_open_brace) print "";
        print standard_indent header_attr;
      }
      if (attr_block != "") {
        sorted_attrs = sort_attrs(attr_block);
        print standard_indent sorted_attrs;
      }
      attr_block = "";
      header_attr = "";
      in_attr = 0;
      last_was_open_brace = 0;
    }
    print $0;
    skip_next_blank = 0;
    last_was_open_brace = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Done! Headers are spaced correctly, attributes sorted, and everything is clean."
