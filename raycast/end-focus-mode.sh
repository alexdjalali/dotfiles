#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title End Focus Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☀️
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Disable focus mode: DND off, restore apps
# @raycast.author Alex Djalali

# Disable Do Not Disturb
shortcuts run "Turn Off Focus" 2>/dev/null || \
osascript -e 'tell application "System Events" to keystroke "D" using {control down, command down}' 2>/dev/null

# Restore communication apps
open -a "Slack" 2>/dev/null
open -a "Mail" 2>/dev/null

# Unmute
osascript -e 'set volume without output muted'

echo "Focus mode disabled - welcome back!"
