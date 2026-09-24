#!/usr/bin/env bash
# edit-lint.sh
#
# Claude Code PostToolUse hook for the Edit tool. Warns about debugging
# leftovers the edit introduced: print() and bare `except:` in Python,
# console.log and `: any` in TS/JS. A pattern counts only when new_string holds
# more of it than old_string, so unchanged context lines never warn. Warnings go
# to stderr with exit 2, the PostToolUse channel Claude actually sees.
set -uo pipefail

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
new=$(jq -r '.tool_input.new_string // empty' <<<"$input")
old=$(jq -r '.tool_input.old_string // empty' <<<"$input")
[ -n "$file" ] && [ -n "$new" ] || exit 0

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

[ ${#warnings[@]} -eq 0 ] && exit 0
printf 'WARNING: %s\n' "${warnings[@]}" >&2
exit 2
