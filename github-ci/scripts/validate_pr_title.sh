#!/usr/bin/env sh

set -eu

pr_title="${1:-}"

if [ -z "$pr_title" ]; then
  echo "Error: PR title is required."
  exit 1
fi

# PR title rule:
# - Each word is either Title Case ([A-Z] then lowercase letters/digits) or an all-caps acronym
#   (two or more letters, optional trailing digits), e.g. "API", "HTTP2".
# - Slash-separated segments are allowed, e.g. "Feature/Add Changelog".
# - Words within a segment are space-separated.
word='([A-Z][a-z0-9]*|[A-Z]{2,}[0-9]*)'
segment="${word}( ${word})*"
pattern="^(${segment})(/(${segment}))*$"

if ! printf '%s' "$pr_title" | grep -Eq "$pattern"; then
  echo "Invalid PR title format."
  echo "Expected: Title Case words or acronyms like API (two+ capitals), space-separated; optional slash segments."
  echo "Example: Feature/Add Changelog"
  echo "Example: Fix API Gateway"
  exit 1
fi
