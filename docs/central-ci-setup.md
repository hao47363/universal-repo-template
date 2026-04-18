# Centralized CI setup

**Audience:** teams onboarding an **application** repository to shared CI. You add a thin workflow on GitHub that `uses:` the tooling repository’s `universal-ci.yml`; you do **not** duplicate this template’s entire workflow tree inside every app repo.

This repository ships **reusable workflows** under [`.github/workflows/`](../.github/workflows/) (`universal-*.yml`), the composite action [`.github/actions/setup-governance-pack/`](../.github/actions/setup-governance-pack/), and optional [`.github/actions/setup-runtime/`](../.github/actions/setup-runtime/) (Node, PHP, Flutter, Python) used by `universal-ci.yml` when you set a non-`none` **runtime** input.

The **setup-governance-pack** composite action:

1. Checks out the **calling** (application) repository.
2. Uses **vendored** root `scripts/` and `templates/` when `scripts/run_project_checks.sh` is already present.
3. Otherwise checks out the central tooling repository named by the `tooling_repository` input (for example `hao47363/better-dev-ci`), then symlinks `scripts/` and `templates/` from that checkout into the workspace.

## Where the “single update” lives

- **In this monorepo** — Edit `universal-*.yml`, the composite action, or root `scripts/`, `templates/`, and `docs/`, then run `./scripts/sync-github-ci-mirror.sh` to refresh the publishable mirror in [`github-ci/`](../github-ci/).
- **On GitHub** — Push the `github-ci/` mirror to your tooling repository (for example `hao47363/better-dev-ci`). Application repositories typically pin the **`stable`** branch on `uses:` and `tooling_ref`; add **release tags** or **commit SHAs** when you want explicit, slower-moving pins.

Full operational steps, org settings, secrets, versioning, and consumer YAML snippets are documented in the [Central tooling README](../github-ci/README.md).

## Call patterns

| Repository layout | `uses:` line |
| --- | --- |
| Same repo as the reusable files (this template) | `./.github/workflows/universal-ci.yml` (same commit as the caller; best for PR validation) |
| Minimal app repo with only thin workflows | `hao47363/better-dev-ci/.github/workflows/universal-ci.yml@stable` (or a tag / commit SHA) |

## Cross-repo reusable workflow constraints

When the application repository calls `uses: <tooling>/.github/workflows/universal-ci.yml@<ref>`:

1. **Composites are loaded from `tooling_repository` @ `tooling_ref`.**  
   GitHub resolves **`uses: ./…` only inside the caller repository** and **before** job steps run, so `universal-ci.yml` must reference `setup-governance-pack` and `setup-runtime` as **`owner/repo/.github/actions/<name>@ref`** (built from the same `tooling_repository` / `tooling_ref` inputs used to clone `scripts/` and `templates/`). A “checkout tooling into the workspace, then `uses: ./subdir/...`” pattern does **not** work for another repo’s composites.

2. **`tooling_repository` must be the repo that actually contains** `.github/actions/setup-governance-pack`, `.github/actions/setup-runtime`, and (unless you vendor them in the app) root `scripts/` and `templates/`. Usually this is **identical** to the repository in the workflow `uses:` line.

3. **`tooling_ref` must exist** on that repository (branch, tag, or full SHA). Keep it consistent with how you pin `universal-ci.yml` so composites and workflow YAML stay in lockstep.

4. **Same-repository testing** (caller uses `./.github/workflows/universal-ci.yml` in this monorepo): pass `tooling_repository` and `tooling_ref` explicitly (for example the current repository and branch/SHA) so they are not confused with documentation placeholders.

## Explicit commands (language-agnostic)

By default, `universal-ci.yml` uses **`use_project_commands: true`**: install/lint/test/build run through [`scripts/run_project_checks.sh`](../scripts/run_project_checks.sh). Configuration is read from **`.template/repo-settings.yml`** first; **`.template/project-config.yml`** is still supported as a legacy fallback when a key is not found in repo settings.

Set **`use_project_commands: false`** to pass your own shell commands and optional **runtime** / **cache** inputs from the caller repo. The reusable workflow only orchestrates checkout, governance checks, path filters, optional runtime setup, cache restore, and `bash -eo pipefail -c "$CMD"`—no stack-specific commands are required in the central YAML.

### Thin caller example (Next.js-style)

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

permissions:
  contents: read

jobs:
  ci:
    uses: hao47363/better-dev-ci/.github/workflows/universal-ci.yml@stable
    with:
      use_project_commands: false
      tooling_repository: hao47363/better-dev-ci
      tooling_ref: stable
      tooling_auth_mode: none
      runtime: node
      runtime_version: "20"
      run_lint: true
      run_test: true
      run_build: true
      install_cmd: "npm ci"
      lint_cmd: "npm run lint"
      test_cmd: "npm test"
      build_cmd: "npm run build"
      cache_enabled: true
      cache_path: ~/.npm
      cache_key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
      cache_restore_keys: npm-${{ runner.os }}-
    secrets: inherit
```

### Laravel (PHP)

Use `runtime: php`, `runtime_version` such as `8.3`, and caller-owned commands, for example `composer install`, `vendor/bin/pint --test`, `php artisan test`.

### Flutter

Use `runtime: flutter`, optional `runtime_version` (SDK version; leave empty for latest stable channel), and commands such as `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.

More detail, org access, secrets, and versioning live in the [Central tooling README](../github-ci/README.md) (mirror directory; run `./scripts/sync-github-ci-mirror.sh` after changing canonical files under `.github/`, `scripts/`, `templates/`, or `docs/`).
