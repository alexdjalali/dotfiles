# Visual enhancements (timer, separators, project banners, prompt)

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Command execution time tracker (pure zsh, no python fork)
# Skip in Warp — it shows command duration natively in block headers
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
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
fi

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
