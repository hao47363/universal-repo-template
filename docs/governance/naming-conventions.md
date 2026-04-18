# Naming conventions — branches, commits, and code identifiers

This template enforces governance rules via local hooks (Lefthook) and GitHub Actions.

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
- `stable`
- `develop`
- `dev`
- `staging`

Examples:

```text
feature/user-profile
fix/login-null-check
chore/update-ci
```

## PR titles

Format:

```text
Title Case words, optionally slash-separated
```

Examples:

```text
Feature/Add Changelog
Fix/Login Null Check
Docs/Setup Guide
```

## Variable naming

Follow **language-native** naming for each stack (and any stricter framework rules). Examples:

- **JavaScript / TypeScript:** `camelCase` for variables and parameters; `UPPER_SNAKE_CASE` for module-level constants is common.
- **Python:** `snake_case` for variables and functions; `UPPER_SNAKE_CASE` for constants.
- **Go / Rust / others:** use idiomatic names for that ecosystem (e.g. Go exported identifiers, Rust `snake_case` / `SCREAMING_SNAKE_CASE`).

Keep names descriptive and readable (avoid unclear short names like `x`, `tmp1`, `val2`).

## Declaration style (JS/TS only)

For JavaScript and TypeScript:

- Do not use `var`
- Prefer `const` by default
- Use `let` only when reassignment is needed

Examples:

```text
const apiBaseUrl = process.env.API_BASE_URL;
let retryCount = 0;
const MAX_RETRY_COUNT = 3;
```

## Enforcement points

- `lefthook.yml`
  - `pre-commit` and `pre-push`: branch name
  - `commit-msg`: commit message format
- `.github/workflows/ci.yml`
  - branch validation
  - commit message validation
  - PR title validation
  - optional stack checks from `.template/repo-settings.yml` (legacy fallback supported)
