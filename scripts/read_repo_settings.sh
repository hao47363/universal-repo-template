#!/usr/bin/env sh

set -eu

cfg_file=".template/repo-settings.yml"
query="${1:-}"

if [ -z "$query" ]; then
  echo "Usage: $0 <section.key|top-level-key>"
  exit 1
fi

if [ ! -f "$cfg_file" ]; then
  exit 0
fi

section="${query%%.*}"
key="${query#*.}"

# Plain keys (no dot): top-level "key: value" only (legacy parity with project-config).
if [ "$section" = "$query" ]; then
  awk -v topkey="$query" '
    function trim(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      return s
    }

    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }

    substr($0, 1, length(topkey) + 1) == topkey ":" {
      value = substr($0, length(topkey) + 2)
      value = trim(value)
      if (value !~ /^"/) {
        sub(/\s*#.*$/, "", value)
        value = trim(value)
      }
      if (value ~ /^".*"$/) {
        sub(/^"/, "", value)
        sub(/"$/, "", value)
      }
      print value
      exit 0
    }
  ' "$cfg_file"
  exit 0
fi

if ! printf '%s' "$query" | grep -Eq '^[^.]+\.[^.]+$'; then
  echo "read_repo_settings.sh: query must be exactly one dot with non-empty section and key (e.g. project.stack): $query" >&2
  exit 1
fi

if [ -z "$key" ]; then
  echo "read_repo_settings.sh: invalid query (empty key segment): $query" >&2
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
