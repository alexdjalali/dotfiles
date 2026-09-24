# Global Engineering Standards

## Process

All structural changes follow: ADR → Arch → RFP → Spec (Plan → Implement → Verify) → Ship (`/github`).

**Model policy:** every command is pinned to Opus via `model:` frontmatter, except `/github`, which runs on Sonnet — judgment, planning, and verification stay on Opus (deliberately not Fable, for cost and latency); git/PR plumbing runs on the cheaper one.

**Chaining is automatic.** Type `/spec` (or a phase) once; each phase hands off via `Skill(skill='<next-phase>')` in the same turn: `spec-plan` → **[plan approval]** → `spec-implement` → `spec-verify`, re-looping verify → implement until `Status: VERIFIED`. **Plan approval is the only manual gate** (plus a Feature-vs-Bugfix question in `/spec` only when ambiguous); `spec-verify` then *suggests* `/github` (Sonnet-pinned, every git write confirmed) — never auto-runs it. Hand-offs stay on the session's model, so keep the session on Opus; after an interruption or compaction, re-type the phase to re-apply its pin. `/spec` itself is `disable-model-invocation` (user-typed); its sub-skills chain freely.

- **ADR first**: Before architectural changes, write an ADR in `docs/adr/`.
- **Architecture**: Diagram affected components in `docs/spec/arch/`.
- **Decompose**: Break epics into stories via `/rfp` → `docs/spec/epics/` + `docs/spec/stories/`.
- **Plan before code**: Use `/spec` for non-trivial work → `docs/local/plans/` (gitignored local working docs, never committed; format: `~/.claude/templates/plan.md`).
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

- Conventional commits: `<type>(<scope>): <description>`, scope optional (feat, fix, refactor, docs, test, chore, perf, ci, style)
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

Significant decisions, domain context, and learnings persist per project — review them before starting work on unfamiliar areas. They survive session clears and provide cross-session continuity.

- `/learn` captures a reusable insight as a skill (`.claude/skills/<slug>/SKILL.md`); `/vault` stores snippets and one-off solutions (`.claude/vault/`)
- Decisions and context live in the tracked `docs/` pipeline (ADRs, design docs, RCAs)
- Store: domain concepts, past architectural decisions, team conventions, gotchas

## Templates

Templates live in `~/.claude/templates/<name>.md` (Linear tickets under `linear/` — see `~/.claude/rules/linear.md`; standalone: `constitution.md`, `checklist.md`); each command names the template it uses.

## Monorepo Standard

New repositories follow the standard monorepo layout: `/repo <name>` scaffolds it and `/repo audit` checks compliance (canonical layout: `~/.claude/templates/repo.md`).

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

`~/.claude/` is the source of truth. `cursor/rules/` and `kilocode/rules/` mirror this file and the rules (they have no command equivalents) — when either changes, update the mirrors manually. (Not to be confused with `/sync-docs`, which reconciles a project's docs against its codebase — a different task.)

## Anti-Patterns to Avoid

- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior

@RTK.md
