# Environment, PATH, locale, exports

# Source local/private config (for API keys, tokens, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR="nvim"

# Go
export GOPATH="$HOME/go"

# PATHs (consolidated, zsh array form, deduplicated)
# Highest priority first — Homebrew (Apple Silicon) before Intel path
path=(
  /opt/homebrew/bin
  /usr/local/bin
  $HOME/bin
  $HOME/.local/bin
  $HOME/.local/scripts
  $HOME/.cargo/bin(N)
  $HOME/.bun/bin(N)
  $HOME/Library/Python/3.*/bin(N)
  $GOPATH/bin
  $path
)
typeset -U path  # deduplicate

# Catppuccin Mocha theme for bat
export BAT_THEME="Catppuccin Mocha"

# Catppuccin Mocha-inspired colors for eza/ls
export EZA_COLORS="\
uu=38;5;137:\
gu=38;5;109:\
sn=38;5;150:\
sb=38;5;150:\
da=38;5;110:\
ur=38;5;110:\
uw=38;5;204:\
ux=38;5;150:\
ue=38;5;150:\
gr=38;5;110:\
gw=38;5;204:\
gx=38;5;150:\
tr=38;5;110:\
tw=38;5;204:\
tx=38;5;150:"

# iTerm2 integration
if [ -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Terminal environment detection
detect_terminal() {
  local env=""
  [[ -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && env+="ssh "
  [[ -n "$TMUX" ]] && env+="tmux "
  [[ -n "$ITERM_SESSION_ID" ]] && env+="iterm "
  [[ -z "$env" ]] && env="plain "
  echo "${env% }"  # trim trailing space
}

# Export flags for use in conditionals
export TERM_IS_SSH=$([[ -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] && echo 1 || echo 0)
export TERM_IS_TMUX=$([[ -n "$TMUX" ]] && echo 1 || echo 0)
export TERM_IS_ITERM=$([[ -n "$ITERM_SESSION_ID" ]] && echo 1 || echo 0)

# Visual SSH indicator
if [[ "$TERM_IS_SSH" == "1" ]]; then
  export SSH_INDICATOR="[remote] "
fi

# Lazy load nvm (saves ~200ms startup time; use function, not alias, for proper arg forwarding)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}
