# Visual enhancements (prompt, separators, project banners)
# Command durations come from the p10k command_execution_time segment.

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Rainbow separator
function rainbow_sep() {
  local cols=$(tput cols)
  printf '\033[38;5;81m%*s\033[0m\n' $cols '' | tr ' ' '-'
}

alias sep='rainbow_sep'

# Directory size
function dirsize() {
  local size=$(command du -sh . 2>/dev/null | cut -f1)
  echo "Directory size: $size"
}

alias ds='dirsize'

# Show project banner if .project-name exists
function show_project_banner() {
  if [[ -f .project-name ]] && (( $+commands[figlet] )); then
    figlet -f small "$(cat .project-name)" | lolcat 2>/dev/null || figlet -f small "$(cat .project-name)"
  fi
}

chpwd_functions+=(show_project_banner)
