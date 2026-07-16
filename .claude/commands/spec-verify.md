---
description: Verify a completed plan -- code review, automated gates, execution check, loop back if issues found
---

Read the plan from `docs/plans/`. Status must be `COMPLETE`.

## Phase 1 -- Code Review

Launch two agents in parallel:
1. **Process agent**: "Did the implementation follow the plan exactly? Are all tasks marked complete? Are there undocumented deviations?"
2. **Quality agent**: "Review the diff for correctness bugs, missing error handling, and untested paths; DRY/SOLID violations and reinvented helpers; consistency with the established patterns/naming of the touched files; tests that hand-roll fakes where a mock or existing fixture would serve; and any inline comment, docstring, README, or architecture doc that references the changed code — directly or indirectly — and was not updated."

Categorize findings: `must_fix`, `should_fix`, `suggestion`.

## Phase 2 -- Automated Gates

Run in order (stop on failure, fix, re-run):
1. Tests: `pytest -q` / `go test ./...` / `vitest run`
2. Type check: `basedpyright` / `go vet ./...` / `tsc --noEmit`
3. Lint: `ruff check .` / `golangci-lint run ./...` / `eslint .`
4. File length: flag files over 800 lines

## Phase 3 -- Execution Verification

Run the actual program and verify the feature works end-to-end:
- CLI: run the command with realistic inputs
- API endpoint: call it and inspect the response
- UI change: use browser automation to interact with the changed page

Tests passing is not the same as the program working. Both must be true.

## Phase 4 -- Decision

**If all `must_fix` and `should_fix` items are resolved and all gates pass:**
- Set plan `Status: VERIFIED`
- Report what was verified and the evidence for each check

**If issues remain:**
- Add fix tasks to the plan's task list
- Set `Status: PENDING`, `Approved: Yes`, increment `Iteration`
- Invoke `/spec-implement` to fix them -- do NOT ask the user whether to fix

## Rules

- NEVER mark VERIFIED with open `must_fix` items
- NEVER skip execution verification -- browser/CLI evidence is required for UI/API changes
- Fix loop is automatic -- the only user interaction is the initial plan approval
