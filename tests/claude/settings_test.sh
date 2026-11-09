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

# The Edit|Write PreToolUse hook commands, with $HOME/dotfiles pointed at this
# checkout.
generated_guard_hooks() {
  jq -r '.hooks.PreToolUse[] | select(.matcher == "Edit|Write") | .hooks[].command' "$SETTINGS" |
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

# Why this test is important:
#   - The anchor only helps if compaction actually triggers it, and the 200K
#     auto-compact window is what keeps long /spec sessions from growing to
#     the 1M-window models' ~967K default before compacting, since every turn
#     re-sends the whole context.
# What it tests:
#   - A SessionStart hook matching "compact" runs compact-anchor.sh, and
#     autoCompactWindow is 200000 (the Compact instructions in CLAUDE.md assume 200K).
test_compact_anchor_hook_wired() {
  local hooks
  hooks=$(jq -r '.hooks.SessionStart[] | select(.matcher != null and (.matcher | test("compact"))) | .hooks[].command' "$SETTINGS" |
    sed "s#\$HOME/dotfiles#$REPO_ROOT#g")
  assert_contains "$hooks" "$REPO_ROOT/.claude/scripts/compact-anchor.sh" "SessionStart compact hook"
  assert_eq 200000 "$(jq -r '.autoCompactWindow' "$SETTINGS")" "autoCompactWindow"
}

# Why this test is important:
#   - The edit guard only stops hand edits to generated files if Claude Code
#     runs it before every Edit and Write.
# What it tests:
#   - A PreToolUse hook with matcher Edit|Write invokes guard-generated.sh.
test_settings_registers_generated_guard() {
  assert_contains "$(generated_guard_hooks)" "$REPO_ROOT/.claude/scripts/guard-generated.sh" "Edit|Write PreToolUse hooks"
}

# Why this test is important:
#   - Proves the wiring end to end: the exact configured command must block.
# What it tests:
#   - The configured command, fed an Edit payload for a generated file, exits 2.
test_configured_generated_guard_blocks() {
  local cmd rc
  cmd=$(generated_guard_hooks | grep guard-generated.sh)
  printf '// Code generated by wire. DO NOT EDIT.\n' > "$T/wire_gen.go"
  jq -cn --arg p "$T/wire_gen.go" '{tool_input: {file_path: $p}}' | bash -c "$cmd" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status of the configured edit guard"
}

# Why this test is important:
#   - The suppression guard only stops agents from silencing checks if Claude
#     Code actually runs it before every Edit and Write.
# What it tests:
#   - The Edit|Write PreToolUse hooks include guard-suppressions.sh, and the
#     exact configured command exits 2 on an Edit that adds a //nolint.
test_configured_suppression_guard_blocks() {
  local cmd rc
  cmd=$(generated_guard_hooks | grep guard-suppressions.sh)
  assert_contains "$cmd" "$REPO_ROOT/.claude/scripts/guard-suppressions.sh" "Edit|Write PreToolUse hooks"
  jq -cn --arg p "$T/a.go" '{tool_input: {file_path: $p, old_string: "f()", new_string: "f() //nolint"}}' |
    bash -c "$cmd" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status of the configured suppression guard"
}

# Why this test is important:
#   - Docs are the first priority; the commit guard only enforces that if
#     Claude Code runs it before every Bash command.
# What it tests:
#   - A Bash PreToolUse hook invokes guard-docs.sh, and the exact configured
#     command blocks a code-only commit in a fresh repo.
test_configured_docs_guard_blocks() {
  local cmd rc
  cmd=$(bash_guard_hooks | grep guard-docs.sh)
  assert_contains "$cmd" "$REPO_ROOT/.claude/scripts/guard-docs.sh" "Bash PreToolUse hooks"
  make_repo "$T/r"
  printf 'package a\n' > "$T/r/a.go"
  git -C "$T/r" add a.go
  jq -cn --arg d "$T/r" '{tool_input: {command: "git commit -m x"}, cwd: $d}' | bash -c "$cmd" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status of the configured docs guard"
}

run_test test_configured_docs_guard_blocks
run_test test_configured_suppression_guard_blocks
run_test test_compact_anchor_hook_wired
run_test test_settings_uses_guard_script
run_test test_configured_guard_blocks_force_push
run_test test_configured_guard_fails_closed_without_launcher
run_test test_effort_set_once
run_test test_no_default_false_flags
run_test test_lint_hook_warns_on_new_print
run_test test_lint_hook_ignores_preexisting_print
run_test test_lint_hook_allows_print_with_file
run_test test_lint_hook_counts_only_added_patterns
run_test test_settings_registers_generated_guard
run_test test_configured_generated_guard_blocks
finish
