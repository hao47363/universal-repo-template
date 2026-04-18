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

Use these defaults across projects unless a language framework enforces a stricter rule:

- Variables and function parameters: `camelCase`
- Keep names descriptive and readable (avoid unclear short names like `x`, `tmp1`, `val2`)
- Constants: `UPPER_SNAKE_CASE`

Examples:

```text
userProfile
retryCount
MAX_RETRY_COUNT
API_TIMEOUT_MS
```

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
