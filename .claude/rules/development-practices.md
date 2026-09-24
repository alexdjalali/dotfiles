## Development Practices

### Codebase Exploration

CodeGraph + Semble first, Grep/Glob only to verify — scenario table and the ⛔ `projectPath` rule: `mcp-servers.md`.

### Change Discipline

- **Think before coding.** When a request is ambiguous, state assumptions, present alternatives, ask — before writing code.
- **Lineage test.** Every changed line must trace to the user's request. If it doesn't, revert.
- **Orphan cleanup.** Remove imports/vars/functions YOUR changes made unused. Don't touch pre-existing dead code — mention, don't delete.
- **Self-check.** "Would a senior engineer call this overcomplicated?" If 200 lines could be 50, rewrite. Complexity is earned by actual requirements.

**⛔ Never invent values.** File paths, env var names/values, API keys, IDs (UUIDs, FK ids, third-party object ids), URLs, ports, hostnames, version numbers, third-party service names, function/class names not verified to exist, library API signatures — must be authoritatively confirmed (read the code, run the command, or ask). Pattern-matching a plausible value is the top cause of agent-introduced incidents per the 2026 Agentic Coding Trends Report. If unsure, **STOP and ask** — one round-trip beats a hallucination. See *Evidence Before Claims* in `verification.md`.

### Project Policies

- **File size:** aim < 800 lines. > 1000 is a split signal — only when it's the focus of the current task, not a side-refactor. Test files exempt.
- **Dependency check:** before modifying a shared or non-trivial function, trace `codegraph_callers` + `codegraph_callees` (then Grep for completeness) — it catches callers you'd otherwise miss. A self-contained local function the plan already isolated doesn't need it.
- **Self-correction:** fix obvious mistakes (syntax, typos, missing imports) in code you're actively writing. Do NOT auto-fix code the user edited — report it.
- **Performance:** hot paths (render loops, request handlers, polling) must cache/memoize. Use lighter alternatives for heavy deps. Don't redo work when input hasn't changed.
- **Diagnostics:** check before starting, after changes. Fix all errors before marking complete.
- **Formatting:** automated formatters handle style. **Backward compatibility:** only when explicitly required.

### Systematic Debugging

**No fixes without root cause investigation.** **3+ failed fixes = the approach is wrong** — stop and question the pattern, don't fix again. Full method (phases, red flags, revert-first, defense-in-depth, condition-based waiting, constraint classification): `/investigate`.

### Git Operations

**Read git state freely. NEVER execute write commands without EXPLICIT user permission.** This is about git commands, not file edits — file editing is always allowed.

- **⛔ Write commands need permission:** `git add`, `commit`, `push`, `pull`, `merge`, `rebase`, `reset`, `stash`, `checkout`. "Fix this bug" ≠ "commit it."
- **⛔ NEVER `git checkout --` on unstaged changes.** Irreversible — work is permanently lost. Tell the user the consequences and let THEM run it. "Remove this" / "revert this" do NOT mean "discard all unstaged work." Use Edit for targeted changes.
- **⛔ Never `git add -f`** — if gitignored, tell the user.
- **⛔ Never selectively unstage** — commit all staged changes as-is.
- **⛔ Always `git push -u` on new branches** so the local branch tracks the correct remote.
- **⛔ Respect the active branch. Never auto-branch.** Work on whatever branch the user has checked out. Do NOT run `git checkout -b`, do NOT switch branches, do NOT invent branch names (e.g. `<username>/<feature>`, `feat/<slug>`, `fix/<slug>`) unless the user explicitly asks for a new branch in *this* request. Project conventions in `CLAUDE.md` / `AGENTS.md` that mandate a branch-naming pattern do NOT count as a request to create one now — surface the convention and ask.
- **Read commands always allowed:** `status`, `diff`, `log`, `show`, `branch`.
- **Exceptions:** explicit override ("checkout branch X", "create a new branch for this").
