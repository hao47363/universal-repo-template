# Configuration Reference

The template now uses a centralized config file:

- Primary: `.template/repo-settings.yml`
- Legacy fallback: `.template/project-config.yml` (optional)

When both files define the same key, `.template/repo-settings.yml` takes precedence.

## GitHub Actions: `universal-ci.yml` (workflow inputs)

Application repositories call the reusable workflow with `workflow_call` inputs defined in [`.github/workflows/universal-ci.yml`](../../.github/workflows/universal-ci.yml). Common fields:

| Input | Purpose |
| --- | --- |
| `tooling_repository` | `owner/repo` whose root **`scripts/`** and **`templates/`** are cloned inside the composites when the app does not vendor them — almost always the **same** repo as in the `uses:` URL. |
| `tooling_ref` | Branch, tag, or SHA on **`tooling_repository`** for that checkout; **must match** the ref on `uses: …/universal-ci.yml@…` so scripts align with the workflow you pinned. Composite **`uses:`** in `universal-ci.yml` are **literal** `hao47363/better-dev-ci/.../actions/...@stable` (GitHub forbids `inputs` in `steps.uses`). Defaults to **`stable`** in this template. |
| `tooling_auth_mode` | `none` or `pat` (requires `GH_CI_REPO_TOKEN` on the caller). |
| `use_project_commands` | Default `true`: run [`scripts/run_project_checks.sh`](../../scripts/run_project_checks.sh) using `.template/repo-settings.yml`. Set `false` to supply `install_cmd`, `lint_cmd`, `test_cmd`, `build_cmd`, and related flags. |
| `runtime` / `runtime_version` | Optional environment before commands: `none`, `node`, `php`, `flutter`, `python`. |

The **Prepare** job’s first step validates `tooling_repository` and `tooling_ref` (non-empty, `owner/repo` shape, rejects path traversal). For YAML examples and private-tooling PAT setup, see the [Central tooling README](../../github-ci/README.md).

## Field reference

### `project.stack`

- Required: no
- Default: `custom`
- Description: Stack selector used to determine default commands when `commands.*` are empty.
- Supported values: `nextjs`, `laravel`, `flutter`, `python`, `custom` (aliases `js` -> `nextjs`, `php` -> `laravel` are also supported).

### `commands.install`

- Required: no
- Default: Stack preset command for `nextjs`/`laravel`/`flutter`/`python`, otherwise `""` for `custom`.
- Description: Dependency installation command run in CI/local checks. Overrides stack default when set.

### `commands.lint`

- Required: no
- Default: Stack preset command for `nextjs`/`laravel`/`flutter`/`python`, otherwise `""` for `custom`.
- Description: Lint command for your selected stack. Overrides stack default when set.

### `commands.test`

- Required: no
- Default: Stack preset command for `nextjs`/`laravel`/`flutter`/`python`, otherwise `""` for `custom`.
- Description: Test command for your selected stack. Overrides stack default when set.

### `commands.build`

- Required: no
- Default: Stack preset command for `nextjs`/`laravel`/`flutter`/`python` (where available), otherwise `""` for `custom`.
- Description: Build command for your selected stack. Overrides stack default when set.

### `ci.run_lint`

- Required: no
- Default: `true`
- Description: Controls whether lint job runs in CI.

### `ci.run_test`

- Required: no
- Default: `true`
- Description: Controls whether test job runs in CI.

### `ci.run_build`

- Required: no
- Default: `false`
- Description: Controls whether build job runs in CI.

### `cache.enabled`

- Required: no
- Default: `false`
- Description: Enables dependency cache restore in CI jobs.

### `cache.path`

- Required: no
- Default: `""`
- Description: Cache path for your package manager.

### `cache.key`

- Required: no
- Default: `""`
- Description: Cache key expression value.

### `cache.restore_keys`

- Required: no
- Default: `""`
- Description: Optional restore keys prefix list/value.

### `governance.exempt_branches`

- Required: no
- Default: `main,develop,staging,dev`
- Description: Comma-separated branch names exempt from branch-format checks.

### `governance.branch_types`

- Required: no
- Default: `feature,feat,fix,chore,docs,refactor,test,perf,ci,build,style,revert`
- Description: Comma-separated allowed branch prefixes for `<type>/<name>`.

### `governance.conventional_types`

- Required: no
- Default: `feat,fix,chore,docs,refactor,test,perf,ci,build,style,revert`
- Description: Comma-separated allowed Conventional Commit types.

### `automation.auto_pr_enabled`

- Required: no
- Default: `true`
- Description: Enables/disables automatic PR creation workflow logic.

### `automation.auto_pr_base_branch`

- Required: no
- Default: `main`
- Description: Base branch target for auto-created PRs.

### `automation.stale_enabled`

- Required: no
- Default: `true`
- Description: Enables/disables stale issue/PR automation behavior.

### `automation.stale_days_before_stale`

- Required: no
- Default: `30`
- Description: Inactivity days before marking stale.

### `automation.stale_days_before_close`

- Required: no
- Default: `14`
- Description: Days after stale before auto-close.

### `automation.stale_exempt_issue_labels`

- Required: no
- Default: `pinned,security,never-stale`
- Description: Comma-separated issue labels exempt from stale handling.

### `automation.stale_exempt_pr_labels`

- Required: no
- Default: `pinned,security,never-stale`
- Description: Comma-separated PR labels exempt from stale handling.

### `pr_intelligence.enabled`

- Required: no
- Default: `true`
- Description: Enables/disables PR report generation on pull request CI runs.

### `pr_intelligence.strict_mode`

- Required: no
- Default: `false`
- Description: If `true`, fail the report job when diff generation cannot be resolved; otherwise emit fallback output and continue.

### `pr_intelligence.hotspot_history_commits`

- Required: no
- Default: `200`
- Description: Number of base-branch commits scanned for hotspot frequency checks.

### `pr_intelligence.hotspot_threshold`

- Required: no
- Default: `6`
- Description: Minimum prior touches in the hotspot history window to classify a changed file as a hotspot.

### `pr_intelligence.ignore_patterns`

- Required: no
- Default: `""`
- Description: Comma-separated shell glob patterns to exclude additional files from analysis.

## Notes

- Values are treated as strings by shell scripts; use `true`/`false` for toggles.
- For comma-separated fields, avoid spaces to reduce parsing ambiguity.
