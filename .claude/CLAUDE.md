# Global Engineering Standards

## Process

Structural change: `/adr` → `/design-doc` (or `/design-doc arch` for diagrams) → `/rfp` (epic → stories) → `/spec` (plan → implement → verify) → `/github`. Also: `/audit` (quick sweep, standard audit, `repo` layout), `/rca` (diagnosis only), `/fix` (contained bug).

- **ADR first** for architectural changes and for any deviation from an established pattern.
- **Plan before code** for non-trivial work: `/spec` → gitignored `docs/local/plans/` (`~/.claude/templates/plan.md`).
- **TDD mandatory** (`testing.md`). **Verify before done** (`verification.md`).
- **Own what you find.** Fix a problem when it comes up — a failing test, a broken config, a gap in a module, a stale local file — instead of deferring it, routing around it, or attributing it elsewhere ("pre-existing", "the user's config", "a later story"). Only what you can't do yourself (missing credentials, a destructive or outward-facing step) goes back to the user, with the exact command.

**`/spec` chain** (user-typed; phases hand off via `Skill()` in the same turn): `spec-plan` → **[plan approval — the only gate]** → `spec-implement` → `spec-verify`, looping verify → implement until `Status: VERIFIED`. **1 story = 1 commit:** each story commits on fast checks; verify reviews all the chain's commits once with `/review-diff`, commits the fixes, runs the full gate once, then suggests `/github pr`.

**Models:** skills pin `model:` / `effort:` in frontmatter (applies typed or chained) — Fable for review, Opus 5.5 for planning/diagnosis/verification, Opus 4.8 for execution, Sonnet for mechanical steps. Frontmatter is the source of truth.

## Quality Gates

- **Fast checks** — per story, before each commit, scoped to changed files: format → lint → type check → affected tests → docs updated (`documentation-sync.md`).
- **Full gate** — once, after the last commit, before any push: the project's own gate if it has one (e.g. a repo-local preflight, `just lint` + `just test`), else fast checks repo-wide + the full suite, 0 failures.
- **Never rerun a costly step on unchanged input.** The full gate, reviews, `spec-review`, and live execution record the SHA (or clean tree) they passed on; later steps reuse it and re-run only what a change touched.
- **Docs-only commits inherit the gate.** A commit touching only `docs/**` and `*.md` (e.g. closing stories) keeps the previous SHA's green full gate — record it as `green @ <sha> (+docs <sha2>)`; no rerun.
- Never commit on a red fast check; never push on a red or unrun full gate. Never bypass hooks (`--no-verify`, `LEFTHOOK=0`) — a hook failure is a red fast check: fix, re-stage, retry.

Tools: Python `uv` `ruff` `basedpyright` · Go `gofumpt` `goimports` `golangci-lint` · TS `pnpm` `eslint` `tsc` `vitest`. Language standards auto-load by path from `rules/standards-*.md`.

## Precedence

A project's `docs/constitution.md` / `.claude/constitution.md` and its `.claude/rules/*` override these global rules. Repo-specific architecture belongs in that repo's `.claude/`.

## Git

Conventional commits `<type>(<scope>): <description>`; branches `<type>/<short-description>`; never force-push main/master. Write-command permissions: `development-practices.md`.

## Architecture

**The One Idea:** everything is an implementation detail behind an interface, selected by configuration, injected explicitly, and wrapped by decorators. General by default; the checklist is `~/.claude/templates/code-addition-checklist.md`.

- **Generate > generalize > hand-write.** Code derived from a contract (proto, OpenAPI, schema, DI graph, mocks) comes from the project's generator via its CLI; output is committed, never hand-edited, and CI fails on drift. A repeated shape becomes a template/scaffold.
- Layers Foundation → Client → Service/Domain → Controller/API; **imports go downward only** — no lateral imports, shared libraries never import app code. DRY = push logic down into the shared library, inject product strategy up.
- **Swappable components:** contract in a dependency-free core; impl chosen by config through a factory (`Kind` + frozen `Config` + `*_from_config` / `NewFromConfig`) that returns the interface, defaults to a stub/noop so the graph boots with zero infra, and fails loudly on an unknown kind.
- **DI:** constructor injection, wired at one composition root per deployable (Go: Wire; Python: `deps.py`); no I/O during construction, no globals/singletons, teardown in reverse order. Repository pattern for data; separate persistence models, domain entities, DTOs; early returns.
- **Decorators** carry resilience and observability, applied at the composition root, never inside a backend. Order, outermost first — Controller: tracing → metrics → logging → recovery → rate limit → auth → validation · Service: validation → retry → tracing → metrics → logging · Repository: caching → retry → circuit breaker → timeout → tracing → metrics → logging · Client: bulkhead → retry → circuit breaker → timeout → tracing → metrics → logging. Every external call has a chosen timeout; retry only transient errors, with backoff + jitter; don't double-wrap an SDK that already retries.
- **Errors carry a code;** transient/permanent and transport status derive from it; sanitize at the transport edge.
- **Config:** layered YAML (`base` fail-safe, selects stubs → env overlay → gitignored secrets), env vars override; each layer owns a typed, validated, documented slice; read only in the config layer / composition root.
- **Observability:** structured logs through a logger interface with trace correlation, metrics, traces; health + readiness (flips before drain); graceful shutdown.
- Monorepo layout: `~/.claude/templates/repo.md`.

## Compact instructions

When compacting, keep verbatim: the active plan path and its header (`Type`, `Status`, `Approved`, `Iteration`, `Base`, `Reviewed`, `Full gate`); the current phase and the task in progress; each story's commit SHA; open review findings by tier; user decisions and approvals; the last gate/test result with its exit code; files changed but not yet committed. Drop tool output bodies, file contents already committed, and exploration transcripts — the plan's *Context for Implementer* carries the map. Auto-compaction runs at ~95% of `autoCompactWindow` (500K); the `compact-anchor` hook re-injects the plan header afterwards.

## Anti-Patterns

Files > 800 lines, functions > 50, nesting > 4 (generated files exempt) · hardcoded secrets/URLs/config · config/env read outside the config layer · hand-edited generated code (the `guard-generated.sh` PreToolUse hook blocks Edit/Write on it; edit the source and regenerate) · globals/singletons/service locators · impl selected by `if`/import instead of a `Kind` factory · retry/logging/tracing inlined instead of a decorator · code-less errors · an external call without a timeout · mutable state shared across goroutines/async tasks · untyped `any`/`interface{}` · import cycles · tests of implementation instead of behavior.

@RTK.md
