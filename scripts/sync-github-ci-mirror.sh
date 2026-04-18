#!/usr/bin/env bash
# Syncs the publishable github-ci/ mirror from canonical sources in this repository.
# Run after changing scripts/, templates/, docs/, .github/actions/setup-governance-pack/,
# .github/actions/setup-runtime/, or universal-*.yml workflows.
#
# When this file lives at <monorepo>/scripts/, DEST is <monorepo>/github-ci/.
# When copied to a standalone tooling repo at <repo>/scripts/, DEST is <repo>/ (no nested github-ci/).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "${SCRIPT_DIR}/../github-ci" ]]; then
  ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
  DEST="${ROOT}/github-ci"
else
  ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
  DEST="${ROOT}"
fi

mkdir -p "${DEST}/.github/workflows" "${DEST}/.github/actions"

rsync -a --delete "${ROOT}/scripts/" "${DEST}/scripts/"
rsync -a --delete "${ROOT}/templates/" "${DEST}/templates/"
rsync -a --delete "${ROOT}/docs/" "${DEST}/docs/"
# Monorepo docs link to ../github-ci/README.md or ../../github-ci/README.md; in the
# publishable mirror, tooling README lives at repository root (../README.md).
if command -v perl >/dev/null 2>&1; then
  find "${DEST}/docs" -name '*.md' -type f -print0 | while IFS= read -r -d '' f; do
    perl -0pi -e 's#\]\(\.\./\.\./github-ci/README\.md\)#](../../README.md)#g; s#\]\(\.\./github-ci/README\.md\)#](../README.md)#g' "$f"
  done
fi
rsync -a --delete "${ROOT}/.github/actions/setup-governance-pack/" "${DEST}/.github/actions/setup-governance-pack/"
rsync -a --delete "${ROOT}/.github/actions/setup-runtime/" "${DEST}/.github/actions/setup-runtime/"

if [[ -f "${ROOT}/CHANGELOG.md" ]]; then
  cp "${ROOT}/CHANGELOG.md" "${DEST}/CHANGELOG.md"
elif [[ -f "${DEST}/CHANGELOG.md" ]]; then
  rm -f "${DEST}/CHANGELOG.md"
fi

workflow_names=(universal-ci.yml universal-pr-automation.yml universal-pr-intelligence.yml universal-stale.yml universal-labeler.yml)
for f in "${workflow_names[@]}"; do
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

if [[ -d "${DEST}/.github/workflows" ]]; then
  shopt -s nullglob
  for existing in "${DEST}/.github/workflows"/*.yml; do
    base="$(basename "$existing")"
    in_list=false
    has_src=false
    for f in "${workflow_names[@]}"; do
      if [[ "$base" == "$f" ]]; then
        in_list=true
        [[ -f "${ROOT}/.github/workflows/${f}" ]] && has_src=true
        break
      fi
    done
    if [[ "$in_list" == false ]] || [[ "$has_src" == false ]]; then
      rm -f "$existing"
    fi
  done
  shopt -u nullglob
fi

echo "Synced mirror to ${DEST}"
