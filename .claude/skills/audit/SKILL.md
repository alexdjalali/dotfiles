---
model: opus
description: Audit the code against a named standard (charter, ADR, performance budget) and persist a severity-ranked, file:line-cited report to docs/spec/audits/. Use when findings must feed a refactor epic or plan; /patterns for a quick chat sweep.
argument-hint: "<dimension, e.g. philosophy-conformance | go-optimization | security>"
---

The durable, standard-scoped sibling of `/patterns` (a quick sweep to chat). **Input:** a dimension or standard — e.g. `philosophy-conformance` (vs a design charter), `go-optimization` / `python-optimization` (a performance budget), `configurability`, `cli-conformance`, `security`, `test-quality`; unspecified → infer it from the request and state your choice. **Output:** `docs/spec/audits/<dimension>-audit.md` from `~/.claude/templates/audit.md`. NEVER change code — fixes land via `/rfp` (refactor epic) or `/spec`.

## Steps

1. **Load the basis** — the charter / ADR / budget / standard the code is measured against; cite it in the header. A finding is "non-conformant" only relative to a named rule.
2. **Scan** the relevant trees (e.g. `pkg/`, `apps/`, `tools/`, `zarf/`, config) with `codegraph_impact` / `codegraph_callers` + Semble to surface drift and duplication, then read the code.
3. **Per finding** — `file:line` evidence, the gap against the basis, severity (🔴 High / 🟡 Medium / 🟢 Low, as in the template), and the impact. NEVER report a finding without `file:line`, or style the formatter owns.
4. **Scorecard** (dimension → verdict → one line) and **remediation map** (finding → the plan / epic / story it lands in, or "unplanned") — every high finding mapped or explicitly marked unplanned.
5. **Correct the basis** where the scan proves one of its claims wrong, and say so.
6. **Write** the file.

## Rules

- Rank by severity; a clean dimension yields few findings — say so, don't pad.

## Next Step

Ask:

> Audit recorded. Turn findings into work?
> - `/rfp <epic>` — decompose the remediation into a refactor epic + stories
> - `/spec` — plan a focused fix directly
> - Done — audit only

Run the chosen skill via `Skill()`; `/spec` is suggested for the user to type — never invoked.
