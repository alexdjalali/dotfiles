# Global Engineering Standards

## Process

All structural changes follow: ADR → Arch → RFP → Spec (Plan → Implement → Verify) → Ship (`/github`).

**Model policy:** every command is pinned to Opus via `model:` frontmatter, except `/github`, which runs on Sonnet — judgment, planning, and verification stay on the strongest model; git/PR plumbing runs on the cheaper one. The `verify → implement` loop re-runs automatically until the plan is `VERIFIED`, then `/github` ships it (`git` writes always require explicit user confirmation). Run each phase as its own prompt to get its pinned model reliably — the `model:` switch is scoped to that command's turn, and chained auto-invocation honoring it is undocumented.

- **ADR first**: Before architectural changes, write an ADR in `docs/adr/`.
- **Architecture**: Diagram affected components in `docs/spec/arch/`.
- **Decompose**: Break epics into stories via `/rfp` → `docs/spec/epics/` + `docs/spec/stories/`.
- **Plan before code**: Use `/spec` for non-trivial work → `docs/spec/plans/`.
- **TDD mandatory**: Write failing tests FIRST. Red → Green → Refactor.
- **Verify before done**: Run linters, type checkers, and tests before marking work complete.

**Supporting artifact skills** (each writes to a `docs/spec/` folder, models the same command shape, and chains into the pipeline above):
- **`/roadmap`** → `docs/spec/roadmap/` — sequences epics *above* `/rfp` (dependency map, phasing, critical path).
- **`/design`** → `docs/spec/design/` — the detailed "how it works" narrative *between* `/adr` (decision) and `/spec` (tasks).
- **`/audit`** → `docs/spec/audits/` — a durable, standard-scoped codebase audit (the persistent sibling of `/patterns`); feeds `/rfp` or `/spec`.
- **`/rca`** → `docs/spec/rca/` — an evidence-cited, diagnosis-only bug root-cause (the persistent sibling of `/debug`); feeds `/fix` or `/spec`.
- **`/demo`** → `docs/spec/demos/` — an E2E walkthrough (+ companion `.sh`) proving a shipped epic works (the persistent sibling of `/verify`).

## Language Standards

Per-language standards **auto-load** from `~/.claude/rules/standards-*.md` when you edit a matching file — Go, Python, TypeScript, plus `standards-backend.md` and `standards-frontend.md`. They attach by path; no manual consult needed.

**Precedence:** a project's own `.claude/rules/*` overrides these global rules. Repo-specific architecture (layered stacks, DI frameworks, employer conventions) belongs in that repo's `.claude/`, not in global config.

Key tools: Python=`uv`+`ruff`+`basedpyright`, Go=`gofumpt`+`goimports`+`golangci-lint`, TS=`pnpm`/detect+`eslint`+`tsc`+`vitest`.

## Quality Gates (before every commit)

1. Format (auto-applied by hooks on save)
2. Lint (`ruff check` / `golangci-lint` / `eslint`)
3. Type check (`basedpyright` / `go vet` / `tsc --noEmit`)
4. Unit tests for changed modules

## Git Conventions

- Conventional commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)
- Branch naming: `<type>/<short-description>`
- Never force-push to main/master

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

- Use `/learn` to capture reusable knowledge into skills or memory
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
- **Roadmap**: `~/.claude/templates/roadmap.md`
- **Design Doc**: `~/.claude/templates/design.md`
- **Audit**: `~/.claude/templates/audit.md`
- **RCA**: `~/.claude/templates/rca.md`
- **Demo Walkthrough**: `~/.claude/templates/demo.md`

## Monorepo Standard

New repositories follow the standard monorepo template (`~/.claude/templates/repo.md`):
- Layered architecture: Foundation → Client → Service/Domain → Controller/API → Entrypoint
- Infrastructure in `zarf/` (Docker, K8s, Terraform, observability)
- Spec pipeline in `docs/adr/` + `docs/spec/{roadmap,arch,design,epics,stories,plans,audits,rca,demos}`
- Language conventions: Go=`pkg/`+`apps/`, Python=`src/`+`entrypoints/`, TS=`packages/`+`apps/`
- Use `/repo <name>` to scaffold, `/repo audit` to check compliance

## Architecture Patterns

- Clean/layered: Foundation → Client → Service/Domain → Controller/API
- Dependency injection at composition root
- Repository pattern for data access
- Early returns over nested conditionals
- Separate persistence models, domain entities, and DTOs
- **Implementation behind an interface, selected by configuration.** A swappable component's contract lives in a dependency-free core layer; the concrete impl is chosen by a config value through a factory (`Kind` + `Config` + a `*_from_config` constructor that fails loudly on an unknown kind), injected at the composition root, and wrapped by decorators for cross-cutting concerns (resilience, observability). Swapping one impl for another (stub → real) is then a config change, not a logic edit.
- **Layers import downward only.** Higher layers depend on lower ones, never the reverse; no lateral imports between same-layer packages; app code may import shared libraries, but shared libraries never import app code.
- **Read configuration in one place.** Bind env/config in a config layer or the composition root — not via env reads scattered through business logic.
- **A deviation from an established architectural pattern is an ADR, not a silent exception** — write it up in `docs/adr/` (the ADR-first process above, applied to code).

## Cross-Agent Sync

Commands in `~/.claude/commands/` are the source of truth. When updating commands,
sync equivalents to other agent configs:
- **Cursor**: `cursor/` rules directory
- **Kilocode**: `kilocode/` config directory

Keep the other agent configs in sync manually when commands change. (Not to be confused with `/sync-docs`, which reconciles docs against the codebase — a different task.)

## Anti-Patterns to Avoid

- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior

@RTK.md
