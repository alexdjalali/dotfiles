---
model: opus
description: Write an Architecture Decision Record in docs/adr/, or accept / reject / supersede one. Use before an architectural change — new component or table, library swap, breaking API/schema change, or a pattern deviation.
argument-hint: "[<decision title> | accept|reject|supersede <NNNN> [by <MMMM>]]"
---

**Input:** a decision title/description (create), or `accept <NNNN>` / `reject <NNNN>` / `supersede <NNNN> by <MMMM>` (transition). **Output:** `docs/adr/NNNN-<kebab-slug>.md` from `~/.claude/templates/adr.md`, created or transitioned.

## Create (default)

1. List `docs/adr/`; the next number is the highest + 1, 4 digits zero-padded (`0001`, `0002`, …).
2. Create `docs/adr/NNNN-<kebab-slug>.md` from the template, heading `ADR-NNNN: <Title>`.
3. Fill in context, a concrete decision statement, rationale, consequences, and the alternatives table (rejected options and their trade-offs). `Status: Proposed` — always, for a new ADR.
4. Cross-reference related or superseded ADRs.

## Transition

An ADR is a living record: `Proposed → Accepted | Rejected | Superseded`. A `Proposed` ADR left un-transitioned silently blocks the work that depends on it — resolving it is a real step, not bookkeeping.

- **`accept <NNNN>`** — `Status: Accepted`, dated. The decision is now binding; downstream `/arch`, `/design-doc`, `/spec` may rely on it — name which ones it just unblocked.
- **`reject <NNNN>`** — `Status: Rejected`, dated, with a one-line reason.
- **`supersede <NNNN> by <MMMM>`** — NNNN becomes `Status: Superseded by ADR-MMMM`; MMMM's header back-links to NNNN. Create MMMM first (create mode) if it doesn't exist.

Every transition preserves the original decision text, extends the `Status history` line (`Proposed <date> → Accepted <date>`), and updates every ADR that cross-references NNNN.

## Rules

- NEVER write an ADR without a concrete decision statement.
- NEVER omit the alternatives table — rejected options and trade-offs are mandatory.
- Only an explicit `/adr accept` makes an ADR binding.
- NEVER delete a rejected or superseded ADR — transition its status and keep the history.
- An ADR records a decision, not a to-do list.

## Next Step

On **create**, ask:

> What's next for this decision? (it stays `Proposed` until `/adr accept <NNNN>`)
> - `/arch` — diagram the affected components
> - `/design-doc` — write the detailed technical design
> - `/rfp` — decompose into stories
> - `/spec` — implement directly
> - Done — record only

Run the chosen skill via `Skill()`; `/spec` is suggested for the user to type — never invoked. On **accept**, name the downstream command the decision unblocks (its consequences point to it).
