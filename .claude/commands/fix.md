---
model: opus
description: Fix a bug in the quick lane -- reproduce, failing test, minimal fix, revert-test proof
argument-hint: <bug description | file:line | RCA slug or docs/spec/rca/ path>
---

Quick-lane bugfix. No plan file. For a single, well-scoped bug.

## Steps

0. **From an RCA?** If args name an RCA slug or path (`docs/spec/rca/<slug>.md`), read it first and start from its root cause (`file:line`) and fix sketch — re-confirm them against the current code, and cite the RCA in the commit/PR.
1. **Reproduce** consistently. Capture the trigger, inputs, and observed-vs-expected.
2. **Write a failing reproducing test** -- fails because the bug exists (not a syntax error), at the right tier per `testing.md` *Test Double Policy*. Non-negotiable: a bugfix without a reproducing test is a rubber-stamp fix.
3. **Root-cause it** -- trace to the origin with CodeGraph / Semble, not the first symptom. Check for parallel implementations of the same bug.
4. **Minimal fix** -- the smallest change that makes the reproducing test pass. No refactors, no scope creep.
5. **Revert-test proof** -- revert the fix with Edit (restore the pre-fix lines), run the test and confirm it fails; re-apply the fix with Edit and confirm it passes. Never `git stash` / `git checkout` for this.
6. **Verify** -- full suite green, then `/preflight`, then run the real program on the original trigger.

## Scope Guard -- escalate to /spec

STOP and tell the user to use `/spec` (bugfix lane) if the fix would:

- touch many files or cross module/layer boundaries,
- need a schema / API / architectural change, or
- require more than a couple of focused edits.

`/fix` is for quick, contained bugs. Anything larger gets a plan.

## Rules

- NEVER skip the reproducing test or the revert-test proof
- NEVER fix a symptom when the root cause is reachable
- NEVER expand scope -- if it grows, escalate to `/spec`
- NEVER leave the affected suite failing -- fix all failures before done

## Next Step

Fixed, revert-proven, suite green (`/preflight` already ran in step 6) → ship: `/github`. If the root cause spans several bugs worth recording, capture it with `/rca` first. If scope grew past a quick fix, stop and escalate to `/spec`.
