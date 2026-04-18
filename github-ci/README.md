# Central CI tooling (`github-ci`)

This directory is a **publishable mirror** of reusable GitHub Actions assets: `universal-*.yml` workflows, `.github/actions/setup-governance-pack/`, `.github/actions/setup-runtime/`, root `scripts/`, `templates/`, and `docs/`. Application repositories delegate CI with a small caller workflow and pull updates from one place.

**Canonical edits** live in the `universal-repo-template` monorepo (root `.github/workflows/`, `.github/actions/`, `scripts/`, `templates/`, `docs/`). After changing those, run `./scripts/sync-github-ci-mirror.sh` at the template root, then commit the updated `github-ci/` tree and push to your **`Twiport/github-ci`** (or org equivalent) repository.

## Publish or refresh the GitHub repository

1. Create or reuse the GitHub repository (for example `Twiport/github-ci`).
2. Ensure the default branch root contains `.github/`, `scripts/`, `templates/`, `docs/`, and this `README.md`.
3. Enable **Actions** on the repository.
4. Tag a release for consumers, for example: `git tag -a v1 -m "Central CI v1"` and `git push origin v1`.

## Organization settings (private central repo)

1. Open **Organization → Settings → Actions → General**.
2. Under **Access**, allow member repositories to reuse workflows from this tooling repository (wording depends on your GitHub plan).
3. Confirm each application repository has **Actions** enabled.

## Authentication for the tooling checkout

Reusable workflows clone the **application** repository first. If `scripts/run_project_checks.sh` is **not** present in that tree, they clone this tooling repository into `.github-ci-tooling/` and symlink `scripts/` and `templates/` into the workspace.

| `tooling_auth_mode` (workflow input) | When to use | Secret |
| --- | --- | --- |
| `none` (default) | This repository is **public**, or your org policy allows the default `GITHUB_TOKEN` to read it. | None |
| `pat` | This repository is **private**. | Fine-grained or classic PAT with **Contents: Read** on this tooling repo only. Store as **`GH_CI_REPO_TOKEN`**. Callers should use `secrets: inherit` (or pass the secret explicitly). |

Optional at scale: mint short-lived tokens with a **GitHub App** installation instead of a long-lived PAT.

## Versioning policy

- **Floating tags** (`v1`) update every consumer that references the tag when you move it.
- **Immutable SHAs** — Pin `uses: …/universal-ci.yml@<full_sha>` for maximum stability; bump the SHA when you intentionally adopt changes.
- **Breaking changes** to inputs or job structure should move consumers to a new major tag (for example `v2`).

After any change to reusable YAML, composite actions, `scripts/`, `templates/`, or `docs/`, tag a new release (or move `v1` deliberately) and communicate the upgrade path to application teams.

## Default CI (project config)

Keep `on:` triggers in the application repository; delegate `jobs` to this repository. With **`use_project_commands: true`** (the default), commands come from `.template/project-config.yml` and `scripts/run_project_checks.sh` in the checked-out app (or vendored `scripts/` / `templates/` from this tooling repository).

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
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
    secrets: inherit
```

Use `tooling_auth_mode: pat` when this tooling repository is private and **`GH_CI_REPO_TOKEN`** is configured.

## Explicit commands (`use_project_commands: false`)

Set **`use_project_commands: false`** to pass **`install_cmd`**, **`lint_cmd`**, **`test_cmd`**, **`build_cmd`** from the caller. Use **`run_lint`**, **`run_test`**, **`run_build`** booleans to enable jobs (defaults match legacy: build off). Optional **`runtime`** / **`runtime_version`** activate [`.github/actions/setup-runtime`](.github/actions/setup-runtime/) (`none`, `node`, `php`, `flutter`, `python`). Optional **`cache_*`** inputs enable `actions/cache` restore in lint/test/build jobs.

Empty command strings skip that step with a log line (the job still succeeds).

### Next.js (Node)

```yaml
jobs:
  ci:
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      use_project_commands: false
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
      runtime: node
      runtime_version: "20"
      run_lint: true
      run_test: true
      run_build: true
      install_cmd: "npm ci"
      lint_cmd: "npm run lint"
      test_cmd: "npm test"
      build_cmd: "npm run build"
      cache_enabled: true
      cache_path: ~/.npm
      cache_key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
      cache_restore_keys: npm-${{ runner.os }}-
    secrets: inherit
```

### Laravel (PHP)

```yaml
jobs:
  ci:
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      use_project_commands: false
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
      runtime: php
      runtime_version: "8.3"
      run_lint: true
      run_test: true
      run_build: false
      install_cmd: "composer install --no-interaction --prefer-dist"
      lint_cmd: "vendor/bin/pint --test"
      test_cmd: "php artisan test"
      build_cmd: ""
    secrets: inherit
```

### Flutter

```yaml
jobs:
  ci:
    uses: Twiport/github-ci/.github/workflows/universal-ci.yml@v1
    with:
      use_project_commands: false
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
      runtime: flutter
      runtime_version: ""
      run_lint: true
      run_test: true
      run_build: true
      install_cmd: "flutter pub get"
      lint_cmd: "flutter analyze"
      test_cmd: "flutter test"
      build_cmd: "flutter build apk --debug"
    secrets: inherit
```

Set `runtime_version` to a Flutter SDK version string (for example `3.24.0`) to pin; leave empty for latest **stable** channel per `subosito/flutter-action`.

## Other reusable workflows

Point `uses:` at the matching file in this repository:

- `universal-pr-automation.yml` — auto-create pull requests on push
- `universal-pr-intelligence.yml` — PR report and comment
- `universal-stale.yml` — scheduled stale handling
- `universal-labeler.yml` — label pull requests

Copy the `on:` blocks from thin workflows in the template repository and replace local `uses: ./.github/workflows/...` with `uses: Twiport/github-ci/.github/workflows/...@<ref>`.

## Same-repository layout (`universal-repo-template`)

When reusable workflows live **in the same repository** as the application, callers may use a **local** reference so pull requests validate the branch version of the reusable workflow:

```yaml
jobs:
  universal-ci:
    uses: ./.github/workflows/universal-ci.yml
    with:
      tooling_repository: Twiport/github-ci
      tooling_ref: v1
      tooling_auth_mode: none
    secrets: inherit
```

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| Workflow reuse denied / not found | Org Actions access policy, wrong `uses:` path, or incorrect `@ref`. |
| 403 on second checkout | Private tooling without `tooling_auth_mode: pat` and `GH_CI_REPO_TOKEN`, or insufficient token scopes. |
| Stale governance behavior | Consumers pin an old `@ref`; bump tag or SHA after you publish changes. |
| Explicit command fails with confusing shell errors | Prefer short commands; avoid embedding large scripts in inputs (run a script file in the repo instead). Check quoting and use repo secrets via `secrets: inherit` and `env:` on the caller if needed. |
| Tooling overwrites your `scripts/` or `templates/` directory | The composite action symlinks those paths from the tooling repo when `scripts/run_project_checks.sh` is missing. Vendor the tooling files under those names, use `use_project_commands: false` with explicit commands, or rename your app-owned directories. |

## Permissions and plans

- Typical callers need **`permissions: contents: read`**.
- Reusable workflows from a **private** central repository into private app repos may require paid org features or explicit org policy; verify **Actions → General** for your billing tier.
- **`secrets: inherit`** passes caller secrets into the reusable workflow; map secrets explicitly if you do not want full inheritance.
