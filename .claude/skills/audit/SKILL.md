---
name: audit
model: opus
description: Audit code for structural problems — a quick chat sweep (DRY, coupling, complexity, dead code, convention drift, test gaps), a persisted file:line-cited audit against a named standard (charter, ADR, budget) in docs/spec/audits/, or `repo` for layout compliance. Reports, never fixes. Use when asked to audit, sweep, or assess code quality, conformance, or repo structure.
argument-hint: "[<standard, e.g. philosophy-conformance | go-optimization | security> | repo] [<path>]"
---

One skill, three modes — all report, NEVER change code (fixes land via `/fix`, `/rfp`, or `/spec`). A finding is ranked by severity and carries `file:line`; NEVER report formatter-owned style or "I would have done it differently". A clean area yields few findings — say so, don't pad.

| Args | Mode | Output |
|------|------|--------|
| none, or a path | **Quick sweep** | findings in chat — nothing written |
| a standard / dimension | **Standard audit** | `docs/spec/audits/<dimension>-audit.md` from `~/.claude/templates/audit.md` |
| `repo` | **Layout audit** vs the project's documented layout (`CLAUDE.md`, a repository-structure doc) when it has one, else `~/.claude/templates/repo.md` | pass/fail checklist in chat |

## Quick sweep

1. Map coupling and blast radius with `codegraph_impact` / `codegraph_callers`; surface duplication with Semble (`find_related` from a suspect site).
2. Check each category: **DRY** (duplicated logic with slight variations) · **coupling** (imports across too many layers, cycles) · **complexity** (functions > 50 lines, nesting > 4) · **anti-patterns** (god objects, feature envy, shotgun surgery) · **dead code** (exported symbols with no callers, commented-out blocks > 10 lines) · **convention drift** (a reinvented helper, a divergent idiom — cite the established one) · **test gaps** (public logic untested, structure-not-behavior assertions, fakes where `testing.md` forbids them).
3. Oversized production files (tests exempt): `git ls-files -z -- '*.py' '*.go' '*.ts' '*.tsx' | xargs -0 wc -l | awk '$1 > 800 && $2 != "total"'`.
4. Report `critical` / `high` / `medium` / `low`, each `[file:line] issue — impact`. Then ask which to address: a small fix → `/fix`; a refactor → `/rfp`; to persist the findings, re-run as a standard audit.

## Standard audit

The durable version: findings measured against a named rule, feeding a refactor epic or plan. Unspecified standard → infer it from the request and state your choice.

1. **Load the basis** — the charter / ADR / budget / standard; cite it in the header. "Non-conformant" only relative to a named rule.
2. **Scan** the relevant trees (`pkg/`, `apps/`, `tools/`, `zarf/`, config) as in the quick sweep, then read the code.
3. **Per finding** — `file:line` evidence, the gap against the basis, severity (🔴 / 🟡 / 🟢), impact.
4. **Scorecard** (dimension → verdict → one line) and **remediation map** (finding → plan / epic / story, or "unplanned") — every 🔴 mapped or marked unplanned.
5. **Correct the basis** where the scan proves one of its claims wrong, and say so. **Write** the file.

Next: ask — `/rfp <epic>` (refactor epic + stories), `/spec` (user-typed, focused fix), or done.

## Layout audit (`repo`)

The basis is the project's own documented layout when one exists (`CLAUDE.md`, `docs/**/repository-structure.md`) — a repo that documents its deviations isn't non-conformant; otherwise `~/.claude/templates/repo.md`. Check and report pass/fail with what to add:

- [ ] `docs/adr/` with at least one `NNNN-<slug>.md`; `docs/spec/` pipeline dirs in use
- [ ] `docs/local/` gitignored; no plan files tracked under `docs/spec/`
- [ ] `zarf/` holds infrastructure; no business logic in the root or `zarf/`, no infrastructure in `src/` / `pkg/`
- [ ] `CLAUDE.md` at the root; language dirs match the stack (Go `pkg/` + `apps/`, Python `src/` + `entrypoints/`, TS `packages/` + `apps/`)

Small gaps → fix directly on request, then the fast checks; a structural migration → `/adr` + `/spec`.
