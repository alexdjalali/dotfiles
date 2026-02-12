#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Coding Layout
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Arrange windows for coding: iTerm left half, browser right half
# @raycast.author Alex Djalali

# Get screen dimensions
screen_width=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | awk -F', ' '{print $3}')
screen_height=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | awk -F', ' '{print $4}')

half_width=$((screen_width / 2))

# Position iTerm on left half
osascript << EOF
tell application "iTerm"
    activate
    set bounds of front window to {0, 25, $half_width, $screen_height}
end tell
EOF

# Position Chrome/Safari on right half
osascript << EOF
tell application "System Events"
    if exists process "Google Chrome" then
        tell application "Google Chrome"
            activate
            set bounds of front window to {$half_width, 25, $screen_width, $screen_height}
        end tell
    else if exists process "Safari" then
        tell application "Safari"
            activate
            set bounds of front window to {$half_width, 25, $screen_width, $screen_height}
        end tell
    end if
end tell
EOF

echo "Coding layout applied"
