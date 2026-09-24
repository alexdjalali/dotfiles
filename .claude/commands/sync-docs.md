---
model: opus
description: Sync documentation and rules to match the current state of the codebase
---

Read the codebase. Compare against existing rules and docs. Update what is stale; document what is undocumented.

## Steps

**Write scope:** edit only the project's own `.claude/rules/`, `docs/`, `CLAUDE.md`, READMEs, and in-code docs. Global rules (`~/.claude/rules/`) are **report-only** — list any global drift in the report for the user to fix; never edit them from here.

1. **Inventory**: list all files in `.claude/rules/`, `docs/`, and `CLAUDE.md` (plus `~/.claude/rules/`, read-only).
2. **Scan for drift**: for each documented pattern, constraint, or file path, verify it still matches the code.
   - Wrong paths? Update.
   - Removed tools or commands? Remove the reference.
   - New patterns with no documentation? Flag them.
   - A symbol or behavior changed? Update its **direct** doc references AND the **indirect** ones — docs, READMEs, and docstrings describing callers or higher-level behavior that depend on it (`codegraph_callers` / `codegraph_impact`).
3. **Update stale entries**: change only what is now wrong. Do not rewrite accurate prose.
4. **Document new patterns**: for each undocumented pattern found, update or create the relevant rule file in the project's `.claude/rules/`.
5. **Verify counts and lists**: if docs say "supports X, Y, Z" and Z was removed, fix it.
6. **Report**: list every file changed and what specifically was updated.

## Rules

- NEVER edit `~/.claude/rules/` (or anything under `~/.claude/`) -- report global drift instead
- NEVER invent constraints that do not exist in the code
- NEVER rewrite prose that is still accurate -- minimal diffs only
- NEVER add documentation for future plans -- document what exists now
- Update `CLAUDE.md` when directory structure or key commands change

## Next Step

Report every doc changed, then `/preflight` and `/github` to commit the doc updates (alongside the code change that prompted them, if any).
