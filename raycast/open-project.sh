#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Project
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "project name", "optional": true }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open project directory in iTerm + Neovim
# @raycast.author Alex Djalali

# Raycast doesn't load the zsh config, so read the effective PROJECT_ROOTS
# (default + any ~/.zshrc.local override) from zsh/conf.d/01-env.zsh.
ENV_ZSH="$(cd "$(dirname "$0")" && pwd -P)/../zsh/conf.d/01-env.zsh"
if [ ! -f "$ENV_ZSH" ]; then
    echo "Can't find $ENV_ZSH: run this script from the dotfiles raycast/ folder (install.sh links it)"
    exit 1
fi
# shellcheck disable=SC2016  # $1 and $PROJECT_ROOTS are expanded by zsh
ROOTS=$(zsh -f -c 'source "$1" >/dev/null 2>&1; print -r -- "$PROJECT_ROOTS"' _ "$ENV_ZSH")
IFS=: read -ra roots <<< "$ROOTS"
PROJECT_PATH=""

if [ -n "${1:-}" ]; then
    # Exact name directly under a root
    for dir in "${roots[@]}"; do
        if [ -d "$dir/$1" ]; then
            PROJECT_PATH="$dir/$1"
            break
        fi
    done

    # Otherwise the first directory (one or two levels below a root, never the
    # root itself or anything hidden like .git) whose name contains it
    if [ -z "$PROJECT_PATH" ]; then
        for dir in "${roots[@]}"; do
            [ -d "$dir" ] || continue
            PROJECT_PATH=$(find "$dir" -mindepth 1 -maxdepth 2 -name '.*' -prune -o -type d -name "*$1*" -print 2>/dev/null | head -1)
            [ -n "$PROJECT_PATH" ] && break
        done
    fi
else
    # No argument: open the first project root that exists
    for dir in "${roots[@]}"; do
        if [ -d "$dir" ]; then
            PROJECT_PATH="$dir"
            break
        fi
    done
fi

if [ -z "$PROJECT_PATH" ]; then
    echo "Project not found: ${1:-}"
    exit 1
fi

# Open in iTerm with nvim
osascript <<EOF
tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd \"$PROJECT_PATH\" && nvim"
        end tell
    end tell
end tell
EOF

echo "Opened $PROJECT_PATH"
