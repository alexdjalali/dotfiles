---
model: opus
description: Generate Mermaid architecture diagrams from codebase analysis
---

Analyze the codebase and produce Mermaid diagrams in `docs/spec/arch/`.

## Steps

1. Explore relevant components using CodeGraph and Semble -- derive from actual code, not imagination.
2. Identify scope from the user's description or a referenced ADR.
3. Generate the appropriate diagrams:
   - **System context**: external actors and system boundaries
   - **Container**: services, databases, queues and their protocols
   - **Component**: internal structure of the changed subsystem
4. Write to `docs/spec/arch/<slug>.md` with Mermaid blocks and a brief narrative.
5. Reference the source ADR (if any) in the file header.

## Rules

- NEVER diagram what you imagine -- read the code first
- One diagram per concern -- don't merge context and component into one block
- Every external system must show its protocol or interface
- Mermaid only -- no ASCII art

## Next Step

Ask:

> Ready to decompose into stories?
> - `/rfp` -- Decompose into stories
> - `/spec` -- Implement directly
> - Done -- Diagrams only
