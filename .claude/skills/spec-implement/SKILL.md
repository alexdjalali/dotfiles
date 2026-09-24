---
description: /spec implementation — execute an approved plan task by task with TDD, ticking progress, then hand off to verify. Runs after plan approval or a verify loop-back.
model: opus
---

**Input:** a plan in `docs/local/plans/` with `Status: PENDING`, `Approved: Yes` (Feature or Bugfix — the plan is the interface). **Output:** every task done and ticked, `Status: COMPLETE`, and the hand-off to the verify phase.

## Per task — each unchecked task in order, including fix tasks a verify loop added

1. **Read the task** — know exactly what its Definition of Done requires.
2. **RED** — one failing test for the behavior the task introduces, at the right tier with the right double (`testing.md` *Test Double Policy*; reuse existing fixtures; NEVER a hand-rolled fake, and NEVER a mock or in-memory substitute such as SQLite-for-Postgres or fakeredis for an integration dependency). For a bugfix, Task 1 is the plan's specified reproducing test. Run it: it must fail for the right reason — the feature is missing / the bug is present, not a syntax or import error. A test that passes immediately is testing the wrong thing; rewrite it. Only a task whose `Trivial:` claim holds (`testing.md` limits) skips RED — run its named covering test/command instead; bugfix tasks never do.
3. **GREEN** — the simplest code that passes; NEVER more than the task requires (YAGNI). Match the surrounding code's patterns and naming; NEVER reinvent a helper the repo already provides.
4. **Full suite** — run it; NEVER proceed past a failure.
5. **Refactor** — clarity only; tests stay green.
6. **Code-addition checklist** against the diff (below). A "yes" the plan didn't cover is a Deviation, not a silent add.
7. **Docs** — update every comment, docstring, README, or architecture doc that references the changed code, directly or indirectly (`documentation-sync.md`; `codegraph_callers` / `codegraph_impact` find the indirect ones). NEVER leave one stale.
8. **Tick it now** — `- [ ]` → `- [x]`, Progress Tracking Done +1, Left −1. NEVER batch-mark.

**Code-addition checklist:** (1) infra/deploy change? (2) CLI/tooling change? (3) consistent with the project's philosophy, mirroring gold-standard/reference code? (4) right test *types* (unit / integration / e2e; fuzz/chaos when warranted) with the right double? (5) config change? (6) as simple as possible (DRY/YAGNI)? (7) as general as possible — interface + config-selected, capped by (6)? (8) reuses the shared-library abstractions? A repo's `.claude/rules/code-addition-checklist.md` supplies the concrete answers.

## Deviations

Record every one in the plan's `## Deviations` section.

- **Bug / missing critical / blocking** (errors, missing validation, broken imports) → fix inline (+ tests if applicable) and document; don't expand scope.
- **Architectural surprise** (new table, library swap, breaking API change) → **STOP**, document it, and ask via `AskUserQuestion` before continuing.

## After the last task

1. Run the quality gates (CLAUDE.md *Quality Gates*) — all green.
2. Set `Status: COMPLETE`.
3. In the same turn, hand off by `Type:` — `Skill(skill='spec-verify')` (Feature) or `Skill(skill='spec-bugfix-verify')` (Bugfix). Don't stop for the user.
