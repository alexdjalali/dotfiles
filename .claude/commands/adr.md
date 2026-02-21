---
model: opus
---

# Architecture Decision Record

Generate a numbered ADR before any structural or architectural change.

## Arguments
$ARGUMENTS — Brief title for the decision (e.g., "use-redis-for-caching", "switch-to-grpc")

## Instructions

1. **Find the next ADR number**: Look in `docs/adr/` for existing ADRs. If none exist, create the directory and start at `0001`.

2. **Create the ADR file**: `docs/adr/NNNN-<title>.md` using the template at `~/.claude/templates/adr.md`.

   **Read the template first:** `Read(file_path="~/.claude/templates/adr.md")`

   The template includes: context, decision, alternatives table, architecture diagram, consequences, implementation notes, and quality checklist (architecture, coding patterns, implementation readiness).

3. **Fill in the template** based on the context provided in `$ARGUMENTS` and any relevant codebase context. Ask clarifying questions if the decision scope is unclear.

4. **Pipeline: Next Step**

   After the ADR is written, determine the next step in the architect → engineer pipeline.

   Use AskUserQuestion:

   ```
   question: "What's the next step for this decision?"
   header: "Pipeline"
   options:
     - "/arch — Diagram affected architecture" - Visualize the components and data flows this decision impacts
     - "/rfp — Decompose into stories" - Break this into implementable epics and stories
     - "/spec — Implement directly" - Plan and implement this as a single feature
     - "Done — Record only" - No implementation action needed right now
   ```

   Based on the user's choice, invoke the corresponding skill:
   - `/arch`: `Skill(skill='arch', args='<scope derived from ADR context>')` — pass the ADR path so arch can reference it
   - `/rfp`: `Skill(skill='rfp', args='<epic description from ADR>')` — creates an epic in `docs/spec/epics/`
   - `/spec`: `Skill(skill='spec', args='<task description from ADR>')` — plans and implements directly
   - Done: End the workflow

## Quality Checks

Verify the Quality Checklist at the bottom of the ADR (included in the template). It covers:
- **Architecture & Design** — real concern, genuine alternatives, honest trade-offs, testing strategy
- **Coding Patterns** — which of the 8 standard patterns apply to this decision
- **Implementation Readiness** — clear for unfamiliar implementer, files identified, rollback plan
