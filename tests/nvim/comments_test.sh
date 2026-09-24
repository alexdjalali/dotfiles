#!/usr/bin/env bash
# Text checks that the Neovim config carries no stale commentary, dead plugin
# specs or hand-copied theme colours.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

NVIM_LUA="$REPO_ROOT/nvim/lua"

# Why this test is important:
#   - "4k+ stars" comments go stale and say nothing about why a plugin is here.
# What it tests:
#   - No comment in nvim/lua carries a GitHub star count.
test_no_star_count_comments() {
  local hits
  hits=$(grep -rnE -- '--.*[0-9.]+k?\+? stars' "$NVIM_LUA" | sed "s#$REPO_ROOT/##")
  assert_eq "" "$hits" "star-count comments"
}

# Why this test is important:
#   - A disabled or commented-out plugin spec is dead weight that reads as live.
# What it tests:
#   - The disabled drop.nvim spec and the commented-out wakatime block are gone.
test_no_dead_specs() {
  local hits
  hits=$(grep -rnE 'drop\.nvim|wakatime' "$NVIM_LUA" | sed "s#$REPO_ROOT/##")
  assert_eq "" "$hits" "dead plugin specs"
}

# Why this test is important:
#   - Hex values copied from the Catppuccin palette drift from the theme when
#     the flavour or palette changes.
# What it tests:
#   - plugins/visual.lua has no hardcoded hex colours (it reads the palette API).
test_visual_has_no_hex_colours() {
  local hits
  hits=$(grep -nE '#[0-9a-fA-F]{6}' "$NVIM_LUA/plugins/visual.lua")
  assert_eq "" "$hits" "hex colours in visual.lua"
}

run_test test_no_star_count_comments
run_test test_no_dead_specs
run_test test_visual_has_no_hex_colours
finish
