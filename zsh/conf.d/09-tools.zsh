# External tool initialization (direnv, atuin, mise, nvm)

# Cache-and-source a tool's shell-init script; regenerate only when the binary
# is newer than the cache. Avoids forking each tool on every shell startup.
# Also used by zoxide in .zshrc (which is sourced after this file).
_cache_init() {
  local name="$1"; shift
  (( $+commands[$name] )) || return 0
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init/${name}.zsh"
  if [[ ! -s "$cache" || "$cache" -ot "$commands[$name]" ]]; then
    mkdir -p "${cache:h}"
    "$@" > "$cache" 2>/dev/null
    [[ -s "$cache" ]] || { command rm -f "$cache"; "$@"; return; }
  fi
  source "$cache"
}

# Direnv - load directory-specific env (install: brew install direnv)
_cache_init direnv direnv hook zsh

# Atuin - magical shell history (install: brew install atuin)
_cache_init atuin atuin init zsh --disable-up-arrow

# Mise - universal version manager (install: brew install mise)
_cache_init mise mise activate zsh

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
