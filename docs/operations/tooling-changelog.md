# Changelog

> **Mirror:** The same changelog lives at the repository root in [`CHANGELOG.md`](../../CHANGELOG.md). Update **both** files when you add release notes (or edit the root file and copy it here).

All notable changes to this template are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Reusable **`universal-pr-automation.yml`**, **`universal-stale.yml`**, **`universal-labeler.yml`**, and **`universal-pr-intelligence.yml`**, each reading repo-settings flags with **defaults on** (`automation.auto_pr_enabled`, `automation.stale_enabled`, `automation.labeler_enabled`, `pr_intelligence.enabled`), plus thin caller YAML under **`templates/consumer-quickstart/optional-workflows/`**.
- **`automation.labeler_enabled`** in **`.template/repo-settings.yml`** (default `true`); **`universal-labeler.yml`** skips label steps when set to `false`.
- `templates/consumer-quickstart/{nextjs,laravel,flutter,custom}/` — copy-paste **`.github/workflows/ci.yml`** + **`.template/repo-settings.yml`** pairs for application repos using default project commands (`use_project_commands: true`).
- `universal-ci` **Validate tooling inputs** step (non-empty `tooling_repository` / `tooling_ref`, `owner/repo` shape, reject `..` / stray slashes) so misconfiguration fails with a clear message before composite download.

### Changed

- `templates/consumer-quickstart/{nextjs,laravel,flutter,custom}/.template/repo-settings.yml` now include **`governance`**, **`automation`** (including **`labeler_enabled`**), and **`pr_intelligence`** with the same defaults as the root **`.template/repo-settings.yml`**, plus a short pointer to **`optional-workflows/`**.
- Documentation: clarify **repository root** vs **`github-ci/`** publishable mirror; expand tooling layout §2, [CI tooling overview](../ci-tooling-overview.md), [configuration reference](../reference/configuration-reference.md) (`universal-ci` inputs), and documentation maps with consumer quick-start links.
- Docs and `templates/consumer-quickstart/`: consumer examples pin **`@stable`** / `tooling_ref: stable` as the integration branch; release tags and commit SHAs remain optional for slower upgrades.
- `tooling_repository` / `tooling_ref` defaults in `universal-ci.yml` and `setup-governance-pack` now use **`hao47363/better-dev-ci`** and **`stable`** (maintainer default; production callers should still pass explicit values matching their published tooling repo and pin).
- README, `docs/governance-pack-README.md`, and `docs/central-ci-setup.md`: document cross-repo composite constraints and `tooling_repository` requirements.

### Deprecated

### Removed

### Fixed

- Cross-repo callers: GitHub **rejects** `inputs.*` inside **`steps.*.uses`** when parsing the called reusable workflow (`Unrecognized named-value: 'inputs'`). `universal-ci` now references **`hao47363/better-dev-ci/.github/actions/setup-governance-pack@stable`** and **`.../setup-runtime@stable`** as literal composite locations; **`tooling_repository`** / **`tooling_ref`** still configure the tooling checkout **inside** those composites.

### Security

## [0.5.1] - 2026-04-18

### Fixed

- Cross-repo `universal-ci` callers: `uses: ./.github/actions/…` is evaluated against the **caller** repository and **before** job steps run, so neither the original paths nor a “checkout tooling then `./.gha-better-dev-ci-pack/…`” sequence could supply `action.yml` on the runner. `setup-governance-pack` and `setup-runtime` are now referenced with `${{ format('{0}/.github/actions/<name>@{1}', inputs.tooling_repository, inputs.tooling_ref) }}` so GitHub loads those composites from the tooling repository (the same `inputs` used for the `scripts/` / `templates/` checkout inside the composite).

### Changed

- README and governance-facing Markdown: clearer onboarding, neutral `hao47363/better-dev-ci` examples, and mirrored copies kept in sync (`docs/governance-pack-README.md`, `docs/central-ci-setup.md`, `docs/operations/ci-devx-flow.md`, `github-ci/README.md`).

## [0.5.0] - 2026-04-18

### Added

- Fail-fast PAT validation in `.github/actions/setup-governance-pack` when `tooling_auth_mode` is `pat` and `tooling_token` is empty.
- Runtime input validation in `.github/actions/setup-runtime` before Node, PHP, Flutter, or Python setup steps.
- Multiline-safe `GITHUB_OUTPUT` writes for `cache_path`, `cache_key`, and `cache_restore_keys` in `.github/workflows/universal-ci.yml` and `.github/workflows/ci.yml`.

### Changed

- Moved CI and governance assets from `governance-pack/` to repository root: `scripts/`, `templates/`, and `docs/` (governance content). Updated workflows, Lefthook, the `setup-governance-pack` composite action (symlinks `scripts/` and `templates/` from the tooling repo), and the `github-ci/` mirror sync accordingly.
- **Breaking for published `github-ci` consumers:** repositories that vendored `governance-pack/` must instead vendor root `scripts/` and `templates/` (or rely on the tooling checkout symlinks). Bump your consumer tag (for example `v2`) when you adopt this layout on the default branch.
- Tooling checkout now removes existing `scripts/` and `templates/` paths in the workspace before creating symlinks, avoiding nested symlinks when those names already existed as directories.
- Pinned `actions/setup-node`, `shivammathur/setup-php`, `subosito/flutter-action`, and `actions/setup-python` in `setup-runtime` to explicit commit SHAs (tag equivalents noted in comments).
- `scripts/get_config_value.sh` exits non-zero with a clear error when `read_repo_settings.sh` or `read_project_config.sh` fails instead of swallowing errors.
- `scripts/run_project_checks.sh` returns machine-readable `enabled` results for lint, test, and build when neither `.template/repo-settings.yml` nor `.template/project-config.yml` exists.
- `scripts/validate_pr_title.sh` accepts Title Case words and acronym-style tokens (two or more uppercase letters, optional trailing digits, e.g. `API`) within each slash segment.
- `scripts/init_project.sh` accepts git worktrees (`.git` as a file), passes `INIT_TARGET_DIR` into custom init commands, and documents Python bootstrap with quoting so the variable is not expanded by the caller shell.
- `scripts/sync-github-ci-mirror.sh` selects mirror `ROOT`/`DEST` for monorepo versus standalone tooling layouts, syncs or removes `CHANGELOG.md` in the mirror, and prunes stale universal workflow files under `github-ci/.github/workflows/`.
- `templates/lint/nextjs/eslint.config.mjs` uses `tseslint.config()`, applies type-checked rules to `*.{ts,tsx}` only, and disables type-checked rules for JavaScript file patterns.
- Workflows invoke `sh ./scripts/run_project_checks.sh` for install, lint, test, and build to avoid relying on the executable bit.
- Documentation for central CI, README, bootstrap, and naming conventions now reflects `.template/repo-settings.yml` first with `.template/project-config.yml` as a legacy fallback where applicable.

### Fixed

- `scripts/generate_pr_report.sh` verifies the merge base before hotspot `git log` aggregation and uses an empty hotspot counts file when the base revision is not resolvable, so report generation does not abort under `set -e`.

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
