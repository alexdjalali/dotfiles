# FZF configuration and fzf-powered functions
# Note: fzf keybindings/completions are loaded via `fzf --zsh` below.
# The OMZ fzf plugin is NOT used (removed to avoid double-init).

# Load fzf keybindings and completions (single source of truth)
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

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

# Note: ^R is handled by atuin (09-tools.zsh), not fzf-history-widget

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

# Alias & function cheatsheet: searchable with fzf, Enter copies the name.
# Scans .zshrc, every conf.d module and ~/.zshrc.local; entries are tagged
# with their file.
helpme() {
  local conf_dir="${DOTFILES:-$HOME/dotfiles}/zsh/conf.d"
  local files=("${ZDOTDIR:-$HOME}/.zshrc" "$conf_dir"/*.zsh(N) "$HOME/.zshrc.local")
  local entries=() file line tag entry

  for file in $files; do
    [[ -r $file ]] || continue
    tag="[${${file:t}%.zsh}]"
    while IFS= read -r line; do
      if [[ $line =~ '^[[:space:]]*alias ([^=]+)=(.*)$' ]]; then
        printf -v entry '%-14s  %-40s  %s' "$match[1]" "$match[2]" "$tag"
        entries+=("$entry")
      elif [[ $line =~ '^[[:space:]]*(function[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_-]*)[[:space:]]*\(\)' ]]; then
        printf -v entry '%-14s  %-40s  %s' "$match[2]" "(function)" "$tag"
        entries+=("$entry")
      fi
    done < "$file"
  done

  printf '%s\n' "${entries[@]}" | fzf \
    --header="Aliases & Functions  (Enter=copy name)" \
    --bind "enter:execute-silent(echo {} | awk '{print \$1}' | tr -d '\n' | pbcopy)+abort"
}

# Bind Alt+H to helpme widget
_helpme_widget() { helpme; zle redisplay }
zle -N _helpme_widget
bindkey '^[h' _helpme_widget  # Alt+H (Ctrl+H often conflicts with backspace)
