# Better Dev CI

Centralized **GitHub Actions** workflows, scripts, and governance docs so many application repositories can share one upgrade path. Application repos stay small: a thin caller workflow plus `.template/` configuration. They do **not** copy the full job graph from this repository.

> **Mirror:** The same overview lives at the repository root in [`README.md`](../README.md) (GitHub’s default view). Update both files when you change this document.

<!-- Optional badges (replace ORG/REPO and uncomment)
[![CI](https://img.shields.io/github/actions/workflow/status/ORG/REPO/ci.yml?branch=main)](https://github.com/ORG/REPO/actions)
[![Changelog](https://img.shields.io/badge/changelog-CHANGELOG-blue)](../CHANGELOG.md)
-->

---

## How it works

| Layer | Role |
| --- | --- |
| **This repository** | Source of truth for workflows under `.github/`, composites, `scripts/`, `templates/`, and `docs/`. |
| **[`github-ci/`](../github-ci/) mirror** | Publishable tree you push to a dedicated tooling repo on GitHub (for example `hao47363/better-dev-ci`). |
| **Each application repo** | Declares `uses: …/universal-ci.yml@<branch|tag|sha>` and adds `.template/repo-settings.yml`. |

Maintainers refresh the published repo from here with [`../scripts/sync-github-ci-mirror.sh`](../scripts/sync-github-ci-mirror.sh), then push to the integration branch (for example **`stable`**). Consumers usually pin that branch on `uses:` and `tooling_ref`; add **release tags** or **commit SHAs** when you want slower, explicit upgrades.

---

## What you get

- **Reusable universal CI** — [`universal-ci.yml`](../github-ci/.github/workflows/universal-ci.yml) plus composites such as `setup-governance-pack` and optional `setup-runtime`.
- **Governance in CI** — branch names, commit messages, and PR titles validated on GitHub.
- **Configurable pipelines** — `install` / `lint` / `test` / `build` driven by [`.template/repo-settings.yml`](../.template/repo-settings.yml) and [`scripts/run_project_checks.sh`](../scripts/run_project_checks.sh) when `use_project_commands: true`, or explicit commands from the caller when `use_project_commands: false`.
- **Stack presets** — sensible defaults for Laravel, Next.js, Flutter, and Python when command fields are left empty.
- **Copy-paste starters** — [`templates/consumer-quickstart/`](../templates/consumer-quickstart/README.md) provides ready-made `ci.yml` + `repo-settings.yml` pairs for common stacks.
- **Optional extras** — PR automation, labeler, stale workflows (thin callers can point at the same tooling repo); [Lefthook](../lefthook.yml) for optional local hooks (CI remains authoritative).
- **Documentation** — release policy, linting strategy, naming conventions, and operations guides under this [`docs/`](./) tree.

Root [`CHANGELOG.md`](../CHANGELOG.md) tracks this template and tooling. Each application keeps its own app-level `README.md` and changelog; those are unrelated to wiring central CI.

---

## Quick navigation

| I want to… | Start here |
| --- | --- |
| Wire a new app repo to central CI | [Set up CI on GitHub](#set-up-ci-on-github) |
| Copy a ready-made `ci.yml` + `repo-settings.yml` for my stack | [Copy-paste quick-starts](#5-copy-paste-quick-starts-laravel-nextjs-flutter-custom) |
| See workflow inputs and YAML knobs | [Configuration reference](./reference/configuration-reference.md) |
| Understand org settings and tokens | [Centralized CI setup](./central-ci-setup.md) · [Consumer guide](../github-ci/README.md) |
| Browse governance and ops docs | [Documentation map](#documentation-map) |

---

## Set up CI on GitHub

Examples assume the tooling repository is **`hao47363/better-dev-ci`**; if yours is different, replace **`hao47363`**, **`better-dev-ci`**, and the matching `tooling_repository` / `uses:` pins everywhere below.

### 1. Organization: allow reusable workflows

An organization owner (or admin) must allow application repositories to call workflows from the tooling repository.

1. Open the **organization** that owns your apps (not only the tooling repo).
2. **Settings** → **Actions** → **General**.
3. Under **Access**, adjust **Workflow permissions** / **Actions permissions** as your plan requires.
4. Under **Access to workflows**, allow member repositories to **use workflows from other repositories** (wording varies; on Enterprise Cloud you can allow the tooling repo explicitly).
5. Save. If you use fork-based PRs from outside collaborators, confirm policies still match your security model.

### 2. Tooling repository layout

The published repo (for example **`hao47363/better-dev-ci`**) must include on its **GitHub default branch** (this project uses **`stable`**) at least:

- `.github/workflows/universal-ci.yml`
- Composite actions under `.github/actions/`
- Repository root: `scripts/`, `templates/`, `docs/`

**In this monorepo**, edit the canonical paths at the repository root, run [`../scripts/sync-github-ci-mirror.sh`](../scripts/sync-github-ci-mirror.sh), then commit and push the updated **`github-ci/`** tree to that tooling remote so consumers see the same files.

**Cross-repo callers** that pin `uses: …@stable` and `tooling_ref: stable` always resolve composites and script checkouts to the **tip of `stable`**. Pin a **tag** or **full commit SHA** instead when you want upgrades to be explicit.

### 3. Application repository: enable Actions

1. Open the **application** repo → **Settings** → **Actions** → **General**.
2. Under **Actions permissions**, choose an option that still allows **reusable workflows** from your tooling repo (often “Allow all actions and reusable workflows” or the least privilege your policy permits).
3. Save.

### 4. Add a caller workflow

**Path:** `.github/workflows/ci.yml` (another name is fine; keep one job that `uses:` the reusable workflow unless you add more yourself.)

**Public tooling, default project commands** (`tooling_auth_mode: none`):

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
    uses: hao47363/better-dev-ci/.github/workflows/universal-ci.yml@stable
    with:
      tooling_repository: hao47363/better-dev-ci
      tooling_ref: stable
      tooling_auth_mode: none
    secrets: inherit
```

**Workflow inputs (summary)**

| Input | Purpose |
| --- | --- |
| `uses:` | Path to the reusable workflow on the **tooling** repo; **`@stable`** follows this repo’s integration branch (examples here use `stable`; use a **tag** or **`@<full_sha>`** to pin). |
| `tooling_repository` | Repo whose **`scripts/`** and **`templates/`** are cloned inside the composites when the app does not vendor them (almost always the **same** repo as the `uses:` workflow host). |
| `tooling_ref` | Branch, tag, or SHA on **`tooling_repository`** for that checkout (keep aligned with how you pin `universal-ci.yml`). Composite **`uses:`** lines in `universal-ci.yml` are fixed to **`hao47363/better-dev-ci/.../actions/...@stable`** because GitHub forbids `inputs` in `steps.uses`. |
| `tooling_auth_mode` | `none` if no PAT is needed; `pat` if the tooling repo is private (see below). |
| `secrets: inherit` | Passes secrets into the reusable workflow (needed when using `GH_CI_REPO_TOKEN`). |

**Cross-repo constraints (typical failures):**

- **`tooling_repository` must name the repo** that hosts root **`scripts/`** and **`templates/`** (and the same repo that publishes the composites on GitHub). A mirror without those trees will fail when the job runs.
- **`tooling_ref` must exist** on **`tooling_repository`**. If you pin `uses: …/universal-ci.yml@stable`, pass `tooling_ref: stable` (or the same SHA) so the **scripts/** checkout inside the composites matches the workflow pin.
- **Do not set `tooling_repository` to the application repo** unless you have copied `.github/actions/` and vendored `scripts/` there on purpose.
- GitHub evaluates **`uses: ./…` against the caller workspace before steps run**, so local `./.github/actions/…` cannot point into another repo. **`steps.*.uses` cannot reference `inputs`**, so `universal-ci.yml` loads **`setup-governance-pack`** / **`setup-runtime`** from a **literal** `hao47363/better-dev-ci/.../actions/...@stable`; forked tooling must replace those lines or vendor this workflow.

**Private tooling repo** — Create a PAT with **Contents: Read** scoped to the tooling repo. In the application repo, add secret **`GH_CI_REPO_TOKEN`**, then set:

```yaml
jobs:
  universal-ci:
    uses: hao47363/better-dev-ci/.github/workflows/universal-ci.yml@stable
    with:
      tooling_repository: hao47363/better-dev-ci
      tooling_ref: stable
      tooling_auth_mode: pat
    secrets: inherit
```

Push to the default branch or open a PR; the **Actions** tab should show a **CI** run.

### 5. Copy-paste quick-starts (Laravel, Next.js, Flutter, custom)

Under [`templates/consumer-quickstart/`](../templates/consumer-quickstart/README.md) there are **drop-in pairs** for application repositories:

- **`nextjs/`** — `runtime: node` in the workflow; empty **`commands.*`** use the **npm** stack preset (`npm ci`, `npm run lint`, …).
- **`laravel/`** — `runtime: php`; empty **`commands.*`** use **Composer / Pint / Artisan** presets.
- **`flutter/`** — `runtime: flutter`; empty **`commands.*`** use **Flutter** presets.
- **`custom/`** — `runtime: none`; **`commands.*`** are filled with **example npm lines** you should replace for your stack.

Copy each folder’s `.github/workflows/ci.yml` to **`.github/workflows/ci.yml`** and `.template/repo-settings.yml` to **`.template/repo-settings.yml`**. Keep **`uses:`** `@…` and **`tooling_ref`** on the **same branch name, tag, or SHA**. Swap **`hao47363/better-dev-ci`** if your tooling repo differs.

### 6. Project configuration

With **`use_project_commands: true`** (the default), the reusable workflow reads **`.template/repo-settings.yml`**. See [Configuration reference](./reference/configuration-reference.md).

Minimal example:

```yaml
project:
  stack: nextjs

commands:
  install: ""
  lint: ""
  test: ""
  build: ""
```

Empty `commands.*` values use [stack defaults](#stack-defaults). Override any step with your own shell command.

### 7. Verify

1. **Actions** shows the workflow.
2. A push or PR runs **Prepare**, governance validation, then **Lint** / **Test** / **Build** as configured.
3. Optional: run `lefthook install` locally for faster feedback before push.

**More detail:** [Centralized CI setup](./central-ci-setup.md) · [CI and DevX flow](./operations/ci-devx-flow.md) · [Central tooling README](../github-ci/README.md)

---

## What application repositories need

- One workflow under `.github/workflows/` that **`uses:`** the published `universal-ci.yml` (for example branch **`stable`**, a tag, or SHA).
- **`.template/repo-settings.yml`** for default project-command mode; **`.template/project-config.yml`** is an optional legacy fallback for missing keys.
- **Actions enabled**, and **`GH_CI_REPO_TOKEN`** when the tooling repo is private.

They **do not** need to copy this template’s full [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) graph unless you are developing or testing the reusable workflow in the same repo.

---

## Configuration modes

| Mode | Behavior |
| --- | --- |
| **`use_project_commands: true`** (default) | Commands from `.template/repo-settings.yml` (then `.template/project-config.yml` for missing keys), executed via `scripts/run_project_checks.sh`. Scripts and templates come from the app tree or from the tooling checkout (symlinked when absent). |
| **`use_project_commands: false`** | Caller passes `install_cmd`, `lint_cmd`, `test_cmd`, `build_cmd`, optional `runtime` / `runtime_version`, and optional `cache_*` inputs. |
| **`project.stack: custom`** | With project commands on, define every `commands.*` yourself in `repo-settings.yml`. |

---

## Stack defaults

When `commands.*` are empty and `project.stack` is set:

| Stack | install | lint | test | build |
| --- | --- | --- | --- | --- |
| **laravel** | `composer install` | `vendor/bin/pint --test` | `php artisan test` | *(none)* |
| **nextjs** | `npm ci` | `npm run lint` | `npm test` | `npm run build` |
| **flutter** | `flutter pub get` | `flutter analyze` | `flutter test` | `flutter build apk` |
| **python** | `pip install -r requirements.txt` | `ruff check .` | `pytest -q` | *(none)* |

Any non-empty `commands.*` overrides that step only.

---

## Who this is for

- Teams that want **one place to change** CI and governance across many services.
- Organizations using (or planning) a **central tooling repository** on GitHub.
- Repositories where the application owns its own product docs and layout at the root.

## When to skip it

- One-off prototypes with no shared CI.
- Policies that forbid calling external reusable workflows.
- Teams that do not want branch, commit, or PR title checks in CI.

---

## Documentation map

| Topic | Document |
| --- | --- |
| Org settings, pinning, tokens | [Centralized CI setup](./central-ci-setup.md) |
| Layout of `scripts/` and `templates/` | [CI tooling overview](./ci-tooling-overview.md) |
| Copy-paste `ci.yml` + `repo-settings.yml` pairs | [`../templates/consumer-quickstart/README.md`](../templates/consumer-quickstart/README.md) |
| Consumer-focused workflow examples | [Central tooling README](../github-ci/README.md) |
| Day-to-day CI and developer experience | [CI and DevX flow](./operations/ci-devx-flow.md) |
| All config keys | [Configuration reference](./reference/configuration-reference.md) |
| Optional framework bootstrap | [Bootstrap flow](./operations/bootstrap-flow.md) |
| Naming, linting, quality, releases | [Naming conventions](./governance/naming-conventions.md) · [Linting strategy](./governance/linting-strategy.md) · [Code quality playbook](./governance/code-quality-playbook.md) · [Changelog guidelines](./governance/changelog-guidelines.md) · [Release/versioning](./governance/release-versioning.md) |
| Community notes | [Best-practice report](./governance/community-best-practices-report.md) |
| Template release notes | [CHANGELOG.md](../CHANGELOG.md) |

---

## Required GitHub settings (checklist)

- **Actions** enabled on the tooling repo and on every application repo.
- **Reusable workflow access** from app repos to the tooling repo (organization setting).
- **Workflow permissions** sufficient for any optional automations (for example PR comments).
- **`GH_CI_REPO_TOKEN`** (or equivalent) when using `tooling_auth_mode: pat`.

---

## Repository roles

- **Tooling repository** — on GitHub, hosts reusable workflows, composites, `scripts/`, `templates/`, and `docs/`. **In this monorepo** those assets are authored at the **repository root**; the **`github-ci/`** directory is a **publishable mirror** produced by [`../scripts/sync-github-ci-mirror.sh`](../scripts/sync-github-ci-mirror.sh) (not a second source of truth).
- **Application repositories** — thin `uses:` workflow, `.template/repo-settings.yml`, and your product code; no obligation to duplicate the full template workflow set.

---

## FAQ

### Do we run `init_project.sh` for every new service?

**Not for CI.** New services connect GitHub with the thin caller and config above. [`init_project.sh`](../scripts/init_project.sh) is for optional [root-safe bootstrap](./operations/bootstrap-flow.md) when you generate a framework inside a repo that already contains governance files (typically template maintainers).

### How do we pin CI so upgrades are deliberate?

Pin `uses: …/universal-ci.yml@<full_commit_sha>` for immutability, stay on **`stable`** for continuous updates, or use **semver tags** only after review. See [Release/versioning](./governance/release-versioning.md) and [github-ci/README.md](../github-ci/README.md).

### Can we customize install, lint, test, and build?

**Yes.** Override keys in `.template/repo-settings.yml`, or set `use_project_commands: false` and pass shell commands from the caller workflow.

### What about custom stacks?

**Yes.** Use `project.stack: custom` with explicit `commands.*`, or explicit-command mode with your own shell strings.

### CI fails with “Can’t find `action.yml`” under my app repo path

Cross-repo reusable workflows treat **`uses: ./…`** as paths **inside the application repository**, and they are evaluated **before** steps run—so composites cannot be “checked out first” into a subfolder of the app workspace. **`universal-ci.yml`** loads **`setup-governance-pack`** / **`setup-runtime`** from a **literal** `hao47363/better-dev-ci/.../actions/...@stable` (GitHub forbids `inputs` in `steps.uses`). Pass **`tooling_repository`** and **`tooling_ref`** so the **scripts/** checkout inside those actions matches your tooling repo and pin. See [Centralized CI setup](./central-ci-setup.md#cross-repo-reusable-workflow-constraints).
