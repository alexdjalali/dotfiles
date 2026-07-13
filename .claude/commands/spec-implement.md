---
description: Implement an approved plan task-by-task using TDD
---

Read the plan from `docs/plans/`. Status must be `PENDING` with `Approved: Yes`.

## Execution Loop

For each unchecked task, in order:

1. **Read the task** -- understand exactly what "done" means.
2. **Write a failing test** -- one test for the behavior this task introduces. Run it; confirm it fails for the right reason (not a syntax error, not a wrong import -- the feature doesn't exist yet).
3. **Implement** -- simplest code that makes the test pass. Nothing more.
4. **Verify green** -- run the full test suite. Fix all failures before moving on.
5. **Refactor** -- improve clarity without changing behavior. Tests stay green.
6. **Mark done** -- change `- [ ]` to `- [x]` in the plan file immediately.

Repeat for each task.

## After All Tasks Complete

1. Run `/preflight` -- all four gates must pass.
2. Set plan `Status: COMPLETE` in the header.
3. Invoke `/spec-verify`.

## Deviations

- **Bug or broken import encountered inline**: fix it, add a `## Deviations` section to the plan documenting what was found.
- **Architectural surprise** (new table needed, library swap, breaking API change): STOP. Document in Deviations. Ask the user before continuing.

## Rules

- NEVER skip the failing test -- a test that passes immediately is testing the wrong thing
- NEVER implement more than the current task requires
- NEVER batch-mark tasks -- update the checkbox the moment each task is complete
- NEVER proceed past a failing test suite -- fix first, then continue
