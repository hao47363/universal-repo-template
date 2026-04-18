# Centralized CI setup

**Audience:** teams onboarding an **application** repository to shared CI. You add a thin workflow on GitHub that `uses:` the tooling repository’s `universal-ci.yml`; you do **not** duplicate this template’s entire workflow tree inside every app repo.

This repository ships **reusable workflows** under [`.github/workflows/`](../.github/workflows/) (`universal-*.yml`), the composite action [`.github/actions/setup-governance-pack/`](../.github/actions/setup-governance-pack/), and optional [`.github/actions/setup-runtime/`](../.github/actions/setup-runtime/) (Node, PHP, Flutter, Python) used by `universal-ci.yml` when you set a non-`none` **runtime** input.

The **setup-governance-pack** composite action:

1. Checks out the **calling** (application) repository.
2. Uses **vendored** root `scripts/` and `templates/` when `scripts/run_project_checks.sh` is already present.
3. Otherwise checks out the central tooling repository named by the `tooling_repository` input (for example `example-org/github-ci`), then symlinks `scripts/` and `templates/` from that checkout into the workspace.

## Where the “single update” lives

- **In this monorepo** — Edit `universal-*.yml`, the composite action, or root `scripts/`, `templates/`, and `docs/`, then run `./scripts/sync-github-ci-mirror.sh` to refresh the publishable mirror in [`github-ci/`](../github-ci/).
- **On GitHub** — Push the `github-ci/` mirror to your tooling repository (for example `example-org/github-ci`) and tag releases (`v1`, …). Application repositories pin `uses: …/universal-ci.yml@v1`.

Full operational steps, org settings, secrets, versioning, and consumer YAML snippets are documented in the [Central tooling README](../README.md).

## Call patterns

| Repository layout | `uses:` line |
| --- | --- |
| Same repo as the reusable files (this template) | `./.github/workflows/universal-ci.yml` (same commit as the caller; best for PR validation) |
| Minimal app repo with only thin workflows | `example-org/github-ci/.github/workflows/universal-ci.yml@v1` (or a commit SHA) |

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
    uses: example-org/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      use_project_commands: false
      tooling_repository: example-org/github-ci
      tooling_ref: v1
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

More detail, org access, secrets, and versioning live in the [Central tooling README](../README.md) (mirror directory; run `./scripts/sync-github-ci-mirror.sh` after changing canonical files under `.github/`, `scripts/`, `templates/`, or `docs/`).
