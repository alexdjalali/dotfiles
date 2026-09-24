---
model: opus
description: Decompose an epic into independently testable stories (docs/spec/epics/ + docs/spec/stories/), or report per-epic story progress with `status`. Use when an epic needs breaking into implementable stories.
argument-hint: "[status | <epic name or file>]"
---

`/roadmap` orders the epics; `/rfp` breaks one into stories. **Input:** `status`, or an epic name/file. **Output:** the story files plus the epic's updated stories table — or a progress table.

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
   - answers the **code-addition checklist**, so the *how* is scoped, not just the *what*: (1) infra/deploy change? (2) CLI/tooling change? (3) consistent with the project's philosophy, mirroring gold-standard/reference code? (4) right test *types* (unit / integration / e2e; fuzz/chaos when warranted) with the right double (`testing.md` *Test Double Policy*) — an integration test names its Docker image? (5) config change? (6) as simple as possible (DRY/YAGNI)? (7) as general as possible — interface + config-selected, capped by (6)? (8) reuses shared-library abstractions? A repo's `.claude/rules/code-addition-checklist.md` supplies the concrete answers;
   - **creates new files → includes a Proposed Repository Structure** (the story template's section): a tree of new/changed paths consistent with the current layout (inspect it first — `codegraph_files` / `ls`). NEVER finalize a story whose layout deviates from the current structure without the user's confirmation.
3. Write each story to `docs/spec/stories/<N>.<M>-<slug>.md` from `~/.claude/templates/story.md` — numbered from the epic (epic 5 → 5.1, 5.2, …), titled with a verb phrase ("Add user authentication", not "User authentication").
4. Update the epic's stories table with relative links and status `Todo`.

## Next Step

Ask:

> Stories written. Start one?
> - `/spec <story-file>` — plan and implement it
> - Done — stories only

`/spec` is suggested for the user to type — never invoked.
