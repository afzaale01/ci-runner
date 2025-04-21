#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: grouping, spacing, sorted attributes, etc..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 0;
    standard_indent = "    ";
    last_type = "";  # "field" or "method"
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
    return line;
  }

  # ───── Collect Attributes ─────
  /^[[:space:]]*\[/ {
    attr = trim($0);
    if (attr ~ /^\[Header\(/) {
      header_attr = attr;
    } else {
      in_attr = 1;
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
      attr = gensub(/\][ \t]*\[/, "][", "g", attr)
      attr_block = attr_block attr;
    }
    next;
  }

  # ───── Print Field with Attributes ─────
  in_attr && /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    if (last_type == "method") print "";
    if (header_attr != "") print standard_indent header_attr;
    sorted_attrs = sort_attrs(attr_block);
    print standard_indent sorted_attrs " " trim($0);
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    skip_next_blank = 1;
    last_type = "field";
    next;
  }

  # ───── Print Field without Attributes ─────
  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    if (last_type == "method" || last_type == "attr_field") print "";
    print standard_indent trim($0);
    skip_next_blank = 1;
    last_type = "field";
    next;
  }

  # ───── Blank Lines ─────
  /^[[:space:]]*$/ {
    next;  # handled manually
  }

  # ───── Print Method or Anything Else ─────
  {
    if (attr_block != "" || header_attr != "") {
      if (header_attr != "") print standard_indent header_attr;
      if (attr_block != "") {
        sorted_attrs = sort_attrs(attr_block);
        print standard_indent sorted_attrs;
      }
      attr_block = "";
      header_attr = "";
      in_attr = 0;
    }

    if (last_type == "field") print "";

    print $0;
    last_type = ($0 ~ /^[[:space:]]*(public|private|protected|internal)?[[:space:]]*([a-zA-Z0-9_<>]+\s+)+[a-zA-Z0-9_]+\s*\(.*\)/) ? "method" : "other";
    skip_next_blank = 0;
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Spacing between groups done. Fields and methods are now beautifully grouped."
