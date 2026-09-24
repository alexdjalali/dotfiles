#!/usr/bin/env bash
# guard-bash.sh
#
# Claude Code PreToolUse hook for the Bash tool. The session runs with
# bypassPermissions, so this is the only backstop against destructive commands.
# It blocks:
#   - force-pushes (or deletes) of main/master, including a bare `git push -f`
#     while main is checked out; any `git push --mirror`; a forced --all
#   - recursive rm of /, ~, $HOME, or an ancestor of $HOME, including relative
#     targets such as `*` run from the home directory
#   - git reset --hard, git checkout of paths (or -f), git switch
#     --discard-changes / -f, git restore of the working tree, git clean -f
#
# Scope: this catches *accidental* destructive commands, the ones a model or a
# tired human actually types. It is not a sandbox against deliberate evasion.
# Known unhandled spellings: git's abbreviated long options (`--har`),
# character-class or brace globs (`rm -rf ~/[a-z]*`, `~/{*,.*}`), home paths
# spelled through `..` or odd casing beyond simple case folding, `env -S` with
# its string attached (`-S'…'`, `--split-string=…`), an escaped backslash before
# a line break (`\\` + newline), a `$(...)` inside double quotes after a `cd`
# in the same command (checked against the starting directory), and a heredoc
# fed to a quoted shell name (`"$SHELL" <<EOF`, `ssh host 'bash -s' <<EOF`).
#
# The rules and the shell-aware parsing live in guard_bash.py, run by the first
# python3 on PATH (3.9 or newer). This launcher exists so the hook fails closed:
# Claude Code blocks only on exit 2, so any other failure (python3 missing, a
# broken pyenv shim, a too-old interpreter, a crash) would otherwise let every
# command through. It therefore maps every non-zero status to 2, and the hook
# command in settings.json adds `|| exit 2` in case this file itself is missing.
if ! command -v python3 >/dev/null 2>&1; then
  echo "BLOCKED: guard-bash.sh needs python3 to inspect commands" >&2
  exit 2
fi
python3 "$(dirname "${BASH_SOURCE[0]}")/guard_bash.py"
status=$?
if [ "$status" -ne 0 ] && [ "$status" -ne 2 ]; then
  echo "BLOCKED: the command guard failed (exit $status), so the command was not checked" >&2
  exit 2
fi
exit "$status"
