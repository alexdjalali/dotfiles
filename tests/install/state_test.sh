#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# shellcheck disable=SC2016  # zsh code is passed to zsh_with unexpanded on purpose
# Tests for the tracked config install.sh sets up: git, the iTerm prefs and the
# Neovim plugin lockfile. Real local tools (git, plutil, zsh, nvim) run
# against throwaway copies; nothing touches the real $HOME.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"
# shellcheck source=../lib/zsh.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/zsh.sh"

PLIST="$REPO_ROOT/iterm/com.googlecode.iterm2.plist"

# A throwaway HOME whose ~/.gitconfig links to a copy of the tracked file.
home_with_gitconfig() {
  export HOME="$T/home"
  mkdir -p "$HOME"
  cp "$REPO_ROOT/git/.gitconfig" "$T/gitconfig"
  ln -s "$T/gitconfig" "$HOME/.gitconfig"
}

# Why this test is important:
#   - Identity and signing keys differ per machine; editing the tracked file for
#     them leaves the repo permanently dirty.
# What it tests:
#   - A ~/.gitconfig.local value overrides the tracked one; conflicts use zdiff3;
#     the gh credential helper is found on PATH, not at a Homebrew path.
test_gitconfig_local_overrides_and_settings() {
  home_with_gitconfig
  printf '[user]\n\temail = local@example.com\n' > "$HOME/.gitconfig.local"
  # Read the way git itself does (all files, includes followed), outside any repo.
  cd "$T" || return 1
  assert_eq "local@example.com" "$(git config user.email)" "user.email with a local override"
  assert_eq "zdiff3" "$(git config merge.conflictstyle)" "merge.conflictstyle"
  assert_not_contains "$(git config --get-all credential.https://github.com.helper)" "/opt/homebrew" "gh credential helper"
}

# Why this test is important:
#   - iTerm loads its prefs from iterm/ when pointed at the folder; a file that
#     isn't a plist loads nothing.
# What it tests:
#   - The tracked prefs file passes `plutil -lint`.
test_iterm_plist_valid() {
  plutil -lint "$PLIST" >/dev/null || _fail "$(plutil -lint "$PLIST")"
}

# Why this test is important:
#   - Switching to a profile that doesn't exist silently does nothing.
# What it tests:
#   - Every literal profile name 08-iterm.zsh switches to is a profile in the
#     tracked prefs (the generic `iterm-profile $1` helper is skipped).
test_iterm_profiles_exist() {
  local names missing
  names=$(python3 -c 'import plistlib, sys; print("\n".join(b["Name"] for b in plistlib.load(open(sys.argv[1], "rb"))["New Bookmarks"]))' "$PLIST") ||
    _fail "could not read profiles from the plist"
  missing=$(grep -oE "SetProfile=[^\\\"]+|iterm-profile '[^']+'" "$REPO_ROOT/zsh/conf.d/08-iterm.zsh" |
    sed -E "s/^SetProfile=//; s/^iterm-profile '(.*)'$/\1/" | grep -v '^\$' | sort -u |
    grep -vxF -f <(printf '%s\n' "$names"))
  assert_eq "" "$missing" "profiles 08-iterm.zsh names that the plist lacks"
}

# Why this test is important:
#   - Substring globs painted ~/code/products red ("prod") and */latest blue
#     ("test"), so the colour stopped meaning anything.
# What it tests:
#   - The tab colour (r,g,b) follows whole path segments only.
test_tab_color_globs_anchored() {
  local out
  out=$(ITERM_SESSION_ID=spec zsh_with '
    for d in prod/x products latest Developer/x dev stg/x test; do
      mkdir -p $HOME/$d && cd -q $HOME/$d
      rgb=(${${(f)"$(set_tab_color_by_dir | tr "\a" "\n")"}##*;})
      print -r -- "$d=${(j:,:)rgb}"
    done' 08-iterm.zsh 2>&1)
  assert_eq "prod/x=220,50,50
products=0,0,0
latest=0,0,0
Developer/x=0,0,0
dev=50,220,50
stg/x=220,165,0
test=50,50,220" "$out" "tab colours by directory"
}

# Why this test is important:
#   - An untracked lockfile lets every fresh machine install whatever plugin
#     commits are newest that day, so two machines never match.
# What it tests:
#   - git doesn't ignore nvim/lazy-lock.json, and its entries are exactly the
#     plugins in the lazy spec (read headlessly from this checkout's config).
test_lazy_lock_tracked_and_complete() {
  git -C "$REPO_ROOT" check-ignore -q nvim/lazy-lock.json && _fail "nvim/lazy-lock.json is gitignored"
  mkdir -p "$T/config"
  ln -s "$REPO_ROOT/nvim" "$T/config/nvim"
  local out
  out=$(XDG_CONFIG_HOME="$T/config" nvim --headless -c 'lua
    local ok, err = pcall(function()
      local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
      local plugins, diff = require("lazy.core.config").plugins, {}
      for name in pairs(plugins) do if not lock[name] then table.insert(diff, "unlocked:" .. name) end end
      for name in pairs(lock) do if not plugins[name] then table.insert(diff, "stale:" .. name) end end
      table.sort(diff)
      io.stdout:write(table.concat(diff, " "))
    end)
    if not ok then io.stdout:write("error: " .. tostring(err)) end' -c 'qall!' 2>/dev/null)
  assert_eq "" "$out" "lockfile vs lazy spec"
}

# Why this test is important:
#   - Headless nvim exits 0 even when a -c command fails (E492, a Lua error),
#     so an exit-status check alone still printed "ok" for a bootstrap that
#     never ran (the Treesitter step called a command that no longer exists).
# What it tests:
#   - With the real nvim and an empty config (no lazy.nvim, so :Lazy doesn't
#     exist), install.sh's Neovim bootstrap warns instead of reporting success.
test_nvim_bootstrap_reports_editor_errors() {
  export HOME="$T/home" XDG_CONFIG_HOME="$T/config" XDG_DATA_HOME="$T/data" XDG_STATE_HOME="$T/state" XDG_CACHE_HOME="$T/cache"
  mkdir -p "$HOME" "$XDG_CONFIG_HOME/nvim"
  local out
  # shellcheck source=../../install.sh
  out=$(source "$REPO_ROOT/install.sh" && bootstrap_nvim 2>&1 </dev/null)
  assert_contains "$out" "Neovim plugin restore failed" "bootstrap output"
  assert_not_contains "$out" "restored from lazy-lock.json" "bootstrap output"
}

run_test test_gitconfig_local_overrides_and_settings
run_test test_iterm_plist_valid
run_test test_iterm_profiles_exist
run_test test_tab_color_globs_anchored
run_test test_lazy_lock_tracked_and_complete
run_test test_nvim_bootstrap_reports_editor_errors
finish
