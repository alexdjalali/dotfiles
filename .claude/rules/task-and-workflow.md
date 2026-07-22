# Task & Workflow

## Plan Mode

`/spec` is the structured alternative to CC's built-in plan mode — it adds TDD, verification, and code review. Guide users to `/spec` for planned work. Users should NOT manually enter plan mode (Shift+Tab) before `/spec`: the spec skills manage the plan → approve → implement → verify flow themselves.

The plan file always lives at `docs/spec/plans/YYYY-MM-DD-<slug>.md`. You write the plan file (plus any edits the user authorizes) normally — `bypassPermissions` keeps writes flowing.

**⛔ NEVER auto-invoke `/spec` or `Skill('spec')`.** The user MUST explicitly type it. Suggest, don't invoke.

## Task Complexity Triage

Default is quick mode (direct execution).

| Complexity | Action |
|------------|--------|
| Trivial (single file, no active tasks) | Execute directly |
| Any request while tasks exist | TaskCreate FIRST |
| Moderate (2–5 files) | TaskCreate, then execute |
| High (architectural, 20+ files, cross-cutting system change) | **Ask** if user wants `/spec` or quick mode |

**⛔ Do NOT suggest `/spec` for:** bugfixes (use `/fix`), single-feature additions, refactors inside one module, CLI flag changes, config tweaks, dependency updates, test additions, or anything already scoped to a clear outcome. Reserve the suggestion for genuinely large, multi-system work where upfront planning materially reduces risk — when in doubt, execute in quick mode.

## Bug Lane — which skill

Four entry points; pick by what you know and how big the fix is:

| Situation | Skill | Output |
|-----------|-------|--------|
| Cause unknown — need to investigate | `/debug` | live root-cause + fix (scientific method) |
| Cause known, fix small & contained | `/fix` | quick-lane fix: reproducing test + revert-proof |
| Cause found but not fixing now, or several related bugs | `/rca` | persisted, `file:line`-cited diagnosis (no fix) |
| Fix is large / crosses layers / needs a schema-API change | `/spec` (bugfix lane) | planned fix → implement → verify |

Chain: **`/debug` or `/rca` (diagnose) → `/fix` (small) or `/spec` (large) → `/github` (ship)**. A reproducing test is non-negotiable in every lane except `/rca` (diagnosis only). Never silently upgrade a `/fix` that outgrew the quick lane — stop and escalate to `/spec`.

## Task Management

**Use task management in quick mode.** Tasks are working memory — without them, requests get lost during compaction. Skip only for a truly trivial one-shot with empty `TaskList`.

### Quick Mode: Task-First

Every user request gets a task BEFORE any code/research/substantive response: TaskCreate → in_progress → work → completed.

### On-Demand Interrupts

When the user sends a new request mid-work: STOP, TaskCreate for the new request as your FIRST tool call, then assess priority. If it's not in the task list, it will be forgotten.

### Other Rules

- **Session start:** `TaskList` first, delete stale tasks, create new ones for current request.
- **Cross-session isolation:** Tasks are scoped per session via `CLAUDE_CODE_TASK_LIST_ID`. Memory is shared across sessions; references in memory that aren't in your `TaskList` belong elsewhere. **`TaskList` is the sole source of truth.**
- **Continuations** (same `CLAUDE_CODE_TASK_LIST_ID`): `TaskList` first, don't recreate, resume first uncompleted.
- **Deferring a request:** TaskCreate immediately — never just say "noted."

## Tool Usage

### Tool Parameter Names — Use EXACT names

| Tool | Correct | Wrong |
|------|---------|-------|
| `Bash` | `command` | `cmd`, `bash_command`, `shell` |
| `Write`/`Edit`/`Read` | `file_path` | `path`, `filepath`, `file` |
| `Write` | `content` | `contents`, `text`, `body` |
| `Edit` | `old_string`, `new_string` | `old`, `new`, `search`, `replace` |
| `Grep` | `pattern` | `query`, `search`, `regex` |

### ⛔ Agent Tool — Explore / Plan / Research blocked

Hook blocks `subagent_type` of `Explore`/`Plan`, AND any description starting with "Research" or containing "Explore" (regardless of subagent_type — `general-purpose` with `"Explore codebase"` description is the same violation).

Use direct tools instead — see `development-practices.md` and `mcp-servers.md` for CodeGraph + Semble workflow.

**Whitelisted (pass through silently):** `changes-review`, `spec-review`. `changes-review` is the **Codex-native `/spec` reviewer** — on Claude Code you never launch it by hand. **To review a code diff of any kind — the working tree, a committed branch against a base, or a PR — run `/review-diff`** (it resolves the diff source itself; see the Sub-agents section). The specific trap to avoid: `/code-review` returning nothing on a committed diff is NOT a reason to spawn `changes-review` — that empty result means the diff is committed and `/review-diff` is the tool that materializes and reviews it.

### Web Search/Fetch

Built-in `WebFetch` / `WebSearch` are hook-blocked. Use ToolSearch:

| Need | Query |
|------|-------|
| Web search | `+web-search search` |
| GitHub README | `+web-search fetch` |
| Fetch page | `+web-fetch fetch` |

### Sub-agents

- Launch with `run_in_background=true`
- ⛔ NEVER use `TaskOutput` to retrieve results.
- **The `spec-review` reviewer agent** writes findings JSON files — poll with bash file-existence loop, then Read once. Other agent types do NOT write files; their only output is the final message of a foreground call. Never plan on `SendMessage` to follow up — it may not exist in the running Claude Code version. (Code review in `/spec`/`/fix` is NOT a sub-agent on Claude Code — it is the built-in `/code-review` skill, invoked inline via `Skill(skill='code-review', args='xhigh')`, which reviews the just-implemented **working-tree** diff. To review an already-committed branch or PR diff against a base, run `/review-diff` — it fetches and diffs against the base — never a hand-spawned `changes-review`.)
- Sub-agents do NOT inherit rules; they can read `~/.claude/rules/*.md` and `.claude/rules/*.md`.

### Codex Companion (Reviews & Tasks)

- ⛔ NEVER delegate a Codex companion run to a subagent (`codex:codex-rescue` included) when you need its output — the subagent backgrounds the broker job, writes no findings file, and there is no recovery path (`TaskOutput` banned, `SendMessage` unavailable). The rescue agent exists for user-typed `/codex:rescue` handoffs only.
- Run the companion directly via Bash in the main conversation, exactly as the /spec and /fix steps specify:
  `CODEX_COMPANION=$(ls ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)`
- A background job is never lost while you hold its `task-…` ID: `node "$CODEX_COMPANION" status <job-id> --json` polls it, `node "$CODEX_COMPANION" result <job-id> --json` fetches the finished result. Do NOT abandon a launched job and redo the review yourself.
- If the job ID is unrecoverable (it was launched inside a subagent), re-launch once directly via Bash and continue.

### Background Bash

Use `run_in_background=true` only for long-running processes (dev servers, watchers). Synchronous for tests, lint, git, installs.

---

## /spec Workflow

```
/spec → Dispatcher → Feature: spec-plan        → spec-implement → spec-verify
                   → Bugfix:  spec-bugfix-plan → spec-implement → spec-bugfix-verify
/fix  → fix skill (always quick lane). Stops and tells user to use /spec if scope exceeds quick lane.
```

### ⛔ Dispatcher Integrity

`/spec` dispatcher is a thin router. **Only allowed tools:** `Bash` (env-var reads), `Read` (plan files), `AskUserQuestion`, `Skill()`. Any Grep/Glob/Task/Edit/Write is a workflow violation.

### Phase Dispatch

New tasks (no `.md`): infer type from description. Ambiguous → ask the user.

Existing plans (`.md`): read `Type:` header.

| Status | Approved | Type | Skill |
|--------|----------|------|-------|
| PENDING | No | Feature | `spec-plan` |
| PENDING | No | Bugfix | `spec-bugfix-plan` |
| PENDING | Yes | * | `spec-implement` |
| COMPLETE | * | Feature | `spec-verify` |
| COMPLETE | * | Bugfix | `spec-bugfix-verify` |
| VERIFIED | * | * | Done |

`spec-implement` is identical for both types (the plan file is the interface). Verification differs: features get a code review (built-in `/code-review` at xhigh on Claude Code; native `changes-review` agent on Codex) + inline plan-compliance/goal audit + optional Codex companion + structured E2E (TS-NNN); bugfixes get Behavior Contract audit + revert-test proof.

**Status values:** `PENDING` (awaiting impl) → `COMPLETE` (ready to verify) → `VERIFIED` (done).

### Feedback Loop

`spec-verify` finds issues → status flips to PENDING → `spec-implement` fixes → COMPLETE → re-verify → … → VERIFIED.

### ⛔ Only THREE User Interaction Points

1. **Type confirmation** — new plans only, and only when the type (Feature vs Bugfix) is ambiguous (in dispatcher).
2. **Plan Approval** — in `spec-plan`/`spec-bugfix-plan`; always required before implementation begins.
3. **Code Review Gate** — final quality gate via `AskUserQuestion`.

Everything else is automatic. **NEVER ask "Should I fix these findings?"** — verification fixes are part of the approved plan.

### Deviation Handling (during /spec)

| Type | Trigger | Action |
|------|---------|--------|
| Bug / missing critical / blocking | Errors, missing validation, broken imports | Auto-fix inline, document deviation |
| Architectural | New table, library swap, breaking API | **STOP** — `AskUserQuestion` |

Auto-fix: inline + tests if applicable, do NOT expand scope. Outside `/spec`, respect the user's mode.

### Resuming After Interruptions

During `/spec`, after a user interruption ("Continue", a new mid-task message) or any pause, do NOT say goodbye or stop mid-plan. Your **very next action** must be a tool call (TaskList, Read plan, code change) — re-read the plan and resume until the plan is VERIFIED.

### Task Completion Tracking

Update plan after EACH task: `[ ]` → `[x]`, increment Done, decrement Left. Immediately.
