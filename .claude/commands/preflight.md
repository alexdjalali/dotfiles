---
description: Run all quality gates before committing -- format, lint, type check, tests
---

Four gates in order. All must pass before committing. Run only gates relevant to languages in the diff.

## Gate 1 -- Format (auto-fix in place)

- Python: `ruff format .`
- Go: `gofumpt -w ./...`
- TypeScript/JS: `prettier --write .`

## Gate 2 -- Lint (auto-fix where possible)

- Python: `ruff check --fix .`
- Go: `golangci-lint run ./...`
- TypeScript: `eslint --fix .`

Report remaining errors after auto-fix. Stop if unfixable errors remain.

## Gate 3 -- Type Check (no auto-fix)

Fix manually or do not commit:
- Python: `basedpyright`
- Go: `go vet ./...`
- TypeScript: `tsc --noEmit`

## Gate 4 -- Tests

- Python: `uv run pytest -q`
- Go: `go test ./...`
- TypeScript: `vitest run` or `pnpm test`

Changed modules must have passing tests.

## Rules

- NEVER skip a gate because the change "looks small"
- NEVER commit if Gate 3 or Gate 4 fails -- fix first
- Gates run in order -- do not parallelize them
- If a test was already failing before your change, fix it or document it; "pre-existing" is not an excuse
