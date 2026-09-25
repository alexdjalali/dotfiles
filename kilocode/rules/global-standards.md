# Global Engineering Standards

Companion rules: `testing`, `verification`, `development-practices`, `code-review-reception`, `documentation-sync`; language rules load by file type (`python.md`, `go.md`, `typescript.md`). A project's constitution (`docs/constitution.md`) and its own rules override these.

## Process

Structural change: ADR (`docs/adr/`) → design / architecture diagrams (`docs/spec/design/`, `docs/spec/arch/`) → epic → stories (`docs/spec/epics/`, `docs/spec/stories/`) → plan (gitignored `docs/local/plans/`, `~/.claude/templates/plan.md`) → implement → verify → PR. Audits go in `docs/spec/audits/`, bug diagnoses in `docs/spec/rca/`. Templates: `~/.claude/templates/`.

- **ADR first** for architectural changes and any deviation from an established pattern.
- **TDD mandatory**; **verify before done**.
- **1 story = 1 commit** — commit each story on fast checks, review the whole commit range once, commit the fixes, then run the full gate once.

## Quality Gates

- **Fast checks** — per story, before each commit, on changed files: format → lint → type check → affected tests → docs updated.
- **Full gate** — once, after the last commit, before any push: the project's own gate if it has one (e.g. a repo-local preflight, `just lint` + `just test`), else the fast checks repo-wide + the full suite, 0 failures.
- **Never rerun a costly step on unchanged input** — record the commit it passed on and reuse it. A docs-only commit (`docs/**`, `*.md`) inherits the previous green full gate.
- Never bypass git hooks (`--no-verify`) — a failing hook is a red fast check: fix and retry.

Tools: Python `uv` `ruff` `basedpyright` · Go `gofumpt` `goimports` `golangci-lint` · TS `pnpm` `eslint` `tsc` `vitest`.

## Git

Conventional commits `<type>(<scope>): <description>`; branches `<type>/<short-description>`; never force-push main/master.

## Architecture

- Layers Foundation → Client → Service/Domain → Controller/API; **imports go downward only** — no lateral imports, shared libraries never import app code.
- DI at the composition root; repository pattern; separate persistence models, domain entities, DTOs; early returns.
- **Swappable components:** contract in a dependency-free core; impl chosen by config through a factory (`Kind` + `Config` + `*_from_config`, failing loudly on an unknown kind); cross-cutting concerns as decorators.
- Read configuration in one place. Monorepo layout: `~/.claude/templates/repo.md` (infrastructure in `zarf/`; Go `pkg/` + `apps/`, Python `src/` + `entrypoints/`, TS `packages/` + `apps/`).

## Anti-Patterns

Files > 800 lines, functions > 50, nesting > 4 · hardcoded secrets/URLs/config · mutable state shared across goroutines/async tasks · untyped `any`/`interface{}` · import cycles · tests of implementation instead of behavior · fakes / in-memory substitutes for real dependencies.
