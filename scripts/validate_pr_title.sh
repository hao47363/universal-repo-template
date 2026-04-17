#!/usr/bin/env sh

set -eu

pr_title="${1:-}"

if [ -z "$pr_title" ]; then
  echo "Error: PR title is required."
  exit 1
fi

pattern='^(feat|fix|chore|docs|refactor|test|perf|ci|build|style|revert)(\([a-z0-9][a-z0-9._-]*\))?: .+'

if ! printf '%s' "$pr_title" | grep -Eq "$pattern"; then
  echo "Invalid PR title format."
  echo "Expected: <type>(<scope>): <message> or <type>: <message>"
  echo "Example: feat(api): add account endpoint"
  echo "Example: docs: add onboarding guide"
  echo
  echo "Allowed types: feat, fix, chore, docs, refactor, test, perf, ci, build, style, revert"
  echo "Scope rules: lowercase letters, numbers, dot, underscore, dash"
  exit 1
fi
