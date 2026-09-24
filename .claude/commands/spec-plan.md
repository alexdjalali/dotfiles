---
description: Plan an implementation -- explore the codebase, design tasks, verify the plan, get approval
model: opus
---

## Phase 1 -- Explore

1. **Requirements source.** If given a story (`docs/spec/stories/...`), read it first: its **acceptance criteria are the requirements**, its code-addition answers and Proposed Repository Structure seed the design, and it is cited under the plan's References. Likewise cite any ADR / design doc passed in.
2. If the request is ambiguous, ask one clarifying question before proceeding.
3. Explore the codebase with CodeGraph and Semble:
   - Find all files the change will touch
   - Find similar existing features and the patterns they use
   - Trace call chains upstream and downstream from the affected area
4. Identify: entry points, data models, tests to extend, files to create or modify.

## Phase 2 -- Design

Design 3-12 implementation tasks. Each task must be:
- Independently testable (a failing test can be written for it in isolation)
- Small enough to complete in one focused TDD cycle
- Sequenced so later tasks build on earlier ones without circular dependencies
- Aligned with the repo's existing patterns — reuse established helpers, naming, and conventions rather than introducing parallel ones (consistency, DRY)

**Code-addition checklist.** For work that adds or changes code, make the plan answer these eight before you finalize the tasks — a "yes" to infra/CLI/config is its own task, not an afterthought:

1. **Infra/deploy?** does it need a dev environment change and a staging/prod (IaC) change?
2. **CLI/tooling?** does it need a change to the project's CLI or task runner?
3. **Philosophy / gold-standard?** is it consistent with the project's design philosophy, and does it mirror an existing reference/gold-standard implementation? (a deviation is an ADR, not a silent exception)
4. **Right test *types*, with the right double** (per `testing.md` *Test Double Policy*)? unit / integration / e2e — plus property/fuzz and chaos/resiliency when warranted. A task that adds an integration test **names the Docker image + testcontainers module** (e.g. `postgres:16` via `testcontainers-go` / `testcontainers[postgres]` / `@testcontainers/postgresql`).
5. **Config?** does it need a config change (ideally selecting an impl by configuration, not a hard-coded import)?
6. **As simple as possible?** DRY, YAGNI — no duplicated logic, no speculative knobs.
7. **As general as possible?** behind an interface, selected by config, injected explicitly — balanced against YAGNI (Q6 is the ceiling).
8. **Reuse shared abstractions?** does it reuse the patterns/helpers in the shared library tier rather than reinventing them?

If the repo defines `.claude/rules/code-addition-checklist.md`, follow its concrete answers (that file supplies the project's real infra tiers, CLI, test layers, and shared-library packages).

## Phase 3 -- Write the Plan

Write the plan from **`~/.claude/templates/plan.md`** (the single plan format) to `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored — local working docs, never committed), with header `Type: Feature`, `Status: PENDING`, `Approved: No`, `Iteration: 1`.

- Always fill: Summary, **Goal Verification** (truths + artifacts), Scope, Progress Tracking (Done/Left counters), Implementation Tasks (each with Files, Definition of Done, Verify), Testing Strategy, Risks, **References** (the story / ADR `docs/adr/NNNN-<slug>.md` / design doc it came from).
- **Proposed Repository Structure** — include ONLY if new files are created. Inspect the real tree first (`codegraph_files` / `ls`; the monorepo standard is `~/.claude/templates/repo.md`); if the needed layout DEVIATES from the current structure, STOP and ask the user to confirm before finalizing.
- A task may carry a `Trivial:` justification only within the limits the template states (audited at verify).
- Delete the Bugfix block and any other optional section that doesn't apply.

## Phase 4 -- Verify the Plan

Launch the `spec-review` agent with all four inputs:

- `plan_file` — the plan path
- `user_request` — the user's original request verbatim (plus the story's acceptance criteria when planning from a story)
- `clarifications` — optional: answers gathered in Phase 1
- `output_path` — `docs/local/plans/.spec-review-<slug>.json` (co-located with the plan, gitignored)

It runs in the background, does a single combined alignment + adversarial-assumption review (does the plan fully cover the stated requirements, and what assumptions or unhandled edge cases could break it?), and writes the findings JSON — poll for the file, then Read it once. Incorporate `must_fix` / `should_fix` before presenting the plan to the user.

## Phase 5 -- Approval

Present the complete plan. Ask:

> Plan ready. Approve to begin implementation?
> - Approve -- Start implementing
> - Revise -- [specify changes]
> - Cancel -- Stop here

On approval: set `Approved: Yes` in the plan file, then immediately continue the chain — call `Skill(skill='spec-implement')` in the same turn. Do NOT stop and wait for the user to re-type it; plan approval was the manual gate.

## Rules

- NEVER begin implementation without explicit approval
- NEVER design more than 12 tasks -- split into multiple plans if needed
- NEVER include tasks that don't trace directly to the user's request (or the story's acceptance criteria)
- NEVER add new files without a Proposed Repository Structure that matches the current repo layout -- if the layout must deviate, ask the user before finalizing
- NEVER skip the spec-review pass -- it catches the gaps and bad assumptions you missed
- NEVER plan an integration test that mocks its dependency or uses an in-memory substitute -- name the image + testcontainers module in the task
