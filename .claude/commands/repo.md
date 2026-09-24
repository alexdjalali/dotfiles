---
model: opus
description: Scaffold a new monorepo or audit an existing one for structural compliance
argument-hint: "<name> | audit"
---

## Monorepo Standard

New repositories follow the standard monorepo template (`~/.claude/templates/repo.md`):
- Layered architecture: Foundation → Client → Service/Domain → Controller/API → Entrypoint
- Infrastructure in `zarf/` (Docker, K8s, Terraform, observability)
- Spec pipeline in `docs/adr/` + `docs/spec/{roadmap,arch,design,epics,stories,audits,rca,demos}` (tracked); `/spec` plans + spec-review JSON live in **gitignored** `docs/local/plans/` (local working docs, never committed)
- Language conventions: Go=`pkg/`+`apps/`, Python=`src/`+`entrypoints/`, TS=`packages/`+`apps/`
- Use `/repo <name>` to scaffold, `/repo audit` to check compliance

## Scaffold (`/repo <name>`)

Create a new monorepo at `./<name>/` following the standard structure in `~/.claude/templates/repo.md`.

### Steps

1. Read `~/.claude/templates/repo.md` for the canonical layout.
2. Ask the user for their tech stack before creating anything.
3. Create the directory tree:
   ```
   <name>/
   ├── docs/
   │   ├── adr/
   │   ├── spec/{roadmap,arch,design,epics,stories,audits,rca,demos}/
   │   └── local/plans/          # gitignored
   ├── zarf/{docker,k8s,terraform}/
   └── [stack-specific source dirs]
   ```
   - Go: `pkg/` + `apps/`
   - Python: `src/` + `entrypoints/`
   - TypeScript: `packages/` + `apps/`
4. Initialize git, create `CLAUDE.md`, `.gitignore` (must ignore `docs/local/`), and `README.md`.
5. Create the first ADR: `docs/adr/0001-initial-architecture.md`.

## Audit (`/repo audit`)

Check an existing repo for compliance with the monorepo standard.

### Checks

- [ ] `docs/adr/` exists with at least one ADR (`NNNN-<slug>.md`)
- [ ] `docs/spec/` has the pipeline subdirectories in use (`roadmap/`, `arch/`, `design/`, `epics/`, `stories/`, `audits/`, `rca/`, `demos/`)
- [ ] `docs/local/` is gitignored (plans live in `docs/local/plans/`, never committed); no plan files tracked anywhere under `docs/spec/`
- [ ] `zarf/` exists for infrastructure code
- [ ] `CLAUDE.md` exists at the root
- [ ] No business logic in the root directory
- [ ] Language-specific directories match stack conventions

Report which checks pass, which fail, and what to add.

## Rules

- NEVER scaffold without knowing the user's stack -- ask first
- NEVER put business logic in `zarf/` or infrastructure in `src/`/`pkg/`
- NEVER skip `docs/adr/` -- the decision record starts on day one
