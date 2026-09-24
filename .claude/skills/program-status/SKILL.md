---
model: opus
description: Report what is actually left to build — scan every epic, story, plan, audit, and RCA, verify done-ness against the code, emit the real backlog (optionally to docs/spec/roadmap/status.md). Use for status / what's-left questions.
argument-hint: "[write]"
---

The one view that answers **"what is actually left to build?"** — a deduplicated, confidence-checked backlog across the whole `docs/spec/` pipeline (`/rfp status` and `/roadmap status` unified, one level up). **Input:** optional `write`. **Output:** the backlog in chat; persisted when `write` is passed or a consolidated backlog doc already exists. Report only — it plans nothing (that's `/roadmap` / `/rfp` / `/spec`).

## Steps

1. **Inventory** every artifact in `docs/spec/{epics,stories,audits,rca}/` and the plans in gitignored `docs/local/plans/` (local to this checkout — say so if absent); note each declared Status.
2. **Cross-check against the code** — NEVER trust a Status field over it. Verify each epic/story/plan's done-ness against what actually builds and runs (CodeGraph + Semble + the implementing files); classify plans by *actual* completion, not the header.
3. **Split into tracks** — **product build-out** (unfinished epics/stories) vs **refactor & conformance** (open audits + their remediation epics).
4. **Map each open audit** to its implementing plan/epic; flag audits with none as unplanned.
5. **Plan registers** — genuinely open · stale-`PENDING`-but-done (list for flipping to VERIFIED — NEVER re-open) · superseded/moot · non-plans (working notes).
6. **Sequencing** — critical path first, plus governing-decision blockers (un-accepted ADRs, e.g. a `Proposed` ADR gating a track).
7. **Persist** (when asked): find an existing consolidated backlog under `docs/spec/` (e.g. `remaining-work.md`, `status.md`) and refresh it **in place**; otherwise write `docs/spec/roadmap/status.md` from `~/.claude/templates/status.md`.

## Rules

- NEVER pad — a short backlog is a good sign; cite the artifact path on every line.

## Next Step

Ask:

> Backlog assembled. Act on it?
> - `/roadmap` — re-sequence the epics around it
> - `/rfp <epic>` — decompose the next epic
> - `/spec` — plan the top item
> - Done — status only

Run the chosen skill via `Skill()`; `/spec` is suggested for the user to type — never invoked.
