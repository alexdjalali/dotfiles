---
paths:
  - "**/*_test.go"
  - "**/test_*.py"
  - "**/*_test.py"
  - "**/conftest.py"
  - "**/*.{test,spec}.{ts,tsx,js,jsx}"
  - "**/tests/**"
  - "**/__tests__/**"
---

## Writing Tests

Loaded when editing test files; the core policy (TDD, Test Double Policy) is `testing.md`.

### Parsimony

- **Reuse existing behavioral tests first.** A new public class gets at most **1 unit + 1 functional test class**; split only for genuinely independent behavioral axes.
- Tests track behavior, not structure (contravariant, structure-insensitive): a behavior-preserving refactor must not break the suite. Never mirror production classes.
- **Don't:** one test class per method · three tests of one path · tests for trivial helpers (the caller's test covers them) · coverage padding. Coverage is a diagnostic, not a quota — critical paths (business logic, security, data integrity, error handling) need explicit coverage.

### Shape

- **Tier gate:** Go `//go:build integration`, Python `@pytest.mark.integration` / `@pytest.mark.unit`, TS a separate integration suite. Each test passes alone.
- **Black-box:** external test package, public surface, observable behavior. White-box (Go `*_internal_test.go`) only when unreachable otherwise, saying why. **Never export a symbol or add a test-only method for testability.**
- **Naming:** Python `test_<function>_<scenario>_<expected>` · TS `it("should <behavior> when <condition>")` · Go `TestFunction_Scenario`.
- **Doc comment on every test** — why it matters and what behavior it asserts:

```go
// TestX tests <summary>.
//
// Why this test is important:
//   - <reason>
//
// What it tests:
//   - <observable behavior>
```

### Property-based tests

For parsers, serializers, invariants, encode/decode roundtrips, bug-fix preservation — not CRUD, UI, or fixed-input validation: Python `hypothesis`, TS `fast-check`, Go `go test -fuzz`. Supplements examples; CI 100–200 examples.

### Assertion check

Most LLM-written assertions are wrong. For each: would a one-character bug still pass? Right field? Expected value derived by a second path? Asserts the contract's named behavior, not mechanics (not `mock.assert_called_with`)? Spec too ambiguous for a precise assertion → stop and ask.

### Mocks

Mirror the complete real API — partial mocks hide coupling; a mock that misrepresents reality is a lie. Mock every environment dependency (local tools, PATH lookups, FS checks) or CI fails where local passes.
