---
description: Plan an implementation -- explore the codebase, design tasks, verify the plan, get approval
model: opus
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
- Aligned with the repo's existing patterns — reuse established helpers, naming, and conventions rather than introducing parallel ones (consistency, DRY); tests use mocks and fixtures, not fakes

**Code-addition checklist.** For work that adds or changes code, make the plan answer these eight before you finalize the tasks — a "yes" to infra/CLI/config is its own task, not an afterthought:

1. **Infra/deploy?** does it need a dev environment change and a staging/prod (IaC) change?
2. **CLI/tooling?** does it need a change to the project's CLI or task runner?
3. **Philosophy / gold-standard?** is it consistent with the project's design philosophy, and does it mirror an existing reference/gold-standard implementation? (a deviation is an ADR, not a silent exception)
4. **Right test *types*?** unit / integration / e2e — plus property/fuzz and chaos/resiliency when the code warrants it.
5. **Config?** does it need a config change (ideally selecting an impl by configuration, not a hard-coded import)?
6. **As simple as possible?** DRY, YAGNI — no duplicated logic, no speculative knobs.
7. **As general as possible?** behind an interface, selected by config, injected explicitly — balanced against YAGNI (Q6 is the ceiling).
8. **Reuse shared abstractions?** does it reuse the patterns/helpers in the shared library tier rather than reinventing them?

If the repo defines `.claude/rules/code-addition-checklist.md`, follow its concrete answers (that file supplies the project's real infra tiers, CLI, test layers, and shared-library packages).

## Phase 3 -- Write the Plan

Write to `docs/spec/plans/YYYY-MM-DD-<slug>.md`:

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

Launch the `spec-review` agent (background; it writes a findings JSON file — poll for the file, then read it once). It runs a single combined alignment + adversarial-assumption review: does the plan fully cover the stated requirements, and what assumptions or unhandled edge cases could break it? Incorporate `must_fix` / `should_fix` before presenting the plan to the user.

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
- NEVER skip the spec-review pass -- it catches the gaps and bad assumptions you missed
