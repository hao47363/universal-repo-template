# Universal Repo Template Docs

Reusable GitHub starter template for any language/runtime with:

- branch naming validation
- commit message validation
- PR title validation
- optional auto-create PR workflow
- config-driven lint/test/build checks
- optional dependency cache in CI
- PR labeling and stale management workflows
- CODEOWNERS and PR template governance
- local git hooks via Lefthook

This repository intentionally avoids owning root `README.md` and `CHANGELOG.md` so framework-generated project files can take priority in derived repositories.

## Start Here

- Root-safe framework bootstrap: `governance-pack/docs/operations/bootstrap-flow.md`
- CI behavior and checks: `governance-pack/docs/operations/ci-devx-flow.md`
- Configuration keys and defaults: `governance-pack/docs/reference/configuration-reference.md`

## Governance Docs

- Naming rules: `governance-pack/docs/governance/naming-conventions.md`
- Lint strategy: `governance-pack/docs/governance/linting-strategy.md`
- Code quality playbook: `governance-pack/docs/governance/code-quality-playbook.md`
- Changelog policy for projects: `governance-pack/docs/governance/changelog-guidelines.md`
- Release and versioning policy: `governance-pack/docs/governance/release-versioning.md`
- External best-practice report: `governance-pack/docs/governance/community-best-practices-report.md`
- Template changelog/history: `governance-pack/docs/governance/template-changelog.md`

## Structure Rules

- Keep repository root minimal and reserved for root-dependent files.
- Keep GitHub-native files inside `.github/`.
- Keep policy and process docs under `governance-pack/docs/`.
- Keep movable template assets under `governance-pack/` when possible.
