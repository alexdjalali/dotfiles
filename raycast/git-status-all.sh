#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Git Status All Projects
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📊
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Check git status of all projects
# @raycast.author Alex Djalali

PROJECT_DIRS="$HOME/projects $HOME/work $HOME/dev"

echo "Scanning projects for uncommitted changes..."
echo ""

for dir in $(find $PROJECT_DIRS -maxdepth 1 -mindepth 1 -type d 2>/dev/null); do
    if [ -d "$dir/.git" ]; then
        STATUS=$(git -C "$dir" status --porcelain 2>/dev/null)
        BRANCH=$(git -C "$dir" branch --show-current 2>/dev/null)

        if [ -n "$STATUS" ]; then
            NAME=$(basename "$dir")
            CHANGES=$(echo "$STATUS" | wc -l | tr -d ' ')
            echo "$NAME ($BRANCH) - $CHANGES uncommitted changes"
        fi
    fi
done

echo ""
echo "Scan complete"
