# Aliases (Common Dev Shortcuts)

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
(( $+commands[dust] )) && alias duu='dust'
(( $+commands[procs] )) && alias pss='procs'
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
alias gss='git status --short --branch'
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
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'

# Go
alias dashboard='~/dashboard/dashboard'
alias gob='go build'
alias got='go test ./...'
alias gor='go run .'
alias gom='go mod tidy'

# Node / JS / TS (pnpm preferred)
alias ni='pnpm install'
alias nr='pnpm run'
alias nt='pnpm test'
alias nrd='pnpm dev'
alias ns='pnpm start'

# Python
alias venv='python3 -m venv venv && source venv/bin/activate'
alias py='python3'

# Neovim
alias nvimrc="nvim ~/.config/nvim/init.lua"
alias nvimplugins="nvim ~/.config/nvim/lua/plugins/"
alias nvimlua="cd ~/.config/nvim/lua"
alias nvimconf="cd ~/.config/nvim"
alias nvim-update="nvim --headless '+Lazy! sync' +qa"
alias nvim-clean="nvim --headless '+Lazy! clean' +qa"
alias nvim-check="nvim '+checkhealth'"
alias nvim-profile="nvim --startuptime /tmp/nvim-startup.log +q && cat /tmp/nvim-startup.log"
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'
alias vdiff='nvim -d'
alias vconflict="nvim \$(git diff --name-only --diff-filter=U)"
alias vmod="nvim \$(git ls-files -m)"
alias vstaged="nvim \$(git diff --name-only --cached)"
alias scratch="nvim +'set buftype=nofile' +'set bufhidden=hide' +'set noswapfile'"
alias note="nvim ~/notes/\$(date +%Y-%m-%d).md"
alias todo="nvim ~/notes/TODO.md"
alias lsp-check="nvim --headless -c 'LspInfo' -c 'qa'"
alias mason-status="nvim --headless -c 'Mason' -c 'qa'"
alias copyfile='pbcopy <'
alias vpaste='pbpaste | nvim -'

# macOS Clipboard
alias copy='pbcopy'
alias paste='pbpaste'

# Source .zsh
alias reload="source ~/.zshrc && echo 'Zsh config reloaded'"

# Scripts
alias macclean="$HOME/cleanmymac/cleanmymac run"
alias brewmaintain="$HOME/cleanmymac/cleanmymac run brewmaint"
alias aireview="$HOME/.local/scripts/git-ai-review.sh"

# Ports
alias ports='lsof -i -P -n'

# History helpers (h defined above)
alias htop10='history | awk "{print \$2}" | sort | uniq -c | sort -rn | head -10'

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
alias fortune='command fortune -s'
alias cowsay-random='fortune -s | cowsay -f $(ls /opt/homebrew/share/cows 2>/dev/null | shuf -n1 || echo "default")'
alias ascii='figlet'
alias banner='figlet -f banner'

# Markdown viewer (glow)
alias md='glow'
alias mdp='glow -p'

# Dev Environment
alias dev-start="open -a 'iTerm' && open -a 'Raycast' && open -a 'Rectangle' && open -a '1Password' && open -a 'Cursor'"
alias dev-docker="open -a 'Docker'"
alias dev-status="echo '=== Dev Tools Status ===' && pgrep -lf 'Docker|iTerm|Cursor|Raycast|Rectangle' 2>/dev/null | sort || echo 'No dev tools running'"
alias spotlight-off="sudo mdutil -a -i off && echo 'Spotlight indexing disabled'"
alias spotlight-on="sudo mdutil -a -i on && echo 'Spotlight indexing enabled'"
alias dev-health="echo '=== CPU ===' && top -l 1 | head -10 | tail -4; echo '=== Memory ===' && vm_stat | head -5; echo '=== Disk ===' && df -h / | tail -1"

# Default Tool Aliases
alias tp='open -a "TablePlus"'           # TablePlus (default DB client)
alias db='open -a "TablePlus"'           # Alias for database
alias api='open -a "Insomnia"'           # Insomnia (default API client)
alias lg='lazygit'                       # LazyGit (default git GUI)
alias linear='open -a "Linear"'          # Linear (project management)

# Notes (note defined in Neovim section above)
alias dev-docs='glow ~/.local/docs/dev-environment.md'
alias raycast-scripts='open ~/.local/scripts/raycast'

# Searches
alias gh-search='search-github'
alias so='search-so'
alias godoc='search-go'
alias pydoc='search-pypi'

# Open repo in browser (ghub pulls, ghub issues, ghub actions)
alias ghub-pr='ghub pulls'
alias ghub-issues='ghub issues'
alias ghub-actions='ghub actions'

# Git check all projects
alias gca='git-check-all'
