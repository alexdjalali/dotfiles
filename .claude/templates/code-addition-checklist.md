# Code-Addition Checklist

Answered by `/rfp` (per story) and `spec-plan` (per plan) before tasks are final; `/review-diff` checks the diff against it. A repo's `.claude/rules/code-addition-checklist.md` supplies the concrete answers (real infra tiers, CLI, test layers, shared-library packages, generators) — follow it when present. A "yes" to 1, 2, 5, 6, or 9 is its own task, not an afterthought.

**The One Idea** (the target shape for 3, 7, 8): everything is an implementation detail behind an interface, selected by configuration, injected explicitly, and wrapped by decorators.

1. **Infra/deploy?** A dev-environment change and a staging/prod (IaC) change?
2. **CLI/tooling?** A change to the project's CLI or task runner?
3. **Philosophy / gold standard?** Consistent with the project's design philosophy, mirroring an existing reference implementation? A deviation is an ADR, not a silent exception.
4. **Right test types, right double** (`testing.md` *Test Double Policy*)? Unit / integration / e2e, plus property/fuzz and chaos when warranted. An integration test **names its Docker image + testcontainers module** (e.g. `postgres:16` via `testcontainers-go` / `testcontainers[postgres]` / `@testcontainers/postgresql`).
5. **Config?** Which impl runs is a `Kind` in layered, typed, validated config (`base` → env overlay → gitignored secrets; env vars override) — never a hard-coded import or an env read in a constructor. Every new field has a fail-safe `base` default and a doc string.
6. **Can it be generated?** A contract (proto, OpenAPI, GraphQL, schema, DI graph, enum, mock) the code is derived from? Then edit the source and run the project's generator through its CLI — never hand-write or hand-edit the output. A third repetition of one shape is a scaffold/template (`text/template` + `//go:embed`, Jinja, a codegen subcommand), not copy-paste.
7. **One-Idea shape?** A core interface; impls chosen by a `Kind` + `Config` + `*_from_config` / `NewFromConfig` factory that returns the interface, defaults to a stub/noop (the graph boots with zero infra), and fails loudly on an unknown kind; constructor injection wired at the composition root. A second backend is a config change, not a logic edit.
8. **Resilient and observable?** Every external call has a chosen timeout; retry (backoff + jitter, transient errors only), circuit breaker, logging, tracing, metrics are **decorators** in the per-layer order, applied at the composition root — never inlined. Errors carry a code (transient/permanent, transport status derive from it). Structured logs with trace correlation; health/readiness; graceful shutdown.
9. **Reuse shared abstractions?** DRY means push logic down into the shared library and inject product strategy up — Strategy / Decorator / Factory / Adapter / Repository over a grab-bag helper. A generic gap is fixed in the shared library, not forked locally.
