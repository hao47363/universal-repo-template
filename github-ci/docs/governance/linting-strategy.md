# Universal Linting Strategy

This template supports multiple languages by separating rules into two layers:

1. Universal rules that are safe for every repository.
2. Language-specific rules that run only for the selected stack.

This avoids invalid cross-language rules (for example, suggesting JavaScript `const` patterns inside PHP code).

## Layer 1: Universal rules

Use `.editorconfig` for shared formatting and readability defaults:

- UTF-8, LF line endings, final newline
- trim trailing whitespace (except markdown)
- default indentation: 2 spaces
- language overrides:
  - Python: 4 spaces
  - PHP: 4 spaces

Use governance rules already in this template for:

- branch naming
- commit message format
- PR title format

## Layer 2: Language-specific linting

Define lint commands in `.template/repo-settings.yml` so each project only runs applicable linters.

### Next.js (JavaScript/TypeScript)

Recommended lint command:

```yaml
commands:
  lint: "npm run lint"
```

Recommended style rules (ESLint/TypeScript):

- use `const` by default; use `let` only when reassignment is required
- disallow `var`
- camelCase for variables/functions
- PascalCase for React components/types/classes
- UPPER_SNAKE_CASE only for module-level true constants
- enforce no-unused-vars and consistent imports
- prefer small reusable functions to reduce duplication (DRY)

### Laravel (PHP)

Recommended lint command:

```yaml
commands:
  lint: "vendor/bin/pint --test"
```

Recommended style rules (Pint/PHPCS + PHPStan optionally):

- PSR-12 formatting (4-space indentation)
- camelCase for variables/methods
- PascalCase for classes/interfaces/traits
- UPPER_SNAKE_CASE for global constants
- avoid duplicated query/business logic; move shared logic to services/actions
- optional static analysis (`phpstan`) for stronger type safety

### Flutter (Dart)

Recommended lint command:

```yaml
commands:
  lint: "flutter analyze"
```

Recommended style rules (Dart lints):

- 2-space indentation
- lowerCamelCase for variables/functions
- UpperCamelCase for classes/widgets/types
- lowercase_with_underscores for file names
- prefer `final` and `const` where possible
- keep widgets small/composable to improve readability and DRY

Note: Dart commonly uses lowerCamelCase for constant identifiers; do not force UPPER_SNAKE_CASE as a universal Dart rule.

### Python

Recommended lint command:

```yaml
commands:
  lint: "ruff check ."
```

Recommended style rules (Ruff/Flake8 + Black optionally):

- PEP 8 formatting (4-space indentation)
- snake_case for variables/functions/modules
- PascalCase for classes
- UPPER_SNAKE_CASE for constants
- avoid mutable globals and duplicated logic
- optional formatter (`black .`) for consistent style

## Suggested lint command presets

Use one stack-specific command set per project:

- Next.js (npm): `npm run lint`
- Next.js (pnpm): `pnpm lint`
- Laravel: `vendor/bin/pint --test`
- Flutter: `flutter analyze`
- Python: `ruff check .`

## Starter lint config templates

This repository includes copy-ready starter files:

- `templates/lint/nextjs/eslint.config.mjs`
- `templates/lint/laravel/pint.json`
- `templates/lint/flutter/analysis_options.yaml`
- `templates/lint/python/pyproject.toml`

Usage instructions are in `templates/lint/README.md`.

## Practical quality guardrails

- Keep rules strict enough to prevent common bugs.
- Prefer readable naming over short cryptic names.
- Enforce no dead code and no unused imports/variables.
- Prefer immutable declarations where language supports it.
- Centralize repeated logic into reusable functions/services/widgets/modules.
