---
description: Review code changes for correctness, quality, and adherence to standards
---

Review the current diff or specified files across all quality dimensions.

## Scope

- Args specify files or a PR number -> review those
- No args -> review `git diff HEAD` (staged and unstaged changes)

## Dimensions

Review each independently:

1. **Correctness (bugs)**: logic errors, off-by-ones, race conditions, null/empty not handled, errors not propagated, resource leaks
2. **Security**: injection vectors, auth not checked, secrets in code, input not validated at system boundaries
3. **Codebase consistency**: does the change follow the patterns, naming, error-handling, and structure already established in THIS repo? Flag reinvented helpers, divergent idioms, and one-off styles that ignore an existing convention. Use Semble/CodeGraph to find the established pattern before flagging.
4. **DRY**: duplicated logic (copy-paste with slight variations), reimplementing a utility the repo already has, parallel code that should be extracted. Cite the existing implementation.
5. **YAGNI**: unused abstractions, speculative params/config/hooks, code not reachable from the stated request. Confirm "unused" with a caller search before flagging.
6. **Tests (consistency with the codebase)**: critical paths covered; assertions test behavior, not internals; no obvious coverage gaps. Consistency: reuse existing fixtures, **prefer mocks and fixtures over hand-rolled fakes**, and match the project's established mocking style. Flag a new fake when a fixture/mock for that dependency already exists.
7. **Standards**: file > 800 lines, function > 50 lines, nesting > 4 levels, `any`/`interface{}` without narrowing, bare `except:`
8. **Design**: SOLID violations, premature abstraction, missing abstraction, inappropriate coupling
9. **Docs consistency with the codebase**: every inline comment, docstring, README, and architecture doc that references the changed code — **directly or indirectly** (a caller, or a documented behavior that depends on it) — is updated in the same change; public API / CLI flag / config changes reflected in README/docs; terminology matches the code; counts and lists kept accurate (off-by-one counts are the most common stale-doc bug); breaking changes called out

## Output

```
## Findings

### must_fix
- [file:line] Issue -- failure scenario if not fixed

### should_fix
- [file:line] Issue -- why it degrades maintainability or coverage

### suggestion
- [file:line] Optional improvement
```

## Severity Definitions

- `must_fix`: breaks correctness or security
- `should_fix`: degrades maintainability, test coverage, diverges from an established codebase convention, or violates documented standards
- `suggestion`: optional improvement; no obligation

## Rules

- NEVER report style preferences -- the formatter handles those
- NEVER flag something `must_fix` without naming the failure scenario
- NEVER suggest adding features that are not called anywhere (YAGNI)
- Consistency and DRY findings MUST cite the established pattern or existing implementation (`file:line`) the change diverges from or duplicates -- do not assert "this is inconsistent" without the reference
- Prefer reusing existing test fixtures/mocks; flag a new fake when a fixture/mock already covers that dependency

## Next Step

Apply all `must_fix` and `should_fix` items. Run the affected tests after each fix.
