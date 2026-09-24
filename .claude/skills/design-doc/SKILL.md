---
model: opus
description: Write an implementable technical design (TL;DR, diagrams, state model, alternatives) in docs/spec/design/. Use when a change is too large or subtle to go straight from an ADR to /spec.
argument-hint: <subsystem or feature>
---

The detailed "how it works / how we'll build it" narrative **between an ADR (the decision) and a plan (the tasks)** — richer than a diagram, more concrete than a decision record. **Input:** a subsystem or feature, plus any governing ADR / `/arch` diagrams. **Output:** `docs/spec/design/<slug>.md` from `~/.claude/templates/design.md`.

## Steps

1. **Scope & constraints** — what's covered, explicit non-goals, and hard constraints (external contracts, security, correctness invariants). Reference the governing ADR(s) and any `/arch` diagrams.
2. **Ground it in real code** — read what exists (CodeGraph + Semble + Read); for greenfield, the existing patterns it must match. NEVER design against imagined code.
3. **TL;DR** (the end state in 3–6 steps), **Mermaid diagrams** (sequence / component / flow — one per concern), and a **state/data model** (FSM or schema) when behavior is stateful.
4. **Walk each stage** — what drives it, where the seams/interfaces are (each external seam names its protocol/interface), what's config-selected (`Kind` + factory), what resiliency is built in, what's deferred.
5. **Alternatives considered** and **open questions**.
6. **Write** the file.

## Rules

- Mermaid only, no ASCII art.
- The DECISION belongs in an ADR (`/adr`) — cross-reference it, don't duplicate it.
- Implementable, not aspirational — a reader can plan tasks from it.

## Next Step

Ask:

> Design ready. Next?
> - `/arch` — formal architecture diagrams for the affected components
> - `/rfp` — decompose into stories
> - `/spec` — plan and implement
> - Done — design only

Run the chosen skill via `Skill()`; `/spec` is suggested for the user to type — never invoked.
