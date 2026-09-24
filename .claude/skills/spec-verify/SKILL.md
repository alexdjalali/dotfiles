---
description: /spec feature verification — code review, plan/goal/test-double/parsimony audits, gates, live execution; marks VERIFIED or loops back to implement. Runs after spec-implement.
model: opus
---

**Input:** a plan in `docs/local/plans/` with `Status: COMPLETE`, `Type: Feature`. **Output:** `Status: VERIFIED` with evidence for every check — or fix tasks added and a loop back to `spec-implement`. The loop is automatic: plan approval was the only user checkpoint, so never ask whether to fix.

## Phase 1 — Review

Categorize every finding `must_fix` / `should_fix` / `suggestion`.

1. **Code review** — `Skill(skill='review-diff')` with no args (the working-tree diff). It is the single front door for diff review and returns ranked findings from its two-pass review + completeness critic.
2. **Plan compliance & goal audit** — the implementation followed the plan exactly; every task is ticked and Done/Left agree; no undocumented deviation; every **Goal Verification** truth holds and every artifact exists and is non-stub.
3. **Test-double audit** (`testing.md` *Test Double Policy*) — unit tests mock their boundary; integration tests run the real dependency via testcontainers; no fake, no in-memory substitute, no `integration/` test that mocks the dependency it names. Each violation is `must_fix`.
4. **Parsimony + `Trivial:` audit** (`testing.md` *Test Parsimony*) — no per-method test classes, no redundant tests of one observable path, no coverage padding. Audit every task's `Trivial:` claim against the actual diff: it names a covering test/command, adds ≤ 5 net production lines, no new branch/loop/try with a non-trivial body, no new public symbol, no new error path; bugfixes never qualify. A failed claim is `must_fix` (remove `Trivial:`, write the RED test).

## Phase 2 — Gates

Run the quality gates (CLAUDE.md *Quality Gates*) — stop on failure, fix, re-run. Also flag any production file over 800 lines.

## Phase 3 — Execute

Tests passing ≠ the program working; both must hold. NEVER skip this phase — CLI/API/browser evidence is required:

- **CLI** → run the command with realistic inputs.
- **API** → call the endpoint and inspect the response.
- **UI** → Read `~/.claude/rules/browser-automation.md`, run its live-target probe, then drive the changed page with browser automation (click the primary action, re-snapshot).

## Phase 4 — Decide

**Every `must_fix` and `should_fix` resolved (`suggestion` → applied if quick) and every gate green:**

1. Set `Status: VERIFIED`; report each check with its evidence.
2. **Close the story** — if References cite a `docs/spec/stories/` story, set its `**Status**:` to `Complete` and update its row in the epic (`docs/spec/epics/`) if the epic tracks status.

**Otherwise:** add fix tasks to the plan (and to Left), set `Status: PENDING`, keep `Approved: Yes`, increment `Iteration`, and call `Skill(skill='spec-implement')` in the same turn. NEVER mark VERIFIED with an open `must_fix`.

## Next Step

Suggest — never run — `/github` to commit and open a PR, keeping the chain Decision → Epic → Story → Plan → PR (the user types it; every git write is theirs to confirm). If this completes a user-visible flow, also offer `/demo` to persist the Phase 3 walkthrough as durable proof once it ships — suggest, don't auto-run.
