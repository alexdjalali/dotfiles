---
model: sonnet
---

# GitHub — Full Git Flow

Branch, commit, PR, review, and merge workflow. Integrates with the spec pipeline and uses the GitHub MCP server when available.

## Arguments
$ARGUMENTS — One of:
- `branch <name>` — Create and switch to a feature branch
- `commit` — Stage, validate, and commit with conventional format
- `pr` — Create a pull request from current branch
- `pr <number>` — View/update an existing PR
- `review <number>` — Review a pull request
- `merge <number>` — Merge a pull request
- `status` — Git + PR dashboard

## Instructions

### 0. Determine Mode

```
IF $ARGUMENTS starts with "branch":
    → Mode: BRANCH

ELIF $ARGUMENTS == "commit":
    → Mode: COMMIT

ELIF $ARGUMENTS == "pr" (no number):
    → Mode: PR_CREATE

ELIF $ARGUMENTS matches "pr <number>":
    → Mode: PR_VIEW

ELIF $ARGUMENTS starts with "review":
    → Mode: PR_REVIEW

ELIF $ARGUMENTS starts with "merge":
    → Mode: MERGE

ELIF $ARGUMENTS == "status":
    → Mode: STATUS

ELSE:
    → Ask user what they want to do
```

---

## Mode: BRANCH — Create Feature Branch

### Step 1: Determine Branch Name

If a name is provided, validate it follows the convention:
```
<type>/<short-description>
```
Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

If no name is provided, check for pipeline context:
1. Check for an in-progress story in `docs/spec/stories/` → derive name from story slug
2. Check for an in-progress plan in `docs/spec/plans/` → derive name from plan slug
3. Ask user for a branch name

### Step 2: Create Branch

```bash
git checkout -b <branch-name>
```

Report: branch created, what it's based on, and the upstream tracking.

### Step 3: Pipeline Link

If the branch was derived from a story or plan, note this for later PR creation:
- The PR description will auto-link to the story/plan

---

## Mode: COMMIT — Stage and Commit

### Step 1: Run Preflight

Delegate to `/preflight` to run quality gates on changed files:
```
Skill(skill='preflight')
```

If preflight fails, fix issues before continuing.

### Step 2: Review Changes

```bash
git status --short
git diff --stat
git diff --cached --stat
```

Show the user what will be committed. If nothing is staged, ask what to stage.

### Step 3: Stage Files

Stage the appropriate files. Be selective — never blindly `git add -A`:
- Exclude `.env`, credentials, large binaries
- Ask user to confirm if staging looks unexpected

### Step 4: Compose Commit Message

Read the commit template: `Read(file_path="~/.claude/templates/commit.md")`

Analyze the staged changes to determine:
1. **Type**: What kind of change is this? (feat, fix, refactor, etc.)
2. **Scope**: What module/area does it touch? (optional)
3. **Subject**: Imperative, concise summary (max 72 chars)
4. **Body**: WHY this change was made (not what — the diff shows what)
5. **Footer**: Issue references, breaking changes

Draft the message and present it to the user for approval.

### Step 5: Commit

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<body>

<footer>
EOF
)"
```

### Step 6: Next Step

Use AskUserQuestion:

```
question: "Commit created. What's next?"
header: "Pipeline"
options:
  - "/github pr — Create a pull request" - Push and open a PR for this branch
  - "Push only" - Push to remote without creating a PR
  - "Done — Stay local" - Don't push yet
```

- PR: `Skill(skill='github', args='pr')`
- Push: `git push -u origin HEAD`
- Done: End workflow

---

## Mode: PR_CREATE — Create Pull Request

### Step 1: Ensure Branch is Pushed

```bash
git push -u origin HEAD
```

### Step 2: Gather Context

1. Check `git log main..HEAD --oneline` for all commits on this branch
2. Check `git diff main...HEAD --stat` for all changed files
3. Scan `docs/spec/` for related artifacts:
   - Plans in `docs/spec/plans/` matching the branch slug
   - Stories in `docs/spec/stories/` referenced by plans
   - Epics in `docs/spec/epics/` referenced by stories
   - ADRs in `docs/adr/` referenced by plans
4. Read the PR template: `Read(file_path="~/.claude/templates/pr.md")`

### Step 3: Compose PR Description

Using the template, fill in:
- **Title**: `<type>(<scope>): <description>` (from commits or branch name)
- **Summary**: What and WHY (1-3 bullets)
- **Changes**: Grouped by area, with file paths
- **References**: Links to spec pipeline artifacts (if found in Step 2)
- **Test Plan**: Based on what tests were added/modified

### Step 4: Create PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<pr-body>
EOF
)"
```

Or use the GitHub MCP server if available for richer integration.

### Step 5: Report

Output the PR URL and summary.

---

## Mode: PR_VIEW — View/Update PR

### Step 1: Fetch PR Details

```bash
gh pr view <number>
```

Or use GitHub MCP: `get_pull_request(owner, repo, pullNumber)`

### Step 2: Show Status

Report:
- Title, description, author
- Review status (approvals, requested changes)
- CI check status
- Merge conflicts
- Comments

---

## Mode: PR_REVIEW — Review a Pull Request

### Step 1: Fetch PR

```bash
gh pr view <number>
gh pr diff <number>
```

Or use GitHub MCP for structured access to PR files, comments, and review threads.

### Step 2: Checkout PR Locally

```bash
gh pr checkout <number>
```

### Step 3: Delegate to /review

The `/review` skill handles the actual code analysis:

```
Skill(skill='review')
```

This runs automated checks (lint, type check, format) and performs manual code review against the project's coding standards and patterns.

### Step 4: Check Pipeline Artifacts

If the PR references spec pipeline artifacts (plan, story, ADR):
1. Read the plan file — verify all tasks are marked complete
2. Read the story — verify acceptance criteria are met
3. Check the plan status — should be VERIFIED

### Step 5: Submit Review

Based on `/review` findings and pipeline artifact checks:

```bash
gh pr review <number> --approve --body "<review-comments>"
# or
gh pr review <number> --request-changes --body "<review-comments>"
# or
gh pr review <number> --comment --body "<review-comments>"
```

Format the review body:

```markdown
## Review Summary

### Automated Checks
- Lint: PASS/FAIL
- Type Check: PASS/FAIL
- Tests: PASS/FAIL

### Code Review
<findings from /review>

### Pipeline Status
- Plan: VERIFIED / NOT VERIFIED
- Story: Complete / Incomplete
- Acceptance Criteria: Met / Not Met

### Verdict
APPROVE / REQUEST CHANGES
```

---

## Mode: MERGE — Merge Pull Request

### Step 1: Pre-Merge Checks

```bash
gh pr checks <number>
gh pr view <number> --json reviewDecision,mergeable,statusCheckRollup
```

Verify:
- [ ] All CI checks pass
- [ ] At least one approval (no outstanding requested changes)
- [ ] No merge conflicts
- [ ] Branch is up to date with base

### Step 2: Merge

```bash
gh pr merge <number> --squash --delete-branch
```

Use squash merge by default to keep history clean. The squash commit message should follow conventional commit format.

### Step 3: Clean Up

```bash
git checkout main
git pull
```

### Step 4: Post-Merge Pipeline Update

If the PR was for a story:
1. Verify the story status is `Complete` in `docs/spec/stories/`
2. Check if all stories in the parent epic are complete
3. If epic complete, update epic status

---

## Mode: STATUS — Dashboard

### Step 1: Local Git Status

```bash
git status --short
git log --oneline -5
git branch -vv
```

### Step 2: Open PRs

```bash
gh pr list --author @me
gh pr list --reviewer @me
```

Or use GitHub MCP: `list_pull_requests(owner, repo)`

### Step 3: Report

```
## Git & GitHub Status

### Local
Branch: <current-branch>
Ahead/Behind: <ahead>/<behind> of origin
Uncommitted: <count> files

### My Open PRs
| # | Title | Status | Checks | Reviews |
|---|-------|--------|--------|---------|

### PRs Awaiting My Review
| # | Title | Author | Age |
|---|-------|--------|-----|

### Recent Commits
<last 5 commits>
```

---

## Rules
- NEVER force-push to main/master
- NEVER commit secrets, credentials, .env files, or large binaries
- NEVER skip the preflight quality gate before committing
- ALWAYS use conventional commit format
- ALWAYS use squash merge for PRs (keeps history clean)
- ALWAYS delete feature branches after merge
- Branch names MUST follow `<type>/<short-description>` convention
- PR titles MUST follow conventional commit format
