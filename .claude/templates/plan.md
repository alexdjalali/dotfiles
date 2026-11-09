# Plan: [Title]

Type: Feature | Bugfix
Status: PENDING
Approved: No
Iteration: 1
Created: [Date]
Base: [spec-implement: `git rev-parse HEAD` before the first story commit]
Reviewed: [spec-verify: SHA the one review-diff pass covered — set once, never re-reviewed]
Full gate: [spec-verify: `green @ <sha>`]

> Written by `spec-plan` to `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored). Status PENDING → COMPLETE → VERIFIED; implementation needs `Approved: Yes`; verify increments Iteration on each loop-back. **1 story = 1 commit.** Delete every section that doesn't apply — the plan is re-read by every phase, so keep it tight.

## Summary

**Goal:** [one sentence] · **Approach:** [2–3 sentences] · **Stack:** [key tech]

**Score:** D[n] N[n] O[n] B[n] C[n] = [total] · [Delegate | Design first | Gate and soak] (`~/.claude/templates/estimate.md`) · **Human review:** [the files a human must read — auth, permissions, migrations, public contracts, infrastructure, the first instance of a new pattern; or "sampled"]

## Goal Verification

- [ ] Truth: [observable behavior, e.g. "POST /users with a duplicate email returns 409"; a bugfix's contract "must" clause first]
- [ ] Artifact: `path/to/file` — [what it must contain, non-stub]

## Bugfix (Bugfix only)

- **Source:** [RCA / issue / report]
- **Behavior Contract:** Given [trigger], the code **did** [bug]; it **must** [correct behavior]. Parallel implementations: [call sites — fixed together, or why not].
- **Root Cause:** [where and why, `file:line`]
- **Reproducing Test** (the last task — written after the fix, revert-proven at verify): `tests/...` · `test_<fn>_<scenario>_<expected>` · [unit mocking `<boundary>` | integration, real `<service>` via testcontainers] · asserts [the exact value that failed before the fix and passes after]

## Scope

**In:** [what changes] · **Out:** [explicit boundaries]

## Gaps & Unknowns

Required. Each item names a specific file, system, or decision and ends in a question for the user, `Task N`, or `checked: <evidence>`. A generic worry is a plan failure.

- **Assumptions:** [assumption → `checked: <file:line or command>`, or `untested → Task N`]
- **Questions the user didn't ask:** [question — how the answer changes the plan; ranked, the top 3 are shown at approval]
- **Failure modes:** [what breaks on partial failure, concurrency, scale, rollout, or first run → `Task N` or `checked: <evidence>`]
- **Case against this plan:** [the strongest argument that this is the wrong problem or approach, and the answer to it]
- **Unknown unknowns:** [what was examined outside the plan's own files — adjacent systems, `git log` on the area, similar features, past RCAs — and what it turned up]

## Proposed Repository Structure (only if files are added)

```text
src/<area>/<new_file>        # (new)
tests/<area>/test_<new_file> # (new)
```

Matches the current layout — or deviates, confirmed with the user: [what / why].

## Context for Implementer

The map later phases use instead of re-exploring:

- **Patterns:** [`file:line` to mirror] · **Key files:** [path — why] · **Gotchas:** [non-obvious things] · **Runtime:** [start / health check / port, if a service]
- **Shape** (`code-addition-checklist.md`): core interface [name] · `Kind`s [stub default, real kinds] · composition root [file — where it is wired] · decorators [which, in the per-layer order] · error codes [new codes]
- **Config:** [owning slice; new fields + fail-safe `base` default; env overlay / secrets entries]
- **Codegen:** [source → generator command → generated paths; or "none"]
- **Operability:** [timeouts; logs/metrics/spans added; health/readiness/shutdown impact]
- **Docs** (`code-addition-checklist.md` 11 — first priority): [every doc this plan refreshes, per story: doc comments, test Why/What docs, README / docs pages / CLAUDE.md / AGENTS.md, ADRs, generated references]
- **Budget** (`code-addition-checklist.md` 10): [~N prod / ~M test lines hand-written · deletes: [what] · each new interface / config field / CLI step / test tier and why · generated: [what the generator emits instead]]
- **Reference:** [`file:line` of the implementation this mirrors — or "sets a new pattern: ADR-NNNN"]
- **Guards:** [each new invariant or convention → the check that enforces it (lint rule, repo guard, ratchet, generator) and the task that adds it; or "needs judgment — review only"]
- **Cross-cutting** (`cross-cutting.md`): [one line per layer: done `file:line` · not needed: reason · gap → Task N; or `none (<reason>)`]
- **Rollout:** [order across IaC, data, code, traffic · manual steps with the exact command · rollback and what can't be undone; or "merge is the deploy"]
- **Must agree:** [pairs that must stay in sync — a cloud call and its permission grant, a source and its generated output, a pinned version across environments — each generated from the other or guarded; or "none"]

## Progress Tracking

- **Story 1** — [title] · commit: [ ]
  - [ ] Task 1: [summary]
  - [ ] Task 2: [summary]

**Total:** [n] | **Done:** 0 | **Left:** [n]

## Implementation Tasks

### Story 1: [title] — [`<story>/<file>` (the `story` layout path) or the request]

**Commit:** `<type>(<scope>): <description>` · **SHA:** [filled at commit]

#### Task 1: [name]

- **Objective:** [1–2 sentences] · **Depends on:** [none | Task N]
- **Files:** create `path` · modify `path` · test `tests/path`
- **Interfaces:** produces [exact names/signatures later tasks use] · consumes [from Task N]
- **Notes:** [approach; pattern to follow `file:line`] — no placeholders ("TBD", "handle edge cases", "similar to Task N")
- **Trivial:** [optional — only within `testing.md` limits, naming the covering test; never for bugfixes]
- **Done when:** [observable criterion] · **Verify:** `<test-command> tests/path -q`

## Testing Strategy

- **Unit** (mock the boundary): [what; which collaborators are mocked]
- **Integration** (testcontainers): [what; image + module, e.g. `postgres:16` via `testcontainers[postgres]`]
- **Execution:** [how the running program is exercised at verify]

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|

## Open Questions

- [for the user, or deferred]

## Review Findings

[spec-verify: every `review-diff` finding, all tiers — `- [ ] <tier> [file:line] issue` — ticked when fixed, or `skip: <reason>`. The fix check works from this list.]

## Deviations

[Added by `spec-implement` — inline fixes and architectural stops.]

## References

[story · RCA · ADR · design doc]
