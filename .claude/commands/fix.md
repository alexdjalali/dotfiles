---
model: opus
description: Fix a bug in the quick lane -- reproduce, failing test, minimal fix, revert-test proof
argument-hint: <bug description or file:line>
---

Quick-lane bugfix. No plan file. For a single, well-scoped bug.

## Steps

1. **Reproduce** consistently. Capture the trigger, inputs, and observed-vs-expected.
2. **Write a failing reproducing test** -- fails because the bug exists (not a syntax error). Non-negotiable: a bugfix without a reproducing test is a rubber-stamp fix.
3. **Root-cause it** -- trace to the origin with CodeGraph / Semble, not the first symptom. Check for parallel implementations of the same bug.
4. **Minimal fix** -- the smallest change that makes the reproducing test pass. No refactors, no scope creep.
5. **Revert-test proof** -- revert the fix, confirm the test fails; restore, confirm it passes.
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
