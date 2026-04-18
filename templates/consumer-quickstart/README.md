# Consumer quick-start (copy into your app repository)

These folders are **examples only**: nothing here runs in the tooling repo. Copy the two paths into an **application** repository that calls `universal-ci` with `use_project_commands: true` (the default).

| Stack | Copy these files into your repo |
| --- | --- |
| **Next.js** (npm preset) | [`nextjs/.github/workflows/ci.yml`](nextjs/.github/workflows/ci.yml) → `.github/workflows/ci.yml`<br>[`nextjs/.template/repo-settings.yml`](nextjs/.template/repo-settings.yml) → `.template/repo-settings.yml` |
| **Laravel** | [`laravel/…`](laravel/) (same layout) |
| **Flutter** | [`flutter/…`](flutter/) |
| **Custom** | [`custom/…`](custom/) — you must set non-empty `commands.*` (no stack presets). |

## Before you copy

1. **Pin the same ref everywhere** — the `@stable` (or **tag** / **SHA**) on `uses: …/universal-ci.yml@…` must match **`tooling_ref`** (and exist on **`tooling_repository`**).
2. **Replace owner/repo** if your published tooling is not **`hao47363/better-dev-ci`**.
3. **Optional** — uncomment `runtime_version` in `ci.yml` to pin Node, PHP, or Flutter.
4. **pnpm / Yarn** — keep `stack: nextjs` but set `commands.install`, `commands.lint`, etc. in `repo-settings.yml` (presets assume **npm**).

## Private tooling repository

If the tooling repo is private, set `tooling_auth_mode: pat`, add **`GH_CI_REPO_TOKEN`** on the app repo, and use the same pattern as [README.md](../../README.md) (private tooling section).
