# Go Standards (1.26+)

## Tooling

- Format: `gofumpt` + `goimports`
- Lint: `golangci-lint`
- Test: table-driven with `t.Run()` subtests; `t.Parallel()` where safe

## Code Style

- Errors: always check; wrap with `fmt.Errorf("context: %w", err)`
- Interfaces: small (1-3 methods), consumer-defined; accept interfaces, return structs
- No `fmt.Println` in production; use structured logger. Line length: 140.
- Naming: MixedCaps (exported), mixedCaps (unexported); acronyms all-caps (HTTPClient, ID)
- Concurrency: prefer channels over shared memory; always `defer` cleanup
- Context: pass `ctx context.Context` as first parameter

## Testing Requirements

- Table-driven tests with `t.Run()` subtests
- `t.Parallel()` where safe (no shared mutable state)
- Test naming: `TestFunctionName_Scenario` (e.g., `TestParseConfig_EmptyInput`)
- Every test has a comment: **Why important** + **What it tests**
- `testify` assertions where appropriate (`assert`, `require`)
- Test file pattern: `<file>_test.go` in same package
- `rapid` for property-based testing (pure functions, roundtrips, invariants)

## Documentation Requirements

- Package-level doc comment in `doc.go` or first file
- Doc comment on all exported functions, types, and methods
- Inline comments for non-obvious logic only
- No comments that restate the code

## Quality Gates

1. `gofumpt` — code formatting
2. `goimports` — import organization
3. `golangci-lint run` — comprehensive linting
4. `go vet ./...` — static analysis
5. `go test ./... -count=1` — all tests pass (no caching)
6. `go test -race ./...` — race condition detection
