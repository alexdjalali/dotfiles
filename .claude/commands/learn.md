---
model: opus
description: Extract a reusable skill from a session discovery and save it to .claude/skills/
---

Capture what was learned this session as a reusable skill file.

## When to Extract a Skill

| Trigger | Example |
|---------|---------|
| Non-obvious debugging | 10+ min investigation; answer wasn't in the docs |
| Misleading error | Error message pointed in the wrong direction |
| Workaround discovered | Found a limitation and a creative solution |
| Undocumented tool usage | Figured out an API in an undocumented way |
| Trial-and-error resolved | Tried multiple approaches before finding what worked |
| Repeatable workflow | Multi-step task that will recur; worth standardizing |

## Steps

1. Identify the most reusable insight from the session. One insight per skill.
2. Determine the category (debugging, tooling, testing, architecture, etc.).
3. Write to `.claude/skills/<slug>/SKILL.md` (the folder name is the skill name and MUST match the frontmatter `name`; use a short kebab-case slug). Claude Code only discovers skills that are a `SKILL.md` with `name` + `description` frontmatter — a bare body or an `orchestrator.md` will never load:

```markdown
---
name: <slug>
description: <what it does AND when to use it — this line is what Claude matches on, so make it specific and trigger-oriented>
---

# <Title>

## Context
When does this apply? What situation triggers needing this knowledge?

## Approach
The steps or pattern that worked.

## Rules
- What to avoid (learned the hard way)

## Example
Concrete command sequence or before/after snippet.
```

4. Keep it under 60 lines. If it's longer, it's two separate skills.

## Rules

- NEVER document what the model already knows (standard library, basic syntax)
- NEVER write a skill for a one-off situation unlikely to recur
- Test: "Would this have saved 10+ minutes if I'd had it at session start?" If no, skip it.
