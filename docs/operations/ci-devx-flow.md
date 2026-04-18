# CI and DevX Flow

This template is designed to stay language-agnostic while improving feedback speed and governance quality.

**Consumer model:** application repositories call the **published** reusable workflow (for example `example-org/github-ci/.github/workflows/universal-ci.yml@v1`). They do **not** copy the full in-repo `ci.yml` graph from this monorepo. See [Centralized CI setup](../central-ci-setup.md) and the [Central tooling README](../../github-ci/README.md) for GitHub organization settings, secrets, thin caller YAML, and workflow examples.

## Prerequisites

- `lefthook` is the only non-default tool required by this template for local hook checks.
- Runtime/tooling for `install`, `lint`, `test`, `build` depends on the stack you choose in `.template/repo-settings.yml`.
- Without Lefthook installed, CI still enforces branch/commit/PR rules in GitHub Actions.

## Flow overview

1. `prepare` job reads `.template/repo-settings.yml` (with legacy fallback) and determines:
   - whether to run lint/test/build (`ci.run_*`)
   - whether optional cache should be restored (`cache.*`)
   - whether heavy checks are needed (`docs-only` changes skip heavy jobs)
2. `validate-governance` enforces:
   - branch naming
   - commit message format
   - PR title format
3. `lint`, `test`, and `build` run as separate jobs (if enabled).
4. `PR Intelligence` runs in its own workflow on `pull_request` lifecycle events and generates a deterministic `pr-report.md` artifact from `base...head` for every PR update (including docs-only changes).

## Why this improves DevX

- **Faster feedback**: independent jobs fail earlier and are easier to inspect.
- **Less CI waste**: docs-only updates skip heavy install/lint/test/build steps.
- **Safe defaults**: lint/test default to enabled, build defaults to disabled.
- **Portable setup**: command execution is configured in YAML, not hardcoded by language.
- **PR visibility**: every PR run emits a report with risk score, impact areas, and structural pattern detection.

## PR Intelligence behavior

- Script entrypoint: `bash ./scripts/generate_pr_report.sh pr-report.md`
- Stateless output: report is fully regenerated each run (overwrite semantics).
- PR lifecycle safe: compares base branch to current PR HEAD using a merge-base-aware range (`base...head`), so reruns/new commits/rebase/force-push still produce valid current-state output.
- Deterministic scoring: score and findings derive only from git diff metadata and file paths.
- Language agnostic: no language parsers or framework-specific services required.
- Generated artifact: `pr-report.md` is uploaded by CI as `pr-report-pr-<number>`.
- PR visibility: CI also creates/updates a single sticky PR comment containing the latest report (upsert by marker, no comment spam). If comment permission is restricted for the event context, artifact upload still succeeds.

## Project config reference

```yaml
stack: custom

commands:
  install: ""
  lint: ""
  test: ""
  build: ""

ci:
  run_lint: true
  run_test: true
  run_build: false

cache:
  enabled: false
  path: ""
  key: ""
  restore_keys: ""

pr_intelligence:
  enabled: true
  strict_mode: false
  hotspot_history_commits: 200
  hotspot_threshold: 6
  ignore_patterns: ""
```

### Command examples by stack

Laravel:

```yaml
stack: php

commands:
  install: "composer install"
  lint: "vendor/bin/pint --test"
  test: "php artisan test"
  build: ""
```

Next.js (npm):

```yaml
stack: js

commands:
  install: "npm ci"
  lint: "npm run lint"
  test: "npm test"
  build: "npm run build"
```

Next.js (pnpm):

```yaml
stack: js

commands:
  install: "pnpm i --frozen-lockfile"
  lint: "pnpm lint"
  test: "pnpm test"
  build: "pnpm build"
```

### Cache examples

Use values appropriate for your runtime/package manager:

- JavaScript (npm): `path: ~/.npm`
- Python (pip): `path: ~/.cache/pip`
- Java (Maven): `path: ~/.m2/repository`
- Rust (cargo): `path: ~/.cargo/registry`

Set a meaningful `key` that includes OS and lockfile hash when possible.

## Governance add-ons included

- `CODEOWNERS` for reviewer ownership
- `pull_request_template.md` for PR quality consistency
- `labeler.yml` workflow for auto-labeling by changed files and branch prefix
- `stale.yml` workflow for repository hygiene

## Related docs

- `docs/governance/naming-conventions.md`
- `docs/governance/linting-strategy.md`
- `docs/reference/configuration-reference.md`
- `docs/governance/changelog-guidelines.md`

## Recommended branch protection

- Require status checks from:
  - `Validate naming and commit/PR conventions`
  - `Lint` (if enabled)
  - `Test` (if enabled)
  - `Build` (if enabled)
  - `PR Intelligence Report` (if pull_request validation is required)
- Require pull request review(s)
- Require conversation resolution before merge
