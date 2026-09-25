---
name: review-diff
model: claude-fable-5-1
effort: xhigh
context: fork
agent: general-purpose
background: false
description: Review a diff (working tree, branch vs base, ref range, or PR number) for correctness, quality, and standards — one high-recall pass on Fable. Use when asked to review changes, a branch, a commit range, or a PR; the front door for every code review, including /spec verify.
argument-hint: "[deep] [<paths> | <branch> | <base>...<branch> | <PR number>]"
---

**Target:** `$ARGUMENTS` (empty → the working tree). One high-recall pass on Fable, in a forked context: you see only this skill and the target — resolve everything from the repo, and make your **final message the Output section verbatim**, nothing else, so the caller receives the findings intact. Surface **every real issue**; confidence decides a finding's tier, never whether it's reported. **Output:** one ranked findings list. This is the only review entry point — never a hand-spawned `changes-review` agent. **Each file is read once and reviewed once** — no re-sweeps.

## 1 — Resolve the range

| Args | Diff |
|------|------|
| none | `git diff HEAD` + untracked files |
| paths | `git diff HEAD -- <paths>` |
| a branch | `git fetch` if remote, then `git diff <base>...<head>` |
| `<base>...<head>` | `git diff <base>...<head>` |
| PR number | `gh pr view <n>`, `gh pr diff <n>` |
| `plan=<path>` (extra token) | read that plan for intent and the `Trivial:` claims |

Default base `main` (else `master`, else the default branch). Always three-dot. **Read-only** — fetch only; read head-ref files with `git show <head>:<path>`; never checkout, pull, commit, reset, or stash.

## 2 — Intent and surface

Read the goal (PR description / commit messages / plan) so deliberate choices aren't flagged, and apply the lineage test. List every changed file and symbol — your coverage checklist. Read each changed file in full at the head ref, and its changed symbols' callers (`codegraph_callers` / `codegraph_impact`) — bugs live in unchanged callers too.

## 3 — Review each file once, against every lens

- **Correctness:** edge cases (empty/zero/boundaries/unicode/large/first-run) · error paths (unchecked returns, swallowed exceptions, partial failure without rollback) · concurrency and shared state · resource lifecycle (leaks, cleanup skipped on early return) · contracts (changed signatures with stale callers, breaking persisted/wire formats, migration order).
- **Tests changed?** Read `~/.claude/rules/testing-authoring.md` first (it loads only when *editing* tests) and the project's `.claude/rules/testing-project.md` if present.
- **Quality:** security (injection, authn/z, secrets, unvalidated boundary input, SSRF/path traversal) · performance (uncached hot paths, N+1, redundant work) · YAGNI (confirm "unused" with a caller search) · consistency and DRY (MUST cite the existing pattern/implementation `file:line`) · tests (`testing.md`: behavior assertions a one-character bug would fail, tier-correct doubles — a violation is `must_fix` — parsimony, new deps mocked in all existing tests) · standards (file > 800, function > 50, nesting > 4, untyped `any`, bare `except:`, hardcoded config) · design (coupling, leaking layers, premature/missing abstraction) · observability (silent failure branches, context-free errors) · docs (`documentation-sync.md`).

File anything that *might* be an issue — "not sure" means `suggestion`, not silence. Before keeping a `must_fix`, try to refute it against the code; keep it only if it survives.

## 4 — Close out

One line per zero-finding file saying why it's clean — you can't write the line without having reviewed it. No second sweep.

## `deep` (opt-in, costly)

Only when args include `deep`: also run `Skill(skill='code-review', args='max <target>')` (a multi-agent adversarial pass; never `--fix`) and fold its findings in unculled. It runs in the background — never write the output without its findings, never fabricate them.

## Output

One list, most severe first, exact duplicates dropped; every finding has `file:line`; `must_fix` / `should_fix` carry a concrete failure scenario.

```
## Findings
### must_fix — breaks correctness or security
- [file:line] Issue — failure scenario (inputs/state → wrong result)
### should_fix — maintainability, coverage, convention, documented standards
- [file:line] Issue — why
### suggestion — optional, or real but lower-confidence
- [file:line] Improvement
```

Say so when a tier is empty. The caller decides what happens next: `spec-verify` turns `must_fix` / `should_fix` into one fix commit; a user who typed `/review-diff` is asked which findings to address.
