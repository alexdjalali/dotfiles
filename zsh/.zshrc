# ZSH Configuration - Bootstrap
# All configuration lives in conf.d/ modules sourced below.

### Powerlevel10k Instant Prompt — keep this near the top ###
# Skip in Warp (has its own prompt rendering; instant prompt causes visual glitches)
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Oh My Zsh ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable Oh My Zsh auto-update (must be set before sourcing)
DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT="true"

# Plugins
# - git: REMOVED — defines ~176 aliases; custom aliases in conf.d/04-aliases.zsh instead
# - fzf: REMOVED — double-inits with conf.d/06-fzf.zsh
# - history-substring-search: REMOVED — atuin handles history (conf.d/09-tools.zsh)
plugins=(
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  kubectl
  colored-man-pages
)

# Add fpath entries BEFORE sourcing OMZ so compinit picks them up on first pass
# GitHub CLI completions (cached to avoid fork on every shell start)
if (( $+commands[gh] )); then
  if [[ ! -f ~/.zsh_completions/_gh || ~/.zsh_completions/_gh -ot $(whence -p gh) ]]; then
    mkdir -p ~/.zsh_completions
    gh completion -s zsh > ~/.zsh_completions/_gh
  fi
  fpath=(~/.zsh_completions $fpath)
fi

# Additional completions (user-local)
fpath=(~/.zsh/functions $fpath)

source $ZSH/oh-my-zsh.sh

# Dotfiles root (used by conf.d modules)
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Source all conf.d modules in order
for conf in "$DOTFILES/zsh/conf.d/"*.zsh(N); do
  source "$conf"
done

# Zoxide - smarter cd (MUST be at end of .zshrc)
# Use `z` / `zi` directly — aliasing cd breaks fzf-tab previews and scripts
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
