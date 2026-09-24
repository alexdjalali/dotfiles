# Linear — Ticket Authoring

Applies **only to repos whose work is tracked in Linear.** If a repo has its own
`.claude/rules/linear.md`, that file wins (it names the team prefix, the docs mirror, etc.).

## Templates

Create tickets from `~/.claude/templates/linear/` — `epic.md`, `story.md`, `bug.md`, `task.md`.
They read like a human wrote them: **Background → Requirements → Acceptance Criteria** (+ Out of
Scope / References). Keep them that way. Engineering discipline — definition-of-done checklists,
coverage gates, layer/import rules — lives in the repo's own rules and `docs/spec/` artifacts and
applies at *implementation* time; it does **not** belong in the ticket body. A ticket a teammate
can't skim in ten seconds is too machine-like.

## What Linear renders

Markdown, checklists, tables, collapsible sections (`>>>`), code blocks, images / file uploads,
Figma / Loom / YouTube embeds, and **Mermaid** diagrams — type `/diagram` or paste a fenced
```mermaid block (`erDiagram` renders ERDs). Add a diagram when it clarifies (an ERD or dependency
graph in an epic; a sequence/flow in a genuinely complex story) — not by default; an empty diagram
slot is noise.

## Diagrams — which ticket type needs what

Match the diagram to the question the ticket asks, and reach for it only when prose can't carry
it. **≤1 diagram per ticket** (2 only for a before→after pair) — more than that means it's a design
doc, not a ticket.

- **Epic — "what will the system *be*?"** (structure)
  - Primary: **C4 Container/Context** (topology) · **ERD** (adds/reshapes entities)
  - Situational: **flowchart** story-dependency graph · **state** for a domain lifecycle
  - Skip: sequence, class (too fine-grained) · Gantt (Linear's timeline owns scheduling)
- **Story — "how does it *behave*?"** (mechanism)
  - Primary: **sequence** (≥2 services or async) · **class** (new `core` interface + `Kind` impls + decorator) · **Figma**/**journey** (frontend)
  - Situational: **state** (owns a status machine) · **flowchart** (branching logic)
  - Skip: C4, full ERD
- **Bug — "*where* did it break?"** (failure)
  - Primary: **screenshot/annotated image** (any UI bug) · **sequence marking the break** (cross-service) · **state** (illegal/stuck transition)
  - Situational: **Loom** repro · **timeline** (incident)
  - Skip: C4, ERD, class
- **Task — "*what changes*?"** (transformation)
  - Primary: **flowchart/class before→after** (refactor) · **architecture** (infra target) · **flowchart steps / timeline** (migration)
  - Situational: **gitgraph** (release/CI) · **XY chart** (perf before/after)
  - Spike: no diagram — its *output* lands in a `/design` or `/rca` doc; link it

**Beta types** (`architecture`, `packet`, `xychart`, `sankey`, `block`, `radar`) depend on Linear's
Mermaid version — verify once, or fall back to `flowchart`/`C4`. No `docs/spec/` pipeline? Inline the
diagram in the ticket; if the repo keeps design docs, author durable diagrams there and link/embed
them (the ticket isn't their source of truth).

## Rules

- **Mirror + link.** A ticket usually mirrors a `docs/spec/` artifact (story / epic / RCA). Keep the
  two cross-referenced: the markdown owns design + acceptance criteria, Linear owns execution state.
- **⛔ Never fabricate a ticket id.** Read it from the story / plan / PR / branch, or ask. Use a
  `(unticketed — create in <TEAM>)` placeholder when none exists yet — a wrong id silently mis-tracks work.
- **Mutate Linear only through an authenticated Linear MCP server.** If it's unavailable, "update the
  ticket" means preparing the text for the user — never claim a ticket changed unless the call succeeded.
- Reference the ticket id in the branch / PR / commit so Linear auto-links the work.
- **⛔ No ticket ids in code comments.** Ticket ids rot and couple the source to the tracker — keep
  them in the ticket / PR / commit, per the language `standards-*.md`.
