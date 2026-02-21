# Monorepo Scaffold Template

## Directory Structure

```
<project>/
├── .ci/                          # CI/CD pipelines
│   ├── github/                   # GitHub Actions workflows
│   │   └── workflows/
│   │       ├── ci.yml            # Lint, typecheck, unit tests
│   │       ├── extended.yml      # Integration, fuzz, e2e (schedule/manual)
│   │       └── deploy.yml        # Deployment pipeline
│   ├── scripts/                  # CI helper scripts
│   └── templates/                # Pipeline templates
│
├── .claude/                      # Claude Code configuration
│   ├── rules/                    # Project-specific rules
│   │   └── project.md            # Project context and standards
│   └── settings.local.json       # Local Claude settings (gitignored)
│
├── configs/                      # Centralized configuration
│   ├── <language>/               # Language tool configs (linter, formatter)
│   ├── environments/             # Per-environment app config (dev, staging, prod)
│   ├── .security/                # Security scanner configs
│   └── .env.example              # Environment variables template
│
├── contracts/                    # API & schema definitions
│   ├── proto/                    # Protocol Buffer schemas
│   ├── openapi/                  # OpenAPI specifications
│   └── graphql/                  # GraphQL schemas
│
├── docs/                         # Documentation
│   ├── adr/                      # Architecture Decision Records
│   └── spec/                     # Spec pipeline artifacts
│       ├── arch/                 # Architecture diagrams
│       ├── epics/                # Epic specifications
│       ├── stories/              # Implementation stories
│       └── plans/                # Implementation plans
│
├── frontends/                    # Frontend applications
│   └── <app>/                    # Each frontend app
│       ├── src/
│       ├── __tests__/
│       ├── package.json
│       └── tsconfig.json
│
├── zarf/                         # Infrastructure as Code
│   ├── docker/                   # Per-service Dockerfiles
│   │   └── base/                 # Base image(s)
│   ├── k8s/                      # Kubernetes
│   │   ├── chart/                # Shared Helm chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml       # Base defaults
│   │   │   ├── templates/        # K8s manifests
│   │   │   ├── policies/         # OPA/Rego policies
│   │   │   └── tests/            # helm-unittest
│   │   ├── dev/                  # Dev environment values
│   │   ├── stage/                # Staging values
│   │   └── prod/                 # Production values
│   ├── terraform/                # Terraform/Terragrunt modules
│   │   ├── modules/              # Reusable modules
│   │   └── live/                 # Per-environment configs
│   ├── config/                   # Observability configs
│   │   ├── grafana/
│   │   ├── prometheus/
│   │   ├── loki/
│   │   └── tempo/
│   ├── docker-compose.yaml       # Profile-based local stack
│   └── docker-compose.override.yaml
│
├── <lib>/                        # Shared libraries (pkg/ for Go, src/ for Python)
│   ├── foundation/               # Cross-cutting concerns
│   │   ├── builder/              # DI builder pattern
│   │   ├── cache/                # Caching layer
│   │   ├── config/               # Configuration management
│   │   ├── decorators/           # AOP decorators (retry, circuit breaker, logging)
│   │   ├── errors/               # Error hierarchy
│   │   ├── events/               # Event bus
│   │   ├── lifecycle/            # Service lifecycle management
│   │   ├── logger/               # Structured logging
│   │   ├── metrics/              # Prometheus metrics
│   │   ├── middleware/           # HTTP middleware stack
│   │   ├── resilience/           # Retry, circuit breaker, DLQ
│   │   ├── telemetry/            # OpenTelemetry tracing
│   │   └── types/                # Domain type aliases
│   ├── interfaces/               # Core ABCs / interfaces
│   ├── clients/                  # External service clients
│   │   ├── sdk/                  # Client base classes + decorators
│   │   └── domain/               # Concrete client implementations
│   ├── service/                  # Business logic layer
│   │   ├── sdk/                  # Service base classes
│   │   └── domain/               # Domain services
│   ├── repository/               # Data access layer
│   │   ├── sdk/                  # Repository base classes
│   │   └── <store>/              # Per-database implementations
│   ├── controller/               # HTTP handler framework
│   │   ├── sdk/                  # Handler base classes
│   │   └── domain/               # Entity controllers
│   ├── pipeline/                 # Data processing pipelines (optional)
│   └── workflow/                 # Workflow orchestration (optional)
│
├── <apps>/                       # Deployable services (apps/ for Go, entrypoints/ for Python)
│   ├── server/                   # HTTP/gRPC servers
│   │   └── <service>/            # Per-service entry point
│   ├── worker/                   # Async workers
│   ├── stream/                   # Stream consumers (Kafka, etc.)
│   ├── scheduler/                # Periodic jobs
│   ├── cli/                      # CLI tool
│   └── ml/                       # ML services (optional)
│
├── tests/                        # Testing infrastructure
│   ├── unit/                     # Fast, isolated unit tests
│   ├── integration/              # Single-service with real deps
│   ├── contract/                 # Cross-service schema validation
│   ├── e2e/                      # Full-stack end-to-end
│   ├── fuzz/                     # Property-based / fuzzing
│   ├── chaos/                    # Resilience under failure
│   ├── performance/              # Benchmarks
│   ├── fixtures/                 # Static test data
│   └── shared/                   # Shared test utilities (mocks, fakes)
│
├── scripts/                      # Helper scripts
│   ├── setup/                    # bootstrap.sh, install-hooks.sh
│   ├── deploy/                   # deploy.sh, cleanup.sh
│   └── tooling/                  # version.sh, vendor scripts
│
├── migrations/                   # Database migrations (optional)
│
├── Makefile                      # Root build orchestrator
├── .makefiles/                   # Modular Makefile system (optional)
│   ├── foundation/               # variables.mk, help.mk
│   ├── development/              # build.mk, test.mk, lint.mk, fmt.mk
│   └── devx/                     # pre-commit.mk, git.mk, security.mk
│
├── README.md                     # Project overview
├── CLAUDE.md                     # Claude Code context
├── .gitignore                    # Git ignores
├── .gitattributes                # Line endings, merge strategies
├── .editorconfig                 # Editor configuration
├── .pre-commit-config.yaml       # Pre-commit hooks
├── renovate.json                 # Dependency update bot
│
├── # Language-specific root files:
├── # Go: go.mod, go.work, go.work.sum
├── # Python: pyproject.toml, uv.lock, ruff.toml
├── # TypeScript: package.json, pnpm-workspace.yaml, tsconfig.json
└── # Multi-language: combination of above
```

## Naming Conventions

| Concept | Go Convention | Python Convention |
|---------|--------------|-------------------|
| Shared libraries | `pkg/` | `src/` |
| Deployable services | `apps/` | `entrypoints/` |
| Infrastructure | `zarf/` | `zarf/` |
| Sub-packages | `pkg/go/`, `pkg/python/` | flat under `src/` |

## Architecture Layers

```
Foundation → Client → Service/Domain → Controller/API → Entrypoint
```

- **Foundation**: Cross-cutting (logging, metrics, errors, resilience, config)
- **Client**: External service SDKs with decorator chains
- **Service**: Business logic, domain rules, validation
- **Controller**: HTTP handlers, request/response mapping
- **Entrypoint**: Transport wiring, DI container creation (thin)

Import rules:
- Entrypoints → Lib allowed
- Lib → Entrypoints FORBIDDEN
- Foundation → nothing (only stdlib + external deps)
- Each layer imports only from the layer below

## Infrastructure Profiles (docker-compose)

| Profile | Contains |
|---------|----------|
| (base) | Databases, caches, message brokers |
| services | Application services |
| monitoring | Prometheus, Grafana, Loki, Tempo |
| management | DB admin UIs (Mongo Express, pgAdmin, Redis Commander) |
