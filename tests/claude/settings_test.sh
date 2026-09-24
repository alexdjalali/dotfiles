#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for the hooks and env block in .claude/settings.json (symlinked to
# ~/.claude/settings.json, so it configures every Claude Code session).
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

SETTINGS="$REPO_ROOT/.claude/settings.json"

# Hook commands as configured, with $HOME/dotfiles pointed at this checkout so
# the tests exercise the scripts under test, not the installed copy.
bash_guard_hooks() {
  jq -r '.hooks.PreToolUse[] | select(.matcher == "Bash") | .hooks[].command' "$SETTINGS" |
    sed "s#\$HOME/dotfiles#$REPO_ROOT#g"
}

lint_hook() {
  jq -r '.hooks.PostToolUse[] | select(.matcher == "Edit") | .hooks[].command' "$SETTINGS" |
    sed "s#\$HOME/dotfiles#$REPO_ROOT#g"
}

# Why this test is important:
#   - The guard only protects sessions if settings.json actually runs it, and an
#     inline copy of the old regexes would silently shadow the tested script.
# What it tests:
#   - A Bash PreToolUse hook invokes guard-bash.sh, and no hook still carries
#     the old inline grep patterns.
test_settings_uses_guard_script() {
  local hooks
  hooks=$(bash_guard_hooks)
  assert_contains "$hooks" "$REPO_ROOT/.claude/scripts/guard-bash.sh" "Bash PreToolUse hooks"
  assert_not_contains "$hooks" "grep -qE" "Bash PreToolUse hooks"
}

# Why this test is important:
#   - Proves the wiring end to end: the exact command Claude Code runs must block.
# What it tests:
#   - The configured guard command, fed a force-push-to-main hook payload, exits 2.
test_configured_guard_blocks_force_push() {
  local cmd rc
  cmd=$(bash_guard_hooks | grep guard-bash.sh)
  jq -cn '{tool_input: {command: "git push -f origin main"}}' |
    bash -c "$cmd" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status of the configured guard"
}

# Why this test is important:
#   - Claude Code blocks only on exit 2. If the launcher is missing (moved, or
#     settings.json synced without the scripts), bash exits 127 and every
#     command would run unchecked.
# What it tests:
#   - The configured guard command exits 2 when guard-bash.sh doesn't exist.
test_configured_guard_fails_closed_without_launcher() {
  local cmd rc
  cmd=$(bash_guard_hooks | grep guard-bash.sh)
  cmd=${cmd//"$REPO_ROOT"/"$T/missing"}
  jq -cn '{tool_input: {command: "git status"}}' | bash -c "$cmd" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status with guard-bash.sh missing"
}

# Why this test is important:
#   - Two effort settings with different precedence invite drift; one source of truth.
# What it tests:
#   - effortLevel is set and the CLAUDE_CODE_EFFORT_LEVEL env override is gone.
test_effort_set_once() {
  assert_eq "xhigh" "$(jq -r '.effortLevel' "$SETTINGS")" "effortLevel"
  assert_eq "null" "$(jq -r '.env.CLAUDE_CODE_EFFORT_LEVEL' "$SETTINGS")" "env CLAUDE_CODE_EFFORT_LEVEL"
}

# Why this test is important:
#   - Flags explicitly set to their documented default are noise that hides the
#     settings that matter.
# What it tests:
#   - The only env flag left at "false" is DISABLE_MICROCOMPACT, the one flag
#     whose parsing is not documented (kept deliberately).
test_no_default_false_flags() {
  assert_eq "DISABLE_MICROCOMPACT" \
    "$(jq -r '.env | to_entries[] | select(.value == "false") | .key' "$SETTINGS")" \
    "env flags set to \"false\""
}

# Why this test is important:
#   - The lint hook should flag what the edit introduced, and Claude only sees
#     PostToolUse feedback written to stderr with exit 2 (stdout with exit 0
#     only reaches the transcript view).
# What it tests:
#   - A new print( in the edit's new_string produces the warning on stderr and
#     exit 2.
test_lint_hook_warns_on_new_print() {
  local rc
  printf 'x = 1\n' > "$T/mod.py"
  jq -cn --arg f "$T/mod.py" '{tool_input: {file_path: $f, new_string: "print(x)"}}' |
    bash -c "$(lint_hook)" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 2 "$rc" "lint hook exit status"
  assert_contains "$(cat "$T/err")" "print() found" "lint hook stderr"
}

# Why this test is important:
#   - Same contract, other side: untouched code must not trigger warnings.
# What it tests:
#   - A file that already contains print( gives exit 0 and no output when the
#     edit's new_string is clean.
test_lint_hook_ignores_preexisting_print() {
  local rc
  printf 'print("old")\n' > "$T/mod.py"
  jq -cn --arg f "$T/mod.py" '{tool_input: {file_path: $f, new_string: "x = 2"}}' |
    bash -c "$(lint_hook)" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 0 "$rc" "lint hook exit status"
  assert_eq "" "$(cat "$T/out" "$T/err")" "lint hook output"
}

# Why this test is important:
#   - A print() that names its stream (file=sys.stderr) is deliberate CLI
#     output; flagging it as debugging pushes Claude to "fix" correct code.
# What it tests:
#   - An edit adding print(..., file=sys.stderr) gives exit 0 and no output.
test_lint_hook_allows_print_with_file() {
  local rc
  printf 'import sys\n' > "$T/cli.py"
  jq -cn --arg f "$T/cli.py" '{tool_input: {file_path: $f, new_string: "print(\"BLOCKED\", file=sys.stderr)"}}' |
    bash -c "$(lint_hook)" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 0 "$rc" "lint hook exit status"
  assert_eq "" "$(cat "$T/out" "$T/err")" "lint hook output"
}

# Why this test is important:
#   - Edit's new_string repeats unchanged context lines; warning about a print()
#     the edit merely kept (now fed to Claude via exit 2) pushes it to "fix"
#     code it didn't touch.
# What it tests:
#   - When old_string and new_string contain the same print(, there is no
#     warning; adding one more print( still warns.
test_lint_hook_counts_only_added_patterns() {
  local rc
  printf 'x = 1\n' > "$T/mod.py"
  jq -cn --arg f "$T/mod.py" '{tool_input: {file_path: $f, old_string: "print(a)\nx = 1", new_string: "print(a)\nx = 2"}}' |
    bash -c "$(lint_hook)" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 0 "$rc" "exit status when print( is only context"
  jq -cn --arg f "$T/mod.py" '{tool_input: {file_path: $f, old_string: "print(a)", new_string: "print(a)\nprint(b)"}}' |
    bash -c "$(lint_hook)" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 2 "$rc" "exit status when a print( is added"
}

run_test test_settings_uses_guard_script
run_test test_configured_guard_blocks_force_push
run_test test_configured_guard_fails_closed_without_launcher
run_test test_effort_set_once
run_test test_no_default_false_flags
run_test test_lint_hook_warns_on_new_print
run_test test_lint_hook_ignores_preexisting_print
run_test test_lint_hook_allows_print_with_file
run_test test_lint_hook_counts_only_added_patterns
finish
