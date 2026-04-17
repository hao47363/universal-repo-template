# Changelog Guidelines

This template uses:

- [Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/)
- [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html)

## Rules

- Keep changelog entries human-readable and curated (not raw git logs).
- Maintain an `Unreleased` section at the top of `CHANGELOG.md`.
- Group entries under standard sections:
  - `Added`
  - `Changed`
  - `Deprecated`
  - `Removed`
  - `Fixed`
  - `Security`
- Use SemVer for releases:
  - MAJOR for incompatible changes
  - MINOR for backward-compatible features
  - PATCH for backward-compatible fixes

## Maintenance approach

- Update `CHANGELOG.md` manually during feature/fix work.
- Keep the top-level Keep a Changelog structure (`Unreleased` + sections) intact.
- Before a release, review and curate entries for clarity and user impact.

## Recommended release process

1. Keep adding notable changes under `Unreleased`.
2. At release time, create a new section with a SemVer tag and date.
3. Move finalized `Unreleased` notes into the release section.
4. Reset `Unreleased` sections for the next cycle.
