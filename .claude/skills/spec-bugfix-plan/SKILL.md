---
description: /spec bugfix-lane planning — reproduce, root-cause, Behavior Contract, reproducing-test spec, approval. Started by /spec, not unprompted; small contained bugs go to /fix.
model: opus
---

**Input:** a bug report, or an RCA slug / `docs/spec/rca/<slug>.md`. **Output:** an approved Bugfix plan at `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored), then the hand-off to `spec-implement`. NEVER write code — test or fix — before approval: this phase *specifies* the reproducing test; `spec-implement` writes it as Task 1's RED step.

## Phase 1 — Reproduce & root-cause

1. **From an RCA?** Read it first: its root cause (`file:line` evidence) and fix sketch are the starting point — re-confirm both against the current code rather than re-deriving; cite the RCA under References.
2. **Reproduce** consistently — the exact trigger, inputs, and observed vs expected behavior.
3. **Trace to the root cause, not the symptom** — CodeGraph (`codegraph_callers` / `codegraph_impact`) + Semble — including every parallel implementation that shares the flaw. NEVER plan a symptom fix when the root cause is reachable.
4. **Specify the reproducing test** — path, name, tier/double, and the exact assertion that fails *because the bug exists* (not a syntax/import error) and passes after the fix. NEVER skip it: it's the regression guarantee, and bugfixes never qualify for `Trivial:`. A bug in a DB / queue / cache interaction is pinned by an integration test against the real dependency via testcontainers — NEVER a mock of the dependency the test must exercise (`testing.md` *Test Double Policy*).

## Phase 2 — Behavior Contract

- **Given** <trigger/state>, the code **did** <buggy behavior>; it **must** <correct behavior>.
- List every call site / parallel implementation sharing the root cause — fixed together, or with a stated reason why not (NEVER leave a known one unfixed silently).

## Phase 3 — Write the plan

From `~/.claude/templates/plan.md` (the single plan format), header `Type: Bugfix`, `Status: PENDING`, `Approved: No`, `Iteration: 1`.

- **Bugfix block:** Source (RCA / issue / report), Behavior Contract, Root Cause, and the Reproducing Test spec from Phase 1.
- **Goal Verification:** the Behavior Contract's "must" clause is the first truth.
- **Tasks:** Task 1 writes the specified reproducing test and confirms it fails on current code (RED); later tasks fix the root cause (and the parallel implementations) until it passes.
- **References:** the RCA, related story/ADR, or issue.
- **Proposed Repository Structure** — only if the fix adds files, consistent with the current layout; a layout that must deviate → ask the user before finalizing.
- Delete optional sections that don't apply.

## Phase 4 — Review the plan

Launch `Agent(subagent_type='spec-review')` with:

- `plan_file` — the plan path
- `user_request` — the original bug report verbatim (plus the RCA's symptom when planning from one)
- `clarifications` — Phase 1 answers (optional)
- `output_path` — `docs/local/plans/.spec-review-<slug>.json`

It runs in the background, does one combined alignment + adversarial-assumption review (does the fix target the *root cause*? does the reproducing test actually pin the bug?), and writes JSON. Poll for the file with a bash existence loop, Read it once, and fold in every `must_fix` / `should_fix` before presenting.

## Phase 5 — Approval

Present the plan and ask:

> Bugfix plan ready. Approve to begin implementation?
> - Approve — start implementing
> - Revise — [specify changes]
> - Cancel — stop here

NEVER begin implementation without an explicit Approve. On approval, set `Approved: Yes` and call `Skill(skill='spec-implement')` in the same turn — approval was the manual gate.
