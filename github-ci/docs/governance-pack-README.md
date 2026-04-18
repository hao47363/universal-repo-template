# Universal Repo Template Docs

> **Mirror:** The same content lives at the repository root in [`README.md`](../README.md) (GitHub’s default view). Update both files together when you change this overview.

A governance-first template system for framework projects. **Application repositories do not vendor full CI from this tree.** They enable GitHub Actions by calling the **published central tooling** (for example `Twiport/github-ci`) with a thin workflow and configuration under `.template/`.

<!-- Optional badges (replace when needed)
[![CI](https://img.shields.io/github/actions/workflow/status/ORG/REPO/ci.yml?branch=main)](#)
[![Version](https://img.shields.io/badge/version-0.5.0-blue)](../CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](#)
-->

## Navigation

- [Set up CI on GitHub](#set-up-ci-on-github)
- [What application repositories need](#what-application-repositories-need)
- [Configuration modes](#configuration-modes)
- [Stack defaults](#stack-defaults)
- [Who should use this](#who-should-use-this)
- [When not to use this](#when-not-to-use-this)
- [Documentation map](#documentation-map)
- [Required GitHub settings](#required-github-settings)
- [Structure policy](#structure-policy)
- [FAQ](#faq)

## What this includes

- **Central reusable CI** — `universal-ci.yml`, governance composites (`setup-governance-pack`, optional `setup-runtime`), and shared `scripts/` / `templates/` / `docs/`, published from the [`github-ci/`](../github-ci/) mirror to a tooling repository (for example `Twiport/github-ci`).
- Branch naming, commit message, and PR title validation (in CI).
- Config-driven `install` / `lint` / `test` / `build` via `scripts/run_project_checks.sh` when `use_project_commands: true`, or explicit caller commands when `use_project_commands: false`.
- Optional PR automation, labeler, and stale workflows (reference the tooling repo or copy thin callers as needed).
- Optional local git hooks with Lefthook (CI remains the source of truth on GitHub).
- Stack-aware defaults for Laravel, Next.js, Flutter, and Python when using project commands.
- Structured governance docs, release policy, and quality playbook.

This monorepo’s root `README.md` and `CHANGELOG.md` describe the **template and tooling**. Your application’s own `README.md` / `CHANGELOG.md` live in that service’s repository and are unrelated to central CI wiring.

## Set up CI on GitHub

Follow these steps **for each application repository** that should run central CI. Replace `Twiport/github-ci` with your org and repository name if different.

### 1. Allow reusable workflows (organization)

Someone with **organization owner** (or equivalent admin) access must allow app repos to call the tooling workflows.

1. On GitHub, open the **organization** that owns your application repositories (not the tooling repo alone).
2. Go to **Settings** → **Actions** → **General**.
3. Under **Access**, find **Workflow permissions** / **Fork pull request workflows** / **Actions permissions** as applicable to your plan.
4. Under **Access to workflows**, choose that repositories in the org may **use workflows from other repositories** (wording varies; on Enterprise Cloud you may set **Allow** for the tooling repository explicitly).
5. Save. If your org uses **fork-based PRs** from outside collaborators, confirm fork PR policies still match your security model.

### 2. Confirm the tooling repository

The central repo (for example **`Twiport/github-ci`**) must expose reusable workflows on its default branch and carry the mirrored tree: `.github/workflows/universal-ci.yml`, composite actions under `.github/actions/`, and root `scripts/`, `templates/`, `docs/`.

- **Tag a consumer ref** (for example `v1`) after each reviewed release so apps can pin `…/universal-ci.yml@v1` or a **full commit SHA** for immutability.
- Maintainers of this monorepo refresh that repository from here with [`../scripts/sync-github-ci-mirror.sh`](../scripts/sync-github-ci-mirror.sh), then push and tag on GitHub.

### 3. Enable Actions on the application repository

1. Open the **application** repository on GitHub.
2. Go to **Settings** → **Actions** → **General**.
3. Under **Actions permissions**, select **Allow all actions and reusable workflows** (or the least privilege option your policy allows that still permits **reusable workflows** from your tooling repo).
4. Save.

### 4. Add `ci.yml` under `.github/workflows/`

In the **application** repository (local clone or GitHub web editor), create the workflow file:

**Path:** `.github/workflows/ci.yml`  
(You may use another name such as `universal-ci.yml`; keep a single entry workflow that only `uses:` the reusable workflow unless you add more jobs yourself.)

**Minimal example (public tooling, default project commands):**

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
  universal-ci:
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
    secrets: inherit
```

**What each field does:**

| Input | Purpose |
| --- | --- |
| `uses:` | Calls the published reusable workflow; `@v1` is a tag on the **tooling** repo (pin `@<sha>` for stricter control). |
| `tooling_repository` | Repository that holds `scripts/` and `templates/` when they are not already in the app checkout (usually the same as the workflow host). |
| `tooling_ref` | Branch or tag checked out for that tooling repository (must contain the expected files). |
| `tooling_auth_mode` | `none` when the tooling repo is readable without a PAT; `pat` when it is private (see below). |
| `secrets: inherit` | Passes repository/organization secrets into the reusable workflow (required when using `GH_CI_REPO_TOKEN`). |

**Private tooling repository** — Create a fine-grained or classic PAT with **Contents: Read** on the tooling repo only. In the application repo, add a secret named **`GH_CI_REPO_TOKEN`**. Then use:

```yaml
jobs:
  universal-ci:
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: pat
    secrets: inherit
```

Commit and push `.github/workflows/ci.yml` to the default branch (or open a PR); the **Actions** tab should show a **CI** run triggered by `push` or `pull_request`.

### 5. Add project configuration in the application repo

With the default **`use_project_commands: true`** (omit `use_project_commands` or set it to `true`), the reusable workflow reads **`.template/repo-settings.yml`** in the application repository (see [Configuration reference](./reference/configuration-reference.md)).

**Minimal example** at `.template/repo-settings.yml`:

```yaml
project:
  stack: nextjs

commands:
  install: ""
  lint: ""
  test: ""
  build: ""
```

Leave `commands.*` empty to use stack defaults (see [Stack defaults](#stack-defaults)), or set explicit shell commands. Commit this file on the same branch as your workflow so CI sees it on checkout.

### 6. Verify

1. Open **Actions** in the application repository and confirm the **CI** workflow appears.
2. Push a small commit or open a pull request; confirm jobs such as **Prepare**, **Validate naming…**, and **Lint** / **Test** run as expected.
3. Optional: run `lefthook install` locally for branch/commit checks before push.

**Deeper reference:** [Centralized CI setup](./central-ci-setup.md) · [CI and DevX flow](./operations/ci-devx-flow.md) · [Central tooling README](../README.md) · [Configuration reference](./reference/configuration-reference.md)

## What application repositories need

- A workflow file under `.github/workflows/` that **`uses:`** the published `universal-ci.yml` (tag or SHA).
- **`.template/repo-settings.yml`** when using default project commands (primary config); **`.template/project-config.yml`** is optional legacy fallback for missing keys.
- **Actions enabled** and, for private tooling, the **`GH_CI_REPO_TOKEN`** secret where required.

They **do not** need to copy this template’s full `.github/workflows/ci.yml` graph into the app repo unless you choose same-repo validation while developing the reusable workflow itself.

## Configuration modes

- **`use_project_commands: true` (default in reusable workflow)**  
  Commands come from `.template/repo-settings.yml` (then legacy `.template/project-config.yml`) via `scripts/run_project_checks.sh`, using scripts/templates from the app checkout or symlinked from the tooling repo.

- **`use_project_commands: false`**  
  Pass `install_cmd`, `lint_cmd`, `test_cmd`, `build_cmd`, optional `runtime` / `runtime_version`, and optional `cache_*` inputs from the thin caller. No stack logic is required inside the central YAML.

- **`project.stack: custom`** (project-command mode)  
  Define all `commands.*` explicitly in `.template/repo-settings.yml`.

## Stack defaults

When `commands.*` are empty and a stack is set, defaults apply:

- **`laravel`**: `composer install` · `vendor/bin/pint --test` · `php artisan test` · build empty
- **`nextjs`**: `npm ci` · `npm run lint` · `npm test` · `npm run build`
- **`flutter`**: `flutter pub get` · `flutter analyze` · `flutter test` · `flutter build apk`
- **`python`**: `pip install -r requirements.txt` · `ruff check .` · `pytest -q` · build empty

Any `commands.*` you set overrides the preset for that step.

## Who should use this

- Teams that want **one place to upgrade** CI and governance across many services
- Organizations that already use (or plan) a **central `github-ci` repository**
- Repositories where the application owns its own root docs and code layout

## When not to use this

- Very small prototypes with no shared CI requirement
- Repositories that must not call external reusable workflows
- Teams that do not want enforced naming, commit, or PR title rules in CI

## Documentation map

- [Centralized CI setup](./central-ci-setup.md)
- [CI tooling layout (root)](./ci-tooling-overview.md)
- [Central tooling README (consumer guide)](../README.md)
- [CI and DevX flow](./operations/ci-devx-flow.md)
- [Configuration reference](./reference/configuration-reference.md)
- [Bootstrap flow](./operations/bootstrap-flow.md) (optional; template or legacy root-safe init only)
- [Naming conventions](./governance/naming-conventions.md)
- [Linting strategy](./governance/linting-strategy.md)
- [Code quality playbook](./governance/code-quality-playbook.md)
- [Changelog guidelines](./governance/changelog-guidelines.md)
- [Release/versioning policy](./governance/release-versioning.md)
- [Community best-practice report](./governance/community-best-practices-report.md)
- [Template changelog](../CHANGELOG.md)

## Required GitHub settings

- Repository **Actions** enabled on every application and on the tooling repository
- **Reusable workflow access** from app repos to the tooling repo (org setting)
- Workflow **permissions** aligned with any automations you enable (for example PR comment upserts)
- If using **private** tooling: **`GH_CI_REPO_TOKEN`** (or equivalent) available to the caller workflow

## Structure policy

- **Tooling repository (`github-ci`)** — hosts reusable workflows, composites, `scripts/`, `templates/`, `docs/` (mirrored from this template).
- **Application repositories** — minimal `.github/workflows/` (thin `uses:`), `.template/repo-settings.yml`, and the application source tree; no requirement to duplicate this template’s full workflow set.

## FAQ

### Do we still run `init_project.sh` for every new service?

**No** for CI. New services wire **GitHub** with a thin caller and config as in [Set up CI on GitHub](#set-up-ci-on-github). `init_project.sh` remains documented for [root-safe framework bootstrap](./operations/bootstrap-flow.md) when you intentionally generate a framework **inside** a repo that already holds governance files (for example maintainers of this template).

### How do we pin CI so merges do not surprise us?

Pin `uses: …/universal-ci.yml@<full_commit_sha>` instead of a floating tag, or control updates by moving a `v1` tag only after review. See [Release/versioning policy](./governance/release-versioning.md) and [Central tooling README](../README.md).

### Can we still customize install/lint/test/build?

**Yes.** Either override keys in `.template/repo-settings.yml` (project-command mode) or set `use_project_commands: false` and pass shell commands from the caller workflow.

### Does this support custom stacks?

**Yes.** Use `project.stack: custom` with explicit `commands.*`, or explicit-command mode with your own shell strings.
