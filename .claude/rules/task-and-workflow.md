# Task & Workflow

## Plan Mode

`/spec` is the structured alternative to CC plan mode (adds TDD, verification, code review) — guide users to it; they should NOT press Shift+Tab into plan mode first (the spec skills run plan → approve → implement → verify). Plans: `docs/local/plans/YYYY-MM-DD-<slug>.md` — **gitignored** local working docs (never committed, so a merged PR can't delete them; spec-review findings JSON co-locates as `.spec-review-<slug>.json`). Write the plan (and user-authorized edits) normally — `bypassPermissions` keeps writes flowing.

**⛔ NEVER auto-invoke `/spec` or `Skill('spec')`** — the user MUST type it. Suggest, don't invoke. Routing, the dispatcher's tool allowlist, the single plan-approval checkpoint, and deviation handling live in the `/spec` and `spec-*` skills.

**Resuming after interruptions:** after an interruption ("Continue", a new mid-task message) or pause during `/spec`, never say goodbye or stop mid-plan: your **very next action** is a tool call (TaskList, Read plan, code change) — re-read the plan, resume until VERIFIED.

## Task Complexity Triage

Default: quick mode. Trivial (single file, no active tasks) → execute directly · any request while tasks exist → TaskCreate FIRST · moderate (2–5 files) → TaskCreate, then execute · high (architectural, 20+ files, cross-cutting) → **ask**: `/spec` or quick mode?

**⛔ Don't suggest `/spec` for** bugfixes (use `/fix`), single-feature additions, one-module refactors, CLI flag changes, config tweaks, dependency updates, test additions, or anything scoped to a clear outcome — only for large multi-system work where planning materially reduces risk. In doubt → quick mode.

## Bug Lane — which skill

- Cause unknown → `/investigate` (live root-cause + fix, scientific method).
- Cause known, fix small & contained → `/fix` (reproducing test + revert-proof).
- Cause found but not fixing now, or several related bugs → `/rca` (persisted `file:line`-cited diagnosis, no fix).
- Large / cross-layer / schema-API change → `/spec` bugfix lane (plan → implement → verify).

Chain: `/investigate`|`/rca` → `/fix` (small) | `/spec` (large) → `/github`. A reproducing test is mandatory in every lane but `/rca`. Never silently upgrade an outgrown `/fix` — stop and escalate to `/spec`.

## Task Management

Tasks are working memory (otherwise lost in compaction). Use them in quick mode; skip only a trivial one-shot with an empty `TaskList`.

- **Task-first:** every request gets a task BEFORE any code/research/substantive reply: TaskCreate → in_progress → work → completed.
- **Interrupts:** new mid-work request → STOP, TaskCreate it as your FIRST tool call, then assess priority.
- **Session start:** `TaskList` first, delete stale tasks, create current ones. **Continuations** (same `CLAUDE_CODE_TASK_LIST_ID`): `TaskList` first, don't recreate, resume the first uncompleted.
- **Isolation:** tasks are per-session (`CLAUDE_CODE_TASK_LIST_ID`); memory is shared, so memory references absent from your `TaskList` belong elsewhere. **`TaskList` is the sole source of truth.**
- **Deferring:** TaskCreate immediately — never just say "noted."

## Tool Usage

### ⛔ Agent Tool — don't spawn Explore / Plan / Research agents

Policy: don't delegate code search to a `subagent_type` `Explore`/`Plan` agent, or to any agent whose description starts "Research" or contains "Explore" — use CodeGraph + Semble directly (`mcp-servers.md`). `spec-review` is launched by the plan phases; `changes-review` is the Codex-native `/spec` reviewer — never launch it by hand on Claude Code. **Review any diff — working tree, committed branch vs base, or PR — with `/review-diff`**; an empty `/code-review` on a committed diff means `/review-diff`, not `changes-review`.

### Web Search/Fetch

Prefer the web-search / web-fetch MCP servers over built-in `WebFetch`/`WebSearch`: ToolSearch `+web-search search` (search) · `+web-search fetch` (GitHub README) · `+web-fetch fetch` (page).

### Sub-agents

- Subagents run in the background by default (the Agent tool has no `run_in_background` param); you're notified on completion — never predict a pending result. **⛔ NEVER use `TaskOutput`.** Continue a finished agent with `SendMessage` (its ID/name); a new Agent call starts fresh.
- `spec-review` writes its findings JSON to `output_path`: poll with a bash file-existence loop, then Read once. Other agents' output is their final message.
- `/spec` code review isn't a sub-agent on Claude Code: `spec-verify`/`spec-bugfix-verify` run `/review-diff` inline (`Skill(skill='review-diff')`) on the **working-tree** diff. `/review-diff` is the one front door for any diff — never hand-spawn `changes-review`. `/fix` runs no code-review step.
- Sub-agents don't inherit rules; they can read `~/.claude/rules/*.md` and `.claude/rules/*.md`.
- **Codex companion:** ⛔ never delegate a companion run whose output you need to a subagent (`codex:codex-rescue` is only for user-typed `/codex:rescue`) — run `codex-companion.mjs` directly via Bash (recipe: `~/.claude/templates/codex-changes-review.md`).

### Background Bash

`run_in_background=true` only for long-running processes (dev servers, watchers); tests, lint, git, installs run synchronously.
