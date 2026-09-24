---
model: opus
description: Debug a problem using the scientific method -- reproduce, isolate, hypothesize, fix, verify
---

**No fixes without root cause investigation.** The phases run sequentially.

## Phase 1 -- Reproduce

1. Read the error completely. Don't skim stack traces.
2. Reproduce the failure consistently before touching any code.
3. Write a failing test that captures the bug now -- before any fix attempt -- at the right tier per `testing.md` *Test Double Policy* (unit mocks the boundary; a bug in a DB/queue/cache interaction is reproduced by an integration test against the real dependency via testcontainers). Never a hand-rolled fake.

If you can't reproduce it reliably, investigate why before proceeding.

## Phase 2 -- Isolate

1. `git diff` -- what changed recently that could have caused this?
2. Trace data flow from symptom to source using `codegraph_callers` and `codegraph_callees`.
3. **Pattern analysis:** `semble search` for similar working code and `semble find-related` from the bug site for parallel implementations. Compare and identify ALL differences.
4. Add minimal instrumentation at boundaries to observe actual values (not assumed values).

## Phase 3 -- Hypothesize

State a specific, falsifiable hypothesis before touching code:
> "The bug occurs because X when Y, causing Z." (e.g. "state resets because the component remounts on route change")

Test with the minimal possible change. One variable at a time.

## Phase 4 -- Fix

1. Fix at the root cause -- not at the symptom.
2. The failing test from Phase 1 must now pass.
3. Run the full test suite. Fix all regressions before declaring done.
4. Update any comment, docstring, or README that describes the fixed behavior -- directly or indirectly (a caller or higher-level behavior that depended on the bug).

## Red Flags, Revert-First, Meta-Debugging

- **Red flags → STOP:** "quick fix for now," multiple changes at once, proposing fixes before tracing data flow, 2+ failed fixes. **3+ failed fixes = architectural problem** -- question the pattern, don't fix again.
- **Revert-first.** When something breaks: (1) revert the change, (2) consider deleting the broken thing entirely, (3) one-liner targeted fix, (4) none of the above → stop, reconsider.
- **Meta-debugging:** treat your own code as foreign. Your mental model is a guess -- the code's behavior is truth.

## Defense-in-Depth

After fixing, make the bug structurally impossible, not just patched. Trace backward from symptom to original trigger (LSP `incomingCalls`, or `new Error().stack` instrumentation), fix at the source, then add validation at every layer the data passes:

| Layer | Purpose |
|-------|---------|
| Entry point | Reject invalid input at API boundary |
| Business logic | Ensure data makes sense for this operation (validate preconditions) |
| Environment guards | Prevent dangerous ops in specific contexts (e.g., refuse destructive ops outside temp dirs in tests) |
| Debug instrumentation | Capture context for forensics (cwd, stack, args before risky ops) |

Single validation = "fixed." All four layers = "impossible." The reproducing test stays in the suite permanently.

## Condition-Based Waiting (Flakiness)

Replace arbitrary `sleep`/`setTimeout` with polling for the actual condition:

```python
# ❌ flaky
await sleep(500); result = get_result()

# ✅ reliable
result = await wait_for(lambda: get_result() is not None, timeout=5.0)
```

**Use:** flaky tests, async waits. **Don't use** when testing actual timing (debounce, throttle) -- document WHY in that case. Poll every 10 ms, always include a timeout with a clear error, call the getter inside the loop (no stale cache).

## Constraint Classification

When a fix seems blocked by a constraint, classify it:

- **Hard** -- non-negotiable (physics, external contracts, security, deadlines)
- **Soft** -- conventions or preferences -- negotiable if the trade-off is stated
- **Ghost** -- past constraints baked in that no longer apply

Ghost constraints are the highest-value to find -- they lock out options nobody realises are available. Ask "why can't we do X?" -- if nobody can name a current requirement, it may be a ghost.

## Rules

- NEVER change code before understanding the root cause
- NEVER fix a bug without a test that reproduces it
- NEVER apply a fix you can't explain in one sentence
- 3+ failed fixes = the approach is wrong, not the fix -- stop and reconsider
- If the fix requires a design change, write an ADR first
- To hand a diagnosis off instead of fixing now (several related bugs, or someone else owns the fix), record it with `/rca` -- diagnosis-only, `file:line`-cited -- then `/fix` or `/spec` from it

## Next Step

- **Fixed and verified** → ship: `/preflight`, then `/github`.
- **Investigated but not fixing now** (or several related bugs surfaced) → record the diagnosis with `/rca`, then `/fix` (small) or `/spec` (large).
- **Fix needs a design change** → `/adr` first, then `/design` / `/spec`.
