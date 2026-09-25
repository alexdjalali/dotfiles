---
name: fix
model: opus
effort: high
description: Fix one contained bug, cause known or not — reproduce, root-cause with the scientific method, reproducing test first, minimal fix, revert-test proof, no plan. Use for errors, failing or flaky tests, unexpected behavior. Escalate to /spec when the fix crosses layers or needs a schema/API change.
argument-hint: <bug description | file:line | RCA slug or docs/spec/rca/ path>
---

**Input:** a symptom (error, failing/flaky test, unexpected behavior), a `file:line`, or an RCA slug / `docs/spec/rca/<slug>.md`. **Output:** a root-cause fix pinned by a reproducing test with revert-test proof, fast checks green, ready for `/github` (which commits, then runs the full gate once). No plan file.

## Steps

1. **From an RCA?** Read it first; start from its root cause (`file:line`) and fix sketch — re-confirm both against the current code, and cite the RCA in the commit/PR.
2. **Reproduce** consistently — trigger, inputs, observed vs expected.
3. **Failing reproducing test** — fails *because the bug exists* (not a syntax/import error); tier and double per `testing.md`. NEVER skip it.
4. **Root-cause** — read the whole error and stack trace; check `git diff` / `git log` for recent changes; trace data flow from symptom to source (`codegraph_callers` / `codegraph_callees`); compare against similar working code and find parallel implementations (`semble find-related`); instrument boundaries to see actual values, not assumed ones. Cause still unknown → state one falsifiable hypothesis ("X when Y, causing Z") and test it changing one variable at a time. NEVER fix a symptom when the root cause is reachable, or a cause you can't state in one sentence.
5. **Minimal fix** — the smallest change that turns the test green. No refactors, no scope creep.
6. **Revert-test proof** (NEVER skip) — revert the fix with Edit (restore the pre-fix lines) and run the test: it must fail. Re-apply with Edit: it must pass. Never `git stash` / `git checkout` for this.
7. **Verify** — fast checks green (CLAUDE.md *Quality Gates*; reproducing + affected tests), then run the real program on the original trigger. The full gate runs once, in `/github` after the commit.

## Debugging discipline

- **Red flags → STOP:** "quick fix for now", several changes at once, a fix proposed before tracing data flow. **3+ failed fixes = the approach is wrong** — question the pattern, don't fix again.
- **Revert-first** when a change breaks something: revert it; consider deleting the broken thing; then a one-line targeted fix; else stop and reconsider.
- **Flaky / async:** replace `sleep` with polling for the actual condition (short interval, a timeout, a clear error, the getter called inside the loop) — except when testing real timing (debounce, throttle; say why).
- **Defense in depth:** once fixed, validate where the bad data enters (entry point → business logic → environment guards) so the bug is impossible, not just patched.
- **Rationalizations → STOP:** "it's simple, skip the process" · "emergency, no time" (thrashing is slower) · "I'll write the test after" · "I see the problem" (a symptom isn't a cause) · "one more try" after two failures.
- **No root cause found?** Truly environmental, timing, or external: document what you ruled out, add handling (retry/timeout/clear error) and logging at the boundary — but most "no root cause" is an unfinished investigation.
- **Blocked by a constraint?** Classify it — hard (contracts, security), soft (convention; negotiable with the trade-off stated), or ghost (no current requirement behind it — the highest-value find).

## Scope guard

STOP and tell the user to use `/spec` (bugfix lane) if the fix would touch many files or cross module/layer boundaries, need a schema / API / architectural change, or take more than a couple of focused edits. NEVER expand scope silently — `/fix` is for quick, contained bugs; anything larger gets a plan.

## Next Step

- **Fixed, revert-proven, fast checks green** → suggest `/github` to ship (the user types it).
- **Several related bugs, or someone else will fix it** → record the diagnosis with `/rca` instead.
- **Fix needs a design change** → `/adr` first.
- **Outgrew the quick lane** → stop; suggest `/spec` for the user to type.
