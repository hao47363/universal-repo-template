#!/usr/bin/env sh

set -eu

pr_title="${1:-}"

if [ -z "$pr_title" ]; then
  echo "Error: PR title is required."
  exit 1
fi

# PR title rule:
# - Human-readable title-case segments
# - Slash-separated segments are allowed, e.g. "Feature/Add Changelog"
pattern='^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9 ]*)*$'

if ! printf '%s' "$pr_title" | grep -Eq "$pattern"; then
  echo "Invalid PR title format."
  echo "Expected: Title Case words, optionally slash-separated."
  echo "Example: Feature/Add Changelog"
  echo "Example: Fix/Login Null Check"
  exit 1
fi
