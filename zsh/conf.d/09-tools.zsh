# External tool initialization (direnv, atuin, mise, delta)

# Direnv - load directory-specific env (install: brew install direnv)
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Atuin - magical shell history (install: brew install atuin)
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# Mise - universal version manager (install: brew install mise)
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# Delta - beautiful git diffs (install: brew install delta)
(( $+commands[delta] )) && export GIT_PAGER='delta'

# Custom aliases file (optional)
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# Fastfetch splash on new terminal (skip inside tmux panes to avoid noise)
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$FASTFETCH_SHOWN" ]] && (( $+commands[fastfetch] )); then
  export FASTFETCH_SHOWN=1
  fastfetch --pipe false
fi
