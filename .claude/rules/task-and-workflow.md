# Task & Workflow

## Plan Mode

`/spec` is the structured alternative to CC plan mode (adds TDD, verification, code review) — guide users to it; they should NOT press Shift+Tab into plan mode first (the spec skills run plan → approve → implement → verify). Plans: `docs/local/plans/YYYY-MM-DD-<slug>.md` — **gitignored** local working docs (never committed, so a merged PR can't delete them; spec-review findings JSON co-locates as `.spec-review-<slug>.json`). Write the plan (and user-authorized edits) normally — `bypassPermissions` keeps writes flowing.

**⛔ NEVER auto-invoke `/spec` or `Skill('spec')`** — the user MUST type it. Suggest, don't invoke.

## Task Complexity Triage

Default: quick mode. Trivial (single file, no active tasks) → execute directly · any request while tasks exist → TaskCreate FIRST · moderate (2–5 files) → TaskCreate, then execute · high (architectural, 20+ files, cross-cutting) → **ask**: `/spec` or quick mode?

**⛔ Don't suggest `/spec` for** bugfixes (use `/fix`), single-feature additions, one-module refactors, CLI flag changes, config tweaks, dependency updates, test additions, or anything scoped to a clear outcome — only for large multi-system work where planning materially reduces risk. In doubt → quick mode.

## Bug Lane — which skill

- Cause unknown → `/debug` (live root-cause + fix, scientific method).
- Cause known, fix small & contained → `/fix` (reproducing test + revert-proof).
- Cause found but not fixing now, or several related bugs → `/rca` (persisted `file:line`-cited diagnosis, no fix).
- Large / cross-layer / schema-API change → `/spec` bugfix lane (plan → implement → verify).

Chain: `/debug`|`/rca` → `/fix` (small) | `/spec` (large) → `/github`. A reproducing test is mandatory in every lane but `/rca`. Never silently upgrade an outgrown `/fix` — stop and escalate to `/spec`.

## Task Management

Tasks are working memory (otherwise lost in compaction). Use them in quick mode; skip only a trivial one-shot with an empty `TaskList`.

- **Task-first:** every request gets a task BEFORE any code/research/substantive reply: TaskCreate → in_progress → work → completed.
- **Interrupts:** new mid-work request → STOP, TaskCreate it as your FIRST tool call, then assess priority.
- **Session start:** `TaskList` first, delete stale tasks, create current ones. **Continuations** (same `CLAUDE_CODE_TASK_LIST_ID`): `TaskList` first, don't recreate, resume the first uncompleted.
- **Isolation:** tasks are per-session (`CLAUDE_CODE_TASK_LIST_ID`); memory is shared, so memory references absent from your `TaskList` belong elsewhere. **`TaskList` is the sole source of truth.**
- **Deferring:** TaskCreate immediately — never just say "noted."

## Tool Usage

**Exact parameter names:** `Bash` → `command` (not `cmd`/`bash_command`/`shell`) · `Write`/`Edit`/`Read` → `file_path` (not `path`/`filepath`/`file`) · `Write` → `content` (not `contents`/`text`/`body`) · `Edit` → `old_string`/`new_string` (not `old`/`new`/`search`/`replace`) · `Grep` → `pattern` (not `query`/`search`/`regex`).

### ⛔ Agent Tool — Explore / Plan / Research blocked

A hook blocks `subagent_type` `Explore`/`Plan` and any description starting "Research" or containing "Explore", whatever the type — use direct tools (CodeGraph + Semble: `development-practices.md`, `mcp-servers.md`). Whitelisted: `spec-review`, `changes-review` (Codex-native `/spec` reviewer — never launch it by hand on Claude Code). **Review any diff — working tree, committed branch vs base, or PR — with `/review-diff`**; an empty `/code-review` on a committed diff means `/review-diff`, not `changes-review`.

### Web Search/Fetch

Built-in `WebFetch`/`WebSearch` are hook-blocked; ToolSearch `+web-search search` (search) · `+web-search fetch` (GitHub README) · `+web-fetch fetch` (page).

### Sub-agents

- Launch with `run_in_background=true`. **⛔ NEVER use `TaskOutput`.** Never plan on `SendMessage` (may not exist).
- Only `spec-review` writes files (findings JSON): poll with a bash file-existence loop, then Read once. Other agents' only output is a foreground call's final message.
- `/spec` code review isn't a sub-agent on Claude Code: `spec-verify`/`spec-bugfix-verify` run `/review-diff` inline (`Skill(skill='review-diff')`) on the **working-tree** diff, since built-in `/code-review` is user-trigger-only. `/review-diff` is the one front door for any diff — never hand-spawn `changes-review`. `/fix` runs no code-review step.
- Sub-agents don't inherit rules; they can read `~/.claude/rules/*.md` and `.claude/rules/*.md`.

### Codex Companion (Reviews & Tasks)

- ⛔ Never delegate a companion run whose output you need to a subagent (`codex:codex-rescue` included): no findings file, no recovery (`TaskOutput` banned, `SendMessage` unavailable). The rescue agent is only for user-typed `/codex:rescue`.
- Run it directly via Bash as the `/spec` and `/fix` steps specify: `CODEX_COMPANION=$(ls ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)`
- With its `task-…` ID a job is never lost: `node "$CODEX_COMPANION" status <job-id> --json` polls, `node "$CODEX_COMPANION" result <job-id> --json` fetches — don't abandon it and redo the review. ID unrecoverable (launched in a subagent)? Re-launch once directly and continue.

### Background Bash

`run_in_background=true` only for long-running processes (dev servers, watchers); tests, lint, git, installs run synchronously.

---

## /spec Workflow

```
/spec → Dispatcher → Feature: spec-plan        → spec-implement → spec-verify
                   → Bugfix:  spec-bugfix-plan → spec-implement → spec-bugfix-verify
/fix  → fix skill (always quick lane; stops and points to /spec if scope exceeds it)
```

### ⛔ Dispatcher Integrity

Thin router — **only** `Bash` (env-var reads), `Read` (plan files), `AskUserQuestion`, `Skill()`. Any Grep/Glob/Task/Edit/Write is a violation.

### Phase Dispatch

New task (no `.md`): infer type from the description; ambiguous → ask. Existing plan: read its `Type:` header. PENDING + unapproved → `spec-plan` (Feature) / `spec-bugfix-plan` (Bugfix) · PENDING + approved → `spec-implement` · COMPLETE → `spec-verify` (Feature) / `spec-bugfix-verify` (Bugfix) · VERIFIED → done.

`PENDING` (awaiting impl) → `COMPLETE` (ready to verify) → `VERIFIED`. `spec-implement` serves both types (the plan is the interface). Features verify via code review (`/review-diff` run inline on Claude Code; native `changes-review` on Codex) + inline plan-compliance/goal audit + optional Codex companion + structured E2E (TS-NNN); bugfixes via Behavior Contract audit + revert-test proof. **Feedback loop:** verify finds issues → PENDING → implement fixes → COMPLETE → re-verify … → VERIFIED.

### ⛔ Only THREE User Interaction Points

1. **Type confirmation** — new plans, only when Feature vs Bugfix is ambiguous (dispatcher).
2. **Plan Approval** — `spec-plan`/`spec-bugfix-plan`; always required before implementation.
3. **Code Review Gate** — final gate via `AskUserQuestion`.

All else is automatic. **NEVER ask "Should I fix these findings?"** — fixes are part of the approved plan.

### Deviation Handling (during /spec)

- **Bug / missing critical / blocking** (errors, missing validation, broken imports) → auto-fix inline (+ tests if applicable), document it, don't expand scope.
- **Architectural** (new table, library swap, breaking API) → **STOP** — `AskUserQuestion`.

Outside `/spec`, respect the user's mode.

### Resuming After Interruptions

After an interruption ("Continue", a new mid-task message) or pause during `/spec`, never say goodbye or stop mid-plan: your **very next action** is a tool call (TaskList, Read plan, code change) — re-read the plan, resume until VERIFIED.

### Task Completion Tracking

After EACH task, immediately: `[ ]` → `[x]`, Done +1, Left −1 in the plan.
