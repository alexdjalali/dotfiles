# Code-Addition Checklist

Answered by `/rfp` (per story) and `spec-plan` (per plan) before tasks are final. A repo's `.claude/rules/code-addition-checklist.md` supplies the concrete answers (real infra tiers, CLI, test layers, shared-library packages) — follow it when present. A "yes" to 1, 2, or 5 is its own task, not an afterthought.

1. **Infra/deploy?** A dev-environment change and a staging/prod (IaC) change?
2. **CLI/tooling?** A change to the project's CLI or task runner?
3. **Philosophy / gold standard?** Consistent with the project's design philosophy, mirroring an existing reference implementation? A deviation is an ADR, not a silent exception.
4. **Right test types, right double** (`testing.md` *Test Double Policy*)? Unit / integration / e2e, plus property/fuzz and chaos when warranted. An integration test **names its Docker image + testcontainers module** (e.g. `postgres:16` via `testcontainers-go` / `testcontainers[postgres]` / `@testcontainers/postgresql`).
5. **Config?** Ideally selecting an impl by configuration, not a hard-coded import.
6. **As simple as possible?** DRY, YAGNI — no duplicated logic, no speculative knobs.
7. **As general as possible?** Behind an interface, config-selected, injected explicitly — capped by 6.
8. **Reuse shared abstractions?** The shared-library patterns/helpers rather than reinventions.
