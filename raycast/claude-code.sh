#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Claude Code
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "directory (optional)", "optional": true }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open Claude Code CLI in iTerm
# @raycast.author Alex Djalali

# Raycast runs scripts from their own folder, so default to $HOME, not $(pwd)
DIR="${1:-$HOME}"
DIR="${DIR/#\~/$HOME}"

osascript <<EOF
tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd \"$DIR\" && claude"
        end tell
    end tell
end tell
EOF

echo "Opened Claude Code in $DIR"
