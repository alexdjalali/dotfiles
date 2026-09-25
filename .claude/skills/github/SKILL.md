---
name: github
model: sonnet
effort: low
description: Ship the current work — commit, create a branch, push and open or update a PR, or merge — fast checks before a commit, the full gate once after it, confirming every git write. User-typed only.
argument-hint: "[commit | branch <type>/<desc> | pr | merge]"
disable-model-invocation: true
---

The manual ship step: user-typed only (other skills suggest it, never run it). **Input:** the subcommand in args (ask if absent). **Output:** the confirmed git/GitHub operation, done. Every git write below happens only after the user confirms that step, and `development-practices.md` *Git* applies throughout.

## Commit

1. Fast checks on the changed files — skip if the skill that produced the change (`/fix`, `/sync-docs`, `spec-implement`) already ran them green and nothing changed since; otherwise run them, fix, re-run until green.
2. Draft a conventional commit message from `~/.claude/templates/commit.md` — `<type>(<scope>): <description>`, scope optional.
3. Show the files to stage (`git status --short`) and the message; confirm.
4. Stage them (never `git add -f` a gitignored file) and commit everything staged as-is.
5. **Then** run the full gate once at the new HEAD — commit first, gate second. Red → fix, and commit the fix (confirmed) before re-running it; never push on red.

## Branch

Create `<type>/<short-description>`, the type a conventional-commit type (feat, fix, refactor, chore, …). Take type and description from args, or ask — never invent them.

## PR

1. The full gate must be green at HEAD: skip it when a `/spec` plan's `Full gate:` or an earlier run this session already recorded green at this SHA; otherwise run it once now.
2. Draft the description from `~/.claude/templates/pr.md` — summary, changes by area, test plan, linked ADR / story / plan (plans are local-only: name them, don't link).
3. Show the title, description, and push target; get approval.
4. Push (`git push -u origin <branch>`), write the approved description to a temp file, and create the PR from it:
   ```
   gh pr create --title "<type>(<scope>): <desc>" --body-file /tmp/pr-body.md
   ```
   Update an existing PR's description with `gh pr edit <number> --body-file /tmp/pr-body.md`.

## Merge

1. Check approval and CI: `gh pr view <number> --json reviewDecision,statusCheckRollup`.
2. Ask the user to confirm the merge (PR number, strategy); only then `gh pr merge --squash` (default) or `--merge` on request.
3. Ask again before deleting the remote branch.

## Rules

- NEVER commit with a red fast check; NEVER push with the full gate red or unrun at HEAD. NEVER run the full gate twice on the same SHA.
- NEVER force-push to main or master.
- NEVER auto-create a branch — ask the user for its type and name.
- NEVER push without showing and confirming the commit message.
- NEVER merge a PR or delete a remote branch without the user's explicit confirmation for that step.
- The PR description goes in the PR **body** (`--body-file`) — NEVER inline as a multi-line `--body "…"` (backticks, `$`, `!` break it), and NEVER as a top-level `gh pr comment` (comments are for review replies).

## Next Step

More work open → `/rfp status`.
