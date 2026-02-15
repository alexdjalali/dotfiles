#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Focus Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎯
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Enable focus mode: DND on, close distractions, open dev tools
# @raycast.author Alex Djalali

# Enable Do Not Disturb
shortcuts run "Turn On Focus" 2>/dev/null || \
osascript -e 'tell application "System Events" to keystroke "D" using {control down, command down}' 2>/dev/null

# Quit distracting apps
osascript -e 'tell application "Slack" to quit' 2>/dev/null
osascript -e 'tell application "Discord" to quit' 2>/dev/null
osascript -e 'tell application "Messages" to quit' 2>/dev/null
osascript -e 'tell application "Mail" to quit' 2>/dev/null
osascript -e 'tell application "Twitter" to quit' 2>/dev/null

# Open work apps
open -a "iTerm"

# Play focus sound (optional)
# afplay /System/Library/Sounds/Glass.aiff

echo "Focus mode enabled - time to code!"
