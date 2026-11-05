#!/usr/bin/env bash
# Size check for the in-editor guides: a few prose pages, not a keymap dump.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

# Why this test is important:
#   - The 1,573-line cheatsheet re-typed every keymap by hand; which-key now
#     renders the keymaps, so the file only holds the workflow pages.
# What it tests:
#   - nvim/lua/plugins/cheatsheet.lua is under 300 lines.
test_cheatsheet_under_300_lines() {
  local n
  n=$(wc -l <"$REPO_ROOT/nvim/lua/plugins/cheatsheet.lua")
  ((n < 300)) || _fail "cheatsheet.lua has $n lines"
}

run_test test_cheatsheet_under_300_lines
finish
