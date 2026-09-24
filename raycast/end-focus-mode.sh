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
# Requires a Shortcuts.app shortcut named "Turn Off Focus" (toggles Do Not Disturb).

# Disable Do Not Disturb
if shortcuts run "Turn Off Focus" 2>/dev/null; then
    dnd="Do Not Disturb off"
else
    dnd="create a Shortcut named 'Turn Off Focus' in Shortcuts.app to disable Do Not Disturb"
fi

# Restore communication apps
open -a "Slack" 2>/dev/null
open -a "Mail" 2>/dev/null

# Unmute
osascript -e 'set volume without output muted'

echo "Focus mode disabled - $dnd"
