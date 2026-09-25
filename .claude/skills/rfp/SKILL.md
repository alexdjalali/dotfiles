---
name: rfp
model: claude-opus-4-8
effort: high
description: Decompose an epic into independently testable stories (docs/spec/epics/ + docs/spec/stories/), or report per-epic story progress with `status`. Use when an epic needs breaking into implementable stories.
argument-hint: "[status | <epic name or file>]"
---

`/rfp` breaks an epic into stories. **Input:** `status`, or an epic name/file. **Output:** the story files plus the epic's updated stories table — or a progress table.

## `status`

Scan `docs/spec/epics/` and `docs/spec/stories/`; per epic, count stories by `**Status**` (Todo / In Progress / Complete) and print:

```
| #  | Epic                   | Total | Done | Left | Progress        |
|----|------------------------|-------|------|------|-----------------|
| 1  | Auth Overhaul          |   7   |   5  |  2   | ########--  71% |
```

## Decompose an epic

1. Read `docs/spec/epics/epic-NN-<slug>.md` — create it from `~/.claude/templates/epic.md` first if missing.
2. Break it into **3–10 stories**. Each story:
   - has concrete, testable acceptance criteria, at least one checkable at the unit level — NEVER a story testable only end-to-end;
   - is implementable without an unfinished sibling — NEVER depend on one;
   - **fits one commit** — `/spec` makes exactly one commit per story, so each story leaves the tree green on its own and is small enough to review as a unit (≤ 12 plan tasks);
   - answers the **code-addition checklist** (`~/.claude/templates/code-addition-checklist.md`), so the *how* is scoped, not just the *what*;
   - **creates new files → includes a Proposed Repository Structure** (the story template's section): a tree of new/changed paths consistent with the current layout (inspect it first — `codegraph_files` / `ls`). NEVER finalize a story whose layout deviates from the current structure without the user's confirmation.
3. Write each story to `docs/spec/stories/<N>.<M>-<slug>.md` from `~/.claude/templates/story.md` — numbered from the epic (epic 5 → 5.1, 5.2, …), titled with a verb phrase ("Add user authentication", not "User authentication").
4. Update the epic's stories table with relative links and status `Todo`.

## Next Step

Ask:

> Stories written. Start one?
> - `/spec <epic-file>` — plan and implement every open story, one commit each, reviewed and gated once at the end
> - `/spec <story-file>` — plan and implement just one
> - Done — stories only

`/spec` is user-typed.
