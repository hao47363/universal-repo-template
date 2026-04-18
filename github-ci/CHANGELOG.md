# Changelog

> **Mirror:** The same changelog is kept under [`docs/operations/tooling-changelog.md`](docs/operations/tooling-changelog.md) for documentation deep links. Update **both** files when you add release notes.

All notable changes to this template are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

- Moved CI and governance assets from `governance-pack/` to repository root: `scripts/`, `templates/`, and `docs/` (governance content). Updated workflows, Lefthook, the `setup-governance-pack` composite action (symlinks `scripts/` and `templates/` from the tooling repo), and the `github-ci/` mirror sync accordingly.
- **Breaking for published `github-ci` consumers:** repositories that vendored `governance-pack/` must instead vendor root `scripts/` and `templates/` (or rely on the tooling checkout symlinks). Bump your consumer tag (for example `v2`) when you adopt this layout on the default branch.

### Deprecated

### Removed

### Fixed

### Security

## [0.4.1] - 2026-04-18

### Fixed

- Ensured `.github/workflows/ci.yml` always runs on `pull_request` events by removing top-level `pull_request.paths-ignore`, while keeping job-level heavy-check filters in place.
- Corrected numstat rename-path handling in `governance-pack/scripts/generate_pr_report.sh` so ignore and churn logic use the renamed destination path.
- Optimized hotspot detection in `governance-pack/scripts/generate_pr_report.sh` by aggregating file touch counts from one `git log --name-only` pass instead of per-file `git log` calls.
- Simplified redundant ignore and classification glob patterns in `governance-pack/scripts/generate_pr_report.sh`.

## [0.4.0] - 2026-04-17

### Added

- Added `governance-pack/scripts/generate_pr_report.sh` to generate deterministic `pr-report.md` from base-vs-head PR diff metadata.
- Added a pull-request-only `PR Intelligence Report` job in `.github/workflows/ci.yml` that uploads `pr-report.md` as an artifact.
- Added `pr_intelligence.*` configuration keys in `.template/repo-settings.yml` for feature toggle, strict mode, hotspot window, threshold, and ignore patterns.

### Changed

- Updated CI/DevX and configuration reference documentation to include PR Intelligence behavior, determinism guarantees, and configuration fields.
- Standardized changelog location to `governance-pack/CHANGELOG.md`.

### Fixed

- Ensured PR intelligence report generation remains stateless and resilient across reruns, new commits, rebases, and force-push updates.

## [0.3.0] - 2026-04-17

### Changed

- Moved all template docs from root `docs/` to `governance-pack/docs/`.
- Moved all script entrypoints from root `scripts/` to `governance-pack/scripts/`.
- Updated GitHub workflows and Lefthook commands to call `governance-pack/scripts/*` directly.
- Updated labeler path rules to track `governance-pack/docs/**` and `governance-pack/scripts/**`.
- Updated documentation links to point to `governance-pack/docs/**` and align with the strict root-clean structure.

### Removed

- Removed root folders `docs/`, `scripts/`, and `templates/` after migrating their template-owned contents to `governance-pack/`.

## [0.2.0] - 2026-04-17

### Added

- Added DRY principle guidance to `docs/governance/code-quality-playbook.md` with practical application notes and references.
- Added atomic component folder structure guidance (`atoms`/`molecules`/`organisms`/`templates`/`pages`) to `docs/governance/code-quality-playbook.md`.
- Added `scripts/init_project.sh` for root-safe framework initialization (`laravel`, `nextjs`, `flutter`, `python`) from template-generated repositories.
- Added `docs/operations/bootstrap-flow.md` with framework initialization and merge behavior guidance.
- Added `docs/governance/template-changelog.md` as the template-owned changelog location.
- Added `governance-pack/` as a container for movable template assets.

### Changed

- Replaced Reddit-based references in `docs/governance/community-best-practices-report.md` with Stack Overflow and engineering-reference sources.
- Updated template docs index wording for source-neutral phrasing.
- Added stack-based command presets so `project.stack` values (`nextjs`, `laravel`, `flutter`, `python`) resolve default install/lint/test/build commands when `commands.*` are empty.
- Updated template and reference docs to clarify that only `custom` requires manual `commands.*` configuration.
- Updated docs index with root-safe bootstrap workflow and explicit priority of framework `README.md`/`CHANGELOG.md`.
- Moved lint starter presets from `templates/lint/` to `governance-pack/templates/lint/` and updated references.
- Updated `scripts/init_project.sh` to preserve `governance-pack/` during framework scaffold merge.
- Moved script entrypoints fully into `governance-pack/scripts/` and updated workflows/hooks to use new paths.

### Removed

- Removed root template-owned `README.md` and `CHANGELOG.md` to allow framework-generated project files to own root documentation.

### Fixed

- Improved push commit validation range in `.github/workflows/ci.yml` to use merge-base with default branch, preventing false failures on new-branch pushes and force-push updates.

## [0.1.0] - 2026-04-17

### Added

- Added `docs/README.md` as a centralized documentation index with task-based navigation.
- Added governance documentation set under `docs/governance/`:
  - `naming-conventions.md`
  - `linting-strategy.md`
  - `changelog-guidelines.md`
  - `code-quality-playbook.md`
  - `release-versioning.md`
  - `community-best-practices-report.md`
- Added structured docs for operations/reference:
  - `docs/operations/ci-devx-flow.md`
  - `docs/reference/configuration-reference.md`
- Added code quality and review guidance (mandatory vs recommended rules, review checklist, exceptions policy).
- Added release/tagging policy for SemVer-based `vMAJOR.MINOR.PATCH` releases.
- Added community-backed best-practice report based on Stack Overflow and Reddit references.

### Changed

- Expanded naming conventions to include variable naming defaults (`camelCase`) and constant naming (`UPPER_SNAKE_CASE`), with JS/TS declaration guidance (`const`/`let`, no `var`).
- Reorganized docs to keep repository root clean and move policy/process docs into dedicated subfolders.

### Removed

- Removed legacy flat docs files from `docs/` after migration to structured folders:
  - `docs/naming-conventions.md`
  - `docs/linting-strategy.md`
  - `docs/changelog-guidelines.md`
  - `docs/ci-devx-flow.md`
  - `docs/configuration-reference.md`
