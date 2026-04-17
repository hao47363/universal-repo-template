# CI and DevX Flow

This template is designed to stay language-agnostic while improving feedback speed and governance quality.

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

## Why this improves DevX

- **Faster feedback**: independent jobs fail earlier and are easier to inspect.
- **Less CI waste**: docs-only updates skip heavy install/lint/test/build steps.
- **Safe defaults**: lint/test default to enabled, build defaults to disabled.
- **Portable setup**: command execution is configured in YAML, not hardcoded by language.

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

- `governance-pack/docs/governance/naming-conventions.md`
- `governance-pack/docs/governance/linting-strategy.md`
- `governance-pack/docs/reference/configuration-reference.md`
- `governance-pack/docs/governance/changelog-guidelines.md`

## Recommended branch protection

- Require status checks from:
  - `Validate naming and commit/PR conventions`
  - `Lint` (if enabled)
  - `Test` (if enabled)
  - `Build` (if enabled)
- Require pull request review(s)
- Require conversation resolution before merge
