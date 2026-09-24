---
model: opus
description: Implement behavior with strict red-green-refactor, one failing test at a time and no skipped steps. Use when asked to TDD something or add behavior test-first outside /spec.
---

**Input:** the behavior(s) to add. **Output:** each behavior implemented and covered by a test that failed first; full suite green. This is `testing.md`'s Red → Green → Refactor loop run strictly — no `Trivial:` escape.

## Loop — one behavior per pass

1. **Pick** the next smallest behavior not yet covered.
2. **Red** — write exactly one test for it, asserting observable behavior (not implementation details) and no more than needed to fail. Naming: Python `test_<function>_<scenario>_<expected>` · TS `it("should <behavior> when <condition>")` · Go `TestFunctionName_Scenario`. Doubles per `testing.md` *Test Double Policy*: at the unit tier mock only external boundaries (HTTP, DB, filesystem, subprocess, time) with mocks and fixtures — NEVER internal collaborators, NEVER a hand-rolled fake or stub that reimplements the dependency; when the behavior *is* the interaction with a backing service, write an integration test via testcontainers.
3. **Verify red** — it fails for the right reason (the behavior is missing, not a syntax error). A test that passes on first run is probably wrong — investigate and rewrite it before continuing.
4. **Green** — the simplest code that passes; no extras; hardcoding is fine. Run the full suite — everything stays green.
5. **Refactor** — remove duplication, improve naming, clarify structure, tests green throughout. NEVER skip it — "it looks fine" is not a reason.
6. Loop to 1 until every specified behavior is done.

NEVER write implementation before a failing test.

## Next Step

Run the quality gates (CLAUDE.md *Quality Gates*), then suggest `/github` to commit (user-typed).
