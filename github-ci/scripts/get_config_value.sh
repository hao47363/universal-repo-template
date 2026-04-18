#!/usr/bin/env sh

set -eu

key="${1:-}"
default_value="${2:-}"

if [ -z "$key" ]; then
  echo "Usage: $0 <section.key> [default]"
  exit 1
fi

value="$(sh ./scripts/read_repo_settings.sh "$key" 2>/dev/null || true)"

if [ -z "$value" ]; then
  value="$(sh ./scripts/read_project_config.sh "$key" 2>/dev/null || true)"
fi

if [ -z "$value" ]; then
  value="$default_value"
fi

printf '%s\n' "$value"
