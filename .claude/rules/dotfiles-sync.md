---
paths:
  - "**/dotfiles/.claude/**"
  - "**/dotfiles/cursor/**"
  - "**/dotfiles/kilocode/**"
  - ".claude/CLAUDE.md"
  - ".claude/rules/**"
  - "cursor/rules/**"
---

## Dotfiles — cross-agent mirrors

`dotfiles/.claude/` is the source of truth. `cursor/rules/*.mdc` are hand-condensed, tool-neutral mirrors; `kilocode/rules/` is generated from them. After changing a mirrored source: edit the Cursor mirror, run `.claude/scripts/sync-mirrors.sh`, and confirm `--check` exits 0. (Not `/sync-docs`, which syncs a project's docs with its code.)

| Cursor mirror | Source |
|---|---|
| `global-standards` | `CLAUDE.md` (+ the test-double summary) |
| `testing` | `rules/testing.md` + `rules/testing-authoring.md` |
| `verification` | `rules/verification.md` (+ the live-target probe from `rules/browser-automation.md`) |
| `development-practices` | `rules/development-practices.md` (+ the debugging method from `skills/fix/SKILL.md`) |
| `code-review-reception` / `documentation-sync` | the same-named rule |
| `go` / `python` / `typescript-react` | `rules/standards-golang.md` / `standards-python.md` / `standards-typescript.md` + `standards-frontend.md` |

Not mirrored: `task-and-workflow`, `mcp-servers`, `linear`, `browser-automation`, `standards-backend`, `dotfiles-sync`, and all skills/agents.
