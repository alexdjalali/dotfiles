# Linear — Ticket Authoring

Applies **only to repos whose work is tracked in Linear.** If a repo has its own
`.claude/rules/linear.md`, that file wins (it names the team prefix, the docs mirror, etc.).

## Templates

Create tickets from `~/.claude/templates/linear/` — `epic.md`, `story.md`, `bug.md`, `task.md`; what
Linear renders and which diagram fits each ticket type: `~/.claude/templates/linear/README.md`.
They read like a human wrote them: **Background → Requirements → Acceptance Criteria** (+ Out of
Scope / References). Engineering discipline (DoD checklists, coverage gates, layer rules) lives in
the repo's rules and `docs/spec/`, **not** the ticket body. A ticket a teammate can't skim in ten
seconds is too machine-like.

## Rules

- **Mirror + link.** A ticket usually mirrors a `docs/spec/` artifact (story / epic / RCA). Keep the
  two cross-referenced: the markdown owns design + acceptance criteria, Linear owns execution state.
- **⛔ Never fabricate a ticket id.** Read it from the story / plan / PR / branch, or ask. Use a
  `(unticketed — create in <TEAM>)` placeholder when none exists yet — a wrong id silently mis-tracks work.
- **Mutate Linear only through an authenticated Linear MCP server.** If it's unavailable, "update the
  ticket" means preparing the text for the user — never claim a ticket changed unless the call succeeded.
- Reference the ticket id in the branch / PR / commit so Linear auto-links the work.
- **⛔ No ticket ids in code comments.** Ticket ids rot and couple the source to the tracker — keep
  them in the ticket / PR / commit, per the language `standards-*.md`.
