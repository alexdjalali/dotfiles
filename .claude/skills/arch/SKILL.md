---
model: opus
description: Generate Mermaid architecture diagrams (context / container / component) from the real code into docs/spec/arch/. Use after an ADR, or when asked to diagram how a system fits together.
---

**Input:** a scope — the user's description or a referenced ADR. **Output:** `docs/spec/arch/ARCH-NNN-<slug>.md` (next 3-digit number in the folder — the name stories link to): Mermaid diagrams plus a brief narrative, the source ADR (if any) referenced in the header.

## Steps

1. **Scope** — from the description or ADR: which system, subsystem, or change.
2. **Explore** the relevant components with CodeGraph + Semble and read the code. NEVER diagram what you imagine.
3. **Diagram** what the scope needs, one diagram per concern:
   - **System context** — external actors and system boundaries.
   - **Container** — services, databases, queues, and the protocols between them.
   - **Component** — the internal structure of the changed subsystem.
4. **Write** the file with the Mermaid blocks and narrative.

## Rules

- One diagram per concern — never merge context and component into one block.
- Every external system shows its protocol or interface.
- Mermaid only — no ASCII art.

## Next Step

Ask:

> Diagrams written. Next?
> - `/rfp` — decompose into stories
> - `/design-doc` — write the detailed design first
> - `/spec` — implement directly
> - Done — diagrams only

Run the chosen skill via `Skill()`; `/spec` is suggested for the user to type — never invoked.
