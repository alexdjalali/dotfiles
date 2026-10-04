## Documentation Sync

**Docs change in the same change as the code** — stale docs are a bug; never leave a "docs to follow" TODO.

- **When:** a public API / CLI flag / config field / endpoint added, renamed, or removed; documented behavior changed; a breaking change (CHANGELOG / migration note); layout changed (the project's `*-project.md` rule, README). **Not** for internal refactors, bugs restoring documented behavior, or test-only changes — then say "no doc impact".
- **Where:** Grep the docs, READMEs, `CLAUDE.md` / `AGENTS.md`, docstrings, and comments for the changed symbol (direct), then one hop out via `codegraph_callers` / `codegraph_impact` for docs describing dependent behavior (indirect).
- **How:** change only what's now wrong; fix counts and lists ("supports X, Y, Z"); one term across code, docs, and help text. When you edit a documented symbol, **revise** its doc comment — never silently delete it.
- **Generated docs:** a doc derived from a source (config reference from the config schema, API reference from proto/OpenAPI, CLI reference from the command tree) is regenerated, never hand-edited.
- **Comments:** document every symbol (language standards); no issue-tracker IDs (Linear/Jira/GitHub numbers) in comments or doc comments — they rot and couple code to a tracker, so that context goes in the commit/PR. Link only committed in-repo docs (under `docs/`), never gitignored or scratch paths.
- **Report** the doc files touched alongside the code files.
