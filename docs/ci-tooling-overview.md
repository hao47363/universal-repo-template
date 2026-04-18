# CI tooling layout (root)

Template-owned automation lives at repository **root** so centralized GitHub Actions can symlink `scripts/` and `templates/` from the tooling repository into consumer workspaces.

## Contents

- **`scripts/`**: validation, config helpers, project checks, PR report generation, and `sync-github-ci-mirror.sh`
- **`templates/`**: optional starter templates (lint presets, etc.)
- **`docs/`**: governance playbooks, operations guides, and `central-ci-setup.md`

Other root files used by the template include:

- **`README.md`** and **`CHANGELOG.md`** — default overview and release notes (mirrored under `docs/governance-pack-README.md` and `docs/operations/tooling-changelog.md`; `init_project.sh` may replace the root pair with your framework’s files)
- `.github/` workflows and issue templates
- `.template/` configuration files
- `lefthook.yml`
- `.editorconfig`
