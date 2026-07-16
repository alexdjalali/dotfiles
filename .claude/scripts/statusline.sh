#!/usr/bin/env bash
# statusline.sh — Claude Code status line.
# Receives a JSON payload on stdin; prints one line for the terminal footer.
# Shows: current dir · git branch (+dirty flag) · model · effort · permission mode.
# Degrades gracefully if jq is missing or fields are absent.
set -euo pipefail

input=$(cat)

field() { printf '%s' "$input" | jq -r "$1 // \"\"" 2>/dev/null; }

dir=$(field '.workspace.current_dir')
[ -z "$dir" ] && dir=$(field '.cwd')
[ -z "$dir" ] && dir="$PWD"
model=$(field '.model.display_name')
[ -z "$model" ] && model=$(field '.model.id')
effort=$(field '.effort')
[ -z "$effort" ] && effort=$(field '.output_style.name')
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
