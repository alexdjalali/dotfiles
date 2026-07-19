---
model: opus
description: Review code changes for correctness, quality, and adherence to standards
---

High-recall, two-pass review. The failure mode this is tuned against is a **thin review** — walking past real issues and returning three findings on a fifty-line diff. The goal is to surface **every real issue**, then rank by severity. Confidence is managed by the severity tier a finding lands in, **never by silently dropping it**. Merge everything into one ranked list.

## Scope

- Args specify files or a PR number → review those
- No args → review the current working-tree diff (staged + unstaged + untracked)

## Step 0 — Anchor to intent and enumerate the surface

Before looking for issues, establish what the change is *for* and what it *touches*:

1. Read the PR description / commit messages / stated goal. Note the intended behavior so you can tell a deliberate design choice from a bug (and apply the lineage test: every changed line should trace to that goal).
2. List **every changed file and every changed symbol**. This list is your coverage checklist for Step 2 and Step 3 — you are accountable for each entry.
3. **Read the full changed files, not just the diff hunks.** Then use CodeGraph/Semble to map callers and callees of each changed symbol (`codegraph_callers` / `codegraph_impact`). Bugs frequently live in *unchanged* callers that the change just invalidated — those are in scope.

## Pass 1 — Built-in core at max coverage

Run the built-in reviewer inline, at the broadest setting:

`Skill(skill='code-review', args='max')`

This is the canonical Claude Code reviewer — it has an effort dial and adversarially verifies each finding before reporting, covering correctness bugs and reuse / simplification / efficiency cleanups. `max` (not `xhigh`) because thin reviews are the failure mode we are fixing and `max` gives the broadest coverage.

- Its findings are already verified and rendered. **Carry every one of them forward into the merged list — do not re-cull them.**
- Pass through flags when relevant: `args='max --comment'` posts findings as inline PR comments; `args='max --fix'` applies them.

## Pass 2 — Dimension sweep (this is where recall is won or lost)

Pass 1 is deliberately precision-biased and will miss whole categories. Pass 2 is the recall pass. Work **one dimension at a time**, and for each dimension check it against **every changed file** from your Step 0 list — a coverage matrix, not a skim. Do not collapse dimensions into a single glance; that is what produces thin reviews.

**Correctness & robustness (beyond Pass 1):**
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

## Step 3 — Completeness critic (defeats the thin-review failure directly)

Before writing output, audit your own coverage against the Step 0 checklist:

1. **Zero-finding files**: which changed files/functions produced *no* finding? For each, state in one line why it is genuinely clean. If you can't, you haven't reviewed it — go back and do the dimension sweep on it.
2. **Weakest dimension**: which of the 15 dimensions did you spend the least on? Run it once more, deliberately.
3. **Unchecked callers**: did you inspect the callers/impact of every changed symbol (Step 0.3)? Name any you skipped and check them now.

Only after this audit do you produce the merged output.

## Output — merged, ranked findings

One list, **ranked most-severe first**. Fold Pass 1's findings in with Pass 2's (drop exact duplicates; keep the more specific wording). Every finding carries `file:line`, and `must_fix`/`should_fix` carry a concrete failure scenario.

```
## Findings

### must_fix
- [file:line] Issue — concrete failure scenario (inputs/state → wrong result)

### should_fix
- [file:line] Issue — why it degrades maintainability, coverage, or diverges from an established convention

### suggestion
- [file:line] Optional or lower-confidence improvement
```

If a tier is empty, say so explicitly (e.g. "no `must_fix`"). A genuinely clean diff yields few findings — but you must have *earned* that via the Step 3 audit, not skipped the sweep.

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
- Do not re-cull Pass 1's verified findings — carry them forward.

## Next Step

Apply all `must_fix` and `should_fix` items. Run the affected tests after each fix.
