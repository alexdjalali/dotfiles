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
# Requires a Shortcuts.app shortcut named "Turn On Focus" (toggles Do Not Disturb).

# Enable Do Not Disturb
if shortcuts run "Turn On Focus" 2>/dev/null; then
    dnd="Do Not Disturb on"
else
    dnd="create a Shortcut named 'Turn On Focus' in Shortcuts.app to enable Do Not Disturb"
fi

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

echo "Focus mode enabled - $dnd"
