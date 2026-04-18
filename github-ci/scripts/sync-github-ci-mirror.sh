#!/usr/bin/env bash
# Syncs the publishable github-ci/ mirror from canonical sources in this repository.
# Run after changing scripts/, templates/, docs/, .github/actions/setup-governance-pack/,
# .github/actions/setup-runtime/, or universal-*.yml workflows.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${ROOT}/github-ci"

mkdir -p "${DEST}/.github/workflows" "${DEST}/.github/actions"

rsync -a --delete "${ROOT}/scripts/" "${DEST}/scripts/"
rsync -a --delete "${ROOT}/templates/" "${DEST}/templates/"
rsync -a --delete "${ROOT}/docs/" "${DEST}/docs/"
rsync -a --delete "${ROOT}/.github/actions/setup-governance-pack/" "${DEST}/.github/actions/setup-governance-pack/"
rsync -a --delete "${ROOT}/.github/actions/setup-runtime/" "${DEST}/.github/actions/setup-runtime/"

if [[ -f "${ROOT}/CHANGELOG.md" ]]; then
  cp "${ROOT}/CHANGELOG.md" "${DEST}/CHANGELOG.md"
fi

for f in universal-ci.yml universal-pr-automation.yml universal-pr-intelligence.yml universal-stale.yml universal-labeler.yml; do
  src="${ROOT}/.github/workflows/${f}"
  if [[ -f "$src" ]]; then
    cp "$src" "${DEST}/.github/workflows/${f}"
  elif [[ "$f" == "universal-ci.yml" ]]; then
    echo "error: required workflow missing: $src" >&2
    exit 1
  else
    echo "warning: skip missing workflow: $src" >&2
  fi
done

echo "Synced mirror to ${DEST}"
