---
model: opus
description: Build or refresh the program roadmap (dependency map, phasing, critical path) in docs/spec/roadmap/
argument-hint: "[status | <program or phase>]"
---

Create or refresh program-level planning artifacts in `docs/spec/roadmap/` using `~/.claude/templates/roadmap.md`.

The roadmap sits **above epics**: it sequences them, maps dependencies, and defines the critical path that `/rfp` then decomposes into stories. Where `/rfp status` reports story-level progress, `/roadmap` owns the epic-level plan (models: `roadmap/epic-dependency-map.md`, `roadmap/program-roadmap.md`).

If args = "status", refresh the roadmap against reality. Otherwise build/update the roadmap for the named program or phase.

## Steps

1. Inventory epics and their real status from `docs/spec/epics/` **cross-checked against the code** -- story/epic `Status` fields drift, so verify done-ness against what actually builds and runs.
2. Derive the **dependency graph** -- which epic's output another genuinely needs. Render it as a status-colored Mermaid `graph TD`.
3. **Phase** the work: group epics by dependency; identify tracks that can run in parallel.
4. Compute the **critical path** (longest sequential chain) and note what parallelizes against it.
5. Capture milestones (each with a done-gate: a demo, an audit, an E2E), open risks, and pending decisions (link the un-accepted ADRs).
6. Write/update `docs/spec/roadmap/<slug>.md`; keep any executive-summary variant short.

## Rules

- NEVER assert an epic is done from its `Status` field alone -- cross-check the code
- Dependencies must be real (an epic genuinely needs another's output), not aspirational ordering
- Mermaid for the graph; keep the critical path explicit
- The roadmap plans SEQUENCE, not implementation -- no task-level detail (that's `/spec`)

## Next Step

Ask:

> Roadmap set. Decompose the next epic?
> - `/rfp <epic>` -- break an epic into stories
> - `/rfp status` -- story-level progress across epics
> - Done -- roadmap only
