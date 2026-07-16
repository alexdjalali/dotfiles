---
description: Verify a completed plan -- code review, automated gates, execution check, loop back if issues found
---

Read the plan from `docs/spec/plans/`. Status must be `COMPLETE`.

## Phase 1 -- Code Review

1. **Built-in code review** (correctness + quality): run inline via `Skill(skill='code-review', args='xhigh')`. On Claude Code the changes review is this built-in skill, not a sub-agent.
2. **Plan-compliance & goal audit** (inline): did the implementation follow the plan exactly, are all tasks marked complete, are there undocumented deviations, and does the result achieve the plan's stated goal?

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
