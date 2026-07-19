# Remaining Work — Consolidated Backlog

> **Date:** <YYYY-MM-DD>
> **Purpose:** One place that answers "what is left to build?" Synthesizes every
> epic, story, plan, and audit into a single, deduplicated backlog with
> confidence-checked status.
> **Method:** story/epic `Status` cross-checked against code (they drift), plan
> inventory classified by *actual* completion, and the code audits mapped to their
> implementing plans.

---

## 0. At a Glance

**Shipped:** <epics/stories verified complete against code>.

**What's left splits in two:**

| Track | What | Where |
| --- | --- | --- |
| **A. Product build-out** | <unfinished epics/stories> | §1 |
| **B. Refactor & conformance** | <open audits + remediation epics> | §2 |

---

## 1. Track A — Product Build-Out Remaining

Status verified against code, not the `Status` field.

### Epic <N> — <name> · *<state>*
| Story | State | What's left |
| --- | --- | --- |
| <n.m> <slug> | <Todo / In Progress> | <the concrete gap, with `file:line`> |

---

## 2. Track B — Refactor & Conformance

### <Audit / Epic> — *<state>*
`docs/spec/audits/<...>-audit.md`. <Which findings are planned, which unplanned;
the implementing plan/epic.>

---

## 3. Open Plans Register

Plan `Status` is unreliable — classified here by **actual** completion.

### Genuinely open (real outstanding work)
| Plan | Approved | Ties to |
| --- | --- | --- |

### Stale-`PENDING`-but-done (flip to VERIFIED, don't re-open)
<list>

### Superseded / moot (closed)
<list>

### Non-plans (working notes — not actionable)
<list>

---

## 4. Suggested Sequencing

1. <critical path first — the item everything downstream needs>
2. <decision blockers: accept/reject the gating ADR>
3. <refactors in leverage order>
4. <housekeeping: flip stale plan statuses>

---

## References

- Epics/stories: `docs/spec/epics/`, `docs/spec/stories/`
- Plans: `docs/spec/plans/` · Audits: `docs/spec/audits/` · RCA: `docs/spec/rca/`
- Governing ADRs: <…>
