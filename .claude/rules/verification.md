## Verification

**Core rules:** (1) Tests passing ≠ program working — always execute. (2) No completion claim without fresh evidence in the current message.

### Execution Verification

Unit tests with mocks prove nothing about real-world behavior. After tests pass:

- CLI command → run it. API endpoint → call it. Frontend UI → use browser automation (see `browser-automation.md`). Any runnable program → run it.

**When:** after tests pass, after refactoring, after changing imports/deps/config, before marking any task complete. **Skip only for:** docs-only, test-only, pure internal refactoring with no entry points, config-only.

**⛔ Frontend changes require browser verification, and the live-target probe must run before any "I can't run live E2E" claim** — in `/spec` and quick mode. Procedure, 4-tier probe, and hard rules: `~/.claude/rules/browser-automation.md` (read it for any UI change).

### Output Correctness

Running without errors ≠ correct output. If code processes external data, fetch independently and compare. Numbers and content MUST match.

### Evidence Before Claims

Before proceeding, ask: "Do these tests verify what matters, or only what was easy to test?" If important edge cases go untested, acknowledge the gap explicitly — don't claim full coverage with partial.

1. **Identify** — what command proves this claim?
2. **Execute** — run the full command (not cached).
3. **Read output** — check exit code, count failures.
4. **Report** — state claim WITH evidence.

**If you haven't run the command in this message, you cannot claim it passes.**

| Claim | Required Evidence | Insufficient |
|-------|-------------------|--------------|
| "Tests pass" | Fresh run: 0 failures | Previous run, "should pass" |
| "Build succeeds" | Build exit 0 | "Linter passed" |
| "Bug fixed" | Reproducing test passes | "Code changed" |
| "UI works" | Browser snapshot/read_page | "API returns 200" |
| "No perf regression" | Hot paths cache/memoize, no heavy imports, no redundant repeat work | "Tests pass" |

### ⛔ Fix ALL Errors — No Exceptions, No Asking

In `/spec`, fix all verification errors without asking (finding tiers → action: `code-review-reception.md` *Workflow reviews*; plan approval is the only `/spec` checkpoint). Outside `/spec`, respect the user's mode — in plan mode, present issues and proposed fixes instead of applying them.

### Stop Signals — Verify NOW

About to use uncertain language ("should", "probably"), express satisfaction ("Done!"), commit/push, or mark complete? Run verification first.

### When Execution Fails After Tests Pass

This is a real bug. During `/spec`: fix → re-run tests → re-execute → add a test to catch this failure type. Outside `/spec`: report and propose.

### Five Failure Modes Self-Check

Before reporting completion, pass against each of the five (2026 Agentic Coding Trends Report):

- **Hallucinated actions** — invented paths, env vars, IDs, function names, library APIs, URLs (e.g., `STRIPE_SECRET_KEY` when actual is `STRIPE_SK`). Cross-ref *Never invent values* in `development-practices.md`.
- **Scope creep** — diff touches files/behaviors outside the request? Bundled refactors, "while I'm here" cleanups? Apply the lineage test (`development-practices.md`).
- **Cascading errors** — a failure suppressed/caught/wrapped in a way that hides root cause. Silent fallbacks (try/except returning `[]`, papering over missing data) metastasize bugs.
- **Context loss** — diff contradicts earlier decisions in the session, plan, CLAUDE.md, or CONTEXT.md? ~65% of agent failures trace to context drift, not token exhaustion.
- **Tool misuse** — wrong tool for the job (Bash for file reads, MCP when CLI was simpler), or right tool with wrong params (Grep without escaping, Edit without reading first). Re-check `cli-tools.md` and `mcp-servers.md`.

**Any mode flagged → fix and re-run, don't claim done.** Stop Signals and Evidence Before Claims are the during-work guards; Five Modes is the pre-completion checklist.
