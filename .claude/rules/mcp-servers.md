## MCP Servers

MCP tools are lazy-loaded: `ToolSearch` by keyword (`"keyword"`, `"+server keyword"` to require a server prefix, or `"select:full_tool_name"`) returns their full schemas, and they're callable immediately after. Names are `mcp__<server>__<tool>` (e.g. `mcp__codegraph__`, `mcp__semble__`); the summaries below cover purpose and minimum usage.

### Code Search — CodeGraph (structure) + Semble (intent)

Co-primary for every code-search task; Grep/Glob only verify their completeness or find exact text in a known file. **⛔ NEVER pass `projectPath` to CodeGraph for the current project** — it takes a code path that fails with "not initialized" unless `.codegraph/` is at that exact path; the server defaults correctly (use it only for a genuinely different codebase).

| Scenario | Tool |
|---|---|
| **Start here** — orient on a task, "how does X work", trace a flow | `codegraph_explore` — accepts a natural-language question OR symbol/file names (`codegraph_explore(query="SymA SymB file.ts")`); returns the relevant source grouped by file in one call |
| Find a symbol by name | `codegraph_search` |
| Callers / callees before modifying | `codegraph_callers` / `codegraph_callees`, then Grep for dynamic callers |
| Blast radius | `codegraph_impact` |
| One symbol's full source | `codegraph_node` |
| File tree / index health | `codegraph_files` / `codegraph_status` |
| Concept, cross-cutting feature, "where is X modified/configured", debugging | `mcp__semble__search(query, repo?, top_k?, mode?)` — `mode` `hybrid` (default) / `semantic` / `bm25`; `repo` = local path or `https://` git URL |
| Similar code / parallel implementations | `mcp__semble__find_related(file_path, line, repo?, top_k?)` — no CodeGraph equivalent |

Semble can't enumerate callers or match AST patterns (e.g. every `async function $X`) — use CodeGraph (or Grep as a last resort); for the block at `file:line`, `Read` with `offset`/`limit` or `codegraph_node`. The `semble` CLI (`uv tool install semble`; `semble --help`) mirrors the MCP tools: `semble search "<query>" ./ --top-k <n>`, `semble find-related <file> <line> ./`, `semble savings` (saving = `(file_chars − snippet_chars) / 4` per call; stats in `~/.semble/savings.jsonl`).

### context7 — Library Documentation

Up-to-date docs and code examples for any library/framework: `resolve-library-id(libraryName, query)` → a `libraryId` like `/pypi/pytest`, then `query-docs(libraryId, query)`. Use descriptive queries. Max 3 calls per question per tool.

### Web — web-search / web-fetch (prefer over built-in `WebSearch` / `WebFetch`)

- **web-search** (ToolSearch `+web-search search`): `search(query, limit?, engines?)` — DuckDuckGo / Bing / Exa, no API keys. GitHub README: `fetchGithubReadme(url)` (`+web-search fetch`).
- **web-fetch** (`+web-fetch fetch`): Playwright-backed, no truncation, handles JS-rendered pages — use for full page content. `fetch_url(url, ...)` / `fetch_urls(urls=[...], ...)`; `browser_install(withDeps?, force?)` installs Chromium. Options: `waitUntil` (`load`/`domcontentloaded`/`networkidle`), `returnHtml`, `waitForNavigation` (anti-bot).

### grep-mcp — GitHub Code Search

`searchGitHub(query, language?, repo?, path?, useRegexp?, matchCase?)` — finds real-world production code in 1M+ public repos. Query is a literal pattern (or regex with `useRegexp=true`; prefix `(?s)` for multiline). Filter `language=["Python"]`, `repo="vercel/next-auth"`, `path="src/components/"`.
