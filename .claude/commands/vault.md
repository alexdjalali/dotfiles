---
description: Save or retrieve reusable knowledge -- snippets, patterns, solutions -- from .claude/vault/
---

Persistent knowledge store for high-value items that don't fit a skill but shouldn't be lost between sessions.

## Save (`/vault save <topic>`)

1. Capture the item: a command sequence, a configuration pattern, a solution to a recurring problem, a code snippet.
2. Choose a category (tooling, debugging, infra, api, patterns, etc.).
3. Write to `.claude/vault/<category>/<slug>.md`:

```markdown
# <Title>

## Context
When does this apply?

## Content
The snippet / pattern / solution.

## Notes
Caveats, version constraints, known limitations.
```

4. Confirm the path written.

## Find (`/vault find <query>`)

Search `.claude/vault/` for entries matching the query terms. Show each match with its path and first 5 lines of content.

## List (`/vault list`)

List all entries in `.claude/vault/` grouped by category.

## Rules

- NEVER save something already in a skill or rule file -- vault is for one-offs and snippets
- NEVER save secrets or credentials -- vault is not a secrets manager
- Test: "Would I search for this next time I hit this problem?" If no, skip it.
- Keep entries short -- if it needs more than 40 lines, it belongs in a skill instead
