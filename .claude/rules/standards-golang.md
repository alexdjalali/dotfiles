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

Integration tests exercise a single unit against its **real** collaborator (Postgres, Redis, SQS/Kafka, S3/MinIO) — never a mock, never an in-memory substitute. Stand the dependency up in a throwaway container with `testcontainers-go`, drive it through reusable fixtures/builders, and clean up in teardown so each test passes alone. Gate with the `integration` build tag in an external `_test` package, so `go test ./...` stays fast and `go test -tags=integration ./...` runs them.

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
- **Exported:** PascalCase (`ProcessOrder`, `UserService`)
- **Unexported:** camelCase (`processOrder`, `userService`)
- **Acronyms:** ALL CAPS (`HTTPServer`, `XMLParser`, `userID`)
- **Interfaces:** Often -er suffix (`Reader`, `Writer`, `Handler`); small (1-3 methods), consumer-defined — accept interfaces, return structs
- **Comments:** Exported functions start with function name: `// ProcessOrder handles...`

### Error Handling

- Always handle errors explicitly — never `result, _ := doSomething()`
- Wrap with context: `fmt.Errorf("processing user %s: %w", userID, err)`
- Use sentinel errors: `var ErrNotFound = errors.New("not found")`

### Common Patterns

- **Context:** Always first parameter: `func ProcessRequest(ctx context.Context, ...)`
- **Defer:** For cleanup: `defer f.Close()`
- **Struct init:** Named fields: `User{ID: "123", Name: "Alice"}`

### Project Structure

```
cmd/         # Main applications
internal/    # Private packages
pkg/         # Public packages
```

### Verification Checklist

- [ ] `gofumpt -w .` + `goimports -w .` — formatted, imports organized
- [ ] `go test ./...` — unit tests pass (boundaries mocked)
- [ ] `go test -tags=integration ./...` — integration tests pass (real deps via testcontainers, no fakes)
- [ ] `go vet ./...` — clean
- [ ] `golangci-lint run` — clean (v2 config format)
- [ ] `go mod tidy` — deps tidy
- [ ] No ignored errors
- [ ] Production files ideally under 800 lines (1000+ = consider splitting)
