# Environment, PATH, locale, exports

# Source local/private config (for API keys, tokens, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR="nvim"

# GPG — tell gpg-agent which TTY to use for passphrase prompts
export GPG_TTY=$(tty)

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

# Man pages (user-local)
export MANPATH="$HOME/local/share/man:$MANPATH"

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
