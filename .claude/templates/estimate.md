# Estimate — score the work, not the effort

Story points measured human effort, and human effort is no longer what varies. Score a story (`/rfp`) or a plan (`spec-plan`) on five axes, 1–3 each; the total (5–15) sets a **class**, and the class says how to run the work, not how big it is.

| Axis | 1 — Low | 2 — Medium | 3 — High |
|---|---|---|---|
| **Decisions** — human calls the work needs | none; the plan is obvious | one or two open questions | needs an ADR, or three-plus decisions |
| **Novelty** — pattern-following or pattern-setting | follows a reference implementation | extends an existing pattern | sets a new pattern |
| **Operational surface** — what it touches outside code | code only | CI, config, generated artifacts | cloud, identity, permissions, data |
| **Blast radius** — cost of being wrong | internal and reversible | shared library or internal API | migration, auth, public contract |
| **Context cost** — breadth the agent must hold | one tier | two or three tiers | cross-cutting |

| Total | Class | How to run it |
|---|---|---|
| 5–7 | **Delegate** | agent-led; plan approval; sampled review |
| 8–10 | **Design first** | an Accepted ADR (or design doc) before `/spec`; then delegate |
| 11–12 | **Gate and soak** | the guards that pin the new invariants land before the code; every risky file reviewed by a human; a staging soak before the epic counts as stable |
| 13–15 | **Spike** | human-led and timeboxed; split before building — never `/spec` it whole |

Record it in words, with each axis named: `<total> of 15, <Class>. Decisions <n>, Novelty <n>, Operational surface <n>, Blast radius <n>, Context cost <n>.`, then one sentence on what drives the score.

**Fixed limits:** 3–12 tasks per story (a thirteenth task means two stories), one commit per story, one design doc and one PR per epic. Above the epic sits the **initiative**: a set of ADRs delivered as a sequence of epics.

**Done means stable, not merged.** An epic is `Merged` when its PR lands and `Stable` when it has run in staging with no follow-up fix for the soak window. Record both dates; lead time is first commit → `Stable`.

**Tokens are a coupling signal.** A story that is expensive in context is usually crossing too many boundaries — a high Context cost is a reason to split or re-draw the boundary before building, not just a budget line.
