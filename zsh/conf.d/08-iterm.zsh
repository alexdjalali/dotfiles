# iTerm2-specific configuration (badges, tab colors, titles, profiles)

# iTerm2 badge with current directory and git branch
# (lazy-cache tool versions on first prompt, not at shell startup)
function iterm2_print_user_vars() {
  iterm2_set_user_var currentDir "$(basename "$PWD")"
  # Only query git inside a work tree to avoid hangs on network mounts
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    iterm2_set_user_var gitBranch "$(git branch --show-current 2>/dev/null)"
  else
    iterm2_set_user_var gitBranch ""
  fi
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
alias mark="iterm2_set_user_var mark"

# Split pane shortcuts (requires iTerm2 shell integration)
alias vsplit="echo 'Use Cmd+D for vertical split'"
alias hsplit="echo 'Use Cmd+Shift+D for horizontal split'"

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
