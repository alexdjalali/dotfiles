---
model: opus
description: Dispatch to the right phase of the implementation workflow based on plan status
argument-hint: "[<plan file> | <story/RCA file> | <description>]"
disable-model-invocation: true
---

Read the plan file and dispatch to the correct phase automatically.

## Dispatch Logic

Read the plan's `Type:` (Feature or Bugfix) and `Status:` header, then route:

| Plan state | Feature | Bugfix |
|------------|---------|--------|
| No plan file yet | `/spec-plan` | `/spec-bugfix-plan` |
| `PENDING`, `Approved: No` | `/spec-plan` (resume/start) | `/spec-bugfix-plan` (resume/start) |
| `PENDING`, `Approved: Yes` | `/spec-implement` | `/spec-implement` |
| `COMPLETE` | `/spec-verify` | `/spec-bugfix-verify` |
| `VERIFIED` | Report done -- nothing to do | Report done -- nothing to do |

Lifecycle: `PENDING` (awaiting implementation) → `COMPLETE` (ready to verify) → `VERIFIED`; verify loops back to `PENDING` (incrementing `Iteration:`) until everything passes. `spec-implement` serves both types -- the plan is the interface.

For a **new** request (no plan yet), infer Type from the description — a defect/regression/error report → Bugfix; a new capability → Feature. If genuinely ambiguous, ask the user once.

## Finding the Plan

- If args is a plan file (under `docs/local/plans/`, or has a `Status:` header) -- use it directly
- If args is a path that is NOT a plan (e.g. a `docs/spec/stories/` story, a `docs/spec/rca/` RCA, a design doc) -- it is the **request**: infer Type (a story → Feature; an RCA → Bugfix) and pass the path to `/spec-plan` or `/spec-bugfix-plan`, which read it as their requirements source
- If args is a description -- search `docs/local/plans/` (`ls docs/local/plans/`) for a matching file by name or title
- If no match -- start fresh: invoke `/spec-plan` (or `/spec-bugfix-plan` for a defect) with the description

## Plan File Convention

`docs/local/plans/YYYY-MM-DD-<slug>.md`, written from `~/.claude/templates/plan.md`.

## ⛔ Dispatcher Integrity

Thin router — **only** `Bash` (env-var reads and `ls docs/local/plans/` to find plans), `Read` (plan files, or the head of a passed story/RCA to infer its type), `AskUserQuestion`, `Skill()`. Any Grep/Glob/Task/Edit/Write is a violation.

## User Checkpoints

**Plan approval is the only checkpoint** (in `spec-plan` / `spec-bugfix-plan`), plus the Type question above only when Feature-vs-Bugfix is genuinely ambiguous. Everything else chains automatically; `/github` is *suggested* after `VERIFIED`, never auto-run. **NEVER ask "Should I fix these findings?"** — verification fixes are part of the approved plan.

Invoke the correct skill immediately. Do not ask the user what to do -- the status header determines the action.
