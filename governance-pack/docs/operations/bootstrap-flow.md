# Bootstrap Flow (Root-Safe Framework Init)

Use this flow when creating a new project from this template and you want framework files at repository root without breaking template governance workflows.

## Why this exists

Some framework generators expect an empty directory. This template contains governance files (`.github`, `.template`, `governance-pack`, `lefthook.yml`, etc), which can conflict with direct root initialization.

`governance-pack/scripts/init_project.sh` solves this by:

- generating framework files in a temporary directory
- merging framework files into repository root
- preserving template governance/workflow files
- giving framework `README.md` and `CHANGELOG.md` higher priority

## Commands

Laravel:

```bash
sh ./governance-pack/scripts/init_project.sh laravel
```

Next.js:

```bash
sh ./governance-pack/scripts/init_project.sh nextjs
```

Flutter:

```bash
sh ./governance-pack/scripts/init_project.sh flutter
```

Python (custom command required):

```bash
sh ./governance-pack/scripts/init_project.sh python "uv init \"$INIT_TARGET_DIR\""
```

## Behavior and safety

- Keeps template-owned paths unchanged by default:
  - `.github/`
  - `.template/`
  - `governance-pack/`
  - `lefthook.yml`
  - `.editorconfig`
- Rewrites `.template/repo-settings.yml` `project.stack` to selected stack.

## Recommended next steps

1. Review generated files and adjust `.template/repo-settings.yml`.
2. Run `lefthook install`.
3. Run install/lint/test/build commands for your stack.
