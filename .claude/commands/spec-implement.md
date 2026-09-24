---
description: Implement an approved plan task-by-task using TDD
model: opus
---

Read the plan from `docs/local/plans/`. Status must be `PENDING` with `Approved: Yes`.

## Execution Loop

For each unchecked task, in order:

1. **Read the task** -- understand exactly what "done" means.
2. **Write a failing test** -- one test for the behavior this task introduces, at the right tier with the right double (per `testing.md` *Test Double Policy*: unit mocks the external boundary and reuses existing fixtures; integration runs the real dependency via testcontainers). For a bugfix, Task 1 is the reproducing test the plan specifies. Run it; confirm it fails for the right reason (not a syntax error, not a wrong import -- the feature doesn't exist yet / the bug is present).
3. **Implement** -- simplest code that makes the test pass. Nothing more. Follow the existing patterns and naming in the files you touch; reuse existing helpers instead of reinventing them (DRY). Before ticking the box, run the **code-addition checklist** (below) against the diff.
4. **Verify green** -- run the full test suite. Fix all failures before moving on.
5. **Refactor** -- improve clarity without changing behavior. Tests stay green.
6. **Sync docs** -- per `documentation-sync.md`: every comment, docstring, README, or architecture doc that references the changed code, directly or indirectly (`codegraph_callers` / `codegraph_impact`).
7. **Mark done immediately** -- `- [ ]` → `- [x]` in the plan, and in Progress Tracking Done +1, Left −1.

Repeat for each task.

## Code-addition checklist

Re-check each per task before ticking its box (a "yes" that the plan didn't cover is a Deviation, not a silent add): (1) **infra/deploy** change needed? (2) **CLI/tooling** change needed? (3) consistent with the project's **philosophy** and mirrors **gold-standard/reference** code? (4) right **test *types*** with the right **double** (unit / integration / e2e, plus fuzz/chaos when warranted)? (5) **config** change needed? (6) as **simple** as possible (DRY/YAGNI)? (7) as **general** as possible — interface + config-selected, balanced against YAGNI? (8) **reuses** the shared-library patterns/abstractions rather than reinventing them?

If the repo defines `.claude/rules/code-addition-checklist.md`, follow its concrete answers.

## After All Tasks Complete

1. Run `/preflight` -- all gates must pass.
2. Set plan `Status: COMPLETE` in the header.
3. Continue the chain in the same turn, routed by the plan's `Type:` — `Skill(skill='spec-verify')` (Feature) or `Skill(skill='spec-bugfix-verify')` (Bugfix). Do NOT stop and hand back to the user.

## Deviations

Record every deviation in the plan's `## Deviations` section.

- **Bug / missing critical / blocking** (errors, missing validation, broken imports): auto-fix inline (+ tests if applicable), document it, and do NOT expand scope.
- **Architectural surprise** (new table, library swap, breaking API change): **STOP** — document it and ask the user (`AskUserQuestion`) before continuing.

Outside `/spec`, respect the user's mode.

## Rules

- NEVER skip the failing test -- a test that passes immediately is testing the wrong thing
- NEVER hand-roll a fake or satisfy an integration test with a mock / in-memory substitute (SQLite-for-Postgres, fakeredis) -- a must_fix per `testing.md`
- NEVER implement more than the current task requires (YAGNI)
- NEVER reinvent a helper the repo already provides -- reuse it, and match the surrounding code's conventions
- NEVER leave docs that reference the changed code (directly or indirectly) stale
- NEVER batch-mark tasks -- update the checkbox and counters the moment each task is complete
- NEVER proceed past a failing test suite -- fix first, then continue
