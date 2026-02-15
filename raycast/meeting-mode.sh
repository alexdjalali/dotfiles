#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Meeting Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📹
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Enable meeting mode: DND on, close distracting apps, open Zoom
# @raycast.author Alex Djalali

# Enable Do Not Disturb (macOS Monterey+)
shortcuts run "Turn On Focus" 2>/dev/null || \
osascript -e 'tell application "System Events" to keystroke "D" using {control down, command down}' 2>/dev/null

# Quit distracting apps
osascript -e 'tell application "Slack" to quit' 2>/dev/null
osascript -e 'tell application "Discord" to quit' 2>/dev/null
osascript -e 'tell application "Messages" to quit' 2>/dev/null
osascript -e 'tell application "Mail" to quit' 2>/dev/null

# Open Zoom if installed
if [ -d "/Applications/zoom.us.app" ]; then
    open -a "zoom.us"
fi

# Mute system audio
osascript -e 'set volume with output muted'

echo "Meeting mode enabled"
