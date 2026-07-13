---
description: Review code changes for correctness, quality, and adherence to standards
---

Review the current diff or specified files across all quality dimensions.

## Scope

- Args specify files or a PR number -> review those
- No args -> review `git diff HEAD` (staged and unstaged changes)

## Dimensions

Review each independently:

1. **Correctness**: logic errors, off-by-ones, race conditions, null/empty not handled, errors not propagated
2. **Security**: injection vectors, auth not checked, secrets in code, input not validated at system boundaries
3. **Tests**: critical paths covered, assertions test behavior not internals, no obvious coverage gaps
4. **Standards**: file > 800 lines, function > 50 lines, nesting > 4 levels, `any`/`interface{}`, bare `except:`
5. **Design**: SOLID violations, premature abstraction, missing abstraction, inappropriate coupling
6. **Docs**: public API changes reflected in README/docs, breaking changes called out

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
- `should_fix`: degrades maintainability, test coverage, or violates documented standards
- `suggestion`: optional improvement; no obligation

## Rules

- NEVER report style preferences -- the formatter handles those
- NEVER flag something `must_fix` without naming the failure scenario
- NEVER suggest adding features that are not called anywhere (YAGNI)

## Next Step

Apply all `must_fix` and `should_fix` items. Run the affected tests after each fix.
