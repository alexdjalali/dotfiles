---
name: spec-implement
description: /spec implementation — execute an approved plan task by task with TDD, one commit per story, then hand off to verify. Runs after plan approval or a verify loop-back.
model: claude-opus-4-8
effort: high
---

**Input:** a plan in `docs/local/plans/` with `Status: PENDING`, `Approved: Yes` (Feature or Bugfix — the plan is the interface). **Output:** every task done and ticked, one commit per story (plus one review-fix commit on a verify loop-back), `Status: COMPLETE`, and the hand-off to the verify phase.

**Before the first commit** (`Base:` empty): `git status --short` — unrelated uncommitted changes → STOP and ask; clean → set `Base:` to `git rev-parse HEAD`. Approval authorizes the commits below and nothing else (`development-practices.md` *Git*).

**Don't re-explore.** The plan's Context for Implementer and each task's Files are the map; look up only what a task needs that the plan doesn't say.

## Per task — each unchecked task in order, including fix tasks a verify loop added

1. **Read the task** — know exactly what its Definition of Done requires.
2. **RED** — one failing test for the task's behavior, tier and double per `testing.md` *Test Double Policy*, reusing existing fixtures. For a bugfix, Task 1 is the plan's reproducing test. It must fail for the right reason (behavior missing / bug present — not a syntax or import error). Only a task whose `Trivial:` claim holds skips RED — run its named covering command instead.
3. **GREEN** — the simplest code that passes; nothing the task doesn't require. Match surrounding patterns; reuse the repo's helpers. Anything the plan didn't cover (infra, CLI, config, a new dependency) is a Deviation, not a silent add.
4. **Affected tests** — run the tests for the code this task touched; NEVER proceed past a failure. The full suite waits for the full gate.
5. **Refactor** — clarity only; tests stay green.
6. **Docs** — update every doc referencing the changed code, directly or indirectly (`documentation-sync.md`).
7. **Tick it now** — `- [ ]` → `- [x]`, Progress Tracking Done +1, Left −1. NEVER batch-mark.

**Red flags — stop and do the step:** "too simple to test" · "I'll write the test after" · "it passed immediately, fine" · "the plan didn't say, but I'll add it" · "I'll batch the ticks". Each is how a verify loop-back starts.

## After each story's last task — commit

1. **Fast checks** (CLAUDE.md *Quality Gates*) on the story's changed files — all green. NEVER the full gate here.
2. `git add` exactly the story's files (never `-f`), then `git commit -m "<the story's Commit: message>"`. One commit per story — never split a story across commits or batch two stories into one.
3. Record the SHA on the story's `Commit:` line and tick it in Progress Tracking.

**Verify loop-back:** the fix tasks verify added are one group — fast checks, then one `fix(<scope>): address review findings` commit.

## Deviations

Record every one in the plan's `## Deviations` section.

- **Bug / missing critical / blocking** (errors, missing validation, broken imports) → fix inline (+ tests if applicable) and document; don't expand scope.
- **Architectural surprise** (new table, library swap, breaking API change) → **STOP**, document it, and ask via `AskUserQuestion` before continuing.

## After the last task

1. Every story (and fix group) is committed; `git status --short` shows none of the plan's files uncommitted.
2. Set `Status: COMPLETE`.
3. In the same turn, call `Skill(skill='spec-verify')`. Don't stop for the user.
