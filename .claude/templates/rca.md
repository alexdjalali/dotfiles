# <Area> — Root-Cause Analysis

_Date: <YYYY-MM-DD> · Area: <subsystem(s) touched>_

<One or two sentences: how many issues were investigated, what surfaced them
(a disparity, an incident, a report), and that this is **diagnosis only** —
symptom + root cause with `file:line` evidence, no fixes applied.>

---

## 1. <Symptom in one line>

**Symptom:** <What the user/operator observes, and the condition under which it
happens vs. doesn't — "works locally, 403s in staging".>

**Root cause — <named mechanism>.** <The actual cause. Trace the control/data
flow from trigger to symptom; every causal claim carries `file:line` evidence.
Name the mechanism (e.g. "split-brain authorization", "missing soft-delete
cascade"), don't just point at a line.>

**Blast radius:** <Other symptoms this same cause explains; who else shares the
faulty path.>

**Fix sketch (not applied):** <The minimal change at the root cause, and the
defense-in-depth layers to harden. Diagnosis only — the fix lands via `/fix` or
`/spec`.>

---

## 2. <Next symptom>

**Symptom:** …

**Root cause — …**

<Repeat per distinct issue. If a cause can't be proven from the code, label it
**"not yet pinned"** and state the exact capture step needed to confirm it
(e.g. "requires the actual JSON:API response bytes for a zero-count workspace").>

---

## Latent issues (found during investigation)

<Distinct bugs discovered while diagnosing the above — each with `file:line`.>

---

## References

- Governing ADRs: <ADR-XXXX …>
- Related plans / stories: <…>
