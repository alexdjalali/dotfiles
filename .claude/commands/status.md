---
model: opus
description: Consolidated program status -- scan epics/stories/plans/audits/rca, cross-check against code, emit the real backlog
argument-hint: "[status | write]"
---

Produce the one view that answers **"what is actually left to build?"** -- a deduplicated, confidence-checked backlog synthesized from every epic, story, plan, audit, and RCA, cross-checked against the code (declared status fields drift). This is `/rfp status` and `/roadmap status` unified and one level up: it spans the whole `docs/spec/` pipeline, not a single folder.

By default it reports to chat. Persist it when asked (`/status write`) or when a consolidated backlog doc already exists.

## Steps

1. Inventory every artifact under `docs/spec/{epics,stories,plans,audits,rca}/`; note each item's declared Status.
2. **Cross-check against the code** -- the declared Status is unreliable. For each epic/story/plan, verify done-ness against what actually builds and runs (CodeGraph + Semble + read the implementing files). Classify plans by *actual* completion, not the header.
3. Split the backlog into tracks: **product build-out** (unfinished epics/stories) vs **refactor & conformance** (open audits + their remediation epics).
4. Map each open code audit to its implementing plan/epic; flag audits with no plan as unplanned.
5. Build the plan registers: **genuinely open**, **stale-`PENDING`-but-done** (flip to VERIFIED, do NOT re-open), **superseded/moot**, and **non-plans** (working notes).
6. Add a suggested sequencing (critical path first) and the governing-decision blockers (un-accepted ADRs -- e.g. a `Proposed` ADR gating a track).
7. **Persist** when asked: refresh an existing `remaining-work.md` / `status.md` **in place** (look before overwriting); else write `docs/spec/roadmap/status.md` from `~/.claude/templates/status.md`.

## Rules

- NEVER trust a Status field over the code -- every "done" claim is verified against what runs
- NEVER re-open a stale-`PENDING`-but-done plan -- list it for flipping to VERIFIED instead
- NEVER pad -- a short backlog is a good sign; report what's real, cite the artifact path for every line
- Report only; this command plans nothing (that's `/roadmap` / `/rfp` / `/spec`)

## Next Step

Ask:

> Backlog assembled. Act on it?
> - `/roadmap` -- re-sequence the epics around it
> - `/rfp <epic>` -- decompose the next epic
> - `/spec` -- plan the top item
> - Done -- status only
