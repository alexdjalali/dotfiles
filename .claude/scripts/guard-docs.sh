#!/usr/bin/env bash
# guard-docs.sh
#
# Claude Code PreToolUse hook for Bash. Docs are the first priority: it blocks
# a `git commit` whose changes touch code but refresh no docs at all. Any of
# these counts as a doc refresh:
#   - a Markdown / reStructuredText file (README, docs/, CLAUDE.md, ADRs, …);
#   - an added or changed comment line in a code file (doc comments, test
#     "Why this test is important / What it tests" blocks, docstrings).
# A commit with truly no doc impact declares it in its message with
# `Docs-Impact: none (<reason>)`, where review can see and judge it.
#
# What is judged: the staged changes; when the same command also runs
# `git add` (or `commit -a`), the working-tree changes too, since they are
# about to be committed. The repo is the payload's cwd, or `git -C <dir>`.
#
# The hook fails closed: a payload it cannot read, or a missing jq, blocks
# with exit 2, the only status Claude Code treats as a block.
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: guard-docs.sh needs jq to read the hook payload" >&2
  exit 2
fi
if ! payload=$(jq -ec '.' 2>/dev/null); then
  echo "BLOCKED: guard-docs.sh could not read the hook payload" >&2
  exit 2
fi
cmd=$(jq -r '.tool_input.command // ""' <<<"$payload")
dir=$(jq -r '.cwd // ""' <<<"$payload")
[[ -n $dir ]] || dir=$PWD

# Only a git commit is judged.
commit_re='(^|[;&|(]|[[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)'
[[ $cmd =~ $commit_re ]] || exit 0
if [[ $cmd =~ git[[:space:]]+-C[[:space:]]+([^[:space:]]+)[[:space:]]+commit ]]; then
  c=${BASH_REMATCH[1]}
  c=${c/#\~/$HOME}
  [[ $c == /* ]] && dir=$c || dir=$dir/$c
fi
git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

# A declared no-impact commit passes; the declaration is the reviewable record.
[[ $cmd == *"Docs-Impact:"* ]] && exit 0

# The diff about to be committed: staged, plus the working tree when this
# command stages it (`git add`, `commit -a` / `-am` / `--all`).
diff=$(git -C "$dir" diff --cached --no-color --unified=0 2>/dev/null)
files=$(git -C "$dir" diff --cached --name-only 2>/dev/null)
if [[ $cmd =~ git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add([[:space:]]|$) || $cmd =~ commit[[:space:]]+(-[a-zA-Z]*a|--all) ]]; then
  diff+=$'\n'$(git -C "$dir" diff --no-color --unified=0 2>/dev/null)
  files+=$'\n'$(git -C "$dir" diff --name-only 2>/dev/null)
  files+=$'\n'$(git -C "$dir" ls-files --others --exclude-standard 2>/dev/null)
fi

code_re='\.(go|py|pyi|ts|tsx|js|jsx|mjs|cjs|sh|bash|zsh|lua|rs|java|kt|rb|tf|proto)$'
doc_re='\.(md|mdx|rst|adoc)$'
grep -Eq "$code_re" <<<"$files" || exit 0
grep -Eq "$doc_re" <<<"$files" && exit 0

# A changed comment line in a code file counts as a doc refresh.
if grep -E '^[+-][^+-]' <<<"$diff" | grep -Eq '^[+-][[:space:]]*(//|#[^!]|#$|/\*|\*|"""|--)'; then
  exit 0
fi

echo "BLOCKED: this commit changes code but refreshes no docs. Docs are the first priority: update the doc comments, test docs (Why this test is important / What it tests), README, docs/ pages and CLAUDE.md that describe the changed code, then commit them together. If the change truly has no doc impact, say so in the message: Docs-Impact: none (<reason>)." >&2
exit 2
