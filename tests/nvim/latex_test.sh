#!/usr/bin/env bash
# Text checks for the LaTeX build configuration: latex/.latexmkrc is the one
# place latexmk flags live, and shell escape is a per-project opt-in.
# shellcheck disable=SC2016  # latexmk variables ($max_repeat, $silent) are literal text
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

LATEXMKRC="$REPO_ROOT/latex/.latexmkrc"

# Why this test is important:
#   - -shell-escape lets any document run shell commands at build time; on for
#     every document, opening an untrusted .tex runs its code.
# What it tests:
#   - No active (uncommented) latexmkrc line enables -shell-escape, and the
#     dead $silent branch and default-valued $max_repeat are gone.
test_latexmkrc_no_global_shell_escape() {
  local active
  active=$(grep -vE '^\s*#' "$LATEXMKRC")
  assert_not_contains "$active" "-shell-escape" "active latexmkrc lines"
  assert_not_contains "$active" '$max_repeat' "active latexmkrc lines"
  assert_not_contains "$active" '$silent' "active latexmkrc lines"
}

# Why this test is important:
#   - The same flags in three places (latexmkrc, VimTeX, texlab) drift apart and
#     let one editor build differ from another.
# What it tests:
#   - The Neovim config passes none of latexmk's -pdf/-synctex/-interaction/
#     -shell-escape flags; latexmkrc sets them.
test_flags_defined_once() {
  local hits
  hits=$(grep -rnE -- '"-(pdf|synctex=1|interaction=nonstopmode|shell-escape)"' "$REPO_ROOT/nvim/lua" | sed "s#$REPO_ROOT/##")
  assert_eq "" "$hits" "latexmk flags in the Neovim config"
  assert_contains "$(cat "$LATEXMKRC")" "-synctex=1" "latexmkrc flags"
}

run_test test_latexmkrc_no_global_shell_escape
run_test test_flags_defined_once
finish
