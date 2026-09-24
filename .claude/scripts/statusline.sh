#!/usr/bin/env bash
# statusline.sh — Claude Code status line.
# Receives a JSON payload on stdin; prints one line for the terminal footer.
# Shows: current dir · git branch (+dirty flag) · model · effort · permission mode.
# Degrades gracefully if jq is missing or fields are absent.
set -euo pipefail

input=$(cat)

# Prints "" for absent fields, and for every field when jq is missing.
field() {
  command -v jq >/dev/null 2>&1 || return 0
  printf '%s' "$input" | jq -r "$1 // \"\"" 2>/dev/null || true
}

dir=$(field '.workspace.current_dir')
[ -z "$dir" ] && dir=$(field '.cwd')
[ -z "$dir" ] && dir="$PWD"
model=$(field '.model.display_name')
[ -z "$model" ] && model=$(field '.model.id')
# Claude Code sends {"level": "..."}; accept a plain string too.
effort=$(field '.effort | if type == "object" then .level else . end')
mode=$(field '.permission_mode')

base=$(basename "$dir")
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
dirty=""
if [ -n "$branch" ] && ! git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  dirty="*"
fi

out="📁 ${base}"
[ -n "$branch" ] && out="${out}  ⎇ ${branch}${dirty}"
[ -n "$model" ]  && out="${out}  🤖 ${model}"
[ -n "$effort" ] && out="${out}  ⚡ ${effort}"
[ -n "$mode" ] && [ "$mode" != "default" ] && out="${out}  🔓 ${mode}"

printf '%s' "$out"
