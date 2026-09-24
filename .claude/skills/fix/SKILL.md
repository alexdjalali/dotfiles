---
model: opus
description: Fix one known, contained bug in the quick lane — reproducing test first, minimal root-cause fix, revert-test proof, no plan. Escalate to /spec when the fix crosses layers or needs a schema/API change.
argument-hint: <bug description | file:line | RCA slug or docs/spec/rca/ path>
---

**Input:** a bug description, a `file:line`, or an RCA slug / `docs/spec/rca/<slug>.md`. **Output:** a root-cause fix pinned by a reproducing test with revert-test proof, suite and gates green, ready for `/github`. No plan file.

## Steps

1. **From an RCA?** Read it first; start from its root cause (`file:line`) and fix sketch — re-confirm both against the current code, and cite the RCA in the commit/PR.
2. **Reproduce** consistently — trigger, inputs, observed vs expected.
3. **Failing reproducing test** — fails *because the bug exists* (not a syntax/import error), at the right tier and double (`testing.md` *Test Double Policy*). NEVER skip it: a bugfix without one is a rubber-stamp fix.
4. **Root-cause** — trace to the origin with CodeGraph / Semble, not the first symptom; check for parallel implementations of the same bug. NEVER fix a symptom when the root cause is reachable.
5. **Minimal fix** — the smallest change that turns the test green. No refactors, no scope creep.
6. **Revert-test proof** (NEVER skip) — revert the fix with Edit (restore the pre-fix lines) and run the test: it must fail. Re-apply with Edit: it must pass. Never `git stash` / `git checkout` for this.
7. **Verify** — full suite green (fix every failure before done), run the quality gates (CLAUDE.md *Quality Gates*), then run the real program on the original trigger.

## Scope guard

STOP and tell the user to use `/spec` (bugfix lane) if the fix would touch many files or cross module/layer boundaries, need a schema / API / architectural change, or take more than a couple of focused edits. NEVER expand scope silently — `/fix` is for quick, contained bugs; anything larger gets a plan.

## Next Step

- **Fixed, revert-proven, gates green** → suggest `/github` to ship (the user types it).
- **Root cause spans several bugs worth recording** → `/rca` first.
- **Outgrew the quick lane** → stop; suggest `/spec` for the user to type.
