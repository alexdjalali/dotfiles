## CLI Tools

### RTK — Rust Token Killer

Token-optimized CLI proxy (60–90% savings on dev operations).

```bash
rtk gain              # Token savings analytics
rtk gain --history    # Command usage history
rtk discover          # Find missed optimization opportunities
rtk proxy <cmd>       # Bypass filtering (debugging)
rtk --version         # Verify install
```

All other commands are auto-rewritten by the `rtk hook claude` PreToolUse hook (e.g., `git status` → `rtk git status`, transparent).

⚠️ **Name collision:** if `rtk gain` errors, you may have `reachingforthejack/rtk` (Rust Type Kit) on PATH instead.

---

### Semble — Code Search (CLI + MCP) — CO-PRIMARY

**Intent-based code search — co-primary with CodeGraph.** CodeGraph for structural queries (callers, callees, impact, symbol enumeration); Semble for intent queries (concept discovery, cross-cutting features, mutation sites, debugging, cross-language search). Grep for exact text in known files. Hybrid (BM25 + Model2Vec semantic embeddings), code-aware chunking, ~1.5ms queries, ranks by relevance.

Installed via `uv tool install semble` (also available as an MCP server — see `mcp-servers.md`). Verify with `semble --help`.

#### `semble search` — Hybrid Code Search

```bash
semble search "authentication flow" ./
semble search "save_pretrained" ./ --top-k 10            # symbol/identifier lookup
semble search "save model to disk" ./ --top-k 5          # natural-language intent
semble search "query" https://github.com/org/repo        # remote repo (cloned on demand)
```

**How ranking works:** Adaptive weighting (symbol-like queries get more lexical weight; NL queries balance semantic + lexical), definition boosts (defining `class`/`def`/`func` outranks references), identifier stem matching, file coherence, noise penalties (test/legacy/example down-ranked). Auto-reindexes on file change.

`--top-k <n>` controls result count (default 5). For most cases the defaults are correct — semble's chunks are already trimmed to the matched code only.

#### `semble find-related` — Similar Code by Location

```bash
semble find-related src/auth.ts 42 ./           # find code similar to src/auth.ts:42
semble find-related src/auth.ts 42 ./ --top-k 5
```

Pass `file_path` + `line` from a prior `semble search` result. Useful for discovering parallel implementations, related call sites, or test fixtures for a piece of code.

#### `semble savings` — Token-Saving Report

```bash
semble savings           # summary by period (today / 7-day / all-time)
semble savings --verbose # also breakdown by call type
```

The saving is `(file_chars − snippet_chars) / 4` per call: the baseline assumes the alternative was reading the matched files in full. Stats live at `~/.semble/savings.jsonl`.

#### When NOT to use Semble

- **Callers / callees / impact analysis** → use CodeGraph (`codegraph_callers` / `codegraph_callees` / `codegraph_impact`). Semble can find code that *mentions* a callee, but cannot enumerate callers.
- **AST pattern matching (e.g., "all `async function $X` declarations")** → no equivalent. Use CodeGraph by symbol name, or Grep as a last resort.
- **Extract enclosing block at `file:line`** → use `Read` with `offset`/`limit`, or `codegraph_node` when you have a symbol name.
