# Global Engineering Standards

## Process

Structural change: `/adr` → `/design-doc` (or `/design-doc arch` for diagrams) → `/rfp` (epic → stories) → `/spec` (plan → implement → verify) → `/github`. Also: `/audit` (quick sweep, standard audit, `repo` layout), `/rca` (diagnosis only), `/fix` (contained bug).

- **ADR first** for architectural changes and for any deviation from an established pattern.
- **Plan before code** for non-trivial work: `/spec` → gitignored `docs/local/plans/` (`~/.claude/templates/plan.md`).
- **TDD mandatory** (`testing.md`). **Verify before done** (`verification.md`).

**`/spec` chain** (user-typed; phases hand off via `Skill()` in the same turn): `spec-plan` → **[plan approval — the only gate]** → `spec-implement` → `spec-verify`, looping verify → implement until `Status: VERIFIED`. **1 story = 1 commit:** each story commits on fast checks; verify reviews all the chain's commits once with `/review-diff`, commits the fixes, runs the full gate once, then suggests `/github pr`.

**Models:** skills pin `model:` / `effort:` in frontmatter (applies typed or chained) — Fable for review, Opus 5.5 for planning/diagnosis/verification, Opus 4.8 for execution, Sonnet for mechanical steps. Frontmatter is the source of truth.

## Quality Gates

- **Fast checks** — per story, before each commit, scoped to changed files: format → lint → type check → affected tests → docs updated (`documentation-sync.md`).
- **Full gate** — once, after the last commit, before any push: the project's own gate if it has one (e.g. a repo-local preflight, `just lint` + `just test`), else fast checks repo-wide + the full suite, 0 failures.
- **Never rerun a costly step on unchanged input.** The full gate, reviews, `spec-review`, and live execution record the SHA (or clean tree) they passed on; later steps reuse it and re-run only what a change touched.
- Never commit on a red fast check; never push on a red or unrun full gate.

Tools: Python `uv` `ruff` `basedpyright` · Go `gofumpt` `goimports` `golangci-lint` · TS `pnpm` `eslint` `tsc` `vitest`. Language standards auto-load by path from `rules/standards-*.md`.

## Precedence

A project's `docs/constitution.md` / `.claude/constitution.md` and its `.claude/rules/*` override these global rules. Repo-specific architecture belongs in that repo's `.claude/`.

## Git

Conventional commits `<type>(<scope>): <description>`; branches `<type>/<short-description>`; never force-push main/master. Write-command permissions: `development-practices.md`.

## Architecture

- Layers Foundation → Client → Service/Domain → Controller/API; **imports go downward only** — no lateral imports, shared libraries never import app code.
- DI at the composition root; repository pattern for data access; separate persistence models, domain entities, DTOs; early returns.
- **Swappable components:** contract in a dependency-free core; impl chosen by config through a factory (`Kind` + `Config` + `*_from_config`, failing loudly on an unknown kind); cross-cutting concerns as decorators.
- Read configuration in one place (config layer / composition root).
- Monorepo layout: `~/.claude/templates/repo.md`.

## Anti-Patterns

Files > 800 lines, functions > 50, nesting > 4 · hardcoded secrets/URLs/config · mutable state shared across goroutines/async tasks · untyped `any`/`interface{}` · import cycles · tests of implementation instead of behavior.

@RTK.md
