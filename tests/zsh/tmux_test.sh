#!/usr/bin/env bash
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

# Load .tmux.conf into a private server and print the output of tmux "$@" run
# against it. TPM's `run` lines are skipped, so no plugin clone happens.
tmux_query() {
  local sock="$T/q.sock" conf="$T/tmux.conf" out
  grep -v "tpm" "$TMUX_CONF" >"$conf"
  out=$(tmux -S "$sock" -f /dev/null new-session -d \; source-file "$conf" \; "$@" 2>&1)
  tmux -S "$sock" kill-server 2>/dev/null
  printf '%s\n' "$out"
}

# Why this test is important:
#   - Neovim's smart-splits moves between its splits on Ctrl-h/j/k/l and hands
#     off to tmux at the edge; without matching root bindings the keys never
#     cross from an nvim split into a neighbouring tmux pane.
# What it tests:
#   - Ctrl-h/j/k/l in the root table forward to Neovim panes (@pane-is-vim)
#     and select the neighbouring tmux pane otherwise.
test_ctrl_hjkl_cross_nvim_and_tmux() {
  local key dir out
  for key in h:L j:D k:U l:R; do
    dir=${key#*:}
    out=$(tmux_query list-keys -T root "C-${key%%:*}")
    assert_contains "$out" "@pane-is-vim" "C-${key%%:*} checks @pane-is-vim"
    assert_contains "$out" "select-pane -$dir" "C-${key%%:*} falls back to select-pane -$dir"
  done
}

# Why this test is important:
#   - Programs in a pane (Neovim, image previews, OSC 8 links) talk to iTerm
#     through escape sequences that tmux drops unless passthrough is allowed.
# What it tests:
#   - allow-passthrough is on.
test_allow_passthrough_on() {
  local out
  out=$(tmux_query show-options -gv allow-passthrough)
  assert_eq "on" "$out" "allow-passthrough"
}

run_test test_no_global_env_assignments
run_test test_config_parses
run_test test_ctrl_hjkl_cross_nvim_and_tmux
run_test test_allow_passthrough_on
finish
