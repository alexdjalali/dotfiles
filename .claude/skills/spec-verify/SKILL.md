---
name: spec-verify
description: /spec verification, Feature or Bugfix — one review-diff over the chain's commits, plan/contract audits, revert-test proof (bugfix), the full gate once, live execution; marks VERIFIED or loops back to implement. Runs after spec-implement.
model: opus
---

**Input:** a plan in `docs/local/plans/` with `Status: COMPLETE`. **Output:** `Status: VERIFIED` with evidence for every check — or fix tasks added and a loop back to `spec-implement`. The loop is automatic: plan approval was the only user checkpoint, so never ask whether to fix.

## Phase 1 — Review

**Loop-backs re-run only what the fix commits touched** (`git diff --name-only <Reviewed>...HEAD`): review that range only; re-prove the revert-test only if it touches the fix or the reproducing test; the plan audit is cheap and always re-runs. The full gate and execution run once, at the final HEAD.

Categorize every finding `must_fix` / `should_fix` / `suggestion`.

1. **Code review** — once over every commit the chain made: `Skill(skill='review-diff', args='<Base>...HEAD')`; on a loop-back only the fix commits, `'<Reviewed>...HEAD'`. It covers tests, doubles, and parsimony (`testing.md`) — don't re-audit them here. Then set `Reviewed:` to `git rev-parse HEAD`.
2. **Plan audit** — every task ticked, Done/Left agree, each story has exactly one commit with its SHA recorded, no undocumented deviation, every **Goal Verification** truth holds and every artifact exists and is non-stub. Audit each `Trivial:` claim against the diff (the `testing.md` limits); a failed claim is `must_fix` (remove it, write the RED test).
3. **Bugfix — Behavior Contract** — the exact trigger now produces the correct behavior; every parallel implementation the plan names was fixed.

Any `must_fix` / `should_fix` (or a quick `suggestion`) → loop back now (Phase 5 *Otherwise*); don't prove or gate code that is about to change.

## Phase 2 — Bugfix: revert-test proof

NEVER mark a bugfix VERIFIED without it. Revert the fix (not the test) with Edit — `git show <Base>:<path>` shows the pre-fix lines — and run the reproducing test: it MUST fail. Re-apply with Edit: it MUST pass and `git diff` is empty again. Never `git stash` / `git checkout` for this. A test that passes with the fix reverted doesn't pin the bug — rewrite it.

## Phase 3 — Full gate (once)

Run the full gate (CLAUDE.md *Quality Gates*) at HEAD — skip if `Full gate:` already records HEAD. Green → `Full gate: green @ <sha>`. Red → fix tasks, loop back; the fix commit is reviewed as `<Reviewed>...HEAD`, then the gate re-runs once. Flag any production file over 800 lines.

## Phase 4 — Execute (once, at the final HEAD)

Tests passing ≠ the program working. NEVER skip — but run it once, after the full gate is green; a failure loops back and it runs again only after the fix: run the real CLI / call the API / drive the UI (Read `~/.claude/rules/browser-automation.md` and run its live-target probe) — for a bugfix, on the **original trigger**.

## Phase 5 — Decide

**Every `must_fix` / `should_fix` resolved (`suggestion` → applied if quick), everything committed, full gate green at HEAD:** set `Status: VERIFIED` and report each check with its evidence; close every `docs/spec/stories/` story the plan covers (`**Status**: Complete`, plus its row in the epic) — these doc edits ride in the next `/github` commit.

**Otherwise:** add fix tasks to the plan (and to Left), set `Status: PENDING`, keep `Approved: Yes`, increment `Iteration`, and call `Skill(skill='spec-implement')` in the same turn. NEVER mark VERIFIED with an open `must_fix`.

## Next Step

Suggest `/github pr` (user-typed) to push the commits and open a PR — no full-gate re-run.
