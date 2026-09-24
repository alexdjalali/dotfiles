# Global Engineering Standards

## Process

All structural changes follow: ADR → Arch → RFP → Spec (Plan → Implement → Verify) → Ship (`/github`).

**Model policy:** every skill is pinned to Opus via `model:` frontmatter, except `/github`, which runs on Sonnet — judgment, planning, and verification stay on Opus (deliberately not Fable, for cost and latency); git/PR plumbing runs on the cheaper one.

**Chaining is automatic.** Type `/spec` (or a phase) once; each phase hands off via `Skill(skill='<next-phase>')` in the same turn: `spec-plan` → **[plan approval]** → `spec-implement` → `spec-verify`, re-looping verify → implement until `Status: VERIFIED`. **Plan approval is the only manual gate** (plus a Feature-vs-Bugfix question in `/spec` only when ambiguous); `spec-verify` then *suggests* `/github` (Sonnet-pinned, every git write confirmed) — never auto-runs it. Hand-offs stay on the session's model, so keep the session on Opus; after an interruption or compaction, re-type the phase to re-apply its pin. `/spec` itself is `disable-model-invocation` (user-typed); its sub-skills chain freely.

- **ADR first**: Before architectural changes, write an ADR in `docs/adr/`.
- **Architecture**: Diagram affected components in `docs/spec/arch/`.
- **Decompose**: Break epics into stories via `/rfp` → `docs/spec/epics/` + `docs/spec/stories/`.
- **Plan before code**: Use `/spec` for non-trivial work → `docs/local/plans/` (gitignored local working docs, never committed; format: `~/.claude/templates/plan.md`).
- **TDD mandatory**: Write failing tests FIRST. Red → Green → Refactor.
- **Verify before done**: Run linters, type checkers, and tests before marking work complete.

**Supporting artifact skills** (each writes a `docs/spec/<folder>/` and chains into the pipeline above): `/roadmap` → `roadmap/` (sequences epics *above* `/rfp`: dependencies, phasing, critical path) · `/design-doc` → `design/` (the "how it works" *between* `/adr` and `/spec`) · `/audit` → `audits/` (durable, standard-scoped sibling of `/patterns`; feeds `/rfp`/`/spec`) · `/rca` → `rca/` (diagnosis-only, `file:line`-cited sibling of `/investigate`; feeds `/fix`/`/spec`) · `/demo` → `demos/` (E2E walkthrough + `.sh` proving a shipped epic works; persistent sibling of `/verify`).

## Language Standards

Per-language standards **auto-load** from `~/.claude/rules/standards-*.md` when you edit a matching file — Go, Python, TypeScript, plus `standards-backend.md` and `standards-frontend.md`. They attach by path; no manual consult needed.

**Precedence:** a project's own `.claude/rules/*` overrides these global rules. Repo-specific architecture (layered stacks, DI frameworks, employer conventions) belongs in that repo's `.claude/`, not in global config.

Key tools: Python=`uv`+`ruff`+`basedpyright`, Go=`gofumpt`+`goimports`+`golangci-lint`, TS=`pnpm`/detect+`eslint`+`tsc`+`vitest`.

## Quality Gates (before every commit)

Skills say "run the quality gates" for this. Use the project's own full gate when it documents one (a CLI such as `search preflight`, or `justfile` / `Makefile` / `package.json` targets such as `just lint` + `just test`); otherwise run, for the languages in the diff and in order:

1. Format — `ruff format` / `gofumpt` + `goimports` / `prettier` (hooks also format on save)
2. Lint — `ruff check` / `golangci-lint run` / `eslint`
3. Type check — `basedpyright` / `go vet` / `tsc --noEmit`
4. Tests — the full suite, 0 failures (`testing.md` *Zero Tolerance* and its completion checklist)
5. Docs & consistency — every doc referencing the change updated (`documentation-sync.md`); the touched files' patterns and helpers reused

Never skip a gate because a change "looks small"; never commit with one red.

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

Templates live in `~/.claude/templates/<name>.md` (Linear tickets under `linear/` — see `~/.claude/rules/linear.md`; standalone: `constitution.md`, `checklist.md`); each skill names the template it uses.

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

`~/.claude/` is the source of truth. `cursor/rules/` and `kilocode/rules/` hold condensed mirrors of this file and the agent-agnostic rules (no skill equivalents; the source→mirror map is in `cursor/rules/global-standards.mdc`) — when either changes, edit `cursor/rules/` by hand, then run `.claude/scripts/sync-mirrors.sh` to regenerate `kilocode/rules/` (`--check` reports drift). (Not `/sync-docs`, which reconciles a project's docs against its code.)

## Anti-Patterns to Avoid

- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior

@RTK.md
