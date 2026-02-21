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

Consult the detailed reference for the language you're working in:
- **Python**: `~/.claude/standards/python.md`
- **Go**: `~/.claude/standards/go.md`
- **TypeScript/React/Tailwind**: `~/.claude/standards/typescript.md`

Key tools: Python=`uv`+`ruff`+`basedpyright`, Go=`gofumpt`+`golangci-lint`, TS=`pnpm`+`eslint`+`tsc`.

## Quality Gates (before every commit)

1. Format (auto-applied by hooks on save)
2. Lint (`ruff check` / `golangci-lint` / `eslint`)
3. Type check (`basedpyright` / `go vet` / `tsc --noEmit`)
4. Unit tests for changed modules

## Git Conventions

- Conventional commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)
- Branch naming: `<type>/<short-description>`
- Never force-push to main/master

## Templates

Use the templates at `~/.claude/templates/` for document generation:
- **ADR**: `~/.claude/templates/adr.md`
- **Epic Spec**: `~/.claude/templates/epic.md`
- **Story/RFP**: `~/.claude/templates/story.md`
- **Plan**: `~/.claude/templates/plan.md`
- **Commit Message**: `~/.claude/templates/commit.md`
- **Pull Request**: `~/.claude/templates/pr.md`
- **Monorepo Scaffold**: `~/.claude/templates/repo.md`

## Monorepo Standard

New repositories follow the standard monorepo template (`~/.claude/templates/repo.md`):
- Layered architecture: Foundation → Client → Service/Domain → Controller/API → Entrypoint
- Infrastructure in `zarf/` (Docker, K8s, Terraform, observability)
- Spec pipeline in `docs/adr/` + `docs/spec/{arch,epics,stories,plans}`
- Language conventions: Go=`pkg/`+`apps/`, Python=`src/`+`entrypoints/`, TS=`packages/`+`apps/`
- Use `/repo <name>` to scaffold, `/repo audit` to check compliance

## Architecture Patterns

- Clean/layered: Foundation → Client → Service/Domain → Controller/API
- Dependency injection at composition root
- Repository pattern for data access
- Early returns over nested conditionals
- Separate persistence models, domain entities, and DTOs

## Anti-Patterns to Avoid

- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior
