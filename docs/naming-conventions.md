# Naming conventions — branches and commits

This template enforces these rules via local hooks (Lefthook) and GitHub Actions.

## Commit messages

Format:

```text
<type>(<scope>): <short description>
```

Allowed `type`:

`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, `style`, `revert`

`scope` rules:

- lowercase letters and numbers
- may contain `.`, `_`, `-`

Examples:

```text
feat(auth): add login endpoint
fix(api): handle timeout retry
ci(workflows): add commit validation
```

## Branch names

Format:

```text
<type>/<short-description>
```

Allowed `type`:

`feature`, `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, `style`, `revert`

Exempt branches:

- `main`
- `develop`
- `dev`
- `staging`

Examples:

```text
feature/user-profile
fix/login-null-check
chore/update-ci
```

## Enforcement points

- `lefthook.yml`
  - `pre-commit` and `pre-push`: branch name
  - `commit-msg`: commit message format
- `.github/workflows/ci.yml`
  - branch validation
  - commit message validation
  - PR title validation
  - optional stack checks from `.template/project-config.yml`

## PR titles

Format:

```text
<type>(<scope>): <short description>
```

or:

```text
<type>: <short description>
```

Allowed `type`:

`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, `style`, `revert`

Examples:

```text
feat(auth): add oauth callback handling
docs: add setup guide
ci(workflows): split checks into lint/test/build jobs
```

