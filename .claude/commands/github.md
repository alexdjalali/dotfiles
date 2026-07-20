---
model: sonnet
description: Handle branching, committing, pull requests, and merges
---

Git operations for the current work. Always runs `/preflight` before committing.

## Commit

1. Run `/preflight`. If any gate fails, fix and re-run before proceeding.
2. Stage changed files. Never force-add gitignored files.
3. Write a conventional commit message from `~/.claude/templates/commit.md`:
   `<type>(<scope>): <description>`
4. Show the message to the user and confirm before committing.

## Branch

Create a branch named `<type>/<short-description>` where type matches conventional commit types (feat, fix, refactor, chore, etc.).
Ask the user for type and description if not provided in args.

## PR

1. Confirm `/preflight` has passed.
2. Push the current branch: `git push -u origin <branch>`.
3. Draft a PR description using `~/.claude/templates/pr.md` -- summary, changes by area, test plan, linked ADR/story/plan.
4. Show the draft and get approval before creating.
5. Write the approved description to a temp file, then create the PR with the body sourced from that file. The description ALWAYS goes in the PR body -- NEVER pass a multi-line markdown body inline (backticks/`$`/`!` break inline `--body "..."`), and NEVER post the description as a `gh pr comment`:
   ```
   gh pr create --title "<type>(<scope>): <desc>" --body-file /tmp/pr-body.md
   ```
6. Updating an existing PR's description: `gh pr edit <number> --body-file /tmp/pr-body.md`. Never convey the description via `gh pr comment`.

## Merge

1. Confirm the PR is approved and CI is green: `gh pr view --json statusCheckRollup`.
2. Merge: `gh pr merge --squash` (default) or `--merge` if the user requests.
3. Delete the remote branch after merge.

## Rules

- NEVER commit without `/preflight` passing first
- NEVER force-push to main or master
- NEVER auto-create a branch -- ask the user for name and type
- NEVER push without showing and confirming the commit message
- The PR description belongs in the PR **body** (`gh pr create --body-file` / `gh pr edit --body-file`). NEVER put the description or summary in a top-level PR comment (`gh pr comment`) -- comments are for review replies, not the description.
