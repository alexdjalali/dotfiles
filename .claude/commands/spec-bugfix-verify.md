---
description: Verify a bugfix -- Behavior Contract audit, revert-test proof, regression + gates
model: opus
---

Read the plan from `docs/local/plans/`. Status must be `COMPLETE`, `Type: Bugfix`.

## Phase 1 -- Code Review

Run `/review-diff` inline over the just-implemented changes: `Skill(skill='review-diff')` (no args → the working-tree diff). `/review-diff` is the single front door for reviewing a diff — it resolves the diff surface itself and runs its two-pass review + completeness critic, so it executes even though the built-in `/code-review` skill is blocked from model invocation on Claude Code (that skill can only be user-triggered; its empty result on a committed diff is not a fallback). Categorize findings `must_fix` / `should_fix` / `suggestion`.

**Test-double audit (inline):** the reproducing test and any tests touched use the right double — unit mocks the boundary; integration runs the real dependency in a Docker container via testcontainers, never a mock or in-memory substitute (SQLite-for-Postgres, fakeredis). A fake / mislabeled integration test is `must_fix`. (See `testing.md` *Test Double Policy*.)

## Phase 2 -- Behavior Contract Audit

Confirm the implementation satisfies the **Behavior Contract** in the plan: the exact trigger now produces the correct behavior, and no contract clause is unmet. Confirm every parallel implementation named in the plan was fixed.

## Phase 3 -- Revert-Test Proof

Prove the reproducing test actually catches the bug:

1. Temporarily revert the fix (not the test).
2. Run the reproducing test -- it MUST fail.
3. Restore the fix.
4. Run it again -- it MUST pass.

A reproducing test that still passes with the fix reverted is not pinning the bug -- rewrite it.

## Phase 4 -- Gates & Execution

1. Full suite: `pytest -q` / `go test ./...` / `vitest run` -- 0 failures.
2. Type check + lint: `basedpyright` / `go vet ./...` / `tsc --noEmit`; `ruff check .` / `golangci-lint run ./...` / `eslint .`.
3. Execute the real program on the original trigger and confirm the bug is gone (CLI / API / browser evidence).

## Phase 5 -- Decision

**All `must_fix` / `should_fix` resolved, revert-test proven, gates pass:**
- Set `Status: VERIFIED`; report the revert-test evidence and the execution proof.
- **Next Step (Ship)** — suggest, do NOT auto-run: `/github` to commit and open a PR (traceability: Decision -> Epic -> Story -> Plan -> PR). Git writes always require the user to run the command themselves.

**Issues remain:**
- Add fix tasks; set `Status: PENDING`, `Approved: Yes`, increment `Iteration`; continue the chain — call `Skill(skill='spec-implement')` in the same turn. Do NOT ask whether to fix.

## Rules

- NEVER mark VERIFIED without the revert-test proof -- it is the regression guarantee
- NEVER mark VERIFIED with open `must_fix` items
- NEVER skip execution on the original trigger -- "tests pass" is not "bug is gone"
- Fix loop is automatic -- the only user interaction was the initial plan approval
