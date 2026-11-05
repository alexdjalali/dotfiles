#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for the Raycast script commands in raycast/.
#
# Raycast runs each script with the script's own folder as the working
# directory and without the zsh config, so tests run them the same way.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

RAYCAST="$REPO_ROOT/raycast"

# Run a Raycast script as Raycast would: cwd = raycast/, HOME = $T.
raycast() {
  local script=$1
  shift
  (cd "$RAYCAST" && HOME="$T" bash "./$script" "$@" </dev/null)
}

# Why this test is important:
#   - The Raycast status check and the zsh `gca` must agree on what "all
#     projects" means.
# What it tests:
#   - git-status-all.sh reports dirty repos under every PROJECT_ROOTS entry.
test_git_status_all_reads_project_roots() {
  local out
  make_repo "$T/r1/alpha" dirty
  make_repo "$T/r2/beta" dirty
  make_repo "$T/r2/clean"
  out=$(PROJECT_ROOTS="$T/r1:$T/r2" raycast git-status-all.sh)
  assert_contains "$out" "alpha (main) - 1 uncommitted changes" "git-status-all output"
  assert_contains "$out" "beta (main) - 1 uncommitted changes" "git-status-all output"
  assert_not_contains "$out" "clean" "git-status-all output"
}

# Why this test is important:
#   - Opening a project by name should find it in any configured root.
# What it tests:
#   - open-project.sh resolves a project that lives in the second root and
#     asks iTerm to cd into it.
test_open_project_finds_project_in_any_root() {
  mkdir -p "$T/r1" "$T/r2/beta"
  mock_cmd osascript
  PROJECT_ROOTS="$T/r1:$T/r2" raycast open-project.sh beta >/dev/null
  assert_contains "$(cat "$MOCK_DIR/osascript.stdin")" "cd \\\"$T/r2/beta\\\"" "AppleScript sent to iTerm"
}

# Why this test is important:
#   - The query was pasted into Python source, so an apostrophe crashed the
#     script and a crafted query could run arbitrary code.
# What it tests:
#   - search-github.sh opens the URL with the query form-encoded.
test_search_github_encodes_apostrophe() {
  mock_cmd open
  raycast search-github.sh "don't panic" >/dev/null
  assert_eq "https://github.com/search?q=don%27t+panic&type=repositories" "$(mock_calls open)" "URL opened"
}

# Why this test is important:
#   - Same injection bug as search-github.sh.
# What it tests:
#   - search-stackoverflow.sh opens the URL with the query form-encoded.
test_search_stackoverflow_encodes_apostrophe() {
  mock_cmd open
  raycast search-stackoverflow.sh "don't panic" >/dev/null
  assert_eq "https://stackoverflow.com/search?q=don%27t+panic" "$(mock_calls open)" "URL opened"
}

# Why this test is important:
#   - Raycast runs scripts from their own folder, so defaulting to $(pwd)
#     opened Claude Code in the dotfiles raycast/ directory.
# What it tests:
#   - claude-code.sh with no argument asks iTerm to cd into $HOME.
test_claude_code_defaults_to_home() {
  mock_cmd osascript
  raycast claude-code.sh >/dev/null
  assert_contains "$(cat "$MOCK_DIR/osascript.stdin")" "cd \\\"$T\\\"" "AppleScript sent to iTerm"
}

# Why this test is important:
#   - Same working-directory bug as claude-code.sh.
# What it tests:
#   - open-in-nvim.sh with no argument opens $HOME.
test_open_in_nvim_defaults_to_home() {
  mock_cmd osascript
  raycast open-in-nvim.sh >/dev/null
  assert_contains "$(cat "$MOCK_DIR/osascript.stdin")" "nvim \\\"$T\\\"" "AppleScript sent to iTerm"
}

# Why this test is important:
#   - The fallback sent Ctrl+Cmd+D, which is macOS "Look Up", not Do Not
#     Disturb, so the script did something unrelated when the Shortcut failed.
# What it tests:
#   - When the Focus Shortcut is missing, focus-mode.sh, meeting-mode.sh and
#     end-focus-mode.sh send no keystrokes and say how to fix it.
test_focus_scripts_send_no_keystroke() {
  mock_cmd shortcuts "" 1
  mock_cmd osascript
  mock_cmd open
  local s out
  for s in focus-mode.sh meeting-mode.sh end-focus-mode.sh; do
    out=$(raycast "$s")
    assert_contains "$out" "Shortcuts.app" "$s output"
  done
  assert_not_contains "$(mock_calls osascript)" "keystroke" "osascript calls"
}

# Why this test is important:
#   - Raycast never loads zsh, so its scripts kept their own copy of the
#     default roots and ignored the documented ~/.zshrc.local override.
# What it tests:
#   - With PROJECT_ROOTS set only in ~/.zshrc.local, git-status-all.sh scans it.
test_raycast_uses_zshrc_local_roots() {
  make_repo "$T/custom/alpha" dirty
  printf 'export PROJECT_ROOTS="%s/custom"\n' "$T" > "$T/.zshrc.local"
  local out
  out=$(env -u PROJECT_ROOTS bash -c "$(declare -f raycast); RAYCAST='$RAYCAST' T='$T' raycast git-status-all.sh")
  assert_contains "$out" "alpha (main) - 1 uncommitted changes" "git-status-all output"
}

# Why this test is important:
#   - A query that is part of a root's name (proj, dev, Tech) opened the root
#     itself, and depth-2 matches could open a .git directory.
# What it tests:
#   - open-project.sh never resolves to a root or a hidden directory.
test_open_project_fuzzy_never_returns_root() {
  mkdir -p "$T/r1/r1-app" "$T/r1/tool/.git"
  mock_cmd osascript
  PROJECT_ROOTS="$T/r1" raycast open-project.sh r1 >/dev/null
  assert_contains "$(cat "$MOCK_DIR/osascript.stdin")" "cd \\\"$T/r1/r1-app\\\"" "project opened for 'r1'"
  : > "$MOCK_DIR/osascript.stdin"
  PROJECT_ROOTS="$T/r1" raycast open-project.sh git >/dev/null
  assert_not_contains "$(cat "$MOCK_DIR/osascript.stdin")" ".git" "project opened for 'git'"
}

# Why this test is important:
#   - When the scripts can't find zsh/conf.d/01-env.zsh (installed outside the
#     dotfiles checkout), an empty root list made them report nothing at all.
# What it tests:
#   - Copied away from the repo, git-status-all.sh and open-project.sh name the
#     missing 01-env.zsh and exit 1.
test_missing_env_file_is_reported() {
  mkdir -p "$T/elsewhere"
  cp "$RAYCAST/git-status-all.sh" "$RAYCAST/open-project.sh" "$T/elsewhere/"
  local s out rc
  for s in git-status-all.sh open-project.sh; do
    out=$(cd "$T/elsewhere" && HOME="$T" bash "./$s" </dev/null 2>&1)
    rc=$?
    assert_eq 1 "$rc" "$s exit status"
    assert_contains "$out" "01-env.zsh" "$s output"
  done
}

run_test test_git_status_all_reads_project_roots
run_test test_missing_env_file_is_reported
run_test test_open_project_finds_project_in_any_root
run_test test_raycast_uses_zshrc_local_roots
run_test test_open_project_fuzzy_never_returns_root
run_test test_search_github_encodes_apostrophe
run_test test_search_stackoverflow_encodes_apostrophe
run_test test_claude_code_defaults_to_home
run_test test_open_in_nvim_defaults_to_home
run_test test_focus_scripts_send_no_keystroke
finish
