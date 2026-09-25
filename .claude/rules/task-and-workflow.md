# Task & Workflow

## Choosing a lane

- **Default: quick mode** — do it directly. Architectural / 20+ files / cross-cutting → ask: `/spec` or quick mode?
- **Don't suggest `/spec`** for bugfixes, single features, one-module refactors, flag/config/dependency changes, test additions, or anything with a clear outcome. In doubt → quick mode.
- **⛔ Never invoke `/spec`** — the user types it (it's `disable-model-invocation`). Suggest it instead of Claude Code plan mode.
- **Bugs:** contained (cause known or not) → `/fix` · several related, or someone else fixes → `/rca` (diagnosis only) · cross-layer / schema / API → `/spec` bugfix lane. A reproducing test is mandatory everywhere but `/rca`. An outgrown `/fix` stops and escalates — never silently.
- **Resuming `/spec`** after an interruption or compaction: the next action is a tool call — re-read the plan and continue until VERIFIED.

## Tasks

Working memory that survives compaction — for **multi-step work (3+ steps)** or when tasks already exist, not for one-shots.

- Create the task before starting; mark in_progress → completed as you go; a new mid-work request gets a task first, then triage.
- Session start or continuation: `TaskList` first; resume the first uncompleted, delete stale ones. `TaskList` is the source of truth.
- Deferring something → create the task now; never just say "noted".

## Agents — ⛔ no fan-out (cost)

- **Work inline by default.** Launch a subagent only when a skill step names it (`spec-review`; `/review-diff deep`), a skill declares `context: fork` (a sequential foreground fork that keeps its reads out of this context — `review-diff`), or the user asks. Never several in parallel, never one "to be thorough", never Explore/Plan/Research agents for code search — use CodeGraph + Semble (`mcp-servers.md`). `/code-review` at `high`/`max` fans out agents — only on request.
- **Review any diff with `/review-diff`** — never a hand-launched `changes-review` (Codex-only).
- Subagents run in the background and notify on completion — never predict a pending result, never use `TaskOutput`; continue one with `SendMessage`. `spec-review` writes JSON to `output_path`: poll for the file, Read once. Subagents don't inherit rules.
- **Codex companion:** run `codex-companion.mjs` directly via Bash (`~/.claude/templates/codex-changes-review.md`); `codex:codex-rescue` only for user-typed `/codex:rescue`.
- `run_in_background` Bash only for long-running processes (servers, watchers).
