## Testing

Core policy, always loaded. Writing or editing a test file also loads `testing-authoring.md` (parsimony, doc comments, PBT, assertion checks). A repo's `.claude/rules/testing-project.md` overrides this file — the **only** way to loosen the Test Double Policy.

### TDD

**⛔ Failing test before production code** — new functions, endpoints, business logic, behavior changes, and bug fixes (reproduce first).

1. **RED** — one minimal behavior test; mocks for external deps only.
2. **VERIFY RED** — fails because the behavior is missing, not a syntax/import error; passes immediately → rewrite it.
3. **GREEN** — simplest passing code; hardcoding is fine.
4. **VERIFY GREEN** — affected tests pass, diagnostics clean. The full suite runs once, in the full gate.
5. **REFACTOR** — stay green, no new behavior.

**Skip RED only for** docs, config, dep bumps, formatting — or a plan task's `Trivial:` claim naming its covering test/command: ≤ 5 net new production lines, no new branch/loop/try with a non-trivial body, no new public symbol, no new error path (audited at verify). **Bugfixes never qualify.** Code written first? Write the test now and prove it catches the regression.

### ⛔ Test Double Policy — two tiers

A violation is a `must_fix`.

| Tier | Real | The one legal double |
|---|---|---|
| **Unit** | the code under test | a **mock** of the consumer-side interface for an *external* collaborator (HTTP, DB, cache, queue, object store, subprocess, clock, 3rd-party API) — generated or a small hand-written mock. Never mock an internal collaborator. |
| **Integration** | code + the **real service** | none — the real dependency in a throwaway **testcontainers** container via a fixture, cleaned up in teardown |

**Forbidden:** a hand-rolled fake / stub / in-memory client in any test; an in-memory lookalike for integration (SQLite-for-Postgres, fakeredis/miniredis, in-process queue, map-backed repository); mocking the dependency an integration test exists to exercise; an `integration/` test that mocks its dependency.

Unit tests mock HTTP, subprocess, file I/O, DB, and 3rd-party clients where imported, not where defined; a unit test > 1 s is likely unmocked I/O. When a function gains a dependency, update **all** its existing tests to mock it.

### ⛔ Zero Tolerance

Fix every failure before work is done — "pre-existing" is no excuse. The full gate runs the FULL suite, once, after the last commit. Tests passing ≠ program working: run it too (`verification.md`).
