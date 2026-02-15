# FZF configuration and fzf-powered functions

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
# Scans all conf.d files plus .zshrc for aliases and functions
helpme() {
  local conf_dir="${DOTFILES:-$HOME/dotfiles}/zsh/conf.d"
  local section=""
  local section_next=""
  local entries=()

  # Scan all zsh config files
  local files=("${ZDOTDIR:-$HOME}/.zshrc")
  [[ -d "$conf_dir" ]] && files+=("$conf_dir"/*.zsh(N))

  for zshrc in "${files[@]}"; do
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
  done

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
