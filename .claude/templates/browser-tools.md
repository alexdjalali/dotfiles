# Browser Tools — reference

On-demand detail behind `~/.claude/rules/browser-automation.md`, which keeps the binding rules
(when to verify, the live-target probe, the tier chain, the E2E hard rules). Read this when you
pick or drive a tool.

## Tool Selection: 4-Tier Priority

Pick the tool that gives the most accurate verification for the situation, not the fastest.

| Priority | Tool | Best For | Key Advantage |
|----------|------|----------|---------------|
| 1st | Claude Code Chrome (`mcp__claude-in-chrome__*`) | Quick E2E, visual check | Shares user's existing browser session, natural-language `find` |
| 2nd | Chrome DevTools MCP (`mcp__plugin_chrome-devtools-mcp_*`) | DevTools-level debugging, perf audits | Direct CDP, Lighthouse, tracing — no extension needed |
| 3rd | `playwright-cli` | Thorough E2E, complex flows | Most reliable targeting, persistent sessions, network mocking, tracing, multi-tab |
| 4th | `agent-browser` | Lightweight checks | Concise output (200–400 tk/page), fast startup |

## Override the Default

| Situation | Use |
|-----------|-----|
| Lighthouse / performance trace | Chrome DevTools MCP |
| Network mocking, tracing, video | playwright-cli |
| Multi-tab workflow | playwright-cli |
| Persistent browser profile | playwright-cli (`--persistent`) |
| Auth flow (Clerk, OAuth) | playwright-cli (most reliable) or agent-browser |
| Already logged in, quick visual | Claude Code Chrome |
| Simple click-and-verify | agent-browser |

## Common Workflow Shape (all tools)

1. Get current state (tab/page/snapshot)
2. Navigate to target URL
3. Snapshot / read elements (gives you refs)
4. Interact (click / fill / press)
5. Re-snapshot to verify

## Session Isolation — MANDATORY in /spec or any parallel workflow

Without session isolation, parallel agents share one browser instance and clobber each other.

```bash
# agent-browser — pass a unique session id per parallel agent
agent-browser --session "${BROWSER_SESSION_ID:-default}" <command>

# playwright-cli
playwright-cli -s="${BROWSER_SESSION_ID:-default}" <command>
```

Chrome MCP and Chrome DevTools MCP target tabs/pages directly — no session ID needed.

## Tool-Specific Notes

- **Claude Code Chrome:** load tools via `ToolSearch(query="select:mcp__claude-in-chrome__<tool>")` first. Avoid triggering `alert/confirm/prompt` — they block the extension. Use `javascript_tool` + `console.log` for debugging.
- **Chrome DevTools MCP:** load via `ToolSearch(query="chrome-devtools-mcp", max_results=30)`. Snapshots use `uid=` refs that go stale after navigation — re-snapshot. Unique: `lighthouse_audit`, `performance_start_trace`, `evaluate_script`, `emulate`, network/console listing.
- **agent-browser:** uses `@e1`/`@e2` refs from `snapshot -i`. Refs invalidate after navigation/forms/dynamic loads — re-snapshot. Full command reference: `agent-browser --help`.
- **playwright-cli:** refs are bare numbers (`e1`, not `@e1`). Snapshots saved to files. Unique: `--persistent` profiles, `route` for mocking, `tracing-start/stop`, `video-start/stop`, cookie/localStorage management, `run-code` for raw Playwright. Full reference: `playwright-cli --help`.

## E2E Checklist

- [ ] User can complete the main workflow
- [ ] Forms validate and show errors correctly
- [ ] Success states display after operations
- [ ] Navigation works between pages
- [ ] Error states render properly
