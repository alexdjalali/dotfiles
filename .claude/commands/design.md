---
model: opus
description: Write a technical design document for a subsystem or feature in docs/spec/design/
argument-hint: <subsystem or feature>
---

Write an implementable technical design in `docs/spec/design/` using `~/.claude/templates/design.md`.

A design doc is the detailed "how it works / how we'll build it" narrative that sits **between an ADR (the decision) and a plan (the tasks)** -- richer than a diagram, more concrete than a decision record. Reach for `/design` when a change is too large or subtle to jump straight from `/adr` to `/spec`: it needs a written walkthrough, diagrams, and a state model the team reviews first (e.g. `design/ingestion.md`, `design/ownership-and-byoc-architecture.md`).

## Steps

1. Establish **scope and constraints** -- what's covered, explicit non-goals, and the hard constraints (external contracts, security, correctness invariants). Reference the governing ADR(s) and any `/arch` diagrams.
2. **Derive from real code** where it exists (CodeGraph + Semble + read); for greenfield, ground the design in the existing patterns it must match -- never design against imagined code.
3. Produce a **TL;DR** (end-state in 3-6 steps), **Mermaid diagram(s)** (sequence / component / flow -- one per concern), and a **state/data model** (FSM or schema) when there's stateful behavior.
4. Walk each stage: what drives it, where the seams/interfaces are, what's config-selected (`Kind`/factory), what resiliency is built in, what's deferred.
5. Record **alternatives considered** and **open questions**.
6. Write `docs/spec/design/<slug>.md` from the template.

## Rules

- NEVER design against imagined code -- read the actual code, or the pattern it must match, first
- One diagram per concern; Mermaid only, no ASCII art
- Every external seam names its protocol/interface
- A design explains a solution; the DECISION belongs in an ADR (`/adr`) -- cross-reference, don't duplicate
- Keep it implementable, not aspirational -- a reader should be able to plan tasks from it

## Next Step

Ask:

> Design ready. Next?
> - `/arch` -- formal architecture diagrams for the affected components
> - `/rfp` -- decompose into stories
> - `/spec` -- plan and implement
> - Done -- design only
