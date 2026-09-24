---
model: opus
description: Write an Architecture Decision Record, or transition an existing one (accept/reject/supersede)
argument-hint: "[<decision title> | accept|reject|supersede <NNNN> [by <MMMM>]]"
---

Create a new ADR in `docs/adr/`, or move an existing one through its lifecycle. Dispatch on args:

- `accept <NNNN>` / `reject <NNNN>` / `supersede <NNNN> by <MMMM>` → **transition** (see Lifecycle).
- anything else (a decision title/description) → **create** a new ADR.

## Create (default)

Uses `~/.claude/templates/adr.md`.

1. Scan `docs/adr/` for existing files; determine the next sequential number (4 digits, zero-padded: `0001`, `0002`, …).
2. Create `docs/adr/NNNN-<kebab-slug>.md` from the template (heading `ADR-NNNN: <Title>`).
3. Fill in: title, status (Proposed), context, decision, rationale, consequences, and the alternatives table with rejected options and their trade-offs.
4. Cross-reference related or superseded ADRs.

## Lifecycle transitions

An ADR is a living record: `Proposed → Accepted | Rejected | Superseded`. A `Proposed` ADR left un-transitioned silently blocks the work that depends on it — resolving it is a real step, not bookkeeping.

- **`/adr accept <NNNN>`** — set `Status: Accepted`, stamp the date. The decision is now binding; downstream `/arch` / `/design-doc` / `/spec` may rely on it. Note which of them just unblocked.
- **`/adr reject <NNNN>`** — set `Status: Rejected`, stamp the date, add a one-line reason. Keep the record — do not delete it.
- **`/adr supersede <NNNN> by <MMMM>`** — set NNNN `Status: Superseded by ADR-MMMM` and add a back-link from MMMM's header to NNNN. Create MMMM first (via create mode) if it doesn't exist.

Every transition: preserve the original decision text, extend the `Status history` line (`Proposed <date> → Accepted <date>`), and update any ADR that cross-references NNNN.

## Rules

- NEVER write an ADR without a concrete decision statement
- NEVER omit the alternatives table -- rejected options and trade-offs are mandatory
- A new ADR is always `Proposed` -- only an explicit `/adr accept` makes it binding
- NEVER delete a rejected or superseded ADR -- transition its status, keep the history
- An ADR records a decision, not a to-do list

## Next Step

On **create**, ask:

> What's the next step for this decision?
> - `/design-doc` -- Write the detailed technical design
> - `/arch` -- Diagram affected components
> - `/rfp` -- Decompose into stories
> - `/spec` -- Implement directly
> - Done -- Record only

Suggest the chosen command for the user to run -- never auto-invoke `/spec`.

On **accept**, name the downstream command the decision now unblocks (its consequences point to it).
