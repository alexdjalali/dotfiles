---
model: sonnet
description: Ship the current work — commit, create a branch, push and open or update a PR, or merge — running the quality gates first and confirming every git write. User-typed only.
argument-hint: "[commit | branch <type>/<desc> | pr | merge]"
disable-model-invocation: true
---

The manual ship step: user-typed only (other skills suggest it, never run it). **Input:** the subcommand in args (ask if absent). **Output:** the confirmed git/GitHub operation, done. Every git write below happens only after the user confirms that step, and `development-practices.md` *Git Operations* applies throughout.

## Commit

1. Run the quality gates (CLAUDE.md *Quality Gates*) — fix and re-run until every gate passes.
2. Draft a conventional commit message from `~/.claude/templates/commit.md` — `<type>(<scope>): <description>`, scope optional.
3. Show the files to stage (`git status --short`) and the message; confirm.
4. Stage them (never `git add -f` a gitignored file) and commit everything staged as-is.

## Branch

Create `<type>/<short-description>`, the type a conventional-commit type (feat, fix, refactor, chore, …). Take type and description from args, or ask — never invent them.

## PR

1. Confirm the quality gates passed for the commits being shipped.
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

- NEVER commit without the quality gates passing first.
- NEVER force-push to main or master.
- NEVER auto-create a branch — ask the user for its type and name.
- NEVER push without showing and confirming the commit message.
- NEVER merge a PR or delete a remote branch without the user's explicit confirmation for that step.
- The PR description goes in the PR **body** (`--body-file`) — NEVER inline as a multi-line `--body "…"` (backticks, `$`, `!` break it), and NEVER as a top-level `gh pr comment` (comments are for review replies).

## Next Step

After a merge that ships a user-visible epic or story → suggest `/demo` to record the end-to-end walkthrough. More work open → `/program-status`.
