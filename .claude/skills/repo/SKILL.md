---
model: opus
description: Scaffold a new monorepo to the standard layout (docs pipeline, zarf/, language dirs), or audit an existing repo's structure against it. Use when starting a repository or checking compliance.
argument-hint: "<name> | audit"
---

The standard is `~/.claude/templates/repo.md` — read it first in both modes: layers Foundation → Client → Service/Domain → Controller/API → Entrypoint; infrastructure in `zarf/`; the spec pipeline in `docs/adr/` + `docs/spec/{roadmap,arch,design,epics,stories,audits,rca,demos}/` (tracked), with `/spec` plans in gitignored `docs/local/plans/`; Go `pkg/` + `apps/`, Python `src/` + `entrypoints/`, TS `packages/` + `apps/`. **Input:** a new repo name, or `audit`. **Output:** the scaffolded tree at `./<name>/`, or a pass/fail compliance report.

## Scaffold (`/repo <name>`)

1. Ask for the tech stack — NEVER scaffold without knowing it.
2. Create the tree:
   ```
   <name>/
   ├── docs/
   │   ├── adr/
   │   ├── spec/{roadmap,arch,design,epics,stories,audits,rca,demos}/
   │   └── local/plans/          # gitignored
   ├── zarf/{docker,k8s,terraform}/
   └── [stack dirs: Go pkg/ + apps/ · Python src/ + entrypoints/ · TS packages/ + apps/]
   ```
3. `git init`; create `CLAUDE.md`, `README.md`, and a `.gitignore` that ignores `docs/local/`.
4. Create the first ADR — `Skill(skill='adr', args='Initial architecture')` → `docs/adr/0001-initial-architecture.md`. NEVER skip `docs/adr/`: the decision record starts on day one.

## Audit (`/repo audit`)

- [ ] `docs/adr/` exists with at least one ADR (`NNNN-<slug>.md`)
- [ ] `docs/spec/` has the pipeline subdirectories in use (`roadmap/`, `arch/`, `design/`, `epics/`, `stories/`, `audits/`, `rca/`, `demos/`)
- [ ] `docs/local/` is gitignored (plans live in `docs/local/plans/`); no plan files tracked anywhere under `docs/spec/`
- [ ] `zarf/` exists for infrastructure code
- [ ] `CLAUDE.md` exists at the root
- [ ] No business logic in the root directory, in `zarf/`, or infrastructure in `src/`/`pkg/`
- [ ] Language-specific directories match the stack conventions

Report which checks pass, which fail, and what to add.

## Rules

- NEVER put business logic in `zarf/` or infrastructure in `src/`/`pkg/`.

## Next Step

- **Scaffolded** → `/roadmap` to sequence the first epics, or `/rfp` to decompose one.
- **Audited** → fix small gaps directly (then run the quality gates (CLAUDE.md *Quality Gates*)); a structural migration is `/adr` + `/spec` (user-typed).
