---
model: opus
description: Save, find, or list reusable snippets, commands, and one-off solutions in the project's .claude/vault/. Use for knowledge too small for a skill that shouldn't be lost between sessions.
argument-hint: "save <topic> | find <query> | list"
---

A persistent store for high-value items that don't warrant a skill (`/learn`). **Input:** `save <topic>`, `find <query>`, or `list`. **Output:** the path written, the matches, or the listing.

## `save <topic>`

1. Capture the item — a command sequence, config pattern, solution to a recurring problem, or code snippet — and choose a category (tooling, debugging, infra, api, patterns, …).
2. Write `.claude/vault/<category>/<slug>.md`:

   ```markdown
   # <Title>

   ## Context
   When does this apply?

   ## Content
   The snippet / pattern / solution.

   ## Notes
   Caveats, version constraints, known limitations.
   ```

3. Report the path written.

## `find <query>`

Grep `.claude/vault/` for the query terms; show each match's path and its first 5 lines.

## `list`

List every entry in `.claude/vault/`, grouped by category.

## Rules

- NEVER save something already in a skill or rule file — the vault is for one-offs and snippets.
- NEVER save secrets or credentials — the vault is not a secrets manager.
- Save only what you'd search for next time; over 40 lines → it's a skill, not a vault entry.
