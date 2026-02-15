#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open in Neovim
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "file or directory", "optional": true }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open file or directory in Neovim (iTerm)
# @raycast.author Alex Djalali

TARGET="${1:-.}"

# Expand ~ to home directory
TARGET="${TARGET/#\~/$HOME}"

# Open iTerm and run nvim
osascript <<EOF
tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd \"$(dirname "$TARGET")\" && nvim \"$TARGET\""
        end tell
    end tell
end tell
EOF

echo "Opened $TARGET in Neovim"
