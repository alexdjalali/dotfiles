---
description: Plan a bugfix -- reproduce, root-cause, design the fix with a reproducing test first
model: opus
---

## Phase 1 -- Reproduce & Root-Cause

1. Reproduce the bug consistently. Capture the exact trigger, inputs, and observed-vs-expected behavior.
2. Write a **failing reproducing test** that fails *because the bug exists* (not a syntax/import error). This is the regression guarantee — a bugfix without one is a rubber-stamp fix.
3. Trace to the **root cause, not the symptom**. Use CodeGraph (`codegraph_callers` / `codegraph_impact`) and Semble to find the origin and any parallel implementations that share the flaw.

## Phase 2 -- Behavior Contract

State the contract the fix must satisfy:

- **Given** <trigger/state>, the code **did** <buggy behavior>, it **must** <correct behavior>.
- List every call site / parallel implementation that shares the root cause (fix them together, or note why not).

## Phase 3 -- Write the Plan

Write to `docs/spec/plans/YYYY-MM-DD-<slug>.md`:

```
# Plan: <Bug title>

Type: Bugfix
Status: PENDING
Approved: No
Iteration: 1

## Behavior Contract
Given <...>, did <...>, must <...>.

## Reproducing Test
<path::test name> -- fails on current code, passes after the fix.

## Root Cause
<where and why the bug originates>

## Affected Files
<files to change>

## Tasks
- [ ] Task 1: <verb phrase> -- <what done looks like>
```

## Phase 4 -- Verify the Plan

Launch the `spec-review` agent (background; it writes a findings JSON file — poll for the file, then read it once). It runs a combined alignment + adversarial-assumption review: does the fix address the *root cause* (not the symptom), and does the reproducing test actually pin the bug? Incorporate `must_fix` / `should_fix` before presenting.

## Phase 5 -- Approval

Present the plan. Ask:

> Bugfix plan ready. Approve to begin implementation?
> - Approve -- Start implementing
> - Revise -- [specify changes]
> - Cancel -- Stop here

On approval: set `Approved: Yes` in the plan file, then invoke `/spec-implement`.

## Rules

- NEVER skip the reproducing test -- a bugfix without one cannot prove the bug is gone (bugfixes never qualify for the `Trivial:` escape)
- NEVER fix a symptom when the root cause is reachable -- trace it first
- NEVER leave a known parallel implementation of the same bug unfixed without noting why
- NEVER begin implementation without explicit approval
