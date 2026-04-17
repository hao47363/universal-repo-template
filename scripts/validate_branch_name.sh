#!/usr/bin/env sh

set -eu

branch_name="${1:-}"

if [ -z "$branch_name" ]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch_name="$(git rev-parse --abbrev-ref HEAD)"
  fi
fi

if [ -z "$branch_name" ]; then
  echo "Error: branch name is required."
  exit 1
fi

case "$branch_name" in
  main|develop|staging|dev)
    exit 0
    ;;
esac

pattern='^(feature|feat|fix|chore|docs|refactor|test|perf|ci|build|style|revert)\/[a-z0-9][a-z0-9._-]*$'

if ! printf '%s' "$branch_name" | grep -Eq "$pattern"; then
  echo "Invalid branch name: $branch_name"
  echo "Expected: <type>/<branch-name>"
  echo "Examples: feature/cart-add-item, fix/login-null-check, chore/update-readme"
  echo
  echo "Allowed types: feature, feat, fix, chore, docs, refactor, test, perf, ci, build, style, revert"
  echo "Branch-name rules: lowercase letters, numbers, dot, underscore, dash"
  exit 1
fi

