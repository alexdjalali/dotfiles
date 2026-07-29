---
model: opus
description: Decompose an epic into independently testable stories, or show epic/story progress
argument-hint: "[status | <epic name or file>]"
---

If args = "status", run the status report. Otherwise decompose the named epic.

The epic-level sequencing that feeds this -- dependencies, phasing, and the critical path -- is owned by `/roadmap` (one level up). `/roadmap` orders the epics; `/rfp` breaks one into stories.

## Status Report (`/rfp status`)

Scan `docs/spec/stories/` and `docs/spec/epics/`. For each epic, count stories by status (Todo / In Progress / Complete). Output:

```
| #  | Epic                   | Total | Done | Left | Progress        |
|----|------------------------|-------|------|------|-----------------|
| 1  | Auth Overhaul          |   7   |   5  |  2   | ########--  71% |
```

## Decompose an Epic

1. Read the epic from `docs/spec/epics/epic-NN-<slug>.md` (create it first with `~/.claude/templates/epic.md` if it doesn't exist).
2. Break the epic into 3-10 independently testable stories. Each story must:
   - Have a single, testable acceptance criterion
   - Be implementable without depending on an unfinished sibling
   - Answer the **code-addition checklist** so the *how* is scoped, not just the *what*: (1) infra/deploy change? (2) CLI/tooling change? (3) consistent with the project's philosophy & mirrors gold-standard/reference code? (4) right test *types* with the right double — unit (mock the boundary) / integration (real dep in a Docker container via testcontainers; name the image) / e2e; fuzz/chaos when warranted; no fakes / in-memory substitutes? (5) config change? (6) as simple as possible (DRY/YAGNI)? (7) as general as possible — interface + config-selected, balanced against YAGNI? (8) reuses shared-library abstractions? If the repo defines `.claude/rules/code-addition-checklist.md`, fold in its concrete answers.
   - **Propose a repository structure when the story creates new files** — a tree of the new/changed paths (see the *Proposed Repository Structure* section of `~/.claude/templates/story.md`), consistent with the current repo layout (inspect it first — `codegraph_files` / `ls`). If the needed layout deviates from the current structure, ask the user to confirm before finalizing the story.
3. Write each story to `docs/spec/stories/<epic-N>.<story-N>-<slug>.md` using `~/.claude/templates/story.md`.
4. Update the epic's stories table with relative links and initial status `Todo`.

## Rules

- NEVER create stories testable only end-to-end -- each must have a unit-level acceptance criterion
- NEVER make a story depend on an unfinished sibling story
- Story titles are verb phrases: "Add user authentication", not "User authentication"
- Number stories from the epic number: epic 5 produces stories 5.1, 5.2, ...
- NEVER let a story add new files without a Proposed Repository Structure that matches the current repo layout -- if the layout must deviate, ask the user first

## Next Step

After creating stories, ask:

> Start implementing a story?
> - `/spec <story-file>` -- Plan and implement
> - Done -- Stories created only
