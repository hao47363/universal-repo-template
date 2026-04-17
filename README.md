# Universal Repo Template

Reusable GitHub starter template for any language/runtime with:

- Branch naming validation
- Commit message validation
- PR title validation
- Optional auto-create PR workflow
- Config-driven lint/test/build checks (with CI toggles)
- Optional dependency cache in CI
- PR labeling and stale management workflows
- CODEOWNERS and PR template for governance
- Local git hooks via Lefthook

## Prerequisites

- `git` and a POSIX shell (`sh`/`bash`) should already be available in most dev environments.
- `lefthook` is the only extra tool you need to explicitly install for local hook enforcement.
- Install runtime/package-manager dependencies based on your project stack (for example `node`/`npm` or `php`/`composer`).
- If Lefthook is not installed, local hooks will not run, but CI in GitHub Actions still enforces rules.

## Quick start

1. Create a new repository from this template in GitHub.
2. Update `.template/repo-settings.yml` with your stack and commands.
3. Install Lefthook and run:

```bash
lefthook install
```

4. Push a feature branch and open a PR (or let auto-PR workflow create one).

## What to customize per project

- `.template/repo-settings.yml` (primary centralized config):
  - `stack` (`js`, `php`, `flutter`, `custom`)
  - install/lint/test/build commands
  - `ci` toggles for lint/test/build jobs
  - optional `cache` settings for dependency cache path/key
  - governance and automation settings (branch/commit/PR/stale)
- `.template/project-config.yml` (optional legacy fallback for backward compatibility)
- Branch protection rules in GitHub
- Optional remove `pr-automation.yml` if you do not want auto-created PRs
- Update `.github/CODEOWNERS` with your team/user
- Tune `.github/workflows/stale.yml` timing/labels if needed

## Required repository settings

- Settings -> Actions -> General:
  - Allow GitHub Actions
  - Workflow permissions: Read and write (required for `pr-automation.yml`)
  - Allow GitHub Actions to create and approve pull requests

## Included workflows

- `ci.yml`: governance checks + split lint/test/build jobs
- `pr-automation.yml`: auto-create PR from valid branch push
- `labeler.yml`: auto-label PR by changed files and branch type
- `stale.yml`: auto-mark/close stale issues and PRs

## Documentation

- `docs/README.md` for full docs navigation
- `docs/governance/naming-conventions.md` for branch/commit/PR title and variable naming rules
- `docs/operations/ci-devx-flow.md` for CI optimization and DevX flow design
  - includes ready-to-use Laravel and Next.js command examples
- `docs/governance/linting-strategy.md` for universal + language-specific linting rules
  - includes guidance for Next.js, Laravel, Flutter, and Python
- `templates/lint/README.md` for copy-ready lint starter configs by stack
- `docs/reference/configuration-reference.md` for required/optional/default values of each setting
- `docs/governance/changelog-guidelines.md` for Keep a Changelog + SemVer release rules
- `docs/governance/release-versioning.md` for release tags and versioning policy
- `docs/governance/code-quality-playbook.md` for mandatory/recommended quality rules and review checklist
- `docs/governance/community-best-practices-report.md` for Stack Overflow/Reddit-informed recommendations

