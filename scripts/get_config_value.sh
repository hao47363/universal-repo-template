#!/usr/bin/env sh

set -eu

key="${1:-}"
default_value="${2:-}"

if [ -z "$key" ]; then
  echo "Usage: $0 <section.key> [default]"
  exit 1
fi

value=""
if ! value="$(sh ./scripts/read_repo_settings.sh "$key")"; then
  echo "Error: read_repo_settings.sh failed for key: $key" >&2
  exit 1
fi

if [ -z "$value" ]; then
  if ! value="$(sh ./scripts/read_project_config.sh "$key")"; then
    echo "Error: read_project_config.sh failed for key: $key" >&2
    exit 1
  fi
fi

if [ -z "$value" ]; then
  value="$default_value"
fi

printf '%s\n' "$value"
