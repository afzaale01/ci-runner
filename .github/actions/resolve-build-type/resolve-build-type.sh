#!/usr/bin/env bash
set -euo pipefail

# 1) If tests-only flag is true, we always do a preview build
if [[ "${TESTS_ONLY_OVERRIDE:-}" == "true" ]]; then
  echo "buildType=preview" >> "$GITHUB_OUTPUT"
  exit 0
fi

# 2) Manual override wins next, but only if it's not empty or invalid
if [[ -n "${BUILD_TYPE_OVERRIDE:-}" && "$BUILD_TYPE_OVERRIDE" =~ ^(preview|release_candidate|release)$ ]]; then
  echo "buildType=${BUILD_TYPE_OVERRIDE}" >> "$GITHUB_OUTPUT"
  exit 0
fi

# 3) Auto-detect based on event/ref
case "$GITHUB_EVENT_NAME" in
  pull_request)
    # all PR updates are preview/test runs
    echo "buildType=preview" >> "$GITHUB_OUTPUT"
    ;;

  push)
    # on push, inspect the ref for a tag
    if [[ "$GITHUB_REF" =~ ^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "buildType=release" >> "$GITHUB_OUTPUT"
    elif [[ "$GITHUB_REF" =~ ^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+-rc\.[0-9]+$ ]]; then
      echo "buildType=release_candidate" >> "$GITHUB_OUTPUT"
    else
      echo "buildType=preview" >> "$GITHUB_OUTPUT"
    fi
    ;;

  *)
    # everything else defaults to preview
    echo "buildType=preview" >> "$GITHUB_OUTPUT"
    ;;
esac