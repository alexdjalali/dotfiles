---
description: Debug a problem using the scientific method -- reproduce, isolate, hypothesize, fix, verify
---

## Phase 1 -- Reproduce

1. Read the error completely. Don't skim stack traces.
2. Reproduce the failure consistently before touching any code.
3. Write a failing test that captures the bug now -- before any fix attempt. Use mocks and fixtures, not fakes.

If you can't reproduce it reliably, investigate why before proceeding.

## Phase 2 -- Isolate

1. `git diff` -- what changed recently that could have caused this?
2. Trace data flow from symptom to source using `codegraph_callers` and `codegraph_callees`.
3. Use Semble to find similar working code and compare -- what is structurally different?
4. Add minimal instrumentation at boundaries to observe actual values (not assumed values).

## Phase 3 -- Hypothesize

State a specific, falsifiable hypothesis before touching code:
> "The bug occurs because X when Y, causing Z."

Test with the minimal possible change. One variable at a time.

## Phase 4 -- Fix

1. Fix at the root cause -- not at the symptom.
2. The failing test from Phase 1 must now pass.
3. Run the full test suite. Fix all regressions before declaring done.
4. Update any comment, docstring, or README that describes the fixed behavior -- directly or indirectly (a caller or higher-level behavior that depended on the bug).

## Defense-in-Depth

After fixing, make the bug structurally impossible:
- Entry point: reject invalid input at the API boundary
- Business logic: validate preconditions
- Test: the reproducing test stays in the suite permanently

## Rules

- NEVER change code before understanding the root cause
- NEVER fix a bug without a test that reproduces it
- NEVER apply a fix you can't explain in one sentence
- 3+ failed fixes = the approach is wrong, not the fix -- stop and reconsider
- If the fix requires a design change, write an ADR first
