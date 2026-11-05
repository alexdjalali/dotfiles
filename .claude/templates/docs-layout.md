# Docs layout — where the artifact skills read and write

Skills never hard-code a docs folder. Each artifact's folder is a **layout path**, resolved in this
order:

1. **The repo's layout file** — `.claude/docs-layout.yaml` at the repository root, when it exists.
   Its `paths.<artifact>` is the folder. A repo renders it from its own config (e.g.
   `search gen docs-layout`); it is per checkout and gitignored.
2. **Else the fallback** below — today's default layout.

| Artifact | Layout key | Fallback |
|---|---|---|
| ADR | `adr` | `docs/adr` |
| Design doc | `design` | `docs/spec/design` |
| Architecture diagrams | `arch` | `docs/spec/arch` |
| Epic | `epic` | `docs/spec/epics` |
| Story | `story` | `docs/spec/stories` |
| RCA | `rca` | `docs/spec/rca` |
| Audit | `audit` | `docs/spec/audits` |
| Plan | `plan` | `docs/local/plans` |

- `{epic}` in a path is the epic's directory name (e.g. `epic-63-okf-docs-bundle`): a story path
  of `docs/delivery/epics/{epic}/stories` puts story 63.2 under its epic's folder. An epic path
  whose epics are directories holds `<epic dir>/epic.md`; otherwise an epic is
  `<epic path>/epic-NN-<slug>.md`.
- Read the file once per skill run (`cat .claude/docs-layout.yaml`); never guess a folder it does
  not name — fall back instead.
- **Frontmatter.** When the layout file says `frontmatter: true`, a new artifact opens with the
  OKF frontmatter block from its template (`type`, `title`, `description`, `status`, `tags`,
  `generated`). `generated.by` is the actor that wrote the file — `human:<id>` for a person,
  `<tool>/<model>` for an agent (e.g. `claude-code/claude-opus-4-8`) — and `generated.at` an
  RFC 3339 datetime. With no layout file, or `frontmatter: false`, omit the block.
- **Names.** When the layout file has `names.<artifact>`, a new artifact's filename (without its
  extension) follows that rule. Tokens: `{date}` (`YYYY-MM-DD`), `{nnnn}` (four digits, the next
  free number), `{nn}` (two or more digits), `{epic}` (the epic's number), `{n}` (the next number
  in the epic), `{slug}` (lowercase kebab-case starting with a letter). An epic's rule names its
  directory. No `names` entry → the skill's own default name.
- Links between artifacts are **relative** (`../decisions/0120-x.md`), never bundle-absolute
  (`/docs/...`), so they survive a folder move.
