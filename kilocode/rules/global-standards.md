# Global Engineering Standards

## Process

All structural changes follow: ADR → Arch → RFP → Spec (Plan → Implement → Verify).

- **ADR first**: Before architectural changes, write an ADR in `docs/adr/`.
- **Architecture**: Diagram affected components in `docs/spec/arch/`.
- **Decompose**: Break epics into stories via `/rfp` → `docs/spec/epics/` + `docs/spec/stories/`.
- **Plan before code**: Use `/spec` for non-trivial work → `docs/spec/plans/`.
- **TDD mandatory**: Write failing tests FIRST. Red → Green → Refactor.
- **Verify before done**: Run linters, type checkers, and tests before marking work complete.

## Language Standards

Consult the language-specific rule file for your current language:
- **Python**: `python.md`
- **Go**: `go.md`
- **TypeScript/React/Tailwind**: `typescript.md`

Key tools: Python=`uv`+`ruff`+`basedpyright`, Go=`gofumpt`+`goimports`+`golangci-lint`, TS=`pnpm`/detect+`eslint`+`tsc`+`vitest`.

## Project Constitution

If a project has `docs/constitution.md` or `.claude/constitution.md`, its principles
take precedence over global standards for that project. Use constitutions to:
- Establish non-negotiable project-specific principles (e.g., "no ORM", "gRPC only")
- Override global defaults when justified (e.g., different coverage thresholds)
- Document technology constraints and quality budgets

Template: `~/.claude/templates/constitution.md`

## Project Memory

Significant decisions, domain context, and learnings persist in `docs/spec/memory/`
(or `.claude/memory/`) per project. Review before starting work on unfamiliar areas.

- Memory files survive session clears and provide cross-session continuity
- Store: domain concepts, past architectural decisions, team conventions, gotchas

## Templates

Use the templates at `~/.claude/templates/` for document generation:
- **ADR**: `~/.claude/templates/adr.md`
- **Epic Spec**: `~/.claude/templates/epic.md`
- **Story/RFP**: `~/.claude/templates/story.md`
- **Plan**: `~/.claude/templates/plan.md`
- **Commit Message**: `~/.claude/templates/commit.md`
- **Pull Request**: `~/.claude/templates/pr.md`
- **Monorepo Scaffold**: `~/.claude/templates/repo.md`
- **Constitution**: `~/.claude/templates/constitution.md`
- **Checklist**: `~/.claude/templates/checklist.md`

## Monorepo Standard

New repositories follow the standard monorepo template (`~/.claude/templates/repo.md`):
- Layered architecture: Foundation → Client → Service/Domain → Controller/API → Entrypoint
- Infrastructure in `zarf/` (Docker, K8s, Terraform, observability)
- Spec pipeline in `docs/adr/` + `docs/spec/{roadmap,arch,design,epics,stories,plans,audits,rca,demos}`
- Language conventions: Go=`pkg/`+`apps/`, Python=`src/`+`entrypoints/`, TS=`packages/`+`apps/`

## Quality Gates (before every commit)

1. Format (auto-applied by hooks on save)
2. Lint (`ruff check` / `golangci-lint` / `eslint`)
3. Type check (`basedpyright` / `go vet` / `tsc --noEmit`)
4. Unit tests for changed modules

## Test Doubles (two tiers)

- **Unit → mock the boundary.** Real code under test; external collaborators (HTTP, DB, cache, queue, object store, subprocess, clock, 3rd-party API) replaced by a **mock** (generated, or a mock of a small consumer-side interface). Reuse existing fixtures.
- **Integration → real dependency in a Docker container via testcontainers**, driven by fixtures, cleaned up in teardown — Go `testcontainers-go` (`//go:build integration`), Python `testcontainers` (`@pytest.mark.integration`), Node `@testcontainers/postgresql`.
- **`must_fix`:** a hand-rolled fake / stub / in-memory client, an in-memory substitute where a real service belongs (SQLite-for-Postgres, `fakeredis`, in-process queue), or a mock of the very dependency an integration test exists to exercise. Folder ≠ tier: a mock inside `integration/` is a mislabeled unit test.

## Git Conventions

- Conventional commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)
- Branch naming: `<type>/<short-description>`
- Never force-push to main/master

## Architecture Patterns

- Clean/layered: Foundation → Client → Service/Domain → Controller/API
- Dependency injection at composition root
- Repository pattern for data access
- Early returns over nested conditionals
- Separate persistence models, domain entities, and DTOs
- Implementation behind an interface, selected by configuration (`Kind` + `Config` + a factory that fails loudly on unknown kinds), injected at the composition root, wrapped by decorators — swapping impls (stub → real) is a config change, not a logic edit
- Layers import downward only; app code may import shared libs, shared libs never import app code
- A deviation from an established pattern is an ADR, not a silent exception

## Cross-Agent Sync

Commands in `~/.claude/commands/` are the source of truth. When updating commands,
sync equivalents to other agent configs:
- **Cursor**: `cursor/` rules directory
- **Kilocode**: `kilocode/` config directory

## Anti-Patterns to Avoid

- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior
- Fakes / in-memory substitutes where a mock (unit) or a real container (integration) belongs
- Silently deleting an existing doc comment while editing its symbol (revise it, never drop it)
