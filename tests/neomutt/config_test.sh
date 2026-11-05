#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for the neomutt config (neomutt/.neomuttrc and the account examples).
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

NEOMUTT="$REPO_ROOT/neomutt"

# A throwaway HOME whose ~/.neomutt holds the example Gmail account, with the
# IMAP folder pointed at local maildirs (one per sidebar mailbox) and no SMTP
# URL, so neomutt parses the whole config without ever connecting.
make_home() {
  local box
  mkdir -p "$T/.neomutt"
  for box in INBOX "[Gmail]/Sent Mail" "[Gmail]/Drafts" "[Gmail]/Spam" "[Gmail]/Trash" "[Gmail]/All Mail"; do
    mkdir -p "$T/Mail/$box"/{cur,new,tmp}
  done
  sed -E -e "s|^set folder = .*|set folder = \"$T/Mail\"|" -e 's|^set smtp_url = .*|set smtp_url = ""|' \
    "$NEOMUTT/account.gmail.example" > "$T/.neomutt/account.gmail"
  ln -s "$NEOMUTT/.neomutt/catppuccin-mocha.neomuttrc" "$T/.neomutt/"
  : > "$T/.neomutt/aliases"
}

# Why this test is important:
#   - The IMAP cache holds real email; inside ~/.neomutt it lived in the git
#     working tree, one `git add -f` away from being committed.
# What it tests:
#   - The rc and the example account parse with no errors, and header_cache,
#     message_cache_dir and tmp_dir resolve under ~/.cache/neomutt.
test_cache_paths_outside_repo() {
  make_home
  mock_cmd security "dummy-password"
  local out
  out=$(HOME="$T" neomutt -n -F "$NEOMUTT/.neomuttrc" -Q header_cache -Q message_cache_dir -Q tmp_dir 2>"$T/err" </dev/null)
  assert_eq "" "$(cat "$T/err")" "neomutt config errors"
  assert_contains "$out" 'header_cache = "~/.cache/neomutt/headers"' "neomutt -Q"
  assert_contains "$out" 'message_cache_dir = "~/.cache/neomutt/bodies"' "neomutt -Q"
  assert_contains "$out" 'tmp_dir = "~/.cache/neomutt/tmp"' "neomutt -Q"
}

# Why this test is important:
#   - Folder names are the account's business: the global rc must stay
#     account-agnostic so an account can be added without editing it.
# What it tests:
#   - The global rc names no Gmail folder, and the Gmail account example
#     defines every folder macro (gi gs gd gt ga A).
test_folder_macros_live_in_the_account() {
  assert_eq 0 "$(grep -c '\[Gmail\]' "$NEOMUTT/.neomuttrc")" "[Gmail] mentions in .neomuttrc"
  local key
  for key in gi gs gd gt ga A; do
    grep -qE "^macro index,pager $key " "$NEOMUTT/account.gmail.example" || _fail "no '$key' folder macro"
  done
}

# Why this test is important:
#   - The Georgia Tech account was removed; leftover switch macros or OAuth
#     tooling would point at files that no longer exist.
# What it tests:
#   - No GT account, authorizer, OAuth helper or multi-account guide remains,
#     and the rc neither switches accounts nor mentions GT.
test_single_gmail_account() {
  local f
  for f in account.gatech.example .neomutt/authorize_gatech.sh .neomutt/mutt_oauth2.py .neomutt/MULTI-ACCOUNT.md; do
    [[ -e "$NEOMUTT/$f" ]] && _fail "$f should be gone"
  done
  assert_eq 0 "$(grep -ciE 'gatech|georgia|office ?365|<f3>' "$NEOMUTT/.neomuttrc")" "GT mentions in .neomuttrc"
}

# Why this test is important:
#   - A plaintext password file under ~/.neomutt sat inside the repo tree,
#     guarded only by .gitignore.
# What it tests:
#   - The Gmail example reads its password from the macOS Keychain.
test_secrets_outside_repo() {
  local gmail
  gmail=$(grep -E '^set (imap|smtp)_pass' "$NEOMUTT/account.gmail.example")
  assert_eq 2 "$(grep -c 'security find-generic-password -s neomutt-gmail' <<<"$gmail")" "Keychain-backed passwords"
  assert_not_contains "$gmail" "gmail.pass" "Gmail password source"
}

run_test test_cache_paths_outside_repo
run_test test_folder_macros_live_in_the_account
run_test test_single_gmail_account
run_test test_secrets_outside_repo
finish
