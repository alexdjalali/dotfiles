---
model: opus
description: Dispatch to the right phase of the implementation workflow based on plan status
argument-hint: "[<plan file> | <description>]"
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

For a **new** request (no plan yet), infer Type from the description — a defect/regression/error report → Bugfix; a new capability → Feature. If genuinely ambiguous, ask the user once.

## Finding the Plan

- If args is a file path -- use it directly
- If args is a description -- search `docs/spec/plans/` for a matching file by name or title
- If no match -- start fresh: invoke `/spec-plan` (or `/spec-bugfix-plan` for a defect) with the description

## Plan File Convention

`docs/spec/plans/YYYY-MM-DD-<slug>.md`

Invoke the correct skill immediately. Do not ask the user what to do -- the status header determines the action.
