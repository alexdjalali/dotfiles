---
name: spec
model: sonnet
effort: low
description: Run the plan → implement → verify workflow — routes a description, epic, story, RCA, or existing plan file to the right phase by its Type and Status. Use to start or resume large multi-system work that needs a plan; user-typed only.
argument-hint: "[<plan file> | <epic/story/RCA file> | <description>]"
disable-model-invocation: true
---

Thin router: find (or start) the plan, read its `Type:` and `Status:` header, invoke the phase. It never plans, codes, or verifies itself.

## 1. Find the plan

- **A plan file** (under `docs/local/plans/`, or has a `Status:` header) → use it.
- **A non-plan path** (a `docs/spec/epics/` epic, a `docs/spec/stories/` story, a `docs/spec/rca/` RCA, a design doc) → it is the **request**: an epic or story → Feature (an epic plans every open story, 1 story = 1 commit), an RCA → Bugfix. Pass the path to the plan phase, which reads it as its requirements source.
- **A description** → `ls docs/local/plans/` for a match by name or title; no match → a new request.
- **New request** → infer Type: a defect / regression / error report → Bugfix; a new capability → Feature. Ask once only if genuinely ambiguous.

Plans live at `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored), written from `~/.claude/templates/plan.md`.

## 2. Route

| Plan state | Phase (Feature and Bugfix alike — the plan's `Type:` drives each phase) |
|------------|-------|
| No plan yet, or `PENDING` + `Approved: No` | `spec-plan` (start/resume; pass the inferred Type) |
| `PENDING`, `Approved: Yes` | `spec-implement` |
| `COMPLETE` | `spec-verify` |
| `VERIFIED` | report done |

Invoke the phase immediately — `Skill(skill='<phase>', args='<plan path | request>')`. The header decides; don't ask the user what to do. Lifecycle: `PENDING` → `COMPLETE` → `VERIFIED`; verify loops back to `PENDING` (incrementing `Iteration:`) until everything passes. Every phase serves both types — the plan is the interface. Each phase's `model:` / `effort:` pin applies when invoked via `Skill()`.

## Rules

- **⛔ Dispatcher integrity:** only `Bash` (env-var reads, `ls docs/local/plans/`), `Read` (plan files, or the head of a passed epic/story/RCA to infer its type), `AskUserQuestion`, and `Skill()`. Any Grep/Glob/Task/Edit/Write is a violation.
- **Plan approval is the only checkpoint** (in the plan phase), plus the Type question above when genuinely ambiguous; everything else chains. **NEVER ask "Should I fix these findings?"** — verification fixes are part of the approved plan. `/github` is suggested after `VERIFIED`, never auto-run.
