# <Scope> Audit — against <standard / dimension>

> **Date:** <YYYY-MM-DD>
> **Basis:** <the standard the code is measured against — a charter, an ADR, a
> performance budget, a conformance spec>.
> **Method:** Evidence-based static scan of <paths: `pkg/`, `apps/`, `tools/`,
> `zarf/`, config>. Every finding cites the path(s) it was derived from.
> **Status:** <e.g. raw input for a future refactor plan, not the plan itself>.

---

## A. Executive Summary

**Verdict: <one-sentence bottom line>.**

<2–4 sentences: what is strong and genuinely conformant, what is weak, and the
*shape* of the gaps in priority order. Where the scan proves a claim in the basis
wrong, correct it here and say so.>

### Scorecard

| Dimension | Constraint | Verdict | One-line |
| --- | --- | --- | --- |
| <§ / area> | <what's required> | 🟢 / 🟡 / 🔴 | <why> |

---

## B. Findings

Ranked by severity. Every finding cites `file:line` and states the impact if left.

### <ID> — <title> · 🔴 High

**Evidence:** `<path:line>` — <what the code actually does>.
**Gap:** <how it diverges from the basis>.
**Impact:** <what it costs if unfixed>.
**Remediation:** <the change, and where it should land — plan / epic / story>.

### <ID> — <title> · 🟡 Medium

…

---

## C. Remediation Map

| Finding | Severity | Lands in (plan / epic / story) | Status |
| --- | --- | --- | --- |
| <ID> | 🔴 | `<plan/epic ref>` | planned / unplanned |

---

## References

- Basis: <charter / ADR / budget path>
- Implementing plans: <…>
