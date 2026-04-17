# Community Best Practices Report

This report summarizes practical conventions commonly supported in engineering references and developer communities, then maps them to this template.

## Sources consulted

- Stack Overflow:
  - [Thoughts on variable/function naming conventions](https://stackoverflow.com/questions/1505880/thoughts-on-variable-function-naming-conventions)
  - [Picking good identifier names](https://stackoverflow.com/questions/841888/picking-good-identifier-names)
  - [What is readable code? What are the best practices to follow while naming variables?](https://stackoverflow.com/questions/454178/what-is-readable-code-what-are-the-best-practices-to-follow-while-naming-variab)
  - [What is the naming convention in Python for variables and functions?](https://stackoverflow.com/questions/159720/what-is-the-naming-convention-in-python-for-variables-and-functions)
- Additional references:
  - [Martin Fowler: Avoiding Repetition](https://www.martinfowler.com/ieeeSoftware/repetition.pdf)
  - [Atomic Design by Brad Frost](https://bradfrost.com/blog/post/atomic-web-design/)
  - [Atomic Design methodology (book site)](https://atomicdesign.bradfrost.com/chapter-2/%E3%80%80)

## Majority-supported conventions

- Use descriptive, intention-revealing names.
- Follow language-native style conventions rather than forcing one naming style globally.
- Keep team conventions consistent and automate enforcement with linters/formatters.
- Prefer principles over rigid arbitrary limits (for example, avoid fixed class line-count rules).
- Keep code review focused on correctness, risk, maintainability, and tests (not formatting nits).
- Balance clean structure with performance needs; optimize with evidence where it matters.
- Structure reusable UI components with clear boundaries (for example Atomic Design layers: atoms, molecules, organisms, templates, pages).

## Practical template rules to adopt

- Keep formatting and linting automated in CI.
- Keep naming and governance conventions explicit and versioned in docs.
- Prefer immutable declarations where language supports it.
- Keep PR scope small and logically focused.
- Add release tags and changelog discipline for traceability.
- For component-heavy frontends, keep a predictable folder hierarchy and ownership boundaries for reusable UI.

## What not to over-enforce

- Do not enforce JS-specific declarations in non-JS languages.
- Do not force universal casing styles that conflict with language ecosystems.
- Do not use arbitrary size thresholds as hard blockers without context.

## Recommended rollout order

1. Finalize docs and references.
2. Keep linter rules aligned with each language stack.
3. Add review checklist usage in PR template.
4. Apply gradually to avoid large migration friction.
