# Visual enhancements (timer, k8s indicator, separators, project banners)

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
      printf '\n\033[0;36m  Took %.2fs\033[0m\n' $elapsed
    fi
    VISUAL_TIMER_START=0
  fi
}

preexec_functions+=(visual_preexec)
precmd_functions+=(visual_precmd)

# Kubernetes context visual indicator
function k8s_context_visual() {
  if (( $+commands[kubectl] )); then
    local ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$ctx" ]]; then
      case "$ctx" in
        *prod*) echo -e "\n\033[1;31mK8s: $ctx (PRODUCTION)\033[0m" ;;
        *stg*|*staging*) echo -e "\n\033[1;33mK8s: $ctx (STAGING)\033[0m" ;;
        *dev*) echo -e "\n\033[1;32mK8s: $ctx (DEV)\033[0m" ;;
        *) echo -e "\n\033[0;36mK8s: $ctx\033[0m" ;;
      esac
    fi
  fi
}

# Uncomment to show k8s context before each prompt
# precmd_functions+=(k8s_context_visual)

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
