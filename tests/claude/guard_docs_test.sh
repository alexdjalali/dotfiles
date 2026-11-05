#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/guard-docs.sh, the Bash PreToolUse hook that blocks
# a `git commit` changing code without refreshing any docs, doc comments or
# test docs, unless the message declares `Docs-Impact: none (<reason>)`.
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

# Exit status of the guard for Bash command $1 run from $T/r.
guard_status() {
  jq -cn --arg c "$1" --arg d "$T/r" '{tool_name: "Bash", tool_input: {command: $c}, cwd: $d}' |
    bash "$GUARD" >/dev/null 2>&1
  echo $?
}

# Why this test is important:
#   - Stale docs are what agents read first; a commit that changes behavior
#     without touching any doc leaves the next agent working from a wrong map.
# What it tests:
#   - A commit staging only a code-body change (no comment, no doc file)
#     exits 2, and the reason names Docs-Impact as the declared way out.
test_blocks_code_without_docs() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq 2 "$(guard_status 'git commit -m "fix: return 2"')" "code-only commit"
  local err
  err=$(jq -cn --arg c 'git commit -m x' --arg d "$T/r" '{tool_input: {command: $c}, cwd: $d}' |
    bash "$GUARD" 2>&1 >/dev/null)
  assert_contains "$err" "Docs-Impact" "reason names the declaration"
}

# Why this test is important:
#   - Doc comments and test docs are docs; refreshing them must count, or the
#     guard pushes agents toward Markdown churn instead of better comments.
# What it tests:
#   - A commit whose code change also edits a comment line exits 0.
test_allows_doc_comment_refresh() {
  setup_repo
  printf 'package a\n\n// F returns two, the new default.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq 0 "$(guard_status 'git commit -m "fix: return 2"')" "comment refreshed"
}

# Why this test is important:
#   - Updating a README, a docs/ page or a CLAUDE.md alongside the code is
#     the main way docs stay current.
# What it tests:
#   - A commit staging a code change plus a Markdown file exits 0.
test_allows_markdown_with_code() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 2 }\n' > "$T/r/a.go"
  printf '# A\nF returns 2.\n' > "$T/r/README.md"
  git -C "$T/r" add a.go README.md
  assert_eq 0 "$(guard_status 'git commit -m "fix: return 2"')" "markdown staged"
}

# Why this test is important:
#   - Some changes truly have no doc impact (a pure internal refactor); the
#     author must say so in the commit, where review can see and judge it.
# What it tests:
#   - A code-only commit whose message carries `Docs-Impact: none (...)`
#     exits 0.
test_allows_declared_no_impact() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 1 + 0 }\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  assert_eq 0 "$(guard_status 'git commit -m "refactor: simplify" -m "Docs-Impact: none (internal expression only)"')" "declared"
}

# Why this test is important:
#   - Agents usually stage and commit in one command; judging only what is
#     already staged would wave the code through or block the docs.
# What it tests:
#   - `git add -A && git commit` judges the working-tree changes: code alone
#     exits 2, code plus a doc exits 0.
test_judges_add_and_commit_together() {
  setup_repo
  printf 'package a\n\n// F does a thing.\nfunc F() int { return 3 }\n' > "$T/r/a.go"
  assert_eq 2 "$(guard_status 'git add -A && git commit -m "fix: 3"')" "code only"
  printf 'F returns 3.\n' > "$T/r/NOTES.md"
  assert_eq 0 "$(guard_status 'git add -A && git commit -m "fix: 3"')" "code plus doc"
}

# Why this test is important:
#   - The guard runs on every Bash call; anything that is not a commit, or a
#     commit with no code in it, must pass untouched.
# What it tests:
#   - A non-git command, and a commit staging only a Markdown file, exit 0.
test_ignores_non_commits_and_docs_only() {
  setup_repo
  assert_eq 0 "$(guard_status 'ls -la')" "non-git command"
  printf '# A\n' > "$T/r/README.md"
  git -C "$T/r" add README.md
  assert_eq 0 "$(guard_status 'git commit -m "docs: readme"')" "docs-only commit"
}

# Why this test is important:
#   - A guard that allows what it cannot read fails open.
# What it tests:
#   - Malformed JSON exits 2.
test_blocks_bad_json() {
  printf 'not json' | bash "$GUARD" >/dev/null 2>&1
  assert_eq 2 "$?" "exit for malformed payload"
}

run_test test_blocks_code_without_docs
run_test test_allows_doc_comment_refresh
run_test test_allows_markdown_with_code
run_test test_allows_declared_no_impact
run_test test_judges_add_and_commit_together
run_test test_ignores_non_commits_and_docs_only
run_test test_blocks_bad_json
finish
