#!/usr/bin/env bash
# compact-anchor.sh — Claude Code SessionStart hook (matcher: compact|resume).
#
# After compaction or a resume, the summary may have dropped the state a /spec
# chain needs. This prints a short anchor Claude reads before its next turn:
# the active plan's path and header (Status, SHAs), its progress line, the
# first unchecked task, the git position, and the command to resume. Prints
# nothing (exit 0) when no plan under docs/local/plans/ is still in flight, so
# unrelated sessions see no noise. Degrades without jq: cwd falls back to $PWD.
set -euo pipefail

input=$(cat)

cwd=""
if command -v jq >/dev/null 2>&1; then
  cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null || true)
fi
[ -z "$cwd" ] && cwd="$PWD"

dir="$cwd/docs/local/plans"
[ -d "$dir" ] || exit 0
shopt -s nullglob
files=("$dir"/*.md)
[ ${#files[@]} -eq 0 ] && exit 0

# The newest plan (by mtime) whose Status is not VERIFIED.
plan=""
# shellcheck disable=SC2012  # ls -t on our own plan filenames (no newlines) is the portable mtime sort
while IFS= read -r f; do
  status=$(grep -m1 '^Status:' "$f" 2>/dev/null | sed 's/^Status:[[:space:]]*//' || true)
  if [ "$status" != "VERIFIED" ]; then
    plan="$f"
    break
  fi
done < <(ls -t "${files[@]}")
[ -n "$plan" ] || exit 0

rel="docs/local/plans/$(basename "$plan")"
header=$(grep -E '^(Type|Status|Approved|Iteration|Base|Reviewed|Full gate):' "$plan" | head -7 | tr '\n' '|' | sed 's/|$//; s/|/ · /g')
progress=$(grep -m1 '^\*\*Total:\*\*' "$plan" || true)
next=$(grep -m1 -- '- \[ \]' "$plan" | sed 's/^[[:space:]]*//' || true)

# symbolic-ref names the branch even before the first commit (rev-parse says HEAD).
branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
sha=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)
uncommitted=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

printf '## Context anchor (after compaction / resume)\n'
printf 'Plan: %s\n' "$rel"
[ -n "$header" ] && printf 'Header: %s\n' "$header"
[ -n "$progress" ] && printf 'Progress: %s\n' "$progress"
[ -n "$next" ] && printf 'Next unchecked: %s\n' "$next"
[ -n "$branch" ] && printf 'Git: %s @ %s, %s uncommitted\n' "$branch" "${sha:-no commits}" "${uncommitted:-0}"
printf 'Resume: re-read the plan, then run /spec %s (the phase re-applies its pin).\n' "$rel"
