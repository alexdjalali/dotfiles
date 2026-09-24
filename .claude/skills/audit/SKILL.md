---
model: opus
description: Audit the codebase against a standard or quality dimension and record findings in docs/spec/audits/
argument-hint: "<dimension, e.g. philosophy-conformance | go-optimization | security>"
---

Run an evidence-based audit against a named standard or dimension and persist a severity-ranked report to `docs/spec/audits/` using `~/.claude/templates/audit.md`.

This is the durable, standard-scoped sibling of `/patterns`. Use `/patterns` for a quick structural sweep reported to chat; use `/audit` when the findings must **persist**, cite a specific charter/ADR/budget, and feed a refactor epic (`/rfp`) or plan (`/spec`) -- the way `audits/philosophy-conformance-audit.md` drove Epic 10.

## Scope (from args)

Name the standard or dimension, e.g.: `philosophy-conformance` (vs a design charter), `go-optimization` / `python-optimization` (a performance budget), `configurability`, `cli-conformance`, `security`, `test-quality`. If unspecified, infer it from the request and state what you chose.

## Steps

1. Load the **basis** -- the charter / ADR / budget / standard the code is measured against. Cite it in the header; a finding is only "non-conformant" relative to a named rule.
2. Statically scan the relevant trees (`pkg/`, `apps/`, `tools/`, `zarf/`, config) using `codegraph_impact` / `codegraph_callers` + Semble to surface drift and duplication, then read the code.
3. For each finding: cite `file:line`, name the gap against the basis, rate severity (🔴 high / 🟡 medium / 🟢 low, or critical/high/medium/low), and state the impact.
4. Build a **scorecard** (dimension -> verdict -> one-line) and a **remediation map** (finding -> the plan/epic/story it should land in, or "unplanned").
5. If the scan proves a claim in the basis wrong, correct it and say so explicitly.
6. Write `docs/spec/audits/<dimension>-audit.md` from the template.

## Rules

- NEVER report a finding without `file:line` evidence
- NEVER change code -- this command reports; fixes land via `/rfp` (refactor epic) or `/spec`
- NEVER report style the formatter owns
- Rank by severity; a clean dimension yields few findings -- say so, don't pad
- Map every high/critical finding to where it will be fixed, or mark it explicitly unplanned

## Next Step

Ask:

> Audit recorded. Turn findings into work?
> - `/rfp <epic>` -- decompose the remediation into a refactor epic + stories
> - `/spec` -- plan a focused fix directly
> - Done -- audit only
