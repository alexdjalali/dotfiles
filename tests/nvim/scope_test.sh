#!/usr/bin/env bash
# Text checks that the global Neovim config (and the Claude hook scripts) carry
# nothing specific to one project.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

# Project names, credentials and another repo's CI commands in a global config mislead every other repo it runs in.
test_no_project_specific_strings() {
  local hits
  hits=$(grep -rnE -i 'hpc|changeme|bloodhound|ADR-0058|search (lint|typecheck|preflight)' \
    "$REPO_ROOT/nvim" "$REPO_ROOT/.claude/scripts" --exclude=lazy-lock.json | sed "s#$REPO_ROOT/##")
  assert_eq "" "$hits" "project-specific strings"
}

# polish.lua had grown into a feature module (terminals, kubectl helpers) behind a polling loop; it should hold options, autocmds and workarounds.
test_polish_holds_no_features() {
  local hits
  hits=$(grep -nE 'Terminal:new|nvim_create_user_command|defer_fn' "$REPO_ROOT/nvim/lua/polish.lua")
  assert_eq "" "$hits" "feature code in polish.lua"
}

run_test test_no_project_specific_strings
run_test test_polish_holds_no_features
finish
