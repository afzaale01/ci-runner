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
      prev_blank = 0
    }

    /^\s*\[Header\(.*\)\]\s*$/ {
      header_line = $0
      next
    }

    /^\s*\[[^]]+\]/ {
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
        if (prev_blank == 0) {
          print header_line
          print ""
          prev_blank = 1
        } else {
          print header_line
        }
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
      prev_blank = 0
      next
    }

    /^\s*$/ {
      # Track blank lines to avoid duplicating after header
      if (header_line != "") {
        print header_line
        print ""
        header_line = ""
      } else {
        print ""
      }
      prev_blank = 1
