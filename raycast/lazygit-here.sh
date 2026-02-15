#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title LazyGit
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌿
# @raycast.argument1 { "type": "text", "placeholder": "directory (optional)", "optional": true }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open LazyGit in iTerm
# @raycast.author Alex Djalali

DIR="${1:-$HOME/projects}"
DIR="${DIR/#\~/$HOME}"

osascript <<EOF
tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd \"$DIR\" && lazygit"
        end tell
    end tell
end tell
EOF

echo "Opened LazyGit in $DIR"
