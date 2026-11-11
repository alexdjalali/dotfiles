#!/usr/bin/env bash
# guard-docs.sh
#
# Claude Code PreToolUse hook for Bash. Docs are the first priority: a
# `git commit` whose changes touch code but refresh no docs at all goes to the
# user's permission prompt (an "ask" decision, hook_lib.sh); the user's
# approval is the override. Any of these counts as a doc refresh:
#   - a Markdown / reStructuredText file (README, docs/, CLAUDE.md, ADRs, …);
#   - an added or removed comment line in a code file (doc comments, test
#     "Why this test is important / What it tests" blocks, docstrings).
# A commit with truly no doc impact declares it in its message with
# `Docs-Impact: none (<reason>)`, where review can see and judge it.
#
# Which commits: guard_bash.py --commit-dirs parses the command as the shell
# would and lists the repo of each `git commit`, following `cd` / `pushd`,
# wrappers (`env`, `rtk`, …) and git's `-C` / `-c` options. What is judged in
# each: the staged changes; when the same command also runs `git add` (or
# `commit -a`), the working-tree changes too, since they are about to be
# committed.
#
# The hook fails toward the prompt: a payload it cannot read, or a missing jq
# or python3, asks rather than letting the commit through unseen.
set -uo pipefail

here=${BASH_SOURCE[0]%/*}
[[ $here == "${BASH_SOURCE[0]}" ]] && here=.
# shellcheck source=hook_lib.sh
source "$here/hook_lib.sh" || exit 2

payload=""
hook_payload guard-docs payload
cmd=$(jq -r '.tool_input.command // ""' <<<"$payload")

# Cheap pre-filter: most Bash calls never mention a commit.
[[ $cmd == *commit* ]] || exit 0
command -v python3 >/dev/null 2>&1 || hook_ask guard-docs "needs python3 to find the commits in the command, so it was not checked"
dirs=$(python3 "$here/guard_bash.py" --commit-dirs <<<"$payload" 2>/dev/null) ||
  hook_ask guard-docs "could not parse the command to find its commits, so it was not checked"
[[ -n $dirs ]] || exit 0

# A declared no-impact commit passes; the declaration is the reviewable record.
[[ $cmd == *"Docs-Impact:"* ]] && exit 0

# Whether this command stages the working tree before committing.
stages_tree=false
add_re='(^|[^[:alnum:]_.-])add([[:space:]]|$)'
all_re='commit[[:space:]].*(-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)'
[[ $cmd =~ $add_re || $cmd =~ $all_re ]] && stages_tree=true

code_re='\.(go|py|pyi|ts|tsx|js|jsx|mjs|cjs|sh|bash|zsh|lua|rs|java|kt|rb|tf|proto)$'
doc_re='\.(md|mdx|rst|adoc)$'
# A comment line: //, # (not a shebang), /*, a * continuation (`* ` or `*/`
# or a bare `*`), a docstring quote, or `-- ` (SQL / Lua).
comment_re='^[+-][[:space:]]*(//|#([^!]|$)|/\*|\*([[:space:]/]|$)|"""|--([[:space:]]|$))'

# docs_refreshed <repo>: whether the commit about to be made in repo touches
# no code, or refreshes a doc file or a comment line alongside it.
docs_refreshed() {
  local dir=$1 diff files
  git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || return 0
  # The diff about to be committed: staged, plus the working tree when this
  # command stages it (`git add`, `commit -a` / `-am` / `--all`).
  diff=$(git -C "$dir" diff --cached --no-color --unified=0 2>/dev/null)
  files=$(git -C "$dir" diff --cached --name-only 2>/dev/null)
  if $stages_tree; then
    diff+=$'\n'$(git -C "$dir" diff --no-color --unified=0 2>/dev/null)
    files+=$'\n'$(git -C "$dir" diff --name-only 2>/dev/null)
    files+=$'\n'$(git -C "$dir" ls-files --others --exclude-standard 2>/dev/null)
  fi
  grep -Eq "$code_re" <<<"$files" || return 0
  grep -Eq "$doc_re" <<<"$files" && return 0
  # A changed comment line in a code file counts as a doc refresh; the
  # ---/+++ file headers are not changes.
  grep -Ev '^(\+\+\+|---) ' <<<"$diff" | grep -Eq "$comment_re"
}

while IFS= read -r dir; do
  docs_refreshed "$dir" || hook_ask guard-docs "this commit changes code but refreshes no docs. Docs are the first priority: update the doc comments, test docs (Why this test is important / What it tests), README, docs/ pages and CLAUDE.md that describe the changed code, then commit them together. If the change truly has no doc impact, say so in the message: Docs-Impact: none (<reason>)."
done <<<"$dirs"
exit 0
