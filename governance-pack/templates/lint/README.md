# Lint Starter Templates

Copy only the stack you use. Do not combine all lint configs in one project.

## Available presets

- Next.js: `governance-pack/templates/lint/nextjs/eslint.config.mjs`
- Laravel: `governance-pack/templates/lint/laravel/pint.json`
- Flutter: `governance-pack/templates/lint/flutter/analysis_options.yaml`
- Python: `governance-pack/templates/lint/python/pyproject.toml`

## Quick usage

- Next.js
  - Copy to project root as `eslint.config.mjs`
  - Install lint dependencies:
    - `npm i -D eslint @eslint/js globals typescript typescript-eslint`
  - Set lint command in `.template/repo-settings.yml`:
    - `lint: "npm run lint"`

- Laravel
  - Copy to project root as `pint.json`
  - Ensure Pint is installed:
    - `composer require --dev laravel/pint`
  - Set lint command:
    - `lint: "vendor/bin/pint --test"`

- Flutter
  - Copy to project root as `analysis_options.yaml`
  - Ensure `flutter_lints` is in `dev_dependencies`
  - Set lint command:
    - `lint: "flutter analyze"`

- Python
  - Copy to project root as `pyproject.toml` (or merge `[tool.ruff*]` sections)
  - Install Ruff:
    - `pip install ruff`
  - Set lint command:
    - `lint: "ruff check ."`
