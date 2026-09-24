---
model: opus
description: Run the plan → implement → verify workflow — routes a description, story, RCA, or existing plan file to the right phase by its Type and Status
argument-hint: "[<plan file> | <story/RCA file> | <description>]"
disable-model-invocation: true
---

Thin router: find (or start) the plan, read its `Type:` and `Status:` header, invoke the phase. It never plans, codes, or verifies itself.

## 1. Find the plan

- **A plan file** (under `docs/local/plans/`, or has a `Status:` header) → use it.
- **A non-plan path** (a `docs/spec/stories/` story, a `docs/spec/rca/` RCA, a design doc) → it is the **request**: a story → Feature, an RCA → Bugfix. Pass the path to the plan phase, which reads it as its requirements source.
- **A description** → `ls docs/local/plans/` for a match by name or title; no match → a new request.
- **New request** → infer Type: a defect / regression / error report → Bugfix; a new capability → Feature. Ask once only if genuinely ambiguous.

Plans live at `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored), written from `~/.claude/templates/plan.md`.

## 2. Route

| Plan state | Feature | Bugfix |
|------------|---------|--------|
| No plan yet | `spec-plan` | `spec-bugfix-plan` |
| `PENDING`, `Approved: No` | `spec-plan` (start/resume) | `spec-bugfix-plan` (start/resume) |
| `PENDING`, `Approved: Yes` | `spec-implement` | `spec-implement` |
| `COMPLETE` | `spec-verify` | `spec-bugfix-verify` |
| `VERIFIED` | report done | report done |

Invoke the phase immediately — `Skill(skill='<phase>', args='<plan path | request>')`. The header decides; don't ask the user what to do. Lifecycle: `PENDING` → `COMPLETE` → `VERIFIED`; verify loops back to `PENDING` (incrementing `Iteration:`) until everything passes. `spec-implement` serves both types — the plan is the interface.

## Rules

- **⛔ Dispatcher integrity:** only `Bash` (env-var reads, `ls docs/local/plans/`), `Read` (plan files, or the head of a passed story/RCA to infer its type), `AskUserQuestion`, and `Skill()`. Any Grep/Glob/Task/Edit/Write is a violation.
- **Plan approval is the only checkpoint** (in the plan phase), plus the Type question above when genuinely ambiguous; everything else chains. **NEVER ask "Should I fix these findings?"** — verification fixes are part of the approved plan. `/github` is suggested after `VERIFIED`, never auto-run.
