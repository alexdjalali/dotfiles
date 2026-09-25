---
name: sync-docs
model: claude-opus-4-8
effort: high
description: Repo-wide sweep of a project's docs and rules (.claude/rules/, docs/, CLAUDE.md, READMEs, docstrings) against the current code, fixing what is stale. Use when docs have drifted across the repo or after a large refactor; per-change doc updates happen inline instead.
---

A repo-wide sweep; the always-on per-change rule is `documentation-sync.md`. **Input:** the current codebase. **Output:** minimal edits to stale project docs, plus a report of every file changed and any global drift.

**Write scope:** only the project's own `.claude/rules/`, `docs/`, `CLAUDE.md`, READMEs, and in-code docs. NEVER edit `~/.claude/` (global rules included) — list global drift in the report for the user.

## Steps

1. **Inventory** `.claude/rules/`, `docs/`, `CLAUDE.md`, and READMEs (plus `~/.claude/rules/`, read-only).
2. **Scan for drift** — for each documented pattern, constraint, path, tool, or command, verify it against the code: wrong path → update; removed tool or command → remove the reference; a changed symbol or behavior → update its **direct** references AND the **indirect** ones (docs describing callers or higher-level behavior that depend on it — `codegraph_callers` / `codegraph_impact`).
3. **Fix stale entries** — minimal diffs: change only what is now wrong; NEVER rewrite accurate prose.
4. **Document undocumented patterns** that exist in the code, in the relevant project `.claude/rules/` file — NEVER invent a constraint the code doesn't have, and NEVER document future plans.
5. **Counts and lists** — "supports X, Y, Z" with Z removed → fix it; update `CLAUDE.md` when directory structure or key commands changed.
6. **Report** every file changed and what was updated, plus global drift found.

## Next Step

Run the fast checks (CLAUDE.md *Quality Gates*), then suggest `/github` (it runs the full gate once, after committing) to commit the doc updates (with the code change that prompted them, if any).
