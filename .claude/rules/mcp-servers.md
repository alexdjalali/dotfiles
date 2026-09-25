## MCP Servers

Load a deferred tool with `ToolSearch` (`"select:<name>"` or keywords) before calling it.

**Code search — CodeGraph (structure) + Semble (intent), before Grep/Glob** (those only verify or find exact text in a known file). **⛔ Never pass `projectPath` to CodeGraph for the current project** — it defaults correctly; the param is only for a different codebase.

| Need | Tool |
|---|---|
| Orient / "how does X work" / trace a flow | `codegraph_explore` (question or symbol/file names) — usually the only call needed |
| Symbol by name · one symbol's source | `codegraph_search` · `codegraph_node` |
| Callers / callees / blast radius | `codegraph_callers` / `codegraph_callees` / `codegraph_impact` (then Grep for dynamic callers) |
| Concept, cross-cutting feature, "where is X configured" | `mcp__semble__search` (`mode` hybrid/semantic/bm25) |
| Similar code / parallel implementations | `mcp__semble__find_related(file_path, line)` |

**Others:** `context7` for library docs (`resolve-library-id` → `query-docs`, ≤ 3 calls) · `web-search` / `web-fetch` over built-in WebSearch/WebFetch · `grep-mcp` `searchGitHub` for real-world code examples.
