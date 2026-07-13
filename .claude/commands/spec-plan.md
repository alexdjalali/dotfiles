---
description: Plan an implementation -- explore the codebase, design tasks, verify the plan, get approval
---

## Phase 1 -- Explore

1. If the request is ambiguous, ask one clarifying question before proceeding.
2. Explore the codebase with CodeGraph and Semble:
   - Find all files the change will touch
   - Find similar existing features and the patterns they use
   - Trace call chains upstream and downstream from the affected area
3. Identify: entry points, data models, tests to extend, files to create or modify.

## Phase 2 -- Design

Design 3-12 implementation tasks. Each task must be:
- Independently testable (a failing test can be written for it in isolation)
- Small enough to complete in one focused TDD cycle
- Sequenced so later tasks build on earlier ones without circular dependencies

## Phase 3 -- Write the Plan

Write to `docs/plans/YYYY-MM-DD-<slug>.md`:

```
# Plan: <Title>

Type: Feature
Status: PENDING
Approved: No
Iteration: 1

## Summary
<2-3 sentences describing what this implements and why>

## Affected Files
<list of files to create or modify>

## Tasks
- [ ] Task 1: <verb phrase> -- <what done looks like>
- [ ] Task 2: ...

## References
- ADR: docs/adr/NNN-...
- Story: docs/spec/stories/...
```

## Phase 4 -- Verify the Plan

Launch two agents in parallel:
1. **Alignment**: "Does this plan fully cover the stated requirements? What's missing or misrepresented?"
2. **Risk**: "What assumptions does this plan make that could be wrong? What edge cases are unhandled?"

Incorporate findings before presenting the plan to the user.

## Phase 5 -- Approval

Present the complete plan. Ask:

> Plan ready. Approve to begin implementation?
> - Approve -- Start implementing
> - Revise -- [specify changes]
> - Cancel -- Stop here

On approval: set `Approved: Yes` in the plan file, then invoke `/spec-implement`.

## Rules

- NEVER begin implementation without explicit approval
- NEVER design more than 12 tasks -- split into multiple plans if needed
- NEVER include tasks that don't trace directly to the user's request
- NEVER skip the parallel verification agents -- they catch the gaps you missed
