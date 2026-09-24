---
model: opus
description: Review a diff (working tree, branch vs base, ref range, or PR number) for correctness, quality, and standards via a two-pass, high-recall review. The front door for every code review, including /spec verify.
argument-hint: "[<paths> | <branch> | <base>...<branch> | <PR number>]"
---

High-recall, two-pass review. It is tuned against the **thin review** — walking past real issues and returning three findings on a fifty-line diff. Surface **every real issue**, then rank: confidence decides the tier a finding lands in, **never whether it is reported**. **Input:** an optional target (Step 1). **Output:** one merged, ranked findings list (format below).

**This is the only review entry point** — never a hand-spawned `changes-review` agent or another review command. If the built-in `/code-review` returns nothing because the work is already committed, that means Step 1 must materialize the committed range, not that another reviewer is needed.

## Step 1 — Resolve the diff surface

| Args | Diff you review (Steps 2, 4, 5) | Pass A target (Step 3) |
|------|----------------------------------|------------------------|
| none | working tree: `git diff HEAD` + untracked files | none |
| file paths | `git diff HEAD -- <paths>` | `<paths>` |
| a branch / "this branch" | `git fetch <remote> <branch>` if remote, then `git diff <base>...<head>` | `<branch>` |
| `<base>...<branch>` (a named base) | `git diff <base>...<head>` | `<base>...<head>` |
| a PR number | `gh pr view <n>`, `gh pr diff <n>` | `<n>` |

- **Default base:** `main` (else `master`, else the repo's default branch); honor an explicit base.
- **Three-dot** — `<base>...<head>` is what `<head>` introduced since it diverged (GitHub's "Files changed"); never two-dot, so changes landed on `<base>` don't pollute the review.
- **Read-only.** Fetch — never checkout, pull, commit, reset, or stash; read head-ref files with `git show <head>:<path>` when the branch isn't checked out. A review never mutates the working tree.
- Record the exact range (e.g. `main...origin/feature-x`); every later step reviews that range.

## Step 2 — Anchor to intent; enumerate the surface

1. Read the PR description / commit messages / stated goal, so a deliberate design choice isn't mistaken for a bug; apply the lineage test (every changed line traces to that goal).
2. List **every changed file and changed symbol** in the range — the coverage checklist you're accountable for in Steps 4–5.
3. Read the **full changed files** at the head ref, not just hunks. Map callers and callees of each changed symbol (`codegraph_callers` / `codegraph_impact`) — bugs often live in *unchanged* callers the change invalidated; they are in scope.

## Step 3 — Pass A: precision core

Launch the built-in reviewer at its broadest setting with the Step 1 target: `Skill(skill='code-review', args='max')`, or `args='max <target>'`. Add `--comment` only when asked to post findings on the PR; never `--fix` — reviewing must not mutate the tree. It adversarially verifies each finding (correctness bugs + reuse / simplification / efficiency cleanups). With no target it also covers the branch's commits ahead of upstream — keep any finding outside the Step 1 range, labeled `(outside range)`.

It normally runs as a **background subagent**: carry on with Step 4 while it runs, and never write the output without its findings. If Pass B is done before they arrive, end the turn stating Pass A is pending — its completion notification resumes you. Never predict or fabricate them.

If the skill is refused or unavailable, run the precision pass **yourself** over the Step 1 diff: full changed files at the head ref, the same lens, and each finding adversarially verified before you keep it (for a PR, `gh pr comment` posts findings when asked).

Pass A's findings are verified — carry every one forward; **never re-cull them**.

## Step 4 — Pass B: dimension sweep (where recall is won or lost)

One dimension at a time, each checked against **every** file on the Step 2 list — a coverage matrix, not a skim; collapsing dimensions into one glance is what produces thin reviews.

**Correctness & robustness**

1. **Edge cases** — empty/null/zero inputs, boundaries and off-by-one, unicode/encoding, large inputs, first-run/empty state.
2. **Error paths** — unchecked returns, swallowed exceptions, `try/except` hiding the root cause, partial failure leaving inconsistent state, missing rollback/cleanup on the error branch.
3. **Concurrency & shared state** — races, ordering assumptions, mutable state shared across goroutines/async tasks, non-idempotent retries.
4. **Resource lifecycle** — unclosed handles/connections/files, leaks, missing `finally`/`defer`/context manager, cleanup skipped on early return.
5. **Contracts & compatibility** — a changed function/API/CLI/config signature with callers not updated; a breaking change to a persisted format, wire protocol, or public interface; migration ordering.

**Quality & standards**

6. **Security** — injection, missing authn/authz checks, secrets in code, unvalidated input at system boundaries, unsafe deserialization, SSRF/path traversal.
7. **Performance** — uncached hot paths (render loops, request handlers, polling), N+1 queries, redundant recomputation, heavy imports on a hot path.
8. **YAGNI** — unused abstractions, speculative params/config/hooks, code unreachable from the stated goal; confirm "unused" with a caller search. NEVER suggest adding features nothing calls.
9. **Consistency** — reinvented helpers, divergent idioms, one-off styles; MUST cite the established pattern (`file:line`).
10. **DRY** — duplicated logic or a reimplemented utility; MUST cite the existing implementation (`file:line`).
11. **Tests** — critical paths covered; assertions test behavior, not internals, and a one-character bug would fail them; existing fixtures reused; doubles match the tier (`testing.md` *Test Double Policy* — every violation is `must_fix`); a new dependency (subprocess/I/O) mocked in *all* existing tests of that function.
12. **Standards** — file > 800 lines, function > 50, nesting > 4, `any`/`interface{}` without narrowing, bare `except:`, hardcoded secrets/URLs/config.
13. **Design** — SOLID violations, premature or missing abstraction, inappropriate coupling, persistence models leaking across layers.
14. **Observability** — errors swallowed without logging, context-free error messages, log-level misuse, no signal on the failure branch.
15. **Docs** — every comment, docstring, README, and architecture doc referencing the changed code, directly or indirectly, updated in the change; API/CLI/config changes documented; terminology, counts, and lists accurate; breaking changes called out (`documentation-sync.md`).

**Reporting threshold (the recall lever).** File anything that *might* be an issue, routed by confidence — "not 100% sure" means `suggestion`, not silence. Silence only formatter-owned style and what you actively verified is correct.

## Step 5 — Completeness critic

Before output, audit coverage against the Step 2 checklist:

1. **Zero-finding files/functions** — one line each on why it is genuinely clean; if you can't say, you haven't reviewed it — sweep it now.
2. **Weakest dimension** — the one of the 15 you spent least on; run it once more, deliberately.
3. **Unchecked callers** — any changed symbol whose callers/impact you skipped (Step 2.3); check them now.

## Output — merged, ranked findings

Fold Pass A into Pass B; one list, most severe first; drop exact duplicates (keep the more specific wording). Every finding carries `file:line`; `must_fix` and `should_fix` carry a concrete failure scenario — NEVER a `must_fix` without one.

```
## Findings

### must_fix — breaks correctness or security
- [file:line] Issue — failure scenario (inputs/state → wrong result)

### should_fix — degrades maintainability or coverage, diverges from an established convention, or violates documented standards
- [file:line] Issue — why

### suggestion — optional, or real but lower-confidence
- [file:line] Improvement
```

Say so when a tier is empty ("no `must_fix`"). A clean diff may yield few findings — earned through Step 5, never by skipping the sweep.

## Next Step

- **From `spec-verify` / `spec-bugfix-verify`:** return the findings; that phase applies every `must_fix` and `should_fix` (running affected tests after each) as part of the approved plan.
- **Invoked directly:** report only — ask which findings to address before changing any code.
