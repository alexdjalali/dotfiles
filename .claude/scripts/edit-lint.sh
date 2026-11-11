#!/usr/bin/env bash
# edit-lint.sh
#
# Claude Code PostToolUse hook for Edit and Write. In order, so lint always
# sees the formatted file:
#   1. Formats the file: ruff format (.py), gofumpt (.go), prettier (JS/TS).
#   2. Runs the project's own linter on it, only where the project configures
#      one (the nearest config at or above the file):
#        .py      ruff check <file>          pyproject.toml with [tool.ruff],
#                                            ruff.toml, .ruff.toml
#        .go      golangci-lint run ./<pkg>  .golangci.{yml,yaml,toml,json};
#                                            run from the go.mod directory
#        JS/TS    node_modules/.bin/eslint   eslint.config.* / .eslintrc*;
#                                            only the project's own binary
#      Type checking stays with the LSP tool and the fast checks: a per-edit
#      basedpyright or tsc run costs seconds on every edit.
#   3. Warns about debugging leftovers the edit introduced: print() and bare
#      `except:` in Python, console.log and `: any` in TS/JS. A pattern counts
#      only when the new text holds more of it than the old text, so unchanged
#      context lines never warn: an Edit's old_string, or for a Write the file
#      it replaced (tool_response.originalFile, null on create; the field is
#      what Claude Code returns, not a documented hook contract, so without it
#      a Write is judged against an empty file). This covers repos with no
#      linter config.
# Findings go to stderr with exit 2, the PostToolUse channel Claude actually
# sees, so a violation is fixed on the next edit instead of at the pre-commit
# fast checks. Each linter's output is capped at MAX_LINES lines.
set -uo pipefail

MAX_LINES=40

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
new=$(jq -r '.tool_input.new_string // .tool_input.content // empty' <<<"$input")
old=$(jq -r '.tool_input.old_string // .tool_response.originalFile? // empty' <<<"$input")
[ -n "$file" ] && [ -f "$file" ] || exit 0
dir=$(cd "$(dirname "$file")" && pwd) || exit 0

# The nearest directory at or above $1 holding one of the files $2..., else
# fails. A pyproject.toml counts only when it configures ruff.
find_up() {
  local d=$1 name
  shift
  while :; do
    for name in "$@"; do
      [ -f "$d/$name" ] || continue
      if [ "$name" = pyproject.toml ] && ! grep -q '^\[tool\.ruff' "$d/$name"; then
        continue
      fi
      printf '%s\n' "$d"
      return 0
    done
    [ "$d" = / ] && return 1
    d=$(dirname "$d")
  done
}

findings=()
# Runs "$@" in directory $1; a non-zero exit records its capped output.
lint() {
  local in=$1 out
  shift
  out=$(cd "$in" && "$@" 2>&1) && return 0
  findings+=("$(printf '%s\n' "$out" | head -n "$MAX_LINES")")
}

ESLINT_CONFIGS=(eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts
  eslint.config.mts eslint.config.cts .eslintrc.js .eslintrc.cjs .eslintrc.json
  .eslintrc.yml .eslintrc.yaml .eslintrc)

case "$file" in
  *.py)
    command -v ruff >/dev/null && ruff format --quiet "$file" 2>/dev/null
    if root=$(find_up "$dir" pyproject.toml ruff.toml .ruff.toml); then
      lint "$root" ruff check --quiet --output-format concise --force-exclude "$file"
    fi
    ;;
  *.go)
    command -v gofumpt >/dev/null && gofumpt -w "$file" 2>/dev/null
    if find_up "$dir" .golangci.yml .golangci.yaml .golangci.toml .golangci.json >/dev/null &&
      mod=$(find_up "$dir" go.mod); then
      pkg=${dir#"$mod"}
      lint "$mod" golangci-lint run "./${pkg#/}"
    fi
    ;;
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.mts | *.cts)
    command -v prettier >/dev/null && prettier --write --log-level silent "$file" 2>/dev/null
    if root=$(find_up "$dir" "${ESLINT_CONFIGS[@]}") && [ -x "$root/node_modules/.bin/eslint" ]; then
      lint "$root" "$root/node_modules/.bin/eslint" "$file"
    fi
    ;;
esac

# Lines of $1 matching the ERE $2, minus lines matching the ERE $3.
count() { printf '%s\n' "$1" | grep -E -- "$2" | grep -Evc -- "$3"; }
added() { [ "$(count "$new" "$1" "$2")" -gt "$(count "$old" "$1" "$2")" ]; }

warnings=()
case "$file" in
  *.py)
    added 'print\(' '#.*print|logging|file=' && warnings+=("print() found - use structured logging instead")
    added 'except:' '#' && warnings+=("bare except: found - catch specific exceptions")
    ;;
  *.ts | *.tsx | *.js | *.jsx)
    added 'console\.log' '//.*console' && warnings+=("console.log found - remove before committing")
    added ': any' '//' && warnings+=("any type found - use unknown + type guards")
    ;;
esac

[ ${#findings[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ] && exit 0
if [ ${#findings[@]} -gt 0 ]; then
  printf 'LINT: the project linter flags %s - fix the code (no suppressions); if this edit is one step of a larger change, finish it first:\n' "$file" >&2
  printf '%s\n' "${findings[@]}" >&2
fi
[ ${#warnings[@]} -gt 0 ] && printf 'WARNING: %s\n' "${warnings[@]}" >&2
exit 2
