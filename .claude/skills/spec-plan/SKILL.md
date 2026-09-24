---
description: /spec feature planning — explore the code, design 3–12 testable tasks, write the plan, run spec-review, get approval. Started by /spec, not unprompted.
model: opus
---

**Input:** a feature request, or a story / ADR / design-doc path. **Output:** an approved plan at `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored), then the hand-off to `spec-implement`. No production or test code before approval.

## Phase 1 — Explore

1. **Requirements source.** Given a story (`docs/spec/stories/…`), read it first: its **acceptance criteria are the requirements**; its code-addition answers and Proposed Repository Structure seed the design. Cite it — and any ADR / design doc passed in — under References.
2. Ambiguous request → ask one clarifying question before continuing.
3. With CodeGraph + Semble: find every file the change touches, similar features and the patterns they use, and the call chains upstream and downstream of the affected area.
4. Note entry points, data models, tests to extend, and files to create or modify.

## Phase 2 — Design

Design **3–12 tasks** — NEVER more than 12; split into several plans instead. Each task is independently testable (a failing test can be written for it alone), one focused TDD cycle, sequenced without circular dependencies, and aligned with the repo's existing patterns (reuse its helpers, naming, conventions — no parallel ones). NEVER include a task that doesn't trace to the request or the story's acceptance criteria.

**Code-addition checklist** — the plan answers all eight before tasks are final; a "yes" to infra/CLI/config is its own task, not an afterthought:

1. **Infra/deploy?** a dev-environment change and a staging/prod (IaC) change?
2. **CLI/tooling?** a change to the project's CLI or task runner?
3. **Philosophy / gold standard?** consistent with the project's design philosophy, mirroring an existing reference implementation? (a deviation is an ADR, not a silent exception)
4. **Right test *types*, right double** (`testing.md` *Test Double Policy*)? unit / integration / e2e, plus property/fuzz and chaos/resiliency when warranted. A task that adds an integration test **names the Docker image + testcontainers module** (e.g. `postgres:16` via `testcontainers-go` / `testcontainers[postgres]` / `@testcontainers/postgresql`) — NEVER plan one that mocks its dependency or uses an in-memory substitute.
5. **Config?** a config change (ideally selecting an impl by configuration, not a hard-coded import)?
6. **As simple as possible?** DRY, YAGNI — no duplicated logic, no speculative knobs.
7. **As general as possible?** behind an interface, config-selected, injected explicitly — Q6 is the ceiling.
8. **Reuse shared abstractions?** the shared-library patterns/helpers rather than reinventions?

A repo's `.claude/rules/code-addition-checklist.md` supplies the concrete answers (real infra tiers, CLI, test layers, shared-library packages) — follow it when present.

## Phase 3 — Write the plan

From `~/.claude/templates/plan.md` (the single plan format), header `Type: Feature`, `Status: PENDING`, `Approved: No`, `Iteration: 1`.

- Always fill: Summary, **Goal Verification** (truths + artifacts), Scope, Progress Tracking (Done/Left), Implementation Tasks (each with Files, Definition of Done, Verify), Testing Strategy, Risks, **References** (the story / `docs/adr/NNNN-<slug>.md` / design doc).
- **Proposed Repository Structure** — required whenever new files are created, omitted otherwise. Inspect the real tree first (`codegraph_files` / `ls`; standard: `~/.claude/templates/repo.md`); if the layout must DEVIATE from the current structure, STOP and ask the user before finalizing.
- `Trivial:` only within the limits the template states (audited at verify).
- Delete the Bugfix block and every optional section that doesn't apply.

## Phase 4 — Review the plan

NEVER skip this pass — it catches the gaps and bad assumptions you missed. Launch `Agent(subagent_type='spec-review')` with:

- `plan_file` — the plan path
- `user_request` — the original request verbatim (plus the story's acceptance criteria when planning from one)
- `clarifications` — Phase 1 answers (optional)
- `output_path` — `docs/local/plans/.spec-review-<slug>.json`

It runs in the background, does one combined alignment + adversarial-assumption review (full coverage of the requirements; assumptions or edge cases that could break the plan), and writes JSON. Poll for the file with a bash existence loop, Read it once, and fold in every `must_fix` / `should_fix` before presenting.

## Phase 5 — Approval

Present the complete plan and ask:

> Plan ready. Approve to begin implementation?
> - Approve — start implementing
> - Revise — [specify changes]
> - Cancel — stop here

NEVER begin implementation without an explicit Approve. On approval, set `Approved: Yes` and call `Skill(skill='spec-implement')` in the same turn — approval was the manual gate; don't wait for the user to re-type anything.
