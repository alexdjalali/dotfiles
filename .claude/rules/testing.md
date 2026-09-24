## Testing

### Default Posture: Parsimonious

- **Reuse existing behavioural tests first.** A new public production class gets at most **1 unit + 1 functional test class** (functional only if unit tests can't exercise the behaviour); split further only for genuinely independent behavioural axes.
- Tests are **contra-variant** with code (Uncle Bob, *Test Contravariance*) and **structure-insensitive** (Beck, *Test Desiderata*): they track behaviour, not method placement — don't mirror production classes.
- **Local override:** a repo's `.claude/rules/testing-project.md` (e.g. strict TDD, blanket coverage) shadows this file — the **only** way to loosen the Test Double Policy.

### TDD — Default with Documented Escapes

**⛔ Failing test before production code** — for new functions, API endpoints, business logic, bug fixes (reproduce first), behaviour changes.

1. **RED** — one minimal behaviour test (not implementation); mocks for external deps only. Naming: Python `test_<function>_<scenario>_<expected>` · TS `it("should <behavior> when <condition>")`.
2. **VERIFY RED** — must fail because the feature is missing, not a syntax error; if it passes, rewrite it.
3. **GREEN** — simplest passing code; no extras or refactor; hardcoding is fine.
4. **VERIFY GREEN** — full suite passes; diagnostics clean.
5. **REFACTOR** — improve quality, stay green, no new behaviour.

**Skip RED only for** docs, config, dep bumps, formatting-only; or a plan task's `Trivial:` justification naming the covering test/verification command (≤ 5 net new production lines, no new branch/loop/try with a non-trivial body, no new public symbol, no new error path) — the changes review and verify step audit it against the diff; the planner's claim is **not** authoritative. **Bugfixes never qualify** — the reproducing test is the regression guarantee. Code written first? Don't revert — write the test now and verify it catches regressions.

### Test Strategy & Coverage

| Type | When | Requirements |
|---|---|---|
| **Unit** — logic | No external deps: pure functions, business logic, validation | <1 ms, mock ALL external deps, `@pytest.mark.unit` |
| **Integration** — interactions | DB, cache, queue, object store, external APIs, auth flows | Real dep via testcontainers + fixtures, teardown cleanup; `@pytest.mark.integration` / `//go:build integration` |
| **E2E** — workflows | Complete user workflows, API chains | Test the entire flow |

**Coverage is a diagnostic, not a quota.** Critical paths (business logic, security, data integrity, error handling) need explicit behaviour coverage and no obvious regressions; glue code, config plumbing, simple CRUD, and trivial UI bindings have no numeric gate (the parsimony audit — `spec-verify` Phase 1 — and the changes review replace it).

### ⛔ Test Double Policy — Two Tiers (mocks for unit, Docker for integration)

Enforced for every language; a violation is a **`must_fix`** blocking a green review / `VERIFIED`.

| Tier | Real | Replaced | The ONE legal double |
|---|---|---|---|
| **Unit** | code under test | *external* collaborators (HTTP, DB, cache, queue, object store, subprocess, clock, 3rd-party API) | a **mock** of the consumer-side interface — generated (`mockgen`/`unittest.mock`/`vi.fn`) or hand-written for a *small* interface; reuse existing fixtures. Never mock an internal collaborator. |
| **Integration** | code **+ real collaborator** | nothing | the **real service in a throwaway testcontainers container** (Postgres, Redis, Kafka/SQS, S3/MinIO, Elasticsearch, any official image) via a **fixture**, truncated/closed in teardown so each test passes alone |

Per-language binding (package, entry point, tier gate — Go `//go:build integration`, Python `@pytest.mark.integration`, TS a separate integration suite): `standards-golang.md` / `standards-python.md` / `standards-typescript.md`.

**⛔ FORBIDDEN (each a `must_fix`):**

- A **hand-rolled fake / stub / in-memory client** replacing a dependency in *any* test.
- An **in-memory lookalike** where integration must run the real service (SQLite-for-Postgres, `fakeredis`/`miniredis`, in-process queue for SQS/Kafka, map-backed "repository").
- **Mocking the dependency an integration test exists to exercise**, or **mixing a unit test with a hand-rolled client** — pick a tier.
- **Folder ≠ tier:** a test under `integration/` that mocks its dependency is a mislabeled unit test.

### Property-Based Testing (PBT)

When behaviour depends on data shape, ranges, or combinations: Python `hypothesis` (`@given(st.lists(st.integers()))`) · TS `fast-check` (`fc.assert(fc.property(fc.array(fc.integer()), ...))`) · Go `go test -fuzz` (`func FuzzFoo(f *testing.F) { f.Fuzz(...) }`). **Use:** parsers, serializers, invariants, encode/decode roundtrips, bug-fix preservation. **Not:** simple CRUD, UI, fixed-input validation, config. Supplements example tests; simple strategies; CI `max_examples`/`numRuns` 100–200.

### Running Tests & Mandatory Mocking

Unit tests MUST mock HTTP/network, subprocess, file I/O, database, and third-party APIs (mock the client) — where imported, not where defined. A test > 1 s is likely unmocked I/O. Run commands and the Python `@patch` table: `standards-python.md` / `standards-typescript.md` / `standards-golang.md`. UI changes also need browser E2E (`browser-automation.md`).

### ⛔ Mock Audit on Dependency Changes

A function gains a dependency (subprocess, helper, I/O) → update ALL its tests (#1 cause of CI-only failures): `Grep` its name in `tests/`, confirm subprocess/I/O is mocked in each, run with `--tb=short`.

### Black-Box by Default (white-box is a last resort)

Behavioural tests use an **external test package** and the **public surface**, asserting observable behaviour. White-box (Go `*_internal_test.go`) only when behaviour is unreachable through the exported surface — the doc comment says why. **⛔ Never export a symbol or add a test-only method/flag for testability** — restructure (accept a small consumer-side interface).

### Test Documentation — the "why / what" doc comment

Every test has a doc comment — **why it matters** and **what behaviour it asserts** (this template or clear prose):

```go
// TestX tests <one-line summary>.
//
// Why this test is important:
//   - <reason the covered behavior matters>
//
// What it tests:
//   - <the observable behavior asserted>
func TestX(t *testing.T) { … }
```

### Anti-Patterns

- **Dependent tests** — each must pass alone.
- **Testing implementation** — assert outputs/state (`assert result == expected`), not calls (`mock.assert_called_with(...)`).
- **Incomplete mocks** — mirror the complete real API; partial mocks hide coupling.
- **Unmocked environment deps** — local tools (semble, node) pass locally, fail CI; mock every subprocess, PATH lookup, FS check for external tools.
- **Unnecessary mocks** — external deps only. **Mocking without understanding** — a mock that misrepresents reality is a lie.
- **Test-only methods in production** — expose behaviour via public interfaces instead.
- **Fakes / in-memory substitutes** — see *Test Double Policy — Two Tiers*.

### Test Parsimony — what NOT to do

- **One test class per method** (e.g. `DoSomethingTests`, `DoNothingTests` for `Foo`) — one per production class is the ceiling, not the floor.
- **Mirroring code structure** — a behaviour-preserving refactor must not break the suite.
- **Redundant assertions** — three tests of one behaviour via three internal paths is one test.
- **Test-per-trivial-helper** — no branches, I/O, or public-API exposure ⇒ the caller's test covers it.
- **Coverage padding** — tests only to push a number over a threshold.

### ⛔ Zero Tolerance for Failing Tests

Fix every failure before work is done. Run the FULL suite, not just touched files. "Pre-existing" is no excuse — if you see it, you fix it.

### Completion Checklist

- [ ] ≤ 1 unit + ≤ 1 functional test class per new public class; no redundant tests on one path
- [ ] Observable-behaviour assertions, naming convention, black-box, why/what doc comment
- [ ] Critical-path coverage adequate (no blanket %; reviewer judges)
- [ ] Doubles match the tier (unit mocks the boundary, integration uses testcontainers; no fakes/in-memory substitutes)
- [ ] Full suite passes (0 failures); actual program executed and verified

### Assertion-Correctness Warning

> **62%** of LLM-generated assertions were incorrect (HumanEval, four LLMs); false confidence is worse than no test. Check each:

1. **One-character bug** — would it still pass? (`assert result` ≠ `assert result == 42`)
2. **Right field** — e.g. `response.status` vs `response.body.error`.
3. **Computed value** — verify hand-derived expectations via a second path.
4. **Spec-named behaviour** — assert what the contract names ("user can perform X within rate limit"), not mechanics ("calls `_internal_fn` with `'QUEUED'`").

Spec too ambiguous for a precise assertion? **STOP and ask** — don't pattern-match a plausible value.
