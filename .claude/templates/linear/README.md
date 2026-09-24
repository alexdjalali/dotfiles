# Linear Ticket Templates — Guide

Templates: `epic.md`, `story.md`, `bug.md`, `task.md` (this directory). The authoring rules (mirror + link,
never fabricate an id, mutate only via an authenticated Linear MCP) live in `~/.claude/rules/linear.md`.

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
