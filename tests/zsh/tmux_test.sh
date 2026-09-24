#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for tmux/.tmux.conf.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

TMUX_CONF="$REPO_ROOT/tmux/.tmux.conf"

# Why this test is important:
#   - In tmux, a top-level NAME=value line sets the global environment, which
#     every new pane's shell inherits; config-only variables leak into all shells.
# What it tests:
#   - .tmux.conf contains no top-level NAME=value assignment.
test_no_global_env_assignments() {
  local found
  found=$(grep -nE '^[A-Za-z_][A-Za-z0-9_]*=' "$TMUX_CONF")
  assert_eq "" "$found" "global environment assignments in .tmux.conf"
}

# Why this test is important:
#   - A syntax error in .tmux.conf silently drops every setting after it.
# What it tests:
#   - tmux parses the file without errors (parse-only, so no TPM network clone).
test_config_parses() {
  local sock="$T/tmux.sock" out rc
  out=$(tmux -S "$sock" -f /dev/null start-server \; source-file -n "$TMUX_CONF" 2>&1)
  rc=$?
  tmux -S "$sock" kill-server 2>/dev/null
  assert_eq 0 "$rc" "tmux source-file -n exit status ($out)"
}

run_test test_no_global_env_assignments
run_test test_config_parses
finish
