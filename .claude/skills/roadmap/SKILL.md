---
model: opus
description: Build or refresh the program roadmap (epic dependency map, phasing, critical path, milestones) in docs/spec/roadmap/. Use to sequence epics before /rfp, or with `status` to refresh against what shipped.
argument-hint: "[status | <program or phase>]"
---

The roadmap sits **above epics**: it sequences them, maps their dependencies, and fixes the critical path that `/rfp` then decomposes into stories (`/rfp status` owns story-level progress). **Input:** `status` (refresh against reality) or a program/phase to plan. **Output:** `docs/spec/roadmap/<slug>.md` from `~/.claude/templates/roadmap.md`, created or updated.

## Steps

1. **Inventory** epics in `docs/spec/epics/` and their real status, **cross-checked against the code** — NEVER call an epic done from its `Status` field alone; verify against what actually builds and runs.
2. **Dependency graph** — only real dependencies (an epic genuinely needs another's output), not aspirational ordering; render as a status-colored Mermaid `graph TD`.
3. **Phase** the work — group epics by dependency; identify tracks that run in parallel.
4. **Critical path** — the longest sequential chain, stated explicitly, plus what parallelizes against it.
5. **Milestones** (each with a done-gate: a demo, an audit, an E2E), open risks, and pending decisions (link the un-accepted ADRs).
6. **Write** the file; keep any executive-summary variant short.

## Rules

- The roadmap plans SEQUENCE, not implementation — no task-level detail (that's `/spec`).

## Next Step

Ask:

> Roadmap set. Decompose the next epic?
> - `/rfp <epic>` — break an epic into stories
> - `/rfp status` — story-level progress across epics
> - Done — roadmap only

Run the chosen skill via `Skill()`.
