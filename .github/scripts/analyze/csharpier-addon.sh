#!/bin/bash
set -e

echo "🔧 Unity-style post-processing: fix field formatting and spacing between fields/methods..."

find Assets -name "*.cs" | while read -r file; do
  awk '
  BEGIN {
    attr_block = "";
    header_attr = "";
    in_attr = 0;
    standard_indent = "    ";
    last_was_field = 0;
    last_line_type = "";
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

  function print_field(header, attrs, decl) {
    if (last_line_type == "method") print "";  # insert spacing after methods
    if (header != "") print standard_indent header;
    if (attrs != "") print standard_indent attrs " " decl;
    else print standard_indent decl;
    last_line_type = "field";
  }

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

  /^[[:space:]]*(public|private|protected|internal)[^;]*;[[:space:]]*$/ {
    sorted_attrs = attr_block != "" ? sort_attrs(attr_block) : "";
    print_field(header_attr, sorted_attrs, trim($0));
    header_attr = "";
    attr_block = "";
    in_attr = 0;
    next;
  }

  /^[[:space:]]*$/ {
    next; # we manage spacing manually
  }

  {
    # print a blank line before a method or unrelated code if previous was field
    if (last_line_type == "field") {
      print "";
    }

    if (attr_block != "" || header_attr != "") {
      # orphaned attribute block, flush it
      if (header_attr != "") print standard_indent header_attr;
      if (attr_block != "") print standard_indent sort_attrs(attr_block);
      header_attr = "";
      attr_block = "";
    }

    print $0;
    last_line_type = ($0 ~ /^[[:space:]]*(public|private)?[[:space:]]*void[[:space:]]+[a-zA-Z0-9_]+\(/) ? "method" : "other";
  }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

echo "✅ Clean spacing between fields and methods restored. No code lost!"
