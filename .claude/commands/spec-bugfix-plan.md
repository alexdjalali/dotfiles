---
description: Plan a bugfix -- reproduce, root-cause, design the fix with a reproducing test first
model: opus
---

No production or test code is written before approval — this phase *specifies* the reproducing test; `spec-implement` writes it as Task 1's RED step.

## Phase 1 -- Reproduce & Root-Cause

1. **Start from an RCA when given one.** If args name an RCA slug or path (`docs/spec/rca/<slug>.md`), read it first: its root cause (with `file:line` evidence) and fix sketch are the starting point — re-confirm them against the current code rather than re-deriving from scratch, and cite the RCA in the plan's References.
2. Reproduce the bug consistently. Capture the exact trigger, inputs, and observed-vs-expected behavior.
3. Trace to the **root cause, not the symptom**. Use CodeGraph (`codegraph_callers` / `codegraph_impact`) and Semble to find the origin and any parallel implementations that share the flaw.
4. **Specify the reproducing test** — path, test name, tier/double, and the exact assertion that fails *because the bug exists* (not a syntax/import error) and passes after the fix. This is the regression guarantee — a bugfix without one is a rubber-stamp fix. It becomes Task 1 (RED) after approval.

## Phase 2 -- Behavior Contract

State the contract the fix must satisfy:

- **Given** <trigger/state>, the code **did** <buggy behavior>, it **must** <correct behavior>.
- List every call site / parallel implementation that shares the root cause (fix them together, or note why not).

## Phase 3 -- Write the Plan

Write the plan from **`~/.claude/templates/plan.md`** (the single plan format) to `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored — local working docs, never committed), with header `Type: Bugfix`, `Status: PENDING`, `Approved: No`, `Iteration: 1`.

- Fill the **Bugfix block**: Source (RCA / issue / report), Behavior Contract, Root Cause, and the Reproducing Test spec from Phase 1.
- **Goal Verification:** the Behavior Contract's "must" clause is the first truth.
- **Tasks:** Task 1 writes the specified reproducing test and confirms it fails on current code (RED); later tasks fix the root cause (and any parallel implementations) until it passes.
- **References:** the RCA, related story/ADR, or issue this fix came from.
- **Proposed Repository Structure** — ONLY if the fix adds new files, consistent with the current layout; if the layout must deviate, ask the user to confirm before finalizing.
- Delete optional sections that don't apply.

## Phase 4 -- Verify the Plan

Launch the `spec-review` agent with all four inputs:

- `plan_file` — the plan path
- `user_request` — the user's original bug report verbatim (plus the RCA's symptom when planning from one)
- `clarifications` — optional: answers gathered in Phase 1
- `output_path` — `docs/local/plans/.spec-review-<slug>.json` (co-located with the plan, gitignored)

It runs in the background, does a combined alignment + adversarial-assumption review (does the fix address the *root cause*, not the symptom, and does the specified reproducing test actually pin the bug?), and writes the findings JSON — poll for the file, then Read it once. Incorporate `must_fix` / `should_fix` before presenting.

## Phase 5 -- Approval

Present the plan. Ask:

> Bugfix plan ready. Approve to begin implementation?
> - Approve -- Start implementing
> - Revise -- [specify changes]
> - Cancel -- Stop here

On approval: set `Approved: Yes` in the plan file, then immediately continue the chain — call `Skill(skill='spec-implement')` in the same turn. Do NOT stop and wait for the user to re-type it; plan approval was the manual gate.

## Rules

- NEVER skip the reproducing test -- a bugfix without one cannot prove the bug is gone (bugfixes never qualify for the `Trivial:` escape)
- NEVER write code (test or fix) before approval -- the plan specifies the reproducing test; Task 1 writes it
- NEVER let the reproducing test mock the dependency it must exercise -- a bug in a DB/queue/cache interaction is pinned by an integration test against the real dependency via testcontainers (`testing.md` *Test Double Policy*)
- NEVER fix a symptom when the root cause is reachable -- trace it first
- NEVER leave a known parallel implementation of the same bug unfixed without noting why
- NEVER begin implementation without explicit approval
