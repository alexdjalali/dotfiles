# ZSH Configuration - Bootstrap
# All configuration lives in conf.d/ modules sourced below.

### Powerlevel10k Instant Prompt — keep this near the top ###
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Oh My Zsh ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable Oh My Zsh auto-update (must be set before sourcing)
DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT="true"

# Plugins
plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  kubectl
  fzf
  history-substring-search
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# Dotfiles root (used by conf.d modules)
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Source all conf.d modules in order
for conf in "$DOTFILES/zsh/conf.d/"*.zsh(N); do
  source "$conf"
done

# Zoxide - smarter cd (MUST be at end of .zshrc)
# Use `z` / `zi` directly — aliasing cd breaks fzf-tab previews and scripts
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
