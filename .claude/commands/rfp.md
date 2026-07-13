---
description: Decompose an epic into independently testable stories, or show epic/story progress
---

If args = "status", run the status report. Otherwise decompose the named epic.

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
3. Write each story to `docs/spec/stories/<epic-N>.<story-N>-<slug>.md` using `~/.claude/templates/story.md`.
4. Update the epic's stories table with relative links and initial status `Todo`.

## Rules

- NEVER create stories testable only end-to-end -- each must have a unit-level acceptance criterion
- NEVER make a story depend on an unfinished sibling story
- Story titles are verb phrases: "Add user authentication", not "User authentication"
- Number stories from the epic number: epic 5 produces stories 5.1, 5.2, ...

## Next Step

After creating stories, ask:

> Start implementing a story?
> - `/spec <story-file>` -- Plan and implement
> - Done -- Stories created only
