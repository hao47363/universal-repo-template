# Better Dev CI

Centralized **GitHub Actions** workflows, scripts, and governance docs so many application repositories can share one upgrade path. Application repos stay small: a thin caller workflow plus `.template/` configuration. They do **not** copy the full job graph from this repository.

> The same overview lives in [`docs/governance-pack-README.md`](docs/governance-pack-README.md) for deep links. When you change this file, update that copy too.

<!-- Optional badges (replace ORG/REPO and uncomment)
[![CI](https://img.shields.io/github/actions/workflow/status/ORG/REPO/ci.yml?branch=main)](https://github.com/ORG/REPO/actions)
[![Changelog](https://img.shields.io/badge/changelog-CHANGELOG-blue)](./CHANGELOG.md)
-->

---

## How it works

| Layer | Role |
| --- | --- |
| **This repository** | Source of truth for workflows under `.github/`, composites, `scripts/`, `templates/`, and `docs/`. |
| **[`github-ci/`](github-ci/) mirror** | Publishable tree you push to a dedicated tooling repo on GitHub (for example `example-org/github-ci`). |
| **Each application repo** | Declares `uses: …/universal-ci.yml@<tag-or-sha>` and adds `.template/repo-settings.yml`. |

Maintainers refresh the published repo from here with [`scripts/sync-github-ci-mirror.sh`](scripts/sync-github-ci-mirror.sh), then tag releases (for example `v1`) for consumers to pin.

---

## What you get

- **Reusable universal CI** — [`universal-ci.yml`](github-ci/.github/workflows/universal-ci.yml) plus composites such as `setup-governance-pack` and optional `setup-runtime`.
- **Governance in CI** — branch names, commit messages, and PR titles validated on GitHub.
- **Configurable pipelines** — `install` / `lint` / `test` / `build` driven by [`.template/repo-settings.yml`](.template/repo-settings.yml) and [`scripts/run_project_checks.sh`](scripts/run_project_checks.sh) when `use_project_commands: true`, or explicit commands from the caller when `use_project_commands: false`.
- **Stack presets** — sensible defaults for Laravel, Next.js, Flutter, and Python when command fields are left empty.
- **Optional extras** — PR automation, labeler, stale workflows (thin callers can point at the same tooling repo); [Lefthook](lefthook.yml) for optional local hooks (CI remains authoritative).
- **Documentation** — release policy, linting strategy, naming conventions, and operations guides under [`docs/`](docs/).

Root [`CHANGELOG.md`](CHANGELOG.md) tracks this template and tooling. Each application keeps its own app-level `README.md` and changelog; those are unrelated to wiring central CI.

---

## Quick navigation

| I want to… | Start here |
| --- | --- |
| Wire a new app repo to central CI | [Set up CI on GitHub](#set-up-ci-on-github) |
| See workflow inputs and YAML knobs | [Configuration reference](docs/reference/configuration-reference.md) |
| Understand org settings and tokens | [Centralized CI setup](docs/central-ci-setup.md) · [Consumer guide](github-ci/README.md) |
| Browse governance and ops docs | [Documentation map](#documentation-map) |

---

## Set up CI on GitHub

Use a **placeholder** tooling repo name in the examples below: replace `example-org/github-ci` with your real **owner/repository** on GitHub.

### 1. Organization: allow reusable workflows

An organization owner (or admin) must allow application repositories to call workflows from the tooling repository.

1. Open the **organization** that owns your apps (not only the tooling repo).
2. **Settings** → **Actions** → **General**.
3. Under **Access**, adjust **Workflow permissions** / **Actions permissions** as your plan requires.
4. Under **Access to workflows**, allow member repositories to **use workflows from other repositories** (wording varies; on Enterprise Cloud you can allow the tooling repo explicitly).
5. Save. If you use fork-based PRs from outside collaborators, confirm policies still match your security model.

### 2. Tooling repository layout

The published repo (for example **`example-org/github-ci`**) must include on its default branch:

- `.github/workflows/universal-ci.yml`
- Composite actions under `.github/actions/`
- Repository root: `scripts/`, `templates/`, `docs/`

Tag a consumer reference after each reviewed release (`v1`, or a **full commit SHA** for immutability). Consumers pin `uses: …/universal-ci.yml@v1` or `@<sha>`.

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
    uses: example-org/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      tooling_repository: example-org/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
    secrets: inherit
```

**Workflow inputs (summary)**

| Input | Purpose |
| --- | --- |
| `uses:` | Path to the reusable workflow on the **tooling** repo; `@v1` is a tag (use `@<full_sha>` for a fixed revision). |
| `tooling_repository` | Repo that provides `scripts/` and `templates/` when they are not in the app checkout (usually the same as the workflow host). |
| `tooling_ref` | Branch or tag to check out for that tooling repo. |
| `tooling_auth_mode` | `none` if no PAT is needed; `pat` if the tooling repo is private (see below). |
| `secrets: inherit` | Passes secrets into the reusable workflow (needed when using `GH_CI_REPO_TOKEN`). |

**Private tooling repo** — Create a PAT with **Contents: Read** scoped to the tooling repo. In the application repo, add secret **`GH_CI_REPO_TOKEN`**, then set:

```yaml
jobs:
  universal-ci:
    uses: example-org/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      tooling_repository: example-org/github-ci
      tooling_ref: v1
      tooling_auth_mode: pat
    secrets: inherit
```

Push to the default branch or open a PR; the **Actions** tab should show a **CI** run.

### 5. Project configuration

With **`use_project_commands: true`** (the default), the reusable workflow reads **`.template/repo-settings.yml`**. See [Configuration reference](docs/reference/configuration-reference.md).

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

### 6. Verify

1. **Actions** shows the workflow.
2. A push or PR runs **Prepare**, governance validation, then **Lint** / **Test** / **Build** as configured.
3. Optional: run `lefthook install` locally for faster feedback before push.

**More detail:** [Centralized CI setup](docs/central-ci-setup.md) · [CI and DevX flow](docs/operations/ci-devx-flow.md) · [Central tooling README](github-ci/README.md)

---

## What application repositories need

- One workflow under `.github/workflows/` that **`uses:`** the published `universal-ci.yml` (tag or SHA).
- **`.template/repo-settings.yml`** for default project-command mode; **`.template/project-config.yml`** is an optional legacy fallback for missing keys.
- **Actions enabled**, and **`GH_CI_REPO_TOKEN`** when the tooling repo is private.

They **do not** need to copy this template’s full [`.github/workflows/ci.yml`](.github/workflows/ci.yml) graph unless you are developing or testing the reusable workflow in the same repo.

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
| Org settings, pinning, tokens | [Centralized CI setup](docs/central-ci-setup.md) |
| Layout of `scripts/` and `templates/` | [CI tooling overview](docs/ci-tooling-overview.md) |
| Consumer-focused workflow examples | [Central tooling README](github-ci/README.md) |
| Day-to-day CI and developer experience | [CI and DevX flow](docs/operations/ci-devx-flow.md) |
| All config keys | [Configuration reference](docs/reference/configuration-reference.md) |
| Optional framework bootstrap | [Bootstrap flow](docs/operations/bootstrap-flow.md) |
| Naming, linting, quality, releases | [Naming conventions](docs/governance/naming-conventions.md) · [Linting strategy](docs/governance/linting-strategy.md) · [Code quality playbook](docs/governance/code-quality-playbook.md) · [Changelog guidelines](docs/governance/changelog-guidelines.md) · [Release/versioning](docs/governance/release-versioning.md) |
| Community notes | [Best-practice report](docs/governance/community-best-practices-report.md) |
| Template release notes | [CHANGELOG.md](./CHANGELOG.md) |

---

## Required GitHub settings (checklist)

- **Actions** enabled on the tooling repo and on every application repo.
- **Reusable workflow access** from app repos to the tooling repo (organization setting).
- **Workflow permissions** sufficient for any optional automations (for example PR comments).
- **`GH_CI_REPO_TOKEN`** (or equivalent) when using `tooling_auth_mode: pat`.

---

## Repository roles

- **Tooling repository** — hosts reusable workflows, composites, `scripts/`, `templates/`, `docs/` (mirrored from `github-ci/` here).
- **Application repositories** — thin `uses:` workflow, `.template/repo-settings.yml`, and your product code; no obligation to duplicate the full template workflow set.

---

## FAQ

### Do we run `init_project.sh` for every new service?

**Not for CI.** New services connect GitHub with the thin caller and config above. [`init_project.sh`](scripts/init_project.sh) is for optional [root-safe bootstrap](docs/operations/bootstrap-flow.md) when you generate a framework inside a repo that already contains governance files (typically template maintainers).

### How do we pin CI so upgrades are deliberate?

Pin `uses: …/universal-ci.yml@<full_commit_sha>`, or move a floating tag like `v1` only after review. See [Release/versioning](docs/governance/release-versioning.md) and [github-ci/README.md](github-ci/README.md).

### Can we customize install, lint, test, and build?

**Yes.** Override keys in `.template/repo-settings.yml`, or set `use_project_commands: false` and pass shell commands from the caller workflow.

### What about custom stacks?

**Yes.** Use `project.stack: custom` with explicit `commands.*`, or explicit-command mode with your own shell strings.
