#!/usr/bin/env sh

set -eu

cfg_file=".template/repo-settings.yml"
query="${1:-}"

if [ -z "$query" ]; then
  echo "Usage: $0 <section.key>"
  exit 1
fi

if [ ! -f "$cfg_file" ]; then
  exit 0
fi

section="${query%%.*}"
key="${query#*.}"

if [ "$section" = "$query" ] || [ -z "$key" ]; then
  echo "Query must be in section.key format."
  exit 1
fi

awk -v section="$section" -v key="$key" '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    return s
  }

  /^[[:space:]]*#/ { next }
  /^[[:space:]]*$/ { next }

  /^[a-zA-Z0-9_]+:[[:space:]]*$/ {
    current = $0
    sub(/:.*/, "", current)
    current = trim(current)
    next
  }

  {
    if (current != section) next
    if ($0 !~ /^[[:space:]]{2}[a-zA-Z0-9_]+:[[:space:]]*/) next

    line = $0
    sub(/^[[:space:]]{2}/, "", line)
    item_key = line
    sub(/:.*/, "", item_key)
    item_key = trim(item_key)
    if (item_key != key) next

    value = line
    sub(/^[^:]+:[[:space:]]*/, "", value)
    value = trim(value)
    if (value ~ /^".*"$/) {
      sub(/^"/, "", value)
      sub(/"$/, "", value)
    }
    print value
    exit
  }
' "$cfg_file"
