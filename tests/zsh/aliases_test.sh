#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# shellcheck disable=SC2016  # zsh code is passed to zsh_with unexpanded on purpose
# Tests for the tracked aliases and prompt hooks in zsh/conf.d/*.zsh.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"
# shellcheck source=../lib/zsh.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/zsh.sh"

# Why this test is important:
#   - Aliases that shadow real tools (pydoc, godoc) break those tools.
# What it tests:
#   - pydoc/godoc are not aliases, and the duplicate tree2 alias is gone.
test_aliases_are_hygienic() {
  mock_cmd eza
  local out
  out=$(zsh_with 'for a in pydoc godoc tree2; do alias $a || echo "$a: no alias"; done' 04-aliases.zsh 2>&1)
  assert_contains "$out" "pydoc: no alias" "pydoc"
  assert_contains "$out" "godoc: no alias" "godoc"
  assert_contains "$out" "tree2: no alias" "tree2"
}

# Why this test is important:
#   - `gac` staged everything (`git add .`), sweeping untracked scratch files
#     into commits; it must match the tracked-only `ga`.
# What it tests:
#   - After `gac msg`, the tracked change is committed as "msg" and an
#     untracked file is still untracked.
test_gac_commits_tracked_changes_only() {
  make_repo "$T/repo"
  printf 'v1\n' > "$T/repo/tracked.txt"
  git -C "$T/repo" add tracked.txt
  git -C "$T/repo" -c user.name=t -c user.email=t@example.com commit -qm init
  printf 'v2\n' > "$T/repo/tracked.txt"
  printf 'scratch\n' > "$T/repo/new.txt"
  GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com \
    zsh_with "cd $T/repo && gac msg" 05-functions.zsh >/dev/null 2>&1
  assert_eq "msg" "$(git -C "$T/repo" log -1 --format=%s)" "last commit subject"
  assert_eq "?? new.txt" "$(git -C "$T/repo" status --porcelain)" "working tree after gac"
}

# Why this test is important:
#   - Every eza-backed alias must degrade gracefully on a machine without eza.
# What it tests:
#   - With no eza on PATH, the tree alias is not defined.
test_tree_alias_needs_eza() {
  local out
  out=$(PATH="$MOCK_BIN:/usr/bin:/bin" zsh_with 'alias tree || echo "tree: no alias"' 04-aliases.zsh 2>&1)
  assert_contains "$out" "tree: no alias" "tree alias without eza"
}

# Why this test is important:
#   - Aliases pointing at files this repo doesn't track break on every other
#     machine; they belong in the untracked ~/.zshrc.local.
# What it tests:
#   - None of the machine-only aliases/functions is defined by the tracked config.
test_machine_only_aliases_not_tracked() {
  local out
  out=$(zsh_with 'for n in gbs dreset e2e prr docs docs-git dev-docs dashboard macclean brewmaintain aireview aws-export-tf; do whence -w $n; done' \
    04-aliases.zsh 05-functions.zsh 10-aws.zsh 2>&1)
  local n
  for n in gbs dreset e2e prr docs docs-git dev-docs dashboard macclean brewmaintain aireview aws-export-tf; do
    assert_contains "$out" "$n: none" "whence -w $n"
  done
}

# Why this test is important:
#   - Two timers printed every slow command's duration twice.
# What it tests:
#   - Loading 07-visual.zsh registers no preexec timer (p10k owns durations).
test_no_duplicate_timer() {
  local out
  out=$(zsh_with 'print -l -- "${preexec_functions[@]}" "${precmd_functions[@]}"' 07-visual.zsh 2>&1)
  assert_not_contains "$out" "visual_preexec" "preexec hooks"
  assert_not_contains "$out" "visual_precmd" "precmd hooks"
}

# Why this test is important:
#   - ~/.zshrc.local loads first, so a tracked alias of the same name silently
#     beats it; overrides that must win need a hook that loads last.
# What it tests:
#   - After the whole .zshrc loads, an alias from ~/.zshrc.local.post replaces
#     the tracked alias of the same name.
test_zshrc_local_post_wins() {
  echo "alias gs='echo post'" > "$T/.zshrc.local.post"
  local out
  out=$(HOME="$T" DOTFILES="$REPO_ROOT" zsh -f -c "source $REPO_ROOT/zsh/.zshrc 2>/dev/null; alias gs" </dev/null)
  assert_eq "gs='echo post'" "$out" "gs after .zshrc"
}

# Why this test is important:
#   - install.sh links ~/.zshrc from wherever the repo is cloned; a .zshrc that
#     assumed ~/dotfiles loaded no conf.d module from any other clone.
# What it tests:
#   - With DOTFILES unset, .zshrc (reached through a ~/.zshrc link) sets
#     DOTFILES to the repo it lives in.
test_zshrc_finds_its_repo() {
  ln -s "$REPO_ROOT/zsh/.zshrc" "$T/.zshrc"
  local out
  out=$(env -u DOTFILES HOME="$T" zsh -f -c "source ~/.zshrc 2>/dev/null; print -r -- \$DOTFILES" </dev/null)
  assert_eq "$REPO_ROOT" "$out" "DOTFILES"
}

run_test test_aliases_are_hygienic
run_test test_gac_commits_tracked_changes_only
run_test test_tree_alias_needs_eza
run_test test_machine_only_aliases_not_tracked
run_test test_no_duplicate_timer
run_test test_zshrc_local_post_wins
run_test test_zshrc_finds_its_repo
finish
