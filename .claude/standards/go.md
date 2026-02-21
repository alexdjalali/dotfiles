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
