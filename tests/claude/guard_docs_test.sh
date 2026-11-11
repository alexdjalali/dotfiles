#!/usr/bin/env bash
# Tests for .claude/scripts/guard-docs.sh, the Bash PreToolUse hook that asks
# the user before a `git commit` changing code without refreshing any docs,
# doc comments or test docs, unless the message declares
# `Docs-Impact: none (<reason>)`.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GUARD="$REPO_ROOT/.claude/scripts/guard-docs.sh"

# A repo at $T/r with one committed Go file, so later edits show as changes.
setup_repo() {
  make_repo "$T/r"
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 1 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  git -C "$T/r" -c user.email=t@t -c user.name=t commit -qm init
}

# The guard's verdict (ask / pass) for Bash command $1 run from ${2:-$T/r}.
guard_status() {
  jq -cn --arg c "$1" --arg d "${2:-$T/r}" '{tool_name: "Bash", tool_input: {command: $c}, cwd: $d}' |
    verdict bash "$GUARD"
}

# Stage a code-body change (no comment, no doc file) in $T/r.
stage_code_only() {
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
}

# Why this test is important:
#   - Stale docs are what agents read first; a commit that changes behavior
#     without touching any doc leaves the next agent working from a wrong map.
# What it tests:
#   - A commit staging only a code-body change (no comment, no doc file)
#     gets an "ask" decision whose reason names Docs-Impact as the declared
#     way out.
test_asks_code_without_docs() {
  setup_repo
  stage_code_only
  assert_eq ask "$(guard_status 'git commit -m "fix: return 2"')" "code-only commit"
  local out
  out=$(jq -cn --arg c 'git commit -m x' --arg d "$T/r" '{tool_input: {command: $c}, cwd: $d}' |
    bash "$GUARD" 2>/dev/null)
  assert_contains "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<<"$out")" "Docs-Impact" "reason names the declaration"
}

# Why this test is important:
#   - The commit to judge is rarely typed bare: agents cd into a repo first,
#     pass `-c` options, or wrap git (`rtk git commit`). A regex on the raw
#     text missed each of these, letting a doc-less commit through.
# What it tests:
#   - `cd r && git commit`, `git -c k=v commit`, `git -C r commit` run from
#     the parent, and `env X=1 git commit` all ask for a code-only change.
test_finds_commits_behind_cd_options_and_wrappers() {
  setup_repo
  stage_code_only
  assert_eq ask "$(guard_status 'cd r && git commit -m x' "$T")" "cd then commit"
  assert_eq ask "$(guard_status 'git -c user.name=t commit -m x')" "-c option"
  assert_eq ask "$(guard_status 'git -C r commit -m x' "$T")" "-C from the parent"
  assert_eq ask "$(guard_status 'env X=1 git commit -m x')" "env wrapper"
}

# Why this test is important:
#   - Only a real comment counts as a doc refresh; matching any line that
#     starts with `*` or `--` let arithmetic and decrements pass as docs.
# What it tests:
#   - A code-only change whose added lines start with `*p = 1` or `--i`
#     still asks.
test_code_resembling_comments_is_not_docs() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F(p *int) int {\n*p = 1\nreturn 1 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq ask "$(guard_status 'git commit -m x')" "pointer write"
  printf 'x=1\n--x\n' > "$T/r/b.sh"
  git -C "$T/r" add b.sh
  assert_eq ask "$(guard_status 'git commit -m x')" "decrement"
}

# Why this test is important:
#   - Doc comments and test docs are docs; refreshing them must count, or the
#     guard pushes agents toward Markdown churn instead of better comments.
# What it tests:
#   - A commit whose code change also edits a comment line passes.
test_allows_doc_comment_refresh() {
  setup_repo
  printf 'package a\n\n// F returns two, the new default.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq pass "$(guard_status 'git commit -m "fix: return 2"')" "comment refreshed"
}

# Why this test is important:
#   - Updating a README, a docs/ page or a CLAUDE.md alongside the code is
#     the main way docs stay current.
# What it tests:
#   - A commit staging a code change plus a Markdown file passes.
test_allows_markdown_with_code() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  printf '# A\nF returns 2.\n' > "$T/r/README.md"
  git -C "$T/r" add a.go README.md
  assert_eq pass "$(guard_status 'git commit -m "fix: return 2"')" "markdown staged"
}

# Why this test is important:
#   - Some changes truly have no doc impact (a pure internal refactor); the
#     author must say so in the commit, where review can see and judge it.
# What it tests:
#   - A code-only commit whose message carries `Docs-Impact: none (...)`
#     passes.
test_allows_declared_no_impact() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 1 + 0 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq pass "$(guard_status 'git commit -m "refactor: simplify" -m "Docs-Impact: none (internal expression only)"')" "declared"
}

# Why this test is important:
#   - Agents usually stage and commit in one command; judging only what is
#     already staged would wave the code through or block the docs.
# What it tests:
#   - `git add -A && git commit` judges the working-tree changes: code alone
#     asks, code plus a doc passes.
test_judges_add_and_commit_together() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 3 }\n' > "$T/r/a.go"
  assert_eq ask "$(guard_status 'git add -A && git commit -m "fix: 3"')" "code only"
  printf 'F returns 3.\n' > "$T/r/NOTES.md"
  assert_eq pass "$(guard_status 'git add -A && git commit -m "fix: 3"')" "code plus doc"
}

# Why this test is important:
#   - The guard runs on every Bash call; anything that is not a commit, or a
#     commit with no code in it, must pass untouched.
# What it tests:
#   - A non-git command, and a commit staging only a Markdown file, pass.
test_ignores_non_commits_and_docs_only() {
  setup_repo
  assert_eq pass "$(guard_status 'ls -la')" "non-git command"
  printf '# A\n' > "$T/r/README.md"
  git -C "$T/r" add README.md
  assert_eq pass "$(guard_status 'git commit -m "docs: readme"')" "docs-only commit"
}

# Why this test is important:
#   - A guard that allows what it cannot read fails open.
# What it tests:
#   - Malformed JSON gets an "ask" decision.
test_asks_on_bad_json() {
  assert_eq ask "$(printf 'not json' | verdict bash "$GUARD")" "malformed payload"
}

run_test test_asks_code_without_docs
run_test test_finds_commits_behind_cd_options_and_wrappers
run_test test_code_resembling_comments_is_not_docs
run_test test_allows_doc_comment_refresh
run_test test_allows_markdown_with_code
run_test test_allows_declared_no_impact
run_test test_judges_add_and_commit_together
run_test test_ignores_non_commits_and_docs_only
run_test test_asks_on_bad_json
finish
