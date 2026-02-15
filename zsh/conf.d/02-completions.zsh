# Completion configuration and fzf-tab

# Completion tweaks (compinit already run by Oh My Zsh)
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' complete-options true

# Group completions by category with Catppuccin Mocha-styled headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format $'\e[38;2;137;180;250m-- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[38;2;249;226;175m-- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[38;2;243;139;168m-- no matches --\e[0m'

# Better sorting and caching
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=34=31'
zstyle ':completion:*:*:kill:*' menu yes select

# fzf-tab configuration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || cat $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || cat $realpath'
zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || cat $realpath'
zstyle ':fzf-tab:*' fzf-flags --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=border:#6c7086
zstyle ':fzf-tab:*' switch-group '<' '>'

# GitHub CLI completions (cached to avoid fork on every shell start)
if (( $+commands[gh] )); then
  if [[ ! -f ~/.zsh_completions/_gh || ~/.zsh_completions/_gh -ot $(whence -p gh) ]]; then
    mkdir -p ~/.zsh_completions
    gh completion -s zsh > ~/.zsh_completions/_gh
  fi
  fpath=(~/.zsh_completions $fpath)
fi

# Makefile target completion
_make_targets() {
  if [[ -f Makefile ]]; then
    local targets=$(command grep -E '^[a-zA-Z_-]+:' Makefile | cut -d: -f1)
    _arguments "1: :($targets)"
  fi
}
compdef _make_targets make
