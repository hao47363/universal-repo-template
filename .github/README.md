# Universal Repo Template

This repository provides reusable governance and automation for projects across different stacks while keeping framework ownership of root project files.

Included capabilities:

- Branch naming validation
- Commit message validation
- PR title validation
- Config-driven lint/test/build checks
- Optional PR automation, labeling, and stale management
- Local hook support via Lefthook
- Stack-aware defaults for Laravel, Next.js, Flutter, and Python

For full documentation and setup details, see:

- [`governance-pack/docs/README.md`](../governance-pack/docs/README.md)

Once your framework creates a root `README.md`, GitHub will prioritize that README automatically.
