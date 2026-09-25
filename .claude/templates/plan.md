# Plan: [Title]

Type: Feature | Bugfix
Status: PENDING
Approved: No
Iteration: 1
Created: [Date]
Base: [spec-implement: `git rev-parse HEAD` before the first story commit]
Reviewed: [spec-verify: SHA the last review covered]
Full gate: [spec-verify: `green @ <sha>`]

> Written by `spec-plan` to `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored). Status PENDING → COMPLETE → VERIFIED; implementation needs `Approved: Yes`; verify increments Iteration on each loop-back. **1 story = 1 commit.** Delete every section that doesn't apply — the plan is re-read by every phase, so keep it tight.

## Summary

**Goal:** [one sentence] · **Approach:** [2–3 sentences] · **Stack:** [key tech]

## Goal Verification

- [ ] Truth: [observable behavior, e.g. "POST /users with a duplicate email returns 409"; a bugfix's contract "must" clause first]
- [ ] Artifact: `path/to/file` — [what it must contain, non-stub]

## Bugfix (Bugfix only)

- **Source:** [RCA / issue / report]
- **Behavior Contract:** Given [trigger], the code **did** [bug]; it **must** [correct behavior]. Parallel implementations: [call sites — fixed together, or why not].
- **Root Cause:** [where and why, `file:line`]
- **Reproducing Test:** `tests/...` · `test_<fn>_<scenario>_<expected>` · [unit mocking `<boundary>` | integration, real `<service>` via testcontainers] · asserts [the exact value that fails now and passes after the fix]

## Scope

**In:** [what changes] · **Out:** [explicit boundaries]

## Proposed Repository Structure (only if files are added)

```text
src/<area>/<new_file>        # (new)
tests/<area>/test_<new_file> # (new)
```

Matches the current layout — or deviates, confirmed with the user: [what / why].

## Context for Implementer

The map later phases use instead of re-exploring:

- **Patterns:** [`file:line` to mirror] · **Key files:** [path — why] · **Gotchas:** [non-obvious things] · **Runtime:** [start / health check / port, if a service]

## Progress Tracking

- **Story 1** — [title] · commit: [ ]
  - [ ] Task 1: [summary]
  - [ ] Task 2: [summary]

**Total:** [n] | **Done:** 0 | **Left:** [n]

## Implementation Tasks

### Story 1: [title] — [`docs/spec/stories/<file>` or the request]

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

## Deviations

[Added by `spec-implement` — inline fixes and architectural stops.]

## References

[story · RCA · ADR · design doc]
