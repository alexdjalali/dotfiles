---
description: Audit the codebase for DRY violations, anti-patterns, coupling problems, and complexity hotspots
---

Scan the codebase and produce a severity-ranked findings report.

## What to Look For

| Category | Examples |
|----------|---------|
| DRY violations | Duplicated logic with slight variations across files |
| Coupling | Components importing across too many layers; circular dependencies |
| Complexity | Functions > 50 lines; nesting > 4 levels; high cyclomatic complexity |
| Anti-patterns | God objects, primitive obsession, feature envy, shotgun surgery |
| Dead code | Exported symbols with no callers; commented-out blocks > 10 lines |
| Convention drift | Code that ignores an established repo pattern, naming, or error-handling idiom; a reinvented helper that duplicates an existing one |
| Test gaps | Public logic with no tests; assertions that test structure not behavior; hand-rolled fakes where a mock or existing fixture would serve |

## Steps

1. Use `codegraph_impact` and `codegraph_callers` to map coupling and blast radius.
2. Use Semble to surface duplicated patterns across files.
3. Flag oversized files with `find . -type f \( -name "*.py" -o -name "*.go" -o -name "*.ts" \) | xargs wc -l | awk '$1 > 800'` — use `xargs wc -l` (a bare `... | wc -l` only counts the *number of files*, not lines per file). Or use CodeGraph to list large symbols.
4. Rank all findings by severity: `critical`, `high`, `medium`, `low`.

## Output Format

```
## Findings

### Critical
- [file:line] Description -- impact if left unfixed

### High
- [file:line] Description

### Medium / Low
- [file:line] Description
```

## Rules

- NEVER report style preferences -- the formatter handles those
- NEVER change code without explicit user approval -- this command reports, it does not fix
- Report only structural problems, not "I would have done it differently"

## Next Step

Ask which findings to address. For each approved fix, apply it and run `/preflight`.
