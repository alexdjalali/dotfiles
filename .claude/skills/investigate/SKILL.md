---
model: opus
description: Debug a problem whose cause is unknown with the scientific method — reproduce, isolate, hypothesize, fix at the root, verify. Use for errors, failing or flaky tests, or unexpected behavior before proposing a fix.
---

**No fix without root-cause investigation.** **Input:** a symptom (error, failing test, unexpected behavior). **Output:** the root cause, a fix at that cause pinned by a reproducing test, suite green — or a hand-off to `/rca` when fixing now isn't right. Phases run in order.

## Phase 1 — Reproduce

1. Read the error completely — don't skim stack traces.
2. Reproduce the failure consistently before touching any code; if it won't reproduce reliably, find out why before proceeding.
3. Write a failing test that captures the bug now, before any fix attempt, at the right tier and double (`testing.md` *Test Double Policy* — a bug in a DB / queue / cache interaction is reproduced against the real dependency via testcontainers; never a hand-rolled fake). NEVER fix a bug without one.

## Phase 2 — Isolate

1. `git diff` / `git log` — what changed recently that could cause this?
2. Trace data flow from symptom to source with `codegraph_callers` / `codegraph_callees`.
3. **Pattern analysis** — `semble search` for similar working code and `semble find-related` from the bug site for parallel implementations; compare and list ALL differences.
4. Add minimal instrumentation at boundaries to observe actual values, not assumed ones.

## Phase 3 — Hypothesize

Before touching code, state one specific, falsifiable hypothesis — "the bug occurs because X when Y, causing Z" (e.g. "state resets because the component remounts on route change"). Test it with the minimal possible change, one variable at a time. NEVER change code before the root cause is understood, or apply a fix you can't explain in one sentence.

## Phase 4 — Fix

1. Fix at the root cause, not the symptom. If it needs a design change, write an ADR first (`/adr`).
2. The Phase 1 test now passes and stays in the suite permanently.
3. Run the full suite; fix every regression before declaring done.
4. Update every comment, docstring, or README describing the fixed behavior, directly or indirectly (`documentation-sync.md`).

## Discipline

- **Red flags → STOP:** "quick fix for now", several changes at once, proposing a fix before tracing data flow, 2+ failed fixes. **3+ failed fixes = architectural problem** — the approach is wrong, not the fix; question the pattern, don't fix again.
- **Revert-first** when something breaks: (1) revert the change, (2) consider deleting the broken thing entirely, (3) a one-line targeted fix, (4) none of these → stop and reconsider.
- **Meta-debugging:** treat your own code as foreign — your mental model is a guess; the code's behavior is truth.

## Defense in depth

After fixing, make the bug structurally impossible, not just patched: trace back from symptom to original trigger (LSP `incomingCalls`, or `new Error().stack` instrumentation), fix at the source, then validate at every layer the data passes:

| Layer | Purpose |
|-------|---------|
| Entry point | Reject invalid input at the API boundary |
| Business logic | Ensure the data makes sense for this operation (validate preconditions) |
| Environment guards | Prevent dangerous ops in specific contexts (e.g. refuse destructive ops outside temp dirs in tests) |
| Debug instrumentation | Capture context for forensics (cwd, stack, args before risky ops) |

One validation = "fixed"; all four layers = "impossible".

## Condition-based waiting (flakiness)

Replace arbitrary `sleep`/`setTimeout` with polling for the actual condition:

```python
# ❌ flaky
await sleep(500); result = get_result()

# ✅ reliable
result = await wait_for(lambda: get_result() is not None, timeout=5.0)
```

Use for flaky tests and async waits — not when testing real timing (debounce, throttle; document WHY there). Poll every 10 ms, always with a timeout and a clear error, calling the getter inside the loop (no stale cache).

## Constraint classification

When a fix seems blocked by a constraint, classify it: **Hard** — non-negotiable (physics, external contracts, security, deadlines) · **Soft** — conventions or preferences, negotiable if the trade-off is stated · **Ghost** — a past constraint baked in that no longer applies. Ghosts are the highest-value find — they lock out options nobody realises exist. Ask "why can't we do X?"; if nobody can name a current requirement, it may be a ghost.

## Next Step

- **Fixed and verified** → run the quality gates (CLAUDE.md *Quality Gates*), then suggest `/github` (user-typed).
- **Not fixing now** (several related bugs, or someone else owns the fix) → record a diagnosis-only, `file:line`-cited report with `/rca`, then `/fix` (small) or `/spec` (large, user-typed).
- **Fix needs a design change** → `/adr` first, then `/design-doc` or `/spec`.
