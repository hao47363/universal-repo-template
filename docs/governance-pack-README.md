# Universal Repo Template Docs

> **Mirror:** The same content lives at the repository root in [`README.md`](../README.md) (GitHub’s default view). Update both files together when you change this overview.

A governance-first template system for framework projects that keeps application ownership at root while enforcing consistent engineering standards.

<!-- Optional badges (replace when needed)
[![CI](https://img.shields.io/github/actions/workflow/status/ORG/REPO/ci.yml?branch=main)](#)
[![Version](https://img.shields.io/badge/version-0.4.0-blue)](../CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](#)
-->

## Navigation

- [Quick start](#quick-start)
- [Setup modes](#setup-modes)
- [Stack behavior](#stack-behavior)
- [Who should use this](#who-should-use-this)
- [When not to use this](#when-not-to-use-this)
- [Documentation map](#documentation-map)
- [Required GitHub settings](#required-github-settings)
- [Structure policy](#structure-policy)
- [FAQ](#faq)

## What this includes

- Branch naming, commit message, and PR title validation
- Config-driven `install`/`lint`/`test`/`build` execution
- Optional PR automation, labeler, and stale management workflows
- Local git hooks with Lefthook
- Stack-aware command defaults for Laravel, Next.js, Flutter, and Python
- Structured governance docs, release policy, and quality playbook

This template ships a **default** root `README.md` and `CHANGELOG.md` so GitHub shows overview and release notes. After you run `init_project.sh`, the scaffold step copies the framework’s `README.md` and `CHANGELOG.md` from the generated project onto the repository root (replacing those files).

## At a glance

- **Framework ownership after init**: once scaffolded, application `README.md` and `CHANGELOG.md` come from your stack generator.
- **Governance by default**: CI, hooks, and conventions are ready out of the box.
- **Minimal root coupling**: template assets live at repository root (`scripts/`, `templates/`, `docs/`).
- **Stack-aware defaults**: Laravel, Next.js, Flutter, and Python supported.

## Quick start

1. Create a new repository from this template in GitHub.
2. Clone it locally.
3. Initialize your framework safely from template context:

```bash
sh ./scripts/init_project.sh <laravel|nextjs|flutter|python>
```

Examples:

```bash
sh ./scripts/init_project.sh laravel
sh ./scripts/init_project.sh nextjs
sh ./scripts/init_project.sh flutter
sh ./scripts/init_project.sh python "uv init \"$INIT_TARGET_DIR\""
```

4. Set stack and options in `.template/repo-settings.yml`.
5. Install hooks:

```bash
lefthook install
```

6. Push a feature branch and open a PR.

## Setup modes

- **Framework-first mode (recommended)**  
  Use `init_project.sh` to scaffold framework files without breaking governance assets.

- **Custom mode**  
  Set `project.stack: custom` and define all `commands.*` manually in `.template/repo-settings.yml`.

- **Preset mode**  
  Set stack to one of `laravel`, `nextjs`, `flutter`, `python` and leave `commands.*` empty to use built-in defaults.

## Stack behavior

- **`laravel`** defaults:
  - `install`: `composer install`
  - `lint`: `vendor/bin/pint --test`
  - `test`: `php artisan test`
  - `build`: empty
- **`nextjs`** defaults:
  - `install`: `npm ci`
  - `lint`: `npm run lint`
  - `test`: `npm test`
  - `build`: `npm run build`
- **`flutter`** defaults:
  - `install`: `flutter pub get`
  - `lint`: `flutter analyze`
  - `test`: `flutter test`
  - `build`: `flutter build apk`
- **`python`** defaults:
  - `install`: `pip install -r requirements.txt`
  - `lint`: `ruff check .`
  - `test`: `pytest -q`
  - `build`: empty

Any `commands.*` value you set manually overrides stack defaults.

## Who should use this

- Teams that want standardized Git workflow governance across multiple stacks
- Projects that need repeatable CI + naming + review discipline
- Repositories where framework/root files should remain owned by the app itself

## When not to use this

- Very small throwaway prototypes with no CI/governance needs
- Repos where full custom workflow logic replaces all template governance
- Teams that do not want enforced naming/commit/PR conventions

## Documentation map

- [Bootstrap and migration flow](./operations/bootstrap-flow.md)
- [CI and DevX flow](./operations/ci-devx-flow.md)
- [Configuration reference](./reference/configuration-reference.md)
- [Naming conventions](./governance/naming-conventions.md)
- [Linting strategy](./governance/linting-strategy.md)
- [Code quality playbook](./governance/code-quality-playbook.md)
- [Changelog guidelines](./governance/changelog-guidelines.md)
- [Release/versioning policy](./governance/release-versioning.md)
- [Community best-practice report](./governance/community-best-practices-report.md)
- [Template changelog](../CHANGELOG.md)

## Required GitHub settings

- Repository Actions enabled
- Workflow permissions aligned with enabled automations
- If using auto PR features, allow Actions to create pull requests

## Structure policy

- Keep root minimal and framework-owned where possible
- Keep GitHub-native files under `.github/`
- Keep template-owned docs/scripts/templates at repository root (`scripts/`, `templates/`, `docs/`).

## FAQ

### What happens to the root `README.md` after `init_project.sh`?

`init_project.sh` copies the framework’s `README.md` and `CHANGELOG.md` from the generated project into the repository root, replacing the template defaults so the app becomes the primary documentation.

### Can I still customize commands?

Yes. Set `project.stack` for defaults and override any `commands.*` key as needed.

### Does this support custom stacks?

Yes. Use `project.stack: custom` and define `commands.install`, `commands.lint`, `commands.test`, and `commands.build` explicitly.
