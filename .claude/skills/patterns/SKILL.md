---
model: opus
description: Quick chat-only sweep for DRY violations, coupling, complexity, dead code, convention drift, and test gaps — reports, never fixes. For a persisted, standard-scoped audit use /audit.
---

**Input:** the repo, or a path to focus on. **Output:** a severity-ranked findings report **in chat** — nothing written to disk. For findings that must persist, cite a charter/ADR/budget, and feed a refactor epic, use `/audit`. NEVER change code without explicit approval — this skill reports.

## What to look for

| Category | Examples |
|----------|----------|
| DRY violations | Duplicated logic with slight variations across files |
| Coupling | Components importing across too many layers; circular dependencies |
| Complexity | Functions > 50 lines; nesting > 4 levels; high cyclomatic complexity |
| Anti-patterns | God objects, primitive obsession, feature envy, shotgun surgery |
| Dead code | Exported symbols with no callers; commented-out blocks > 10 lines |
| Convention drift | Code ignoring an established pattern, naming, or error-handling idiom; a reinvented helper duplicating an existing one |
| Test gaps | Public logic with no tests; assertions on structure, not behavior; hand-rolled fakes where a mock or existing fixture would serve |

## Steps

1. Map coupling and blast radius with `codegraph_impact` / `codegraph_callers`.
2. Surface duplicated patterns across files with Semble (`find_related` from a suspect site).
3. Flag oversized production files (test files are exempt): `git ls-files -z -- '*.py' '*.go' '*.ts' '*.tsx' | xargs -0 wc -l | awk '$1 > 800 && $2 != "total"'` (`xargs wc -l` counts lines per file; a bare `| wc -l` only counts files).
4. Rank every finding `critical` / `high` / `medium` / `low` — structural problems only: never formatter-owned style, never "I would have done it differently".

## Output

```
## Findings

### Critical
- [file:line] Description — impact if left unfixed

### High
- [file:line] Description

### Medium / Low
- [file:line] Description
```

## Next Step

Ask which findings to address; for each approved fix, apply it, then run the quality gates (CLAUDE.md *Quality Gates*). To persist the findings, `/audit`; to plan a larger refactor, `/rfp` or `/spec` (user-typed).
