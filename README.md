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
2. Update `.template/project-config.yml` with your stack and commands.
3. Install Lefthook and run:

```bash
lefthook install
```

4. Push a feature branch and open a PR (or let auto-PR workflow create one).

## What to customize per project

- `.template/project-config.yml`:
  - `stack` (`js`, `php`, `flutter`, `custom`)
  - install/lint/test/build commands
  - `ci` toggles for lint/test/build jobs
  - optional `cache` settings for dependency cache path/key
- Branch protection rules in GitHub
- Optional remove `pr-automation.yml` if you do not want auto-created PRs
- Update `.github/CODEOWNERS` with your team/user
- Tune `.github/workflows/stale.yml` timing/labels if needed

## Required repository settings

- Settings -> Actions -> General:
  - Allow GitHub Actions
  - Workflow permissions: Read and write (required for `pr-automation.yml`)

## Included workflows

- `ci.yml`: governance checks + split lint/test/build jobs
- `pr-automation.yml`: auto-create PR from valid branch push
- `labeler.yml`: auto-label PR by changed files and branch type
- `stale.yml`: auto-mark/close stale issues and PRs

## Documentation

- `docs/naming-conventions.md` for branch/commit/PR title rules
- `docs/ci-devx-flow.md` for CI optimization and DevX flow design
  - includes ready-to-use Laravel and Next.js command examples
- `docs/linting-strategy.md` for universal + language-specific linting rules
  - includes guidance for Next.js, Laravel, Flutter, and Python
- `templates/lint/README.md` for copy-ready lint starter configs by stack

