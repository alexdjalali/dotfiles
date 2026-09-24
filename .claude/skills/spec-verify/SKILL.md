---
description: Verify a completed plan -- code review, automated gates, execution check, loop back if issues found
model: opus
---

Read the plan from `docs/local/plans/`. Status must be `COMPLETE`.

## Phase 1 -- Code Review

1. **Code review** (correctness + quality): run `/review-diff` inline via `Skill(skill='review-diff')` (no args → the working-tree diff). `/review-diff` is the single front door for reviewing a diff — it resolves the diff surface itself and runs its two-pass review + completeness critic.
2. **Plan-compliance & goal audit** (inline): did the implementation follow the plan exactly, are all tasks marked complete (Done/Left consistent), are there undocumented deviations, and does every **Goal Verification** truth hold (every artifact present and non-stub)?
3. **Test-double audit** (inline, per `testing.md` *Test Double Policy*): unit tests mock their boundary; integration tests run the real dependency via testcontainers; no fake, no in-memory substitute, no `integration/` test that mocks the dependency it names. Each violation is `must_fix`.
4. **Parsimony + `Trivial:` audit** (inline, per `testing.md` *Test Parsimony*): no per-method test classes, no redundant tests of one observable path, no coverage padding. Audit every task's `Trivial:` claim against the actual diff — it must name a covering test/command, add ≤ 5 net production lines, no new branch/loop/try with a non-trivial body, no new public symbol, no new error path; bugfixes never qualify. A failed claim is `must_fix` (remove `Trivial:`, write the RED test).

Categorize findings: `must_fix`, `should_fix`, `suggestion`.

## Phase 2 -- Automated Gates

Run `/preflight` (format, lint, type check, tests, docs & consistency — stop on failure, fix, re-run), plus flag any production file over 800 lines.

## Phase 3 -- Execution Verification

Run the actual program and verify the feature works end-to-end:
- CLI: run the command with realistic inputs
- API endpoint: call it and inspect the response
- UI change: run the **live-target probe** (`browser-automation.md`) to get a live target, then use browser automation to interact with the changed page

Tests passing is not the same as the program working. Both must be true.

## Phase 4 -- Decision

**If all `must_fix` and `should_fix` items are resolved and all gates pass:**
- Set plan `Status: VERIFIED`
- **Close the story** — if the plan's References cite a `docs/spec/stories/` story, set its `**Status**:` to `Complete`, and update that story's row in its epic (`docs/spec/epics/`) if the epic tracks status.
- Report what was verified and the evidence for each check
- **Persist the proof (user-facing epics/stories)** — if this completes a user-visible flow, offer to capture the end-to-end walkthrough (the same one Phase 3 just ran) as a `/demo` doc, so the proof is durable and shareable. Suggest, do NOT auto-run.
- **Next Step (Ship)** — suggest, do NOT auto-run: `/github` to commit and open a PR, preserving the traceability chain Decision -> Epic -> Story -> Plan -> PR. Git writes always require the user to run the command themselves.

**If issues remain:**
- Add fix tasks to the plan's task list (and to Left)
- Set `Status: PENDING`, `Approved: Yes`, increment `Iteration`
- Continue the chain — call `Skill(skill='spec-implement')` to fix them, in the same turn. Do NOT ask the user whether to fix

## Rules

- NEVER mark VERIFIED with open `must_fix` items
- NEVER skip execution verification -- browser/CLI evidence is required for UI/API changes
- Fix loop is automatic -- plan approval is the only user checkpoint; `/github` is suggested, never auto-run
