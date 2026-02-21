---
model: opus
---

# RFP — Request for Proposal

Break an epic spec into implementation stories, or create/complete individual stories.

## Arguments
$ARGUMENTS — One of:
- Epic spec path (e.g., `docs/spec/epics/epic-05-data-model.md`) — decompose into stories
- Story number (e.g., `5.3`) — create or work on a specific story
- `status` — show progress across all epics and stories

## Instructions

### 0. Determine Mode

```
IF $ARGUMENTS ends with ".md" AND contains "epic":
    → Mode: DECOMPOSE (break epic into stories)

ELIF $ARGUMENTS matches N.N pattern (e.g., "5.3"):
    → Mode: STORY (create or complete a single story)

ELIF $ARGUMENTS == "status":
    → Mode: STATUS (report progress)

ELSE:
    → Mode: DECOMPOSE with new epic (create spec first, then decompose)
```

---

## Mode: DECOMPOSE — Epic → Stories

### Step 1: Read the Epic

Read the spec file. Extract:
- Epic number and title
- Summary and key changes
- Story count (if stories table exists)
- Architecture references

If the spec doesn't exist yet, create it at `docs/spec/epics/epic-NN-<slug>.md` using the template at `~/.claude/templates/epic.md`.

**Read the template first:** `Read(file_path="~/.claude/templates/epic.md")`

### Step 1b: Cross-Reference Architecture

Check `docs/spec/arch/` for existing architecture diagrams related to this epic. If found, reference them in the epic and stories to provide architectural context.

### Step 2: Explore Affected Code

For each area mentioned in the epic:
1. Read current implementation files
2. Identify interfaces, types, and functions that will change
3. Note test files that need updating
4. Check for cross-cutting concerns (config, migrations, CI)

### Step 3: Decompose into Stories

Break the epic into independently deliverable stories. Each story should:
- Be completable in a single focused session
- Have clear acceptance criteria
- Touch 2-5 files max
- Be testable in isolation

**Numbering convention**: `<epic>.<story>` (e.g., Epic 5 → stories 5.1, 5.2, 5.3, ...)

**Ordering**: Dependencies first. Foundation → clients → services → API → tests → docs.

### Step 4: Write Stories

For each story, create `docs/spec/stories/<epic>.<story>-<slug>.md` using the template at `~/.claude/templates/story.md`.

**Read the template first:** `Read(file_path="~/.claude/templates/story.md")`

Fill in all placeholder fields (`<N>`, `<Title>`, etc.) with story-specific values. The template includes:
- Story metadata (epic, points, status)
- User story (as/want/so that) with acceptance criteria
- Architecture references and diagram
- Checklist: coding patterns, testing, documentation, completion workflow

### Step 5: Update Epic Spec

Update the epic's stories table with links to each story:

```markdown
## Stories

| #   | Story                        | Status | File                                              |
| --- | ---------------------------- | ------ | ------------------------------------------------- |
| N.1 | <Story title>                | Todo   | [N.1-slug.md](../stories/N.1-slug.md)            |
| N.2 | <Story title>                | Todo   | [N.2-slug.md](../stories/N.2-slug.md)            |
```

Update status and points: `**Status**: In Progress **Stories**: N.1--N.M **Points**: <sum>`

### Step 6: Pipeline — Start First Story

After decomposition, automatically chain to implementation of the first story:

```
## RFP Decomposition Complete

**Epic**: <N> — <Title>
**Stories Created**: <count>
**Total Points**: <sum>

| # | Story | Points | Dependencies |
|---|-------|--------|-------------|
| N.1 | <title> | 2 | None |
| N.2 | <title> | 3 | N.1 |
| ... | ... | ... | ... |
```

Use AskUserQuestion:

```
question: "Start implementing the first story?"
header: "Pipeline"
options:
  - "Yes — start /spec on story N.1" - Begin planning and implementing the first story now
  - "No — stop here" - Review the decomposition first, implement later
```

If yes: `Skill(skill='spec', args='docs/spec/stories/N.1-<slug>.md')`

---

## Mode: STORY — Work on a Single Story

### Step 1: Find the Story

Look for `docs/spec/stories/<number>-*.md`. Read it fully.

### Step 2: Check Status

- **Todo** → Implement via `/spec` workflow
- **In Progress** → Continue implementation
- **Complete** → Report completion, suggest next story

### Step 3: Implement

Bridge to the spec workflow for implementation:
```
Skill(skill='spec', args='docs/spec/stories/<epic>.<story>-<slug>.md')
```

The spec workflow handles planning, TDD, and verification.

### Step 4: Story Completion

Story completion is handled by `/spec-verify` when the plan reaches VERIFIED status. The verify phase:
1. Updates the story's `**Status**` field to `Complete`
2. Updates the epic's stories table with the new status
3. Suggests the next uncompleted story in the epic

Stories stay in `docs/spec/stories/` — they are the permanent record of what was built.

---

## Mode: STATUS — Progress Report

### Step 1: Scan All Epics

```bash
ls docs/spec/epics/epic-*.md
```

### Step 2: For Each Epic, Count Stories by Status

```bash
# Read each story file in docs/spec/stories/ and check Status field
grep -l "Status.*Todo\|Status.*In Progress" docs/spec/stories/<epic-num>.* 2>/dev/null | wc -l
grep -l "Status.*Complete" docs/spec/stories/<epic-num>.* 2>/dev/null | wc -l
```

### Step 3: Generate Report

```
## Epic Status Report

| # | Epic | Total | Done | Remaining | Progress |
|---|------|-------|------|-----------|----------|
| 1 | Repository Restructure | 9 | 9 | 0 | ████████░░ 100% |
| 2 | Foundation Fault Tolerance | 8 | 5 | 3 | █████░░░░░ 63% |
| ... | ... | ... | ... | ... | ... |

**Overall**: X/Y stories complete (Z%)
```

---

## Epic Spec Template

For creating new epics (`docs/spec/epics/epic-NN-<slug>.md`), use the template at `~/.claude/templates/epic.md`.

**Read the template first:** `Read(file_path="~/.claude/templates/epic.md")`

The template includes: summary, architecture diagram, stories table, key changes, dependencies, and risks.

## Rules
- NEVER create stories without reading the affected code first
- NEVER skip the architecture diagram in story RFPs
- ALWAYS use the `<epic>.<story>` numbering convention
- Stories stay in `docs/spec/stories/` — status field tracks completion, no file movement
- Points: 1=trivial, 2=small, 3=medium, 5=large (no 4 — force a decision)
