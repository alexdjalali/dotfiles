---
name: design-doc
model: opus
description: Write an implementable technical design (TL;DR, diagrams, state model, alternatives) in docs/spec/design/, or with `arch` just the architecture diagrams (context / container / component) in docs/spec/arch/. Use when a change is too large or subtle to go straight from an ADR to /spec, or to diagram how a system fits together.
argument-hint: "[arch] <subsystem or feature | ADR>"
---

The "how it works / how we'll build it" **between an ADR (the decision) and a plan (the tasks)**. **Input:** a subsystem, feature, or governing ADR. **Output:** `docs/spec/design/<slug>.md` from `~/.claude/templates/design.md` — or, with `arch`, `docs/spec/arch/ARCH-NNN-<slug>.md` (next 3-digit number; the name stories link to).

## Steps

1. **Scope & constraints** — what's covered, non-goals, hard constraints (external contracts, security, invariants); cite the governing ADR(s).
2. **Ground it in real code** (CodeGraph + Semble + Read) — for greenfield, the patterns it must match. NEVER design or diagram imagined code.
3. **Diagrams** — Mermaid only, one per concern, every external system showing its protocol: **context** (actors, boundaries) · **container** (services, stores, queues) · **component** (the changed subsystem's internals) · sequence / state where behavior needs it.
4. **`arch` stops here** — write the diagrams with a brief narrative and the source ADR in the header.
5. **Design only:** a **TL;DR** (end state in 3–6 steps), a **state/data model** when stateful, then **each stage** — what drives it, its seams and interfaces, what's config-selected (`Kind` + factory), built-in resiliency, what's deferred. Then **alternatives considered** and **open questions**. Write the file.

## Rules

- The DECISION belongs in an ADR — cross-reference it, don't duplicate it.
- Implementable, not aspirational — a reader can plan tasks from it.

## Next Step

Ask: `/rfp` (decompose into stories) · `/spec` (user-typed) · done.
