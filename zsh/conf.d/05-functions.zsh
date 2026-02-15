# Shell functions (docker, git, k8s, nvim, workflow, utilities)

# Unalias any conflicting aliases before defining functions
unalias dstop drm dprune dexec dlogs gcb gac gbdel kexec kpf v ve vrg vr vs vl vw proj tn ta dark light vf vg 2>/dev/null

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
  echo "This will remove all stopped containers, unused networks, dangling images, and build cache"
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

# --- Neovim Functions ---

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

# --- Workflow Functions ---

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
vf() { nvim -c "Telescope find_files"; }
vg() { nvim -c "Telescope live_grep"; }

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

# Unified search commands
search-github() { open "https://github.com/search?q=$(echo "$*" | sed 's/ /+/g')&type=repositories"; }
search-so() { open "https://stackoverflow.com/search?q=$(echo "$*" | sed 's/ /+/g')"; }
search-go() { open "https://pkg.go.dev/search?q=$(echo "$*" | sed 's/ /+/g')"; }
search-pypi() { open "https://pypi.org/search/?q=$(echo "$*" | sed 's/ /+/g')"; }

# Quick open in browser
ghub() {
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url" || echo "Not a git repo or no origin"
}

ghub-pr() {
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/pulls" || echo "Not a git repo"
}

ghub-issues() {
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/issues" || echo "Not a git repo"
}

ghub-actions() {
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  [ -n "$url" ] && open "$url/actions" || echo "Not a git repo"
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
  echo "Note added to $today.md"
}

# Check all projects for uncommitted changes
git-check-all() {
  echo "Checking projects for uncommitted changes..."
  for dir in ~/projects/*/; do
    if [ -d "$dir/.git" ]; then
      local status=$(git -C "$dir" status --porcelain 2>/dev/null)
      local branch=$(git -C "$dir" branch --show-current 2>/dev/null)
      if [ -n "$status" ]; then
        local name=$(basename "$dir")
        local changes=$(echo "$status" | wc -l | tr -d ' ')
        echo "  $name ($branch) - $changes uncommitted changes"
      fi
    fi
  done
  echo "Done"
}
