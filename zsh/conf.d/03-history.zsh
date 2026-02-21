# History, autosuggestions, syntax highlighting

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE  # Don't save commands starting with space

# Autosuggestions (Catppuccin Mocha)
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