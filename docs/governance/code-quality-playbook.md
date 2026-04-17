# Code Quality Playbook

This playbook defines practical rules that improve readability, maintainability, and team consistency.

## Mandatory Rules

- Keep naming intention-revealing and consistent with language norms.
- Keep branch, commit, and PR title conventions valid.
- Run lint and tests in CI before merge.
- Avoid dead code and unused imports/variables.
- Keep PRs focused and reviewable (prefer small scope over broad mixed changes).

## Recommended Rules

- Prefer immutable declarations (`const`, `final`) when reassignment is not needed.
- Keep modules/functions focused on one responsibility.
- Reduce duplication by extracting shared logic.
- Prefer explicit, readable control flow (early returns where useful).
- Use comments sparingly; comment intent or non-obvious tradeoffs, not obvious code.

## Review Checklist

- Correctness: does behavior match the requirement?
- Risks: are edge cases and failure paths handled?
- Clarity: are names and structure easy to follow?
- Tests: is behavior verified or updated with tests?
- Maintainability: does this introduce unnecessary coupling or duplication?

## Exceptions Policy

You may deviate from style defaults when there is a clear reason, such as:

- hot-path performance considerations
- unavoidable framework constraints
- backward compatibility requirements

When deviating:

- keep deviation local
- add a brief rationale in code or PR description
- prefer measurable evidence for performance-based exceptions

## Anti-patterns to avoid

- cryptic variable names in non-trivial scope
- hidden side effects in function names that imply simple operations
- premature abstraction with no clear reuse or stability need
- large mixed-purpose PRs that combine unrelated refactors and behavior changes
