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

4. **Bridge to implementation**: After the ADR is written, suggest running `/spec` to plan the implementation if the decision involves code changes.

## Quality Checks

Verify the Quality Checklist at the bottom of the ADR (included in the template). It covers:
- **Architecture & Design** — real concern, genuine alternatives, honest trade-offs, testing strategy
- **Coding Patterns** — which of the 8 standard patterns apply to this decision
- **Implementation Readiness** — clear for unfamiliar implementer, files identified, rollback plan
