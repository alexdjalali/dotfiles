# ==============================================================
# 🧠 Developer ZSH Configuration (macOS + iTerm2)
# Optimized for Go, Python, Node/TS, Docker, Kubernetes, Git
# ==============================================================

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
  # autojump  # removed — using zoxide instead
  docker
  kubectl
  fzf
  history-substring-search
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# --------------------------------------------------------------
# 🧩 Completions and Performance
# --------------------------------------------------------------

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

# --------------------------------------------------------------
# ⚙️ Environment Setup
# --------------------------------------------------------------

# Supermemory (Claude Code plugin — persistent memory)
# IMPORTANT: Set your own API key or source from ~/.zshrc.local
# export SUPERMEMORY_CC_API_KEY="your-api-key-here"

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
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.local/scripts
  $HOME/.cargo/bin(N)
  $HOME/Library/Python/3.*/bin(N)
  /usr/local/bin
  /opt/homebrew/bin
  $path
  $GOPATH/bin
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

# Scripts (PATH set above in consolidated path array)

# --------------------------------------------------------------
# 🎨 Powerlevel10k
# --------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 🧠 History Configuration
# --------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE  # Don't save commands starting with space

# --------------------------------------------------------------
# 🔍 Autosuggestions and Syntax Highlighting (Catppuccin Mocha)
# --------------------------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Catppuccin Mocha-themed syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# Main highlighter colors (Catppuccin Mocha palette)
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=#f38ba8,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=#cba6f7,bold
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=#a6e3a1,underline
ZSH_HIGHLIGHT_STYLES[global-alias]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[precommand]=fg=#a6e3a1,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=#a6e3a1,underline
ZSH_HIGHLIGHT_STYLES[path]=fg=#cdd6f4,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=#f9e2af
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=#f9e2af
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=#f9e2af
ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=#f5c2e7
ZSH_HIGHLIGHT_STYLES[redirection]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[comment]=fg=#585b70,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=#a6e3a1

# Bracket highlighter (Catppuccin Mocha colors)
ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=#f38ba8,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=#89dceb,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=#a6e3a1,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=#cba6f7,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=#f9e2af,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=#89b4fa,bold
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout

# --------------------------------------------------------------
# ⚡ Global Alias Expansion
# --------------------------------------------------------------
globalias() {
   if [[ $LBUFFER =~ '[a-zA-Z0-9]+$' ]]; then
       zle _expand_alias
       zle expand-word
   fi
   zle self-insert
}
zle -N globalias
bindkey " " globalias
bindkey "^[[Z" magic-space
bindkey -M isearch " " magic-space

# --------------------------------------------------------------
# 🧰 Performance: Lazy Load Heavy Tools
# --------------------------------------------------------------

# Lazy load nvm (saves ~200ms startup time)
export NVM_DIR="$HOME/.nvm"
alias nvm='unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@'

# --------------------------------------------------------------
# 🧠 Aliases (Common Dev Shortcuts)
# --------------------------------------------------------------

# General
alias ll='ls -lah'
alias cls='clear'
alias h='history | grep'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Modern CLI replacements (install: brew install eza bat ripgrep fd dust)
# Uses $+commands (zsh hash lookup, no fork)
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias la='eza --icons -a --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias lt='eza --icons --tree --level=2'
  alias llt='eza -la --icons --tree --level=2 --git'
fi
if (( $+commands[bat] )); then
  alias cat='bat --style=plain'
  alias ccat='/bin/cat'  # Original cat
fi
# Use rg/fd directly — don't alias over grep/find (breaks scripts using GNU flags)
(( $+commands[rg] )) && alias rgg='rg'
(( $+commands[fd] )) && alias fdd='fd'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[procs] )) && alias ps='procs'
if (( $+commands[btop] )); then
  alias top='btop'
  alias htop='btop'
fi
(( $+commands[duf] )) && alias df='duf'

# Safety aliases
alias rm='rm -i'
alias rmf='/bin/rm -f'
alias mv='mv -i'
alias cp='cp -i'

# Git
alias gs='git status'
alias ga='git add -u'  # only tracked files; use git add . explicitly when needed
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gd='git diff'
alias gco='git checkout'
alias gundo='git reset --soft HEAD~1'
alias glog='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gclean='echo "Run: git clean -fd (destructive, no alias)"'
alias grh='echo "Run: git reset --hard (destructive, no alias)"'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gpr='gh pr create --fill'
alias gpv='gh pr view --web'

# Custom workflow scripts (~/.local/scripts)
alias gbs='git-branch-stack.sh'       # Branch stack management
alias dreset='docker-reset.sh'        # Docker cluster reset
alias e2e='pipeline-e2e.sh'           # ML pipeline E2E testing
alias prr='pr-review.sh'              # PR review workflow

# Documentation (~/.local/docs)
alias docs='glow ~/.local/docs/README.md'
alias docs-git='glow ~/.local/docs/git-workflow.md'
alias docs-api='glow ~/.local/docs/api-development.md'
alias docs-docker='glow ~/.local/docs/docker-containers.md'
alias docs-quality='glow ~/.local/docs/code-quality.md'
alias docs-productivity='glow ~/.local/docs/productivity.md'
alias docs-scripts='glow ~/.local/docs/custom-scripts.md'

# Docker
alias d='docker'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kga='kubectl get all'
alias kctx='kubectl config get-contexts'
alias kuse='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kl='kubectl logs -f'

# Docker Compose
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Go
alias gob='go build'
alias got='go test ./...'
alias gor='go run .'
alias gom='go mod tidy'

# Node / JS / TS
alias ni='npm install'
alias nr='npm run'
alias nt='npm test'
alias nrd='npm run dev'
alias ns='npm start'

# Python
alias venv='python3 -m venv venv && source venv/bin/activate'
alias py='python3'
alias pip='pip3'

# Neovim
alias nvimrc="nvim ~/.config/nvim/init.lua"
alias nvimplugins="nvim ~/.config/nvim/lua/plugins/"
alias nvimlua="cd ~/.config/nvim/lua"
alias nvimconf="cd ~/.config/nvim"
alias nvim-update="nvim --headless '+Lazy! sync' +qa"
alias nvim-clean="nvim --headless '+Lazy! clean' +qa"
alias nvim-check="nvim --headless '+checkhealth' +qa"
alias nvim-profile="nvim --startuptime /tmp/nvim-startup.log +q && cat /tmp/nvim-startup.log"
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'
alias vconflict="nvim \$(git diff --name-only --diff-filter=U)"
alias vmod="nvim \$(git ls-files -m)"
alias vstaged="nvim \$(git diff --name-only --cached)"
alias scratch="nvim +'set buftype=nofile' +'set bufhidden=hide' +'set noswapfile'"
alias note="nvim ~/notes/\$(date +%Y-%m-%d).md"
alias todo="nvim ~/notes/TODO.md"
alias lsp-check="nvim --headless -c 'LspInfo' -c 'qa'"
alias mason-status="nvim --headless -c 'Mason' -c 'qa'"
alias diff="nvim -d"
alias copyfile='pbcopy <'
alias vpaste='pbpaste | nvim -'

# macOS Clipboard
alias copy='pbcopy'
alias paste='pbpaste'

# Source .zsh
alias reload="source ~/.zshrc && echo '🔁 Zsh config reloaded!'"

# Scripts
alias macclean="$HOME/.local/scripts/mac-cleanup.sh"
alias brewmaintain="$HOME/.local/scripts/brew-maintain.sh"
alias aireview="$HOME/.local/scripts/git-ai-review.sh"

# Ports
alias ports='lsof -i -P -n'

# History helpers (h defined above)
alias htop10='history | awk "{print \$2}" | sort | uniq -c | sort -rn | head -10'

# --------------------------------------------------------------
# 🛠️ Useful Functions
# --------------------------------------------------------------

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

# Unalias any conflicting aliases before defining functions
unalias dstop drm dprune dexec dlogs gcb gac gbdel kexec kpf v ve vrg vr vs vl vw proj tn ta gdiff dark light vf vg 2>/dev/null

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Docker: Stop all running containers
dstop() {
  local containers=$(docker ps -q)
  [[ -n "$containers" ]] && docker stop $containers || echo "No running containers"
}

# Docker: Remove all stopped containers
drm() {
  local containers=$(docker ps -aq)
  [[ -n "$containers" ]] && docker rm $containers || echo "No containers to remove"
}

# Docker: System prune (with confirmation)
dprune() {
  echo "⚠️  This will remove all stopped containers, unused networks, dangling images, and build cache"
  read "reply?Continue? (y/N) "
  [[ $reply =~ ^[Yy]$ ]] && docker system prune -af
}

# Docker: Exec into running container
dexec() { docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh; }

# Docker: Follow logs
dlogs() { docker logs -f "$1"; }

# Git: Create and checkout branch
gcb() { git checkout -b "$1"; }

# Git: Add all and commit
gac() { git add . && git commit -m "$1"; }

# Git: Delete branch
gbdel() { git branch -d "$1"; }

# Kubernetes: Exec into pod
kexec() { kubectl exec -it "$1" -- /bin/bash || kubectl exec -it "$1" -- /bin/sh; }

# Kubernetes: Port forward helper
kpf() { kubectl port-forward "$1" "$2:$2"; }

# Find process using port
port() { lsof -i ":$1"; }

# Kill process on port
killport() {
  local pid=$(lsof -ti ":$1")
  [[ -n "$pid" ]] && kill -9 $pid && echo "Killed process on port $1" || echo "No process on port $1"
}

# Quick web server
serve() { python3 -m http.server "${1:-8000}"; }

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.gz|*.tgz) tar -xzf "$1" ;;
      *.tar.bz2|*.tbz2) tar -xjf "$1" ;;
      *.tar.xz) tar -xJf "$1" ;;
      *.tar) tar -xf "$1" ;;
      *.zip) unzip "$1" ;;
      *.rar) unrar x "$1" ;;
      *.7z) 7z x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *) echo "Unknown archive format: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
}

# Quick backup of a file
backup() { cp "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"; }

# Show PATH in readable format
path() { echo $PATH | tr ':' '\n'; }

# --------------------------------------------------------------
# 🎯 Neovim Functions
# --------------------------------------------------------------

# Open file at specific line (e.g., v file.txt:42)
v() {
  if [[ $1 =~ ^(.+):([0-9]+):?([0-9]*)$ ]]; then
    nvim "+${match[2]}" "${match[1]}"
  else
    nvim "$@"
  fi
}

# FZF edit with live preview
ve() {
  local file=$(fzf --preview 'bat --color=always --line-range=:50 {}')
  [[ -n "$file" ]] && nvim "$file"
}

# FZF ripgrep edit (search content then open in nvim)
vrg() {
  local file=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  if [[ -n "$file" ]]; then
    nvim "+${file##*:}" "${file%%:*}"
  fi
}

# FZF recent files (nvim oldfiles)
vr() {
  local file=$(nvim --headless -c "echo join(v:oldfiles, '\n')" -c "qa!" 2>&1 | fzf --preview 'bat --color=always {}')
  [[ -n "$file" ]] && nvim "$file"
}

# Save nvim session for current directory
vs() {
  local session_name="${1:-$(basename $PWD)}"
  mkdir -p ~/.config/nvim/sessions
  nvim -c "mksession! ~/.config/nvim/sessions/${session_name}.vim" -c "qa"
  echo "Session saved: ${session_name}"
}

# Load nvim session
vl() {
  local session=$(find ~/.config/nvim/sessions -name "*.vim" 2>/dev/null | fzf --preview 'cat {}')
  [[ -n "$session" ]] && nvim -S "$session"
}

# Auto-restore session if exists
vw() {
  local session="$HOME/.config/nvim/sessions/$(basename $PWD).vim"
  if [[ -f "$session" ]]; then
    nvim -S "$session"
  else
    nvim
  fi
}

# Git diff in nvim
gdiff() {
  git diff "$@" | nvim -R -
}

# Backup nvim config
nvim-backup() {
  local backup_dir="$HOME/.config/nvim-backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  cp -r ~/.config/nvim/* "$backup_dir/"
  echo "Nvim config backed up to: $backup_dir"
}

# Restore nvim config from backup
nvim-restore() {
  local backup=$(fd -t d . ~/.config/nvim-backups 2>/dev/null | fzf)
  if [[ -n "$backup" ]]; then
    rm -rf ~/.config/nvim/*
    cp -r "$backup"/* ~/.config/nvim/
    echo "Restored from: $backup"
  fi
}

# --------------------------------------------------------------
# 🚀 Workflow Functions
# --------------------------------------------------------------

# Quick project switcher with fzf + nvim
proj() {
  local project=$(fd -t d -d 3 . ~/projects ~/work ~/dev 2>/dev/null | fzf --preview 'eza --tree --level=2 {}')
  if [[ -n "$project" ]]; then
    cd "$project"
    nvim
  fi
}

# Create tmux session with nvim
tn() {
  if [[ -n "$TMUX" ]]; then
    echo "Already inside tmux. Use 'tmux new-session -d -s name' to create a detached session."
    return 1
  fi
  local session_name="${1:-$(basename $PWD)}"
  tmux new-session -s "$session_name" -d
  tmux send-keys -t "$session_name" "nvim" C-m
  tmux attach -t "$session_name"
}

# Attach to existing tmux or create new
ta() {
  if [[ -n "$TMUX" ]]; then
    echo "Already inside tmux. Use 'tmux switch-client -t <session>' to switch sessions."
    return 1
  fi
  if tmux ls 2>/dev/null; then
    tmux attach -t "$(tmux ls | fzf | cut -d: -f1)"
  else
    tn
  fi
}

# Telescope shortcuts (if using Telescope in nvim)
vf() {
  nvim -c "Telescope find_files"
}

vg() {
  nvim -c "Telescope live_grep"
}

# Switch to dark mode (iTerm + system)
dark() {
  iterm-profile 'Dark'
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
}

# Switch to light mode
light() {
  iterm-profile 'Light'
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
}

# --------------------------------------------------------------
# 🎨 Visual Enhancements
# --------------------------------------------------------------

# Command execution time tracker (pure zsh, no python fork)
zmodload zsh/datetime 2>/dev/null
VISUAL_TIMER_START=0
function visual_preexec() {
  VISUAL_TIMER_START=$EPOCHREALTIME
}

function visual_precmd() {
  if (( VISUAL_TIMER_START > 0 )); then
    local elapsed=$(( EPOCHREALTIME - VISUAL_TIMER_START ))
    if (( elapsed > 1 )); then
      printf '\n\033[0;36m⏱  Took %.2fs\033[0m\n' $elapsed
    fi
    VISUAL_TIMER_START=0
  fi
}

preexec_functions+=(visual_preexec)
precmd_functions+=(visual_precmd)

# Directory info panel (pure zsh glob — no subprocess)
function dir_info() {
  local files=( *(N.) )
  local dirs=( *(N/) )
  local git_branch=$(git branch --show-current 2>/dev/null)

  if (( ${#files} > 0 || ${#dirs} > 0 )); then
    echo -e "\n\033[0;36m📁 Files: ${#files} | 📂 Dirs: ${#dirs}\033[0m"
  fi
  [[ -n "$git_branch" ]] && echo -e "\033[0;32m  $git_branch\033[0m"
}

chpwd_functions+=(dir_info)

# Background jobs indicator (pure zsh — no subprocess)
function check_background_jobs() {
  local job_count=${#jobstates}
  (( job_count > 0 )) && echo -e "\033[1;33m⚙️  $job_count background job(s) running\033[0m"
}

precmd_functions+=(check_background_jobs)

# Kubernetes context visual indicator
function k8s_context_visual() {
  if (( $+commands[kubectl] )); then
    local ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$ctx" ]]; then
      case "$ctx" in
        *prod*) echo -e "\n\033[1;31m☸  K8s: $ctx (PRODUCTION)\033[0m" ;;
        *stg*|*staging*) echo -e "\n\033[1;33m☸  K8s: $ctx (STAGING)\033[0m" ;;
        *dev*) echo -e "\n\033[1;32m☸  K8s: $ctx (DEV)\033[0m" ;;
        *) echo -e "\n\033[0;36m☸  K8s: $ctx\033[0m" ;;
      esac
    fi
  fi
}

# Uncomment to show k8s context before each prompt
# precmd_functions+=(k8s_context_visual)

# Rainbow separator
function rainbow_sep() {
  local cols=$(tput cols)
  printf '\033[38;5;81m%*s\033[0m\n' $cols '' | tr ' ' '─'
}

alias sep='rainbow_sep'

# Directory size
function dirsize() {
  local size=$(du -sh . 2>/dev/null | cut -f1)
  echo -e "\033[0;36m📦 Directory size: $size\033[0m"
}

alias ds='dirsize'

# Automatic iTerm2 profile switching
function iterm_profile_switch() {
  case "$PWD" in
    */production*|*/prod*)
      echo -e "\033]50;SetProfile=Production\a" 2>/dev/null
      ;;
    */staging*|*/stage*|*/stg*)
      echo -e "\033]50;SetProfile=Staging\a" 2>/dev/null
      ;;
    */development*|*/dev*)
      echo -e "\033]50;SetProfile=Development\a" 2>/dev/null
      ;;
    *)
      echo -e "\033]50;SetProfile=Default\a" 2>/dev/null
      ;;
  esac
}

# Enable auto profile switching (iTerm2 only — no-op if profiles don't exist)
[[ -n "$ITERM_SESSION_ID" ]] && chpwd_functions+=(iterm_profile_switch)

# Show project banner if .project-name exists
function show_project_banner() {
  if [[ -f .project-name ]] && (( $+commands[figlet] )); then
    figlet -f small "$(cat .project-name)" | lolcat 2>/dev/null || figlet -f small "$(cat .project-name)"
  fi
}

chpwd_functions+=(show_project_banner)

# --------------------------------------------------------------
# 🧰 FZF Integration (if installed via brew)
# --------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enhanced FZF settings with Catppuccin Mocha theme
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border rounded
  --info=inline
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=border:#6c7086,selected-bg:#45475a
  --prompt '  ' --pointer '' --marker ''"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find .'

# Use fzf for history search
bindkey '^R' fzf-history-widget

# FZF file opener
fopen() {
  local file=$(fzf --preview 'bat --color=always {} 2>/dev/null || cat {}')
  [[ -n "$file" ]] && $EDITOR "$file"
}

# FZF cd into directory
fcd() {
  local dir=$(fd --type d 2>/dev/null | fzf --preview 'eza --tree --level=1 {} 2>/dev/null || ls -la {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# FZF git checkout
fco() {
  local branch=$(git branch -a | command grep -v HEAD | sed 's/^..//' | fzf --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {}')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# FZF kubernetes pod logs
klogs() {
  local pod=$(kubectl get pods --no-headers | fzf | awk '{print $1}')
  [[ -n "$pod" ]] && kubectl logs -f "$pod"
}

# FZF kubernetes exec
kfexec() {
  local pod=$(kubectl get pods --no-headers | fzf | awk '{print $1}')
  [[ -n "$pod" ]] && kubectl exec -it "$pod" -- /bin/bash
}

# FZF docker logs
dflogs() {
  local container=$(docker ps --format '{{.Names}}' | fzf)
  [[ -n "$container" ]] && docker logs -f "$container"
}

# FZF git diff files
fgd() {
  local file=$(git diff --name-only | fzf --preview 'git diff --color=always {}')
  [[ -n "$file" ]] && nvim "$file"
}

# Alias & function cheatsheet — searchable with fzf
helpme() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local section=""
  local section_next=""
  local entries=()

  while IFS= read -r line; do
    # Detect section headers: "# ------" followed by "# Title" followed by "# ------"
    if [[ "$line" =~ '^# [-]+$' ]]; then
      section_next=1
      continue
    elif [[ -n "$section_next" && "$line" =~ '^# [^-]' ]]; then
      section="${line#\# }"
      section="${section#* }"  # strip leading emoji
      unset section_next
      continue
    elif [[ -n "$section_next" ]]; then
      unset section_next
    fi

    # Capture alias definitions
    if [[ "$line" =~ "^alias " ]]; then
      local name="${line#alias }"
      name="${name%%=*}"
      local value="${line#*=}"
      entries+=("$(printf '%-14s  %-40s  %s' "$name" "$value" "[$section]")")
    fi

    # Capture function definitions (oneliner and block)
    if [[ "$line" =~ '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' ]]; then
      local fname="${line%%\(*}"
      entries+=("$(printf '%-14s  %-40s  %s' "$fname" "(function)" "[$section]")")
    fi
  done < "$zshrc"

  printf '%s\n' "${entries[@]}" | fzf \
    --header="Aliases & Functions  (Enter=copy, Ctrl-X=run)" \
    --preview='echo {}' \
    --preview-window=hidden \
    --bind "enter:execute-silent(echo {} | awk '{print \$1}' | tr -d '\n' | pbcopy)+abort" \
    --bind "ctrl-x:become(eval \$(echo {} | awk '{print \$1}'))"
}

# Bind Alt+H to helpme widget
_helpme_widget() { helpme; zle redisplay }
zle -N _helpme_widget
bindkey '^[h' _helpme_widget  # Alt+H (Ctrl+H often conflicts with backspace)

# --------------------------------------------------------------
# 🔧 Tool Completions
# --------------------------------------------------------------

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

# --------------------------------------------------------------
# 🚀 Optional Modern Tools
# --------------------------------------------------------------

# Zoxide - smarter cd (install: brew install zoxide)
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# Direnv - load directory-specific env (install: brew install direnv)
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Atuin - magical shell history (install: brew install atuin)
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# Mise - universal version manager (install: brew install mise)
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# Delta - beautiful git diffs (install: brew install delta)
(( $+commands[delta] )) && export GIT_PAGER='delta'

# --------------------------------------------------------------
# 💡 Final Touches
# --------------------------------------------------------------

# Custom aliases file (optional)
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# lsd - another beautiful ls replacement
if (( $+commands[lsd] )); then
  alias lsd='lsd --icon always --group-directories-first'
  alias lsda='lsd -la --icon always --group-directories-first'
  alias lsdt='lsd --tree --depth 2 --icon always'
fi

# Fastfetch splash on new terminal (only for interactive, non-nested shells)
if [[ $- == *i* ]] && [[ -z "$FASTFETCH_SHOWN" ]] && (( $+commands[fastfetch] )); then
  export FASTFETCH_SHOWN=1
  fastfetch
fi

# --------------------------------------------------------------
# 🧹 End of .zshrc
# --------------------------------------------------------------

# Git branch visualization
alias gtree="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
alias git-tree-all="git log --all --graph --decorate --oneline --abbrev-commit"

# Enhanced git status with icons
alias gss='git status --short --branch'

# --------------------------------------------------------------
# 🎨 Visual Tool Aliases
# --------------------------------------------------------------

# Weather
alias weather='curl -s "wttr.in/?format=3"'
alias weather-full='curl -s "wttr.in/?0"'

# Code statistics
alias stats='tokei'
alias code-stats='tokei --sort lines'

# JSON pretty viewing
alias json='jq -C . | less -R'
alias json-compact='jq -c .'
alias jsonview='fx'

# Enhanced tree views
alias tree='eza --tree --icons --git-ignore --level=3'
alias tree-all='eza --tree --icons --all --level=3'
alias tree-git='eza --tree --icons --git --level=3'
alias tree-type='eza --tree --icons --group-directories-first --color=always --level=3'
alias tree2='eza --tree --level=2 --icons'
alias tree4='eza --tree --level=4 --icons'

# Fun stuff
alias fortune='fortune -s'
alias cowsay-random='fortune -s | cowsay -f $(ls /opt/homebrew/share/cows 2>/dev/null | shuf -n1 || echo "default")'
alias ascii='figlet'
alias banner='figlet -f banner'

# Markdown viewer (glow)
alias md='glow'
alias mdp='glow -p'

# Note: glog is defined earlier in the Git aliases section

# --------------------------------------------------------------
# 🛠️ Dev Environment Optimization Aliases
# --------------------------------------------------------------

# Start all dev tools at once
alias dev-start="open -a 'iTerm' && open -a 'Raycast' && open -a 'Rectangle' && open -a '1Password' && open -a 'Cursor'"

# Start Docker Desktop
alias dev-docker="open -a 'Docker'"

# Check status of running dev tools
alias dev-status="echo '=== Dev Tools Status ===' && pgrep -lf 'Docker|iTerm|Cursor|Raycast|Rectangle' 2>/dev/null | sort || echo 'No dev tools running'"

# Spotlight control
alias spotlight-off="sudo mdutil -a -i off && echo 'Spotlight indexing disabled'"
alias spotlight-on="sudo mdutil -a -i on && echo 'Spotlight indexing enabled'"

# Quick system health check
alias dev-health="echo '=== CPU ===' && top -l 1 | head -10 | tail -4; echo '=== Memory ===' && vm_stat | head -5; echo '=== Disk ===' && df -h / | tail -1"

# --------------------------------------------------------------
# 🖥️ iTerm2 Optimizations
# --------------------------------------------------------------

# iTerm2 badge with current directory and git branch
# (lazy-cache tool versions on first prompt, not at shell startup)
function iterm2_print_user_vars() {
  iterm2_set_user_var gitBranch "$(git branch --show-current 2>/dev/null)"
  iterm2_set_user_var currentDir "$(basename "$PWD")"
  if [[ -z "$_CACHED_PYTHON_VERSION" ]]; then
    _CACHED_PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    _CACHED_NODE_VERSION=$(node --version 2>/dev/null)
  fi
  iterm2_set_user_var pythonVersion "$_CACHED_PYTHON_VERSION"
  iterm2_set_user_var nodeVersion "$_CACHED_NODE_VERSION"
}

# Quick iTerm2 profile switching
function iterm-profile() {
  echo -e "\033]50;SetProfile=$1\a"
}

# Set iTerm2 tab color based on directory
function iterm-tab-color() {
  echo -ne "\033]6;1;bg;red;brightness;$1\a"
  echo -ne "\033]6;1;bg;green;brightness;$2\a"
  echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}

# Auto-set tab colors based on directory
function set_tab_color_by_dir() {
  case "$PWD" in
    *production*|*prod*) iterm-tab-color 220 50 50 ;;  # Red for production
    *staging*|*stg*) iterm-tab-color 220 165 0 ;;      # Orange for staging
    *development*|*dev*) iterm-tab-color 50 220 50 ;;  # Green for dev
    *test*) iterm-tab-color 50 50 220 ;;               # Blue for test
    *) iterm-tab-color 0 0 0 ;;                        # Black (default)
  esac
}

# Run on every directory change
chpwd_functions+=(set_tab_color_by_dir)

# iTerm2 marks for quick navigation
alias mark="iterm2_set_user_var mark 📍"

# Split pane shortcuts (requires iTerm2 shell integration)
alias vsplit="echo -e '\033]1337;SetProfile=DevOps Optimized\a' && echo 'Use ⌘D for vertical split'"
alias hsplit="echo -e '\033]1337;SetProfile=DevOps Optimized\a' && echo 'Use ⌘⇧D for horizontal split'"

# Clear scrollback buffer
alias clear-all="clear && printf '\e[3J'"

# iTerm2 profile shortcuts
alias iterm-dev="iterm-profile 'DevOps Optimized'"
alias iterm-light="iterm-profile 'Light'"
alias iterm-dark="iterm-profile 'Dark'"
alias iterm-here="open -a iTerm \$PWD"

# Set iTerm2 title dynamically
function set-iterm-title() {
  echo -ne "\033]0;$1\007"
}

# Auto-set title based on command (use hook arrays, not bare functions)
function _iterm_title_preexec() {
  set-iterm-title "$1"
}

function _iterm_title_precmd() {
  set-iterm-title "$(basename $PWD)"
}

preexec_functions+=(_iterm_title_preexec)
precmd_functions+=(_iterm_title_precmd)

# Send notification when long nvim sessions end
alias nvim-notify='nvim; echo -e "\a"; osascript -e "display notification \"Nvim session ended\" with title \"iTerm2\""'

# --------------------------------------------------------------
# 🔗 Unified Tool Integration (Raycast + Default Apps)
# --------------------------------------------------------------

# Default Tool Aliases
alias tp='open -a "TablePlus"'           # TablePlus (default DB client)
alias db='open -a "TablePlus"'           # Alias for database
alias api='open -a "Insomnia"'           # Insomnia (default API client)
alias lg='lazygit'                       # LazyGit (default git GUI)
alias linear='open -a "Linear"'          # Linear (project management)

# Quick Note (adds timestamped note to daily file)
qn() {
  local notes_dir="$HOME/notes"
  local today=$(date +%Y-%m-%d)
  local note_file="$notes_dir/$today.md"

  mkdir -p "$notes_dir"

  if [ ! -f "$note_file" ]; then
    echo "# Notes for $today" > "$note_file"
    echo "" >> "$note_file"
  fi

  local timestamp=$(date +%H:%M)
  echo "- [$timestamp] $*" >> "$note_file"
  echo "✅ Note added to $today.md"
}

# Open today's notes
alias notes='nvim ~/notes/$(date +%Y-%m-%d).md'

# Development environment docs
alias dev-docs='glow ~/.local/docs/dev-environment.md'

# Open Raycast script folder (for adding new scripts)
alias raycast-scripts='open ~/.local/scripts/raycast'

# Unified search commands
search-github() { open "https://github.com/search?q=$(echo "$*" | sed 's/ /+/g')&type=repositories"; }
search-so() { open "https://stackoverflow.com/search?q=$(echo "$*" | sed 's/ /+/g')"; }
search-go() { open "https://pkg.go.dev/search?q=$(echo "$*" | sed 's/ /+/g')"; }
search-pypi() { open "https://pypi.org/search/?q=$(echo "$*" | sed 's/ /+/g')"; }

# Aliases for searches
alias gh-search='search-github'
alias so='search-so'
alias godoc='search-go'
alias pydoc='search-pypi'

# Quick open in browser
ghub() {
  # Open current repo in GitHub
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url" || echo "Not a git repo or no origin"
}

ghub-pr() {
  # Open PRs for current repo
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/pulls" || echo "Not a git repo"
}

ghub-issues() {
  # Open issues for current repo
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/issues" || echo "Not a git repo"
}

ghub-actions() {
  # Open GitHub Actions for current repo
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/actions" || echo "Not a git repo"
}

# Quick Claude Code launcher
cc() {
  local dir="${1:-.}"
  cd "$dir" && claude
}

# Combined dev opener - open project with all tools
dev-open() {
  local project_dir="${1:-.}"
  cd "$project_dir"

  # Start Docker if docker-compose exists
  [ -f "docker-compose.yml" ] && dcup

  # Open in Neovim
  nvim
}

# Check all projects for uncommitted changes
git-check-all() {
  echo "🔍 Checking projects for uncommitted changes..."
  for dir in ~/projects/*/; do
    if [ -d "$dir/.git" ]; then
      cd "$dir"
      local status=$(git status --porcelain 2>/dev/null)
      local branch=$(git branch --show-current 2>/dev/null)
      if [ -n "$status" ]; then
        local name=$(basename "$dir")
        local changes=$(echo "$status" | wc -l | tr -d ' ')
        echo "📁 $name ($branch) - $changes uncommitted changes"
      fi
    fi
  done
  echo "✅ Done"
}

alias gca='git-check-all'

# --------------------------------------------------------------
# 🎯 End of Unified Tool Integration
# --------------------------------------------------------------

