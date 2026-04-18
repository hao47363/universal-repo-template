# CI tooling layout (root)

Template-owned automation lives at repository **root** so centralized GitHub Actions can symlink `scripts/` and `templates/` from the tooling repository into consumer workspaces.

## Contents

- **`scripts/`**: validation, config helpers, project checks, PR report generation, and `sync-github-ci-mirror.sh`
- **`templates/`**: optional starter templates (lint presets, etc.)
- **`docs/`**: governance playbooks, operations guides, and `central-ci-setup.md`

Other root files used by the template include:

- **`README.md`** and **`CHANGELOG.md`** — overview and release notes for this template and tooling (mirrored under `docs/governance-pack-README.md` and `docs/operations/tooling-changelog.md`). Application repositories keep their own root docs; optional `init_project.sh` is only for [root-safe bootstrap](./operations/bootstrap-flow.md) inside a repo that already has governance files.
- `.github/` workflows and issue templates
- `.template/` configuration files
- `lefthook.yml`
- `.editorconfig`
