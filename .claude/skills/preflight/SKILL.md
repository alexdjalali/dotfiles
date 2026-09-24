---
model: opus
description: Run all quality gates before committing -- format, lint, type check, tests
---

Five gates in order. All must pass before committing. Run only the gates — and within each gate only the commands — for languages present in the diff (`git diff --name-only HEAD` plus untracked files).

## Gate 1 -- Format (auto-fix in place)

Only for languages in the diff:

- Python: `ruff format .`
- Go: `gofumpt -w .` then `goimports -w .` (or pass just the changed `.go` files)
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

Changed modules must have passing tests. New tests follow `testing.md` *Test Double Policy* — unit mocks the boundary (reuse the project's fixtures), integration runs the real dependency via testcontainers; never a hand-rolled fake.

## Gate 5 -- Docs & Consistency (manual)

- **Docs sync** (per `documentation-sync.md`): every comment, docstring, README, and architecture doc that references the changed code — **directly or indirectly** — is updated in this change (`codegraph_callers` / `codegraph_impact` find indirect references).
- **Consistency & DRY:** the change follows the established patterns, naming, and error-handling idioms of the files it touches; no helper is reinvented that the repo already provides.

## Rules

- NEVER skip a gate because the change "looks small"
- NEVER commit if Gate 3 or Gate 4 fails -- fix first
- NEVER commit with stale docs -- Gate 5 is not optional
- Gates run in order -- do not parallelize them
- If a test was already failing before your change, fix it or document it; "pre-existing" is not an excuse

## Next Step

All gates green → `/github` to commit and open a PR. Any gate red → fix and re-run `/preflight`; do not commit.
