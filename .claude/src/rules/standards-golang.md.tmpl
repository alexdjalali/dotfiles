---
paths:
  - "**/*.go"
---

## Go Development Standards

**Standards:** Go modules | go test | gofumpt + goimports + go vet + golangci-lint | Self-documenting code

### Module Management

```bash
go mod init module-name    # Initialize
go mod tidy                # Add/remove deps
go get -u ./...            # Update deps
```

### Testing & Quality

**Use minimal output flags to avoid context bloat.**

```bash
go test ./...                             # All tests
go test ./... -race                       # With race detector
go test -coverprofile=coverage.out ./...  # Coverage report

gofumpt -w .                              # Format (stricter superset of gofmt)
goimports -w .                            # Organize imports
go vet ./...                              # Static analysis
golangci-lint run                         # Comprehensive linting (golangci-lint v2)
```

**Table-driven tests** preferred for multiple cases. Use `t.Run()` for subtests; `t.Parallel()` where there's no shared mutable state.

- **Test doubles (two tiers — see `testing.md` *Test Double Policy*):** **unit** mocks the external boundary — a generated mock (`mockgen` → `go.uber.org/mock/gomock`) or a mock of a small consumer-side interface (accept interfaces); **integration** runs the real dependency in a Docker container via `testcontainers-go`, driven by fixtures. Hand-rolled fakes / in-memory reimplementations are a `must_fix`.
- **Property-based:** `rapid` for pure functions, roundtrips, and invariants. `testify` (`assert`/`require`) where it aids clarity.

### Integration tests (testcontainers)

Integration tests exercise a single unit against its **real** collaborator (Postgres, Redis, SQS/Kafka, S3/MinIO) — never a mock, never an in-memory substitute. Stand the dependency up in a throwaway container with `testcontainers-go`, drive it through reusable fixtures/builders, and clean up in teardown so each test passes alone. Gate with the `integration` build tag (or a `testing.Short()` skip) in an external `_test` package, so `go test ./...` stays fast and `go test -tags=integration ./...` runs them.

```go
//go:build integration

package integration_test

import (
	"context"
	"testing"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
)

// TestStore_CRUD tests the store against real Postgres.
//
// Why this test is important:
//   - real SQL, FK persistence, and transaction semantics are invisible to sqlmock.
// What it tests:
//   - Create → Get → List → Delete round-trips against a live database.
func TestStore_CRUD(t *testing.T) {
	testcontainers.SkipIfProviderIsNotHealthy(t) // skip when Docker is unavailable
	ctx := context.Background()

	pg, err := postgres.Run(ctx, "postgres:16-alpine",
		postgres.WithDatabase("app"), postgres.WithUsername("test"), postgres.WithPassword("test"))
	testcontainers.CleanupContainer(t, pg) // nil-safe; terminates on test end; call before the error check
	if err != nil {
		t.Fatal(err)
	}
	dsn, err := pg.ConnectionString(ctx, "sslmode=disable")
	// … open the DB with dsn, apply migrations via a fixture, assert observable behavior.
}
```

Prefer a module package (`modules/postgres`, `modules/redis`, …) over a raw `GenericContainer` where one exists — it encodes the wait strategy and connection helpers.

### Code Style

- **Packages:** lowercase, single word (`http`, `json`, `user`)
- **Exported:** PascalCase (`ProcessOrder`, `UserService`) · **Unexported:** camelCase · **Acronyms:** ALL CAPS (`HTTPServer`, `userID`)
- **Interfaces:** small (1–3 methods), often `-er`; accept interfaces, return structs. Contracts other packages swap live in the core interfaces package; a consumer-side interface embeds the core one rather than redeclaring it.
- **Guard clauses** over nesting; named struct fields; `ctx context.Context` first; `defer` cleanup.
- Line length, `funlen`, `gocyclo`: the project's golangci-lint config.

### Documentation

- Exactly one package doc per package (`doc.go`), starting `// Package x …`.
- Every symbol documented — exported **and** unexported types, functions, methods, constants, **struct fields and enum values** — the comment starts with the name (`// ProcessOrder handles…`). A blank line separates documented members. Trivially obvious fields are exempt.
- When you edit a documented symbol, revise its comment — never delete it. Tracker IDs and link rules: `documentation-sync.md`.

### Error Handling

- Always handle errors — never `result, _ := doSomething()`.
- **Errors carry a code.** Wrap with the project's coded-error package (`Wrap(err, code, msg)`); transient/permanent and the HTTP/gRPC status derive from the code, and the transport edge sanitizes the message. Code-less `fmt.Errorf` / `errors.New` in production code is a lint failure where the project bans it (`forbidigo` / `depguard`). A project without a coded-error package gets one in its core layer (ADR) — don't fall back to bare strings.
- Compare with `errors.Is` / `errors.As`, never string matching.

### Factories — `Kind` + `Config` + `NewFromConfig`

Each swappable component: a core interface, one package per backend, and a factory that returns the interface.

```go
// Kind names a Store backend.
type Kind string

const (
	// KindStub is the zero-I/O default, so the graph boots with no infrastructure.
	KindStub Kind = "stub"

	// KindPostgres stores rows in PostgreSQL.
	KindPostgres Kind = "postgres"
)

// Config selects and configures a Store backend; it holds every kind's settings.
type Config struct {
	// Kind picks the backend; empty means KindStub.
	Kind Kind `mapstructure:"kind"`

	// Postgres configures KindPostgres.
	Postgres postgres.Config `mapstructure:"postgres"`
}

// NewFromConfig returns the Store backend cfg.Kind names.
// (errors and codes here are the project's coded-error package, not the stdlib.)
func NewFromConfig(cfg Config) (interfaces.Store, error) {
	switch cfg.Kind {
	case "", KindStub:
		return stub.New(), nil
	case KindPostgres:
		return postgres.New(cfg.Postgres)
	default:
		return nil, errors.New(codes.InvalidConfig, fmt.Sprintf("store: unknown kind %q", cfg.Kind))
	}
}
```

- Every backend asserts its contract at compile time: `var _ interfaces.Store = (*Store)(nil)`.
- No I/O in constructors — connect lazily or in an explicit `Start`.

### Dependency Injection — Wire

- One composition root per deployable. Provider sets live in `wire.go` (`//go:build wireinject`); `wire` generates `wire_gen.go`, which is committed and never hand-edited. `main` calls the generated initializer and defers its cleanup (teardown runs in reverse order).
- Constructors take their dependencies as parameters. No package-level mutable state, `init()` side effects, singletons, or service locators.

```go
//go:build wireinject

package app

// InitializeApp builds the App graph from cfg.
func InitializeApp(ctx context.Context, cfg config.Config) (*App, func(), error) {
	wire.Build(storeSet, serviceSet, NewApp)
	return nil, nil, nil
}
```

### Decorators — resilience and observability

Timeout, retry (backoff + jitter, transient codes only), circuit breaker, tracing, metrics, logging, and recovery wrap the interface at the composition root, in the per-layer order (`CLAUDE.md` *Architecture*), recovery outermost — e.g. a fluent builder `decorators.NewBuilder(base, "users").WithTimeout(d).WithTracing(t).WithLogging(l).Build()`. Never inline them in a backend; never stack a retry over an SDK client that already retries.

### Configuration

- Each layer owns a typed config struct with `mapstructure` tags, loaded from layered YAML (`base` → env overlay → gitignored secrets; env vars override — e.g. Viper `UnmarshalKey`) and checked by a `Validate() error` before startup.
- `os.Getenv` only in the config layer or `main`. Every field has a doc comment and a fail-safe `base` value.

### Observability

- `log/slog` through an injected logger: `*Context` methods so trace IDs correlate, snake_case keys (`sloglint`), no `fmt.Println`.
- OpenTelemetry spans on every boundary, ended on every path (`spancheck`); Prometheus metrics via the metrics decorator.
- Health and readiness endpoints; readiness flips before the drain; graceful shutdown on `SIGTERM` with a deadline.

### Code Generation — generate first

- **Off-the-shelf generators first**, run through the project CLI / `//go:generate`: `buf` (protobuf, gRPC, Connect, OpenAPI), `oapi-codegen`, `ent`, `gqlgen`, `wire`, `mockgen`, `go-enum`. Pin generator versions with the go.mod `tool` directive and run them via `go tool <name>`.
- **No off-the-shelf generator?** Write one with the standard library: `text/template` + `//go:embed` for the template, `go/format.Source` on the output, a `// Code generated by <tool>; DO NOT EDIT.` header (the line Go tooling and linters recognize), wired to `//go:generate go run ./internal/gen/<name>`.
- Generated files are committed and excluded from lint and size limits. Drift check in CI: `go generate ./... && git diff --exit-code`.
- Never hand-edit generated output — change the proto, schema, template, or `wire.go` and regenerate.

```go
//go:embed kinds.go.tmpl
var kindsTmpl string

func render(out string, data any) error {
	var buf bytes.Buffer
	if err := template.Must(template.New("kinds").Parse(kindsTmpl)).Execute(&buf, data); err != nil {
		return err
	}
	src, err := format.Source(buf.Bytes())
	if err != nil {
		return err
	}
	return os.WriteFile(out, src, 0o644)
}
```

### Project Structure

Follow the project's documented layout; the monorepo default is `~/.claude/templates/repo.md` (Go `pkg/` + `apps/`). Inside a layer: `core/interfaces` for contracts, one package per backend, the factory beside the `Config`, decorators in their own package, the composition root (`wire.go`) per deployable under `cmd/` or `apps/`.

### Verification Checklist

- [ ] `gofumpt -w .` + `goimports -w .` — formatted, imports organized
- [ ] `go test ./...` — unit tests pass (boundaries mocked)
- [ ] `go test -tags=integration ./...` — integration tests pass (real deps via testcontainers, no fakes)
- [ ] `go vet ./...` — clean
- [ ] `golangci-lint run` — clean (v2 config format)
- [ ] `go mod tidy` — deps tidy
- [ ] `go generate ./... && git diff --exit-code` — generated code in sync
- [ ] No ignored errors; every error coded
- [ ] Production files ideally under 800 lines (generated files exempt)
