---
name: spec-plan
description: /spec planning, Feature or Bugfix — explore (or reproduce + root-cause), design 3–12 tasks per story (1 story = 1 commit), write the plan, run spec-review, get approval. Started by /spec, not unprompted; small contained bugs go to /fix.
model: opus
effort: xhigh
---

**Input:** a feature request or story / epic / ADR / design-doc path (`Type: Feature`), or a bug report or RCA (`Type: Bugfix`). **Output:** an approved plan at `docs/local/plans/YYYY-MM-DD-<slug>.md` (gitignored) from `~/.claude/templates/plan.md`, then the hand-off to `spec-implement`. NEVER write production or test code before approval.

## Phase 1 — Explore

1. **Requirements source** — cite every one under References.
   - **Epic** (`docs/spec/epics/…`) → read it and every open story it lists, in order; each story becomes one story group (one commit).
   - **Story** → its **acceptance criteria are the requirements**; its code-addition answers and Proposed Repository Structure seed the design.
   - **RCA** → its root cause (`file:line`) and fix sketch are the starting point — re-confirm both against the current code, don't re-derive.
2. Ambiguous request → ask one clarifying question before continuing.
3. With CodeGraph + Semble: every file the change touches, similar features and their patterns, and the call chains up- and downstream. Record what you found in the plan's **Context for Implementer** (patterns `file:line`, key files, gotchas) — it is the map later phases use instead of re-exploring.
4. **Bugfix only:** reproduce consistently (trigger, inputs, observed vs expected); trace to the **root cause, not the symptom**, including every parallel implementation sharing the flaw; specify the reproducing test — path, name, tier/double (`testing.md` *Test Double Policy*), and the exact assertion that fails *because the bug exists* and passes after the fix.

## Phase 2 — Design

- **1 story = 1 commit** — group tasks by story; each group leaves the tree green on its own. **3–12 tasks per story**, NEVER more; a story needing more is two stories (say so; `/rfp` owns the split). A bugfix is one group.
- Each task: independently testable, one focused TDD cycle, no circular dependencies, reusing the repo's helpers and conventions. NEVER a task that doesn't trace to the request or acceptance criteria. Fold setup, config, and docs into the task whose deliverable needs them.
- **Interfaces:** a task that others build on names what it produces (exact function/type names, signatures); a task that uses them names what it consumes.
- **No placeholders** — each is a plan failure: "TBD", "add error handling", "handle edge cases", "similar to Task N", tests without their assertion, or a name no task defines.
- **Code-addition checklist** — answer all eight from `~/.claude/templates/code-addition-checklist.md` before tasks are final (a repo's `.claude/rules/code-addition-checklist.md` supplies concrete answers); a "yes" to infra/CLI/config is its own task.
- **Bugfix:** the Behavior Contract — Given <trigger>, the code **did** <bug>; it **must** <correct behavior> — plus every parallel implementation, fixed together or with a stated reason. Task 1 writes the reproducing test (RED on current code); later tasks fix the root cause.

## Phase 3 — Write the plan

Header `Type: Feature | Bugfix`, `Status: PENDING`, `Approved: No`, `Iteration: 1`.

- Always fill: Summary, **Goal Verification** (truths + artifacts; for a bugfix the contract's "must" clause is the first truth), Scope, Progress Tracking (grouped by story), Implementation Tasks (`### Story N` groups, each with a conventional `Commit:` message), Testing Strategy, Risks, References.
- **Bugfix block** (Bugfix only): Source, Behavior Contract, Root Cause, Reproducing Test spec.
- **Proposed Repository Structure** — only when new files are created; match the real tree (`codegraph_files` / `ls`); read `~/.claude/templates/repo.md` only when a new top-level directory is needed. A layout that must DEVIATE → ask the user before finalizing.
- `Trivial:` only within the template's limits; bugfix tasks never. Delete every section that doesn't apply.

**Self-review before Phase 4** (inline, not an agent): every requirement / acceptance criterion maps to a task · no placeholders · names and signatures agree across tasks · the edge cases and failure inputs a user would hit (empty, invalid, concurrent, first-run) each have a task whose test pins them. Fix gaps inline.

## Phase 4 — Review the plan

NEVER skip it. Launch `Agent(subagent_type='spec-review')` with `plan_file`, `user_request` (the request or bug report verbatim, plus story acceptance criteria / RCA symptom), `clarifications` (optional), and `output_path` = `docs/local/plans/.spec-review-<slug>.json`. It runs in the background and writes JSON — poll for the file with a bash existence loop, Read it once, fold in every `must_fix` / `should_fix`. **Once per plan:** a Revise round re-runs it only if the revision adds or removes stories/tasks or changes scope — wording and detail edits don't.

## Phase 5 — Approval

> Plan ready. Approve to begin implementation?
> - Approve — start implementing
> - Revise — [specify changes]
> - Cancel — stop here
>
> (Long session? `/compact` first, then `/spec <plan path>` — the plan carries the state.)

NEVER begin without an explicit Approve. On approval set `Approved: Yes` and call `Skill(skill='spec-implement')` in the same turn — approval also authorizes the plan's story commits.
