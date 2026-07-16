# Go Standards (1.26+)

Grounded in the flagship repo **bloodhound-search-platform** (`~/TechAI/bloodhound-search-platform`, `pkg/go`). Match how we do things there.

## Architecture (the `pkg/go` layered library)

The shared library is a strictly layered stack; dependencies point downward only:

`core → foundation → clients → repos → services → pipelines → workflows → transport`

(plus `execution` and `helpers`). Conventions:
- **Decorator builders at every layer** — cross-cutting concerns (retry, circuit breaker, bulkhead, caching, telemetry, idempotency) are composed as decorators, not baked into business logic.
- **Import boundaries are lint-enforced** via `golangci-lint` `depguard` — a layer may only import lower layers. Do not reach upward or sideways.
- **Wire** for compile-time dependency injection (composition at the entrypoint, not `init()`).
- **Ent** (`contracts/ent`) for the ORM / schema-as-code.
- **Cobra** for the `search` CLI.
- Consumer-defined interfaces live in `core/interfaces`; implementations satisfy them from higher layers.

## Tooling
- Format: `gofumpt` + `goimports`
- Lint: `golangci-lint` (with `depguard` layer boundaries, `lll`, `forbidigo`)
- Test: table-driven with `t.Run()` subtests; `t.Parallel()` where safe

## Code Style
- Errors: always check; wrap with `fmt.Errorf("context: %w", err)`
- Interfaces: small (1-3 methods), consumer-defined; accept interfaces, return structs
- No `fmt.Println` in production; use the structured logger. **Line length: 90** (`golangci-lint` `lll`).
- Naming: MixedCaps (exported), mixedCaps (unexported); acronyms all-caps (HTTPClient, ID)
- Concurrency: prefer channels over shared memory; always `defer` cleanup
- Context: pass `ctx context.Context` as first parameter

## Testing Requirements
- Table-driven tests with `t.Run()` subtests
- `t.Parallel()` where safe (no shared mutable state)
- Test naming: `TestFunctionName_Scenario` (e.g., `TestParseConfig_EmptyInput`)
- Every test has a comment: **Why important** + **What it tests**
- `testify` assertions where appropriate (`assert`, `require`)
- **Test doubles: mocks and fixtures, not fakes.** Mock the external boundary (or use a generated mock); reuse shared fixtures under `pkg/go/tests`. Do not hand-roll an in-memory reimplementation of a dependency when a mock or fixture will serve.
- `rapid` for property-based testing (pure functions, roundtrips, invariants)
- Test file pattern: `<file>_test.go` in same package

## Documentation Requirements
- Package-level doc comment in `doc.go` or first file
- Doc comment on all exported functions, types, and methods
- Inline comments for non-obvious logic only; no comments that restate the code
- A code change updates every doc comment / README / architecture doc that references it, **directly or indirectly** (a caller or documented behavior that depends on it)

## Flagship Patterns

Our engineering standards are catalogued in two posts; the standards above are the day-to-day subset:
- [The Top 50 Techniques for Distributed Engineering](https://alexdjalali.github.io/posts/top-50-techniques-for-distributed-engineering/)
- [100 Patterns for Production Go and Python](https://alexdjalali.github.io/posts/100-patterns-for-production-go-and-python/)

Known gaps in the flagship repo — reach for these when the task touches the relevant hot path (don't add speculatively, YAGNI):
- **#65 Backpressure / load shedding** on the SQS consumers (currently a `Phase 2+` TODO in `core/interfaces/messaging.go`)
- **#70 / #73 Object & buffer pooling (`sync.Pool`)** on the document-parse / embedding hot path
- **#82 Golden-file testing** for codegen (proto/OpenAPI/diagram) and citation-extraction outputs
- **#53 Time-ordered IDs (ULID/KSUID)** where UUIDv4/Ent defaults create index locality problems
- Hot-key mitigation (L1 cache in front of Redis), CDN for blob downloads, read-your-writes on the ingestion→search-index lag

## Quality Gates
1. `gofumpt` — code formatting
2. `goimports` — import organization
3. `golangci-lint run` — comprehensive linting (incl. `depguard` layer boundaries)
4. `go vet ./...` — static analysis
5. `go test ./... -count=1` — all tests pass (no caching)
6. `go test -race ./...` — race condition detection
