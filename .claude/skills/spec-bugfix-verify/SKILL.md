---
description: /spec bugfix verification — review, Behavior Contract audit, revert-test proof, gates, run on the original trigger; marks VERIFIED or loops back. Runs after spec-implement.
model: opus
---

**Input:** a plan in `docs/local/plans/` with `Status: COMPLETE`, `Type: Bugfix`. **Output:** `Status: VERIFIED` with the revert-test and execution evidence — or fix tasks added and a loop back to `spec-implement`. The loop is automatic: never ask whether to fix.

## Phase 1 — Review

1. **Code review** — `Skill(skill='review-diff')` with no args (the working-tree diff); categorize its findings `must_fix` / `should_fix` / `suggestion`.
2. **Test-double audit** (`testing.md` *Test Double Policy*) — the reproducing test and every touched test use the right double: unit mocks the boundary; integration runs the real dependency via testcontainers. A fake, an in-memory substitute, or a mislabeled integration test is `must_fix`.

## Phase 2 — Behavior Contract audit

The exact trigger now produces the correct behavior; no contract clause is unmet; every parallel implementation the plan names was fixed.

## Phase 3 — Revert-test proof

NEVER mark VERIFIED without it — it is the regression guarantee.

1. Revert the fix (not the test) with Edit — restore the pre-fix lines.
2. Run the reproducing test — it MUST fail.
3. Re-apply the fix with Edit.
4. Run it again — it MUST pass.

Never use `git stash` / `git checkout` for this — they are git writes and can discard unrelated work. A test that still passes with the fix reverted isn't pinning the bug — rewrite it.

## Phase 4 — Gates & execution

1. Run the quality gates (CLAUDE.md *Quality Gates*; full suite, 0 failures); also flag any production file over 800 lines.
2. Run the real program on the **original trigger** and confirm the bug is gone — CLI / API / browser evidence (for a UI bug, Read `~/.claude/rules/browser-automation.md` and run its live-target probe). NEVER skip this: "tests pass" is not "bug is gone".

## Phase 5 — Decide

**Every `must_fix` / `should_fix` resolved (`suggestion` → applied if quick), revert-test proven, gates green:**

1. Set `Status: VERIFIED`; report the revert-test evidence and the execution proof.
2. **Close the story** — if References cite a `docs/spec/stories/` story, set its `**Status**:` to `Complete` and update its row in the epic (`docs/spec/epics/`) if the epic tracks status.

**Otherwise:** add fix tasks, set `Status: PENDING`, keep `Approved: Yes`, increment `Iteration`, and call `Skill(skill='spec-implement')` in the same turn. NEVER mark VERIFIED with an open `must_fix`.

## Next Step

Suggest — never run — `/github` to commit and open a PR (traceability: Decision → Epic → Story → Plan → PR). The user types it; every git write is theirs to confirm.
