---
model: opus
description: Capture a non-obvious, reusable lesson from this session as a project skill (.claude/skills/<slug>/SKILL.md). Use after a hard-won debugging insight, workaround, or repeatable workflow.
---

**Input:** the current session. **Output:** one new `.claude/skills/<slug>/SKILL.md` in the project, with its path reported. One insight per skill; snippets and one-offs go to `/vault` instead.

## When to extract

| Trigger | Example |
|---------|---------|
| Non-obvious debugging | 10+ min investigation; the answer wasn't in the docs |
| Misleading error | The error message pointed in the wrong direction |
| Workaround | Found a limitation and a creative way around it |
| Undocumented tool usage | Figured out an API in an undocumented way |
| Trial-and-error resolved | Tried several approaches before one worked |
| Repeatable workflow | A multi-step task that will recur |

Test: "Would this have saved 10+ minutes at session start?" If not, skip it. NEVER document what the model already knows (standard library, basic syntax), or a one-off unlikely to recur.

## Steps

1. Pick the single most reusable insight and its category (debugging, tooling, testing, architecture, …).
2. Choose a short kebab-case slug. The folder name is the command (`/<slug>`) — make sure it doesn't collide with an existing skill, a bundled skill, or a built-in command (`/debug`, `/design`, `/verify`, `/review`, `/status`, …); a same-named skill shadows or is shadowed.
3. Write `.claude/skills/<slug>/SKILL.md` — it must be exactly that path (a loose `.md` elsewhere never loads). `description` is what Claude matches on: say what it does AND when to use it, key use case first. `name` is optional (a display label, defaulting to the folder name); if set, match the folder.

```markdown
---
name: <slug>
description: <what it does AND when to use it — specific and trigger-oriented>
---

# <Title>

## Context
When does this apply? What situation triggers needing this knowledge?

## Approach
The steps or pattern that worked.

## Rules
- What to avoid (learned the hard way)

## Example
A concrete command sequence or before/after snippet.
```

4. Keep it under 60 lines — longer means it's two skills.
