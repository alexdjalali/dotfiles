---
model: opus
---

# Repo — Scaffold a New Monorepo

Create a new project with the standard monorepo structure, configured for the chosen language stack and infrastructure needs.

## Arguments
$ARGUMENTS — One of:
- `<project-name>` — Scaffold a new monorepo (interactive setup)
- `<project-name> --stack <go|python|typescript|go+python>` — Skip language prompt
- `audit` — Audit an existing repo against the standard structure

## Instructions

### 0. Determine Mode

```
IF $ARGUMENTS == "audit":
    → Mode: AUDIT (compare existing repo against standard)

ELSE:
    → Mode: SCAFFOLD (create new repo)
    Parse: project name, optional --stack flag
```

---

## Mode: SCAFFOLD — Create New Monorepo

### Step 1: Gather Requirements

Read the repo template: `Read(file_path="~/.claude/templates/repo.md")`

If `--stack` was not provided, ask:

Use AskUserQuestion:

```
question: "What's the primary language stack?"
header: "Stack"
options:
  - "Python" - Python 3.13+ with uv, ruff, basedpyright. Lib=src/, Apps=entrypoints/
  - "Go" - Go 1.24+ with gofumpt, golangci-lint. Lib=pkg/, Apps=apps/
  - "Go + Python" - Multi-language monorepo. Lib=pkg/{go,python}/, Apps=apps/{go,python}/
  - "TypeScript" - TypeScript 5+ with pnpm, ESLint, Vitest. Lib=packages/, Apps=apps/
```

Then ask about infrastructure:

```
question: "What infrastructure do you need?"
header: "Infra"
options:
  - "Full stack" - Docker Compose, Helm/K8s, Terraform, observability (Recommended)
  - "Containers only" - Docker Compose + Dockerfiles, no K8s or Terraform
  - "Minimal" - No infrastructure, just the application structure
multiSelect: false
```

### Step 2: Initialize Git Repository

```bash
mkdir -p <project-name>
cd <project-name>
git init
```

### Step 3: Create Directory Structure

Based on the template and chosen stack, create all directories.

**Always created (all stacks):**

```bash
# Documentation (unified spec pipeline)
mkdir -p docs/adr docs/spec/{arch,epics,stories,plans}

# Infrastructure
mkdir -p zarf/docker/base zarf/k8s/{chart/templates,chart/policies,chart/tests,dev,stage,prod}
mkdir -p zarf/config/{grafana,prometheus,loki,tempo}
mkdir -p zarf/terraform/{modules,live}

# CI/CD
mkdir -p .ci/github/workflows .ci/scripts .ci/templates

# Contracts
mkdir -p contracts/{proto,openapi,graphql}

# Configuration
mkdir -p configs/environments configs/.security

# Tests
mkdir -p tests/{unit,integration,contract,e2e,fuzz,chaos,performance,fixtures,shared}

# Scripts
mkdir -p scripts/{setup,deploy,tooling}

# Frontends (placeholder)
mkdir -p frontends

# Claude Code
mkdir -p .claude/rules

# Makefile system
mkdir -p .makefiles/{foundation,development,devx}
```

**Python stack:**
```bash
mkdir -p src/{foundation/{builder,cache,config,decorators,errors,events,lifecycle,logger,metrics,middleware,resilience,telemetry,types},interfaces,clients/{sdk,domain},service/{sdk,domain},repository/{sdk},controller/{sdk,domain},pipeline/{sdk,domain},workflow/{sdk,domain}}
mkdir -p entrypoints/{server,worker,stream,scheduler,cli,ml}
mkdir -p migrations/versions
```

**Go stack:**
```bash
mkdir -p pkg/go/{foundation/{builder,cache,config,errors,events,lifecycle,logger,metrics,middleware,resilience,telemetry,types},core/interfaces,clients,platform/{client,controller,repository,service,workflow},repos/{adapters,caches,databases,message-brokers},services}
mkdir -p apps/go/{server,worker,job}
mkdir -p cli/cmd
```

**Go + Python stack:** both of the above, with `pkg/python/` mirroring `src/` layout.

**TypeScript stack:**
```bash
mkdir -p packages/{core,utils,ui}
mkdir -p apps/{web,api,worker}
```

### Step 4: Create Root Configuration Files

Generate language-appropriate config files:

**All stacks:**
- `.gitignore` — comprehensive, language-aware
- `.gitattributes` — line endings, merge strategies
- `.editorconfig` — indent style/size, charset, newlines
- `.pre-commit-config.yaml` — language-specific hooks
- `renovate.json` — dependency update bot config
- `Makefile` — root orchestrator (includes `.makefiles/`)

**Python:**
- `pyproject.toml` — project metadata, deps, tool configs (pytest, mypy, ruff, coverage)
- `ruff.toml` — strict linting rules
- `.python-version` — pinned Python version

**Go:**
- `go.mod` — root module
- `go.work` — workspace file listing all modules
- `configs/go/.golangci.yml` — linter config

**TypeScript:**
- `package.json` — workspace root
- `pnpm-workspace.yaml` — workspace packages
- `tsconfig.json` — base TypeScript config

### Step 5: Create CLAUDE.md

Generate a project-level `CLAUDE.md` with:
- Project name and description
- Architecture overview (layered, referencing the template)
- Import rules (lib → entrypoints direction)
- Key directories and their purpose
- Spec pipeline location (`docs/adr/`, `docs/spec/`)
- Link to `~/.claude/CLAUDE.md` for global standards

### Step 6: Create README.md

Generate a `README.md` with:
- Project title and description
- Quick start instructions
- Directory structure overview
- Development setup (prerequisites, bootstrap)
- Available make targets
- Contributing guidelines (link to docs/)

### Step 7: Create CI Workflows

Generate `.ci/github/workflows/ci.yml`:
- Lint, format, type-check jobs (language-specific tools)
- Unit test job with coverage
- Triggered on push to main and PRs

### Step 8: Create Docker Compose (if infrastructure selected)

Generate `zarf/docker-compose.yaml` with profile-based architecture:
- Base profile: common databases/caches based on user's needs
- `services` profile: application services
- `monitoring` profile: Prometheus, Grafana, Loki, Tempo
- `management` profile: admin UIs

### Step 9: Create Makefile System

Generate modular Makefiles:
- `Makefile` — root includes `.makefiles/**/*.mk`
- `.makefiles/foundation/variables.mk` — project name, language, paths
- `.makefiles/foundation/help.mk` — auto-generated help
- `.makefiles/development/build.mk` — build targets
- `.makefiles/development/test.mk` — test targets
- `.makefiles/development/lint.mk` — lint targets
- `.makefiles/development/fmt.mk` — format targets
- `.makefiles/devx/pre-commit.mk` — hook management

### Step 10: Create .env.example

Generate an `.env.example` with documented placeholders for:
- Database connections
- Auth secrets
- Observability endpoints
- Service-specific config

### Step 11: Create Bootstrap Script

Generate `scripts/setup/bootstrap.sh`:
- Check prerequisites (language runtime, docker, make)
- Install dependencies
- Install pre-commit hooks
- Copy `.env.example` → `.env`
- Print success message with next steps

### Step 12: Initial Commit

```bash
git add -A
git commit -m "feat: scaffold <project-name> monorepo

Stack: <language>
Infrastructure: <level>
Structure follows standard monorepo template with:
- Layered architecture (foundation → client → service → controller)
- Unified spec pipeline (docs/spec/)
- Profile-based Docker Compose (zarf/)
- Modular Makefile system
- CI/CD with quality gates
"
```

### Step 13: Pipeline — Next Steps

Use AskUserQuestion:

```
question: "Repository created. What's next?"
header: "Pipeline"
options:
  - "/adr — Record initial architecture decisions" - Document the tech stack choices and architecture rationale
  - "/arch — Diagram the system" - Create architecture diagrams in docs/spec/arch/
  - "/github branch — Start a feature branch" - Begin building the first feature
  - "Done — Explore on your own" - Review the scaffolded structure first
```

Based on the user's choice, invoke the corresponding skill.

---

## Mode: AUDIT — Compare Against Standard

### Step 1: Read Template

Read the repo template: `Read(file_path="~/.claude/templates/repo.md")`

### Step 2: Scan Current Repository

Explore the current working directory:
- List all top-level directories
- Check for language-specific config files
- Check for infrastructure directories
- Check for docs/ structure

### Step 3: Compare Against Standard

For each standard directory/file, report:
- **Present**: directory/file exists and follows convention
- **Missing**: directory/file doesn't exist
- **Non-standard**: exists but uses different naming/structure

### Step 4: Generate Audit Report

```markdown
## Repository Audit Report

### Structure Compliance

| Standard | Status | Current | Notes |
|----------|--------|---------|-------|
| Shared library | ? | | |
| Deployable services | ? | | |
| Infrastructure (zarf/) | ? | | |
| Tests | ? | | |
| Documentation | ? | | |
| CI/CD | ? | | |
| Configs | ? | | |
| Contracts | ? | | |
| Scripts | ? | | |

### Documentation Pipeline

| Artifact | Status | Path |
|----------|--------|------|
| ADRs | ? | docs/adr/ |
| Architecture diagrams | ? | docs/spec/arch/ |
| Epics | ? | docs/spec/epics/ |
| Stories | ? | docs/spec/stories/ |
| Plans | ? | docs/spec/plans/ |

### Configuration

| Config | Status |
|--------|--------|
| .gitignore | ? |
| .editorconfig | ? |
| .pre-commit-config.yaml | ? |
| CLAUDE.md | ? |
| Makefile | ? |
| CI workflows | ? |

### Recommendations

1. ...
```

### Step 5: Offer Fixes

For any **Missing** or **Non-standard** items, offer to:
- Create missing directories
- Add missing config files
- Restructure non-standard paths

---

## Rules
- NEVER create files with placeholder content like "TODO" — either generate real content or leave the file empty
- NEVER include secrets or real credentials in generated files — use `.env.example` with placeholder values
- ALWAYS use the standard naming conventions from the template (zarf/, not infra/)
- ALWAYS include the spec pipeline directories (docs/adr/, docs/spec/{arch,epics,stories,plans})
- ALWAYS create CLAUDE.md as the AI tooling entry point
- ALWAYS set up pre-commit hooks for the chosen language
- Git hooks enforce: format, lint, type-check before commit
