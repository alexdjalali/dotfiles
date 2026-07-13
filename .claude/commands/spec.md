---
description: Dispatch to the right phase of the implementation workflow based on plan status
---

Read the plan file and dispatch to the correct phase automatically.

## Dispatch Logic

| Plan state | Action |
|------------|--------|
| No plan file yet | Run `/spec-plan` |
| `Status: PENDING`, `Approved: No` | Run `/spec-plan` (resume or start) |
| `Status: PENDING`, `Approved: Yes` | Run `/spec-implement` |
| `Status: COMPLETE` | Run `/spec-verify` |
| `Status: VERIFIED` | Report done -- nothing to do |

## Finding the Plan

- If args is a file path -- use it directly
- If args is a description -- search `docs/plans/` for a matching file by name or title
- If no match -- start fresh: invoke `/spec-plan` with the description

## Plan File Convention

`docs/plans/YYYY-MM-DD-<slug>.md`

Invoke the correct skill immediately. Do not ask the user what to do -- the status header determines the action.
