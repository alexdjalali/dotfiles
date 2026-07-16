---
description: Write an Architecture Decision Record for a significant design decision
---

Create an Architecture Decision Record in `docs/adr/` using `~/.claude/templates/adr.md`.

## Steps

1. Scan `docs/adr/` for existing files; determine the next sequential number.
2. Create `docs/adr/NNN-<kebab-slug>.md` from the template.
3. Fill in: title, status (Proposed), context, decision, rationale, consequences, and the alternatives table with rejected options and their trade-offs.
4. Cross-reference related or superseded ADRs.

## Rules

- NEVER write an ADR without a concrete decision statement
- NEVER omit the alternatives table -- rejected options and trade-offs are mandatory
- Status is always `Proposed` until explicitly accepted by the team
- An ADR records a decision, not a to-do list

## Next Step

Ask:

> What's the next step for this decision?
> - `/arch` -- Diagram affected components
> - `/rfp` -- Decompose into stories
> - `/spec` -- Implement directly
> - Done -- Record only

Suggest the chosen command for the user to run — never auto-invoke `/spec` (the user must type it).
