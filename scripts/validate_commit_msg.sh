#!/usr/bin/env sh

set -eu

commit_msg_file="${1:-}"

if [ -z "$commit_msg_file" ] || [ ! -f "$commit_msg_file" ]; then
  echo "Error: commit message file is required."
  exit 1
fi

first_line="$(sed -n '1p' "$commit_msg_file" | tr -d '\r')"

conventional_types="$(sh ./scripts/get_config_value.sh governance.conventional_types "feat,fix,chore,docs,refactor,test,perf,ci,build,style,revert")"
types_pattern="$(printf '%s' "$conventional_types" | tr -d ' ' | tr ',' '|')"
pattern="^(${types_pattern})\\([a-z0-9][a-z0-9._-]*\\): .+"

if ! printf '%s' "$first_line" | grep -Eq "$pattern"; then
  echo "Invalid commit message format."
  echo "Expected: <type>(<scope>): <message>"
  echo "Example: feat(cart): implement add to cart option"
  echo
  echo "Allowed types: $conventional_types"
  echo "Scope rules: lowercase letters, numbers, dot, underscore, dash"
  exit 1
fi
