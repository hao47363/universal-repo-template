# Release and Versioning Policy

This repository follows Semantic Versioning and tag-based releases.

## Why tags are required

- Tags provide immutable release points.
- They improve rollback safety and auditability.
- They allow CI/CD to deploy only reviewed release snapshots.

## Versioning format

- Use `vMAJOR.MINOR.PATCH` (example: `v1.4.2`).
- Follow SemVer meaning:
  - MAJOR: incompatible changes
  - MINOR: backward-compatible features
  - PATCH: backward-compatible fixes

## Minimum release checklist

- Merge approved changes into `main`.
- Ensure CI is green.
- Curate and finalize `CHANGELOG.md` entries.
- Create and push release tag (`vX.Y.Z`).
- Publish GitHub Release notes linked to the tag.

## Recommended operational checks

- Keep release scope focused and documented.
- Avoid mixing large refactors with release-critical fixes.
- Include rollback notes when a release has operational risk.
