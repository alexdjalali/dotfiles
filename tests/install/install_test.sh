#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for install.sh, sourced into a throwaway HOME with every external
# command it runs replaced by a mock, so nothing touches brew, the network or
# the real home directory.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

# The real git, for reading tracked files after `git` itself is mocked.
REAL_GIT=$(command -v git)

# Mock the external commands install.sh runs, then source it (or a copy at $1)
# with HOME=$T/home.
load_install() {
  local script=${1:-$REPO_ROOT/install.sh} cmd
  for cmd in xcode-select brew curl sudo chsh git nvim uv bat defaults latexmk tee; do
    mock_cmd "$cmd"
  done
  export HOME="$T/home"
  mkdir -p "$HOME"
  # shellcheck source=../../install.sh
  source "$script" </dev/null
}

# Why this test is important:
#   - The tests (and anyone reusing a helper) source install.sh; if sourcing ran
#     the installer it would brew, curl and relink the machine it runs on.
# What it tests:
#   - Sourcing install.sh defines its functions but runs no external command
#     and creates nothing in HOME.
test_sourcing_runs_nothing() {
  load_install
  assert_eq "function" "$(type -t main)" "main after sourcing"
  assert_eq "" "$(cat "$MOCK_DIR"/*.calls 2>/dev/null)" "external commands run while sourcing"
  assert_eq "" "$(ls -A "$HOME")" "files created in HOME while sourcing"
}

# Why this test is important:
#   - install.sh is re-run with --update on every machine; a second run must not
#     pile up backups of links it made itself.
# What it tests:
#   - backup_and_link creates the link, and a second call leaves it alone with
#     no backup directory.
test_backup_and_link_is_idempotent() {
  load_install
  : > "$T/src"
  backup_and_link "$T/src" "$HOME/.cfg" >/dev/null
  backup_and_link "$T/src" "$HOME/.cfg" >/dev/null
  assert_eq "$T/src" "$(readlink "$HOME/.cfg")" "link target"
  [[ -e "$HOME/.dotfiles-backup" ]] && _fail "a backup was made on the second run"
  return 0
}

# Why this test is important:
#   - A fresh machine already has some of these files; linking must not destroy them.
# What it tests:
#   - An existing regular file is moved into the backup directory before the link
#     replaces it.
test_backup_and_link_backs_up_existing_file() {
  load_install
  : > "$T/src"
  echo mine > "$HOME/.cfg"
  backup_and_link "$T/src" "$HOME/.cfg" >/dev/null
  assert_eq "$T/src" "$(readlink "$HOME/.cfg")" "link target"
  assert_eq "mine" "$(cat "$HOME"/.dotfiles-backup/*/.cfg)" "backed-up content"
}

# Why this test is important:
#   - A hardcoded ~/dotfiles links every file to the wrong place when the repo
#     is cloned anywhere else.
# What it tests:
#   - DOTFILES is the directory install.sh itself lives in.
test_dotfiles_dir_derived_from_script_location() {
  mkdir -p "$T/elsewhere"
  cp "$REPO_ROOT/install.sh" "$T/elsewhere/install.sh"
  load_install "$T/elsewhere/install.sh"
  assert_eq "$T/elsewhere" "$DOTFILES" "DOTFILES"
}

# Why this test is important:
#   - The old bootstrap printed "ok" after `|| true`, so a broken plugin install
#     looked like success; and `Lazy! sync` moved every plugin past the lockfile.
# What it tests:
#   - bootstrap_nvim installs the locked versions (`Lazy! restore`) and, when
#     nvim exits non-zero, prints a warning and no "ok".
test_nvim_bootstrap_failure_is_reported() {
  load_install
  mock_cmd nvim "" 1
  local out
  out=$(bootstrap_nvim 2>&1)
  assert_contains "$(mock_calls nvim)" "Lazy! restore" "nvim bootstrap command"
  assert_contains "$out" "[warn]" "bootstrap output"
  assert_not_contains "$out" "[ok]" "bootstrap output"
}

# Why this test is important:
#   - Under `set -e` a missing bat aborted the whole install at the theme step.
# What it tests:
#   - With no bat on PATH, the theme step warns and the script carries on.
test_missing_bat_does_not_abort() {
  load_install
  command rm -f "$MOCK_BIN/bat"
  local out
  out=$(PATH="$MOCK_BIN:/usr/bin:/bin" bash -c 'set -e; source "$1" </dev/null; setup_bat_theme; echo reached' _ "$REPO_ROOT/install.sh" 2>&1)
  assert_contains "$out" "[warn]" "theme step output"
  assert_contains "$out" "reached" "script continued after the theme step"
}

# Why this test is important:
#   - Links from older layouts point at directories that no longer exist (or,
#     for Cursor's skills, that Cursor now manages itself).
# What it tests:
#   - remove_legacy_links deletes the ~/.claude/commands, ~/.claude/standards and
#     ~/.cursor/skills-cursor symlinks, and leaves a real directory alone.
test_legacy_links_removed() {
  load_install
  mkdir -p "$HOME/.claude" "$HOME/.cursor" "$HOME/.cursor/rules-real"
  ln -s "$T/gone" "$HOME/.claude/commands"
  ln -s "$T/gone" "$HOME/.claude/standards"
  ln -s "$T/gone" "$HOME/.cursor/skills-cursor"
  remove_legacy_links >/dev/null
  local link
  for link in .claude/commands .claude/standards .cursor/skills-cursor; do
    [[ -L "$HOME/$link" ]] && _fail "$link still linked"
  done
  [[ -d "$HOME/.cursor/rules-real" ]] || _fail "a real directory was removed"
}

# Why this test is important:
#   - The uv tool list must match what the editor and `just lint` actually use;
#     mypy has no consumer in the nvim config.
# What it tests:
#   - install_uv_tools installs basedpyright and ruff, and not mypy.
test_uv_tools_match_consumers() {
  load_install
  install_uv_tools >/dev/null
  local calls
  calls=$(mock_calls uv)
  assert_contains "$calls" "tool install basedpyright" "uv calls"
  assert_contains "$calls" "tool install ruff" "uv calls"
  assert_not_contains "$calls" "mypy" "uv calls"
}

# Why this test is important:
#   - ~/.gitconfig links to the tracked file, so whatever `git lfs install`
#     writes shows up as a repo diff after every install; `--skip-smudge`
#     rewrote the tracked [filter "lfs"].
# What it tests:
#   - The lfs step runs plain `git lfs install`, and the tracked filter holds
#     exactly the values that command writes.
test_git_lfs_step_matches_tracked_config() {
  load_install
  mock_cmd git-lfs
  setup_git_lfs >/dev/null
  assert_eq "lfs install" "$(mock_calls git)" "git calls"
  local cfg="$REPO_ROOT/git/.gitconfig"
  assert_eq "git-lfs smudge -- %f" "$("$REAL_GIT" config -f "$cfg" filter.lfs.smudge)" "filter.lfs.smudge"
  assert_eq "git-lfs filter-process" "$("$REAL_GIT" config -f "$cfg" filter.lfs.process)" "filter.lfs.process"
}

run_test test_sourcing_runs_nothing
run_test test_backup_and_link_is_idempotent
run_test test_backup_and_link_backs_up_existing_file
run_test test_dotfiles_dir_derived_from_script_location
run_test test_nvim_bootstrap_failure_is_reported
run_test test_missing_bat_does_not_abort
run_test test_legacy_links_removed
run_test test_uv_tools_match_consumers
run_test test_git_lfs_step_matches_tracked_config
finish
