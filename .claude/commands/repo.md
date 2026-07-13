---
description: Scaffold a new monorepo or audit an existing one for structural compliance
---

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
   │   └── spec/{arch,epics,stories,plans}/
   ├── zarf/{docker,k8s,terraform}/
   └── [stack-specific source dirs]
   ```
   - Go: `pkg/` + `apps/`
   - Python: `src/` + `entrypoints/`
   - TypeScript: `packages/` + `apps/`
4. Initialize git, create `CLAUDE.md`, `.gitignore`, and `README.md`.
5. Create the first ADR: `docs/adr/001-initial-architecture.md`.

## Audit (`/repo audit`)

Check an existing repo for compliance with the monorepo standard.

### Checks

- [ ] `docs/adr/` exists with at least one ADR
- [ ] `docs/spec/` has `arch/`, `epics/`, `stories/`, `plans/` subdirectories
- [ ] `zarf/` exists for infrastructure code
- [ ] `CLAUDE.md` exists at the root
- [ ] No business logic in the root directory
- [ ] Language-specific directories match stack conventions

Report which checks pass, which fail, and what to add.

## Rules

- NEVER scaffold without knowing the user's stack -- ask first
- NEVER put business logic in `zarf/` or infrastructure in `src/`/`pkg/`
- NEVER skip `docs/adr/` -- the decision record starts on day one
