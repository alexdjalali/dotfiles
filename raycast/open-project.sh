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

PROJECT_DIRS="$HOME/projects $HOME/work $HOME/dev"

if [ -n "$1" ]; then
    # Search for project by name
    for dir in $PROJECT_DIRS; do
        if [ -d "$dir/$1" ]; then
            PROJECT_PATH="$dir/$1"
            break
        fi
    done

    if [ -z "$PROJECT_PATH" ]; then
        # Try fuzzy find
        PROJECT_PATH=$(find $PROJECT_DIRS -maxdepth 2 -type d -name "*$1*" 2>/dev/null | head -1)
    fi
else
    # Use fzf to select (falls back to first project dir)
    PROJECT_PATH="$HOME/projects"
fi

if [ -z "$PROJECT_PATH" ]; then
    echo "Project not found: $1"
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
