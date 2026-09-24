#!/usr/bin/env bash
# Helpers for testing zsh/conf.d modules; source after tests/lib/assert.sh.
#
# zsh_with CODE MODULE... runs a non-interactive `zsh -f` with HOME=$T (so
# ~/.zshrc.local and the user's git config never leak in), sources each
# conf.d MODULE by file name, then runs CODE. The pseudo-module `compinit`
# initializes the completion system, which 02-completions.zsh needs.

zsh_with() {
  local code=$1
  shift
  local src="" f
  for f in "$@"; do
    if [[ $f == compinit ]]; then
      src+="autoload -Uz compinit; compinit -D -u -d $T/.zcompdump; "
    else
      src+="source $REPO_ROOT/zsh/conf.d/$f; "
    fi
  done
  # 01-env.zsh prepends Homebrew to $path; keep the mocks in front of it.
  src+="path=(${MOCK_BIN} \$path); "
  HOME="$T" DOTFILES="$REPO_ROOT" zsh -f -c "$src$code" </dev/null
}
