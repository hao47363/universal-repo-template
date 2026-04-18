# Bootstrap Flow (Root-Safe Framework Init)

> **Application teams:** do **not** rely on this flow to “turn on CI.” Wire your service to the central tooling repository with a thin GitHub Actions workflow and `.template/repo-settings.yml` as described in [Centralized CI setup](../central-ci-setup.md), [CI and DevX flow](./ci-devx-flow.md), and the [Central tooling README](../../github-ci/README.md).

Use this flow only when you **intentionally** scaffold framework files inside a repository that already contains governance assets (for example maintainers of this template, or a legacy migration), and you want framework files at repository root without breaking template workflows.

## Why this exists

Some framework generators expect an empty directory. This template contains governance files (`.github`, `.template`, `scripts/`, `templates/`, `lefthook.yml`, etc), which can conflict with direct root initialization.

`scripts/init_project.sh` solves this by:

- generating framework files in a temporary directory
- merging framework files into repository root
- preserving template governance/workflow files
- giving framework `README.md` and `CHANGELOG.md` higher priority

## Commands

Laravel:

```bash
sh ./scripts/init_project.sh laravel
```

Next.js:

```bash
sh ./scripts/init_project.sh nextjs
```

Flutter:

```bash
sh ./scripts/init_project.sh flutter
```

Python (custom command required):

```bash
sh ./scripts/init_project.sh python 'uv init "$INIT_TARGET_DIR"'
```

## Behavior and safety

- Keeps template-owned paths unchanged by default:
  - `.github/`
  - `.template/`
  - `scripts/` and `templates/`
  - `lefthook.yml`
  - `.editorconfig`
- Rewrites `.template/repo-settings.yml` `project.stack` to selected stack.

## Recommended next steps

1. Review generated files and adjust `.template/repo-settings.yml`.
2. Run `lefthook install`.
3. Run install/lint/test/build commands for your stack.
