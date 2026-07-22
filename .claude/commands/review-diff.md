---
model: opus
description: Review code changes for correctness, quality, and adherence to standards
---

High-recall, two-pass review. The failure mode this is tuned against is a **thin review** — walking past real issues and returning three findings on a fifty-line diff. The goal is to surface **every real issue**, then rank by severity. Confidence is managed by the severity tier a finding lands in, **never by silently dropping it**. Merge everything into one ranked list.

**This is the single front door for reviewing a code diff** — working tree, a committed branch against a base, or a PR. You never need another review command or a hand-spawned `changes-review` agent: Step 1 resolves whatever diff you point it at. If the built-in `/code-review` skill returns nothing because the change is already committed, that is NOT a signal to reach for `changes-review` — it means Step 1 must materialize the committed diff (below).

## Step 1 — Resolve the diff surface

Establish **what to review** and **how to obtain it** before anything else. The built-in `/code-review` skill (Step 3, Pass A) only sees the **working-tree** diff, so for anything already committed you must materialize the diff explicitly here.

| Args | Source | How to get the diff | Pass A engine |
|------|--------|---------------------|---------------|
| none | Working tree (staged + unstaged + untracked) | `git diff HEAD` plus untracked files | built-in `/code-review` skill (native) |
| file paths | Working-tree subset | `git diff HEAD -- <paths>` | built-in `/code-review` skill (native) |
| a branch / "this branch" / `<base>..<branch>` | Committed branch vs base | fetch if remote (`git fetch <remote> <branch>`), then `git diff <base>...<head>` | manual precision pass over the resolved diff |
| a PR number | GitHub PR | `gh pr view <n>`, `gh pr diff <n>` | manual precision pass; `gh pr comment` / built-in `/review` to post |

Rules for Step 1:

- **Default base is `main`** (fall back to `master` or the repo's default branch if `main` is absent). Honor an explicit base when the user names one (`<base>..<branch>`).
- **Three-dot diff for a branch:** `git diff <base>...<head>` shows the changes introduced on `<head>` since it diverged from `<base>` — the same set GitHub's "Files changed" shows. Use it, not two-dot, so changes landed on `<base>` don't pollute the review.
- **Reviewing is read-only.** *Fetch*, don't checkout/pull, so you never mutate the user's working branch; read head-ref file contents with `git show <head>:<path>` when the branch isn't checked out. Never run a git write command as part of a review.
- Record the exact range you resolved (e.g. `main...origin/feature-x`) — every later step reviews *that* range.

## Step 2 — Anchor to intent and enumerate the surface

Before looking for issues, establish what the change is *for* and what it *touches*:

1. Read the PR description / commit messages / stated goal. Note the intended behavior so you can tell a deliberate design choice from a bug (and apply the lineage test: every changed line should trace to that goal).
2. List **every changed file and every changed symbol** in the resolved range. This list is your coverage checklist for Step 4 and Step 5 — you are accountable for each entry.
3. **Read the full changed files, not just the diff hunks** (at the head ref — `git show <head>:<path>` for a committed range). Then use CodeGraph/Semble to map callers and callees of each changed symbol (`codegraph_callers` / `codegraph_impact`). Bugs frequently live in *unchanged* callers that the change just invalidated — those are in scope.

## Step 3 — Pass A: precision core

The precision-biased first pass. Pick the engine Step 1 resolved:

- **Working-tree diff** → run the built-in reviewer inline at the broadest setting: `Skill(skill='code-review', args='max')`. This is the canonical Claude Code reviewer — it has an effort dial and adversarially verifies each finding before reporting, covering correctness bugs and reuse / simplification / efficiency cleanups. `max` (not `xhigh`) because thin reviews are the failure mode we are fixing and `max` gives the broadest coverage. Pass flags through when relevant: `args='max --comment'` posts findings as inline PR comments; `args='max --fix'` applies them.
- **Committed branch / base-ref / PR** → the built-in skill sees an empty working tree and would report nothing, so run the precision pass **yourself** over the resolved `git diff <base>...<head>`: read the full changed files at the head ref and apply the same lens (correctness bugs + reuse / simplification / efficiency cleanups), adversarially verifying each finding before you keep it. For a GitHub PR, `gh pr diff <n>` is the diff and `gh pr comment` (or the built-in `/review` skill) posts findings back.

Its findings are verified. **Carry every one of them forward into the merged list — do not re-cull them.**

## Step 4 — Pass B: dimension sweep (this is where recall is won or lost)

Pass A is deliberately precision-biased and will miss whole categories. Pass B is the recall pass. Work **one dimension at a time**, and for each dimension check it against **every changed file** from your Step 2 list — a coverage matrix, not a skim. Do not collapse dimensions into a single glance; that is what produces thin reviews.

**Correctness & robustness (beyond Pass A):**
1. **Edge cases**: empty/null/zero inputs, boundary and off-by-one, unicode/encoding, large inputs, first-run/empty-state.
2. **Error paths**: unchecked return values, swallowed exceptions, `try/except` that hides root cause, partial failure leaving inconsistent state, missing rollback/cleanup on the error branch.
3. **Concurrency & shared state**: races, ordering assumptions, mutable state shared across goroutines/async tasks, non-idempotent retries.
4. **Resource lifecycle**: unclosed handles/connections/files, leaks, missing `finally`/`defer`/context-manager, cleanup skipped on early return.
5. **Contracts & compatibility**: changed function/API/CLI/config signature without updating all callers; breaking change to a persisted format, wire protocol, or public interface; migration ordering.

**Quality & standards:**
6. **Security**: injection vectors, auth/authorization not checked, secrets in code, input not validated at system boundaries, unsafe deserialization, SSRF/path traversal.
7. **Performance**: hot paths (render loops, request handlers, polling) without caching/memoization; N+1 queries; redundant recomputation; heavy imports in a hot path.
8. **YAGNI**: unused abstractions, speculative params/config/hooks, code not reachable from the stated request. Confirm "unused" with a caller search before flagging.
9. **Codebase consistency**: reinvented helpers, divergent idioms, one-off styles that ignore an existing convention. Cite the established pattern (`file:line`).
10. **DRY**: duplicated logic, reimplementing a utility the repo already has. Cite the existing implementation (`file:line`).
11. **Tests**: critical paths covered; assertions test behavior, not internals; a one-character bug in the implementation would still fail the test (not just truthiness); reuse existing fixtures; prefer mocks/fixtures over hand-rolled fakes; a new dependency (subprocess/I/O) mocked in *all* existing tests for that function.
12. **Standards**: file > 800 lines, function > 50 lines, nesting > 4 levels, `any`/`interface{}` without narrowing, bare `except:`, hardcoded secrets/URLs/config.
13. **Design**: SOLID violations, premature or missing abstraction, inappropriate coupling, leaked persistence models across layers.
14. **Observability**: errors swallowed without logging, missing context in error messages, log level misuse, no signal on the failure branch.
15. **Docs consistency**: every inline comment, docstring, README, and architecture doc that references the changed code — directly or indirectly (a caller, or a documented behavior that depends on it) — updated in the same change; public API / CLI flag / config changes reflected in docs; terminology, counts, and lists kept accurate; breaking changes called out.

### Reporting threshold (the key recall lever)

When you notice something that *might* be an issue, **report it** — do not self-censor. Route it by confidence into the right tier instead of dropping it:

- Confident it breaks correctness/security → `must_fix`
- Confident it degrades maintainability/coverage/consistency → `should_fix`
- Real but lower-confidence, minor, or genuinely optional → `suggestion`

The **only** things you silence: pure formatter-owned style, and anything you actively verified is correct. "I'm not 100% sure" is a reason to file it as a `suggestion`, not a reason to omit it.

## Step 5 — Completeness critic (defeats the thin-review failure directly)

Before writing output, audit your own coverage against the Step 2 checklist:

1. **Zero-finding files**: which changed files/functions produced *no* finding? For each, state in one line why it is genuinely clean. If you can't, you haven't reviewed it — go back and do the dimension sweep on it.
2. **Weakest dimension**: which of the 15 dimensions did you spend the least on? Run it once more, deliberately.
3. **Unchecked callers**: did you inspect the callers/impact of every changed symbol (Step 2.3)? Name any you skipped and check them now.

Only after this audit do you produce the merged output.

## Output — merged, ranked findings

One list, **ranked most-severe first**. Fold Pass A's findings in with Pass B's (drop exact duplicates; keep the more specific wording). Every finding carries `file:line`, and `must_fix`/`should_fix` carry a concrete failure scenario.

```
## Findings

### must_fix
- [file:line] Issue — concrete failure scenario (inputs/state → wrong result)

### should_fix
- [file:line] Issue — why it degrades maintainability, coverage, or diverges from an established convention

### suggestion
- [file:line] Optional or lower-confidence improvement
```

If a tier is empty, say so explicitly (e.g. "no `must_fix`"). A genuinely clean diff yields few findings — but you must have *earned* that via the Step 5 audit, not skipped the sweep.

## Severity Definitions

- `must_fix`: breaks correctness or security
- `should_fix`: degrades maintainability, test coverage, diverges from an established codebase convention, or violates documented standards
- `suggestion`: optional improvement, or a real-but-lower-confidence observation; no obligation

## Rules

- NEVER report formatter-owned style — but everything else you notice gets filed, at the appropriate tier. Under-reporting is the failure we are fixing; when unsure, file it as a `suggestion`.
- NEVER flag `must_fix` without naming the failure scenario.
- NEVER suggest adding features that are not called anywhere (YAGNI).
- Consistency and DRY findings MUST cite the established pattern or existing implementation (`file:line`) the change diverges from or duplicates.
- Prefer reusing existing test fixtures/mocks; flag a new fake when a fixture/mock already covers that dependency.
- Do not re-cull Pass A's verified findings — carry them forward.
- NEVER run a git write command (checkout/pull/commit/reset) as part of a review — fetch and diff are read-only; reviewing must not mutate the working tree.

## Next Step

Apply all `must_fix` and `should_fix` items. Run the affected tests after each fix.
