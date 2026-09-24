#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/statusline.sh, the Claude Code status line.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

STATUSLINE="$REPO_ROOT/.claude/scripts/statusline.sh"

# Status line for a payload whose workspace is a fresh git repo in $T.
render() {
  git -C "$T" init -q
  jq -cn --arg d "$T" "$1 | .workspace.current_dir = \$d" | bash "$STATUSLINE"
}

# Why this test is important:
#   - The ⚡ segment claims to show the reasoning effort; showing the output
#     style name there mislabels it.
# What it tests:
#   - A payload with an output style but no effort renders no ⚡ segment.
test_no_effort_segment_without_effort() {
  local out
  out=$(render '{model: {display_name: "Opus"}, output_style: {name: "default"}}')
  assert_not_contains "$out" "⚡" "status line"
}

# Why this test is important:
#   - Claude Code sends effort as an object ({level: ...}); printing it raw put
#     three lines of JSON into the footer of every Opus session.
# What it tests:
#   - The real payload shape renders "⚡ xhigh" on a single line, and the plain
#     string form still works.
test_effort_segment_with_effort() {
  local out
  out=$(render '{model: {display_name: "Opus"}, effort: {level: "xhigh"}}')
  assert_contains "$out" "⚡ xhigh" "status line"
  assert_eq 1 "$(printf '%s\n' "$out" | grep -c .)" "status line row count"
  out=$(render '{model: {display_name: "Opus"}, effort: "high"}')
  assert_contains "$out" "⚡ high" "status line (string effort)"
}

# Why this test is important:
#   - The header promises graceful degradation; a status line that exits 127
#     blanks the footer on a machine without jq.
# What it tests:
#   - With no jq on PATH it still prints the directory and exits 0.
test_degrades_without_jq() {
  local bin="$T/nojq" out rc
  mkdir -p "$bin"
  ln -s "$(command -v git)" "$bin/git"
  ln -s /usr/bin/basename "$bin/basename"
  ln -s /bin/cat "$bin/cat"
  out=$(cd "$T" && printf '{}' | PATH="$bin" /bin/bash "$STATUSLINE")
  rc=$?
  assert_eq 0 "$rc" "exit status without jq"
  assert_contains "$out" "📁" "status line without jq"
}

run_test test_no_effort_segment_without_effort
run_test test_effort_segment_with_effort
run_test test_degrades_without_jq
finish
