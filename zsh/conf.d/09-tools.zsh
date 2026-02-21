# External tool initialization (direnv, atuin, mise, nvm)

# Direnv - load directory-specific env (install: brew install direnv)
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Atuin - magical shell history (install: brew install atuin)
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# Mise - universal version manager (install: brew install mise)
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# Lazy load nvm (saves ~200ms startup time; use function, not alias, for proper arg forwarding)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# Fastfetch splash on new terminal (skip inside tmux panes to avoid noise)
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$FASTFETCH_SHOWN" ]] && (( $+commands[fastfetch] )); then
  export FASTFETCH_SHOWN=1
  fastfetch --pipe false
fi
