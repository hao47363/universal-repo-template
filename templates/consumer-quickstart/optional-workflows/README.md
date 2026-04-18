# Optional reusable workflows (thin callers)

These YAML files are **copy-paste starters** for app repositories that use `universal-ci.yml` for the main pipeline but still want **PR automation**, **stale**, **labeler**, and **PR intelligence** from the tooling repo.

Each file is a **thin caller**: triggers live in your app repo; the job `uses:` the matching reusable workflow on `stable`.

## Setup

1. Copy the YAML files you need into **`.github/workflows/`** in your app repo.
2. Ensure **`.github/labeler.yml`** exists (or copy from this repo’s template) if you use the labeler caller.
3. Tune flags in **`.github/repo-settings.yml`** (or your configured path). Defaults are **enabled** (`true`) unless you set them to `false`.

## Private tooling repository

If `hao47363/better-dev-ci` is private for your org, set on each job:

```yaml
with:
  tooling_auth_mode: pat
secrets: inherit
```

…and define **`GH_CI_REPO_TOKEN`** in repository secrets (read access to the tooling repo).
