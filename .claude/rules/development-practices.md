## Development Practices

### Changes

- **Ambiguous request →** state assumptions and ask before coding.
- **Lineage test:** every changed line traces to the request; otherwise revert it. Remove what *your* change orphaned; mention (don't delete) pre-existing dead code.
- **Simplest thing:** if 200 lines could be 50, rewrite. Complexity is earned by real requirements.
- **⛔ Never invent values** — paths, env vars, keys, IDs, URLs, ports, hosts, versions, service names, unverified functions or library signatures. Confirm by reading the code, running the command, or asking.
- **Before modifying a shared function**, trace `codegraph_callers` / `codegraph_callees` (then Grep for dynamic callers).
- Fix obvious mistakes in code you're writing; report — don't auto-fix — code the user edited.
- Hot paths (render loops, handlers, polling) cache/memoize. Formatters own style. Backward compatibility only when required. Split a file > 1000 lines only when it's the task's focus.
- **Debugging:** no fix without a root cause; 3+ failed fixes = wrong approach, stop. Method: `/fix`.
- **Code search:** CodeGraph + Semble first (`mcp-servers.md`). **Prefer a tool's CLI** (`--help`, `Makefile`, `justfile`, `package.json`) over raw API calls or reimplementing it.

### Git — ⛔ writes need explicit permission

Read freely (`status`, `diff`, `log`, `show`, `branch`). **Writes** (`add`, `commit`, `push`, `pull`, `merge`, `rebase`, `reset`, `stash`, `checkout`) only when the user asks — "fix this" ≠ "commit it".

- **Never** `git checkout --` / discard unstaged work — explain and let the user run it. Never `git add -f`. Never selectively unstage. Never force-push main/master.
- **Never auto-branch** — work on the checked-out branch; create or switch only when asked in *this* request (a naming convention isn't a request). New branches push with `-u`.
- **`/spec` exception:** plan approval authorizes the chain's commits on the current branch — one per story, one review-fix commit per loop-back, and the final `docs(spec): close …` story-closure commit (`git add <files>` + `git commit`) — nothing else. Unrelated uncommitted changes → stop and ask first.
- **Never bypass hooks** (`--no-verify`, `LEFTHOOK=0`): a failing hook is a red fast check — fix, re-stage, retry. Hooks that re-stage files (tidy, codegen) are fine; the extra files belong to the commit.
